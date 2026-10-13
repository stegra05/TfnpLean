#!/usr/bin/env python3
"""Append one LLM-interaction record to the private interaction log.

Hooks record the objective events (prompts, edits, builds). This records the
judgment: what the model was asked, how it went, how much human fixing it
took, and whether a definition changed. The Stop hook refuses to end a
session with Lean edits and no record.

Example:
  python3 scripts/log_interaction.py --task definition \
    --target TfnpLean.PureCircuit.Instance --model claude-fable-5-1 \
    --outcome after_repair --attempts 2 --fix-min 10 \
    --notes "Fin n for nodes; distinctness as a field (DESIGN D7)"
"""
import argparse
import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WORKSPACE = ROOT.parent
LOGS = (WORKSPACE / "notes" / "ai-logs") if (WORKSPACE / "notes").is_dir() else (ROOT / ".ai-logs")

TASKS = ["definition", "statement", "test", "proof", "repair", "refactor", "search", "infra", "docs"]
OUTCOMES = ["unaided", "after_repair", "human_finished", "failed"]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--task", required=True, choices=TASKS)
    parser.add_argument("--target", required=True, help="Lean declaration or file")
    parser.add_argument("--model", required=True, help="exact model id, e.g. claude-fable-5-1")
    parser.add_argument("--outcome", required=True, choices=OUTCOMES,
                        help="unaided = compiled first try; after_repair = after repair loops; "
                             "human_finished = Steffen completed or corrected it; failed = abandoned")
    parser.add_argument("--attempts", type=int, default=1, help="builds run including the first")
    parser.add_argument("--fix-min", type=float, default=None, help="human minutes fixing model output")
    parser.add_argument("--definition-changed", action="store_true",
                        help="a definition or statement file changed meaning in this task")
    parser.add_argument("--notes", default="")
    args = parser.parse_args()

    session = ""
    current = LOGS / ".current_session"
    if current.exists():
        session = current.read_text(encoding="utf-8").strip()

    rec = {
        "ts": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "session": session,
        "task": args.task,
        "target": args.target,
        "model": args.model,
        "outcome": args.outcome,
        "attempts": args.attempts,
        "fix_min": args.fix_min,
        "definition_changed": args.definition_changed,
        "notes": args.notes,
    }
    LOGS.mkdir(parents=True, exist_ok=True)
    with (LOGS / "interactions.jsonl").open("a", encoding="utf-8") as f:
        f.write(json.dumps(rec, ensure_ascii=False) + "\n")
    print(f"logged: {rec['task']} {rec['target']} -> {rec['outcome']}")


if __name__ == "__main__":
    main()
