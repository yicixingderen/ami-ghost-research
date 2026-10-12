# AMi TODO 初始审计

这是修复前的历史审计记录。当前 Ghost 修复和复现方法见[研究首页](README.md)；
文中所述第三方研究日记未纳入公开仓库。

日期：2026-10-10

## 基线

- AMi 根仓库：`workspace/ami-repro`，`main` @ `c353e93`
- evaluation：`e0478ef7e280fe63f8f6932a3fd5d94ef1730ba3`
- Proteus：`bbfc8d7c1410514fa0bb6e62a3af01b1437bb3db`
- toolchain：`7a71eb9771b844b8e52385c3ac9fe66398c6567c`
- 研究日志：`Ami Install&Run Note.md`，SHA-256
  `e287e997cff6f01545462d168eb28093ef552bd3efb58c184a99ac75676c82ce`

本记录只保存分析结果，不向 AMi 根仓库提交任何文件。

## TODO 对照

日志 TODO 位于附件第 842 行附近，共三项。

### 1. 地址相关的内存访问时间

结论：**条件性存在，默认模拟器未证实。**

Proteus 仿真器在 `proteus/sim/main.cpp:282-298` 按代码区/数据区和数据缓存命中选择延迟，但当前常量
`AXI_LATENCY=1`、`DL1_LATENCY=0`、`DMEM_LATENCY=0`、`IMEM_LATENCY=0`（`main.cpp:27-34`），所以默认
仿真中地址本身不会产生不同的固定延迟。动态内存骨干仍有多路请求、挂起计数和响应仲裁
（`DynamicMemoryBackbone.scala:53-155`）；真实外部内存、设备映射或改动后的缓存参数仍可能让地址影响时序。

因此，日志中的地址时序差异不能直接归因于当前原始 AMi；需要在固定总线模型和目标硬件模型中分别测量。

### 2. 乘法/除法的操作数相关延迟

结论：**在原始 Proteus 的 MulDiv 单元中未发现操作数相关的提前结束。**

乘法先初始化，再由 `Counter(33)` 固定推进 32 次迭代（`MulDiv.scala:134-165`）；除法同样固定迭代，除数为
零只改变最终结果，不改变完成路径（`MulDiv.scala:201-245`）。`product.lsb` 和比较结果只选择每周期的数据运算，
不会改变 `arbitration.isReady` 的迭代次数。程序总时间仍可能受依赖、发射和访存竞争影响，不能仅凭该单元证明整机
恒定时间。

### 3. 虚拟执行中的越界 load

结论：**存在，且原始代码没有一般性的地址范围保护。**

LSU 只检查访问宽度和对齐，并在通过后直接发出 `dbusCtrl.read`（`Lsu.scala:229-245`、`290-355`）；没有针对
内存上界或地址权限的检查。普通 `MemBus` 也没有错误响应字段。默认 C++ 模拟器的 `ensureEnoughMemory`
会把越界地址对应的内存扩展为 `0xcafebabe`（`sim/main.cpp:229-265`），而不是产生 trap。只有未对齐访问会通过
`TrapService` 进入异常路径。

这与日志中的担忧一致：Ghost 路径仍可能实际发出越界读，虚拟值会影响总线、依赖或后续地址，即使最终不应改变
架构寄存器。

## 研究者的 Ghost 实现

日志第 1130-1300 行给出的攻击序列是：`mark 1`，条件分支，`g.lw`，紧接着 `sw`，再用 load 形成后续地址，
最后 `mark 2`。日志记录了正常与虚拟路径的不同波形和约 575 ps/885 ps 的时序差异。该实验首先证明了
Ghost load 的结果进入了普通寄存器并能改变后续 store/地址计算。

日志第 1502 行提出的防御是：Ghost load 的值存入 LSU 专用暂存，只在紧邻的 store 上转发，不写入通用 GPR。
但“Ghost 只能转发给 store”一节没有实际代码，日志没有给出 LSU 暂存器、store 身份校验或完整 patch。

随后日志展示了动态流水线中已有/被调试的通用依赖机制：

