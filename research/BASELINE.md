# 基线与环境档案

这是 2026-10-11 的历史环境记录。下述本机路径不属于公开仓库，当前复现方法见
[研究首页](README.md)；原始研究日记也未公开收录。

更新：2026-10-11。所有路径均在本机（yicixingderen@remote-ssh）。

## 1. 代码基线（保持 pristine，不提交研究内容）

`/home/yicixingderen/ami/workspace/ami-repro`：

| 仓库 | 位置 | 指针 |
| --- | --- | --- |
| 根仓库 | `main` @ `c353e93`（跟踪 upstream/main） | — |
| evaluation | 子模块 | `e0478ef7e280fe63f8f6932a3fd5d94ef1730ba3` |
| proteus | 子模块 | `bbfc8d7c1410514fa0bb6e62a3af01b1437bb3db` |
| toolchain | 子模块 | `7a71eb9771b844b8e52385c3ac9fe66398c6567c` |

原则：研究分支、补丁一律在 scratch 副本或独立分支上进行（日记"后续验证顺序"第 4 条：
每一步使用新分支和独立 commit）。防御实现等修改工作开始时，先在 proteus 子模块开
`research/<主题>` 分支。

原始资料：研究日记 `Ami Install&Run Note.md`（ami/ 根目录，SHA-256
`e287e997cff6f01545462d168eb28093ef552bd3efb58c184a99ac75676c82ce`）。关键章节：
TODO idea（842 行起）、ghost 攻击脚本（1142 行起，含 1146 行不对齐 load 注记）、
ghost 防御方案（1502 行起）、工作进度（1581 行起：9/11、9/23 CDB/ROB 转发、9/26
延迟一周期 bug）。

## 2. 工具链

| 工具 | 路径 | 说明 |
| --- | --- | --- |
| clang/ld.lld/llvm-objcopy/llvm-nm (15) | `/home/yicixingderen/.local/share/docker/containerd/daemon/io.containerd.snapshotter.v1.overlayfs/snapshots/62/fs/opt/ami/toolchain/install/bin` | AMi 容器层快照，攻击实验所用；快照号 62 可能随 docker GC 失效 |
| riscv32-unknown-elf-gcc (12.2) | `/opt/riscv/bin` | 备用，可汇编同样的工作负载 |
| sbt / verilator | PATH 中 | Proteus Verilog 生成与 C++ 仿真编译 |
| ⚠ 容器 docker-ami | 日记第 21-79 行 | 完整上游环境；当前实验未依赖 |

## 3. 构建与运行（Proteus）

```bash
# Verilog 生成（按入口点选择核心），在 proteus/ 下：
sbt 'runMain riscv.CoreExtMem'          # 顺序核心
sbt 'runMain riscv.CoreDynamicExtMem'   # 动态乱序核心 + 外部 AXI
sbt 'runMain riscv.CoreDynamicSim <hex>'# 片上存储动态核心（hex 需 Verilog 格式）

# C++ 仿真编译（生成 Verilog 后）：
make -C sim CORE=riscv.CoreDynamicExtMem build/sim

# 运行：sim 在 CWD 写 sim.vcd / sim.mem
./sim/build/sim workload.bin
```

- EOT 设备：地址 `0x10000000`，写 `4` 正常退出（exit 0）。
- watchdog：scratch 补丁在 200000 周期强制退出（exit 2），用于发现总线卡死。

## 4. 关键源码位置（proteus @ bbfc8d7）

| 文件 | 内容 |
| --- | --- |
| `plugins/mimicry/DynamicMimicry.scala` | 解码分类（111-146）、模式状态机（199-257）、ABRANCH disableJump（253-257） |
| `plugins/mimicry/Mimicry.scala` | 顺序核心 mimicry、CSR MMAC(0x7ff)/MMEXIT(0x7ef) |
| `plugins/scheduling/dynamic/ReservationStation.scala` | `realUpdate`（256-264）、wawBuffer（145-155）、依赖转发（165-192, 389-417） |
| `plugins/scheduling/dynamic/ReorderBuffer.scala` | 按 `realUpdate` 标 `GPR/MIMIC_GPR`（472-490） |
| `plugins/scheduling/dynamic/LoadManager.scala` | mimicked load 用 wawBuffer（132-143） |
| `plugins/RegisterFileAccessor.scala` | 只写 `RD_TYPE==GPR`（49-52） |
| `plugins/MulDiv.scala` | 固定 32 次迭代（TODO-2 审计点，134-165, 201-245） |
| `plugins/Lsu.scala` | 只查宽度/对齐，无范围检查（229-245, 290-355） |
| `sim/main.cpp` | 延迟常量（27-34）、`ensureEnoughMemory`（229-265） |
| `soc/SoC.scala`、`MemBus.scala` | 片上总线、无错误响应字段 |

## 5. 已知坑

1. **AXI 取指阻塞**：`CoreDynamicExtMem` 在取指密集时外部 AXI 模型可能长时间不返回
   数据响应，程序"卡住"——此前函数调用版攻击脚本未完成的原因之一。对策：直接入口
   最小程序 + watchdog + `id` 字段区分取指/数据。
2. **不对齐 load**：触发 `TrapService` 异常，PC 置 0；无异常处理时异常套异常死循环
   （日记 1146 行注记）。工作负载数据须 4 字节对齐。
3. **AXI 地址是相对偏移**：追踪中 `addr` 相对 RAM 基址 0x80000000，符号表是绝对
   地址，比对时要减基址。
4. **取指请求 id=0、LSU 数据 id=8**（CoreDynamicExtMem）：泄漏地址判定必须按 id
   过滤，否则 j 循环后顺序预取进数据段会污染末次读判定。
5. **默认仿真无地址时序**：延迟常量全 0，不能把日记的时序测量结论直接当成当前
   基线的行为（TODO-1 需自定延迟模型重测）。
6. **越界不 trap**：越界读自动扩展内存返回 `0xcafebabe`；只有不对齐才异常。
7. **docker 快照脆弱**：工具链在 containerd 快照 62 内，docker GC 后路径失效；
   失效时改用 `/opt/riscv`（run.sh 已做回退）。

## 6. Scratch 副本

`/tmp/ami-ghost-attack`（run.sh 默认）与遗留的 `/tmp/ami-ghost-repro.uDX4NG`
（上个会话创建，sim 已构建，可用于复用）。scratch 属临时目录，随时可由
`FORCE_BUILD=1 ./run.sh` 从 pristine 重建。
