	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0"
	.file	"keypad.c"
	.globl	keypad_init                     # -- Begin function keypad_init
	.p2align	2
	.type	keypad_init,@function
keypad_init:                            # @keypad_init
# %bb.0:
	lui	a0, %hi(cfl_taken)
	lw	a1, %lo(cfl_taken)(a0)
	lui	a2, %hi(count)
	lw	a3, %lo(count)(a2)
	not	a4, a1
	and	a5, a1, zero
	and	a3, a4, a3
	or	a3, a5, a3
	sw	a3, %lo(count)(a2)
	lui	a2, %hi(key_state)
	lh	a3, %lo(key_state)(a2)
	not	a4, a1
	and	a5, a1, zero
	and	a3, a4, a3
	or	a3, a5, a3
	sh	a3, %lo(key_state)(a2)
	lui	a2, %hi(pin_idx)
	lw	a3, %lo(pin_idx)(a2)
	not	a4, a1
	and	a5, a1, zero
	and	a3, a4, a3
	or	a3, a5, a3
	sw	a3, %lo(pin_idx)(a2)
	sw	a1, %lo(cfl_taken)(a0)
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
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	sw	s1, 4(sp)                       # 4-byte Folded Spill
	lui	s0, %hi(cfl_taken)
	lw	s1, %lo(cfl_taken)(s0)
	sw	s1, %lo(cfl_taken)(s0)
	call	read_key_state
	lui	a1, %hi(keymap)
	addi	a1, a1, %lo(keymap)
	li	a2, 1
	li	a3, 16
	lui	a4, %hi(key_state)
	lui	a5, %hi(pin_idx)
	lui	a6, %hi(pin)
	addi	a6, a6, %lo(pin)
.LBB1_1:                                # =>This Inner Loop Header: Depth=1
	lhu	a7, %lo(key_state)(a4)
	and	t1, a2, a0
	#APP
	mark	1
	#NO_APP
	lw	t0, %lo(pin_idx)(a5)
	and	a7, a2, a7
	snez	t1, t1
	seqz	a7, a7
	slti	t2, t0, 4
	and	t1, t1, t2
	and	a7, t1, a7
	xor	a7, a7, zero
	snez	a7, a7
	neg	a7, a7
	and	a7, a7, s1
	lw	t1, 0(a1)
	lw	t2, %lo(pin_idx)(a5)
	addi	t3, t0, 1
	not	t4, s1
	and	t3, s1, t3
	and	t2, t4, t2
	lw	t4, %lo(pin_idx)(a5)
	or	t2, t3, t2
	not	t3, a7
	and	t2, a7, t2
	and	t3, t3, t4
	or	t2, t2, t3
	sw	t2, %lo(pin_idx)(a5)
	add	t0, a6, t0
	lb	t2, 0(t0)
	not	t3, s1
	and	t1, s1, t1
	and	t2, t3, t2
	lb	t3, 0(t0)
	or	t1, t1, t2
	not	t2, a7
	and	a7, a7, t1
	and	t1, t2, t3
	or	a7, a7, t1
	sb	a7, 0(t0)
	#APP
	mark	2
	#NO_APP
	slli	a2, a2, 1
	addi	a3, a3, -1
	addi	a1, a1, 4
	bnez	a3, .LBB1_1
# %bb.2:
	lui	a1, %hi(key_state)
	lh	a2, %lo(key_state)(a1)
	not	a3, s1
	and	a0, s1, a0
	and	a2, a3, a2
	lui	a3, %hi(pin_idx)
	lw	a3, %lo(pin_idx)(a3)
	or	a0, a0, a2
	sh	a0, %lo(key_state)(a1)
	li	a0, 4
	sub	a0, a0, a3
	sw	s1, %lo(cfl_taken)(s0)
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	lw	s1, 4(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
.Lfunc_end1:
	.size	keypad_poll, .Lfunc_end1-keypad_poll
                                        # -- End function
	.p2align	2                               # -- Begin function read_key_state
	.type	read_key_state,@function
read_key_state:                         # @read_key_state
# %bb.0:
	lui	a1, %hi(cfl_taken)
	lw	a2, %lo(cfl_taken)(a1)
	lui	a4, %hi(count)
	lw	a3, %lo(count)(a4)
	li	a0, 0
	lw	a5, %lo(count)(a4)
	addi	a6, a3, 1
	not	a7, a2
	and	a6, a2, a6
	and	a5, a7, a5
	or	a5, a6, a5
	addi	a3, a3, -1
	li	a6, 9
	sw	a5, %lo(count)(a4)
	bltu	a6, a3, .LBB2_2
# %bb.1:
	slli	a3, a3, 1
	lui	a0, %hi(.Lswitch.table.read_key_state)
	addi	a0, a0, %lo(.Lswitch.table.read_key_state)
	add	a0, a0, a3
	lhu	a0, 0(a0)
.LBB2_2:
	sw	a2, %lo(cfl_taken)(a1)
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
