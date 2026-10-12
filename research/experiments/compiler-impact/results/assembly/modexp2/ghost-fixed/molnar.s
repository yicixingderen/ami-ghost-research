	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0"
	.file	"modexp2.c"
	.globl	modexp2                         # -- Begin function modexp2
	.p2align	2
	.type	modexp2,@function
modexp2:                                # @modexp2
# %bb.0:
	lui	a2, %hi(cfl_taken)
	lw	a3, %lo(cfl_taken)(a2)
	li	a5, 1
	li	a6, 32
	lui	a7, 524288
	addi	a7, a7, 1
	lui	a4, 599186
	addi	t0, a4, 1171
	li	a4, 1
.LBB0_1:                                # =>This Inner Loop Header: Depth=1
	#APP
	mark	1
	#NO_APP
	and	t1, a1, a7
	xor	t1, t1, a5
	seqz	t1, t1
	neg	t1, t1
	and	t1, t1, a3
	mul	t2, a4, a0
	mulh	t3, t2, t0
	add	t3, t3, t2
	srli	t4, t3, 31
	srai	t3, t3, 2
	add	t3, t3, t4
	slli	t4, t3, 3
	add	t2, t2, t3
	sub	t2, t2, t4
	not	t3, t1
	and	t1, t1, t2
	and	a4, t3, a4
	or	a4, t1, a4
	#APP
	mark	2
	#NO_APP
	mul	a0, a0, a0
	mulhu	t1, a0, t0
	srli	t1, t1, 2
	slli	t2, t1, 3
	add	a0, a0, t1
	sub	a0, a0, t2
	addi	a6, a6, -1
	srai	a1, a1, 1
	bnez	a6, .LBB0_1
# %bb.2:
	lui	a0, 599186
	addi	a0, a0, 1171
	mulh	a0, a4, a0
	add	a0, a0, a4
	srli	a1, a0, 31
	srai	a0, a0, 2
	add	a0, a0, a1
	slli	a1, a0, 3
	add	a0, a4, a0
	sub	a0, a0, a1
	sw	a3, %lo(cfl_taken)(a2)
	ret
.Lfunc_end0:
	.size	modexp2, .Lfunc_end0-modexp2
                                        # -- End function
	.ident	"clang version 16.0.5 (https://github.com/Danacus/llvm-project-ami-cfl.git f160e224b5f040b340b3ae0693b41dacc0458ef0)"
	.section	".note.GNU-stack","",@progbits
