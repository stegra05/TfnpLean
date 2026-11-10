/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.PureCircuit
public import TfnpLean.EndOfLine
public import TfnpLean.Results.EndOfLineTotal
public import TfnpLean.Tests.PureCircuit
public import TfnpLean.Tests.EndOfLine

/-!
# TfnpLean

A Lean 4 library of verified definitions and theorem statements for total search
problems: TFNP, PPAD, PLS and their canonical problems Pure-Circuit, End-of-Line and
Localopt, built on CSLib and Mathlib.

The library is built in layers. Written so far:

* Problems: `TfnpLean.PureCircuit` (Pure-Circuit and the gates of its variants) and
  `TfnpLean.EndOfLine`. A problem module depends on Mathlib and CSLib only, not on the
  frame below.
* Results: `TfnpLean.Results.EndOfLineTotal`, the statements that test the End-of-Line
  definition (its graph reading, totality).
* Tests: `TfnpLean.Tests`, the examples and must-fail cases from `docs/CHECKING.md`.

Planned, in this order (`docs/PLANNED.md`): polynomial time behind an interface (D5); the
frame of search problems, TFNP and reductions; the classes, with PPAD as the reduction
closure of End-of-Line (D14) and PLS from Localopt; then the reductions between the
problems. A module is created when its first declaration exists.
-/
