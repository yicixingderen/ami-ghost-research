; ModuleID = '/tmp/ami-compiler-impact-wordkyxg/baseline.ll'
source_filename = "/home/yicixingderen/ami/workspace/ami-compiler-performance/evaluation/mulmod16/mulmod16.c"
target datalayout = "e-m:e-p:32:32-i64:64-n32-S128"
target triple = "riscv32-unknown-unknown"

; Function Attrs: nounwind
define dso_local i32 @mulmod16(i32 noundef secret(1) %0, i32 noundef %1) local_unnamed_addr #0 {
  %3 = and i32 %0, 65535
  %4 = and i32 %1, 65535
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %5 = icmp ne i32 %3, 0
  br i1 %5, label %10, label %Flow2

Flow2:                                            ; preds = %Flow1, %2
  %6 = phi i32 [ %24, %Flow1 ], [ undef, %2 ]
  %7 = phi i1 [ false, %Flow1 ], [ true, %2 ]
  br i1 %7, label %8, label %25

8:                                                ; preds = %Flow2
  %9 = sub nuw nsw i32 65537, %4
  br label %25

10:                                               ; preds = %2
  %11 = icmp ne i32 %4, 0
  br i1 %11, label %16, label %Flow

Flow:                                             ; preds = %16, %10
  %12 = phi i32 [ %23, %16 ], [ undef, %10 ]
  %13 = phi i1 [ false, %16 ], [ true, %10 ]
  br i1 %13, label %14, label %Flow1

14:                                               ; preds = %Flow
  %15 = sub nuw nsw i32 65537, %3
  br label %Flow1

16:                                               ; preds = %10
  %17 = mul nuw nsw i32 %4, %3
  %18 = and i32 %17, 65535
  %19 = lshr i32 %17, 16
  %20 = sub nsw i32 %18, %19
  %21 = icmp ult i32 %18, %19
  %22 = zext i1 %21 to i32
  %23 = add nsw i32 %20, %22
  br label %Flow

Flow1:                                            ; preds = %14, %Flow
  %24 = phi i32 [ %15, %14 ], [ %12, %Flow ]
  br label %Flow2

25:                                               ; preds = %Flow2, %8
  %26 = phi i32 [ %6, %Flow2 ], [ %9, %8 ]
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !5
  %27 = and i32 %26, 65535
  ret i32 %27
}

attributes #0 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic-rv32" "target-features"="+32bit,+m,+relax,-a,-c,-d,-e,-experimental-zawrs,-experimental-zca,-experimental-zcd,-experimental-zcf,-experimental-zihintntl,-experimental-ztso,-experimental-zvfh,-f,-h,-save-restore,-svinval,-svnapot,-svpbmt,-v,-xtheadvdot,-xventanacondops,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zdinx,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zicbom,-zicbop,-zicboz,-zihintpause,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-zmmul,-zve32f,-zve32x,-zve64d,-zve64f,-zve64x,-zvl1024b,-zvl128b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl32b,-zvl4096b,-zvl512b,-zvl64b,-zvl65536b,-zvl8192b" }
attributes #1 = { nounwind }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 1, !"target-abi", !"ilp32"}
!2 = !{i32 1, !"SmallDataLimit", i32 8}
!3 = !{!"clang version 16.0.5 (https://github.com/Danacus/llvm-project-ami-cfl.git 383a9a6c18e5869698e2be5eca1dfc57fd04c05a)"}
!4 = !{i64 2147496190}
!5 = !{i64 2147500311}
