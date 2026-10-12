#!/usr/bin/env bash
# 惯用法正确性验证 + naive-fix（日记 1536 简化改法）对照实验。
# 顺序构建两个 scratch（机器仅 7GB，不能并行 sbt），跑同一 ghost-idiom 负载：
#   1. current RTL  + mimicry   → 期望 point=1（g.lw 值流入 store，内存净效果为零）
#   2. current RTL  + standard  → 期望 point=9（g.lw 被抑制，store 写入旧值 a0=9）
#   3. naive-fix    + mimicry   → 期望 point=9（一刀切把情形 2 强加给 mimicry，
#                                            证明该简化改法破坏 store 模拟正确性）
set -e
EXP="$(cd "$(dirname "$0")" && pwd)"
PROTEUS_SRC="$(cd "$EXP/../../.." && pwd)"
CLANG_BIN="${AMI_TOOLCHAIN_BIN:-$PROTEUS_SRC/../ami-llvm-project-ghost-research/install/bin}"
BASELINE_COMMIT=bbfc8d7c1410514fa0bb6e62a3af01b1437bb3db
CUR=/tmp/ami-ghost-attack
NAIVE=/tmp/ami-ghost-naive
BIN_DIR=/tmp/idiom-check

log() { echo "[idiom-verify $(date +%H:%M:%S)] $*"; }

build_scratch() { # build_scratch <dir> [naive]
    local S="$1"
    log "构建 $S ${2:+(naive-fix)}"
    rm -rf "$S"; mkdir -p "$S"
    if [ -n "${2:-}" ]; then
        mkdir -p "$S/proteus"
        git -C "$PROTEUS_SRC" archive "$BASELINE_COMMIT" | tar -x -C "$S/proteus"
    else
        cp -a "$PROTEUS_SRC" "$S/proteus"
    fi
    ( cd "$S/proteus" && patch -p1 < "$EXP/proteus-sim-axi-trace.patch" )
    if [ -n "${2:-}" ]; then
        ( cd "$S/proteus" && patch -p1 < "$EXP/proteus-naive-realupdate.patch" )
    fi
    ( cd "$S/proteus" && sbt 'runMain riscv.CoreDynamicExtMem' ) > "$S/sbt.log" 2>&1
    ( cd "$S/proteus/sim" && make -j2 CORE=riscv.CoreDynamicExtMem build/sim ) > "$S/make.log" 2>&1
    test -x "$S/proteus/sim/build/sim"
    log "构建完成 $S"
}

run_idiom() { # run_idiom <scratch> <variant-suffix> <label>
    local S="$1"
    local v="$2"
    local label="$3"
    local n="ghost-idiom$v" off
    local W="$S/run-$n"
    mkdir -p "$W"
    if ! ( cd "$W" && timeout 60s "$S/proteus/sim/build/sim" "$BIN_DIR/$n.bin" > sim.out 2> sim.err ); then
        printf '%-34s 运行失败（见 %s/sim.err）\n' "$label" "$W"
        return 1
    fi
    off=$(( 0x$("$CLANG_BIN/llvm-nm" --defined-only "$BIN_DIR/$n.elf" | awk '$3=="point"{print $1}') - 0x80000000 ))
    printf '%-34s point = %s\n' "$label" "$(od -An -tu4 -j "$off" -N4 "$W/sim.mem" | tr -d ' ')"
}

mkdir -p "$BIN_DIR"
for n in ghost-idiom ghost-idiom-standard; do
    "$CLANG_BIN/clang" --target=riscv32-unknown-elf -march=rv32im -mabi=ilp32 \
        -c "$EXP/asm/$n.S" -o "$BIN_DIR/$n.o"
    "$CLANG_BIN/ld.lld" -m elf32lriscv -T "$EXP/asm/link-direct.ld" \
        "$BIN_DIR/$n.o" -o "$BIN_DIR/$n.elf"
    "$CLANG_BIN/llvm-objcopy" -O binary "$BIN_DIR/$n.elf" "$BIN_DIR/$n.bin"
done

log "==== 阶段 1：修复版 RTL scratch ===="
build_scratch "$CUR"
log "==== 阶段 2：惯用法两模式验证（现行 RTL）===="
run_idiom "$CUR" ""          "Ghost 修复版 mimicry (期望 1)"
run_idiom "$CUR" "-standard" "Ghost 修复版 standard (期望 9)"
log "==== 阶段 3：naive-fix scratch 与对照 ===="
build_scratch "$NAIVE" naive
run_idiom "$NAIVE" ""        "naive-fix  mimicry  (期望 9)"
log "==== 全部完成 ===="
