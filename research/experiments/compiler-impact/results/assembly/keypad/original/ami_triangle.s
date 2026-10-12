	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0"
	.file	"keypad.c"
	.globl	keypad_init                     # -- Begin function keypad_init
	.p2align	2
	.type	keypad_init,@function
keypad_init:                            # @keypad_init
# %bb.0:
	lui	a0, %hi(count)
	sw	zero, %lo(count)(a0)
	lui	a0, %hi(key_state)
	sh	zero, %lo(key_state)(a0)
	lui	a0, %hi(pin_idx)
	sw	zero, %lo(pin_idx)(a0)
	ret
.Lfunc_end0:
	.size	keypad_init, .Lfunc_end0-keypad_init
                                        # -- End function
	.globl	keypad_poll                     # -- Begin function keypad_poll
	.p2align	2
	.type	keypad_poll,@function
keypad_poll:                            # @keypad_poll
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	call	read_key_state
	lui	a1, %hi(keymap)
	addi	a1, a1, %lo(keymap)
	li	a2, 1
	li	a3, 16
	lui	a4, %hi(key_state)
	lui	a5, %hi(pin_idx)
	lui	a6, %hi(pin)
	addi	a6, a6, %lo(pin)
	j	.LBB1_1
.LBB1_3:                                #   in Loop: Header=BB1_1 Depth=1
	#APP
	mark	2
	#NO_APP
	slli	a2, a2, 1
	addi	a3, a3, -1
	addi	a1, a1, 4
	beqz	a3, .LBB1_4
.LBB1_1:                                # =>This Inner Loop Header: Depth=1
	lhu	t0, %lo(key_state)(a4)
	and	t1, a2, a0
	#APP
	mark	1
	#NO_APP
	lw	a7, %lo(pin_idx)(a5)
	and	t0, a2, t0
	snez	t1, t1
	seqz	t0, t0
	slti	t2, a7, 4
	and	t1, t1, t2
	and	t0, t1, t0
	a.beq	t0, zero, .LBB1_3
.LBB1_2:                                #   in Loop: Header=BB1_1 Depth=1
	lw	t1, 0(a1)
	addi	t0, a7, 1
	mv	t0, t0
	g.lw	t0, %lo(pin_idx)(a5)
	sw	t0, %lo(pin_idx)(a5)
	p.add	a7, a6, a7
	mv	t0, t1
	g.lb	t0, 0(a7)
	sb	t0, 0(a7)
	j	.LBB1_3
.LBB1_4:
	lui	a1, %hi(pin_idx)
	lw	a1, %lo(pin_idx)(a1)
	lui	a2, %hi(key_state)
	li	a3, 4
	sub	a1, a3, a1
	sh	a0, %lo(key_state)(a2)
	mv	a0, a1
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
.Lfunc_end1:
	.size	keypad_poll, .Lfunc_end1-keypad_poll
                                        # -- End function
	.p2align	2                               # -- Begin function read_key_state
	.type	read_key_state,@function
read_key_state:                         # @read_key_state
# %bb.0:
	lui	a2, %hi(count)
	lw	a1, %lo(count)(a2)
	li	a0, 0
	addi	a3, a1, 1
	addi	a1, a1, -1
	li	a4, 9
	sw	a3, %lo(count)(a2)
	bltu	a4, a1, .LBB2_2
# %bb.1:
	slli	a1, a1, 1
	lui	a0, %hi(.Lswitch.table.read_key_state)
	addi	a0, a0, %lo(.Lswitch.table.read_key_state)
	add	a0, a0, a1
	lhu	a0, 0(a0)
.LBB2_2:
	ret
.Lfunc_end2:
	.size	read_key_state, .Lfunc_end2-read_key_state
                                        # -- End function
	.type	count,@object                   # @count
	.section	.sbss,"aw",@nobits
	.p2align	2
count:
	.word	0                               # 0x0
	.size	count, 4

	.type	key_state,@object               # @key_state
	.p2align	1
key_state:
	.half	0                               # 0x0
	.size	key_state, 2

	.type	pin_idx,@object                 # @pin_idx
	.p2align	2
pin_idx:
	.word	0                               # 0x0
	.size	pin_idx, 4

	.type	keymap,@object                  # @keymap
	.data
	.p2align	2, 0x0
keymap:
	.word	49                              # 0x31
	.word	52                              # 0x34
	.word	55                              # 0x37
	.word	48                              # 0x30
	.word	50                              # 0x32
	.word	53                              # 0x35
	.word	56                              # 0x38
	.word	70                              # 0x46
	.word	51                              # 0x33
	.word	54                              # 0x36
	.word	57                              # 0x39
	.word	69                              # 0x45
	.word	65                              # 0x41
	.word	66                              # 0x42
	.word	67                              # 0x43
	.word	68                              # 0x44
	.size	keymap, 64

	.type	pin,@object                     # @pin
	.section	.sbss,"aw",@nobits
pin:
	.zero	4
	.size	pin, 4

	.type	.Lswitch.table.read_key_state,@object # @switch.table.read_key_state
	.section	.rodata,"a",@progbits
	.p2align	1, 0x0
.Lswitch.table.read_key_state:
	.half	1                               # 0x1
	.half	1                               # 0x1
	.half	0                               # 0x0
	.half	2                               # 0x2
	.half	0                               # 0x0
	.half	4                               # 0x4
	.half	0                               # 0x0
	.half	8                               # 0x8
	.half	0                               # 0x0
	.half	16                              # 0x10
	.size	.Lswitch.table.read_key_state, 20

	.ident	"clang version 16.0.5 (https://github.com/Danacus/llvm-project-ami-cfl.git 383a9a6c18e5869698e2be5eca1dfc57fd04c05a)"
	.section	".note.GNU-stack","",@progbits
