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

The further gates of [DFHM24, Section 2.1] (COPY, NOT, OR, AND, NAND) are defined
alongside, and an instance fixes the gate types it may use. Definition 1 is the
gate set `norPurify`; the choices of [DFHM24, Corollary 2.2] are further gate sets.

## Main definitions

* `PureCircuit.Value`: the three node values `0`, `1`, `⊥`.
* `PureCircuit.GateType`: the seven gate types, the labels that gate sets are made of.
* `PureCircuit.Gate`: a gate of one of the seven types on two or three nodes.
* `PureCircuit.norPurify`: the gate set `{NOR, PURIFY}` of Definition 1.
* `PureCircuit.Instance`: a set of gates on the nodes `Fin n`, each of a type in a
  gate set `S`, with distinct nodes in every gate and every node the output of exactly
  one gate.
* `PureCircuit.Instance.IsSolution`: an assignment that satisfies every gate.

## Implementation notes

Pure-Circuit is modelled as a constraint problem on nodes, not as a CSLib
`Circuit`: cycles are allowed, gates are relations rather than functions, and
PURIFY has two outputs. See `docs/DESIGN.md`, decision D2. The gate set as a
parameter of the instance is D3, the encoding choices for values, nodes, gates and
the instance conditions are D7 to D11, and the two-node gates COPY and NOT are D12.

The paper's node set is `V = [n] = {1, ..., n}`; here it is `Fin n = {0, ..., n - 1}`.

## References

* [A. Deligkas, J. Fearnley, A. Hollender, T. Melissourgos, *Pure-Circuit:
  Tight Inapproximability for PPAD*, Section 2, Definition 1, Section 2.1][DFHM24]
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

/-- The type `T` of a gate [DFHM24, Definition 1 and Section 2.1]. Gate sets are
`Finset GateType`. -/
inductive GateType where
  /-- NOR, Definition 1. -/
  | nor
  /-- PURIFY, Definition 1. -/
  | purify
  /-- COPY, Section 2.1. -/
  | copy
  /-- NOT, Section 2.1. -/
  | not
  /-- OR, Section 2.1. -/
  | or
  /-- AND, Section 2.1. -/
  | and
  /-- NAND, Section 2.1. -/
  | nand
  deriving DecidableEq

/-- The gate set `{NOR, PURIFY}` of Pure-Circuit as in [DFHM24, Definition 1]. -/
def norPurify : Finset GateType := {.nor, .purify}

variable {n : ℕ}

/-- A gate on the nodes `Fin n` [DFHM24, Definition 1 and Section 2.1]: `(T, u, v)` for
COPY and NOT, `(T, u, v, w)` for the others. The type `T` is the constructor. -/
inductive Gate (n : ℕ) where
  /-- `T = NOR`: inputs `u` and `v`, output `w`. -/
  | nor (u v w : Fin n)
  /-- `T = PURIFY`: input `u`, outputs `v` and `w`. -/
  | purify (u v w : Fin n)
  /-- `T = COPY`: input `u`, output `v`. -/
  | copy (u v : Fin n)
  /-- `T = NOT`: input `u`, output `v`. -/
  | not (u v : Fin n)
  /-- `T = OR`: inputs `u` and `v`, output `w`. -/
  | or (u v w : Fin n)
  /-- `T = AND`: inputs `u` and `v`, output `w`. -/
  | and (u v w : Fin n)
  /-- `T = NAND`: inputs `u` and `v`, output `w`. -/
  | nand (u v w : Fin n)
  deriving DecidableEq

namespace Gate

/-- The type `T` of a gate. -/
def type : Gate n → GateType
  | .nor .. => .nor
  | .purify .. => .purify
  | .copy .. => .copy
  | .not .. => .not
  | .or .. => .or
  | .and .. => .and
  | .nand .. => .nand

/-- The output nodes of a gate: `v` for COPY and NOT, `v` and `w` for PURIFY, `w` for
the others. -/
def outputs : Gate n → Finset (Fin n)
  | .purify _ v w => {v, w}
  | .copy _ v | .not _ v => {v}
  | .nor _ _ w | .or _ _ w | .and _ _ w | .nand _ _ w => {w}

/-- The nodes of a gate are distinct [DFHM24, Definition 1]. -/
def Distinct : Gate n → Prop
  | .copy u v | .not u v => u ≠ v
  | .nor u v w | .purify u v w | .or u v w | .and u v w | .nand u v w =>
      u ≠ v ∧ u ≠ w ∧ v ≠ w

instance (g : Gate n) : Decidable g.Distinct := by
  cases g <;> unfold Distinct <;> infer_instance

/-- The assignment `x` satisfies the gate `g` [DFHM24, Definition 1 and Section 2.1,
left column].

