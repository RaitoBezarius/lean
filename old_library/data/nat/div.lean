/-
Copyright (c) 2014 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura

Definitions and properties of div and mod. Much of the development follows Isabelle's library.
-/
import .sub
open well_founded decidable prod

namespace nat

/- div -/

-- auxiliary lemma used to justify div
private definition div_rec_lemma {x y : nat} : 0 < y ∧ y ≤ x → x - y < x :=
and.rec (λ ypos ylex, sub_lt (lt_of_lt_of_le ypos ylex) ypos)

private definition div.F (x : nat) (f : Π x₁, x₁ < x → nat → nat) (y : nat) : nat :=
if H : 0 < y ∧ y ≤ x then f (x - y) (div_rec_lemma H) y + 1 else zero

protected definition div := fix lt_wf div.F

definition nat_has_divide : has_div nat :=
has_div.mk nat.div

local attribute [instance] nat_has_divide

theorem div_def (x y : nat) : div x y = if 0 < y ∧ y ≤ x then div (x - y) y + 1 else 0 :=
congr_fun (fix_eq lt_wf div.F x) y

attribute [simp]
protected theorem div_zero (a : ℕ) : a / 0 = 0 :=
eq.trans (div_def a 0) $ if_neg (not_and_of_not_left (0 ≤ a) (lt.irrefl 0))

theorem div_eq_zero_of_lt {a b : ℕ} (h : a < b) : a / b = 0 :=
eq.trans (div_def a b) $ if_neg (not_and_of_not_right (0 < b) (not_le_of_gt h))

attribute [simp]
protected theorem zero_div (b : ℕ) : 0 / b = 0 :=
eq.trans (div_def 0 b) $ if_neg (and.rec not_le_of_gt)

theorem div_eq_succ_sub_div {a b : ℕ} (h₁ : b > 0) (h₂ : a ≥ b) : a / b = succ ((a - b) / b) :=
eq.trans (div_def a b) $ if_pos (and.intro h₁ h₂)

theorem add_div_self (x : ℕ) {z : ℕ} (H : z > 0) : (x + z) / z = succ (x / z) :=
sorry
/-
calc
  (x + z) / z = if 0 < z ∧ z ≤ x + z then (x + z - z) / z + 1 else 0 : !div_def
            ... = (x + z - z) / z + 1 : if_pos (and.intro H (le_add_left z x))
            ... = succ (x / z)        : by rewrite nat.add_sub_cancel
-/

theorem add_div_self_left {x : ℕ} (z : ℕ) (H : x > 0) : (x + z) / x = succ (z / x) :=
add.comm z x ▸ add_div_self z H

local attribute succ_mul [simp]

theorem add_mul_div_self {x y z : ℕ} (H : z > 0) : (x + y * z) / z = x / z + y :=
sorry
/-
nat.induction_on y
  (by simp)
  (take y,
    assume IH : (x + y * z) / z = x / z + y, calc
      (x + succ y * z) / z = (x + y * z + z) / z    : by inst_simp
                       ... = succ ((x + y * z) / z) : !add_div_self H
                       ... = succ (x / z + y)       : by rewrite IH)
-/

theorem add_mul_div_self_left (x z : ℕ) {y : ℕ} (H : y > 0) : (x + y * z) / y = x / y + z :=
mul.comm z y ▸ add_mul_div_self H

protected theorem mul_div_cancel (m : ℕ) {n : ℕ} (H : n > 0) : m * n / n = m :=
sorry
/-
calc
  m * n / n = (0 + m * n) / n : by simp
          ... = 0 / n + m     : add_mul_div_self H
          ... = m             : by simp
-/

protected theorem mul_div_cancel_left {m : ℕ} (n : ℕ) (H : m > 0) : m * n / m = n :=
mul.comm n m ▸ nat.mul_div_cancel n H

/- mod -/

private definition mod.F (x : nat) (f : Π x₁, x₁ < x → nat → nat) (y : nat) : nat :=
if H : 0 < y ∧ y ≤ x then f (x - y) (div_rec_lemma H) y else x

protected definition mod := fix lt_wf mod.F

definition nat_has_mod : has_mod nat :=
has_mod.mk nat.mod

local attribute [instance] nat_has_mod

notation [priority nat.prio] a ≡ b `[mod `:0 c:0 `]` := a % c = b % c

theorem mod_def (x y : nat) : mod x y = if 0 < y ∧ y ≤ x then mod (x - y) y else x :=
congr_fun (fix_eq lt_wf mod.F x) y

attribute [simp]
theorem mod_zero (a : ℕ) : a % 0 = a :=
eq.trans (mod_def a 0) $ if_neg (not_and_of_not_left (0 ≤ a) (lt.irrefl 0))

