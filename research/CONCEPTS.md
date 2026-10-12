# AMi 概念与语义档案

本文档沉淀截至目前对 AMi/Proteus 机制的**源码级确认结论**（标注 file:line，均对应
`workspace/ami-repro` 的干净基线 `proteus @ bbfc8d7`），以及仍属推断、待验证的内容
（标注 ⚠）。语言沿用研究日记与既往讨论。

## 1. 指令编码：四类前缀

AMi 用指令编码的低两位（opcode[1:0]）区分指令类别；硬件解码时用 `ir | 3` 恢复标准
RISC-V opcode 后照常执行。分类逻辑在
[`DynamicMimicry.scala:111-146`](../src/main/scala/riscv/plugins/mimicry/DynamicMimicry.scala)：

| 前缀 | 低两位 | 类别 | 语义 |
| --- | --- | --- | --- |
| （无） | `11` | 普通 | jump 默认按 persistent 处理；其余正常 |
| `g.` | `00` | Ghost | 条件分支：保留（原 CTBRANCH 已注释）；其余标 `GHOST` |
| `a.` | `01` | 激活 | jump → `AJUMP`；条件分支 → `ABRANCH`；其余 → `MIMIC` |
| `p.` | `10` | Persistent | 标 `PERSISTENT`，两种模式都真实提交 |

机器码实例（已在实验中使用）：

- `mark 1/2`：`0x0010000b` / `0x0020000b`（custom opcode `0x0b`）
- `g.lw a0,0(a1)`：`0x0005a500`（标准 `lw` 的 `0x03` → `0x00`）
- `a.blt a4,a3,+24`：`0x00d74c61`（标准 `blt` 的 `0x63` → `0x61`）
- `p.slli a0,a0,2`：`0x00251512`；`p.add a2,a2,a0`：`0x00a60632`；`p.lw a0,0(a2)`：`0x00062502`

## 2. mimicry 模式状态机

控制状态：`MMAC`（激活计数，CSR 0x7ff）、`MMENTRY`/`MMEXIT`（区域入口/出口地址）。
退休段逻辑在 `DynamicMimicry.scala` 的 `build()`（约 199-257 行）：

1. **进入**：`mmac===0` 时遇到激活 jump，或激活分支 taken → `MMAC:=1`，
   `MMENTRY:=本分支 PC`，`MMEXIT:=分支目标`（即区域结束地址）。
2. **重入/嵌套**：`pc===MMENTRY && mmac>0` → `MMAC+1`。
3. **退出**：`pc===MMEXIT && mmac>0` → `MMAC-1`（减到 0 时清除 MMENTRY/MMEXIT）。
4. **激活分支从不跳转**：`DynamicMimicry.scala:253-257` 对 `ABRANCH` 显式
   `JumpService.disableJump`。`a.blt cond, region_end` 的真实语义是
   "若 cond 成立则在 mimicry 模式下、否则在 standard 模式下**顺序执行** [下一条,
   region_end]"，region_end 处自然退出模式。
5. **抑制规则**（约 236-249 行）：
   - `MIMIC` 类（a. 前缀非控制流）：总是 mimicked；
   - `GHOST`（g.）：`mmac===0` 或处于退出点时 mimicked；
   - 其余普通指令：`mmac>0` 且非退出点时 mimicked；
   - `PERSISTENT`（p. 与 jump）：从不 mimicked。
6. **抑制的效果仅是寄存器写回改名**：`RD_TYPE: GPR → MIMIC_GPR`
   （约 251-255 行）。[`RegisterFileAccessor.scala:49-52`](../src/main/scala/riscv/plugins/RegisterFileAccessor.scala)
   只在 `RD_TYPE==GPR` 时写寄存器堆。**store 的内存写不受 mimicked 影响**——这就是
   攻击的泄漏通道：store 在两种模式下都真实提交。
7. CSR `MMAC`/`MMEXIT` 定义在 [`Mimicry.scala`](../src/main/scala/riscv/plugins/mimicry/Mimicry.scala)
   （0x7ff / 0x7ef）。

### GPR 与 MIMIC_GPR

- `GPR`：RISC-V 32 个通用寄存器 x0-x31（如 a0=x10），程序可见架构状态。
- `MIMIC_GPR`：**不是**独立寄存器，只是流水线标签——"目标编号仍是 xN，但这是
  模拟结果，不得提交到真实寄存器堆"。该值可暂存于保留站/ROB/CDB/wawBuffer。

## 3. realUpdate：写回选择逻辑（动态核心）

[`ReservationStation.scala:256-264`](../src/main/scala/riscv/plugins/scheduling/dynamic/ReservationStation.scala)：

