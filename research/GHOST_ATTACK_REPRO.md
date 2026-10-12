# Ghost Attack Reproduction

Historical baseline record from 2026-10-11. The temporary paths below refer
to the original local experiment and are not needed for reproduction. Use
[the current experiment](experiments/ghost-attack/README.md) to compare the
original AMi behavior with the store-only forwarding fix.

## Result

The earlier function-call experiment was not a complete reproduction: it could
reach the ghost load, but the run did not provide a clean normal/mimicry control
and could continue fetching after the test body. A minimal direct-entry test now
finishes normally and demonstrates the core attack.

The test uses this data flow:

```asm
g.lw a0, 0(a1)       # point contains the secret value 1
sw   a0, 0(a5)       # persistent store to an independent public sink
```

`a0` starts at zero. The branch selects whether the region is executed in
mimicry mode or standard mode.

| Run | `g.lw` result type | register-file write from `g.lw` | sink write | final sink |
| --- | --- | --- | --- | --- |
| mimicry (`2 < 4`) | `GPR` (`01`) | `x10/a0 = 1` | `0x50 <- 1` | `1` |
| standard (`2 < 1`) | `MIMIC_GPR` (`10`) | no secret write | `0x50 <- 0` | `0` |

Both runs returned exit code `0` from the simulator's EOT device.

## Evidence

- Mimicry VCD: `/tmp/ghost-store-observer-mimic.vcd`
  - `loadStage1` at PC `0x80000028` reads `0x8000004c` and returns `1`.
  - Its `RD_TYPE` is `01` (`GPR`).
  - The retirement register-file event writes `rd=x10`, `data=0x1`.
- Standard VCD: `/tmp/ghost-store-observer-standard.vcd`
  - The same load returns `1`, but `RD_TYPE` is `10` (`MIMIC_GPR`).
  - There is no `g.lw` secret write to `x10`; the later `x10` writes are from
    ordinary instructions.
- AXI traces: `/tmp/ghost-store-observer-run.err` and
  `/tmp/ghost-store-observer-standard-run.err`
  - The persistent store is at `addr=0x50`.
  - Its data is `0x1` in mimicry and `0x0` in standard mode.
- Memory images: `/tmp/ghost-store-observer-mimic.mem` and
  `/tmp/ghost-store-observer-standard.mem`
  - The word at offset `0x50` (`sink`) is respectively `1` and `0`.

## Reproduction Setup

The test was assembled with the AMi container toolchain and linked at
`0x80000000`. The temporary test sources are:

- `/tmp/ami-ghost-repro.uDX4NG/work/ghost-store-observer.S`
- `/tmp/ami-ghost-repro.uDX4NG/work/ghost-store-observer-standard.S`
- `/tmp/ami-ghost-repro.uDX4NG/work/ghost-persistent-index.S`
- `/tmp/ami-ghost-repro.uDX4NG/work/ghost-persistent-index-standard.S`
- `/tmp/ami-ghost-repro.uDX4NG/work/link-direct.ld`

The simulator was rebuilt as `riscv.CoreDynamicExtMem`; the AXI harness was
instrumented only in the temporary copy to print request addresses and write
data. The original repository at `workspace/ami-repro` remains unchanged.

## Scope of the Result

This proves the security-relevant primitive: a value returned by a ghost load
enters an ordinary GPR during mimicry and reaches an independent persistent
operation.

## Index-Propagation Variant

The diary's later array-index claim can also be reproduced when those operations
are explicitly encoded as persistent:

```asm
g.lw a0, 0(a1)
sw   a0, 0(a1)
p.slli a0, a0, 2
p.add  a2, a2, a0
p.lw   a0, 0(a2)
```

The persistent encoding uses instruction low bits `10`; the decoder restores
the normal RISC-V opcode while setting AMi's `PERSISTENT` flag. Results:

| Run | Final load target | Final load value |
| --- | --- | --- |
| mimicry | `0x8000004c` (`array[1]`) | `0x22222222` |
| standard | `0x80000048` (`array[0]`) | `0x11111111` |

Evidence is in `/tmp/ghost-persistent-index-mimic.vcd`,
`/tmp/ghost-persistent-index-standard.vcd`,
`/tmp/ghost-persistent-index-run.err`, and
`/tmp/ghost-persistent-index-standard-run.err`. The untagged diary sequence
does not select `array[1]` in this baseline because its `slli/add/lw` results
are classified as `MIMIC_GPR` and are kept out of real register state. The
independent `sink` test above remains the direct proof that the ordinary GPR
pollution itself is already exploitable.

## Addendum (2026-10-11, project handover)

The `/tmp` evidence files were archived to `../evidence/ghost-attack/`
(substituting the `mimic` suffix for the older `-run` naming), the workloads
and the AXI-trace instrumentation now live in
`../experiments/ghost-attack/`, and `../experiments/ghost-attack/run.sh`
reproduces both experiments end-to-end with automatic verdicts (validated
2026-10-11 against a rebuilt scratch).

Two clarifications confirmed at the source level
(see `../CONCEPTS.md` for details):

1. The `a.blt` in the workloads is an *activating branch*: when taken it sets
   `MMAC=1` and registers its target as the region exit (`MMEXIT`), and it
   never redirects the PC — `DynamicMimicry.scala` disables the jump for
   `ABRANCH` at retirement. Execution therefore always falls through the
   region; the branch condition selects the mode, and the target selects where
   the region ends. This is why the "mimicry (2 < 4)" run executes the region.
2. The fresh runs added one microarchitectural observation: the *untagged*
   `slli/add/lw` following `g.lw` issue with the old architectural `a0=0` in
   both modes (final load target `array[0]` in both traces), while the
   `p.`-encoded chain takes the ghost value in mimicry mode
   (`array[1]`) and the old value in standard mode (`array[0]`). The sink
   value (1 vs 0) remains the direct GPR-pollution evidence for experiment 1.
