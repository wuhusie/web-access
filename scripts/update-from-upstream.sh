#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir/.." rev-parse --show-toplevel)"
push_after=false

if [[ "${1:-}" == "--push" ]]; then
  push_after=true
elif [[ $# -gt 0 ]]; then
  echo "Usage: $0 [--push]" >&2
  exit 2
fi

if ! git -C "$repo_root" diff --quiet || ! git -C "$repo_root" diff --cached --quiet; then
  echo "Refusing to update: the web-access worktree has uncommitted changes." >&2
  exit 1
fi

branch="$(git -C "$repo_root" branch --show-current)"
if [[ -z "$branch" ]]; then
  echo "Refusing to update from a detached HEAD." >&2
  exit 1
fi

git -C "$repo_root" remote get-url upstream >/dev/null
git -C "$repo_root" fetch upstream
git -C "$repo_root" merge --no-edit upstream/main

if [[ "$push_after" == true ]]; then
  git -C "$repo_root" push origin "$branch"
else
  echo "Merged upstream/main into $branch. Test dependent skills, then run:" >&2
  echo "  $0 --push" >&2
fi
