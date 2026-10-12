# AMi Ghost Store-Only Forwarding Research

This repository extends the original [AMi project](https://gitlab.com/hanswinderix/ami)
and its [Proteus hardware repository](https://github.com/proteus-core/ami) by
Hans Winderix and collaborators. It preserves the Proteus commit history and
MIT license. The AMi architecture and original evaluation were developed by
Winderix, Bognar, Noorman, Daniel, and Piessens; see their
[IEEE S&P 2024 paper](https://mici.hu/papers/winderix24ami.pdf).

Our research change (`a41df240`) keeps a Ghost load's real value out of the
ordinary GPR path in mimicry mode and forwards it only to a directly dependent
store. This is a limited fix: a store issued after the Ghost result was
broadcast has no replay mechanism. The original Proteus behavior is available
at commit `bbfc8d7c1410514fa0bb6e62a3af01b1437bb3db` for comparison.
The companion [LLVM research fork](https://github.com/yicixingderen/ami-llvm-project-ghost-research)
models the Ghost load destination as an input operand while preserving its
encoding and the adjacent store sequence.

The upstream [AMi evaluation repository](https://gitlab.com/hanswinderix/ami-eval)
is referenced as a submodule at `e0478ef7`; our changes are distributed as
[`patches/evaluation.patch`](patches/evaluation.patch), not as a republished
copy of its source. The original AMi toolchain is an external dependency.

## Reproduce the Ghost experiment

The simulator needs Java 17, `sbt`, Verilator, a C++ compiler, and `make`.
Assemble the workloads with the companion LLVM installation or a RISC-V
GNU toolchain. Python 3 is used for the experiment checks.

```sh
git clone https://github.com/yicixingderen/ami-ghost-research.git
cd ami-ghost-research
AMI_TOOLCHAIN_BIN=/path/to/llvm/install/bin ./research/experiments/ghost-attack/run.sh
```

The script builds separate original and fixed dynamic-core simulators in
`/tmp`, runs mimicry and standard controls, and checks both store data and
ordinary GPR pollution. It also accepts `RISCV_GCC_BIN` as an alternative
assembler toolchain. See [research/README.md](research/README.md) for the
experiment record and archived evidence.

To reproduce the compiler comparison, first run
`./scripts/setup-evaluation.sh`. Generate the `riscv.CoreExtMem` simulator with
`sbt 'runMain riscv.CoreExtMem'` and
`make -C sim CORE=riscv.CoreExtMem build/sim`, then run the evaluation's
`compiler-groups` target with explicit `--group NAME=TOOLCHAIN_DIR` entries
for the original and modified LLVM installations.
The recorded reports are in [research/results/compiler-groups](research/results/compiler-groups).

## Original Proteus README

### Architectural Mimicry: Innovative Instructions to Efficiently Address Control-Flow Leakage in Data-Oblivious Programs

Architectural Mimicry (AMi) is a hardware-software co-designed countermeasure to prevent leaking secrets via a program's control flow. For more information about AMi, we refer to our [S&P 2024 paper](https://mici.hu/papers/winderix24ami.pdf).

```
@inproceedings{winderix:2024-ami,
  author    = {Winderix, Hans and Bognar, Marton and Noorman, Job and Daniel, Lesly-Ann and Piessens, Frank},
  booktitle = {2024 IEEE Symposium on Security and Privacy (SP)},
  title     = {Architectural Mimicry: Innovative Instructions to Efficiently Address Control-Flow Leakage in Data-Oblivious Programs},
  year      = {2024}
}
```

This repository contains the source code of the RISC-V hardware. For information how to reproduce the main results we refer to the [top-level AMi repository](https://gitlab.com/hanswinderix/ami).
