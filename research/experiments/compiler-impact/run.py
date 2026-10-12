#!/usr/bin/env python3
"""Compile and execute the seven annotated AMi benchmarks from C sources."""

import argparse
import csv
import hashlib
import importlib
from importlib.metadata import version
import io
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import traceback

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
EVAL = ROOT / "evaluation"
BENCHMARKS = ("triangle", "ifthenloop", "modexp2", "mulmod16", "keypad", "bsl", "fork")
EXPECTED_EVALUATION = "e0478ef7e280fe63f8f6932a3fd5d94ef1730ba3"
EXPECTED_COMPILERS = {
    "original": "383a9a6c18e5869698e2be5eca1dfc57fd04c05a",
    "ghost-fixed": "f160e224b5f040b340b3ae0693b41dacc0458ef0",
}
GROUPS = (
    "baseline", "sese_ir", "triangle_ir", "molnar", "ami_pcfl",
    "ami_sese", "ami_triangle", "manual_molnar", "manual_ami",
)
AUTO_GROUPS = GROUPS[:7]
IR_PASSES = {
    "baseline": None,
    "reducible": "function(fix-irreducible,loop-simplify)",
    "triangle": "function(fix-irreducible,loop-simplify,structurizecfg)",
    "sese": "function(fix-irreducible,loop-simplify,structurizecfg,branch-enhance)",
}
GROUP_IR = {
    "baseline": "baseline", "sese_ir": "sese", "triangle_ir": "triangle",
    "molnar": "triangle", "ami_pcfl": "reducible",
    "ami_sese": "sese", "ami_triangle": "triangle",
}
FIELDS = (
    "benchmark", "compiler", "group", "status", "size_bytes", "cycles",
    "size_ratio", "cycle_ratio", "ami_instructions", "molnar_predicate", "transform_note",
    "source_sha256", "ir_sha256", "asm_sha256", "binary_sha256", "error",
)


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def git_head(path):
    return subprocess.check_output(["git", "-C", str(path), "rev-parse", "HEAD"], text=True).strip()


def run(command, cwd, log):
    log.write("$ " + " ".join(map(str, command)) + "\n")
    log.flush()
    result = subprocess.run([str(x) for x in command], cwd=cwd, stdout=log,
                            stderr=subprocess.STDOUT, timeout=120)
    if result.returncode:
        raise RuntimeError(f"command failed ({result.returncode}): {command[0]}")


def make_ir(bin_dir, src, work, log):
    clang, opt = bin_dir / "clang", bin_dir / "opt"
    raw = work / "baseline.ll"
    run([clang, "-O3", "-nostdlib", "-std=c2x", "--target=riscv32",
         "-march=rv32im", "-I", EVAL, "-S", "-emit-llvm", src,
         "-o", raw], work, log)
    paths = {"baseline": raw}
    for name in ("reducible", "triangle", "sese"):
        dest = work / f"{name}.ll"
        run([opt, "-S", f"-passes={IR_PASSES[name]}", raw, "-o", dest], work, log)
        paths[name] = dest
    return paths


def compile_support(bin_dir, benchmark, work, log):
    clang = bin_dir / "clang"
    result = []
    for source in (EVAL / "boot.S", EVAL / benchmark / "main.c", HERE / "cfl_taken.c"):
        output = work / (source.stem + ".o")
        run([clang, "-O3", "-nostdlib", "-std=c2x", "--target=riscv32",
             "-march=rv32im", "-I", EVAL, "-c", source, "-o", output], work, log)
        result.append(output)
    return result


def generate_asm(bin_dir, group, ir_paths, benchmark, work, log):
    if group.startswith("manual_"):
        suffix = "-linear.s" if group == "manual_molnar" else "-linear-ami.s"
        return EVAL / benchmark / (benchmark + suffix), None
    ir = ir_paths[GROUP_IR[group]]
    asm = work / (group + ".s")
    command = [bin_dir / "llc", "-O3", "-mtriple=riscv32", "-mattr=+m"]
    if group == "molnar":
        command += ["-riscv-enable-molnar-linearization=true"]
    if group.startswith("ami_"):
        command += ["-riscv-enable-ami-linearization=true"]
        if group == "ami_pcfl":
            command += ["-riscv-ami-general-linearization=true"]
    command += [ir, "-o", asm]
    run(command, work, log)
    return asm, ir