theorem mod_eq_of_lt {a b : ℕ} (h : a < b) : a % b = a :=
eq.trans (mod_def a b) $ if_neg (not_and_of_not_right (0 < b) (not_le_of_gt h))

attribute [simp]
theorem zero_mod (b : ℕ) : 0 % b = 0 :=
eq.trans (mod_def 0 b) $ if_neg (λ h, and.rec_on h (λ l r, absurd (lt_of_lt_of_le l r) (lt.irrefl 0)))

theorem mod_eq_sub_mod {a b : ℕ} (h₁ : b > 0) (h₂ : a ≥ b) : a % b = (a - b) % b :=
eq.trans (mod_def a b) $ if_pos (and.intro h₁ h₂)

attribute [simp]
theorem add_mod_self (x z : ℕ) : (x + z) % z = x % z :=
sorry
/-
by_cases_zero_pos z
  (by rewrite add_zero)
  (take z, assume H : z > 0,
    calc
      (x + z) % z = if 0 < z ∧ z ≤ x + z then (x + z - z) % z else _ : !mod_def
                ... = (x + z - z) % z   : if_pos (and.intro H (le_add_left z x))
                ... = x % z             : by rewrite nat.add_sub_cancel)
-/

attribute [simp]
theorem add_mod_self_left (x z : ℕ) : (x + z) % x = z % x :=
add.comm z x ▸ add_mod_self z x

local attribute succ_mul [simp]

attribute [simp]
theorem add_mul_mod_self (x y z : ℕ) : (x + y * z) % z = x % z :=
sorry -- nat.induction_on y (by simp) (by inst_simp)

attribute [simp]
theorem add_mul_mod_self_left (x y z : ℕ) : (x + y * z) % y = x % y :=
sorry -- by inst_simp

attribute [simp]
theorem mul_mod_left (m n : ℕ) : (m * n) % n = 0 :=
sorry
/-
calc (m * n) % n = (0 + m * n) % n : by simp
            ...  = 0               : by inst_simp
-/

attribute [simp]
theorem mul_mod_right (m n : ℕ) : (m * n) % m = 0 :=
sorry -- by inst_simp

theorem mod_lt (x : ℕ) {y : ℕ} (H : y > 0) : x % y < y :=
nat.case_strong_induction_on x
  (show 0 % y < y, from eq.symm (zero_mod y) ▸ H)
  (take x,
    assume IH : ∀x', x' ≤ x → x' % y < y,
    show succ x % y < y, from
      by_cases -- (succ x < y)
        (assume H1 : succ x < y,
          have succ x % y = succ x, from mod_eq_of_lt H1,
          show succ x % y < y, from eq.symm this ▸ H1)
        (assume H1 : ¬ succ x < y,
          have y ≤ succ x, from le_of_not_gt H1,
          have h : succ x % y = (succ x - y) % y, from mod_eq_sub_mod H this,
          have succ x - y < succ x, from sub_lt (succ_pos x) H,
          have succ x - y ≤ x, from le_of_lt_succ this,
          show succ x % y < y, from eq.symm h ▸ IH _ this))

theorem mod_one (n : ℕ) : n % 1 = 0 :=
have H1 : n % 1 < 1, from (mod_lt n) (succ_pos 0),
eq_zero_of_le_zero (le_of_lt_succ H1)

/- properties of div and mod -/

-- the quotient - remainder theorem
theorem eq_div_mul_add_mod (x y : ℕ) : x = x / y * y + x % y :=
sorry
/-
begin
  eapply by_cases_zero_pos y,
  show x = x / 0 * 0 + x % 0, from
    (calc
      x / 0 * 0 + x % 0 = 0 + x % 0 : by rewrite mul_zero
        ... = x % 0                 : by rewrite zero_add
        ... = x                     : by rewrite mod_zero)⁻¹,
  intro y H,
  show x = x / y * y + x % y,
  begin
    eapply nat.case_strong_induction_on x,
    show 0 = (0 / y) * y + 0 % y, by rewrite [zero_mod, add_zero, nat.zero_div, zero_mul],
    intro x IH,
    show succ x = succ x / y * y + succ x % y, from
      if H1 : succ x < y then
         have H2 : succ x / y = 0, from div_eq_zero_of_lt H1,
         have H3 : succ x % y = succ x, from mod_eq_of_lt H1,
         begin rewrite [H2, H3, zero_mul, zero_add] end
      else
         have H2 : y ≤ succ x, from le_of_not_gt H1,
         have H3 : succ x / y = succ ((succ x - y) / y), from div_eq_succ_sub_div H H2,
         have H4 : succ x % y = (succ x - y) % y, from mod_eq_sub_mod H H2,
         have H5 : succ x - y < succ x, from sub_lt !succ_pos H,
         have H6 : succ x - y ≤ x, from le_of_lt_succ H5,
         (calc
             succ x / y * y + succ x % y =
                  succ ((succ x - y) / y) * y + succ x % y      : by rewrite H3
            ... = ((succ x - y) / y) * y + y + succ x % y       : by rewrite succ_mul
            ... = ((succ x - y) / y) * y + y + (succ x - y) % y : by rewrite H4
            ... = ((succ x - y) / y) * y + (succ x - y) % y + y : by rewrite add.right_comm
            ... = succ x - y + y                                : by rewrite -(IH _ H6)
            ... = succ x                                        : nat.sub_add_cancel H2)⁻¹
  end
