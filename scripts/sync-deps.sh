#!/usr/bin/env bash
set -euo pipefail

BASE_BRANCH="${BASE_BRANCH:-main}"
SOURCE_BRANCH="${SOURCE_BRANCH:-md}"

ALLOWED_FILES=(
  "package.json"
  "pnpm-lock.yaml"
)

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository." >&2
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree not clean. Commit or stash first." >&2
  exit 1
fi

if ! git show-ref --verify --quiet "refs/heads/${BASE_BRANCH}"; then
  echo "Missing local branch: ${BASE_BRANCH}" >&2
  exit 1
fi

if ! git show-ref --verify --quiet "refs/heads/${SOURCE_BRANCH}"; then
  echo "Missing local branch: ${SOURCE_BRANCH}" >&2
  exit 1
fi

mapfile -t COMMITS < <(git rev-list --reverse "${BASE_BRANCH}..${SOURCE_BRANCH}" -- "${ALLOWED_FILES[@]}")

if [ "${#COMMITS[@]}" -eq 0 ]; then
  echo "No dependency commits to cherry-pick from ${SOURCE_BRANCH} to ${BASE_BRANCH}."
  exit 0
fi

allowed_set() {
  local f
  for f in "${ALLOWED_FILES[@]}"; do
    if [ "$f" = "$1" ]; then
      return 0
    fi
  done
  return 1
}

for commit in "${COMMITS[@]}"; do
  while read -r file; do
    if ! allowed_set "$file"; then
      echo "Commit ${commit} touches non-dependency file: ${file}" >&2
      echo "Split dependency changes into their own commit before syncing." >&2
      exit 1
    fi
  done < <(git diff --name-only "${commit}^" "${commit}")
done

git switch "${BASE_BRANCH}" >/dev/null
git cherry-pick "${COMMITS[@]}"

echo "Cherry-picked ${#COMMITS[@]} dependency commit(s) onto ${BASE_BRANCH}."
