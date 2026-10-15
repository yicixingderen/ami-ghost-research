#!/usr/bin/env bash
# Ghost 攻击对照实验一键复现脚本。
#
# 功能：
#   1. 分别准备 bbfc8d7 原始基线和当前 Proteus 的 CoreDynamicExtMem 模拟器。
#   2. 汇编 asm/ 下的 mimicry/standard 对照负载。
#   3. 同时检查 store 功能和 Ghost GPR 安全性质：原始基线应被判定为失败，
#      store-only forwarding 修复版应通过。
#   4. 产物（vcd/mem/err/bin）保存在 results/<时间戳>/ 下。
#
# 用法：
#   ./run.sh                         # 使用默认 scratch，缺失时构建两个模拟器
#   SCRATCH=/tmp/x ./run.sh          # 使用 /tmp/x-fixed 和 /tmp/x-baseline
#   BASELINE_SCRATCH=/tmp/base \
#   FIXED_SCRATCH=/tmp/fixed ./run.sh
#   FORCE_BUILD=1 ./run.sh           # 强制重建两个 scratch
set -euo pipefail

EXP_DIR="$(cd "$(dirname "$0")" && pwd)"
RESEARCH_DIR="$EXP_DIR/../.."
PROTEUS_SRC="${PROTEUS_SRC:-$RESEARCH_DIR/..}"
BASELINE_COMMIT="${BASELINE_COMMIT:-bbfc8d7c1410514fa0bb6e62a3af01b1437bb3db}"
SCRATCH_ROOT="${SCRATCH:-/tmp/ami-ghost-attack}"
BASELINE_SCRATCH="${BASELINE_SCRATCH:-${SCRATCH_ROOT}-baseline}"
FIXED_SCRATCH="${FIXED_SCRATCH:-${SCRATCH_ROOT}-fixed}"
CORE="riscv.CoreDynamicExtMem"
BASE=0x80000000
RESULTS="$EXP_DIR/results/$(date +%Y%m%d-%H%M%S)"

log() { printf '\n[run.sh] %s\n' "$*"; }

# ---------------------------------------------------------------
# 1. 工具链探测：优先外部 LLVM 安装，其次 /opt/riscv gcc
# ---------------------------------------------------------------
CLANG_BIN="${AMI_TOOLCHAIN_BIN:-$RESEARCH_DIR/../../ami-llvm-project-ghost-research/install/bin}"
RISCV_GCC="${RISCV_GCC_BIN:-/opt/riscv/bin}"
NM=""

assemble() { # assemble <workload.S> <out_dir>
    local src="$1" out="$2" name
    name="$(basename "$src" .S)"
    mkdir -p "$out"
    if [ -x "$CLANG_BIN/clang" ]; then
        "$CLANG_BIN/clang" --target=riscv32-unknown-elf -march=rv32im -mabi=ilp32 \
            -c "$src" -o "$out/$name.o"
        "$CLANG_BIN/ld.lld" -m elf32lriscv -T "$EXP_DIR/asm/link-direct.ld" \
            "$out/$name.o" -o "$out/$name.elf"
        "$CLANG_BIN/llvm-objcopy" -O binary "$out/$name.elf" "$out/$name.bin"
        NM="$CLANG_BIN/llvm-nm"
    elif [ -x "$RISCV_GCC/riscv32-unknown-elf-gcc" ]; then
        "$RISCV_GCC/riscv32-unknown-elf-gcc" -march=rv32im -mabi=ilp32 \
            -nostdlib -ffreestanding -T "$EXP_DIR/asm/link-direct.ld" \
            "$src" -o "$out/$name.elf"
        "$RISCV_GCC/riscv32-unknown-elf-objcopy" -O binary "$out/$name.elf" "$out/$name.bin"
        NM="$RISCV_GCC/riscv32-unknown-elf-nm"
    else
        echo "ERROR: 找不到可用工具链（$CLANG_BIN 或 $RISCV_GCC）" >&2
        exit 1
    fi
}

sym_addr() { # sym_addr <elf> <symbol> → 16 进制地址（如 80000050）
    "$NM" --defined-only "$1" | awk -v s="$2" '$3==s {print $1; exit}'
}

