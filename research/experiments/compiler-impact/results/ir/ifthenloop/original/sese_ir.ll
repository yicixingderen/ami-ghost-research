; ModuleID = '/tmp/ami-compiler-impact-ouu2jjpk/baseline.ll'
source_filename = "/home/yicixingderen/ami/workspace/ami-compiler-performance/evaluation/ifthenloop/ifthenloop.c"
target datalayout = "e-m:e-p:32:32-i64:64-n32-S128"
target triple = "riscv32-unknown-unknown"

@v = internal global i32 0, align 4
@.str = private unnamed_addr constant [10 x i8] c"secret(0)\00", section "llvm.metadata"
@.str.1 = private unnamed_addr constant [94 x i8] c"/home/yicixingderen/ami/workspace/ami-compiler-performance/evaluation/ifthenloop/ifthenloop.c\00", section "llvm.metadata"
@llvm.global.annotations = appending global [1 x { ptr, ptr, ptr, i32, ptr }] [{ ptr, ptr, ptr, i32, ptr } { ptr @v, ptr @.str, ptr @.str.1, i32 4, ptr null }], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local secret(1) i32 @ifthenloop(i32 noundef secret(1) %0, i32 noundef %1) local_unnamed_addr #0 {
  store i32 0, ptr @v, align 4, !tbaa !4
  tail call void asm sideeffect "mark 1", ""() #2, !srcloc !8
  %3 = icmp slt i32 %0, %1
  br i1 %3, label %.preheader, label %Flow

.preheader:                                       ; preds = %2
  br label %4

Flow:                                             ; preds = %.loopexit, %2
  br label %8

4:                                                ; preds = %.preheader, %4
  %5 = phi i32 [ %6, %4 ], [ 0, %.preheader ]
  tail call fastcc void @foo() #3
  %6 = add nuw nsw i32 %5, 1
  %7 = icmp eq i32 %6, 3
  br i1 %7, label %.loopexit, label %4

.loopexit:                                        ; preds = %4
  br label %Flow

8:                                                ; preds = %Flow
  tail call void asm sideeffect "mark 2", ""() #2, !srcloc !9
  %9 = load i32, ptr @v, align 4, !tbaa !4
  ret i32 %9
}

; Function Attrs: mimicable mustprogress nofree noinline norecurse nosync nounwind willreturn memory(readwrite, argmem: none, inaccessiblemem: none)
define internal fastcc void @foo() unnamed_addr #1 {
  %1 = load i32, ptr @v, align 4, !tbaa !4
  %2 = add nsw i32 %1, 1
  store i32 %2, ptr @v, align 4, !tbaa !4
  ret void
}

attributes #0 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic-rv32" "target-features"="+32bit,+m,+relax,-a,-c,-d,-e,-experimental-zawrs,-experimental-zca,-experimental-zcd,-experimental-zcf,-experimental-zihintntl,-experimental-ztso,-experimental-zvfh,-f,-h,-save-restore,-svinval,-svnapot,-svpbmt,-v,-xtheadvdot,-xventanacondops,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zdinx,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zicbom,-zicbop,-zicboz,-zihintpause,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-zmmul,-zve32f,-zve32x,-zve64d,-zve64f,-zve64x,-zvl1024b,-zvl128b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl32b,-zvl4096b,-zvl512b,-zvl64b,-zvl65536b,-zvl8192b" }
attributes #1 = { mimicable mustprogress nofree noinline norecurse nosync nounwind willreturn memory(readwrite, argmem: none, inaccessiblemem: none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic-rv32" "target-features"="+32bit,+m,+relax,-a,-c,-d,-e,-experimental-zawrs,-experimental-zca,-experimental-zcd,-experimental-zcf,-experimental-zihintntl,-experimental-ztso,-experimental-zvfh,-f,-h,-save-restore,-svinval,-svnapot,-svpbmt,-v,-xtheadvdot,-xventanacondops,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zdinx,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zicbom,-zicbop,-zicboz,-zihintpause,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-zmmul,-zve32f,-zve32x,-zve64d,-zve64f,-zve64x,-zvl1024b,-zvl128b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl32b,-zvl4096b,-zvl512b,-zvl64b,-zvl65536b,-zvl8192b" }
attributes #2 = { nounwind }
attributes #3 = { mimicable }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 1, !"target-abi", !"ilp32"}
!2 = !{i32 1, !"SmallDataLimit", i32 8}
!3 = !{!"clang version 16.0.5 (https://github.com/Danacus/llvm-project-ami-cfl.git 383a9a6c18e5869698e2be5eca1dfc57fd04c05a)"}
!4 = !{!5, !5, i64 0}
!5 = !{!"int", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C/C++ TBAA"}
!8 = !{i64 2147496156}
!9 = !{i64 2147500244}