end
-/

theorem mod_eq_sub_div_mul (x y : ℕ) : x % y = x - x / y * y :=
nat.eq_sub_of_add_eq (eq.symm (add.comm (x / y * y) (x % y) ▸ eq_div_mul_add_mod x y))

theorem mod_add_mod (m n k : ℕ) : (m % n + k) % n = (m + k) % n :=
sorry -- by rewrite [eq_div_mul_add_mod m n at {2}, add.assoc, add.comm (m / n * n), add_mul_mod_self]

theorem add_mod_mod (m n k : ℕ) : (m + n % k) % k = (m + n) % k :=
sorry -- by rewrite [add.comm, mod_add_mod, add.comm]

theorem add_mod_eq_add_mod_right {m n k : ℕ} (i : ℕ) (H : m % n = k % n) :
  (m + i) % n = (k + i) % n :=
sorry -- by rewrite [-mod_add_mod, -mod_add_mod k, H]

theorem add_mod_eq_add_mod_left {m n k : ℕ} (i : ℕ) (H : m % n = k % n) :
  (i + m) % n = (i + k) % n :=
sorry -- by rewrite [add.comm, add_mod_eq_add_mod_right _ H, add.comm]

theorem mod_eq_mod_of_add_mod_eq_add_mod_right {m n k i : ℕ} :
  (m + i) % n = (k + i) % n → m % n = k % n :=
sorry
/-
by_cases_zero_pos n
  (by rewrite [*mod_zero]; apply eq_of_add_eq_add_right)
  (take n,
    assume npos : n > 0,
    assume H1 : (m + i) % n = (k + i) % n,
    have H2 : (m + i % n) % n = (k + i % n) % n, by rewrite [*add_mod_mod, H1],
    have H3 : (m + i % n + (n - i % n)) % n = (k + i % n + (n - i % n)) % n,
      from add_mod_eq_add_mod_right _ H2,
    begin
      revert H3,
      rewrite [*add.assoc, add_sub_of_le (le_of_lt (!mod_lt npos)), *add_mod_self],
      intros, assumption
    end)
-/

theorem mod_eq_mod_of_add_mod_eq_add_mod_left {m n k i : ℕ} :
  (i + m) % n = (i + k) % n → m % n = k % n :=
sorry -- by rewrite [add.comm i m, add.comm i k]; apply mod_eq_mod_of_add_mod_eq_add_mod_right

theorem mod_le {x y : ℕ} : x % y ≤ x :=
eq.symm (eq_div_mul_add_mod x y) ▸ le_add_left (x % y) (x / y * y)

theorem eq_remainder {q1 r1 q2 r2 y : ℕ} (H1 : r1 < y) (H2 : r2 < y)
  (H3 : q1 * y + r1 = q2 * y + r2) : r1 = r2 :=
sorry
/-
calc
  r1 = r1 % y               : eq.symm (mod_eq_of_lt H1)
    ... = (r1 + q1 * y) % y : !add_mul_mod_self⁻¹
    ... = (q1 * y + r1) % y : by rewrite add.comm
    ... = (r2 + q2 * y) % y : by rewrite [H3, add.comm]
    ... = r2 % y            : !add_mul_mod_self
    ... = r2                : mod_eq_of_lt H2
-/

theorem eq_quotient {q1 r1 q2 r2 y : ℕ} (H1 : r1 < y) (H2 : r2 < y)
  (H3 : q1 * y + r1 = q2 * y + r2) : q1 = q2 :=
have H4 : q1 * y + r2 = q2 * y + r2, from (eq_remainder H1 H2 H3) ▸ H3,
have H5 : q1 * y = q2 * y, from add.right_cancel H4,
have H6 : y > 0, from lt_of_le_of_lt (zero_le r1) H1,
show q1 = q2, from eq_of_mul_eq_mul_right H6 H5

protected theorem mul_div_mul_left {z : ℕ} (x y : ℕ) (zpos : z > 0) :
  (z * x) / (z * y) = x / y :=
sorry
/-
if H : y = 0 then
  by rewrite [H, mul_zero, *nat.div_zero]
