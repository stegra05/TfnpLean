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
* **Must fail:** a gate set in which a node is the output of two gates violates
  `OutputUnique`, and this particular one has no satisfying assignment at all.
* **Must fail:** `NOR(u, u → w)` and `PURIFY(u → v, v)` are not `Distinct`.

## References

* [DFHM24, Section 2, Definition 1, Remark 2, Appendix A.1].
-/

public section

namespace TfnpLean.PureCircuit.Tests

open TfnpLean.PureCircuit

/-! ### The three-node instance -/

/-- `PURIFY(0 → 1, 2)` and `NOR(1, 2 → 0)`: a cycle through all three nodes. -/
def threeNode : Instance 3 where
  gates := {.purify 0 1 2, .nor 1 2 0}
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
def norCycle : Instance 3 where
  gates := {.nor 1 2 0, .nor 2 0 1, .nor 0 1 2}
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

end TfnpLean.PureCircuit.Tests
