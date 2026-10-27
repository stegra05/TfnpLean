/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.PPAD
public import Mathlib.Data.Fin.VecNotation

/-!
# Tests: End-of-Line examples and must-fail cases

Small instances worked by hand and checked by `decide`, following `docs/CHECKING.md`.
A vertex is written `![a, b]` for the bit string `ab`: the left bit of the string is
index `0`. The solution condition is checked on the function layer
(`EndOfLine.IsSolution` on tables `S`, `P : Vertex 2 → Vertex 2`) and on one instance
built from CSLib circuits.

* **Example 1, one line:** `00 → 01 → 11 → 10`; `10` is the only solution, a sink.
* **Example 2, two lines:** `00 → 01` and `10 → 11`; the solutions are the sinks `01`
  and `11` and the source `10`, not `00`.
* **E1, must fail:** `0^n` is not a solution while it keeps its out-edge (example 1).
  Dropping `≠ 0^n` from the second clause would make `0^n` a solution of every instance.
* **E2, must fail:** an edge needs `S` and `P` to agree. Reading example 1 with edges
  from `S` alone gives a cycle without ends; the sink `10` is a sink only because
  `P(00) ≠ 10`.
* **E3, must fail:** `S = P = id` violates the condition on `0^n`, so it is not an
  instance; as functions it has no solution at all.
* **E4, control:** `0^n` can lose its out-edge, and then `0^n` is a solution by the first
  clause.
* **Must hold:** the sink reading and the source reading agree with the formula on the
  examples (the bridge of `docs/DESIGN.md`, D17, on instances of size two).
* **Instance:** `S = NOT`, `P = 0` on one bit is an instance (the condition on `0^n`
  holds by `decide`), with the sink `1` as its only solution.

## References

* [DGP09, Section 3.1, p. 202].
-/

public section

namespace TfnpLean.EndOfLine.Tests

open TfnpLean.EndOfLine Cslib.Circuits

/-- The bit string `ab` as a vertex. -/
def v (a b : Bool) : Vertex 2 := ![a, b]

/-! ### Example 1: one line `00 → 01 → 11 → 10` -/

/-- Successor table of example 1: `00 ↦ 01`, `01 ↦ 11`, `11 ↦ 10`, `10 ↦ 00`. -/
def S₁ : Vertex 2 → Vertex 2 := fun x =>
  if x = v false false then v false true else
  if x = v false true then v true true else
  if x = v true true then v true false else v false false

/-- Predecessor table of example 1: `00 ↦ 00`, `01 ↦ 00`, `11 ↦ 01`, `10 ↦ 11`. -/
def P₁ : Vertex 2 → Vertex 2 := fun x =>
  if x = v false false then v false false else
  if x = v false true then v false false else
  if x = v true true then v false true else v true true

/-- The condition on `0^n` holds for the tables of example 1. -/
example : P₁ zeros = zeros ∧ S₁ zeros ≠ zeros := by decide

/-- `10` is the only solution of example 1. -/
example : ∀ x, IsSolution S₁ P₁ x ↔ x = v true false := by decide

/-- `10` is a solution by the first clause: it is a sink. -/
example : P₁ (S₁ (v true false)) ≠ v true false := by decide

/-- The edges of example 1 are exactly `00 → 01`, `01 → 11`, `11 → 10`. -/
example : ∀ x y, Edge S₁ P₁ x y ↔
    (x = v false false ∧ y = v false true) ∨ (x = v false true ∧ y = v true true) ∨
    (x = v true true ∧ y = v true false) := by decide

/-- **E2.** `S₁ 10 = 00`, but `P₁ 00 ≠ 10`: no edge `10 → 00`. -/
example : S₁ (v true false) = v false false ∧ ¬ Edge S₁ P₁ (v true false) (v false false) := by
  decide

/-- **E1.** `00` keeps its out-edge, so it is not a solution. -/
example : ¬ IsSolution S₁ P₁ (v false false) := by decide

/-- **E1, the clause.** Without `≠ 0^n`, `00` would satisfy the second clause. -/
example : S₁ (P₁ (v false false)) ≠ v false false := by decide

/-! ### Example 2: two lines `00 → 01` and `10 → 11` -/

