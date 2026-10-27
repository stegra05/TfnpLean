/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import Cslib.Computability.Machines.Turing.SingleTape.Deterministic
public import Cslib.Foundations.Data.BitString

/-!
# Polynomial time

**Status:** module docstring only.

## What goes here

An interface for polynomial-time computation, so that "checking a solution is
fast" and "the reduction maps are fast" can be stated in `TfnpLean.TFNP` and
`TfnpLean.Reduction` before the machine model is chosen (`docs/DESIGN.md`, D5).
What stands behind the interface is open: a concrete machine model such as
CSLib's `Cslib.Turing.SingleTapeTM.PolyTimeComputable` on single-tape Turing
machines (composition is `Cslib.Turing.SingleTapeTM.PolyTimeComputable.comp`),
an abstract cost model, or polynomial time as an explicit hypothesis. The
encoding of instances and solutions as strings belongs to the concrete choice.

The class FP is not in CSLib; it is stated here against the interface.

## Dependencies

To be fixed with D5. Candidates in CSLib:
`Cslib.Computability.Machines.Turing.SingleTape.Deterministic`,
`Cslib.Foundations.Data.BitString`.

## Paper reference

* [S. Arora, B. Barak, *Computational Complexity: A Modern Approach*,
  Chapter 1][AroraBarak09] for the machine model (CSLib's reference).
* [MP91, Section 1] for FP as the class of search problems solvable in
  polynomial time.
-/
