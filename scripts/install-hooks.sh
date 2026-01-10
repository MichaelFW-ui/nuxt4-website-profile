#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -f "${ROOT_DIR}/.githooks/pre-push" ]; then
  echo "Missing ${ROOT_DIR}/.githooks/pre-push" >&2
  exit 1
fi

git -C "${ROOT_DIR}" config core.hooksPath .githooks
chmod +x "${ROOT_DIR}/.githooks/pre-push"

echo "Git hooks installed: core.hooksPath=.githooks"
