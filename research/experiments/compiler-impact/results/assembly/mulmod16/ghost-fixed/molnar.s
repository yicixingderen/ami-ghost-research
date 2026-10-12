	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0"
	.file	"mulmod16.c"
	.globl	mulmod16                        # -- Begin function mulmod16
	.p2align	2
	.type	mulmod16,@function
mulmod16:                               # @mulmod16
# %bb.0:
	lui	a2, %hi(cfl_taken)
	lw	a3, %lo(cfl_taken)(a2)
	lui	a4, 16
	addi	a4, a4, -1
	and	a6, a0, a4
	and	a1, a1, a4
	#APP
	mark	1
	#NO_APP
	li	a0, 1
	xor	a5, a6, zero
	snez	a5, a5
	neg	a5, a5
	and	a5, a5, a3
	li	t0, 1
                                        # implicit-def: $x17
	beqz	a1, .LBB0_1
# %bb.4:
	li	t0, 0
	mul	a7, a1, a6
	and	t1, a7, a4
	srli	a7, a7, 16
	sub	t2, t1, a7
	sltu	a7, t1, a7
	add	a7, t2, a7
.LBB0_1:                                # %Flow
	li	t1, 0
	beqz	t0, .LBB0_3
# %bb.2:
	li	t1, 0
	sub	a7, a4, a6
	addi	a7, a7, 2
.LBB0_3:                                # %Flow2
	not	a6, a5
	and	t0, a5, t1
	and	a0, a6, a0
	or	a6, t0, a0
	not	a0, a5
	and	a5, a5, a7
	and	a0, a0, a0
	or	a0, a5, a0
	xor	a5, a6, zero
	snez	a5, a5
	neg	a5, a5
	and	a5, a5, a3
	sub	a1, a4, a1
	addi	a1, a1, 2
	not	a6, a5
	and	a1, a5, a1
	and	a0, a6, a0
	or	a0, a1, a0
	#APP
	mark	2
	#NO_APP
	and	a0, a0, a4
	sw	a3, %lo(cfl_taken)(a2)
	ret
.Lfunc_end0:
	.size	mulmod16, .Lfunc_end0-mulmod16
                                        # -- End function
	.ident	"clang version 16.0.5 (https://github.com/Danacus/llvm-project-ami-cfl.git f160e224b5f040b340b3ae0693b41dacc0458ef0)"
	.section	".note.GNU-stack","",@progbits
