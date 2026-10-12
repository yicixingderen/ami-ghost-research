; ModuleID = '/tmp/ami-compiler-impact-fw29q3rx/baseline.ll'
source_filename = "/home/yicixingderen/ami/workspace/ami-compiler-performance/evaluation/keypad/keypad.c"
target datalayout = "e-m:e-p:32:32-i64:64-n32-S128"
target triple = "riscv32-unknown-unknown"

@count = internal global i32 0, align 4
@key_state = internal global i16 0, align 2
@pin_idx = internal global i32 0, align 4
@keymap = internal global [16 x i32] [i32 49, i32 52, i32 55, i32 48, i32 50, i32 53, i32 56, i32 70, i32 51, i32 54, i32 57, i32 69, i32 65, i32 66, i32 67, i32 68], align 4
@pin = internal global [4 x i8] zeroinitializer, align 1
@.str = private unnamed_addr constant [10 x i8] c"secret(0)\00", section "llvm.metadata"
@.str.1 = private unnamed_addr constant [86 x i8] c"/home/yicixingderen/ami/workspace/ami-compiler-performance/evaluation/keypad/keypad.c\00", section "llvm.metadata"
@.str.2 = private unnamed_addr constant [10 x i8] c"secret(1)\00", section "llvm.metadata"
@llvm.global.annotations = appending global [5 x { ptr, ptr, ptr, i32, ptr }] [{ ptr, ptr, ptr, i32, ptr } { ptr @pin, ptr @.str, ptr @.str.1, i32 17, ptr null }, { ptr, ptr, ptr, i32, ptr } { ptr @count, ptr @.str, ptr @.str.1, i32 8, ptr null }, { ptr, ptr, ptr, i32, ptr } { ptr @key_state, ptr @.str.2, ptr @.str.1, i32 9, ptr null }, { ptr, ptr, ptr, i32, ptr } { ptr @pin_idx, ptr @.str, ptr @.str.1, i32 10, ptr null }, { ptr, ptr, ptr, i32, ptr } { ptr @keymap, ptr @.str, ptr @.str.1, i32 11, ptr null }], section "llvm.metadata"
@switch.table.read_key_state = private unnamed_addr constant [10 x i16] [i16 1, i16 1, i16 0, i16 2, i16 0, i16 4, i16 0, i16 8, i16 0, i16 16], align 2

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(write, argmem: none, inaccessiblemem: none)
define dso_local void @keypad_init() local_unnamed_addr #0 {
  store i32 0, ptr @count, align 4, !tbaa !4
  store i16 0, ptr @key_state, align 2, !tbaa !8
  store i32 0, ptr @pin_idx, align 4, !tbaa !4
  ret void
}

; Function Attrs: nounwind
define dso_local i32 @keypad_poll() local_unnamed_addr #1 {
  %1 = tail call fastcc zeroext secret(1) i16 @read_key_state()
  %2 = zext i16 %1 to i32
  br label %6

3:                                                ; preds = %25
  store i16 %1, ptr @key_state, align 2, !tbaa !8
  %4 = load i32, ptr @pin_idx, align 4, !tbaa !4
  %5 = sub nsw i32 4, %4
  ret i32 %5

6:                                                ; preds = %0, %25
  %7 = phi i32 [ %26, %25 ], [ 1, %0 ]
  %8 = phi i32 [ %27, %25 ], [ 0, %0 ]
  %9 = and i32 %7, %2
  %10 = load i16, ptr @key_state, align 2, !tbaa !8
  %11 = zext i16 %10 to i32
  %12 = and i32 %7, %11
  tail call void asm sideeffect "mark 1", ""() #3, !srcloc !10
  %13 = icmp ne i32 %9, 0
  %14 = icmp eq i32 %12, 0
  %15 = select i1 %13, i1 %14, i1 false
  %16 = load i32, ptr @pin_idx, align 4
  %17 = icmp slt i32 %16, 4
  %18 = select i1 %15, i1 %17, i1 false
  br i1 %18, label %19, label %25

