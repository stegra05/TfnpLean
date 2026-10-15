/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.PureCircuit
public import Mathlib.Data.Fin.VecNotation

/-!
# Tests: Pure-Circuit examples and must-fail cases

Small instances worked by hand and checked by `decide`, following `docs/CHECKING.md`.
Assignments are written `![a, b, c]` and quantified value by value, so that `decide`
enumerates all of them.

* The three-node instance `PURIFY(0 → 1, 2)`, `NOR(1, 2 → 0)` has exactly the solutions
  `(⊥, 0, ⊥)` and `(⊥, ⊥, 0)`.
* **MF1, must fail:** with a PURIFY gate, the all-garbage assignment is not a solution.
  **Control:** on a NOR-only instance it is [DFHM24, Section 2 and Appendix A.1].
* **MF2, must fail:** a NOR gate with inputs `1` and `⊥` does not accept output `1`
  (robustness of the logical gates, [DFHM24, Section 2]).
* **Must hold:** a NOR gate whose inputs force nothing accepts every output, and PURIFY
  on a pure input copies it to both outputs.
* **Must hold:** the paper's unconditional PURIFY clause `{x[v], x[w]} ∩ {0, 1} ≠ ∅` is
  equivalent to the reading "if `x[u] = ⊥`, one output is pure".
* **Must hold:** COPY and NOT force their output exactly on a pure input.
* **MF3, must fail:** OR, AND and NAND are robust like NOR: one input that decides the
  result forces the output even if the other input is garbage [DFHM24, Section 2.1].
* **Must hold:** every gate has the output nodes and the type label of its paper form.
* **Must hold:** a cycle of three NOT gates has exactly the all-garbage solution.
* **Must hold:** the gadgets of the proof of [DFHM24, Corollary 2.2] act exactly as the
  gate they simulate: PURIFY then NAND as NOT, OR then NOT as NOR.
* **Must fail:** a gate set in which a node is the output of two gates violates
  `OutputUnique`, and this particular one has no satisfying assignment at all.
* **Must fail:** a gate that repeats a node is not `Distinct`.
* **MF4, must fail:** a valid instance over the gate set `{NOT}` is not an instance over
  `norPurify`.

## References

* [DFHM24, Section 2, Definition 1, Remark 2, Section 2.1, Corollary 2.2,
  Appendix A.1].
-/

public section

namespace TfnpLean.PureCircuit.Tests

open TfnpLean.PureCircuit

/-! ### The three-node instance -/

/-- `PURIFY(0 → 1, 2)` and `NOR(1, 2 → 0)`: a cycle through all three nodes. -/
def threeNode : Instance norPurify 3 where
  gates := {.purify 0 1 2, .nor 1 2 0}
  allowed := by decide
  distinct := by decide
  output_unique := by decide

/-- The three-node instance has exactly the two solutions found by hand. -/
example : ∀ a b c : Value, threeNode.IsSolution ![a, b, c] ↔
    (a, b, c) = (.bot, .zero, .bot) ∨ (a, b, c) = (.bot, .bot, .zero) := by
  decide

/-! ### MF1: all-garbage is not a solution when PURIFY is present -/

/-- MF1. The all-garbage assignment fails the PURIFY gate of `threeNode`. -/
example : ¬ threeNode.IsSolution ![.bot, .bot, .bot] := by decide

/-- `NOR(1, 2 → 0)`, `NOR(2, 0 → 1)`, `NOR(0, 1 → 2)`: a NOR-only instance. -/
def norCycle : Instance {.nor} 3 where
  gates := {.nor 1 2 0, .nor 2 0 1, .nor 0 1 2}
  allowed := by decide
  distinct := by decide
  output_unique := by decide

/-- MF1 control. Without PURIFY the all-garbage assignment is a solution. -/
example : norCycle.IsSolution ![.bot, .bot, .bot] := by decide

/-! ### MF2: NOR is robust -/

/-- MF2. One input `1` forces output `0` even if the other input is garbage. -/
example : ¬ (Gate.nor 0 1 2 : Gate 3).Satisfied ![.one, .bot, .one] := by decide

/-- Control for MF2: the only accepted output is `0`. -/
example : ∀ c : Value, (Gate.nor 0 1 2 : Gate 3).Satisfied ![.one, .bot, c] ↔ c = .zero := by
  decide

/-! ### Gate controls -/

/-- NOR with inputs `0` and `⊥` forces nothing: every output is accepted. -/
example : ∀ c : Value, (Gate.nor 0 1 2 : Gate 3).Satisfied ![.zero, .bot, c] := by decide

/-- PURIFY on a pure input copies it to both outputs. -/
example : ∀ a b c : Value, a.IsPure →
    ((Gate.purify 0 1 2 : Gate 3).Satisfied ![a, b, c] ↔ b = a ∧ c = a) := by
  decide

