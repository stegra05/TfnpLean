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

**Status:** module docstring only. Its form depends on `docs/DESIGN.md`, D5
and D13.

Evaluating a circuit on an input is polynomial time in the size of the circuit
plus the input. This is the fact that makes End-of-Line (and so PPAD) a member
of TFNP: a proposed solution is checked by evaluating the two circuits a
constant number of times. With a concrete machine model (D5) it is a theorem
and a lot of machine work, not conceptually hard; with an abstract model it may
be part of what the interface provides.

## Dependencies

`TfnpLean.PolyTime`, the circuit model (D13).

## Paper reference

* [AroraBarak09, Section 6.1] (circuit evaluation), CSLib
  `Cslib.Computability.Circuit` for the circuit model.
-/
