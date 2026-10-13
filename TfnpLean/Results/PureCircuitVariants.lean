/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.Reduction
public import TfnpLean.PureCircuit

/-!
# Result: Pure-Circuit gate-set variants reduce to each other

**Status:** module docstring only.

The first reductions in the library stay inside Pure-Circuit: the variants of
[DFHM24, Corollary 2.2] (PURIFY with NOR or NAND; PURIFY and NOT with OR or
AND) are each reducible to and from the main NOR plus PURIFY definition. The
proof in the paper simulates NOR by the other gate sets (NOT from PURIFY plus
NAND, OR from NOT plus AND by De Morgan, and so on).

Whether the variants are separate problems or one definition parametrised by a
gate set is decision D3 in `docs/DESIGN.md`, still to be confirmed with the
supervisor.

## Dependencies

`TfnpLean.Reduction`, `TfnpLean.PureCircuit`.

## Paper reference

* [DFHM24, Section 2.1, Corollary 2.2].
-/
