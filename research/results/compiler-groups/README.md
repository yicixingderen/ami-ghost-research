# 编译器组对照结果

在原 AMi 评测集合中，对 11 个 benchmark 的 5 种形式分别使用原作者 LLVM
`383a9a6c18e5869698e2be5eca1dfc57fd04c05a` 与 Ghost 改进版
`f160e224b5f040b340b3ae0693b41dacc0458ef0`。两组各有 55 项结果，
均无失败；`report.csv` 完全相同。报告汇总的基础代码大小为 3528 字节，
基础运行周期合计为 22553。

原始报告见 `original/report.csv`，改进版见 `ghost-fixed/report.csv`。
评测使用已有汇编快照和顺序核心 `riscv.CoreExtMem`，`BUILD_CORE=0`；
因此结果只证明这些工作负载没有性能回归，不等于评估改进后的 Ghost
CodeGen 对所有程序的性能影响。

复现时先运行仓库根目录的 `scripts/setup-evaluation.sh`，生成顺序核心模拟器，
然后执行：

```sh
make -C evaluation compiler-groups ARGS='--group original=/path/to/original/bin --group ghost-fixed=/path/to/modified/bin --build-core 0 --core riscv.CoreExtMem'
```
