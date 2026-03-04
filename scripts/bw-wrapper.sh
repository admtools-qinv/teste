#!/bin/bash
# Bitwarden secure wrapper for OpenClaw
# Usage: bw-wrapper.sh get <item-name> [field]
# Never logs output. Always masks in terminal.

set -euo pipefail

if [ -z "${BW_SESSION:-}" ]; then
  echo "ERROR: BW_SESSION not set. Run: export BW_SESSION=\$(bw unlock --raw)"
  exit 1
fi

ACTION="${1:-}"
ITEM="${2:-}"
FIELD="${3:-password}"

case "$ACTION" in
  get)
    bw get "$FIELD" "$ITEM" 2>/dev/null
    ;;
  list)
    bw list items --search "$ITEM" 2>/dev/null | jq '.[].name'
    ;;
  *)
    echo "Usage: bw-wrapper.sh get|list <item> [field]"
    exit 1
    ;;
esac
