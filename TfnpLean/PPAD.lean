/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.Reduction
public import Cslib.Computability.Circuit.Boolean.Basic

/-!
# End-of-Line and PPAD

**Status:** module docstring only.

## What goes here

The End-of-Line problem: two Boolean circuits `S` and `P` on `n`-bit strings
describe a successor and a predecessor function on `2^n` vertices, the all-zero
vertex is a source, and a solution is any other vertex that is a source or a
sink. Variants differ in details (whether `0^n` must be a source, or counts as a
solution when it is not); the library follows one text, cited by page
(`docs/DESIGN.md`, D15). Whether `S` and `P` are CSLib Boolean circuits or the
library's own circuit core shared with Pure-Circuit and Localopt is open (D13).

PPAD is then the closure of End-of-Line under reductions (D14).
PPAD-hardness and PPAD-completeness are defined alongside.

## Dependencies

`TfnpLean.Reduction`. CSLib's `Cslib.Computability.Circuit.Boolean.Basic` is
imported as the candidate circuit model until D13 is settled.

## Paper reference

* [Pap94, Section 2] (PPAD, End-of-Line as the defining problem).
* [C. Daskalakis, P. W. Goldberg, C. H. Papadimitriou, *The complexity of
  computing a Nash equilibrium*, ECCC TR05-115, 2005, Section 3, p. 3][DGP05]; the
  journal version, SIAM J. Comput. 39(1), 2009, Section 3.1, p. 202 [DGP09].
  The End-of-Line formulation used today.
-/