/-- The paper's PURIFY clauses are equivalent to the conditional reading. -/
example : ∀ a b c : Value, (Gate.purify 0 1 2 : Gate 3).Satisfied ![a, b, c] ↔
    ((a = .bot → b.IsPure ∨ c.IsPure) ∧ (a.IsPure → b = a ∧ c = a)) := by
  decide

/-! ### COPY and NOT -/

/-- COPY on a pure input accepts only that input as output. -/
example : ∀ a b : Value, a.IsPure → ((Gate.copy 0 1 : Gate 2).Satisfied ![a, b] ↔ b = a) := by
  decide

/-- COPY on garbage accepts every output. -/
example : ∀ b : Value, (Gate.copy 0 1 : Gate 2).Satisfied ![.bot, b] := by decide

/-- NOT on `0` accepts only `1`. -/
example : ∀ b : Value, (Gate.not 0 1 : Gate 2).Satisfied ![.zero, b] ↔ b = .one := by decide

/-- NOT on `1` accepts only `0`. -/
example : ∀ b : Value, (Gate.not 0 1 : Gate 2).Satisfied ![.one, b] ↔ b = .zero := by decide

/-- NOT on garbage accepts every output. -/
example : ∀ b : Value, (Gate.not 0 1 : Gate 2).Satisfied ![.bot, b] := by decide

/-! ### OR, AND, NAND and MF3: robustness -/

/-- OR on `0, 0` accepts only `0`. -/
example : ∀ c : Value, (Gate.or 0 1 2 : Gate 3).Satisfied ![.zero, .zero, c] ↔ c = .zero := by
  decide

/-- MF3 for OR. An input `1` forces output `1`, in either position, even if the other
input is garbage. -/
example : ∀ c : Value, ((Gate.or 0 1 2 : Gate 3).Satisfied ![.one, .bot, c] ↔ c = .one) ∧
    ((Gate.or 0 1 2 : Gate 3).Satisfied ![.bot, .one, c] ↔ c = .one) := by
  decide

/-- OR on `0, ⊥` forces nothing. -/
example : ∀ c : Value, (Gate.or 0 1 2 : Gate 3).Satisfied ![.zero, .bot, c] := by decide

/-- AND on `1, 1` accepts only `1`. -/
example : ∀ c : Value, (Gate.and 0 1 2 : Gate 3).Satisfied ![.one, .one, c] ↔ c = .one := by
  decide

/-- MF3 for AND. An input `0` forces output `0`, in either position, even if the other
input is garbage. -/
example : ∀ c : Value, ((Gate.and 0 1 2 : Gate 3).Satisfied ![.zero, .bot, c] ↔ c = .zero) ∧
    ((Gate.and 0 1 2 : Gate 3).Satisfied ![.bot, .zero, c] ↔ c = .zero) := by
  decide

/-- AND on `1, ⊥` forces nothing. -/
example : ∀ c : Value, (Gate.and 0 1 2 : Gate 3).Satisfied ![.one, .bot, c] := by decide

/-- NAND on `1, 1` accepts only `0`. -/
example : ∀ c : Value, (Gate.nand 0 1 2 : Gate 3).Satisfied ![.one, .one, c] ↔ c = .zero := by
  decide

/-- MF3 for NAND. An input `0` forces output `1`, in either position, even if the other
input is garbage. -/
example : ∀ c : Value, ((Gate.nand 0 1 2 : Gate 3).Satisfied ![.zero, .bot, c] ↔ c = .one) ∧
    ((Gate.nand 0 1 2 : Gate 3).Satisfied ![.bot, .zero, c] ↔ c = .one) := by
  decide

/-- NAND on `1, ⊥` forces nothing. -/
example : ∀ c : Value, (Gate.nand 0 1 2 : Gate 3).Satisfied ![.one, .bot, c] := by decide

/-! ### Roles and labels

Which node is an output is written twice, in `outputs` and in `Satisfied`, and the type
of a gate twice, as its constructor and as `Gate.type`. Nothing in the definitions ties
the two together; these tests do. -/

/-- The output nodes: `v` for COPY and NOT, `v` and `w` for PURIFY, `w` for the others. -/
example : (Gate.copy 0 1 : Gate 2).outputs = {1} ∧ (Gate.not 0 1 : Gate 2).outputs = {1} ∧
    (Gate.nor 0 1 2 : Gate 3).outputs = {2} ∧ (Gate.purify 0 1 2 : Gate 3).outputs = {1, 2} ∧
    (Gate.or 0 1 2 : Gate 3).outputs = {2} ∧ (Gate.and 0 1 2 : Gate 3).outputs = {2} ∧
    (Gate.nand 0 1 2 : Gate 3).outputs = {2} := by
  decide

