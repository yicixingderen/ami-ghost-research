# 研究路线图

状态标记：[ ] 待做 · [~] 进行中 · [x] 完成 · ⚠ 含未决问题。
承接 `AMI_TODO_AUDIT.md` 的"后续验证顺序"，并结合交接对话中的遗留问题。

## 主线 A：Ghost 攻击与防御（日记 TODO 核心线）

- [x] A1. Ghost 攻击在动态乱序核心上端到端复现（GPR 污染 + 泄漏到独立 sink）
  - `experiments/ghost-attack/`，2026-10-11 验证通过；证据在 `evidence/ghost-attack/`
- [x] A2. 源码级确认攻击机制：激活分支语义、模式状态机、`realUpdate` 真值表
  - `CONCEPTS.md` §1-4（DynamicMimicry.scala:199-257、ReservationStation.scala:256-264）
- [ ] A3. 确认 `mark 1/2`（0x0010000b/0x0020000b）的解码路径及其与 AJUMP 的对应
  （custom opcode `0x0b` 在哪里被解码为激活指令？静态核 `Mimicry.scala` 是否同样处理？）
- [ ] A4. 用日记原版 `asm/ghost.S`（mark 版、函数调用）复现日记的顺序/乱序时序差
  （575ps/885ps），并解释为什么该版本在动态核上会跑飞（返回路径 + 取指行为）
- [ ] A5. ⚠ 顺序核 vs 动态核 GHOST 写回语义对照：顺序核 `Mimicry.scala` 中 `mmac=0`
  的 g.lw 未污染 a0，动态核 mimicry 内污染。逐行对照两处条件，写清差异根源
  （`CONCEPTS.md` §5 目前是待验证结论）
- [ ] A6. ⚠ 验证微架构观测：mimicked 瞬态后继指令发射时取架构旧值、persistent 后继
  在 mimicry 内取 ghost 真实值（experiments README"微架构事实"两条）——在 RS 源码
  （waitingForReal / wawBuffer 路径）中定位依据
- [ ] A7. 实现研究者提出的防御：Ghost load 值入 LSU 专用暂存，仅向紧邻 store 转发，
  不写 GPR（日记 1502 行；无现成代码，需自己实现）。另评估日记 1536 行的简化改法
  （`realUpdate := !meta.mimicryMode | isPersistent`）对 persistent store 场景的影响
  ——注意该改法可能破坏"g.lw → persistent sw"的合法数据流，需要实验判别
  - **[2026-10-11] 简化改法已实证为不可行**：`experiments/ghost-attack/
    verify-idiom-naive-fix.sh` + `ghost-idiom` 负载，naive-fix 后 mimicry 中
    `sw` 写入旧哨兵 9 而非 load 原值 1，内存状态与 standard 路径分叉
    （证据 `evidence/ghost-attack/idiom-*`）。防御只剩 LSU 暂存 + store-only
    forwarding 路线，工作负载与判据已就绪
- [ ] A8. 防御验证：用同一组工作负载确认 (a) 攻击被阻断（sink 恒 0），
  (b) 合法 persistent-store 场景功能保持；在 proteus 新分支独立 commit

## 主线 B：日记 TODO 三项安全性质（AMI_TODO_AUDIT.md 已有初步审计）

- [ ] B1. TODO-1 地址相关内存延迟：在固定延迟模型下重测（改 `sim/main.cpp` 的
  `DMEM/DL1/IMEM_LATENCY`），设计 cache 命中/未命中与多主竞争可区分的测量程序
- [ ] B2. TODO-2 MulDiv 操作数相关延迟：同程序不同操作数的退休周期比较，
  分离依赖/发射/访存干扰（审计结论：单元本身固定 32 次迭代，需整机层面再证）
- [ ] B3. TODO-3 越界 load：构造对齐的 Ghost 越界读，记录总线地址、`0xcafebabe`
  填充、无 trap 的行为链；对比真实硬件预期

## 主线 C：交接遗留的讨论问题

- [x] C1. "把后续计算编码成 p. 指令是否改变了原有逻辑"——已在 `CONCEPTS.md` §6
  给出结论：不改攻击逻辑结构，只是显式指定日记未写明的指令类别；并给出不做 p. 编码
  时索引变化不可复现的原因
- [ ] C2. ⚠ 日记 1146 行注记验证：不对齐 load → 异常 → PC=0 → 异常套异常死循环。
  在当前基线上构造一个不对齐访问，确认 TrapService 行为与"卡住"现象的关系，
  并回头检查此前外部 AXI 卡死是否与此有关（A1 的卡住另有取指原因，见 BASELINE §5.1）

## 执行约定

1. 任何对 proteus 的修改：先开 `research/<主题>` 分支，一个逻辑步骤一个 commit；
   实验脚本与工作负载进 `research/experiments/`，不进上游仓库。
2. 每个实验必须有 mimicry/standard 对照与自动判定（参照 run.sh 的模式）。
3. 关键证据（mem/err/精选 vcd）归档到 `evidence/<主题>/`，正文引用归档路径而非 /tmp。
4. 结论写回本文件与 `CONCEPTS.md`，标注证据位置；未证实的推断必须带 ⚠。