# ---------------------------------------------------------------
# 2. scratch 模拟器准备
# ---------------------------------------------------------------
build_sim() { # build_sim <label> <scratch> <baseline|fixed>
    local label="$1" scratch="$2" mode="$3" sim="$2/proteus/sim/build/sim"
    if [ "${FORCE_BUILD:-0}" = "1" ] || [ ! -x "$sim" ]; then
        log "构建 $label scratch 模拟器（首次约需 10-30 分钟）"
        rm -rf "$scratch"
        mkdir -p "$scratch/proteus"
        if [ "$mode" = "baseline" ]; then
            git -C "$PROTEUS_SRC" archive "$BASELINE_COMMIT" | tar -x -C "$scratch/proteus"
        else
            cp -a "$PROTEUS_SRC"/. "$scratch/proteus"
        fi
        # The historical baseline predates project/build.properties. Pin the
        # launcher for both scratch trees so a current SBT package does not
        # select SBT 2.x and fail to resolve the SBT 1.x scalafmt plugin.
        printf 'sbt.version=1.11.7\n' > "$scratch/proteus/project/build.properties"
        ( cd "$scratch/proteus" && patch -p1 < "$EXP_DIR/proteus-sim-axi-trace.patch" )
        ( cd "$scratch/proteus" && sbt "runMain $CORE" )
        ( cd "$scratch/proteus/sim" && make "CORE=$CORE" build/sim )
    else
        log "复用 $label scratch 模拟器：$sim"
    fi
    [ -x "$sim" ] || { echo "ERROR: $label 模拟器不存在：$sim" >&2; exit 1; }
}

build_sim "原始基线" "$BASELINE_SCRATCH" baseline
build_sim "Ghost 修复版" "$FIXED_SCRATCH" fixed
BASELINE_SIM="$BASELINE_SCRATCH/proteus/sim/build/sim"
FIXED_SIM="$FIXED_SCRATCH/proteus/sim/build/sim"

# ---------------------------------------------------------------
# 3. 汇编工作负载
# ---------------------------------------------------------------
log "汇编工作负载"
BUILD="$RESULTS/build"
mkdir -p "$BUILD"
for s in ghost-store-observer ghost-store-observer-standard \
         ghost-persistent-index ghost-persistent-index-standard \
         ghost-idiom ghost-idiom-standard; do
    assemble "$EXP_DIR/asm/$s.S" "$BUILD"
done

# ---------------------------------------------------------------
# 4. 运行 + 判定
# ---------------------------------------------------------------
run_one() { # run_one <label> <name> <sim>
    local label="$1" name="$2" sim="$3" dir="$RESULTS/$label/$name"
    local rc=0
    mkdir -p "$dir"
    ( cd "$dir" && timeout 60s "$sim" "$BUILD/$name.bin" > sim.out 2> sim.err ) || rc=$?
    if [ $rc -ne 0 ]; then
        echo "  [FAIL] $name: 模拟器未正常结束 rc=$rc（看 sim.err 的 WATCHDOG）"
    fi
    return $rc
}

mem_word() { # mem_word <sim.mem> <byte_offset> → 10 进制
    od -An -tu4 -j "$2" -N 4 "$1" | tr -d ' '
}

last_data_read() { # last_data_read <sim.err> → 末次 LSU 数据读地址（id=8）
    # AXI 请求中 id=0 是取指（会顺序预取进数据段，造成假阳性），id=8 是 LSU 数据访问
    grep 'REQ ' "$1" | grep 'write=0' | grep 'id=8' | tail -1 \
        | sed -n 's/.*addr=0x\([0-9a-f]*\).*/\1/p'
}

