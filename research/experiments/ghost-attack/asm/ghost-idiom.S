    .text
    .globl main
main:
    la   a1, point
    li   a0, 9           # 标准路径的取值（区域外，两种模式都真实提交）
    li   a3, 4           # 模式选择：2 < 4 taken → mimicry；standard 变体改为 1
    li   a4, 2

    # a.blt a4, a3, +12：激活分支，区域 = g.lw + sw，目标 after = 区域出口
    .word 0x00d74661

    .word 0x0005a500     # g.lw a0, 0(a1) —— 读 point 当前值 1
    sw   a0, 0(a1)       # 惯用法：把读出的值原样写回 point 自身

after:
    li   t0, 0x10000000
    li   t1, 4
    sb   t1, 0(t0)
1:
    j    1b

    .section .data
    .align 2
point:
    .word 1
