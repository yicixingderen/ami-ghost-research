	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0"
	.file	"mulmod16.c"
	.globl	mulmod16                        # -- Begin function mulmod16
	.p2align	2
	.type	mulmod16,@function
mulmod16:                               # @mulmod16
# %bb.0:
	lui	a2, 16
	addi	a2, a2, -1
	and	a0, a0, a2
	and	a1, a1, a2
	#APP
	mark	1
	#NO_APP
	a.beq	a0, zero, .LBB0_1
.LBB0_2:
	beqz	a1, .LBB0_3
# %bb.4:
	mul	a0, a1, a0
	and	a1, a0, a2
	srli	a0, a0, 16
	sub	a3, a1, a0
	sltu	a0, a1, a0
	add	a0, a3, a0
	emm	.LBB0_5
.LBB0_1:
	sub	a0, a2, a1
	addi	a0, a0, 2
	j	.LBB0_5
.LBB0_3:
	sub	a0, a2, a0
	addi	a0, a0, 2
	emm	.LBB0_5
	j	.LBB0_1
.LBB0_5:
	and	a0, a0, a2
	#APP
	mark	2
	#NO_APP
	ret
.Lfunc_end0:
	.size	mulmod16, .Lfunc_end0-mulmod16
                                        # -- End function
	.ident	"clang version 16.0.5 (https://github.com/Danacus/llvm-project-ami-cfl.git 383a9a6c18e5869698e2be5eca1dfc57fd04c05a)"
	.section	".note.GNU-stack","",@progbits
