#!/usr/bin/env bash
set -euo pipefail

BASE_BRANCH="${BASE_BRANCH:-main}"
SOURCE_BRANCH="${SOURCE_BRANCH:-md}"
EXCLUDE_PATHS="${EXCLUDE_PATHS:-${EXCLUDE_PATH:-content} public}"

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

if [ "${BASE_BRANCH}" = "${SOURCE_BRANCH}" ]; then
  echo "BASE_BRANCH and SOURCE_BRANCH must be different." >&2
  exit 1
fi

exclude_args=()
for path in ${EXCLUDE_PATHS}; do
  exclude_args+=(":(exclude)${path}")
done

if git diff --quiet "${BASE_BRANCH}..${SOURCE_BRANCH}" -- . "${exclude_args[@]}"; then
  echo "No non-content changes to sync from ${SOURCE_BRANCH} to ${BASE_BRANCH}."
  exit 0
fi

PATCH_FILE="$(mktemp -t sync-noncontent.XXXXXX.patch)"
cleanup() {
  rm -f "${PATCH_FILE}"
}
trap cleanup EXIT

git diff --binary "${BASE_BRANCH}..${SOURCE_BRANCH}" -- . "${exclude_args[@]}" > "${PATCH_FILE}"

git switch "${BASE_BRANCH}" >/dev/null
git apply --index "${PATCH_FILE}"
git commit -m "sync: snapshot from ${SOURCE_BRANCH} (exclude ${EXCLUDE_PATHS})"

echo "Synced non-content changes from ${SOURCE_BRANCH} to ${BASE_BRANCH}."
