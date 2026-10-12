; ModuleID = '/home/yicixingderen/ami/workspace/ami-compiler-performance/evaluation/modexp2/modexp2.c'
source_filename = "/home/yicixingderen/ami/workspace/ami-compiler-performance/evaluation/modexp2/modexp2.c"
target datalayout = "e-m:e-p:32:32-i64:64-n32-S128"
target triple = "riscv32-unknown-unknown"

; Function Attrs: nounwind
define dso_local i32 @modexp2(i32 noundef %0, i32 noundef secret(1) %1) local_unnamed_addr #0 {
  br label %5

3:                                                ; preds = %15
  %4 = srem i32 %16, 7
  ret i32 %4

5:                                                ; preds = %2, %15
  %6 = phi i32 [ 0, %2 ], [ %20, %15 ]
  %7 = phi i32 [ 1, %2 ], [ %16, %15 ]
  %8 = phi i32 [ %1, %2 ], [ %19, %15 ]
  %9 = phi i32 [ %0, %2 ], [ %18, %15 ]
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %10 = and i32 %8, -2147483647
  %11 = icmp eq i32 %10, 1
  br i1 %11, label %12, label %15

12:                                               ; preds = %5
  %13 = mul nsw i32 %7, %9
  %14 = srem i32 %13, 7
  br label %15

15:                                               ; preds = %12, %5
  %16 = phi i32 [ %14, %12 ], [ %7, %5 ]
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !5
  %17 = mul nsw i32 %9, %9
  %18 = urem i32 %17, 7
  %19 = ashr i32 %8, 1
  %20 = add nuw nsw i32 %6, 1
  %21 = icmp eq i32 %20, 32
  br i1 %21, label %3, label %5, !llvm.loop !6
}

attributes #0 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic-rv32" "target-features"="+32bit,+m,+relax,-a,-c,-d,-e,-experimental-zawrs,-experimental-zca,-experimental-zcd,-experimental-zcf,-experimental-zihintntl,-experimental-ztso,-experimental-zvfh,-f,-h,-save-restore,-svinval,-svnapot,-svpbmt,-v,-xtheadvdot,-xventanacondops,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zdinx,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zicbom,-zicbop,-zicboz,-zihintpause,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-zmmul,-zve32f,-zve32x,-zve64d,-zve64f,-zve64x,-zvl1024b,-zvl128b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl32b,-zvl4096b,-zvl512b,-zvl64b,-zvl65536b,-zvl8192b" }
attributes #1 = { nounwind }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 1, !"target-abi", !"ilp32"}
!2 = !{i32 1, !"SmallDataLimit", i32 8}
!3 = !{!"clang version 16.0.5 (https://github.com/Danacus/llvm-project-ami-cfl.git 383a9a6c18e5869698e2be5eca1dfc57fd04c05a)"}
!4 = !{i64 2147496040}
!5 = !{i64 2147500130}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
