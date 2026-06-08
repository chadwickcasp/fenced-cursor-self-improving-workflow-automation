#!/usr/bin/env bash
# Install fenced Cursor workflow automation into a target git repo.
# Usage: ./scripts/install-to-project.sh /path/to/your/project [cursor-project-slug] \
#          [--templates-path DIR] [--context-path DIR]
set -euo pipefail

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$KIT_ROOT/template"
TARGET=""
SLUG=""
TEMPLATES_PATH=""
CONTEXT_PATH=""

usage() {
  echo "Usage: $0 /path/to/target/repo [cursor-project-slug] [--templates-path DIR] [--context-path DIR]" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --templates-path)
      TEMPLATES_PATH="${2:?--templates-path requires a directory}"
      shift 2
      ;;
    --context-path)
      CONTEXT_PATH="${2:?--context-path requires a directory}"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      if [[ -z "$TARGET" ]]; then
        TARGET="$1"
      elif [[ -z "$SLUG" && "$1" != --* ]]; then
        SLUG="$1"
      else
        echo "Unknown argument: $1" >&2
        usage
      fi
      shift
      ;;
  esac
done

[[ -n "$TARGET" ]] || usage

if [[ ! -d "$TARGET" ]]; then
  echo "Target directory does not exist: $TARGET" >&2
  exit 1
fi

echo "Installing workflow kit into: $TARGET"

# Merge .cursor tree (does not delete existing rules you already have)
mkdir -p "$TARGET/.cursor"
rsync -a \
  --exclude '__pycache__' \
  --exclude '*.pyc' \
  "$TEMPLATE/.cursor/" "$TARGET/.cursor/"

PATHS_FILE="$TARGET/.cursor/workflow-paths.json"
PATHS_EXAMPLE="$TARGET/.cursor/workflow-paths.example.json"
if [[ ! -f "$PATHS_FILE" ]]; then
  if [[ -f "$PATHS_EXAMPLE" ]]; then
    cp "$PATHS_EXAMPLE" "$PATHS_FILE"
    echo "  + .cursor/workflow-paths.json (from example)"
  fi
fi

if [[ -f "$PATHS_FILE" && ( -n "$TEMPLATES_PATH" || -n "$CONTEXT_PATH" ) ]]; then
  python3 - "$PATHS_FILE" "$TEMPLATES_PATH" "$CONTEXT_PATH" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
templates = sys.argv[2]
context = sys.argv[3]
data = json.loads(path.read_text(encoding="utf-8"))
dirs = data.get("directories", [])
for entry in dirs:
    eid = entry.get("id")
    if eid == "workflow_templates" and templates:
        entry["path"] = templates
    if eid == "automation_context" and context:
        entry["path"] = context
path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY
  [[ -n "$TEMPLATES_PATH" ]] && echo "  + workflow-paths: workflow_templates -> $TEMPLATES_PATH"
  [[ -n "$CONTEXT_PATH" ]] && echo "  + workflow-paths: automation_context -> $CONTEXT_PATH"
fi

# Docs stubs (skip if already present)
mkdir -p "$TARGET/docs"
for f in feature-plan.md experiment-log.md decision-log.md; do
  if [[ ! -f "$TARGET/docs/$f" ]]; then
    cp "$TEMPLATE/docs/$f" "$TARGET/docs/$f"
    echo "  + docs/$f"
  else
    echo "  = docs/$f (kept existing)"
  fi
done

# AGENTS.md
if [[ ! -f "$TARGET/AGENTS.md" ]]; then
  cp "$TEMPLATE/AGENTS.md" "$TARGET/AGENTS.md"
  echo "  + AGENTS.md"
else
  echo "  = AGENTS.md (kept existing — merge Cursor workflow section manually)"
fi

# Optional: set project slug in workflow_common.py
HOOKS_PY="$TARGET/.cursor/hooks/workflow_common.py"
if [[ -n "$SLUG" ]]; then
  if [[ "$(uname)" == Darwin ]]; then
    sed -i '' "s/REPLACE_WITH_YOUR_CURSOR_PROJECT_SLUG/$SLUG/" "$HOOKS_PY"
  else
    sed -i "s/REPLACE_WITH_YOUR_CURSOR_PROJECT_SLUG/$SLUG/" "$HOOKS_PY"
  fi
  echo "  + set DEFAULT_PROJECT_SLUG to: $SLUG"
else
  echo "  ! Set DEFAULT_PROJECT_SLUG in .cursor/hooks/workflow_common.py"
  echo "    (find slug: ls ~/.cursor/projects/ after opening repo in Cursor)"
fi

chmod +x "$TARGET/.cursor/hooks/"*.sh 2>/dev/null || true

echo ""
echo "Next steps:"
echo "  1. Edit $TARGET/.cursor/workflow-paths.json (external artifact directories)"
echo "  2. Merge gitignore.snippet into your .gitignore (see template/gitignore.snippet)"
echo "  3. Open $TARGET in Cursor — hooks load from .cursor/hooks.json"
echo "  4. Optional launchd: see template/.cursor/launchd/README.md"
echo "  5. Test: python3 $TARGET/.cursor/hooks/daily_workflow_digest.py --catch-up"
echo "  6. Test: /usr/bin/python3 $TARGET/.cursor/hooks/monday_workflow_suggestions.py --due"
