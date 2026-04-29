#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISTRO_NAME="${1:-${DISTRO:-}}"

if [[ -z "$DISTRO_NAME" ]]; then
  echo "usage: bash launch.sh <distro>" >&2
  echo "or set DISTRO=<distro>" >&2
  exit 1
fi

exec bash "${SCRIPT_DIR}/../termux-superproot.sh" start "$DISTRO_NAME"
