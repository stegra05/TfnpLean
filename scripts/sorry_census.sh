#!/usr/bin/env bash
# Counts `sorry` in the library, total and per file. Exit code is always 0:
# sorries in statements are the work queue, not an error.
set -u
cd "$(dirname "$0")/.."
total=$(grep -rEo '\bsorry\b' --include='*.lean' TfnpLean TfnpLean.lean 2>/dev/null | wc -l | tr -d ' ')
echo "### Sorry census: $total"
echo '```'
grep -rEc '\bsorry\b' --include='*.lean' TfnpLean 2>/dev/null | grep -v ':0$' || echo "(none)"
echo '```'
