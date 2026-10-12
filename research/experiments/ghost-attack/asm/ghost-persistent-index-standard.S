    .text
    .globl main
main:
    la a1,point
    la a2,array
    li a0,0
    li a3,1
    li a4,2

    # 2 < 1 is false: execute the region in standard mode.
    # a.blt a4,a3,+24 (target is after the region).
    .word 0x00d74c61

    .word 0x0005a500     # g.lw a0,0(a1), ghost
    sw a0,0(a1)
    .word 0x00251512     # p.slli a0,a0,2
    .word 0x00a60632     # p.add a2,a2,a0
    .word 0x00062502     # p.lw a0,0(a2)

after:
    li t0,0x10000000
    li t1,4
    sb t1,0(t0)
1:
    j 1b

    .section .data
    .align 2
point:
    .word 1
array:
    .word 0x11111111, 0x22222222
