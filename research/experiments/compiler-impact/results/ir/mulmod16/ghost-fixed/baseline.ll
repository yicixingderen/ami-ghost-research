; ModuleID = '/home/yicixingderen/ami/workspace/ami-compiler-performance/evaluation/mulmod16/mulmod16.c'
source_filename = "/home/yicixingderen/ami/workspace/ami-compiler-performance/evaluation/mulmod16/mulmod16.c"
target datalayout = "e-m:e-p:32:32-i64:64-n32-S128"
target triple = "riscv32-unknown-unknown"

; Function Attrs: nounwind
define dso_local i32 @mulmod16(i32 noundef secret(1) %0, i32 noundef %1) local_unnamed_addr #0 {
  %3 = and i32 %0, 65535
  %4 = and i32 %1, 65535
  tail call void asm sideeffect "mark 1", ""() #1, !srcloc !4
  %5 = icmp eq i32 %3, 0
  br i1 %5, label %6, label %8

6:                                                ; preds = %2
  %7 = sub nuw nsw i32 65537, %4
  br label %20

8:                                                ; preds = %2
  %9 = icmp eq i32 %4, 0
  br i1 %9, label %10, label %12

10:                                               ; preds = %8
  %11 = sub nuw nsw i32 65537, %3
  br label %20

12:                                               ; preds = %8
  %13 = mul nuw nsw i32 %4, %3
  %14 = and i32 %13, 65535
  %15 = lshr i32 %13, 16
  %16 = sub nsw i32 %14, %15
  %17 = icmp ult i32 %14, %15
  %18 = zext i1 %17 to i32
  %19 = add nsw i32 %16, %18
  br label %20

20:                                               ; preds = %10, %12, %6
  %21 = phi i32 [ %7, %6 ], [ %11, %10 ], [ %19, %12 ]
  tail call void asm sideeffect "mark 2", ""() #1, !srcloc !5
  %22 = and i32 %21, 65535
  ret i32 %22
}

attributes #0 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic-rv32" "target-features"="+32bit,+m,+relax,-a,-c,-d,-e,-experimental-zawrs,-experimental-zca,-experimental-zcd,-experimental-zcf,-experimental-zihintntl,-experimental-ztso,-experimental-zvfh,-f,-h,-save-restore,-svinval,-svnapot,-svpbmt,-v,-xtheadvdot,-xventanacondops,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zdinx,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zicbom,-zicbop,-zicboz,-zihintpause,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-zmmul,-zve32f,-zve32x,-zve64d,-zve64f,-zve64x,-zvl1024b,-zvl128b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl32b,-zvl4096b,-zvl512b,-zvl64b,-zvl65536b,-zvl8192b" }
attributes #1 = { nounwind }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 1, !"target-abi", !"ilp32"}
!2 = !{i32 1, !"SmallDataLimit", i32 8}
!3 = !{!"clang version 16.0.5 (https://github.com/Danacus/llvm-project-ami-cfl.git f160e224b5f040b340b3ae0693b41dacc0458ef0)"}
!4 = !{i64 2147496190}
!5 = !{i64 2147500311}