ghost_gpr_leak() { # ghost_gpr_leak <vcd> <ghost_pc> → 0/1
    python3 - "$1" "$2" <<'PY'
import sys

path, ghost_pc = sys.argv[1], int(sys.argv[2], 0)
wanted = {
    "retirementStage_out_PC": None,
    "retirementStage_out_RD_TYPE": None,
    "retirementStage_RegisterFileAccessor_regFileIo_rd": None,
    "retirementStage_RegisterFileAccessor_regFileIo_data": None,
    "retirementStage_RegisterFileAccessor_regFileIo_write": None,
}
ids = {}
values = {}
time = None
leak = False

def as_int(value):
    if value is None or any(c in value.lower() for c in "xz"):
        return None
    return int(value, 2)

def check():
    global leak
    if time is None or leak:
        return
    if (as_int(values.get(ids["retirementStage_out_PC"])) == ghost_pc
            and as_int(values.get(ids["retirementStage_out_RD_TYPE"])) == 1
            and as_int(values.get(ids["retirementStage_RegisterFileAccessor_regFileIo_rd"])) == 10
            and as_int(values.get(ids["retirementStage_RegisterFileAccessor_regFileIo_data"])) == 1
            and as_int(values.get(ids["retirementStage_RegisterFileAccessor_regFileIo_write"])) == 1):
        leak = True

with open(path, encoding="ascii") as stream:
    in_header = True
    for line in stream:
        line = line.strip()
        if in_header:
            if line.startswith("$var"):
                fields = line.split()
                name, ident = fields[4], fields[3]
                if name in wanted:
                    ids[name] = ident
            if line.startswith("$enddefinitions"):
                in_header = False
            continue
        if line.startswith("#"):
            check()
            time = int(line[1:])
            continue
        if not line or line.startswith("$"):
            continue
        if line[0] in "01xXzZ":
            ident, value = line[1:], line[0]
        elif line[0] == "b":
            bits, ident = line.split()
            value = bits[1:]
        else:
            continue
        if ident in ids.values():
            values[ident] = value
    check()

print("1" if leak else "0")
PY
}

FAILED=0

for label in baseline fixed; do
    sim="$BASELINE_SIM"
    [ "$label" = fixed ] && sim="$FIXED_SIM"
    log "运行 $label：store-observer / persistent-index / idiom"
    for name in ghost-store-observer ghost-store-observer-standard \
                ghost-persistent-index ghost-persistent-index-standard \
                ghost-idiom ghost-idiom-standard; do
        run_one "$label" "$name" "$sim" || FAILED=1
    done
done

log "判定 1/3：store-only forwarding 与 GPR 安全性"
base="$RESULTS/baseline"; fixed="$RESULTS/fixed"
sink_off=$(( 0x$(sym_addr "$BUILD/ghost-store-observer.elf" sink) - BASE ))
base_sink=$(mem_word "$base/ghost-store-observer/sim.mem" "$sink_off")
base_sink_std=$(mem_word "$base/ghost-store-observer-standard/sim.mem" "$sink_off")
fixed_sink=$(mem_word "$fixed/ghost-store-observer/sim.mem" "$sink_off")
fixed_sink_std=$(mem_word "$fixed/ghost-store-observer-standard/sim.mem" "$sink_off")
base_leak=$(ghost_gpr_leak "$base/ghost-store-observer/sim.vcd" 0x80000028)
base_leak_std=$(ghost_gpr_leak "$base/ghost-store-observer-standard/sim.vcd" 0x80000028)
fixed_leak=$(ghost_gpr_leak "$fixed/ghost-store-observer/sim.vcd" 0x80000028)
fixed_leak_std=$(ghost_gpr_leak "$fixed/ghost-store-observer-standard/sim.vcd" 0x80000028)
printf '  baseline: mimic sink=%s, standard sink=%s, Ghost GPR leak=%s/%s\n' \
    "$base_sink" "$base_sink_std" "$base_leak" "$base_leak_std"
printf '  fixed:    mimic sink=%s, standard sink=%s, Ghost GPR leak=%s/%s\n' \
    "$fixed_sink" "$fixed_sink_std" "$fixed_leak" "$fixed_leak_std"
[ "$base_sink" = 1 ] && [ "$base_sink_std" = 0 ] && [ "$base_leak" = 1 ] && [ "$base_leak_std" = 0 ] \
    || { echo '  [FAIL] 原始基线没有复现 Ghost GPR 污染'; FAILED=1; }
