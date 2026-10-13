# TfnpLean

A Lean 4 library of checked definitions and theorem statements for total
search problems: TFNP, PPAD, End-of-Line and Pure-Circuit. Built on
[CSLib](https://github.com/leanprover/cslib) and Mathlib.

Bachelor's thesis project at TUM, Chair of Decision Sciences & Systems.
Author: Steffen Grabert. Supervisor: Dr. Abheek Ghosh.

## Goal

Complexity classes for total search problems are usually stated in prose,
and small encoding choices (which inputs a gate constrains, what counts as a
solution, what "polynomial time" is measured on) decide whether a
formal definition means what the paper means. This library writes each
definition next to its paper item, records every encoding choice, and tests
it with hand-worked examples and must-fail cases before anything is proved
about it. Theorem statements from the literature then act as a second test:
if a known result cannot even be stated cleanly, a definition is wrong.

Proofs are secondary. Statements may stay `sorry` as the work queue;
definitions never do.

## Status

Work in progress. Step 1 (Pure-Circuit) is drafted with tests and awaits
supervisor review; the later modules contain module docstrings that say what goes there, what they depend on and
which paper item they follow. Per-item status is tracked in
[`docs/PAPER_MAP.md`](docs/PAPER_MAP.md).

| Step | Module | Content |
|---|---|---|
| 1 | `TfnpLean.PureCircuit` | Pure-Circuit with NOR and PURIFY gates, Mathlib only |
| 2 | `TfnpLean.SearchProblem` | search problems, Pure-Circuit as the first case |
| 3 | `TfnpLean.PolyTime` | polynomial time, from CSLib's single-tape machines |
| 4 | `TfnpLean.TFNP` | the class TFNP |
| 5 | `TfnpLean.Reduction` | polynomial-time reductions between search problems |
| 6 | `TfnpLean.PPAD` | End-of-Line and PPAD, the first use of CSLib circuits |

`TfnpLean/Results/` holds theorem statements that test the definitions
(End-of-Line is total, PPAD is contained in TFNP, Pure-Circuit is in PPAD
and PPAD-hard, gate-set variants). `TfnpLean/Validation/` writes existing
problems in the library's terms (sparse win-lose games, cake cutting).
`TfnpLean/Tests/` holds the examples and must-fail cases.

## How a definition is checked

Every definition goes through four steps, described in
[`docs/CHECKING.md`](docs/CHECKING.md):

1. The paper text and the Lean clauses side by side, with every divergence
   named.
2. Small instances worked by hand, restated as `example`s that Lean must
   confirm.
3. Must-fail cases: weakened variants of the definition that the tests must
   reject.
4. Review with the supervisor, after which the file is frozen
   (`scripts/freeze.py`); CI fails if a frozen file changes.

Every encoding choice, with the rejected alternative and the reason, is
logged in [`docs/DESIGN.md`](docs/DESIGN.md).

## Build

```
lake exe cache get   # Mathlib cache, once after clone
lake build
```

The Lean toolchain and the Mathlib version follow the pinned CSLib commit
(`lakefile.toml`, `lean-toolchain`).

## Checks

```
bash scripts/sorry_census.sh            # sorries per file
lake env lean scripts/AxiomAudit.lean   # no non-standard axioms
python3 scripts/freeze.py --check       # frozen files unchanged
python3 scripts/check_paper_map.py      # paper map consistent with tests
```

CI runs the build and all four checks on every push.

## AI-assisted workflow

Parts of this library are written with Claude Code. The repository keeps
the configuration that constrains it, so the process can be inspected:

- `CLAUDE.md`: the working rules (never weaken a definition to make a proof
  pass, every design choice logged, no new axioms).
- `.claude/settings.json` and `scripts/hooks.py`: hooks that refuse edits
  to definition files unless the author has unlocked them in
  `docs/UNLOCKED.md`, refuse edits to frozen files, and block a session
  from ending when a definition changed without a `docs/DESIGN.md` entry.
- `.claude/skills/`: the procedures for defining one paper item, closing
  one `sorry`, and logging an interaction.
- `scripts/log_interaction.py`, `scripts/summary.py`: one record per task
  (model, outcome, repair attempts, whether a definition changed). The logs
  themselves are kept outside the repository.

Definitions and theorem statements are decided by the author; the AI
drafts, compares encodings and writes proofs.

Commit messages follow `define:`, `state:`, `test:`, `prove:`, `design:`,
`infra:`, `docs:`. Enable the check with
`git config core.hooksPath .githooks`.

## References

- A. Deligkas, J. Fearnley, A. Hollender, T. Melissourgos. Pure-Circuit:
  Tight Inapproximability for PPAD. J. ACM 71(5), 2024. arXiv:2209.15149.
- N. Megiddo, C. H. Papadimitriou. On total functions, existence theorems
  and computational complexity. Theoretical Computer Science 81(2), 1991.
- C. H. Papadimitriou. On the complexity of the parity argument and other
  inefficient proofs of existence. JCSS 48(3), 1994.
- C. Daskalakis, P. W. Goldberg, C. H. Papadimitriou. The complexity of
  computing a Nash equilibrium. ECCC TR05-115, 2005.
- E. Batziou, J. Fearnley, A. Ghosh, R. Savani. The Complexity of Sparse
  Win-Lose Bimatrix Games. arXiv:2602.18380, 2026.

## License

Apache 2.0, see [`LICENSE`](LICENSE).
