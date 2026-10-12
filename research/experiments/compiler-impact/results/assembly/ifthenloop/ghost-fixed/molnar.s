	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0"
	.file	"ifthenloop.c"
	.globl	ifthenloop                      # -- Begin function ifthenloop
	.p2align	2
	.type	ifthenloop,@function
ifthenloop:                             # @ifthenloop
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	sw	s1, 20(sp)                      # 4-byte Folded Spill
	sw	s2, 16(sp)                      # 4-byte Folded Spill
	sw	s3, 12(sp)                      # 4-byte Folded Spill
	sw	s4, 8(sp)                       # 4-byte Folded Spill
	lui	s0, %hi(cfl_taken)
	lw	s1, %lo(cfl_taken)(s0)
	lui	s2, %hi(v)
	lw	a2, %lo(v)(s2)
	not	a3, s1
	and	a4, s1, zero
	and	a2, a3, a2
	or	a2, a4, a2
	sw	a2, %lo(v)(s2)
	#APP
	mark	1
	#NO_APP
	slt	a0, a0, a1
	neg	a0, a0
	and	s3, a0, s1
	li	s4, 3
.LBB0_1:                                # =>This Inner Loop Header: Depth=1
	sw	s1, %lo(cfl_taken)(s0)
	sw	s3, %lo(cfl_taken)(s0)
	call	foo
	addi	s4, s4, -1
	bnez	s4, .LBB0_1
# %bb.2:                                # %Flow
	#APP
	mark	2
	#NO_APP
	lw	a0, %lo(v)(s2)
	sw	s1, %lo(cfl_taken)(s0)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	lw	s1, 20(sp)                      # 4-byte Folded Reload
	lw	s2, 16(sp)                      # 4-byte Folded Reload
	lw	s3, 12(sp)                      # 4-byte Folded Reload
	lw	s4, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end0:
	.size	ifthenloop, .Lfunc_end0-ifthenloop
                                        # -- End function
	.p2align	2                               # -- Begin function foo
	.type	foo,@function
foo:                                    # @foo
# %bb.0:
	lui	a0, %hi(cfl_taken)
	lw	a1, %lo(cfl_taken)(a0)
	lui	a2, %hi(v)
	lw	a3, %lo(v)(a2)
	lw	a4, %lo(v)(a2)
	addi	a3, a3, 1
	not	a5, a1
	and	a3, a1, a3
	and	a4, a5, a4
	or	a3, a3, a4
	sw	a3, %lo(v)(a2)
	sw	a1, %lo(cfl_taken)(a0)
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
