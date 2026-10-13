/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.SearchProblem
public import TfnpLean.PolyTime

/-!
# Step 4: TFNP

**Status:** module docstring only.

## What goes here

The class TFNP: search problems where (1) a solution always exists, (2)
solutions are polynomially short in the instance, and (3) checking a proposed
solution is polynomial time. Conditions (2) and (3) use step 3; condition (1)
is totality from step 2.

## Dependencies

`TfnpLean.SearchProblem`, `TfnpLean.PolyTime`.

## Paper reference

* [MP91, Section 1] (TFNP, written there as "the class of total NP search
  problems").
* [Pap94, Section 1].
* [P. W. Goldberg, C. H. Papadimitriou, *Towards a unified complexity theory
  of total functions*, JCSS 94, 2018][GP18] for the modern view.
-/
