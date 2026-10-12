#!/usr/bin/env python3
"""Check completeness and hashes of a seven-benchmark result directory."""

import csv
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
RESULTS = HERE / "results"
GROUPS = ("baseline", "sese_ir", "triangle_ir", "molnar",
          "ami_pcfl", "ami_sese", "ami_triangle")
BENCHMARKS = ("triangle", "ifthenloop", "modexp2", "mulmod16", "keypad", "bsl", "fork")


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    rows = list(csv.DictReader((RESULTS / "results.csv").open(newline="")))
    metadata = json.loads((RESULTS / "metadata.json").read_text())
    assert len(rows) == 112 and all(row["status"] == "ok" for row in rows)
    assert digest(HERE / "evaluation-secret.patch") == metadata["secret_patch_sha256"]
    assert len(list((RESULTS / "ir").rglob("*.ll"))) == 98
    assert len(list((RESULTS / "assembly").rglob("*.s"))) == 112
    assert len(list((RESULTS / "logs").rglob("*.log"))) == 112
    by_key = {(row["benchmark"], row["compiler"], row["group"]): row for row in rows}
    assert len(by_key) == len(rows)
    for row in rows:
        key = Path(row["benchmark"]) / row["compiler"] / row["group"]
        assert digest(RESULTS / "assembly" / key.with_suffix(".s")) == row["asm_sha256"]
        if row["ir_sha256"]:
            assert digest(RESULTS / "ir" / key.with_suffix(".ll")) == row["ir_sha256"]
    for benchmark in BENCHMARKS:
        for group in GROUPS:
            original = by_key[benchmark, "original", group]
            fixed = by_key[benchmark, "ghost-fixed", group]
            assert original["binary_sha256"] == fixed["binary_sha256"]
            assert (original["size_bytes"], original["cycles"]) == (
                fixed["size_bytes"], fixed["cycles"])
    print("112/112 passed; 98 IR, 112 assembly and 112 log files verified; 49 binary pairs identical")


if __name__ == "__main__":
    main()
