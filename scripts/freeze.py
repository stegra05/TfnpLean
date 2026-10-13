#!/usr/bin/env python3
"""Freeze or unfreeze a definition file after supervisor review.

  python3 scripts/freeze.py TfnpLean/PureCircuit.lean            # freeze (records sha256)
  python3 scripts/freeze.py --unfreeze TfnpLean/PureCircuit.lean # allow edits again
  python3 scripts/freeze.py --check                              # verify all frozen files

Frozen files cannot be edited by Claude Code (PreToolUse gate) and a changed
hash blocks the session from ending and fails CI. Only Steffen runs this, and
an unfreeze gets a DESIGN.md entry saying why.
"""
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FROZEN = ROOT / "docs" / "frozen.json"


def load() -> dict:
    return json.loads(FROZEN.read_text(encoding="utf-8")) if FROZEN.exists() else {}


def save(d: dict) -> None:
    FROZEN.write_text(json.dumps(d, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def sha(r: str) -> str:
    return hashlib.sha256((ROOT / r).read_bytes()).hexdigest()


def main() -> None:
    args = sys.argv[1:]
    if args == ["--check"]:
        bad = [r for r, h in load().items() if not (ROOT / r).exists() or sha(r) != h]
        if bad:
            print("frozen files changed: " + ", ".join(bad))
            sys.exit(1)
        print(f"frozen files unchanged ({len(load())})")
        return
    unfreeze = "--unfreeze" in args
    files = [a for a in args if a != "--unfreeze"]
    if not files:
        print(__doc__)
        sys.exit(1)
    d = load()
    for r in files:
        if unfreeze:
            d.pop(r, None)
            print(f"unfrozen: {r} (log the reason in docs/DESIGN.md)")
        else:
            d[r] = sha(r)
            print(f"frozen: {r}")
    save(d)


if __name__ == "__main__":
    main()
