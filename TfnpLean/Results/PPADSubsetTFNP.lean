/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.TFNP
public import TfnpLean.Results.EndOfLineTotal
public import TfnpLean.Results.CircuitEvalPolyTime

/-!
# Result: PPAD is contained in TFNP

**Status:** module docstring only.

End-of-Line is in TFNP (totality from `EndOfLineTotal`, polynomial-time
checking from `CircuitEvalPolyTime`, short solutions by construction), and
TFNP is closed under polynomial-time reductions, so every problem in PPAD is in
TFNP.

## Dependencies

`TfnpLean.TFNP`, `TfnpLean.Results.EndOfLineTotal`,
`TfnpLean.Results.CircuitEvalPolyTime`.

## Paper reference

* [Pap94, Section 2].
-/
