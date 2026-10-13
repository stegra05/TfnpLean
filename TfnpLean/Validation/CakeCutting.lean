/-
Copyright (c) 2026 Steffen Grabert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Steffen Grabert
-/
module

public import TfnpLean.TFNP

/-!
# Validation: envy-free cake cutting

**Status:** module docstring only.

An existing problem written in the library's terms: envy-free cake cutting
for four agents, Hollender and Rubinstein [HR23]. Cake cutting is usually
studied in a query model (the algorithm asks agents for values instead of
receiving valuations as input), so how it fits a TFNP library of input-based
search problems is an open question.

## Dependencies

`TfnpLean.TFNP`.

## Paper reference

* [A. Hollender, A. Rubinstein, *Envy-Free Cake-Cutting for Four Agents*,
  arXiv:2311.02075][HR23].
-/
