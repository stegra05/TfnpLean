#!/usr/bin/env python3
"""Claude Code hook dispatcher for TfnpLean.

Wired as `hooks.py <event>` in this repo's .claude/settings.json and in the
workspace root's, so sessions launched in either place are logged; the
payload arrives as JSON on stdin. Edits outside this repo are ignored. A
hook failure must never break a session: every path exits 0 except the
deliberate gates, which exit 2 with a reason on stderr.

Logs live in the private workspace (../notes/ai-logs), never in this repo.
If that directory does not exist (repo cloned alone), logs go to .ai-logs/.

Events:
  session_start   record session, HEAD and a content snapshot of the rationale and
                  definition files, print notes/NOW.md as context
  prompt          full user prompt
  gate            PreToolUse on Edit/Write: definition gate + freeze gate
  file_edit       PostToolUse on Edit/Write: .lean edits (sorry count) and docs/*.md
  bash            PostToolUse on Bash: lake invocations with outcome; head_change
                  when a command moved this repo's HEAD (commit, checkout, reset)
  stop            sorry census and HEAD; blocks if (a) Lean edits without an interaction
                  record, (b) definition files changed without a DESIGN/PAPER_MAP change
                  (an Edit/Write event, or content that differs from the snapshot),
                  (c) a frozen definition changed
  session_end     record HEAD, copy the transcript to the log dir (and the backup mirror)
"""
import hashlib
import json
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WORKSPACE = ROOT.parent
LOGS = (WORKSPACE / "notes" / "ai-logs") if (WORKSPACE / "notes").is_dir() else (ROOT / ".ai-logs")
NOW_FILE = WORKSPACE / "notes" / "NOW.md"
BACKUP_MIRROR = Path.home() / "Library/Mobile Documents/com~apple~CloudDocs/Backups/bachelors/notes/ai-logs"
EVENTS = LOGS / "events.jsonl"
INTERACTIONS = LOGS / "interactions.jsonl"
LAST_HEAD = LOGS / ".head"
UNLOCKED = ROOT / "docs" / "UNLOCKED.md"
FROZEN = ROOT / "docs" / "frozen.json"
RATIONALE_FILES = {"docs/DESIGN.md", "docs/PAPER_MAP.md"}


def now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def append(rec: dict) -> None:
    LOGS.mkdir(parents=True, exist_ok=True)
    with EVENTS.open("a", encoding="utf-8") as f:
        f.write(json.dumps(rec, ensure_ascii=False) + "\n")


def head() -> str | None:
    """Current commit of this repo, linking session records to git history."""
    try:
        out = subprocess.run(["git", "-C", str(ROOT), "rev-parse", "HEAD"],
                             capture_output=True, text=True, timeout=5)
    except (OSError, subprocess.SubprocessError):
        return None
    return out.stdout.strip() or None


def record_head() -> str | None:
    """HEAD now, remembered so the bash hook can tell when a command moved it."""
    h = head()
    if h:
        LOGS.mkdir(parents=True, exist_ok=True)
        LAST_HEAD.write_text(h, encoding="utf-8")
    return h


def rel(path: str) -> str:
    """Path relative to this repo, or "" for files outside it."""
    try:
        return str(Path(path).resolve().relative_to(ROOT))
    except (ValueError, OSError):
        return ""


def is_definition_file(r: str) -> bool:
    """Library source that may hold definitions or statements: gated and logged."""
    return r.startswith("TfnpLean/") and r.endswith(".lean") and not r.startswith("TfnpLean/Tests/")


def count_sorries(text: str) -> int:
    return len(re.findall(r"\bsorry\b", text))


def sorry_census() -> dict:
    per_file = {}
    for p in sorted((ROOT / "TfnpLean").rglob("*.lean")):
        n = count_sorries(p.read_text(encoding="utf-8", errors="ignore"))
        if n:
            per_file[str(p.relative_to(ROOT))] = n
    return per_file