* NOR: `x[u] = x[v] = 0 ⟹ x[w] = 1` and `(x[u] = 1) ∨ (x[v] = 1) ⟹ x[w] = 0`.
* PURIFY: `{x[v], x[w]} ∩ {0, 1} ≠ ∅` and `x[u] ∈ {0, 1} ⟹ x[v] = x[w] = x[u]`.
* COPY: `x[u] = 0 ⟹ x[v] = 0` and `x[u] = 1 ⟹ x[v] = 1`.
* NOT: `x[u] = 0 ⟹ x[v] = 1` and `x[u] = 1 ⟹ x[v] = 0`.
* OR: `x[u] = x[v] = 0 ⟹ x[w] = 0` and `(x[u] = 1) ∨ (x[v] = 1) ⟹ x[w] = 1`.
* AND: `x[u] = x[v] = 1 ⟹ x[w] = 1` and `(x[u] = 0) ∨ (x[v] = 0) ⟹ x[w] = 0`.
* NAND: `x[u] = x[v] = 1 ⟹ x[w] = 0` and `(x[u] = 0) ∨ (x[v] = 0) ⟹ x[w] = 1`.

Every case not named by an implication leaves the output free. -/
def Satisfied (g : Gate n) (x : Fin n → Value) : Prop :=
  match g with
  | .nor u v w =>
      (x u = .zero ∧ x v = .zero → x w = .one) ∧
      (x u = .one ∨ x v = .one → x w = .zero)
  | .purify u v w =>
      ((x v).IsPure ∨ (x w).IsPure) ∧
      ((x u).IsPure → x v = x u ∧ x w = x u)
  | .copy u v =>
      (x u = .zero → x v = .zero) ∧
      (x u = .one → x v = .one)
  | .not u v =>
      (x u = .zero → x v = .one) ∧
      (x u = .one → x v = .zero)
  | .or u v w =>
      (x u = .zero ∧ x v = .zero → x w = .zero) ∧
      (x u = .one ∨ x v = .one → x w = .one)
  | .and u v w =>
      (x u = .one ∧ x v = .one → x w = .one) ∧
      (x u = .zero ∨ x v = .zero → x w = .zero)
  | .nand u v w =>
      (x u = .one ∧ x v = .one → x w = .zero) ∧
      (x u = .zero ∨ x v = .zero → x w = .one)

instance (g : Gate n) (x : Fin n → Value) : Decidable (g.Satisfied x) := by
  cases g <;> unfold Satisfied <;> infer_instance

end Gate

/-- Every node is the output of exactly one gate of `G` [DFHM24, Definition 1]. -/
def OutputUnique (G : Finset (Gate n)) : Prop :=
  ∀ i : Fin n, ∃! g, g ∈ G ∧ i ∈ g.outputs

/-- `OutputUnique` is decided by counting, for each node, the gates that output it. -/
instance (G : Finset (Gate n)) : Decidable (OutputUnique G) :=
  decidable_of_iff (∀ i : Fin n, (G.filter (i ∈ ·.outputs)).card = 1) <| by
    refine forall_congr' fun i => ?_
    rw [Finset.card_eq_one]
    constructor
    · rintro ⟨g, hg⟩
      refine ⟨g, by simpa using (Finset.ext_iff.mp hg g).mpr (Finset.mem_singleton_self g),
        fun g' hg' => ?_⟩
      simpa using (Finset.ext_iff.mp hg g').mp (by simpa using hg')
    · rintro ⟨g, hg, huniq⟩
      exact ⟨g, Finset.ext fun g' => by simpa using ⟨fun h => huniq g' h, fun h => h ▸ hg⟩⟩

/-- An instance of Pure-Circuit with gate set `S` on the nodes `Fin n` [DFHM24,
Definition 1 and Corollary 2.2]: a set of gates, each of a type in `S` and on distinct
nodes, such that every node is the output of exactly one gate. Definition 1 is
`Instance norPurify n`. -/
structure Instance (S : Finset GateType) (n : ℕ) where
  /-- The gate set `G`. -/
  gates : Finset (Gate n)
  /-- Every gate has a type in `S`. -/
  allowed : ∀ g ∈ gates, g.type ∈ S
  /-- In every gate the nodes are distinct. -/
  distinct : ∀ g ∈ gates, g.Distinct
  /-- Every node is the output of exactly one gate. -/
  output_unique : OutputUnique gates

variable {S : Finset GateType}

/-- A solution to the instance `I` is an assignment `x : Fin n → Value` that satisfies
all the gates [DFHM24, Definition 1]. -/
def Instance.IsSolution (I : Instance S n) (x : Fin n → Value) : Prop :=
  ∀ g ∈ I.gates, g.Satisfied x

instance (I : Instance S n) (x : Fin n → Value) : Decidable (I.IsSolution x) :=
  inferInstanceAs (Decidable (∀ g ∈ I.gates, g.Satisfied x))

end TfnpLean.PureCircuit
