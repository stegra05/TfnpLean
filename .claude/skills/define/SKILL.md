---
name: define
description: Formalize one paper definition or statement with Steffen using the four-step checking method (paper side by side, examples by hand, must-fail tests, supervisor review). Use when asked to define, formalize, encode or state a paper item.
---

# Define one paper item

One paper item per invocation (a definition, or one theorem statement).
Steffen decides every encoding; you draft, compare and record. Never skip a
step, never continue past step 3 without his choice.

## Steps

1. **Gate.** The target file must be listed in `docs/UNLOCKED.md`. If not,
   stop and ask Steffen to unlock it; the paper must be read first.
2. **Paper side by side.** Open the paper item (PDF in
   `../thesis/material/papers/`, section and number from `docs/PAPER_MAP.md`).
   Before any code, write a two-column table in chat: every clause of the
   paper text on the left, the planned Lean clause on the right. Any clause
   that will differ (indexing, distinctness, representation) gets a third
   column "divergence".
3. **Choices.** List each encoding choice with at least one alternative
   (inductive vs `Option Bool`, `Fin n` vs `Fintype`, field vs proposition,
   ...). Ask Steffen to pick. Record his picks; they become the DESIGN entry.
4. **Draft.** Write the Lean, docstring citing the paper item (`[DFHM24,
   Definition 1]` style), CSLib conventions, no `sorry` in a definition. A
   statement ends in `sorry` and that is fine.
5. **Examples by hand.** Two tiny instances worked on paper by Steffen, then stated in `TfnpLean/Tests/` as
   `example` with `decide` or an explicit witness. The Lean result must
   match the hand result.
6. **Must-fail.** At least one `example : ¬ ...` that the definition must
   reject (see `docs/CHECKING.md`). If it unexpectedly holds, the definition
   is too weak: go back to step 3, do not weaken the test.
7. **Record.** `docs/DESIGN.md`: new entry (question, decision or OPEN,
   paper reference, encoding, rejected options, why, date) plus a
   divergence row for every difference from the paper text.
   `docs/PAPER_MAP.md`: declaration name, file, status `drafted`.
   `docs/CHECKING.md`: section for the item with the examples and
   must-fail cases listed.
8. **Build and check.** `lake build`, `python3 scripts/check_paper_map.py`.
9. **Log.** `python3 scripts/log_interaction.py --task definition` (or
   `statement`) with the exact model id and honest outcome.
10. **Commit** as `define: <item> (<paper ref>)` or `state: ...`.

Status moves to `checked` only when Steffen has done steps 2, 5 and 6
himself, and to `reviewed` after the supervisor's review; then Steffen freezes
the file with `scripts/freeze.py`.
