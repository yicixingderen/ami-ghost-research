	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0"
	.file	"fork.c"
	.globl	fork                            # -- Begin function fork
	.p2align	2
	.type	fork,@function
fork:                                   # @fork
# %bb.0:
	lui	a2, %hi(cfl_taken)
	lw	a3, %lo(cfl_taken)(a2)
	#APP
	mark	1
	#NO_APP
	addi	a4, a0, 2
	slt	a0, a0, a1
	xori	a0, a0, 1
	neg	a0, a0
	and	a0, a0, a3
	li	a1, 3
	not	a5, a0
	and	a0, a0, a1
	and	a4, a5, a4
	or	a0, a0, a4
	#APP
	mark	2
	#NO_APP
	sw	a3, %lo(cfl_taken)(a2)
	ret
.Lfunc_end0:
	.size	fork, .Lfunc_end0-fork
                                        # -- End function
	.ident	"clang version 16.0.5 (https://github.com/Danacus/llvm-project-ami-cfl.git f160e224b5f040b340b3ae0693b41dacc0458ef0)"
	.section	".note.GNU-stack","",@progbits
