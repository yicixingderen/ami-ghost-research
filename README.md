# AMi Ghost Store-Only Forwarding Research

[English](#english) | [中文](#中文)

## English

This repository is a research fork of the [AMi Proteus hardware repository](https://github.com/proteus-core/ami). AMi (Architectural Mimicry) is a hardware-software co-designed countermeasure for reducing control-flow leakage from data-oblivious programs. The fork studies a Ghost load in the out-of-order (`riscv.CoreDynamicExtMem`) core and changes the data path so that a Ghost load forwards its real value only to its directly dependent store. The ordinary register file keeps its architectural value.

The original AMi design and evaluation are described in the [IEEE S&P 2024 paper](https://mici.hu/papers/winderix24ami.pdf). The companion [AMi LLVM fork](https://github.com/yicixingderen/ami-llvm-project-ghost-research) emits the matching Ghost-load/store sequence. This repository contains the hardware, the minimal Ghost workloads, the simulator instrumentation, and the evaluation patch; it does not vendor a compiler installation.

The fixed hardware behavior is recorded at commit `a41df240cd81054129714bfdd6f39220d0a7bb10`; the original behavior used for the negative control is `bbfc8d7c1410514fa0bb6e62a3af01b1437bb3db`. The fix only covers a Ghost value consumed by its directly dependent store; it does not add replay for a store issued after the value has been broadcast.

### Reproducible Ghost experiment

The commands below are the supported path on a fresh 64-bit Ubuntu 22.04 or later installation. The experiment builds an original baseline and the fixed simulator in separate temporary directories, then checks both store forwarding and ordinary-GPR pollution.

#### 1. Install host dependencies

```sh
sudo apt-get update
sudo apt-get install -y \
  git make g++ cmake ninja-build patch python3 coreutils \
  openjdk-17-jdk verilator curl ca-certificates gnupg
```

Ubuntu 22.04 does not provide SBT in its default archive. Add the official SBT repository and install it before continuing:

```sh
echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list
curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y sbt
```

The project pins the SBT version in `project/build.properties` (`1.11.7`). Verify that the project launcher is available with `java -version` and `sbt --version` before starting the build. The first SBT/Verilator build downloads Scala/SpinalHDL dependencies and can take 10--30 minutes.

#### 2. Clone the two repositories

Pinning the commits makes the documented result reproducible. Use the current research commits shown here, or record the commit IDs you intend to compare.

```sh
git clone --recurse-submodules https://github.com/yicixingderen/ami-ghost-research.git
git clone https://github.com/yicixingderen/ami-llvm-project-ghost-research.git

cd ami-ghost-research
git checkout 51717288c15ad8a4137632d3e51594d8c1e5101e
git submodule update --init --recursive
```

Build the companion compiler by following its [build instructions](https://github.com/yicixingderen/ami-llvm-project-ghost-research/blob/main/README.md), or set `AMI_TOOLCHAIN_BIN` to any directory containing compatible `clang`, `ld.lld`, `llvm-objcopy`, and `llvm-nm` binaries. The default script location assumes the two repositories are siblings and uses `../ami-llvm-project-ghost-research/install/bin`.

#### 3. Run the Ghost experiment

```sh
AMI_TOOLCHAIN_BIN="$PWD/../ami-llvm-project-ghost-research/install/bin" \
  ./research/experiments/ghost-attack/run.sh
```

Useful controls are:

```sh
FORCE_BUILD=1 ./research/experiments/ghost-attack/run.sh
BASELINE_SCRATCH=/tmp/ami-baseline \
FIXED_SCRATCH=/tmp/ami-fixed \
  ./research/experiments/ghost-attack/run.sh
```

Results are written to `research/experiments/ghost-attack/results/<timestamp>/`. A successful run reports that the original commit `bbfc8d7c1410514fa0bb6e62a3af01b1437bb3db` can write the Ghost value into a normal GPR, while the fixed commit keeps the GPR value unchanged. Both versions must still pass the adjacent `g.lw -> sw` store-forwarding check. See [`research/experiments/ghost-attack/README.md`](research/experiments/ghost-attack/README.md) for the exact workload and acceptance criteria.

### Optional compiler-group comparison

The evaluation submodule is pinned by `scripts/setup-evaluation.sh`. After building the original and modified LLVM installations, apply the evaluation patch and run the comparison with explicit toolchain paths:

```sh
./scripts/setup-evaluation.sh
sbt 'runMain riscv.CoreExtMem'
make -C sim CORE=riscv.CoreExtMem build/sim
cd evaluation
make compiler-groups ARGS="--group original=/path/to/original/bin \
  --group ghost-fixed=/path/to/ami-llvm-project-ghost-research/install/bin \
  --build-core 0 --core riscv.CoreExtMem"
```

Reports are copied to `evaluation/compiler-groups/`; the archived comparison is in [`research/results/compiler-groups`](research/results/compiler-groups).

### Hardware cost measurement

The original AMi Vivado workflow remains available in the [original AMi README](https://gitlab.com/hanswinderix/ami/-/blob/main/README.md). It requires Xilinx Vivado and approximately 52 GB of additional disk space. The generated `proteus/Core.v` is the RTL input for that workflow.

### Citation

```bibtex
@inproceedings{winderix:2024-ami,
  author    = {Winderix, Hans and Bognar, Marton and Noorman, Job and Daniel, Lesly-Ann and Piessens, Frank},
  booktitle = {2024 IEEE Symposium on Security and Privacy (SP)},
  title     = {Architectural Mimicry: Innovative Instructions to Efficiently Address Control-Flow Leakage in Data-Oblivious Programs},
  year      = {2024}
}
```

## 中文

本仓库是 [AMi Proteus 硬件仓库](https://github.com/proteus-core/ami) 的研究分支。AMi（Architectural Mimicry，架构拟态）是面向数据无关程序、用于降低控制流泄漏的软硬件协同防护机制。本分支研究乱序动态核心（`riscv.CoreDynamicExtMem`）中的 Ghost load，并将数据通路改为：Ghost load 的真实值只转发给紧邻的依赖 store，普通寄存器文件仍保持架构值。

原始 AMi 设计和评测见 [IEEE S&P 2024 论文](https://mici.hu/papers/winderix24ami.pdf)。配套的 [AMi LLVM 分支](https://github.com/yicixingderen/ami-llvm-project-ghost-research) 生成对应的 Ghost-load/store 指令序列。本仓库包含硬件、最小 Ghost 工作负载、模拟器插桩和评测补丁，不包含预编译的编译器。

修复版硬件行为对应提交 `a41df240cd81054129714bfdd6f39220d0a7bb10`，用于负面对照的原始行为对应提交 `bbfc8d7c1410514fa0bb6e62a3af01b1437bb3db`。该修复只覆盖 Ghost 值被紧邻依赖 store 消费的情况，不为值广播后才发射的 store 增加 replay。

### 可复现的 Ghost 实验

以下步骤适用于全新的 64 位 Ubuntu 22.04 或更高版本环境。实验会在不同临时目录中分别构建原始基线和修复版模拟器，并同时检查 store 转发和普通 GPR 污染。

#### 1. 安装依赖

```sh
sudo apt-get update
sudo apt-get install -y \
  git make g++ cmake ninja-build patch python3 coreutils \
  openjdk-17-jdk verilator curl ca-certificates gnupg
```

Ubuntu 22.04 的默认软件源不提供 SBT，请先添加官方 SBT 软件源：

```sh
echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list
curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y sbt
```

项目在 `project/build.properties` 中固定了 SBT 版本（`1.11.7`）。开始构建前请确认 `java -version` 和 `sbt --version` 可用。首次 SBT/Verilator 构建需要下载 Scala/SpinalHDL 依赖，通常需要 10--30 分钟。

#### 2. 获取两个仓库

下面的提交号用于固定本文档对应的研究版本；复现实验时也可以记录你要比较的提交号。

```sh
git clone --recurse-submodules https://github.com/yicixingderen/ami-ghost-research.git
git clone https://github.com/yicixingderen/ami-llvm-project-ghost-research.git

cd ami-ghost-research
git checkout 51717288c15ad8a4137632d3e51594d8c1e5101e
git submodule update --init --recursive
```

请先按照配套编译器的[构建说明](https://github.com/yicixingderen/ami-llvm-project-ghost-research/blob/main/README.md)构建 LLVM，或者将 `AMI_TOOLCHAIN_BIN` 设置为包含 `clang`、`ld.lld`、`llvm-objcopy` 和 `llvm-nm` 的目录。脚本默认两个仓库并列放置，并使用 `../ami-llvm-project-ghost-research/install/bin`。

#### 3. 运行 Ghost 实验

```sh
AMI_TOOLCHAIN_BIN="$PWD/../ami-llvm-project-ghost-research/install/bin" \
  ./research/experiments/ghost-attack/run.sh
```

常用控制参数：

```sh
FORCE_BUILD=1 ./research/experiments/ghost-attack/run.sh
BASELINE_SCRATCH=/tmp/ami-baseline \
FIXED_SCRATCH=/tmp/ami-fixed \
  ./research/experiments/ghost-attack/run.sh
```

结果保存在 `research/experiments/ghost-attack/results/<timestamp>/`。成功运行时，原始提交 `bbfc8d7c1410514fa0bb6e62a3af01b1437bb3db` 会被判定为可将 Ghost 值写入普通 GPR，修复版则保持 GPR 值不变；两个版本都必须通过相邻 `g.lw -> sw` 的 store 转发检查。具体工作负载和判定标准见 [`research/experiments/ghost-attack/README.md`](research/experiments/ghost-attack/README.md)。

### 可选的编译器分组对照

`scripts/setup-evaluation.sh` 会把评测子模块固定到指定版本并应用本仓库补丁。完成原始 LLVM 和修改版 LLVM 的安装后执行：

```sh
./scripts/setup-evaluation.sh
sbt 'runMain riscv.CoreExtMem'
make -C sim CORE=riscv.CoreExtMem build/sim
cd evaluation
make compiler-groups ARGS="--group original=/path/to/original/bin \
  --group ghost-fixed=/path/to/ami-llvm-project-ghost-research/install/bin \
  --build-core 0 --core riscv.CoreExtMem"
```

报告会复制到 `evaluation/compiler-groups/`；已归档的对照结果见 [`research/results/compiler-groups`](research/results/compiler-groups)。

### 硬件成本测量

原始 AMi 的 Vivado 流程仍保留在[原始 AMi README](https://gitlab.com/hanswinderix/ami/-/blob/main/README.md) 中，需要安装 Xilinx Vivado，并额外占用约 52 GB 磁盘空间。该流程使用生成的 `proteus/Core.v` 作为 RTL 输入。
