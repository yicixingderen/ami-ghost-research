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
	and	a3, a0, a2
	and	a1, a1, a2
	#APP
	mark	1
	#NO_APP
	li	a4, 1
                                        # implicit-def: $x10
	a.beq	a3, zero, .LBB0_1
.LBB0_4:
	p.addi	a5, zero, 1
                                        # implicit-def: $x10
	beqz	a1, .LBB0_5
# %bb.7:
	p.addi	a5, zero, 0
	mul	a0, a1, a3
	and	a4, a0, a2
	srli	a0, a0, 16
	sub	a6, a4, a0
	sltu	a0, a4, a0
	add	a0, a6, a0
.LBB0_5:                                # %Flow
	li	a4, 0
	a.beq	a5, zero, .LBB0_1
.LBB0_6:
	sub	a0, a2, a3
	addi	a0, a0, 2
.LBB0_1:                                # %Flow2
	a.beq	a4, zero, .LBB0_3
.LBB0_2:
	sub	a0, a2, a1
	addi	a0, a0, 2
.LBB0_3:
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
