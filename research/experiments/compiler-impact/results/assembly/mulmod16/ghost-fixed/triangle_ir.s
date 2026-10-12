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
	li	a5, 1
                                        # implicit-def: $x13
	beqz	a0, .LBB0_1
# %bb.4:
	li	a4, 1
                                        # implicit-def: $x13
	beqz	a1, .LBB0_5
# %bb.7:
	li	a4, 0
	mul	a3, a1, a0
	and	a5, a3, a2
	srli	a3, a3, 16
	sub	a6, a5, a3
	sltu	a3, a5, a3
	add	a3, a6, a3
.LBB0_5:                                # %Flow
	li	a5, 0
	beqz	a4, .LBB0_1
# %bb.6:
	li	a5, 0
	sub	a3, a2, a0
	addi	a3, a3, 2
.LBB0_1:                                # %Flow2
	beqz	a5, .LBB0_3
# %bb.2:
	sub	a3, a2, a1
	addi	a3, a3, 2
.LBB0_3:
	and	a0, a3, a2
	#APP
	mark	2
	#NO_APP
	ret
.Lfunc_end0:
	.size	mulmod16, .Lfunc_end0-mulmod16
                                        # -- End function
	.ident	"clang version 16.0.5 (https://github.com/Danacus/llvm-project-ami-cfl.git f160e224b5f040b340b3ae0693b41dacc0458ef0)"
	.section	".note.GNU-stack","",@progbits
