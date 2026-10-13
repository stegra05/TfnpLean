/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.Reduction
public import Cslib.Computability.Circuit.Boolean.Basic

/-!
# Step 6: End-of-Line and PPAD

**Status:** module docstring only.

## What goes here

The End-of-Line problem: two Boolean circuits on `n`-bit strings describe a
successor and a predecessor function on `2^n` vertices, the all-zero vertex is
a source, and a solution is any other vertex that is a source or a sink. This
is the first and only place where CSLib's Boolean circuits
(`Cslib.Circuits.Boolean`) are used: they are needed to write instances down
compactly, nothing more.

PPAD is then the set of search problems that reduce (step 5) to End-of-Line.
PPAD-hardness and PPAD-completeness are defined alongside.

## Dependencies

`TfnpLean.Reduction`, CSLib: `Cslib.Computability.Circuit.Boolean.Basic`.

## Paper reference

* [Pap94, Section 2] (PPAD, End-of-Line as the defining problem).
* [C. Daskalakis, P. W. Goldberg, C. H. Papadimitriou, *The complexity of
  computing a Nash equilibrium*, ECCC TR05-115, 2005, Section 2][DGP05] for the
  End-of-Line formulation used today.
-/