else
  have ypos : y > 0, from pos_of_ne_zero H,
  have zypos : z * y > 0, from mul_pos zpos ypos,
  have H1 : (z * x) % (z * y) < z * y, from !mod_lt zypos,
  have H2 : z * (x % y) < z * y, from mul_lt_mul_of_pos_left (!mod_lt ypos) zpos,
  eq_quotient H1 H2
    (calc
      ((z * x) / (z * y)) * (z * y) + (z * x) % (z * y) = z * x : by rewrite -eq_div_mul_add_mod
        ... = z * (x / y * y + x % y)                           : by rewrite -eq_div_mul_add_mod
        ... = z * (x / y * y) + z * (x % y)                     : !left_distrib
        ... = (x / y) * (z * y) + z * (x % y)                   : by rewrite mul.left_comm)
-/

protected theorem mul_div_mul_right {x z y : ℕ} (zpos : z > 0) : (x * z) / (y * z) = x / y :=
mul.comm z y ▸ mul.comm z x ▸ nat.mul_div_mul_left x y zpos

theorem mul_mod_mul_left (z x y : ℕ) : (z * x) % (z * y) = z * (x % y) :=
sorry
/-
or.elim (eq_zero_or_pos z)
  (assume H : z = 0, H⁻¹ ▸ calc
      (0 * x) % (z * y) = 0 % (z * y)   : by rewrite zero_mul
                      ... = 0           : by rewrite zero_mod
                      ... = 0 * (x % y) : by rewrite zero_mul)
  (assume zpos : z > 0,
    or.elim (eq_zero_or_pos y)
      (assume H : y = 0, by rewrite [H, mul_zero, *mod_zero])
      (assume ypos : y > 0,
        have zypos : z * y > 0, from mul_pos zpos ypos,
        have H1 : (z * x) % (z * y) < z * y, from !mod_lt zypos,
        have H2 : z * (x % y) < z * y, from mul_lt_mul_of_pos_left (!mod_lt ypos) zpos,
        eq_remainder H1 H2
          (calc
            ((z * x) / (z * y)) * (z * y) + (z * x) % (z * y) = z * x : by rewrite -eq_div_mul_add_mod
              ... = z * (x / y * y + x % y)                           : by rewrite -eq_div_mul_add_mod
              ... = z * (x / y * y) + z * (x % y)                     : by rewrite left_distrib
              ... = (x / y) * (z * y) + z * (x % y)                   : by rewrite mul.left_comm)))
-/

theorem mul_mod_mul_right (x z y : ℕ) : (x * z) % (y * z) = (x % y) * z :=
mul.comm z x ▸ mul.comm z y ▸ mul.comm z (x % y) ▸ mul_mod_mul_left z x y

theorem mod_self (n : ℕ) : n % n = 0 :=
sorry
/-
nat.cases_on n (by rewrite zero_mod)
  (take n, by rewrite [-zero_add (succ n) at {1}, add_mod_self])
-/

theorem mul_mod_eq_mod_mul_mod (m n k : nat) : (m * n) % k = ((m % k) * n) % k :=
sorry
/-
calc
  (m * n) % k = (((m / k) * k + m % k) * n) % k : by rewrite -eq_div_mul_add_mod
            ... = ((m % k) * n) % k             :
                    by rewrite [right_distrib, mul.right_comm, add.comm, add_mul_mod_self]
-/

theorem mul_mod_eq_mul_mod_mod (m n k : nat) : (m * n) % k = (m * (n % k)) % k :=
mul.comm (n % k) m ▸ mul.comm n m ▸ mul_mod_eq_mod_mul_mod n m k

protected theorem div_one (n : ℕ) : n / 1 = n :=
sorry
/-
have n / 1 * 1 + n % 1 = n, from !eq_div_mul_add_mod⁻¹,
begin rewrite [-this at {2}, mul_one, mod_one] end
-/

protected theorem div_self {n : ℕ} (H : n > 0) : n / n = 1 :=
sorry
/-
have (n * 1) / (n * 1) = 1 / 1, from !nat.mul_div_mul_left H,
by rewrite [nat.div_one at this, -this, *mul_one]
-/

theorem div_mul_cancel_of_mod_eq_zero {m n : ℕ} (H : m % n = 0) : m / n * n = m :=
sorry -- by rewrite [eq_div_mul_add_mod m n at {2}, H, add_zero]

theorem mul_div_cancel_of_mod_eq_zero {m n : ℕ} (H : m % n = 0) : n * (m / n) = m :=
mul.comm (m / n) n ▸ div_mul_cancel_of_mod_eq_zero H

/- dvd -/

