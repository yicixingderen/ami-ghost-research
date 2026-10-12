    .text
    .globl main
main:
    la a1,point
    la a2,array
    la a5,sink
    li a0,0
    li a3,4
    li a4,2

    # 2 < 4: execute the following region in mimicry mode.
    # a.blt a4,a3,+24 (target is after the region).
    .word 0x00d74c61

    # The load reads the secret, while the following store is persistent.
    # It writes to a public sink rather than writing back to point.
    .word 0x0005a500     # g.lw a0,0(a1)
    sw a0,0(a5)
    slli a0,a0,2
    add a2,a2,a0
    lw a0,0(a2)

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
sink:
    .word 0
array:
    .word 0x11111111, 0x22222222
