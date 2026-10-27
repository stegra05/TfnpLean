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
public import TfnpLean.Tests.PureCircuit
public import TfnpLean.Tests.EndOfLine

/-!
# TfnpLean

A Lean 4 library of verified definitions and theorem statements for total search
problems: TFNP, PPAD, PLS and their canonical problems Pure-Circuit, End-of-Line and
Localopt, built on CSLib and Mathlib.

The library is built in layers:

* Problems: `TfnpLean.PureCircuit` (Pure-Circuit and the gates of its variants,
  Mathlib only), End-of-Line in `TfnpLean.PPAD`; Localopt to come. Whether they
  share one circuit core is open (`docs/DESIGN.md`, D13).
* Polynomial time: `TfnpLean.PolyTime`, an interface; the model behind it is open (D5).
* Frame: `TfnpLean.SearchProblem`, `TfnpLean.TFNP`, `TfnpLean.Reduction`.
* Classes: PPAD in `TfnpLean.PPAD` as the reduction closure of End-of-Line (D14);
  PLS from Localopt to come.

`Results/` holds the theorem statements that test the definitions, `Validation/` holds
results of existing papers restated in the library's terms, and `Tests/` holds the
examples and must-fail cases from `docs/CHECKING.md`.
-/