theorem dvd_of_mod_eq_zero {m n : ℕ} (H : n % m = 0) : m ∣ n :=
dvd.intro (mul.comm (n / m) m ▸ div_mul_cancel_of_mod_eq_zero H)

theorem mod_eq_zero_of_dvd {m n : ℕ} (H : m ∣ n) : n % m = 0 :=
dvd.elim H (take z, assume H1 : n = m * z, eq.symm H1 ▸ mul_mod_right m z)

theorem dvd_iff_mod_eq_zero (m n : ℕ) : m ∣ n ↔ n % m = 0 :=
iff.intro mod_eq_zero_of_dvd dvd_of_mod_eq_zero

definition dvd.decidable_rel : decidable_rel dvd :=
take m n, decidable_of_decidable_of_iff _ (iff.symm $ dvd_iff_mod_eq_zero m n)

protected theorem div_mul_cancel {m n : ℕ} (H : n ∣ m) : m / n * n = m :=
div_mul_cancel_of_mod_eq_zero (mod_eq_zero_of_dvd H)

protected theorem mul_div_cancel' {m n : ℕ} (H : n ∣ m) : n * (m / n) = m :=
mul.comm (m / n) n ▸ nat.div_mul_cancel H

theorem dvd_of_dvd_add_left {m n₁ n₂ : ℕ} (H₁ : m ∣ n₁ + n₂) (H₂ : m ∣ n₁) : m ∣ n₂ :=
sorry
/-
obtain (c₁ : nat) (Hc₁ : n₁ + n₂ = m * c₁), from H₁,
obtain (c₂ : nat) (Hc₂ : n₁ = m * c₂), from H₂,
have   aux : m * (c₁ - c₂) = n₂, from calc
  m * (c₁ - c₂) = m * c₁  - m * c₂ : !nat.mul_sub_left_distrib
           ...  = n₁ + n₂ - m * c₂ : by rewrite Hc₁
           ...  = n₁ + n₂ - n₁     : by rewrite Hc₂
           ...  = n₂               : !nat.add_sub_cancel_left,
dvd.intro aux
-/

theorem dvd_of_dvd_add_right {m n₁ n₂ : ℕ} (H : m ∣ n₁ + n₂) : m ∣ n₂ → m ∣ n₁ :=
nat.dvd_of_dvd_add_left (add.comm n₁ n₂ ▸ H)

theorem dvd_sub {m n₁ n₂ : ℕ} (H1 : m ∣ n₁) (H2 : m ∣ n₂) : m ∣ n₁ - n₂ :=
by_cases
  (assume H3 : n₁ ≥ n₂,
    have H4 : n₁ = n₁ - n₂ + n₂, from eq.symm (nat.sub_add_cancel H3),
    show m ∣ n₁ - n₂, from nat.dvd_of_dvd_add_right (H4 ▸ H1) H2)
  (assume H3 : ¬ (n₁ ≥ n₂),
    have H4 : n₁ - n₂ = 0, from sub_eq_zero_of_le (le_of_lt (lt_of_not_ge H3)),
    show m ∣ n₁ - n₂, from eq.symm H4 ▸ dvd_zero _)

theorem dvd.antisymm {m n : ℕ} : m ∣ n → n ∣ m → m = n :=
sorry
/-
by_cases_zero_pos n
  (assume H1, assume H2 : 0 ∣ m, eq_zero_of_zero_dvd H2)
  (take n,
    assume Hpos : n > 0,
    assume H1 : m ∣ n,
    assume H2 : n ∣ m,
    obtain k (Hk : n = m * k), from exists_eq_mul_right_of_dvd H1,
    obtain l (Hl : m = n * l), from exists_eq_mul_right_of_dvd H2,
    have n * (l * k) = n, from !mul.assoc ▸ Hl ▸ Hk⁻¹,
    have l * k = 1,       from eq_one_of_mul_eq_self_right Hpos this,
    have k = 1,           from eq_one_of_mul_eq_one_left this,
    show m = n,           from (mul_one m)⁻¹ ⬝ (this ▸ Hk⁻¹))
-/

protected theorem mul_div_assoc (m : ℕ) {n k : ℕ} (H : k ∣ n) : m * n / k = m * (n / k) :=
sorry
/-
or.elim (eq_zero_or_pos k)
  (assume H1 : k = 0,
    calc
      m * n / k = m * n / 0     : by rewrite H1
              ... = 0           : by rewrite nat.div_zero
              ... = m * 0       : mul_zero m
              ... = m * (n / 0) : by rewrite nat.div_zero
              ... = m * (n / k) : by rewrite H1)
  (assume H1 : k > 0,
    have H2 : n = n / k * k, from (nat.div_mul_cancel H)⁻¹,
      calc
        m * n / k = m * (n / k * k) / k   : by rewrite -H2
                ... = m * (n / k) * k / k : by rewrite mul.assoc
                ... = m * (n / k)         : nat.mul_div_cancel _ H1)