def compile_and_run(bin_dir, sim, benchmark, group, asm, support, work, log):
    obj = work / "benchmark.o"
    elf = work / "program.elf"
    binary = work / "program.bin"
    run([bin_dir / "clang", "-O3", "-nostdlib", "--target=riscv32",
         "-march=rv32im", "-c", asm, "-o", obj], work, log)
    objects = [support[0], support[1], obj]
    if group == "molnar":
        objects.append(support[2])
    run(["/opt/riscv/bin/riscv32-unknown-elf-gcc", "-march=rv32im",
         "-mabi=ilp32", "-ffreestanding", "-nostdlib", "-T", EVAL / "link.ld",
         "-o", elf, *objects], work, log)
    run(["/opt/riscv/bin/riscv32-unknown-elf-objcopy", "-O", "binary", elf, binary], work, log)
    run([sim, binary], work, log)
    return binary


def evaluate(benchmark, work):
    sys.path.insert(0, str(EVAL))
    from ProteusVCD import ProteusVCD
    vcd = ProteusVCD(str(work / "sim.vcd"))
    checker = importlib.import_module(f"{benchmark}.{benchmark}")
    checker.verify_correctness(benchmark, io.StringIO(), vcd)
    return int(vcd.total_cycles())


def one(args, compiler, bin_dir, benchmark, group, output):
    row = dict.fromkeys(FIELDS, "")
    row.update(benchmark=benchmark, compiler=compiler, group=group, status="failed")
    log_path = output / "logs" / f"{benchmark}-{compiler}-{group}.log"
    log_path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="ami-compiler-impact-") as temp:
        work = Path(temp)
        with log_path.open("w") as log:
            try:
                source = EVAL / benchmark / f"{benchmark}.c"
                row["source_sha256"] = sha(source)
                ir_paths = make_ir(bin_dir, source, work, log) if group in AUTO_GROUPS else {}
                support = compile_support(bin_dir, benchmark, work, log)
                asm, ir = generate_asm(bin_dir, group, ir_paths, benchmark, work, log)
                asm_text = asm.read_text()
                row["ir_sha256"] = sha(ir) if ir else ""
                if ir:
                    ir_target = output / "ir" / benchmark / compiler
                    ir_target.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(ir, ir_target / f"{group}.ll")
                row["asm_sha256"] = sha(asm)
                row["ami_instructions"] = len(re.findall(r"\b(?:a|m|p|g)\.[a-z][a-z0-9]*\b", asm_text))
                row["molnar_predicate"] = int("cfl_taken" in asm_text)
                target = output / "assembly" / benchmark / compiler
                target.mkdir(parents=True, exist_ok=True)
                shutil.copy2(asm, target / f"{group}.s")
                if group.startswith("ami_") and not row["ami_instructions"]:
                    baseline_asm, _ = generate_asm(bin_dir, "baseline", ir_paths, benchmark, work, log)
                    has_branch = re.search(
                        r"(?m)^\s*(?:beq|bne|blt|bge|bltu|bgeu|beqz|bnez|blez|bgez|bltz|bgtz)\s",
                        baseline_asm.read_text(),
                    )
                    if has_branch:
                        raise RuntimeError("no AMi instruction despite a baseline conditional branch")
                    row["transform_note"] = "optimized_branchless"
                if group == "molnar" and not row["molnar_predicate"]:
                    raise RuntimeError("no Molnar predicate; secret branch was not transformed")
                binary = compile_and_run(bin_dir, args.sim, benchmark, group, asm, support, work, log)
                row["binary_sha256"] = sha(binary)
                row["size_bytes"] = binary.stat().st_size
                row["cycles"] = evaluate(benchmark, work)
                row["status"] = "ok"
            except Exception as exc:
                row["error"] = str(exc).replace("\n", " ")[:300]
                traceback.print_exc(file=log)
    return row


