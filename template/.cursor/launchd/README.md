# launchd — workflow automation backup

Runs scheduled hooks when Cursor may not be open. Logs append to
`.cursor/workflow-review/launchd.log` (gitignored in the target project).

| Job | Schedule | Command |
|-----|----------|---------|
| `com.fenced.cursor-daily-digest` | Daily 06:00 | `daily_workflow_digest.py --catch-up` |
| `com.fenced.cursor-monday-suggestions` | Monday 09:00 | `monday_workflow_suggestions.py --due` |

## Install (once per machine)

Replace `REPO_ROOT_PLACEHOLDER` with your **target project** repo path, then:

```bash
REPO="/path/to/your/project"

for label in com.fenced.cursor-daily-digest com.fenced.cursor-monday-suggestions; do
  sed "s|REPO_ROOT_PLACEHOLDER|$REPO|g" "$REPO/.cursor/launchd/${label}.plist" \
    > ~/Library/LaunchAgents/${label}.plist
  launchctl load ~/Library/LaunchAgents/${label}.plist
done
```

## Manual test (launchd-equivalent, any time)

```bash
REPO="/path/to/your/project"
/usr/bin/python3 "$REPO/.cursor/hooks/daily_workflow_digest.py" --catch-up
/usr/bin/python3 "$REPO/.cursor/hooks/monday_workflow_suggestions.py" --due
```

## Uninstall

```bash
for label in com.fenced.cursor-daily-digest com.fenced.cursor-monday-suggestions; do
  launchctl unload ~/Library/LaunchAgents/${label}.plist 2>/dev/null || true
  rm -f ~/Library/LaunchAgents/${label}.plist
done
```
