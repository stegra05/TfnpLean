/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.PPAD

/-!
# Result: End-of-Line always has a solution

**Status:** module docstring only. Statement first, proof by AI agents, statement
checked by the author.

Every End-of-Line instance has a solution: in a directed graph where every
vertex has in-degree and out-degree at most one, a source that is not the
standard one, or a sink, must exist because every path has two ends (the
parity argument). Expected to be short.

## Dependencies

`TfnpLean.PPAD`.

## Paper reference

* [Pap94, Section 2].
-/
