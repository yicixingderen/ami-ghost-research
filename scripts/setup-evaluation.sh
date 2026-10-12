#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE=e0478ef7e280fe63f8f6932a3fd5d94ef1730ba3
PATCH="$ROOT/patches/evaluation.patch"

git -C "$ROOT" submodule update --init evaluation
if [ "$(git -C "$ROOT/evaluation" rev-parse HEAD)" != "$BASE" ]; then
    echo "evaluation must be at $BASE" >&2
    exit 1
fi

if git -C "$ROOT/evaluation" apply --reverse --check "$PATCH" >/dev/null 2>&1; then
    echo "evaluation patch is already applied"
    exit 0
fi
if [ -n "$(git -C "$ROOT/evaluation" status --porcelain)" ]; then
    echo "evaluation has other local changes; refusing to apply patch" >&2
    exit 1
fi

git -C "$ROOT/evaluation" apply --check "$PATCH"
git -C "$ROOT/evaluation" apply "$PATCH"
echo "evaluation patch applied"
