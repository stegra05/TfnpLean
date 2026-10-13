/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.SearchProblem
public import TfnpLean.PolyTime

/-!
# Step 5: Reductions

**Status:** module docstring only.

## What goes here

Polynomial-time reductions between search problems: a map from instances of A
to instances of B and a map from solutions of B back to solutions of A, both
polynomial time (step 3), such that a solution of the translated instance maps
back to a solution of the original instance. Reductions compose and are
reflexive; the closure of a problem under reductions is what PPAD is built from
in step 6.

The first reductions to be stated are the ones between Pure-Circuit gate-set
variants, [DFHM24, Corollary 2.2]; their statements live in
`TfnpLean.Results.PureCircuitVariants`.

## Dependencies

`TfnpLean.SearchProblem`, `TfnpLean.PolyTime`.

## Paper reference

* [Pap94, Section 2] (reductions between search problems).
* [MP91, Section 1].
-/