def unlocked() -> set:
    if not UNLOCKED.exists():
        return set()
    out = set()
    for line in UNLOCKED.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line.startswith("- "):
            out.add(line[2:].strip().strip("`"))
    return out


def frozen() -> dict:
    if not FROZEN.exists():
        return {}
    try:
        return json.loads(FROZEN.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return {}


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def frozen_violations() -> list:
    out = []
    for r, h in frozen().items():
        p = ROOT / r
        if not p.exists() or sha(p) != h:
            out.append(r)
    return out


def session_records(path: Path, sid: str) -> list:
    if not path.exists() or not sid:
        return []
    out = []
    for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        try:
            rec = json.loads(line)
        except json.JSONDecodeError:
            continue
        if rec.get("session") == sid:
            out.append(rec)
    return out


def tracked_files() -> set:
    """Files whose content the stop gate compares: rationale files and definition files."""
    defs = {str(p.relative_to(ROOT)) for p in (ROOT / "TfnpLean").rglob("*.lean")}
    return RATIONALE_FILES | {r for r in defs if is_definition_file(r)}


def snapshot() -> dict:
    """Content hash per tracked file, taken at session start."""
    return {r: sha(ROOT / r) for r in sorted(tracked_files()) if (ROOT / r).exists()}


def changed_since_start(evs: list) -> set:
    """Tracked files whose content differs from the session-start snapshot, whatever tool
    changed them (Edit/Write, the shell, an editor). Empty if the session has no snapshot."""
    snaps = [e["snapshot"] for e in evs if e.get("ev") == "session_start" and "snapshot" in e]
    if not snaps:
        return set()
    before, after = snaps[0], snapshot()
    return {r for r in before.keys() | after.keys() if before.get(r) != after.get(r)}


def gate(payload: dict) -> None:
    """PreToolUse: deny edits to gated library files unless unlocked, never if frozen."""
    file_path = (payload.get("tool_input") or {}).get("file_path") or ""
    if not file_path:
        return
    r = rel(file_path)
    if not is_definition_file(r):
        return
    if r in frozen():
        sys.stderr.write(
            f"FROZEN: {r} was reviewed by the supervisor and is frozen. Never weaken a "
            "definition to make a proof pass. If the change is intended, Steffen runs "
            f"`python3 scripts/freeze.py --unfreeze {r}` and logs the reason in docs/DESIGN.md.\n")
        sys.exit(2)
    if "*" not in unlocked() and r not in unlocked():
        sys.stderr.write(
            f"LOCKED: {r} is a definition or statement file. Definitions are written together "
            "with Steffen after the paper check (docs/CHECKING.md). He unlocks a file by adding "
            "`- " + r + "` to docs/UNLOCKED.md. Do not work around this gate.\n")
        sys.exit(2)


def block_stop(reason: str) -> None:
    print(json.dumps({"decision": "block", "reason": reason}))


def stop(sid: str, payload: dict) -> None:
    per_file = sorry_census()
    append({"ts": now(), "ev": "stop", "session": sid, "head": record_head(),
            "total_sorries": sum(per_file.values()), "sorries": per_file})
    if payload.get("stop_hook_active"):
        return
    bad = frozen_violations()
    if bad:
        block_stop("Frozen definition files changed on disk: " + ", ".join(bad) +
                   ". Revert them (git checkout -- <file>) or have Steffen unfreeze them "
                   "with scripts/freeze.py --unfreeze. Then stop again.")
        return
    evs = session_records(EVENTS, sid)
    lean_edits = [e for e in evs if e.get("ev") == "file_edit" and e.get("file", "").endswith(".lean")]
    changed = changed_since_start(evs)
    def_changed = ({e["file"] for e in lean_edits if is_definition_file(e.get("file", ""))} |
                   {r for r in changed if is_definition_file(r)})
    rationale_touched = (any(e.get("ev") == "file_edit" and e.get("file") in RATIONALE_FILES
                             for e in evs) or bool(changed & RATIONALE_FILES))
    logged = session_records(INTERACTIONS, sid)
    if def_changed and not rationale_touched:
        block_stop("Definition or statement files were edited (" +
                   ", ".join(sorted(def_changed)) +
                   ") but docs/DESIGN.md and docs/PAPER_MAP.md were not touched. Every modelling "
                   "choice gets a DESIGN.md entry (decision, paper reference, encoding, rejected "
                   "alternative, why) and PAPER_MAP.md gets its status updated. Do that, then stop.")
        return
    if lean_edits and not logged:
        block_stop("Lean files were edited this session but no interaction record was logged. "
                   "For each distinct task run: python3 scripts/log_interaction.py --task "
                   "<definition|statement|test|proof|repair|refactor|search|infra|docs> "
                   "--target <decl-or-file> --model <exact-model-id> --outcome "
                   "<unaided|after_repair|human_finished|failed> --attempts <n> "
                   "[--definition-changed] [--fix-min <min>] [--notes '...']. Then stop.")


def main() -> None:
    event = sys.argv[1]
    try:
        payload = json.load(sys.stdin)
    except Exception:
        payload = {}
    sid = (payload.get("session_id") or "")[:8]
    rec = {"ts": now(), "ev": event, "session": sid}

    if event == "gate":
        gate(payload)
        return

    if event == "session_start":
        rec.update(source=payload.get("source"), head=record_head(), snapshot=snapshot())
        LOGS.mkdir(parents=True, exist_ok=True)
        if NOW_FILE.exists():
            print("Current focus (notes/NOW.md):\n" + NOW_FILE.read_text(encoding="utf-8").strip())

    elif event == "prompt":
        prompt = payload.get("prompt") or ""
        rec.update(prompt=prompt, prompt_len=len(prompt))
        if NOW_FILE.exists():
            for line in NOW_FILE.read_text(encoding="utf-8").splitlines():
                if line.startswith("Step:"):
                    print("[NOW] " + line)
                    break

    elif event == "file_edit":
        file_path = (payload.get("tool_input") or {}).get("file_path") or ""
        r = rel(file_path)
        if not (r.endswith(".lean") or r.startswith("docs/")):
            return
        rec.update(file=r, tool=payload.get("tool_name"), definition_file=is_definition_file(r))
        if r.endswith(".lean"):
            try:
                rec["sorries"] = count_sorries(Path(file_path).read_text(encoding="utf-8", errors="ignore"))
            except OSError:
                rec["sorries"] = None

    elif event == "bash":
        cmd = (payload.get("tool_input") or {}).get("command") or ""
        before = LAST_HEAD.read_text(encoding="utf-8") if LAST_HEAD.exists() else None
        after = record_head()
        if after and after != before:
            append({"ts": now(), "ev": "head_change", "session": sid, "cmd": cmd[:300],
                    "before": before, "head": after})
        if not re.search(r"\blake\b", cmd):
            return
        resp = str(payload.get("tool_response") or "")
        rec.update(cmd=cmd[:300], errors=resp.count("error"),
                   ok="Build completed successfully" in resp)

    elif event == "stop":
        stop(sid, payload)
        return

    elif event == "session_end":
        rec.update(reason=payload.get("reason"), head=record_head())
        transcript = payload.get("transcript_path")
        if transcript and Path(transcript).exists():
            name = f"{now()[:10]}-{sid or 'unknown'}.jsonl"
            dest = LOGS / "transcripts" / name
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(transcript, dest)
            rec["transcript"] = str(dest)
            if BACKUP_MIRROR.parent.parent.exists():
                mirror = BACKUP_MIRROR / "transcripts" / name
                mirror.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(transcript, mirror)

    append(rec)


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception as exc:
        try:
            LOGS.mkdir(parents=True, exist_ok=True)
            with (LOGS / "hook_errors.log").open("a", encoding="utf-8") as f:
                f.write(f"{now()} {sys.argv[1:]} {exc!r}\n")
        except Exception:
            pass
    sys.exit(0)
