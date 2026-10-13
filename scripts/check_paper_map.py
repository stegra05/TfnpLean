#!/usr/bin/env python3
"""Check docs/PAPER_MAP.md against the library.

Rules:
  * status is one of: planned, on paper, drafted, checked, reviewed
  * a row with status checked or reviewed names a Lean declaration, and that
    declaration's last name component appears in TfnpLean/Tests/ (an example
    or a must-fail case exists for it)
  * every named declaration exists somewhere under TfnpLean/
Exit 1 on any violation. Runs in CI.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MAP = ROOT / "docs" / "PAPER_MAP.md"
STATUSES = {"planned", "on paper", "drafted", "checked", "reviewed"}


def main() -> None:
    lib = "\n".join(p.read_text(encoding="utf-8") for p in (ROOT / "TfnpLean").rglob("*.lean"))
    tests = "\n".join(p.read_text(encoding="utf-8") for p in (ROOT / "TfnpLean" / "Tests").rglob("*.lean"))
    problems = []
    rows = 0
    for line in MAP.read_text(encoding="utf-8").splitlines():
        if not line.startswith("|") or line.startswith("|---") or line.startswith("| Paper item"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 4:
            continue
        rows += 1
        item, decl, _file, status = cells[0], cells[1].strip("`"), cells[2], cells[3]
        status_word = status.split(",")[0].split("(")[0].strip()
        if status_word not in STATUSES and not status_word.startswith("out of scope"):
            problems.append(f"unknown status '{status}' for: {item}")
        if decl:
            short = decl.split(".")[-1]
            if not re.search(r"\b" + re.escape(short) + r"\b", lib):
                problems.append(f"declaration not found in library: {decl} ({item})")
            if status_word in ("checked", "reviewed") and not re.search(r"\b" + re.escape(short) + r"\b", tests):
                problems.append(f"status '{status_word}' but no test mentions {decl} ({item})")
        elif status_word in ("checked", "reviewed"):
            problems.append(f"status '{status_word}' without a declaration: {item}")
    if problems:
        print("\n".join(problems))
        sys.exit(1)
    print(f"paper map ok ({rows} rows)")


if __name__ == "__main__":
    main()