/-- Every gate carries the label of its own type. -/
example : (Gate.copy 0 1 : Gate 2).type = .copy ∧ (Gate.not 0 1 : Gate 2).type = .not ∧
    (Gate.nor 0 1 2 : Gate 3).type = .nor ∧ (Gate.purify 0 1 2 : Gate 3).type = .purify ∧
    (Gate.or 0 1 2 : Gate 3).type = .or ∧ (Gate.and 0 1 2 : Gate 3).type = .and ∧
    (Gate.nand 0 1 2 : Gate 3).type = .nand := by
  decide

/-! ### A NOT cycle -/

/-- `NOT(0 → 1)`, `NOT(1 → 2)`, `NOT(2 → 0)`: an odd cycle of NOT gates. -/
def notCycle : Instance {.not} 3 where
  gates := {.not 0 1, .not 1 2, .not 2 0}
  allowed := by decide
  distinct := by decide
  output_unique := by decide

/-- A pure value at any node would flip around the odd cycle and contradict itself, so
the only solution is all garbage. -/
example : ∀ a b c : Value, notCycle.IsSolution ![a, b, c] ↔ (a, b, c) = (.bot, .bot, .bot) := by
  decide

/-! ### Gadgets of Corollary 2.2

A gadget has an input node that no gate outputs, so it is a gate set, not an instance.
"Acts as gate `T`" means: projected to the gadget's input and output nodes, its
satisfying assignments are exactly those of `T`. -/

/-- `PURIFY(0 → 1, 2)` followed by `NAND(1, 2 → 3)` [DFHM24, proof of Corollary 2.2]. -/
def notGadget : Finset (Gate 4) := {.purify 0 1 2, .nand 1 2 3}

/-- PURIFY then NAND acts as `NOT(0 → 3)`, including the free output on garbage. -/
example : ∀ a d : Value, (∃ b c : Value, ∀ g ∈ notGadget, g.Satisfied ![a, b, c, d]) ↔
    (Gate.not 0 1 : Gate 2).Satisfied ![a, d] := by
  decide

/-- `OR(0, 1 → 2)` followed by `NOT(2 → 3)` [DFHM24, proof of Corollary 2.2]. -/
def norGadget : Finset (Gate 4) := {.or 0 1 2, .not 2 3}

/-- OR then NOT acts as `NOR(0, 1 → 3)`, robustness included. -/
example : ∀ a b d : Value, (∃ c : Value, ∀ g ∈ norGadget, g.Satisfied ![a, b, c, d]) ↔
    (Gate.nor 0 1 2 : Gate 3).Satisfied ![a, b, d] := by
  decide

/-! ### Instance conditions -/

/-- `NOR(0, 1 → 2)`, `PURIFY(2 → 0, 3)`, `PURIFY(3 → 1, 2)`: node `2` is the output of
two gates. -/
def doubleOutput : Finset (Gate 4) := {.nor 0 1 2, .purify 2 0 3, .purify 3 1 2}

/-- Must fail: `doubleOutput` is not an instance. -/
example : ¬ OutputUnique doubleOutput := by decide

/-- Why the condition matters: no assignment satisfies every gate of `doubleOutput`, so
dropping "at most one gate per output" would break totality. -/
example : ∀ a b c d : Value, ¬ ∀ g ∈ doubleOutput, g.Satisfied ![a, b, c, d] := by decide

/-- Must fail: `NOR(u, u → w)` repeats a node [DFHM24, Remark 2]. -/
example : ¬ (Gate.nor 0 0 1 : Gate 2).Distinct := by decide

/-- Must fail: `PURIFY(u → v, v)` repeats a node. With `v = w` it would force a pure
output on garbage input, a stronger gate than PURIFY. -/
example : ¬ (Gate.purify 0 1 1 : Gate 2).Distinct := by decide

/-- Must fail: `NAND(u, u → w)` repeats a node [DFHM24, Remark 2]. -/
example : ¬ (Gate.nand 0 0 1 : Gate 2).Distinct := by decide

/-- Must fail: `COPY(u → u)` and `NOT(u → u)` read their own output. -/
example : ¬ (Gate.copy 0 0 : Gate 1).Distinct ∧ ¬ (Gate.not 0 0 : Gate 1).Distinct := by
  decide

/-- Control: `NOT(0 → 1)` is `Distinct`. -/
example : (Gate.not 0 1 : Gate 2).Distinct := by decide

/-! ### MF4: the gate set -/

/-- `NOT(0 → 1)`, `NOT(1 → 0)`: a valid instance over the gate set `{NOT}`. -/
def notPair : Instance {.not} 2 where
  gates := {.not 0 1, .not 1 0}
  allowed := by decide
  distinct := by decide
  output_unique := by decide

/-- MF4. The gates of `notPair` are distinct and output every node once, yet no instance
of Definition 1 has them: the field `allowed` rejects NOT. -/
example : ¬ ∃ I : Instance norPurify 2, I.gates = notPair.gates := by
  rintro ⟨I, h⟩
  have := I.allowed
  rw [h] at this
  revert this
  decide

end TfnpLean.PureCircuit.Tests
