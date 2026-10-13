/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.PolyTime
public import Cslib.Computability.Circuit.Boolean.Basic

/-!
# Result: Boolean circuits evaluate in polynomial time

**Status:** module docstring only.

Evaluating a CSLib Boolean circuit on an input is polynomial time in the size
of the circuit plus the input, as a `Cslib.PolyTimeComputable` machine. This
is the machine-level fact that makes End-of-Line (and so PPAD) a member of
TFNP: a proposed solution is checked by evaluating the two circuits a constant
number of times. Expected to be a lot of machine work, not conceptually hard.

## Dependencies

`TfnpLean.PolyTime`, CSLib circuits and Turing machines.

## Paper reference

* [AroraBarak09, Section 6.1] (circuit evaluation), CSLib
  `Cslib.Computability.Circuit` for the circuit model.
-/
