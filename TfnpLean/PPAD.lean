/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.Reduction
public import Cslib.Computability.Circuit.Boolean.Basic

/-!
# End-of-Line and PPAD

The End-of-Line problem of Daskalakis, Goldberg and Papadimitriou [DGP09, Section 3.1,
p. 202]: two Boolean circuits `S` and `P`, each with `n` input bits and `n` output bits,
such that `P(0^n) = 0^n ≠ S(0^n)`; find `x ∈ {0,1}^n` with `P(S(x)) ≠ x` or
`S(P(x)) ≠ x ≠ 0^n`. Intuitively, `S` and `P` describe a graph on `{0,1}^n` with an edge
`x → y` whenever `y = S(x)` and `x = P(y)`, every vertex has in- and out-degree at most
one, `0^n` is a source, and a solution is a sink or a source other than `0^n`.

PPAD, the closure of End-of-Line under reductions (`docs/DESIGN.md`, D14), is not yet
defined here: it waits on `TfnpLean.Reduction` and the polynomial-time interface (D5).

## Main definitions

* `EndOfLine.Vertex`: the vertices `{0,1}^n`, as `Fin n → Bool`.
* `EndOfLine.IsSolution`: the solution condition of the paper, on the successor and
  predecessor functions.
* `EndOfLine.Edge`, `EndOfLine.IsSink`, `EndOfLine.IsSource`: the graph reading.
* `EndOfLine.Instance`: two CSLib Boolean circuits with `0^n` a source.
* `EndOfLine.Instance.IsSolution`: the solution condition applied to the circuits.

## Implementation notes

The solution condition is stated on plain functions `S P : Vertex n → Vertex n` and the
instance applies it to the circuits' evaluations (D17). The graph reading is defined next
to the paper's formula, not instead of it; that the two agree is a statement in
`TfnpLean.Results` (D17). The condition on `0^n` is a proof field of the instance (D18,
proposed). The circuits are CSLib circuits over the Boolean signature (D13, D19); the
vertex type is their input and output type (D16).

## References

* [C. Daskalakis, P. W. Goldberg, C. H. Papadimitriou, *The complexity of computing a
  Nash equilibrium*, SIAM J. Comput. 39(1), 2009, Section 3.1, p. 202][DGP09]; the same
  text in the ECCC version TR05-115, 2005, Section 3, p. 3 [DGP05].
* [C. H. Papadimitriou, *On the complexity of the parity argument and other inefficient
  proofs of existence*, JCSS 48(3), 1994, Section 2][Pap94] (PPAD, End-of-Line as the
  defining problem, in an earlier formulation).
-/

@[expose] public section

namespace TfnpLean.EndOfLine

open Cslib.Circuits

/-- A vertex, an `n`-bit string: the paper's `x ∈ {0,1}^n` [DGP09, Section 3.1, p. 202].
This is the input and output type of a CSLib circuit with `n` inputs and `n` outputs
under a Boolean interpretation. -/
abbrev Vertex (n : ℕ) := Fin n → Bool

/-- The all-zero string `0^n` [DGP09, Section 3.1, p. 202]. -/
def zeros : Vertex n := fun _ => false

/-- `x` is a solution for the successor function `S` and the predecessor function `P`:
`P(S(x)) ≠ x` or `S(P(x)) ≠ x ≠ 0^n` [DGP09, Section 3.1, p. 202]. -/
def IsSolution (S P : Vertex n → Vertex n) (x : Vertex n) : Prop :=
  P (S x) ≠ x ∨ (S (P x) ≠ x ∧ x ≠ zeros)

instance (S P : Vertex n → Vertex n) (x : Vertex n) : Decidable (IsSolution S P x) :=
  inferInstanceAs (Decidable (_ ∨ _))

/-- The edge `x → y` of the graph `G_{S,P}`: `y = S(x)` and `x = P(y)`
[DGP09, Section 3.1, p. 202]. -/
def Edge (S P : Vertex n → Vertex n) (x y : Vertex n) : Prop :=
  S x = y ∧ P y = x

instance (S P : Vertex n → Vertex n) (x y : Vertex n) : Decidable (Edge S P x y) :=
  inferInstanceAs (Decidable (_ ∧ _))

/-- `x` is a sink: it has no outgoing edge. -/
def IsSink (S P : Vertex n → Vertex n) (x : Vertex n) : Prop :=
  ∀ y, ¬ Edge S P x y

instance (S P : Vertex n → Vertex n) (x : Vertex n) : Decidable (IsSink S P x) :=
  inferInstanceAs (Decidable (∀ _, ¬ _))

/-- `x` is a source: it has no incoming edge. -/
def IsSource (S P : Vertex n → Vertex n) (x : Vertex n) : Prop :=
  ∀ y, ¬ Edge S P y x

instance (S P : Vertex n → Vertex n) (x : Vertex n) : Decidable (IsSource S P x) :=
  inferInstanceAs (Decidable (∀ _, ¬ _))

/-- A Boolean circuit with `n` inputs and `n` outputs over CSLib's Boolean signature
(constants, NOT, AND, OR), the paper's "circuit with n input bits and n output bits". -/
abbrev BoolCircuit (n : ℕ) := Circuit Boolean.signature n n

/-- The function an `n`-to-`n` Boolean circuit computes, under the usual Boolean
interpretation. -/
def BoolCircuit.fn (C : BoolCircuit n) : Vertex n → Vertex n :=
  C.eval Boolean.interpretation

/-- An End-of-Line instance [DGP09, Section 3.1, p. 202]: two circuits `S` and `P`, each
with `n` input bits and `n` output bits, such that `P(0^n) = 0^n ≠ S(0^n)`. -/
structure Instance (n : ℕ) where
  /-- The successor candidate circuit `S`. -/
  S : BoolCircuit n
  /-- The predecessor candidate circuit `P`. -/
  P : BoolCircuit n
  /-- The paper's "such that `P(0^n) = 0^n ≠ S(0^n)`": `0^n` is a source (`docs/DESIGN.md`,
  D18). -/
  source : P.fn zeros = zeros ∧ S.fn zeros ≠ zeros

/-- `x` is a solution of the instance: the solution condition on the functions its circuits
compute [DGP09, Section 3.1, p. 202]. -/
def Instance.IsSolution (I : Instance n) (x : Vertex n) : Prop :=
  EndOfLine.IsSolution I.S.fn I.P.fn x

instance (I : Instance n) (x : Vertex n) : Decidable (I.IsSolution x) :=
  inferInstanceAs (Decidable (EndOfLine.IsSolution _ _ _))

end TfnpLean.EndOfLine
