# AMi Ghost 研究记录

本仓库基于原作者的 Proteus AMi 硬件实现，研究动态核心 Ghost load 的普通寄存器污染，
并实现直接依赖 store 的专用转发。原始架构与评测项目的署名及链接见根目录 README。

## 当前结果

- 原始 Proteus `bbfc8d7`：mimicry 模式下 Ghost load 可把秘密值写入普通 GPR；
  persistent 后继指令可据此访问 `array[1]`。
- 改进版 `a41df24`：Ghost 真实值仅供匹配的 store 使用，普通 GPR 保持旧值；
  后续访问回到 `array[0]`。standard 模式保持原语义。
- LLVM 改进版 `f160e224`：Ghost load 在 MachineInstr 中不再构成普通 GPR 定义，
  编码及紧邻 store 序列保持不变。
- 已有编译器对照覆盖 11 个 benchmark 的 5 种形式；两组报告相同。
  这些测试主要使用现成汇编快照，不能据此推断一般 CodeGen 性能变化。

## 复现

运行 `experiments/ghost-attack/run.sh`；它从同一 Git 历史导出原始基线，
在 `/tmp` 分别构建原始版和改进版模拟器。可设置 `AMI_TOOLCHAIN_BIN` 指向
LLVM 安装目录中的 `bin`，或设置 `RISCV_GCC_BIN` 使用 RISC-V GCC。
运行结果位于忽略的 `experiments/ghost-attack/results/`。

`../scripts/setup-evaluation.sh` 初始化上游 evaluation 子模块并应用本项目补丁。
评测需要外部安装的 AMi/LLVM 编译器，路径通过 `TOOLCHAIN_DIR` 或
`compiler-groups` 的 `--group NAME=TOOLCHAIN_DIR` 指定。

## 文档

- [攻击与修复实验](experiments/ghost-attack/README.md)：工作负载、判据和运行方法。
- [原始攻击复现记录](GHOST_ATTACK_REPRO.md)、[机制分析](CONCEPTS.md)、
  [TODO 审计](AMI_TODO_AUDIT.md)：研究过程中的历史记录。文中的旧本机路径和
  “尚未修复”表述仅反映记录当时的状态；当前运行方法以上文为准。
- [基线与环境档案](BASELINE.md)：原始项目的提交指针和早期环境。
- [精选证据](evidence/ghost-attack/) 与 [编译器对照报告](results/compiler-groups/)：
  公开归档材料。大型生成波形和完整运行目录不入库。

第三方研究日记未纳入本仓库；文档中提到的日记行号仅用于标明历史分析来源。
