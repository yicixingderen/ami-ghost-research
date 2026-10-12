	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0"
	.file	"triangle.c"
	.globl	triangle                        # -- Begin function triangle
	.p2align	2
	.type	triangle,@function
triangle:                               # @triangle
# %bb.0:
	mv	a2, a0
	#APP
	mark	1
	#NO_APP
	li	a0, 7
	a.blt	a2, a1, .LBB0_2
.LBB0_1:
	li	a0, 3
.LBB0_2:
	#APP
	mark	2
	#NO_APP
	ret
.Lfunc_end0:
	.size	triangle, .Lfunc_end0-triangle
                                        # -- End function
	.ident	"clang version 16.0.5 (https://github.com/Danacus/llvm-project-ami-cfl.git f160e224b5f040b340b3ae0693b41dacc0458ef0)"
	.section	".note.GNU-stack","",@progbits
