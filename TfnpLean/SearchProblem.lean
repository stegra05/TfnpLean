/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.PureCircuit

/-!
# Step 2: Search problems

**Status:** module docstring only.

## What goes here

The general notion of a search problem: an instance type, a solution type, and
a relation saying which solutions count for which instance. Pure-Circuit from
step 1 is the first case written in this form, and it is the test that the
general shape fits a concrete problem.

Totality (every instance has a solution) is a property of a search problem and
is stated here; the complexity conditions of TFNP come in step 4.

## Dependencies

`TfnpLean.PureCircuit`, Mathlib.

## Paper reference

* [N. Megiddo, C. H. Papadimitriou, *On total functions, existence theorems
  and computational complexity*, TCS 81(2), 1991, Section 1][MP91].
* [C. H. Papadimitriou, *On the complexity of the parity argument and other
  inefficient proofs of existence*, JCSS 48(3), 1994, Section 1][Pap94].
-/
