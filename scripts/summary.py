#!/usr/bin/env python3
"""Markdown summary of the private interaction and event logs.

Usage: python3 scripts/summary.py [--since YYYY-MM-DD]
Feeds the weekly mail and, later, the thesis chapter on working with LLMs.
"""
import argparse
import json
import re
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WORKSPACE = ROOT.parent
LOGS = (WORKSPACE / "notes" / "ai-logs") if (WORKSPACE / "notes").is_dir() else (ROOT / ".ai-logs")
OUTCOMES = ["unaided", "after_repair", "human_finished", "failed"]


def load(path: Path):
    if not path.exists():
        return []
    out = []
    for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        try:
            out.append(json.loads(line))
        except json.JSONDecodeError:
            continue
    return out


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--since", default=None, help="YYYY-MM-DD, inclusive")
    args = parser.parse_args()
    interactions = load(LOGS / "interactions.jsonl")
    events = load(LOGS / "events.jsonl")
    if args.since:
        interactions = [r for r in interactions if r.get("ts", "") >= args.since]
        events = [r for r in events if r.get("ts", "") >= args.since]

    print("## Interaction summary" + (f" (since {args.since})" if args.since else ""))
    print()
    if interactions:
        by = Counter((r["task"], r["outcome"]) for r in interactions)
        tasks = sorted({t for t, _ in by})
        print("| task | " + " | ".join(OUTCOMES) + " | total |")
        print("|---" * (len(OUTCOMES) + 2) + "|")
        for t in tasks:
            row = [by.get((t, o), 0) for o in OUTCOMES]
            print(f"| {t} | " + " | ".join(map(str, row)) + f" | {sum(row)} |")
        total = len(interactions)
        closed = sum(1 for r in interactions if r["outcome"] in ("unaided", "after_repair"))
        unaided = sum(1 for r in interactions if r["outcome"] == "unaided")
        fix = [r["fix_min"] for r in interactions if r.get("fix_min") is not None]
        defchg = sum(1 for r in interactions if r.get("definition_changed"))
        print()
        print(f"- {total} interactions; model-closed {closed} ({unaided} unaided, "
              f"{closed - unaided} after repair); {defchg} changed a definition")
        if fix:
            print(f"- human fix time: total {sum(fix):.0f} min, mean {sum(fix)/len(fix):.1f} min "
                  f"over {len(fix)} records")
    else:
        print("_no interaction records_")

    builds = [e for e in events if e.get("ev") == "bash"]
    edits = [e for e in events if e.get("ev") == "file_edit" and e.get("file", "").endswith(".lean")]
    prompts = [e for e in events if e.get("ev") == "prompt"]
    sessions = {e.get("session") for e in events if e.get("session")}
    print()
    print(f"- events: {len(prompts)} prompts, {len(edits)} lean edits, {len(builds)} lake runs "
          f"({sum(1 for b in builds if b.get('ok'))} clean) across {len(sessions)} sessions")
    per_file = {}
    for p in sorted((ROOT / "TfnpLean").rglob("*.lean")):
        n = len(re.findall(r"\bsorry\b", p.read_text(encoding="utf-8", errors="ignore")))
        if n:
            per_file[str(p.relative_to(ROOT))] = n
    print(f"- current sorries: {sum(per_file.values())}"
          + (f" ({', '.join(f'{k}: {v}' for k, v in per_file.items())})" if per_file else ""))


if __name__ == "__main__":
    main()