```scala
realUpdate = !(meta.mimicryMode ^ mimicry.isGhost(exeStage)) | mimicry.isPersistent(exeStage)
```

| `mimicryMode` (M) | `isGhost` (G) | `isPersistent` (P) | realUpdate | 效果 |
| --- | --- | --- | --- | --- |
| 0 | 1 | 0 | 0 | g. 结果不写普通 GPR，广播 `wawBuffer` 中的架构旧值 |
| 1 | 1 | 0 | **1** | **g. 结果作为真实 GPR 更新**（攻击窗口） |
| 1 | 0 | 0 | 0 | 普通瞬态指令结果不写普通 GPR |
| 任意 | 任意 | 1 | 1 | persistent 结果真实提交 |

`realUpdate=0` 时 CDB 广播 `meta.wawBuffer`（架构旧值）；`ReorderBuffer.scala:472-490`
据此把结果标成 `GPR` 或 `MIMIC_GPR`。

## 4. Ghost 攻击原理（已复现，见 experiments/ghost-attack）

1. `g.lw` 在任何模式下都执行**真实硬件 load**（地址计算、访存、取数都是真的）；
   mimicry 模式只影响结果**是否提交到架构状态**。
2. 按当前实现（上表 M=1,G=1 行），mimicry 模式内的 g. 结果被当作真实 GPR 更新——
   这本身是设计选择，为的是让 persistent store 拿到正确数据
   （AMi 论文场景：`g.lw` 读原值 → `sw` 写回，使 store 对内存无净影响）。
3. **漏洞点**：硬件不限制这个真实值只能被紧邻的 store 使用。秘密值一旦进入
   `a0`，后续 persistent 指令链（`p.slli → p.add → p.lw`）会以它计算访存地址，
   store 与 load 地址即成为可观测侧信道。
4. 安全目标的表述：mimicry 执行可以读秘密值，但**不能让秘密值影响架构状态或
   后续可观察行为**。研究者提出的防御（日记 1502 行）：Ghost load 的值放入 LSU
   专用暂存，只向紧邻的 store 转发，不写通用 GPR。

### 检测寄存器污染的判据（严格）

单一证据不足，需同时满足：

1. 退休/写回事件中 `RD_TYPE == GPR`（值 01）而非 `MIMIC_GPR`（值 10）；
2. CDB `realUpdate == 1`；
3. `RegisterFileAccessor.x10_a0` 从哨兵值变为 load 返回的秘密值；
4. 行为证据：后续真实提交的 store/内存访问地址随秘密值变化（本实验的 sink /
   array 索引）。

## 5. 顺序核心与动态核心的差异 ⚠

`AMI_TODO_AUDIT.md` 的顺序核心（`CoreExtMem`，`Mimicry.scala` 静态路径）实验中，
`mmac=0` 的 `g.lw` 未污染 `a0`（安全侧）；动态核心在 mimicry 模式内污染。两个核心
的 GHOST 写回语义差异（`Mimicry.scala` vs `ReservationStation.scala` 的条件）尚未
逐行对照，见 ROADMAP T3。

## 6. 上一轮遗留问题的回答：为什么把后续计算编成 p. 指令？

日记原始攻击脚本的 `slli/add/lw` 未标前缀。在动态核心的 mimicry 模式内，未标前缀的
普通指令按 mimicked 处理、结果不提交（MIMIC_GPR），因此秘密值**无法**沿寄存器链
传播到第二次 load——日记宣称的"索引变化"在该基线上不能直接复现。把三条指令编码为
persistent（低两位 `10`，解码后仍执行原 RISC-V 指令）后，它们两种模式都真实提交，
秘密值得以传播，索引变化才可复现（mimic: array[1]=0x22222222；standard:
array[0]=0x11111111）。这不改变日记攻击的逻辑结构，只是显式指定了日记未写明的
指令类别；独立的 store-observer 实验则证明 GPR 污染本身（不依赖 p. 链）已经可利用。

## 7. 仿真环境要点（详见 BASELINE.md）

- 三个核心入口：`CoreExtMem`（顺序）、`CoreDynamicExtMem`（乱序+外部 AXI）、
  `CoreDynamicSim`（片上存储）。
- 模拟器在 CWD 写 `sim.vcd`/`sim.mem`；EOT 设备地址 `0x10000000`（写 4 正常退出）。
- 默认延迟常量全为 0（`AXI_LATENCY=1, DL1/DMEM/IMEM_LATENCY=0`），地址相关时序
  在默认仿真中不出现（TODO-1 的前提）。
- 越界地址：模拟器 `ensureEnoughMemory` 自动扩展并以 `0xcafebabe` 填充，不 trap；
  只有不对齐访问走 `TrapService` 异常路径（日记 1146 行注记的死循环来源）。
