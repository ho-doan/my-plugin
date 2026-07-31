#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DST="$HOME/.codex/plugins/codex-ticket-workflow"
BACKUP_ROOT="$HOME/.codex/plugin-backups/codex-ticket-workflow"

if [ ! -d "$BACKUP_ROOT" ]; then
  echo "No backup directory found: $BACKUP_ROOT" >&2
  exit 1
fi

LATEST="$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"
if [ -z "$LATEST" ]; then
  echo "No plugin backup found." >&2
  exit 1
fi

rm -rf "$PLUGIN_DST"
cp -R "$LATEST" "$PLUGIN_DST"
echo "Rolled back plugin from: $LATEST"
echo "Restart Codex / ChatGPT desktop."
