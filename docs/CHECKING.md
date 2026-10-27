# Checking a definition

Correct definitions are the central part of this library. A proof going
through only shows that the definitions fit together, not that they mean the
right thing. Every definition goes through the four steps below before it is
used by anything else, and the outcome is recorded in `PAPER_MAP.md`.

## The four steps

1. **Paper side by side.** Write the Lean definition next to the paper's
   text (section, definition number). Every clause in the paper maps to a
   clause in Lean, and every clause in Lean maps back. Anything added or
   dropped is a decision and goes into `DESIGN.md`.
2. **Examples by hand.** Work two or three tiny instances on paper first,
   then state them in `TfnpLean/Tests/` and let Lean confirm the hand
   result (`decide` or an explicit witness).
3. **Must-fail tests.** For each definition, a case that the definition
   must reject. If the test unexpectedly passes, the definition is too
   weak. These are the tests that catch the errors a passing proof hides.
4. **Supervisor review.** The side-by-side from step 1 and the examples
   from steps 2 and 3 go to the supervisor before the definition is built
   on.

## Must-fail cases

### MF1. Pure-Circuit: all-garbage is not a solution when PURIFY is present

Instance: any instance containing at least one PURIFY gate, for example the
three-node instance PURIFY(1 → 2, 3), NOR(2, 3 → 1).
Assignment: every node gets `⊥`.
Expected: not a solution, because PURIFY on input `⊥` needs at least one
output in `{0, 1}`.
Control: the same assignment on an instance with only NOR gates is a
solution. Without PURIFY the problem is trivial (paper, Section 2 and
Appendix A.1), so a definition where MF1 passes has lost PURIFY's meaning.

### MF2. Pure-Circuit: NOR is robust

Instance: NOR(u, v → w). Assignment: `x[u] = 1`, `x[v] = ⊥`, `x[w] = 1`.
Expected: not a solution. One input `1` forces output `0` even if the other
input is garbage. A definition that only constrains NOR on pure inputs
passes this test wrongly and, by Appendix A.1, defines a polynomial-time
problem.

### MF3. Pure-Circuit: OR, AND and NAND are robust

Gates: OR(u, v → w), AND(u, v → w), NAND(u, v → w) [DFHM24, Section 2.1].
Assignment: one input decides the result (`1` for OR, `0` for AND and
NAND), the other input is `⊥`, in either position.
Expected: the output is forced (`1`, `0`, `1`); every other output is
rejected. The analogue of MF2 for the gates of Section 2.1.
Control: OR on `0, ⊥`, AND and NAND on `1, ⊥` accept every output.

### MF4. Pure-Circuit: the gate set is enforced

Gate set: NOT(0 → 1), NOT(1 → 0). It is a valid instance over `{NOT}`.
Expected: there is no instance over `norPurify` with these gates. The
field `allowed` is the only condition that rejects them, so a definition
where MF4 passes has lost the restriction to the gates of Definition 1.

### Must-hold controls

- The three-node instance has exactly the solutions `(⊥, 0, ⊥)` and
  `(⊥, ⊥, 0)` (worked by hand).
- PURIFY on a pure input copies it to both outputs.
- COPY and NOT force their output exactly on a pure input.
- A cycle of three NOT gates has exactly the all-`⊥` solution.
- PURIFY followed by NAND on its two outputs acts exactly as NOT, and OR
  followed by NOT acts exactly as NOR (the gadgets of the proof of
  Corollary 2.2).

### E1. End-of-Line: `0^n` is not a solution while it keeps its out-edge

Instance: example 1, the line `00 → 01 → 11 → 10` (tables `S₁`, `P₁` in
`TfnpLean/Tests/EndOfLine.lean`). Candidate: `x = 00`.
Expected: not a solution. `P(S(00)) = 00`, and the second clause requires
`x ≠ 0^n`. The instance condition makes `0^n` a source in every instance,
so a definition without `≠ 0^n` would accept `0^n` always: a trivial
problem [DGP09, p. 202, "a source other than 0^n"].

### E2. End-of-Line: an edge needs `S` and `P` to agree

Instance: example 1. `S(10) = 00` but `P(00) = 00 ≠ 10`.
Expected: no edge `10 → 00`, and `10` is a sink. A definition with edges
from `S` alone would read example 1 as a cycle without ends, and the
problem would not be total.

### E3. End-of-Line: the condition on `0^n` is needed

Instance: `S = P = id`.
Expected: not an instance (the field `source` cannot be proved); as
functions, no vertex is a solution. A definition without the condition
would have instances without solutions.

### E4. End-of-Line, control: `0^n` can lose its out-edge

Instance: example 1 with `P(01) = 11`. Condition on `0^n` still holds.
Expected: `00` is a solution by the first clause, `P(S(00)) ≠ 00`. The
`≠ 0^n` is only in the second clause.

### Must-hold controls, End-of-Line

- Example 1 has exactly the solution `10`, a sink; example 2 (`00 → 01`,
  `10 → 11`) has exactly the solutions `01`, `11` (sinks) and `10` (a
  source other than `0^n`); both worked by hand on 2026-10-27.
- On both examples the formula agrees with "a sink, or a source other than
  `0^n`" (the bridge of D17, checked by `decide` for `n = 2`).
- The one-bit instance `S = NOT`, `P = 0` built from CSLib circuits
  satisfies the condition on `0^n` by `decide` and has exactly the solution
  `1`.

## Later definitions

Each of search problems, TFNP, reductions, Localopt, PPAD and PLS gets its
own must-fail cases here before it is written. Candidates: a search problem
that is not total is not in TFNP; a reduction whose solution map is not
polynomial time is not a reduction.

## Validating the library

The four steps check one definition at a time. Four further checks test
the library as a whole:

1. **Sanity theorems.** Small proofs that must hold if the definitions are
   right: End-of-Line is total (parity argument), reductions compose, the
   identity is a reduction, PPAD is contained in TFNP. These are the proofs
   the library does carry, because they are evidence that the statements
   mean what the papers mean.
2. **Executable instances.** Tiny Pure-Circuit and End-of-Line instances,
   evaluated with `decide` and compared with solutions worked out by hand
   (step 2 above, kept for every problem).
3. **Reference oracle.** Plain Python implementations of each problem, run
   against the Lean definitions on generated instances. A disagreement
   points at one side or the other.
4. **Restating papers.** The main theorems of the Pure-Circuit paper and of
   the sparse win-lose paper (Batziou, Fearnley, Ghosh, Savani 2026),
   written with library primitives only. Needing a new primitive means the
   library has a gap.
