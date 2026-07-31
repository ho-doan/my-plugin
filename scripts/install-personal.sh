#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_SRC="$ROOT/plugins/codex-ticket-workflow"
PLUGIN_DST="$HOME/.codex/plugins/codex-ticket-workflow"
MARKETPLACE_DIR="$HOME/.agents/plugins"
MARKETPLACE_FILE="$MARKETPLACE_DIR/marketplace.json"
BACKUP_ROOT="$HOME/.codex/plugin-backups/codex-ticket-workflow"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$HOME/.codex/plugins" "$MARKETPLACE_DIR" "$BACKUP_ROOT"

if [ -d "$PLUGIN_DST" ]; then
  cp -R "$PLUGIN_DST" "$BACKUP_ROOT/$STAMP"
  echo "Backed up current plugin to: $BACKUP_ROOT/$STAMP"
fi

rm -rf "$PLUGIN_DST"
cp -R "$PLUGIN_SRC" "$PLUGIN_DST"

python3 - "$MARKETPLACE_FILE" <<'PY'
import json, sys
from pathlib import Path

path = Path(sys.argv[1])
entry = {
    "name": "codex-ticket-workflow",
    "source": {
        "source": "local",
        "path": "./.codex/plugins/codex-ticket-workflow"
    },
    "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
    },
    "category": "Productivity"
}

if path.exists():
    try:
        data = json.loads(path.read_text())
    except Exception:
        backup = path.with_suffix(path.suffix + ".invalid-backup")
        path.replace(backup)
        data = {}
else:
    data = {}

data.setdefault("name", "personal-codex-plugins")
data.setdefault("interface", {"displayName": "Personal Codex Plugins"})
plugins = data.setdefault("plugins", [])
plugins[:] = [p for p in plugins if p.get("name") != entry["name"]]
plugins.append(entry)
path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
PY

echo "Installed codex-ticket-workflow to: $PLUGIN_DST"
echo "Marketplace updated: $MARKETPLACE_FILE"
echo "Restart Codex / ChatGPT desktop, then install the plugin from your personal marketplace."
