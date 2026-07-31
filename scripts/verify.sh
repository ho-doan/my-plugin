#!/usr/bin/env bash
set -euo pipefail

PLUGIN="${1:-$HOME/.codex/plugins/codex-ticket-workflow}"
test -f "$PLUGIN/.codex-plugin/plugin.json"
test -f "$PLUGIN/skills/ticket-workflow-orchestrator/SKILL.md"
test -f "$PLUGIN/assets/flows/manifest.yaml"
test -f "$PLUGIN/assets/skills-lock.yaml"

python3 - "$PLUGIN/.codex-plugin/plugin.json" <<'PY'
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
assert data["name"] == "codex-ticket-workflow"
assert data["version"]
assert data["skills"] == "./skills/"
print(f'Plugin OK: {data["name"]}@{data["version"]}')
PY