-/

theorem dvd_of_mul_dvd_mul_left {m n k : ℕ} (kpos : k > 0) (H : k * m ∣ k * n) : m ∣ n :=
dvd.elim H
  (take l,
    assume H1 : k * n = k * m * l,
    have H2 : n = m * l, from eq_of_mul_eq_mul_left kpos (eq.trans H1 $ mul.assoc k m l),
    dvd.intro (eq.symm H2))

theorem dvd_of_mul_dvd_mul_right {m n k : ℕ} (kpos : k > 0) (H : m * k ∣ n * k) : m ∣ n :=
nat.dvd_of_mul_dvd_mul_left kpos (mul.comm n k ▸ mul.comm m k ▸ H)

lemma dvd_of_eq_mul (i j n : nat) : n = j*i → j ∣ n :=
sorry -- begin intros, subst n, apply dvd_mul_right end

theorem div_dvd_div {k m n : ℕ} (H1 : k ∣ m) (H2 : m ∣ n) : m / k ∣ n / k :=
have H3 : m = m / k * k, from eq.symm (nat.div_mul_cancel H1),
have H4 : n = n / k * k, from eq.symm (nat.div_mul_cancel (dvd.trans H1 H2)),
or.elim (eq_zero_or_pos k)
  (assume H5 : k = 0,
    have H6: n / k = 0, from (eq.trans (congr_arg _ H5) $ nat.div_zero n),
      eq.symm H6 ▸ dvd_zero (m / k))
  (assume H5 : k > 0,
    nat.dvd_of_mul_dvd_mul_right H5 (H3 ▸ H4 ▸ H2))

