# AMi LLVM 七基准本地实验

按 [Vanoverloop 论文第 7 章](https://daan.vanoverloop.xyz/masters-thesis-ami-pcfl.pdf)
的编译、结构化、线性化、链接与顺序核心仿真流程，对原 AMi evaluation
中可对应的七个 C 基准进行完整本地对照：`triangle`、`ifthenloop`、
`modexp2`、`mulmod16`、`keypad`、`bsl`、`fork`。两版 LLVM 各自从 C
重新生成七组自动程序；原 evaluation 的两组手工线性化汇编另外运行一次，
只作为手工参考。论文数据没有进入本次统计。

## 固定版本

- Proteus：本仓库基线 `9681e2892609079792f6ec554eb50c735538523c`，
  顺序核心 `riscv.CoreExtMem`。新的研究提交只增加实验资料。
- evaluation：`e0478ef7e280fe63f8f6932a3fd5d94ef1730ba3`，先应用
  根目录 `patches/evaluation.patch`，再应用本目录 `evaluation-secret.patch`。
- 原作者 LLVM：`383a9a6c18e5869698e2be5eca1dfc57fd04c05a`。
- Ghost 改进 LLVM：`f160e224b5f040b340b3ae0693b41dacc0458ef0`。
- RISC-V GCC：12.2.0；Python：3.12.3；`vcdvcd`：2.6.0。
  `results/metadata.json` 另存实际二进制 SHA-256。

秘密标注补丁只增加编译器可识别的类型标注。`keypad` 的模拟按键输入 helper
额外使用 `noinline`，使秘密返回值在 `-O3` 下仍保留跨函数标注；算法及
测试输入没有改变。`bsl` 的条件在 `-O3` 下已被优化为无分支指令，
因此三组 AMi 汇编没有 `a.*` 指令；该情况在结果中标为
`optimized_branchless`，并通过原评测正确性检查。

## 复现

先准备两套固定版本的 LLVM，保证两套 `bin` 目录各有 `clang`、`opt`、`llc`；
安装 `/opt/riscv/bin/riscv32-unknown-elf-gcc`、`objcopy`、Verilator、sbt，
以及含 `vcdvcd` 的 Python 环境。当前机器的完整运行命令如下：

```sh
cd /home/yicixingderen/ami/workspace/ami-compiler-performance
bash research/experiments/compiler-impact/setup.sh
make -C sim CORE=riscv.CoreExtMem
/home/yicixingderen/ami/workspace/ami-repro/.venv/bin/python \
  research/experiments/compiler-impact/run.py \
  --original-bin /home/yicixingderen/ami/workspace/llvm-project-ami-cfl-baseline-build/bin \
  --fixed-bin /home/yicixingderen/ami/workspace/llvm-project-ami-cfl/install/bin \
  --original-source /home/yicixingderen/ami/workspace/llvm-project-ami-cfl-baseline \
  --fixed-source /home/yicixingderen/ami/workspace/llvm-project-ami-cfl
python3 research/experiments/compiler-impact/verify.py
```

`run.py` 依次生成 baseline、reducible、SESE 和 triangle LLVM IR；
从所需 IR 生成 Molnar、AMi PCFL、AMi SESE、AMi triangle 以及两组
非线性化结构化程序。每项使用相同 `boot.S`、`main.c`、linker script、
GCC 12.2.0 和 Proteus 顺序核心。`results/results.csv` 包含正确性、
二进制大小、周期、相对基线比例和各阶段校验值。`results/logs` 保留
命令及诊断；`results/ir` 按方法保留实际输入 IR，`results/assembly`
保留核查产物。脚本在
提取指标后删除临时 ELF、bin 和 VCD。

`evaluation/evaluate.py` 的安全轨迹函数直接返回 `True`。这里使用相同
benchmark 专用 `verify_correctness` 检查输出，只对正确性与效率作结论，
不把它解释为安全验证。结果见 [报告](results/report.md)。此前 Ghost
硬件转发实验和旧编译器汇编快照报告回答的是不同问题，仍予保留。
