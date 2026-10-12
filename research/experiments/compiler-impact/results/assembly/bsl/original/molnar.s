	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0"
	.file	"bsl.c"
	.globl	BSL430_unlock_BSL               # -- Begin function BSL430_unlock_BSL
	.p2align	2
	.type	BSL430_unlock_BSL,@function
BSL430_unlock_BSL:                      # @BSL430_unlock_BSL
# %bb.0:
	addi	sp, sp, -16
	sw	s0, 12(sp)                      # 4-byte Folded Spill
	sw	s1, 8(sp)                       # 4-byte Folded Spill
	sw	s2, 4(sp)                       # 4-byte Folded Spill
	sw	s3, 0(sp)                       # 4-byte Folded Spill
	lui	a1, %hi(cfl_taken)
	lw	a2, %lo(cfl_taken)(a1)
	#APP
	mark	1
	#NO_APP
	lbu	a3, 0(a0)
	xori	a3, a3, 48
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	a4, 1(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	a5, 2(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	a6, 3(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	a7, 4(a0)
	xori	a4, a4, 49
	xori	a5, a5, 50
	xori	a6, a6, 51
	xori	a7, a7, 52
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	t0, 5(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	t1, 6(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	t2, 7(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	t3, 8(a0)
	xori	t0, t0, 53
	xori	t1, t1, 54
	xori	t2, t2, 55
	xori	t3, t3, 56
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	t4, 9(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	t5, 10(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	t6, 11(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	s0, 12(a0)
	xori	t4, t4, 57
	xori	t5, t5, 65
	xori	t6, t6, 66
	xori	s0, s0, 67
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	s1, 13(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	s2, 14(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	s3, 15(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	a0, 16(a0)
	xori	s1, s1, 68
	xori	s2, s2, 69
	xori	s3, s3, 70
	or	a0, a0, s3
	or	s1, s2, s1
	or	a0, a0, s1
	or	t6, s0, t6
	or	t5, t6, t5
	or	a0, a0, t5
	or	t3, t4, t3
	or	t2, t3, t2
	or	t1, t2, t1
	or	a0, a0, t1
	or	a7, t0, a7
	or	a6, a7, a6
	or	a5, a6, a5
	or	a4, a5, a4
	or	a0, a0, a4
	or	a0, a0, a3
	seqz	a0, a0
	#APP
	mark	2
	#NO_APP
	neg	a3, a0
	lui	a4, 10
	addi	a4, a4, 1444
	lui	a5, %hi(LockedStatus)
	lw	a6, %lo(LockedStatus)(a5)
	and	a3, a3, a4
	not	a4, a2
	and	a3, a2, a3
	and	a4, a4, a6
	or	a3, a3, a4
	sw	a3, %lo(LockedStatus)(a5)
	addi	a0, a0, -1
	andi	a0, a0, 5
	sw	a2, %lo(cfl_taken)(a1)
	lw	s0, 12(sp)                      # 4-byte Folded Reload
	lw	s1, 8(sp)                       # 4-byte Folded Reload
	lw	s2, 4(sp)                       # 4-byte Folded Reload
	lw	s3, 0(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
.Lfunc_end0:
	.size	BSL430_unlock_BSL, .Lfunc_end0-BSL430_unlock_BSL
                                        # -- End function
	.type	LockedStatus,@object            # @LockedStatus
	.section	.sbss,"aw",@nobits
	.p2align	2
LockedStatus:
	.word	0                               # 0x0
	.size	LockedStatus, 4

	.ident	"clang version 16.0.5 (https://github.com/Danacus/llvm-project-ami-cfl.git 383a9a6c18e5869698e2be5eca1dfc57fd04c05a)"
	.section	".note.GNU-stack","",@progbits
