---
name: log
description: Record an LLM interaction in the private interaction log (task type, model, outcome, fix time, definition changed). Use after any formalization task or when the user says "log this".
---

# Log an interaction

```bash
python3 scripts/log_interaction.py --task <type> --target <decl-or-file> \
  --model <exact-model-id> --outcome <outcome> --attempts <n> \
  [--definition-changed] [--fix-min <minutes>] [--notes "..."]
```

| task | meaning |
|---|---|
| `definition` | writing or changing a core definition |
| `statement` | formalizing a paper statement (ends in `sorry`) |
| `test` | examples and must-fail cases in `Tests/` |
| `proof` | proving a stated goal |
| `repair` | fixing earlier non-compiling or wrong output |
| `refactor` | restructuring compiling code |
| `search` | finding Mathlib or CSLib API |
| `infra` | build, CI, tooling |
| `docs` | DESIGN, PAPER_MAP, CHECKING, README |

| outcome | meaning |
|---|---|
| `unaided` | compiled on the first build |
| `after_repair` | compiled after repair loops |
| `human_finished` | Steffen completed or corrected it |
| `failed` | abandoned |

Rules: one record per distinct task; exact model id, never a guess;
`--definition-changed` whenever a definition or statement changed meaning
(the thesis must be able to show that proof work never did this); log
failures too.
