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

The first reductions in the library stay inside Pure-Circuit: the gate sets of
[DFHM24, Corollary 2.2] (PURIFY with NOR or NAND; PURIFY and NOT with OR or AND)
each reduce to and from `norPurify`, the gate set of Definition 1. All of them are
`Instance S n` for a gate set `S` (`docs/DESIGN.md`, D3), so a reduction maps
`Instance S n` to `Instance S' m`. The gate sets of the corollary are named here,
together with the statements.

The proof in the paper simulates NOR by the other gate sets (NOT from PURIFY plus
NAND, OR from NOT plus AND by De Morgan, and so on). The two gadgets the proof
uses are checked in `TfnpLean/Tests/PureCircuit.lean`.

## Dependencies

`TfnpLean.Reduction`, `TfnpLean.PureCircuit`.

## Paper reference

* [DFHM24, Section 2.1, Corollary 2.2].
-/
