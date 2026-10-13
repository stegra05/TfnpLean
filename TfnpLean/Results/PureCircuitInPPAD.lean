/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.PPAD
public import TfnpLean.PureCircuit

/-!
# Result: Pure-Circuit is in PPAD

**Status:** module docstring only. The heavy one.

Membership of Pure-Circuit in PPAD, the easy half of [DFHM24, Theorem 2.1].
In the paper it follows either from the reductions of Section 4 to problems
known to be in PPAD, or directly by reducing to a Brouwer fixed-point problem
(Section 2, discussion after Theorem 2.1). Either way a fixed-point theorem or
another PPAD problem is needed. Whether this is in scope, or stated as a
clearly marked assumption, is an open question.

PPAD-hardness, the other half of Theorem 2.1, is stated in
`TfnpLean.Results.PureCircuitPPADHard`.

## Dependencies

`TfnpLean.PPAD`, `TfnpLean.PureCircuit`.

## Paper reference

* [DFHM24, Theorem 2.1 and the discussion following it; Section 3.1 for
  StrongSperner].
-/
