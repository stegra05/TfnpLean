# TfnpLean (public Lean library)

Bachelor's thesis library (TUM, Steffen Grabert, supervisor Dr. Abheek
Ghosh). This repository is public and may be contributed to CSLib:
keep commits, comments and docs professional and self-explanatory. Private
planning lives outside this repository and never gets copied in.

## Three rules

1. **Never weaken a definition to make a proof pass.** If a proof does not
   go through, the statement or the proof is wrong, or the definition is
   wrong; the last case is decided with the author and the supervisor, not
   by editing the definition.
2. **Every design choice is logged in `docs/DESIGN.md`** before it lands:
   question, decision (or OPEN), paper reference, encoding, rejected
   options, why, date.
3. **No new axioms.** `scripts/AxiomAudit.lean` must stay green. `sorry` is
   allowed in statements as the work queue, never hidden in a definition.

## Gates (enforced by hooks in `.claude/settings.json`, `scripts/hooks.py`)

- **Locked files.** Files under `TfnpLean/` except `Tests/` cannot be edited
  unless listed in `docs/UNLOCKED.md`. Only Steffen unlocks, after the paper
  item is on paper. Do not work around the gate (no edits via shell).
- **Frozen files.** After supervisor review Steffen runs
  `scripts/freeze.py <file>`; edits are refused and a changed hash blocks
  the session end and fails CI. An unfreeze gets a DESIGN.md entry.
- **Rationale gate.** A session that edits a definition or statement file
  cannot end until `docs/DESIGN.md` and `docs/PAPER_MAP.md` were touched.
- **Logging gate.** A session that edits Lean cannot end until one
  interaction record per task exists (`/log`).
- **Commit grammar.** `define:`, `state:`, `test:`, `prove:`, `design:`,
  `infra:`, `docs:` (git hook in `.githooks/`).

## Skills

`/define` (one paper item, four-step method), `/close-sorry` (one proof,
never a definition), `/log` (interaction record). The author keeps further
local skills for supervision; they are not part of this repository.

## How work happens

- Definitions are written together with the author after the four-step
  check in `docs/CHECKING.md`. Do not pre-write definitions, theorems or
  tests on your own.
- Statement first: every paper item becomes a declaration with a docstring
  citing the paper, then `sorry`, then a proof. Update `docs/PAPER_MAP.md`
  when a status changes.
- Follow CSLib conventions: copyright header, `module`, `public import`,
  `/-! -/` module docstrings with references, Mathlib naming
  (`UpperCamelCase` types, `lowerCamelCase` defs, `snake_case` theorems),
  100 columns.
- No em-dashes in prose.
- Logs are private: hooks write them outside this repository (see
  `scripts/hooks.py`). The session-start hook prints the current step if
  the author's workspace provides one; work on that, and say so if a
  request leaves it.

## Commands

- `lake build`: full check. `lake exe cache get` after a clone or
  toolchain change. Never `lake update` casually: it moves the CSLib and
  Mathlib pins (log a pin change in `docs/DESIGN.md`).
- `bash scripts/sorry_census.sh`, `lake env lean scripts/AxiomAudit.lean`.
- Lean MCP (`.mcp.json`, lean-lsp-mcp via uvx): prefer `lean_goal`,
  `lean_diagnostic_messages`, `lean_hover_info`, `lean_leansearch`,
  `lean_loogle` over repeated `lake build` while iterating.
