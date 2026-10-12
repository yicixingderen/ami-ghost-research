	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0"
	.file	"modexp2.c"
	.globl	modexp2                         # -- Begin function modexp2
	.p2align	2
	.type	modexp2,@function
modexp2:                                # @modexp2
# %bb.0:
	li	a2, 1
	li	a3, 32
	lui	a4, 524288
	addi	a4, a4, 1
	lui	a5, 599186
	addi	a5, a5, 1171
	li	a6, 1
	j	.LBB0_1
.LBB0_3:                                #   in Loop: Header=BB0_1 Depth=1
	#APP
	mark	2
	#NO_APP
	mul	a0, a0, a0
	mulhu	a7, a0, a5
	srli	a7, a7, 2
	slli	t0, a7, 3
	add	a0, a0, a7
	sub	a0, a0, t0
	addi	a3, a3, -1
	srai	a1, a1, 1
	beqz	a3, .LBB0_4
.LBB0_1:                                # =>This Inner Loop Header: Depth=1
	and	a7, a1, a4
	#APP
	mark	1
	#NO_APP
	bne	a7, a2, .LBB0_3
# %bb.2:                                #   in Loop: Header=BB0_1 Depth=1
	mul	a6, a6, a0
	mulh	a7, a6, a5
	add	a7, a7, a6
	srli	t0, a7, 31
	srai	a7, a7, 2
	add	a7, a7, t0
	slli	t0, a7, 3
	add	a6, a6, a7
	sub	a6, a6, t0
	j	.LBB0_3
.LBB0_4:
	lui	a0, 599186
	addi	a0, a0, 1171
	mulh	a0, a6, a0
	add	a0, a0, a6
	srli	a1, a0, 31
	srai	a0, a0, 2
	add	a0, a0, a1
	slli	a1, a0, 3
	add	a0, a6, a0
	sub	a0, a0, a1
	ret
.Lfunc_end0:
	.size	modexp2, .Lfunc_end0-modexp2
                                        # -- End function
	.ident	"clang version 16.0.5 (https://github.com/Danacus/llvm-project-ami-cfl.git 383a9a6c18e5869698e2be5eca1dfc57fd04c05a)"
	.section	".note.GNU-stack","",@progbits
