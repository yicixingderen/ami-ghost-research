	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0"
	.file	"ifthenloop.c"
	.globl	ifthenloop                      # -- Begin function ifthenloop
	.p2align	2
	.type	ifthenloop,@function
ifthenloop:                             # @ifthenloop
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	sw	s1, 4(sp)                       # 4-byte Folded Spill
	lui	s0, %hi(v)
	sw	zero, %lo(v)(s0)
	#APP
	mark	1
	#NO_APP
	a.bge	a0, a1, .LBB0_3
.LBB0_1:                                # %.preheader
	p.addi	s1, zero, 3
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	call	foo
	p.addi	s1, s1, -1
	bnez	s1, .LBB0_2
.LBB0_3:
	#APP
	mark	2
	#NO_APP
	lw	a0, %lo(v)(s0)
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	lw	s1, 4(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
.Lfunc_end0:
	.size	ifthenloop, .Lfunc_end0-ifthenloop
                                        # -- End function
	.p2align	2                               # -- Begin function foo
	.type	foo,@function
foo:                                    # @foo
# %bb.0:
	p.lui	a0, %hi(v)
	lw	a1, %lo(v)(a0)
	addi	a1, a1, 1
	mv	a1, a1
	g.lw	a1, %lo(v)(a0)
	sw	a1, %lo(v)(a0)
	ret
.Lfunc_end1:
	.size	foo, .Lfunc_end1-foo
                                        # -- End function
	.type	v,@object                       # @v
	.section	.sbss,"aw",@nobits
	.p2align	2
v:
	.word	0                               # 0x0
	.size	v, 4

	.ident	"clang version 16.0.5 (https://github.com/Danacus/llvm-project-ami-cfl.git f160e224b5f040b340b3ae0693b41dacc0458ef0)"
	.section	".note.GNU-stack","",@progbits