- `ReservationStation.scala:145-155` 记录 WAW 的真实值到 `wawBuffer`；
- `ReservationStation.scala:165-192` 在 CDB 收到真实更新时写回 RS1/RS2，并沿 `previousWaw` 链继续等待；
- `ReservationStation.scala:389-417` 在发射时根据 ROB 元数据设置真实值等待和保留站依赖；
- `ReorderBuffer.scala:472-490` 按 `cdbMessage.realUpdate` 把结果标记为 `GPR` 或 `MIMIC_GPR`；
- `LoadManager.scala:132-143` 对 mimicked load 使用 `wawBuffer`，而不是把 load 的虚拟值标成真实 GPR 更新。

这些机制已经存在于上游 Proteus `bbfc8d7`，不能视为该研究者独有的完整实现。日志明确提出的候选修改是把
`ReservationStation.scala` 中的 `realUpdate` 改为
`!meta.mimicryMode | mimicry.isPersistent(exeStage)`，并在非真实更新时广播 `wawBuffer`；原始基线当前仍是
`!(meta.mimicryMode ^ mimicry.isGhost(exeStage)) | mimicry.isPersistent(exeStage)`（`ReservationStation.scala:256-265`）。

日志第 1593-1655 行还记录了 CDB/ROB 转发调试、注释掉直接选择 mimicked register 的尝试，以及
`priorInstructionNext` 的一个周期延迟问题。由此可确认：攻击验证完成，通用依赖转发有大量调试记录，
但“专用 LSU 暂存 + 仅向 store 转发 + 越界/异常隔离”的闭环实现没有在附件中被证明完成。

## 后续验证顺序

1. 在当前干净基线上先固定默认 simulator 的地址、命中/未命中和请求竞争周期测量。
2. 对 MulDiv 单元做相同程序、不同操作数的退休周期比较，并分离依赖和发射影响。
3. 构造对齐的 Ghost 越界 load，记录总线地址、响应、trap、GPR 写回和后续 store，确认模拟器与硬件模型差异。
4. 再单独实现并验证 Ghost 的 LSU 暂存和 store-only forwarding；每一步使用新分支和独立 commit。

## Ghost 攻击复现记录

在 `/tmp/ami-ghost-repro.uDX4NG` 的临时副本中重新生成了 `CoreExtMem` 和
`CoreDynamicExtMem`，没有修改 `workspace/ami-repro`。攻击指令按日志的机器码编码：

- `g.lw a0,0(a1)`：`0x0005a500`；
- `a.blt a4,a3,+28`：`0x00d74e61`；
- `mark 1/2`：`0x0010000b`、`0x0020000b`。

顺序核心的可重复对照如下，`point=0`，`array[0]=257`，`array[1]=258`，进入
`g.lw` 前 `a0=1`：

| 程序 | `a0` 在 load 后 | 后续索引 load | `sim.mem` 中 point |
| --- | ---: | ---: | ---: |
| Ghost (`g.lw`) | `1` | `array[1]=258` | `1` |
| 普通 `lw` 对照 | `0` | `array[0]=257` | `0` |

因此，当前干净的顺序核心基线没有观察到普通 GPR 污染；Ghost load 在波形中标为
`MIMIC_GPR`。动态核心的第二次调用进入 mimicry mode 后，波形已经显示同一 `g.lw`
的 `loadStage1_out_RD_TYPE=GPR`、目标地址为 `0x800000d4`（填充数据变体为
`0x800020d4`），这是攻击所需的普通寄存器写回窗口；当前 `sim/main.cpp` 的外部 AXI
模型在此处持续取指并未返回该 load，因此本次没有得到最后一个 `x10/a0` 变化事件。

检测普通寄存器污染的标准是同时看两类证据：

1. 波形中的 `RegisterFileAccessor.x10_a0` 是否从哨兵 `1` 变成 load 的秘密值 `0`；
2. 同一退休/CDB 事件的 `RD_TYPE` 是否为 `GPR`（值 `1`），且
   `cdbMessage.realUpdate=1`，而不是 `MIMIC_GPR`（值 `2`）。

只看最终地址不够，因为安全实现也允许把 Ghost 值转发给紧邻的 store；必须证明
架构 GPR 文件本身被写入。
