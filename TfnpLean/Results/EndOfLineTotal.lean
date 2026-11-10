/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.EndOfLine
public import Mathlib.Data.Fintype.EquivFin

/-!
# Result: the graph reading of End-of-Line, and End-of-Line is total

The statements that tie the solution condition of `TfnpLean.EndOfLine` to the graph
`G_{S,P}` of [DGP09, Section 3.1, p. 202], and the totality of the problem. They test the
definitions: each is a sentence of the paper's intuition paragraph, proved from the
formula.

All statements are on the function layer (`S P : Vertex n → Vertex n`, `docs/DESIGN.md`,
D17). The last two apply them to instances.

## Main statements

* `edge_out_unique`, `edge_in_unique`: every vertex has out-degree and in-degree at most
  one.
* `isSink_iff`, `isSource_iff`: `x` is a sink iff `P (S x) ≠ x`, and a source iff
  `S (P x) ≠ x`. These are the two clauses of the solution condition.
* `isSolution_iff_isSink_or_isSource`: a solution is a sink, or a source other than `0^n`
  (the bridge of D17).
* `Instance.isSource_zeros`: in every instance `0^n` is a source.
* `exists_isSink`: if `P(0^n) = 0^n ≠ S(0^n)`, a sink exists.
* `Instance.exists_isSolution`: every instance has a solution.
* `Instance.isEmpty_zero`: there is no instance on zero bits.

## Implementation notes

Totality is proved through `exists_isSink` and never uses the second clause of the
solution condition: if no vertex were a sink, `P` would be a left inverse of `S`, so `S`
would be injective, hence surjective on the finite vertex set, and some `y` would have
`S y = 0^n`; then `y = P (S y) = P (0^n) = 0^n`, against `S (0^n) ≠ 0^n`. This is the
counting form of the paper's argument (follow the path from `0^n`; it must end). It shows
more than totality asks: a sink always exists, which is the remark of [DGP09, p. 202] that
insisting on a sink gives the class PPADS (`docs/DESIGN.md`, D21).

## References

* [DGP09, Section 3.1, p. 202].
* [Pap94, Section 2].
-/

public section

namespace TfnpLean.EndOfLine

variable {n : ℕ} {S P : Vertex n → Vertex n} {x y x' y' : Vertex n}

/-- Every vertex has out-degree at most one [DGP09, Section 3.1, p. 202]: an edge out of `x`
goes to `S x`. -/
theorem edge_out_unique (h : Edge S P x y) (h' : Edge S P x y') : y = y' :=
  h.1.symm.trans h'.1

/-- Every vertex has in-degree at most one [DGP09, Section 3.1, p. 202]: an edge into `y`
comes from `P y`. -/
theorem edge_in_unique (h : Edge S P x y) (h' : Edge S P x' y) : x = x' :=
  h.2.symm.trans h'.2

/-- `x` is a sink iff `P (S x) ≠ x`, the first clause of the solution condition. -/
theorem isSink_iff : IsSink S P x ↔ P (S x) ≠ x := by
  constructor
  · intro h hc
    exact h (S x) ⟨rfl, hc⟩
  · rintro h y ⟨rfl, hp⟩
    exact h hp

/-- `x` is a source iff `S (P x) ≠ x`, the second clause of the solution condition without
its `x ≠ 0^n`. -/
theorem isSource_iff : IsSource S P x ↔ S (P x) ≠ x := by
  constructor
  · intro h hc
    exact h (P x) ⟨hc, rfl⟩
  · rintro h y ⟨hs, rfl⟩
    exact h hs

/-- A solution is a sink, or a source other than `0^n` [DGP09, Section 3.1, p. 202: "We seek
either a sink, or a source other than 0^n"]. -/
theorem isSolution_iff_isSink_or_isSource :
    IsSolution S P x ↔ IsSink S P x ∨ (IsSource S P x ∧ x ≠ zeros) := by
  rw [isSink_iff, isSource_iff]
  rfl

/-- If `P(0^n) = 0^n ≠ S(0^n)`, some vertex is a sink. -/
theorem exists_isSink (hP : P zeros = zeros) (hS : S zeros ≠ zeros) : ∃ x, IsSink S P x := by
  by_contra h
  have hPS : ∀ x, P (S x) = x := fun x => by
    by_contra hx
    exact h ⟨x, isSink_iff.mpr hx⟩
  have hinj : Function.Injective S := Function.LeftInverse.injective hPS
  obtain ⟨y, hy⟩ := Finite.injective_iff_surjective.mp hinj zeros
  have hy0 : y = zeros := by rw [← hPS y, hy, hP]
  exact hS (hy0 ▸ hy)

/-- In every instance `0^n` is a source [DGP09, Section 3.1, p. 202: "there is at least one
source, namely 0^n"]. -/
theorem Instance.isSource_zeros (I : Instance n) : IsSource I.S.fn I.P.fn zeros := by
  rw [isSource_iff, I.source.1]
  exact I.source.2

/-- End-of-Line is total: every instance has a solution [DGP09, Section 3.1, p. 202;
Pap94, Section 2]. -/
theorem Instance.exists_isSolution (I : Instance n) : ∃ x, I.IsSolution x := by
  obtain ⟨x, hx⟩ := exists_isSink I.source.1 I.source.2
  exact ⟨x, Or.inl (isSink_iff.mp hx)⟩

/-- There is no instance on zero bits: the only vertex is `0^n`, and `S(0^n) ≠ 0^n` cannot
hold. -/
theorem Instance.isEmpty_zero : IsEmpty (Instance 0) :=
  ⟨fun I => I.source.2 (Subsingleton.elim _ _)⟩

end TfnpLean.EndOfLine
