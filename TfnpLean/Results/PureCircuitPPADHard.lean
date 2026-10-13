/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.PPAD
public import TfnpLean.PureCircuit

/-!
# Result: Pure-Circuit is PPAD-hard (statement only)

**Status:** module docstring only. Proposed, to confirm with the supervisor
(`docs/DESIGN.md`, D6).

PPAD-hardness of Pure-Circuit, the hard half of [DFHM24, Theorem 2.1]: every
problem in PPAD reduces to Pure-Circuit. Together with
`TfnpLean.Results.PureCircuitInPPAD` this states PPAD-completeness. The
statement is in scope; the proof (a reduction from StrongSperner,
[DFHM24, Section 3]) is not, and the statement stays marked as unproven.

## Dependencies

`TfnpLean.PPAD`, `TfnpLean.PureCircuit`.

## Paper reference

* [DFHM24, Theorem 2.1; Section 3, Definition 2 (StrongSperner)].
-/
