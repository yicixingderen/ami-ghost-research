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
	#APP
	mark	1
	#NO_APP
	lbu	a1, 0(a0)
	xori	a1, a1, 48
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	a2, 1(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	a3, 2(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	a4, 3(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	a5, 4(a0)
	xori	a2, a2, 49
	xori	a3, a3, 50
	xori	a4, a4, 51
	xori	a5, a5, 52
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	a6, 5(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	a7, 6(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	t0, 7(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	t1, 8(a0)
	xori	a6, a6, 53
	xori	a7, a7, 54
	xori	t0, t0, 55
	xori	t1, t1, 56
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	t2, 9(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	t3, 10(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	t4, 11(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	t5, 12(a0)
	xori	t2, t2, 57
	xori	t3, t3, 65
	xori	t4, t4, 66
	xori	t5, t5, 67
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	t6, 13(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	s0, 14(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	s1, 15(a0)
	#APP
	mark	2
	#NO_APP
	#APP
	mark	1
	#NO_APP
	lbu	a0, 16(a0)
	xori	t6, t6, 68
	xori	s0, s0, 69
	xori	s1, s1, 70
	or	a0, a0, s1
	or	t6, s0, t6
	or	a0, a0, t6
	or	t4, t5, t4
	or	t3, t4, t3
	or	a0, a0, t3
	or	t1, t2, t1
	or	t0, t1, t0
	or	a7, t0, a7
	or	a0, a0, a7
	or	a5, a6, a5
	or	a4, a5, a4
	or	a3, a4, a3
	or	a2, a3, a2
	or	a0, a0, a2
	or	a0, a0, a1
	seqz	a0, a0
	#APP
	mark	2
	#NO_APP
	neg	a1, a0
	lui	a2, 10
	addi	a2, a2, 1444
	and	a1, a1, a2
	lui	a2, %hi(LockedStatus)
	addi	a0, a0, -1
	andi	a0, a0, 5
	sw	a1, %lo(LockedStatus)(a2)
	lw	s0, 12(sp)                      # 4-byte Folded Reload
	lw	s1, 8(sp)                       # 4-byte Folded Reload
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

	.ident	"clang version 16.0.5 (https://github.com/Danacus/llvm-project-ami-cfl.git f160e224b5f040b340b3ae0693b41dacc0458ef0)"
	.section	".note.GNU-stack","",@progbits