19:                                               ; preds = %6
  %20 = getelementptr inbounds [16 x i32], ptr @keymap, i32 0, i32 %8
  %21 = load i32, ptr %20, align 4, !tbaa !4
  %22 = trunc i32 %21 to i8
  %23 = add nsw i32 %16, 1
  store i32 %23, ptr @pin_idx, align 4, !tbaa !4
  %24 = getelementptr inbounds [4 x i8], ptr @pin, i32 0, i32 %16
  store volatile i8 %22, ptr %24, align 1, !tbaa !11
  br label %25

25:                                               ; preds = %6, %19
  tail call void asm sideeffect "mark 2", ""() #3, !srcloc !12
  %26 = shl i32 %7, 1
  %27 = add nuw nsw i32 %8, 1
  %28 = icmp eq i32 %27, 16
  br i1 %28, label %3, label %6
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(readwrite, argmem: none, inaccessiblemem: none)
define internal fastcc zeroext secret(1) i16 @read_key_state() unnamed_addr #2 {
  %1 = load i32, ptr @count, align 4, !tbaa !4
  %2 = add nsw i32 %1, 1
  store i32 %2, ptr @count, align 4, !tbaa !4
  %3 = add i32 %1, -1
  %4 = icmp ult i32 %3, 10
  br i1 %4, label %5, label %8

5:                                                ; preds = %0
  %6 = getelementptr inbounds [10 x i16], ptr @switch.table.read_key_state, i32 0, i32 %3
  %7 = load i16, ptr %6, align 2
  br label %8

8:                                                ; preds = %0, %5
  %9 = phi i16 [ 0, %0 ], [ %7, %5 ]
  ret i16 %9
}

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(write, argmem: none, inaccessiblemem: none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic-rv32" "target-features"="+32bit,+m,+relax,-a,-c,-d,-e,-experimental-zawrs,-experimental-zca,-experimental-zcd,-experimental-zcf,-experimental-zihintntl,-experimental-ztso,-experimental-zvfh,-f,-h,-save-restore,-svinval,-svnapot,-svpbmt,-v,-xtheadvdot,-xventanacondops,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zdinx,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zicbom,-zicbop,-zicboz,-zihintpause,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-zmmul,-zve32f,-zve32x,-zve64d,-zve64f,-zve64x,-zvl1024b,-zvl128b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl32b,-zvl4096b,-zvl512b,-zvl64b,-zvl65536b,-zvl8192b" }
attributes #1 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic-rv32" "target-features"="+32bit,+m,+relax,-a,-c,-d,-e,-experimental-zawrs,-experimental-zca,-experimental-zcd,-experimental-zcf,-experimental-zihintntl,-experimental-ztso,-experimental-zvfh,-f,-h,-save-restore,-svinval,-svnapot,-svpbmt,-v,-xtheadvdot,-xventanacondops,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zdinx,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zicbom,-zicbop,-zicboz,-zihintpause,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-zmmul,-zve32f,-zve32x,-zve64d,-zve64f,-zve64x,-zvl1024b,-zvl128b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl32b,-zvl4096b,-zvl512b,-zvl64b,-zvl65536b,-zvl8192b" }
attributes #2 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(readwrite, argmem: none, inaccessiblemem: none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic-rv32" "target-features"="+32bit,+m,+relax,-a,-c,-d,-e,-experimental-zawrs,-experimental-zca,-experimental-zcd,-experimental-zcf,-experimental-zihintntl,-experimental-ztso,-experimental-zvfh,-f,-h,-save-restore,-svinval,-svnapot,-svpbmt,-v,-xtheadvdot,-xventanacondops,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zdinx,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zicbom,-zicbop,-zicboz,-zihintpause,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-zmmul,-zve32f,-zve32x,-zve64d,-zve64f,-zve64x,-zvl1024b,-zvl128b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl32b,-zvl4096b,-zvl512b,-zvl64b,-zvl65536b,-zvl8192b" }
attributes #3 = { nounwind }

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
!8 = !{!9, !9, i64 0}
!9 = !{!"short", !6, i64 0}
!10 = !{i64 2147535730}
!11 = !{!6, !6, i64 0}
!12 = !{i64 2147535759}
