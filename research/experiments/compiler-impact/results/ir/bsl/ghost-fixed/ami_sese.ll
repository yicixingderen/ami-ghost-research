; ModuleID = '/tmp/ami-compiler-impact-l4ubmg9u/baseline.ll'
source_filename = "/home/yicixingderen/ami/workspace/ami-compiler-performance/evaluation/bsl/bsl.c"
target datalayout = "e-m:e-p:32:32-i64:64-n32-S128"
target triple = "riscv32-unknown-unknown"

@LockedStatus = internal global i32 0, align 4
@.str.1 = private unnamed_addr constant [10 x i8] c"secret(0)\00", section "llvm.metadata"
@.str.2 = private unnamed_addr constant [80 x i8] c"/home/yicixingderen/ami/workspace/ami-compiler-performance/evaluation/bsl/bsl.c\00", section "llvm.metadata"
@llvm.global.annotations = appending global [1 x { ptr, ptr, ptr, i32, ptr }] [{ ptr, ptr, ptr, i32, ptr } { ptr @LockedStatus, ptr @.str.1, ptr @.str.2, i32 6, ptr null }], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local zeroext i8 @BSL430_unlock_BSL(ptr nocapture noundef readonly secret(2) %0) local_unnamed_addr #0 {
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %2 = load i8, ptr %0, align 1, !tbaa !5
  %3 = icmp eq i8 %2, 48
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %4 = getelementptr inbounds i8, ptr %0, i32 1
  %5 = load i8, ptr %4, align 1, !tbaa !5
  %6 = icmp eq i8 %5, 49
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %7 = getelementptr inbounds i8, ptr %0, i32 2
  %8 = load i8, ptr %7, align 1, !tbaa !5
  %9 = icmp eq i8 %8, 50
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %10 = getelementptr inbounds i8, ptr %0, i32 3
  %11 = load i8, ptr %10, align 1, !tbaa !5
  %12 = icmp eq i8 %11, 51
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %13 = getelementptr inbounds i8, ptr %0, i32 4
  %14 = load i8, ptr %13, align 1, !tbaa !5
  %15 = icmp eq i8 %14, 52
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %16 = getelementptr inbounds i8, ptr %0, i32 5
  %17 = load i8, ptr %16, align 1, !tbaa !5
  %18 = icmp eq i8 %17, 53
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %19 = getelementptr inbounds i8, ptr %0, i32 6
  %20 = load i8, ptr %19, align 1, !tbaa !5
  %21 = icmp eq i8 %20, 54
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %22 = getelementptr inbounds i8, ptr %0, i32 7
  %23 = load i8, ptr %22, align 1, !tbaa !5
  %24 = icmp eq i8 %23, 55
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %25 = getelementptr inbounds i8, ptr %0, i32 8
  %26 = load i8, ptr %25, align 1, !tbaa !5
  %27 = icmp eq i8 %26, 56
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %28 = getelementptr inbounds i8, ptr %0, i32 9
  %29 = load i8, ptr %28, align 1, !tbaa !5
  %30 = icmp eq i8 %29, 57
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %31 = getelementptr inbounds i8, ptr %0, i32 10
  %32 = load i8, ptr %31, align 1, !tbaa !5
  %33 = icmp eq i8 %32, 65
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %34 = getelementptr inbounds i8, ptr %0, i32 11
  %35 = load i8, ptr %34, align 1, !tbaa !5
  %36 = icmp eq i8 %35, 66
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %37 = getelementptr inbounds i8, ptr %0, i32 12
  %38 = load i8, ptr %37, align 1, !tbaa !5
  %39 = icmp eq i8 %38, 67
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %40 = getelementptr inbounds i8, ptr %0, i32 13
  %41 = load i8, ptr %40, align 1, !tbaa !5
  %42 = icmp eq i8 %41, 68
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %43 = getelementptr inbounds i8, ptr %0, i32 14
  %44 = load i8, ptr %43, align 1, !tbaa !5
  %45 = icmp eq i8 %44, 69
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %46 = getelementptr inbounds i8, ptr %0, i32 15
  %47 = load i8, ptr %46, align 1, !tbaa !5
  %48 = icmp eq i8 %47, 70
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %49 = getelementptr inbounds i8, ptr %0, i32 16
  %50 = load i8, ptr %49, align 1, !tbaa !5
  %51 = icmp eq i8 %50, 0
  %52 = select i1 %51, i1 %48, i1 false
  %53 = select i1 %52, i1 %45, i1 false
  %54 = select i1 %53, i1 %42, i1 false
  %55 = select i1 %54, i1 %39, i1 false
  %56 = select i1 %55, i1 %36, i1 false
  %57 = select i1 %56, i1 %33, i1 false
  %58 = select i1 %57, i1 %30, i1 false
  %59 = select i1 %58, i1 %27, i1 false
  %60 = select i1 %59, i1 %24, i1 false
  %61 = select i1 %60, i1 %21, i1 false
  %62 = select i1 %61, i1 %18, i1 false
  %63 = select i1 %62, i1 %15, i1 false
  %64 = select i1 %63, i1 %12, i1 false
  %65 = select i1 %64, i1 %9, i1 false
  %66 = select i1 %65, i1 %6, i1 false
  %67 = select i1 %66, i1 %3, i1 false
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !8
  %68 = select i1 %67, i32 42404, i32 0
  %69 = select i1 %67, i8 0, i8 5
  store i32 %68, ptr @LockedStatus, align 4, !tbaa !9
  ret i8 %69
}

attributes #0 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic-rv32" "target-features"="+32bit,+m,+relax,-a,-c,-d,-e,-experimental-zawrs,-experimental-zca,-experimental-zcd,-experimental-zcf,-experimental-zihintntl,-experimental-ztso,-experimental-zvfh,-f,-h,-save-restore,-svinval,-svnapot,-svpbmt,-v,-xtheadvdot,-xventanacondops,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zdinx,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zicbom,-zicbop,-zicboz,-zihintpause,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-zmmul,-zve32f,-zve32x,-zve64d,-zve64f,-zve64x,-zvl1024b,-zvl128b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl32b,-zvl4096b,-zvl512b,-zvl64b,-zvl65536b,-zvl8192b" }
attributes #1 = { nounwind }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 1, !"target-abi", !"ilp32"}
!2 = !{i32 1, !"SmallDataLimit", i32 8}
!3 = !{!"clang version 16.0.5 (https://github.com/Danacus/llvm-project-ami-cfl.git f160e224b5f040b340b3ae0693b41dacc0458ef0)"}
!4 = !{i64 2147497809}
!5 = !{!6, !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C/C++ TBAA"}
!8 = !{i64 2147501897}
!9 = !{!10, !10, i64 0}
!10 = !{!"int", !6, i64 0}
