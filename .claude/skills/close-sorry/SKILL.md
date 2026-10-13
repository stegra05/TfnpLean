---
name: close-sorry
description: Close exactly one sorry in a theorem statement, with the repair budget and mandatory logging. Use when asked to prove a lemma, close a sorry, or make progress on a proof.
---

# Close one sorry

Proofs are secondary in this thesis: AI builds them, Steffen checks the
statements. One `sorry` per invocation. A proof task never changes a
definition or a statement; if the statement looks unprovable or wrong, stop
and report, do not adapt it.

## Steps

1. **Pick the target.** As named by the user, else the next `sorry` in build
   order (`bash scripts/sorry_census.sh`).
2. **Read the statement and its paper item** (docstring, `docs/PAPER_MAP.md`).
   If Lean and paper seem to diverge, stop and ask.
3. **Search first** with the lean-lsp tools: `lean_leansearch`,
   `lean_loogle`, `lean_state_search`, and `exact?` in the file.
4. **Prove** with structured tactics; check goals with `lean_goal`.
5. **Build** after each meaningful edit; each failed build plus fix is one
   repair loop.
6. **Budget:** at most 3 repair loops per approach and 2 approaches. If
   exhausted, restore the `sorry`, keep compiling `have` lemmas only, report
   what failed.
7. **Log** with `scripts/log_interaction.py --task proof` (or `repair`),
   exact model id, honest outcome, `--attempts` = builds run.
8. **Commit** as `prove: <decl> (<paper ref>)`.
