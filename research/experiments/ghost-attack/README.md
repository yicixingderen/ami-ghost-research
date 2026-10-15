# Ghost 攻击对照实验

在动态乱序核心（`riscv.CoreDynamicExtMem`）上对照原始 AMi 的 Ghost load 普通寄存器污染
与本仓库的 store-only forwarding 修复。本目录自带工作负载、插桩补丁和一键脚本；
所有构建与运行都发生在 scratch 副本中。

## 一键复现

```bash
cd research/experiments/ghost-attack
./run.sh                                      # 首次运行会构建两个 scratch 模拟器
BASELINE_SCRATCH=/tmp/base FIXED_SCRATCH=/tmp/fix ./run.sh
FORCE_BUILD=1 ./run.sh                        # 强制重建两个 scratch
```

脚本同时运行 `bbfc8d7` 原始基线和当前 Ghost 修复版。2026-10-12 在独立发布副本
以 `FORCE_BUILD=1` 重新构建两版动态核心并验证通过：

| 检查项 | 原始基线 | Ghost 修复版 |
| --- | --- | --- |
| mimicry Ghost GPR 写回 | 失败：`a0=1` | 通过：保持哨兵值 |
| mimicry store-observer | `sink=1` | `sink=1`（store-only 转发） |
| mimicry persistent-index | 失败：末次读 `array[1]` | 通过：末次读 `array[0]` |
| `g.lw -> sw` 惯用法 | `point=1` / `9` | `point=1` / `9` |

standard 对照在两种版本中均为 `sink=0`、`point=0`、末次读 `array[0]`。

## 工作负载设计

两组负载代码完全相同（同一段 `.S` 编出两个变体），只有分支条件 `a3` 不同。
`a.blt a4,a3,+24` 是 AMi 的**激活分支**：taken 时进入 mimicry mode，未 taken 时保持
standard mode（它从不真正跳转，分支目标被注册为区域的退出地址 MMEXIT）。

```asm
li    a3,4 / 1        # 模式选择：2 < a3 是否成立
a.blt a4,a3,+24       # .word 0x00d74c61，激活分支
g.lw  a0,0(a1)        # .word 0x0005a500，读 point 中的秘密值 1
sw    a0,...          # store 不可被 mimic，两种模式都真实提交 → 泄漏通道
[slli/add/lw 或 p.slli/p.add/p.lw]   # 观察秘密值向后续数据流的传播
```

- **store-observer**：`sw` 写独立公开 `sink`，用于确认 store-only 转发仍保留合法数据流；
  GPR 是否污染由 VCD 中 Ghost load 的退休写回事件单独判定。
- **persistent-index**：日记数组的索引变体，后续 `slli/add/lw` 用 p. 编码
  （低两位 `10`）。只有编成 persistent，秘密值才能沿寄存器链传播到第二次 load。

## 观测与判据

模拟器带 AXI 观测插桩（`proteus-sim-axi-trace.patch`，只打在 scratch 副本上）：

- stderr：`REQ/WRITE/RESP` 行。**id=0 是取指，id=8 是 LSU 数据访问**——判定泄漏
  地址时必须按 id 过滤，否则取指顺序预取进数据段会造成假阳性。
- `sim.mem`：结束后的内存镜像，按符号表偏移检查 `sink`/`point`。
- `sim.vcd`：完整波形。GPR 污染的严格判据（见 `../../CONCEPTS.md`）是退休事件中
  `RD_TYPE=GPR` 且 `RegisterFileAccessor.x10` 变为秘密值，而非只看内存。

## 实验中确认的两个微架构事实（待源码级验证，见 ROADMAP T3）

1. 区域内**未标 p. 的 `slli/add/lw`**（mimicked 瞬态指令）在两种模式下发射时都取
   **架构旧值**（a0=0），末次数据读均为 `array[0]`——瞬态链不取转发的 ghost 值。
2. **persistent 后继指令**（p.slli/p.add）在原始基线 mimicry 模式下会取到 g.lw 的
   真实值，因此末次读是 `array[1]`；store-only 修复版不再把该值写入普通 GPR，
   末次读回到 `array[0]`。standard 模式下两种版本都读 `array[0]`。

## 文件

- `asm/*.S`、`asm/link-direct.ld`：工作负载与链接脚本（入口 `main` @ `0x80000000`，
  数据段紧随代码段；`boot.S`/`link.ld` 是带启动代码的变体，本实验未用）
- `proteus-sim-axi-trace.patch`：模拟器 AXI 观测 + watchdog 插桩
- `run.sh`：一键复现
- `results/<时间戳>/`：每次运行的 bin/err/mem/vcd；这些临时结果不入库，运行后可删除
- 历史 VCD 波形不随仓库保存；需要证据时直接运行 `./run.sh`，再查看对应结果目录

## 惯用法正确性验证（防御设计的前提，2026-10-11 实测）

`asm/ghost-idiom*.S` + `verify-idiom-naive-fix.sh` 对照本仓库修复版与原始
`bbfc8d7` 上的简化改法，验证"g.lw → 紧邻 sw"值流通路是 store 模拟正确性的前提：

```asm
li   a0, 9            # 区域外哨兵（两种模式都真实提交）
a.blt a4, a3, +12     # 模式开关（.word 0x00d74661）
g.lw a0, 0(a1)        # 读 point 当前值 1
sw   a0, 0(a1)        # 写回 point 自身
```

判定：AXI WRITE 数据与 point 终值是 1（惯用法正确）还是 9（store 拿到旧哨兵）。

| 运行 | AXI WRITE 数据 | point 终值 | 结论 |
| --- | --- | --- | --- |
| 修复版 RTL，mimicry | `0x1` | 1 | 值流通路存在，store 无净效果 |
| 修复版 RTL，standard | `0x9` | 9 | g.lw 被抑制（realUpdate=0），store 拿旧值 |
| naive-fix，mimicry | `0x9` | 9 | **一刀切把上一行强加给 mimicry，惯用法被破坏** |

证据：`../../evidence/ghost-attack/idiom-*.{err,mem}`。补丁
`proteus-naive-realupdate.patch`（改动即日记 1536 行）。因此防御只能走
"LSU 专用暂存 + 仅向紧邻 store 转发"路线（ROADMAP A7）。

注意：`verify-idiom-naive-fix.sh` 首版有 `local` 单行声明的展开 bug，导致
standard 变体曾被误标为 mimicry 结果；已修复并以本表数据为准。

## 已知坑

- 日记 1146 行注记：load 地址不对齐会触发异常，PC 置 0；无对应异常处理时
  异常套异常死循环。本实验所有数据地址均 4 字节对齐。
- 早期函数调用版攻击脚本（`asm/ghost.S`，日记原版）在动态核心上无法稳定结束：
  返回路径 + 取指模式导致超时，故本实验改用直接入口的最小程序。
