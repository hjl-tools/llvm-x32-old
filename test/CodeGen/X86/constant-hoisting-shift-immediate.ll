; RUN: llc < %s -O3 -march=x86-64 |FileCheck %s
; RUN: llc < %s -O3 -mtriple=x86_64-linux-gnux32 |FileCheck %s
define i64 @foo(i1 %z, i192* %p, i192* %q)
{
; If const 128 is hoisted to a variable, then in basic block L_val2 we would
; have %lshr2 = lshr i192 %data2, %const, and the definition of %const would
; be in another basic block. As a result, a very inefficient code might be
; produced. Here we check that this doesn't occur.
entry:
  %data1 = load i192, i192* %p, align 8
  %lshr1 = lshr i192 %data1, 128
  %val1  = trunc i192 %lshr1 to i64
  br i1 %z, label %End, label %L_val2

; CHECK: movq    16(%{{r|e}}dx), %rax
; CHECK-NEXT: retq
L_val2:
  %data2 = load i192, i192* %q, align 8
  %lshr2 = lshr i192 %data2, 128
  %val2  = trunc i192 %lshr2 to i64
  br label %End

End:
  %p1 = phi i64 [%val1,%entry], [%val2,%L_val2]
  ret i64 %p1
}