def metadata(args, compilers):
    return {
        "ami_commit": git_head(ROOT), "proteus_core": "riscv.CoreExtMem",
        "evaluation_commit": git_head(EVAL),
        "evaluation_patch_sha256": sha(ROOT / "patches/evaluation.patch"),
        "secret_patch_sha256": sha(HERE / "evaluation-secret.patch"),
        "sim_sha256": sha(args.sim),
        "compiler_commits": {
            "original": git_head(args.original_source),
            "ghost-fixed": git_head(args.fixed_source),
        },
        "compiler_binaries": {name: {tool: sha(bin_dir / tool) for tool in ("clang", "opt", "llc")}
                              for name, bin_dir in compilers.items()},
        "gcc": subprocess.check_output(["/opt/riscv/bin/riscv32-unknown-elf-gcc", "--version"], text=True).splitlines()[0],
        "python": sys.version.split()[0], "vcdvcd": version("vcdvcd"),
        "groups": list(GROUPS), "benchmarks": list(BENCHMARKS),
        "ir_passes": IR_PASSES,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--original-bin", type=Path, required=True)
    parser.add_argument("--fixed-bin", type=Path, required=True)
    parser.add_argument("--original-source", type=Path, required=True)
    parser.add_argument("--fixed-source", type=Path, required=True)
    parser.add_argument("--sim", type=Path, default=ROOT / "sim/build/sim")
    parser.add_argument("--output", type=Path, default=HERE / "results")
    parser.add_argument("--benchmarks", nargs="+", choices=BENCHMARKS, default=BENCHMARKS)
    parser.add_argument("--groups", nargs="+", choices=GROUPS, default=GROUPS)
    parser.add_argument("--compilers", nargs="+", choices=("original", "ghost-fixed"),
                        default=("original", "ghost-fixed"))
    args = parser.parse_args()
    for name, source in (("original", args.original_source), ("ghost-fixed", args.fixed_source)):
        actual = git_head(source)
        if actual != EXPECTED_COMPILERS[name]:
            parser.error(f"{name} LLVM must be at {EXPECTED_COMPILERS[name]}, got {actual}")
    if git_head(EVAL) != EXPECTED_EVALUATION:
        parser.error(f"evaluation must be at {EXPECTED_EVALUATION}")
    args.output.mkdir(parents=True, exist_ok=True)
    compilers = {"original": args.original_bin.resolve(), "ghost-fixed": args.fixed_bin.resolve()}
    (args.output / "metadata.json").write_text(json.dumps(metadata(args, compilers), indent=2) + "\n")
    rows = []
    for benchmark in args.benchmarks:
        for compiler in args.compilers:
            for group in args.groups:
                if group.startswith("manual_") and compiler != "original":
                    continue
                row = one(args, compiler, compilers[compiler], benchmark, group, args.output)
                rows.append(row)
                print(f"{benchmark:12} {compiler:11} {group:15} {row['status']:6} {row['error']}", flush=True)
                with (args.output / "results.csv").open("w", newline="") as f:
                    writer = csv.DictWriter(f, fieldnames=FIELDS)
                    writer.writeheader()
                    writer.writerows(rows)
    for row in rows:
        baseline = next((x for x in rows if x["benchmark"] == row["benchmark"]
                         and x["compiler"] == row["compiler"] and x["group"] == "baseline"
                         and x["status"] == "ok"), None)
        if baseline and row["status"] == "ok":
            row["size_ratio"] = round(row["size_bytes"] / baseline["size_bytes"], 4)
            row["cycle_ratio"] = round(row["cycles"] / baseline["cycles"], 4)
    with (args.output / "results.csv").open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(rows)
    failures = sum(row["status"] != "ok" for row in rows)
    print(f"Completed {len(rows)} runs, {failures} failures; results: {args.output}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
