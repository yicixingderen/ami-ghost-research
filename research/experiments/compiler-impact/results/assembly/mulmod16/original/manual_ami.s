	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0"
	.file	"mulmod16.c"
	.globl	mulmod16
	.p2align	2
	.type	mulmod16,@function
mulmod16:
	lui	a2, 16
	addi	a2, a2, -1
	and	t0, a0, a2
	and	t1, a1, a2
	#APP
	mark	1
	#NO_APP
	a.beq	t0, x0, .LBB0_3
	a.beq	t1, x0, .LBB0_3
	mul	a0, t1, t0
	and	a1, a0, a2
	srli	a0, a0, 16
	sub	a3, a1, a0
	sltu	a0, a1, a0
	add	a0, a3, a0
	and	a0, a0, a2
.LBB0_3:
	a.bne	t0, x0, .LBB0_4
	sub	a0, a2, t1
	addi	a0, a0, 2
	and	a0, a0, a2
.LBB0_4:
	a.bne	t1, x0, .LBB0_A
	sub	a0, a2, t0
	addi	a0, a0, 2
	and	a0, a0, a2
.LBB0_A:
	#APP
	mark	2
	#NO_APP
	ret
.Lfunc_end0:
	.size	mulmod16, .Lfunc_end0-mulmod16

	.ident	"clang version 15.0.0 (git@gitlab.kuleuven.be:u0126303/llvm-project.git a3b1800863ff654d43bcfc8fc905822f341d9f92)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
