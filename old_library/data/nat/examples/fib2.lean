/-
Copyright (c) 2015 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Leonardo de Moura

Show that tail recursive fib is equal to standard one.
-/
import data.nat
open nat

definition fib : nat → nat
| 0     := 1
| 1     := 1
| (n+2) := fib (n+1) + fib n

private definition fib_fast_aux : nat → nat → nat → nat
| 0     i j := j
| (n+1) i j := fib_fast_aux n j (j+i)

lemma fib_fast_aux_lemma : ∀ n m, fib_fast_aux n (fib m) (fib (succ m)) = fib (succ (n + m))
| 0        m := sorry -- by rewrite zero_add
| (succ n) m :=
  sorry
  /-
  begin
    have ih : fib_fast_aux n (fib (succ m)) (fib (succ (succ m))) = fib (succ (n + succ m)), from fib_fast_aux_lemma n (succ m),
    have h₁ : fib (succ m) + fib m = fib (succ (succ m)), from rfl,
    change fib_fast_aux n (fib (succ m)) (fib (succ m) + fib m) = fib (succ (succ n + m)),
    rewrite [h₁, ih, succ_add, add_succ]
  end
  -/

definition fib_fast (n: nat) :=
fib_fast_aux n 0 1

lemma fib_fast_eq_fib : ∀ n, fib_fast n = fib n
| 0        := rfl
| (succ n) :=
  sorry
  /-
  begin
    have h₁ : fib_fast_aux n (fib 0) (fib 1) = fib (succ n), from !fib_fast_aux_lemma,
    change fib_fast_aux n 1 (1+0) = fib (succ n),
    krewrite h₁
  end
  -/
