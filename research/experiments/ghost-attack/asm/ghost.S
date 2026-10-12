    .text
    .globl main
    .type main,@function
main:
    addi sp,sp,-16
    sw ra,12(sp)
    sw s0,8(sp)
    sw s1,4(sp)

    la s0,array
    li a0,257
    sw a0,0(s0)
    li a0,258
    sw a0,4(s0)
    la s1,point

    li a0,1
    mv a1,s1
    mv a2,s0
    jal ra,ghost
    .word 0x0650000b

    li a0,4
    mv a1,s1
    mv a2,s0
    jal ra,ghost
    .word 0x0660000b

    li a0,0
    lw ra,12(sp)
    lw s0,8(sp)
    lw s1,4(sp)
    addi sp,sp,16
    ret

    .globl ghost
    .type ghost,@function
ghost:
    addi a3,a0,0
    .word 0x0010000b
    li a4,2
    li a0,10
    # a.blt a4,a3,+28: standard blt opcode 0x63 changed to AMi opcode 0x61.
    .word 0x00d74e61
    li a0,1
    # g.lw a0,0(a1): standard lw opcode 0x03 changed to AMi opcode 0x00.
    .word 0x0005a500
    sw a0,0(a1)
    slli a0,a0,2
    add a2,a2,a0
    lw a0,0(a2)
    .word 0x0020000b
    ret

    .section .data
    .align 2
point:
    .word 0
array:
    .word 0, 0
