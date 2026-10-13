/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.PureCircuit
public import TfnpLean.SearchProblem
public import TfnpLean.PolyTime
public import TfnpLean.TFNP
public import TfnpLean.Reduction
public import TfnpLean.PPAD
public import TfnpLean.Results.EndOfLineTotal
public import TfnpLean.Results.CircuitEvalPolyTime
public import TfnpLean.Results.PPADSubsetTFNP
public import TfnpLean.Results.PureCircuitVariants
public import TfnpLean.Results.PureCircuitInPPAD
public import TfnpLean.Results.PureCircuitPPADHard
public import TfnpLean.Validation.SparseWinLose
public import TfnpLean.Validation.CakeCutting
public import TfnpLean.Tests.PureCircuit

/-!
# TfnpLean

A Lean 4 library of verified definitions and theorem statements for total search
problems: TFNP, PPAD, End-of-Line and Pure-Circuit, built on CSLib and Mathlib.

The build order follows the project plan:

1. `TfnpLean.PureCircuit`: the Pure-Circuit problem (NOR, PURIFY), Mathlib only.
2. `TfnpLean.SearchProblem`: search problems in general, Pure-Circuit as the first case.
3. `TfnpLean.PolyTime`: polynomial time, taken from CSLib.
4. `TfnpLean.TFNP`: the class TFNP.
5. `TfnpLean.Reduction`: polynomial-time reductions between search problems.
6. `TfnpLean.PPAD`: End-of-Line and PPAD, the first use of CSLib circuits.

`Results/` holds the theorem statements that test the definitions, `Validation/` holds
existing problems written in the library's terms, and `Tests/` holds the examples and
must-fail cases from `docs/CHECKING.md`.
-/