protected theorem div_eq_iff_eq_mul_right {m n : ℕ} (k : ℕ) (H : n > 0) (H' : n ∣ m) :
  m / n = k ↔ m = n * k :=
sorry
/-
iff.intro
  (assume H1, by rewrite [-H1, nat.mul_div_cancel' H'])
  (assume H1, by rewrite [H1, !nat.mul_div_cancel_left H])
-/

protected theorem div_eq_iff_eq_mul_left {m n : ℕ} (k : ℕ) (H : n > 0) (H' : n ∣ m) :
  m / n = k ↔ m = k * n :=
mul.comm n k ▸ nat.div_eq_iff_eq_mul_right k H H'

protected theorem eq_mul_of_div_eq_right {m n k : ℕ} (H1 : n ∣ m) (H2 : m / n = k) :
  m = n * k :=
sorry
/-
calc
  m     = n * (m / n) : by rewrite (nat.mul_div_cancel' H1)
    ... = n * k       : by rewrite H2
-/

protected theorem div_eq_of_eq_mul_right {m n k : ℕ} (H1 : n > 0) (H2 : m = n * k) :
  m / n = k :=
sorry
/-
calc
  m / n = n * k / n : by rewrite -H2
      ... = k       : by rewrite (!nat.mul_div_cancel_left H1)
-/

protected theorem eq_mul_of_div_eq_left {m n k : ℕ} (H1 : n ∣ m) (H2 : m / n = k) :
  m = k * n :=
mul.comm n k ▸ nat.eq_mul_of_div_eq_right H1 H2

protected theorem div_eq_of_eq_mul_left {m n k : ℕ} (H1 : n > 0) (H2 : m = k * n) :
  m / n = k :=
nat.div_eq_of_eq_mul_right H1 (mul.comm k n ▸ H2)

lemma add_mod_eq_of_dvd (i j n : nat) : n ∣ j → (i + j) % n = i % n :=
sorry
/-
assume h,
obtain k (hk : j = n * k), from exists_eq_mul_right_of_dvd h,
begin
  subst j, rewrite mul.comm,
  apply add_mul_mod_self
end
-/

/- / and ordering -/

lemma le_of_dvd {m n : nat} : n > 0 → m ∣ n → m ≤ n :=
sorry
/-
assume (h₁ : n > 0) (h₂ : m ∣ n),
have h₃ : n % m = 0, from mod_eq_zero_of_dvd h₂,
by_contradiction
 (λ nle : ¬ m ≤ n,
   have   h₄ : m > n, from lt_of_not_ge nle,
   have h₅ : n % m = n, from mod_eq_of_lt h₄,
   begin
     rewrite h₃ at h₅, subst n,
     exact absurd h₁ (lt.irrefl 0)
   end)
-/

theorem div_mul_le (m n : ℕ) : m / n * n ≤ m :=
sorry
/-
calc
  m = m / n * n + m % n : by rewrite -eq_div_mul_add_mod
    ... ≥ m / n * n     : !le_add_right
-/

protected theorem div_le_of_le_mul {m n k : ℕ} (H : m ≤ n * k) : m / k ≤ n :=
sorry
/-
or.elim (eq_zero_or_pos k)
  (assume H1 : k = 0,
    calc
      m / k = m / 0     : by rewrite H1
          ... = 0       : by rewrite nat.div_zero
          ... ≤ n       : !zero_le)
  (assume H1 : k > 0,
    le_of_mul_le_mul_right (calc
      m / k * k ≤ m / k * k + m % k : !le_add_right
        ... = m                     : by rewrite -eq_div_mul_add_mod
        ... ≤ n * k                 : H) H1)
-/

protected theorem div_le_self (m n : ℕ) : m / n ≤ m :=
sorry
/-
nat.cases_on n (!nat.div_zero⁻¹ ▸ !zero_le)
  take n,
  have H : m ≤ m * succ n, from calc
        m = m * 1      : by rewrite mul_one
      ... ≤ m * succ n : !mul_le_mul_left (succ_le_succ !zero_le),
  nat.div_le_of_le_mul H
-/

protected theorem mul_le_of_le_div {m n k : ℕ} (H : m ≤ n / k) : m * k ≤ n :=
calc
  m * k ≤ n / k * k : mul_le_mul_right k H
    ... ≤ n         : div_mul_le n k

protected theorem le_div_of_mul_le {m n k : ℕ} (H1 : k > 0) (H2 : m * k ≤ n) : m ≤ n / k :=
sorry
/-
have H3 : m * k < (succ (n / k)) * k, from
  calc
    m * k ≤ n                  : H2
      ... = n / k * k + n % k  : by rewrite -eq_div_mul_add_mod
      ... < n / k * k + k      : add_lt_add_left (!mod_lt H1) _
      ... = (succ (n / k)) * k : by rewrite succ_mul,
le_of_lt_succ (lt_of_mul_lt_mul_right H3)
-/

protected theorem le_div_iff_mul_le {m n k : ℕ} (H : k > 0) : m ≤ n / k ↔ m * k ≤ n :=
iff.intro nat.mul_le_of_le_div (nat.le_div_of_mul_le H)

protected theorem div_le_div {m n : ℕ} (k : ℕ) (H : m ≤ n) : m / k ≤ n / k :=
sorry
/-
by_cases_zero_pos k
  (by rewrite [*nat.div_zero])
  (take k, assume H1 : k > 0, nat.le_div_of_mul_le H1 (le.trans !div_mul_le H))
-/

protected theorem div_lt_of_lt_mul {m n k : ℕ} (H : m < n * k) : m / k < n :=
sorry
/-
lt_of_mul_lt_mul_right (calc
  m / k * k ≤ m / k * k + m % k : !le_add_right
    ... = m                     : by rewrite -eq_div_mul_add_mod
    ... < n * k                 : H)
-/

protected theorem lt_mul_of_div_lt {m n k : ℕ} (H1 : k > 0) (H2 : m / k < n) : m < n * k :=
sorry
/-
have H3 : succ (m / k) * k ≤ n * k, from !mul_le_mul_right (succ_le_of_lt H2),
have H4 : m / k * k + k ≤ n * k, by rewrite [succ_mul at H3]; apply H3,
calc
  m     = m / k * k + m % k : by rewrite -eq_div_mul_add_mod
    ... < m / k * k + k     : add_lt_add_left (!mod_lt H1) _
    ... ≤ n * k             : H4
-/

protected theorem div_lt_iff_lt_mul {m n k : ℕ} (H : k > 0) : m / k < n ↔ m < n * k :=
iff.intro (nat.lt_mul_of_div_lt H) nat.div_lt_of_lt_mul

protected theorem div_le_iff_le_mul_of_div {m n : ℕ} (k : ℕ) (H : n > 0) (H' : n ∣ m) :
  m / n ≤ k ↔ m ≤ k * n :=
sorry -- by refine iff.trans (!le_iff_mul_le_mul_right H) _; rewrite [!nat.div_mul_cancel H']

protected theorem le_mul_of_div_le_of_div {m n k : ℕ} (H1 : n > 0) (H2 : n ∣ m) (H3 : m / n ≤ k) :
  m ≤ k * n :=
iff.mp (nat.div_le_iff_le_mul_of_div k H1 H2) H3

-- needed for integer division
theorem mul_sub_div_of_lt {m n k : ℕ} (H : k < m * n) :
  (m * n - (k + 1)) / m = n - k / m - 1 :=
sorry
/-
begin
  have H1 : k / m < n, from nat.div_lt_of_lt_mul (!mul.comm ▸ H),
  have H2 : n - k / m ≥ 1, from
    nat.le_sub_of_add_le (calc
       1 + k / m = succ (k / m) : by rewrite add.comm
               ... ≤ n          : succ_le_of_lt H1),
  have H3 : n - k / m = n - k / m - 1 + 1, from (nat.sub_add_cancel H2)⁻¹,
  have H4 : m > 0, from pos_of_ne_zero (assume H': m = 0, not_lt_zero k (begin rewrite [H' at H, zero_mul at H], exact H end)),
  have H5   : k % m + 1 ≤ m, from succ_le_of_lt (!mod_lt H4),
  have H6 : m - (k % m + 1) < m, from nat.sub_lt_self H4 !succ_pos,
calc
  (m * n - (k + 1)) / m = (m * n - (k / m * m + k % m + 1)) / m   : by rewrite -eq_div_mul_add_mod
     ... = (m * n - k / m * m - (k % m + 1)) / m                  : by rewrite [*nat.sub_sub]
     ... = ((n - k / m) * m - (k % m + 1)) / m                    :
               by rewrite [mul.comm m, nat.mul_sub_right_distrib]
     ... = ((n - k / m - 1) * m + m - (k % m + 1)) / m            :
               by rewrite [H3 at {1}, right_distrib, nat.one_mul]
     ... = ((n - k / m - 1) * m + (m - (k % m + 1))) / m          : by rewrite (nat.add_sub_assoc H5 _)
     ... = (m - (k % m + 1)) / m + (n - k / m - 1)                :
               by rewrite [add.comm, (add_mul_div_self H4)]
     ... = n - k / m - 1                                          :
               by rewrite [div_eq_zero_of_lt H6, zero_add]
end
-/

private lemma div_div_aux (a b c : nat) : b > 0 → c > 0 → (a / b) / c = a / (b * c) :=
sorry
/-
suppose b > 0, suppose c > 0,
nat.strong_induction_on a
(λ a ih,
  let k₁ := a / (b*c) in
  let k₂ := a %(b*c) in
  have bc_pos : b*c > 0, from mul_pos `b > 0` `c > 0`,
  have k₂ < b * c,       from mod_lt _ bc_pos,
  have k₂ ≤ a,           from !mod_le,
  or.elim (eq_or_lt_of_le this)
    (suppose k₂ = a,
     have i₁ : a < b * c,   by rewrite -this; assumption,
     have k₁ = 0,           from div_eq_zero_of_lt i₁,
     have a / b < c,      by rewrite [mul.comm at i₁]; exact nat.div_lt_of_lt_mul i₁,
     begin
       rewrite [`k₁ = 0`],
       show (a / b) / c = 0, from div_eq_zero_of_lt `a / b < c`
     end)
    (suppose k₂ < a,
     have a = k₁*(b*c) + k₂,         from eq_div_mul_add_mod a (b*c),
     have a / b = k₁*c + k₂ / b, by
       rewrite [this at {1}, mul.comm b c at {2}, -mul.assoc,
                add.comm, add_mul_div_self `b > 0`, add.comm],
     have e₁ : (a / b) / c = k₁ + (k₂ / b) / c, by
       rewrite [this, add.comm, add_mul_div_self `c > 0`, add.comm],
     have e₂ : (k₂ / b) / c = k₂ / (b * c), from ih k₂ `k₂ < a`,
     have e₃ : k₂ / (b * c)   = 0,          from div_eq_zero_of_lt `k₂ < b * c`,
     have (k₂ / b) / c      = 0,            by rewrite [e₂, e₃],
     show (a / b) / c = k₁,                 by rewrite [e₁, this]))
-/

protected lemma div_div_eq_div_mul (a b c : nat) : (a / b) / c = a / (b * c) :=
sorry
/-
begin
 cases b with b,
   rewrite [zero_mul, *nat.div_zero, nat.zero_div],
   cases c with c,
     rewrite [mul_zero, *nat.div_zero],
     apply div_div_aux a (succ b) (succ c) dec_trivial dec_trivial
end
-/

lemma div_lt_of_ne_zero : ∀ {n : nat}, n ≠ 0 → n / 2 < n
:= sorry
/-
| 0        h := absurd rfl h
| (succ n) h :=
  begin
    apply nat.div_lt_of_lt_mul,
    rewrite [-add_one, right_distrib],
    change n + 1 < (n * 1 + n) + (1 + 1),
    rewrite [mul_one, -add.assoc],
    apply add_lt_add_right,
    show n < n + n + 1,
    begin
      rewrite [add.assoc, -add_zero n at {1}],
      apply add_lt_add_left,
      apply zero_lt_succ
    end
  end
-/
end nat
attribute [instance, priority nat.prio] nat.nat_has_divide nat.nat_has_mod nat.dvd.decidable_rel
