#!/usr/bin/env bash
set -euo pipefail

BASE_BRANCH="${BASE_BRANCH:-main}"
SOURCE_BRANCH="${SOURCE_BRANCH:-md}"
EXCLUDE_PATH="${EXCLUDE_PATH:-content}"

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

if git diff --quiet "${BASE_BRANCH}..${SOURCE_BRANCH}" -- . ":(exclude)${EXCLUDE_PATH}"; then
  echo "No non-content changes to sync from ${SOURCE_BRANCH} to ${BASE_BRANCH}."
  exit 0
fi

PATCH_FILE="$(mktemp -t sync-noncontent.XXXXXX.patch)"
cleanup() {
  rm -f "${PATCH_FILE}"
}
trap cleanup EXIT

git diff --binary "${BASE_BRANCH}..${SOURCE_BRANCH}" -- . ":(exclude)${EXCLUDE_PATH}" > "${PATCH_FILE}"

git switch "${BASE_BRANCH}" >/dev/null
git apply --index "${PATCH_FILE}"
git commit -m "sync: snapshot from ${SOURCE_BRANCH} (exclude ${EXCLUDE_PATH})"

echo "Synced non-content changes from ${SOURCE_BRANCH} to ${BASE_BRANCH}."
