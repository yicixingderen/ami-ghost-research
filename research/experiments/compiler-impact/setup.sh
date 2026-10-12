#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../../.." && pwd)"
PATCH="$HERE/evaluation-secret.patch"

bash "$ROOT/scripts/setup-evaluation.sh"
if git -C "$ROOT/evaluation" apply --reverse --check "$PATCH" >/dev/null 2>&1; then
    echo "secret annotations are already applied"
elif git -C "$ROOT/evaluation" apply --check "$PATCH"; then
    git -C "$ROOT/evaluation" apply "$PATCH"
    echo "secret annotations applied"
else
    echo "evaluation differs from the expected source; refusing to patch" >&2
    exit 1
fi
