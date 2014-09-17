-- Copyright (c) 2014 Microsoft Corporation. All rights reserved.
-- Released under Apache 2.0 license as described in the file LICENSE.
-- Author: Jeremy Avigad
-- Ported from Coq HoTT
import .path
open path

-- Equivalences
-- ------------

definition Sect {A B : Type} (s : A → B) (r : B → A) := Πx : A, r (s x) ≈ x

-- -- TODO: need better means of declaring structures
-- -- TODO: note that Coq allows projections to be declared to be coercions on the fly

-- Structure IsEquiv

inductive IsEquiv {A B : Type} (f : A → B) :=
IsEquiv_mk : Π
  (equiv_inv : B → A)
  (eisretr : Sect equiv_inv f)
  (eissect : Sect f equiv_inv)
  (eisadj : Πx, eisretr (f x) ≈ ap f (eissect x)),
IsEquiv f

definition equiv_inv {A B : Type} {f : A → B} (H : IsEquiv f) : B → A :=
IsEquiv.rec (λequiv_inv eisretr eissect eisadj, equiv_inv) H

-- TODO: note: does not type check without giving the type
definition eisretr {A B : Type} {f : A → B} (H : IsEquiv f) : Sect (equiv_inv H) f :=
IsEquiv.rec (λequiv_inv eisretr eissect eisadj, eisretr) H

definition eissect {A B : Type} {f : A → B} (H : IsEquiv f) : Sect f (equiv_inv H) :=
IsEquiv.rec (λequiv_inv eisretr eissect eisadj, eissect) H

definition eisadj {A B : Type} {f : A → B} (H : IsEquiv f) :
  Πx, eisretr H (f x) ≈ ap f (eissect H x) :=
IsEquiv.rec (λequiv_inv eisretr eissect eisadj, eisadj) H

-- Structure Equiv

inductive Equiv (A B : Type) : Type :=
Equiv_mk : Π
  (equiv_fun : A → B)
  (equiv_isequiv : IsEquiv equiv_fun),
Equiv A B

definition equiv_fun [coercion] {A B : Type} (e : Equiv A B) : A → B :=
Equiv.rec (λequiv_fun equiv_isequiv, equiv_fun) e

definition equiv_isequiv [coercion] {A B : Type} (e : Equiv A B) : IsEquiv (equiv_fun e) :=
Equiv.rec (λequiv_fun equiv_isequiv, equiv_isequiv) e

-- TODO: better symbol
infix `<~>`:25 := Equiv
notation e `⁻¹` := equiv_inv e