/-- Successor table of example 2: `00 ↦ 01`, `01 ↦ 01`, `10 ↦ 11`, `11 ↦ 11`. -/
def S₂ : Vertex 2 → Vertex 2 := fun x =>
  if x = v false false then v false true else
  if x = v false true then v false true else
  if x = v true false then v true true else v true true

/-- Predecessor table of example 2: `00 ↦ 00`, `01 ↦ 00`, `10 ↦ 10`, `11 ↦ 10`. -/
def P₂ : Vertex 2 → Vertex 2 := fun x =>
  if x = v false false then v false false else
  if x = v false true then v false false else
  if x = v true false then v true false else v true false

/-- The solutions of example 2 are `01`, `10` and `11`. -/
example : ∀ x, IsSolution S₂ P₂ x ↔ x ≠ v false false := by decide

/-- `10` is a solution by the second clause only: a source other than `0^n`. -/
example : P₂ (S₂ (v true false)) = v true false ∧ S₂ (P₂ (v true false)) ≠ v true false := by
  decide

/-- `S x = x` with `P x ≠ x` is "no successor", not a self-loop. -/
example : ¬ Edge S₂ P₂ (v false true) (v false true) := by decide

/-! ### The bridge on the examples: formula versus sink or source -/

example : ∀ x, IsSolution S₁ P₁ x ↔ (IsSink S₁ P₁ x ∨ (IsSource S₁ P₁ x ∧ x ≠ zeros)) := by
  decide

example : ∀ x, IsSolution S₂ P₂ x ↔ (IsSink S₂ P₂ x ∨ (IsSource S₂ P₂ x ∧ x ≠ zeros)) := by
  decide

/-! ### E3 and E4 -/

/-- **E3.** `S = P = id` violates the condition on `0^n`. -/
example : ¬ ((id : Vertex 2 → Vertex 2) zeros = zeros ∧
    (id : Vertex 2 → Vertex 2) zeros ≠ zeros) := by
  decide

/-- **E3.** As functions, `S = P = id` has no solution: the condition is what makes the
problem total. -/
example : ∀ x, ¬ IsSolution (id : Vertex 2 → Vertex 2) id x := by decide

/-- Successor table of E4: as example 1, but `P 01 = 11`, so `00` loses its out-edge. -/
def P₄ : Vertex 2 → Vertex 2 := fun x =>
  if x = v false false then v false false else
  if x = v false true then v true true else
  if x = v true true then v false true else v true true

/-- **E4, control.** The condition on `0^n` still holds, and `00` is a solution by the
first clause. -/
example : (P₄ zeros = zeros ∧ S₁ zeros ≠ zeros) ∧ IsSolution S₁ P₄ (v false false) := by decide

/-! ### An instance built from CSLib circuits: `S = NOT`, `P = 0` on one bit -/

/-- The circuit with one NOT gate on input `0`, output that gate. -/
def notCircuit : BoolCircuit 1 where
  program := .gate .empty ⟨.not, fun _ => .input 0⟩
  outputs := fun _ => .gate 0

/-- The circuit with one constant-`0` gate, output that gate. -/
def zeroCircuit : BoolCircuit 1 where
  program := .gate .empty ⟨.const false, fun i => i.elim0⟩
  outputs := fun _ => .gate 0

example : notCircuit.fn ![false] = ![true] ∧ notCircuit.fn ![true] = ![false] := by decide
example : zeroCircuit.fn ![false] = ![false] ∧ zeroCircuit.fn ![true] = ![false] := by decide

/-- The one-bit instance: edge `0 → 1`, and `1` is a sink. -/
def oneBit : Instance 1 where
  S := notCircuit
  P := zeroCircuit
  source := by decide

/-- `1` is the only solution of the one-bit instance. -/
example : ∀ x, oneBit.IsSolution x ↔ x = ![true] := by decide

/-- **E3 on circuits.** The identity circuit as both `S` and `P` cannot satisfy the
condition on `0^n`, so no instance has it as both circuits. -/
def idCircuit : BoolCircuit 1 := Circuit.id Boolean.signature 1

example : ¬ (idCircuit.fn zeros = zeros ∧ idCircuit.fn zeros ≠ zeros) := by decide

end TfnpLean.EndOfLine.Tests
