/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import Mathlib.Data.Fintype.Basic
public import Mathlib.Data.Finset.Card

/-!
# Step 1: Pure-Circuit

The Pure-Circuit problem of Deligkas, Fearnley, Hollender and Melissourgos
[DFHM24, Definition 1]: a finite set of nodes, a set of gate constraints of type
NOR (two inputs, one output) or PURIFY (one input, two outputs) such that every
node is the output of exactly one gate, and the notion of a solution, an
assignment of `0`, `1` or `⊥` (garbage) to every node that satisfies every gate.

## Main definitions

* `PureCircuit.Value`: the three node values `0`, `1`, `⊥`.
* `PureCircuit.Gate`: a NOR or PURIFY gate on three nodes `u`, `v`, `w`.
* `PureCircuit.Instance`: a set of gates on the nodes `Fin n` with distinct nodes in
  every gate and every node the output of exactly one gate.
* `PureCircuit.Instance.IsSolution`: an assignment that satisfies every gate.

## Implementation notes

Pure-Circuit is modelled as a constraint problem on nodes, not as a CSLib
`Circuit`: cycles are allowed, gates are relations rather than functions, and
PURIFY has two outputs. See `docs/DESIGN.md`, decision D2. The encoding choices
for values, nodes, gates and the instance conditions are D7 to D11.

The paper's node set is `V = [n] = {1, ..., n}`; here it is `Fin n = {0, ..., n - 1}`.

The gate set is NOR and PURIFY, following Definition 1. The alternative gate
sets of [DFHM24, Corollary 2.2] (NAND; NOT with OR or AND) are variants, see
`TfnpLean.Results.PureCircuitVariants`.

## References

* [A. Deligkas, J. Fearnley, A. Hollender, T. Melissourgos, *Pure-Circuit:
  Tight Inapproximability for PPAD*, Section 2, Definition 1][DFHM24]
  (arXiv:2209.15149, J. ACM 71(5), 2024).
-/

@[expose] public section

namespace TfnpLean.PureCircuit

/-- The value of a node: a pure bit `0` or `1`, or garbage `⊥` [DFHM24, Definition 1]. -/
inductive Value where
  /-- The pure bit `0`. -/
  | zero
  /-- The pure bit `1`. -/
  | one
  /-- Garbage, written `⊥` in the paper. -/
  | bot
  deriving DecidableEq

instance : Fintype Value := ⟨{.zero, .one, .bot}, fun x => by cases x <;> decide⟩

/-- A value is pure if it is `0` or `1`, the paper's `x ∈ {0, 1}`. -/
def Value.IsPure (a : Value) : Prop := a = .zero ∨ a = .one

instance (a : Value) : Decidable a.IsPure := inferInstanceAs (Decidable (_ ∨ _))

variable {n : ℕ}

/-- A gate `(T, u, v, w)` on the nodes `Fin n` [DFHM24, Definition 1]. The type `T` is
the constructor. -/
inductive Gate (n : ℕ) where
  /-- `T = NOR`: inputs `u` and `v`, output `w`. -/
  | nor (u v w : Fin n)
  /-- `T = PURIFY`: input `u`, outputs `v` and `w`. -/
  | purify (u v w : Fin n)
  deriving DecidableEq

namespace Gate

/-- The output nodes of a gate: `w` for NOR, `v` and `w` for PURIFY. -/
def outputs : Gate n → Finset (Fin n)
  | .nor _ _ w => {w}
  | .purify _ v w => {v, w}

/-- The nodes `u`, `v`, `w` of a gate are distinct [DFHM24, Definition 1]. -/
def Distinct : Gate n → Prop
  | .nor u v w | .purify u v w => u ≠ v ∧ u ≠ w ∧ v ≠ w

instance (g : Gate n) : Decidable g.Distinct := by
  cases g <;> unfold Distinct <;> infer_instance

/-- The assignment `x` satisfies the gate `g` [DFHM24, Definition 1, left column].

* NOR: `x[u] = x[v] = 0 ⟹ x[w] = 1` and `(x[u] = 1) ∨ (x[v] = 1) ⟹ x[w] = 0`.
* PURIFY: `{x[v], x[w]} ∩ {0, 1} ≠ ∅` and `x[u] ∈ {0, 1} ⟹ x[v] = x[w] = x[u]`.

Every case not named by an implication leaves the output free. -/
def Satisfied (g : Gate n) (x : Fin n → Value) : Prop :=
  match g with
  | .nor u v w =>
      (x u = .zero ∧ x v = .zero → x w = .one) ∧
      (x u = .one ∨ x v = .one → x w = .zero)
  | .purify u v w =>
      ((x v).IsPure ∨ (x w).IsPure) ∧
      ((x u).IsPure → x v = x u ∧ x w = x u)

instance (g : Gate n) (x : Fin n → Value) : Decidable (g.Satisfied x) := by
  cases g <;> unfold Satisfied <;> infer_instance

end Gate

/-- Every node is the output of exactly one gate of `G` [DFHM24, Definition 1]. -/
def OutputUnique (G : Finset (Gate n)) : Prop :=
  ∀ x : Fin n, ∃! g, g ∈ G ∧ x ∈ g.outputs

/-- `OutputUnique` is decided by counting, for each node, the gates that output it. -/
instance (G : Finset (Gate n)) : Decidable (OutputUnique G) :=
  decidable_of_iff (∀ x : Fin n, (G.filter (x ∈ ·.outputs)).card = 1) <| by
    refine forall_congr' fun x => ?_
    rw [Finset.card_eq_one]
    constructor
    · rintro ⟨g, hg⟩
      refine ⟨g, by simpa using (Finset.ext_iff.mp hg g).mpr (Finset.mem_singleton_self g),
        fun g' hg' => ?_⟩
      simpa using (Finset.ext_iff.mp hg g').mp (by simpa using hg')
    · rintro ⟨g, hg, huniq⟩
      exact ⟨g, Finset.ext fun g' => by simpa using ⟨fun h => huniq g' h, fun h => h ▸ hg⟩⟩

/-- An instance of Pure-Circuit on the nodes `Fin n` [DFHM24, Definition 1]: a set of
gates, each on three distinct nodes, such that every node is the output of exactly one
gate. -/
structure Instance (n : ℕ) where
  /-- The gate set `G`. -/
  gates : Finset (Gate n)
  /-- In every gate the nodes `u`, `v`, `w` are distinct. -/
  distinct : ∀ g ∈ gates, g.Distinct
  /-- Every node is the output of exactly one gate. -/
  output_unique : OutputUnique gates

/-- A solution to the instance `I` is an assignment `x : Fin n → Value` that satisfies
all the gates [DFHM24, Definition 1]. -/
def Instance.IsSolution (I : Instance n) (x : Fin n → Value) : Prop :=
  ∀ g ∈ I.gates, g.Satisfied x

instance (I : Instance n) (x : Fin n → Value) : Decidable (I.IsSolution x) :=
  inferInstanceAs (Decidable (∀ g ∈ I.gates, g.Satisfied x))

end TfnpLean.PureCircuit
