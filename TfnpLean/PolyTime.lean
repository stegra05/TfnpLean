/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import Cslib.Computability.Machines.Turing.SingleTape.Deterministic
public import Cslib.Foundations.Data.BitString

/-!
# Step 3: Polynomial time (from CSLib)

**Status:** module docstring only.

## What goes here

The connection between the library's search problems and CSLib's notion of
polynomial-time computation, `Cslib.PolyTimeComputable` (a single-tape Turing
machine packaged with a polynomial time bound). This step fixes how instances
and solutions are encoded as strings so that "checking a solution is fast" and
"the reduction maps are fast" can be stated in steps 4 and 5.

The class FP itself is not in CSLib; it is stated here on top of
`Cslib.PolyTimeComputable`. Composition of polynomial-time machines is
`Cslib.PolyTimeComputable.comp`.

## Dependencies

CSLib: `Cslib.Computability.Machines.Turing.SingleTape.Deterministic`,
`Cslib.Foundations.Data.BitString`.

## Paper reference

* [S. Arora, B. Barak, *Computational Complexity: A Modern Approach*,
  Chapter 1][AroraBarak09] for the machine model (CSLib's reference).
* [MP91, Section 1] for FP as the class of search problems solvable in
  polynomial time.
-/