[ "$fixed_sink" = 1 ] && [ "$fixed_sink_std" = 0 ] && [ "$fixed_leak" = 0 ] && [ "$fixed_leak_std" = 0 ] \
    || { echo '  [FAIL] 修复版未保持 store 功能或仍污染 GPR'; FAILED=1; }

log "判定 2/3：persistent-index 后续地址传播"
point_off=$(( 0x$(sym_addr "$BUILD/ghost-persistent-index.elf" point) - BASE ))
base_point=$(mem_word "$base/ghost-persistent-index/sim.mem" "$point_off")
base_point_std=$(mem_word "$base/ghost-persistent-index-standard/sim.mem" "$point_off")
fixed_point=$(mem_word "$fixed/ghost-persistent-index/sim.mem" "$point_off")
fixed_point_std=$(mem_word "$fixed/ghost-persistent-index-standard/sim.mem" "$point_off")
base_last=$(last_data_read "$base/ghost-persistent-index/sim.err")
fixed_last=$(last_data_read "$fixed/ghost-persistent-index/sim.err")
base_std_last=$(last_data_read "$base/ghost-persistent-index-standard/sim.err")
fixed_std_last=$(last_data_read "$fixed/ghost-persistent-index-standard/sim.err")
printf '  baseline: point=%s/%s, mimicry 末次 LSU 读=0x%s, standard=0x%s\n' \
    "$base_point" "$base_point_std" "$base_last" "$base_std_last"
printf '  fixed:    point=%s/%s, mimicry 末次 LSU 读=0x%s, standard=0x%s\n' \
    "$fixed_point" "$fixed_point_std" "$fixed_last" "$fixed_std_last"
[ "$base_point" = 1 ] && [ "$base_point_std" = 0 ] && [ "$base_last" = 4c ] \
    || { echo '  [FAIL] 原始基线没有复现后续索引传播'; FAILED=1; }
[ "$fixed_point" = 1 ] && [ "$fixed_point_std" = 0 ] && [ "$fixed_last" = 48 ] && [ "$fixed_std_last" = 48 ] \
    || { echo '  [FAIL] 修复版仍存在后续索引传播或破坏 standard'; FAILED=1; }

log "判定 3/3：g.lw -> sw 惯用法"
idiom_base=$(( 0x$(sym_addr "$BUILD/ghost-idiom.elf" point) - BASE ))
idiom_fixed=$(( 0x$(sym_addr "$BUILD/ghost-idiom.elf" point) - BASE ))
base_idiom_mm=$(mem_word "$base/ghost-idiom/sim.mem" "$idiom_base")
base_idiom_std=$(mem_word "$base/ghost-idiom-standard/sim.mem" "$idiom_base")
fixed_idiom_mm=$(mem_word "$fixed/ghost-idiom/sim.mem" "$idiom_fixed")
fixed_idiom_std=$(mem_word "$fixed/ghost-idiom-standard/sim.mem" "$idiom_fixed")
printf '  baseline: mimicry point=%s, standard point=%s\n' "$base_idiom_mm" "$base_idiom_std"
printf '  fixed:    mimicry point=%s, standard point=%s\n' "$fixed_idiom_mm" "$fixed_idiom_std"
[ "$base_idiom_mm" = 1 ] && [ "$base_idiom_std" = 9 ] \
    || { echo '  [FAIL] 原始基线惯用法结果异常'; FAILED=1; }
[ "$fixed_idiom_mm" = 1 ] && [ "$fixed_idiom_std" = 9 ] \
    || { echo '  [FAIL] 修复版破坏 g.lw -> sw 惯用法'; FAILED=1; }

log "结果目录：$RESULTS"
if [ $FAILED -eq 0 ]; then
    echo '  [BASELINE FAIL] 原始 AMi 的 Ghost GPR/索引安全性检查失败（预期）'
    echo '  [FIXED PASS] store-only forwarding 修复版通过全部检查'
    log "判定通过：原始 AMi 被识别为易受攻击，Ghost store-only forwarding 修复版通过"
else
    log "存在失败项，请检查上方 FAIL 与 results/ 下的 sim.err / sim.vcd"
    exit 1
fi
