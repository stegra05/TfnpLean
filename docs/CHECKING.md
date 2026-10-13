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

### Must-hold controls

- The three-node instance has exactly the solutions `(⊥, 0, ⊥)` and
  `(⊥, ⊥, 0)` (worked by hand).
- PURIFY on a pure input copies it to both outputs.

## Later definitions

Each of search problems, TFNP, reductions, End-of-Line and PPAD gets its own
must-fail cases here before it is written. Candidates: a search problem that
is not total is not in TFNP; a reduction whose solution map is not
polynomial time is not a reduction; an End-of-Line instance where the
all-zero vertex is not a source.
