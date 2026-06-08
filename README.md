# Fenced Cursor self-improving workflow automation

A **portable kit** for Cursor projects: daily transcript digests, weekly approval-gated rule reviews, and Monday workflow suggestion stubs with a viewed queue.

**Fenced** = automation proposes changes; you approve before `AGENTS.md` or `.cursor/rules` are edited.

## What is in this repo

| Path | Purpose |
|------|---------|
| [`template/.cursor/hooks/`](template/.cursor/hooks/) | Python + shell hooks (`sessionStart`, `stop`, `afterAgentResponse`) |
| [`template/.cursor/hooks.json`](template/.cursor/hooks.json) | Cursor hook registration |
| [`template/.cursor/workflow-review/`](template/.cursor/workflow-review/) | Daily digests → weekly `latest.md` |
| [`template/.cursor/workflow-suggestions/`](template/.cursor/workflow-suggestions/) | Monday stubs + `KICKOFF.md` |
| [`template/.cursor/launchd/`](template/.cursor/launchd/) | Optional macOS schedules (06:00 daily, Mon 09:00) |
| [`template/.cursor/rules/`](template/.cursor/rules/) | Core Cursor rules (`00`, `30`) + optional ML examples |
| [`template/AGENTS.md`](template/AGENTS.md) | Starter agent contract |
| [`template/docs/`](template/docs/) | `feature-plan`, `experiment-log`, `decision-log` stubs |
| [`scripts/install-to-project.sh`](scripts/install-to-project.sh) | Copy kit into another repo |
| [`template/.cursor/workflow-paths.example.json`](template/.cursor/workflow-paths.example.json) | External artifact directories (copied to `workflow-paths.json` on install) |

Ephemeral outputs (gitignored in target projects): `workflow-review/daily/`, `latest.md`, `agent-workflow-state.json`, `workflow-suggestions/queue.json`, `workflow-paths.json` (when machine-local).

## Quick start: install into a project

```bash
cd /path/to/fenced-cursor-self-improving-workflow-automation

# 1. Install files into your repo
./scripts/install-to-project.sh "/path/to/your/project" "Your-Cursor-Project-Slug" \
  --templates-path "/path/to/templates" \
  --context-path "/path/to/context"

# 2. Edit .cursor/workflow-paths.json if you skipped the flags above

# 3. Append template/gitignore.snippet to your project .gitignore

# 4. Open the project in Cursor (hooks reload from .cursor/hooks.json)
```

### Find your Cursor project slug

After opening the repo in Cursor once:

```bash
ls ~/.cursor/projects/
```

Use the folder name that matches your workspace under `~/.cursor/projects/`. Pass it as the second argument to `install-to-project.sh`, or set `CURSOR_PROJECT_SLUG` in the environment.

## How it runs

```text
Daily 06:00 (launchd)     → yesterday's digest (if Cursor was closed)
Monday 09:00 (launchd)    → new *-monday.md stub + unviewed queue entry
sessionStart              → catch-up digest, Monday nudge, pending weekly review
Agent chat + KICKOFF.md   → 1 big + 3 small proposals (your review)
afterAgentResponse + stop → mark suggestion viewed when headings delivered
Weekly (7+ dailies)       → latest.md rule draft → you say yes / no / edit
```

| You do | Automation does |
|--------|-----------------|
| Open Cursor | `sessionStart` catch-up + nudges |
| Agent kickoff chat | Proposals in chat (see `KICKOFF.md`) |
| Say **yes / no / edit** on weekly draft | Rule changes only after approval |
| `launchctl load` (optional) | Scheduled digest + Monday stub |

**Ask mode** does not run `stop` / `afterAgentResponse` — use **Agent mode** for kickoff and weekly follow-ups.

## Manual commands (in target project)

```bash
REPO="/path/to/your/project"

# Daily
python3 "$REPO/.cursor/hooks/daily_workflow_digest.py" --catch-up
python3 "$REPO/.cursor/hooks/daily_workflow_digest.py" --backfill-days 2 --force

# Monday (launchd-equivalent)
/usr/bin/python3 "$REPO/.cursor/hooks/monday_workflow_suggestions.py" --due

# Weekly rule review stub
python3 "$REPO/.cursor/hooks/weekly_workflow_report.py" --write-stub --force

# After you approve weekly changes in chat
python3 "$REPO/.cursor/hooks/weekly_workflow_report.py" --finalize-approval

# Fallback: mark Monday suggestion viewed
/usr/bin/python3 "$REPO/.cursor/hooks/monday_workflow_suggestions.py" --mark-viewed YYYY-MM-DD
```

## Customize for your project

1. **`.cursor/workflow-paths.json`** — external directories for Monday kickoff (templates, context, etc.); see `workflow-paths.example.json`
2. **`.cursor/hooks/workflow_common.py`** — `DEFAULT_PROJECT_SLUG`, `AREA_KEYWORDS`, `THEME_KEYWORDS`
3. **Rules** — copy optional rules from `template/.cursor/rules/examples/` into `rules/` and adjust globs
4. **`.cursor/workflow-review/sources.json`** — URLs for weekly appendix fetch (User-Agent is `{repo-folder}-workflow-review/1.0`)

## Monday kickoff test (full)

1. **Phase A:** `/usr/bin/python3 .../monday_workflow_suggestions.py --due`
2. **Phase B:** Agent chat using `template/.cursor/workflow-suggestions/KICKOFF.md` (required headings in reply)
3. **Phase C:** verify `queue.json` shows `viewed` after Agent run (auto via hooks)

See [`template/.cursor/workflow-suggestions/README.md`](template/.cursor/workflow-suggestions/README.md).

## GitHub

```bash
cd /path/to/fenced-cursor-self-improving-workflow-automation
git init
git add .
git commit -m "Initial fenced Cursor workflow automation kit"
# gh repo create fenced-cursor-self-improving-workflow-automation --private --source=. --push
```

## Provenance

See [PROVENANCE.md](PROVENANCE.md).

## Future improvements

See [FUTURE_IMPROVEMENTS.md](FUTURE_IMPROVEMENTS.md) for a backlog of possible kit enhancements (releases, in-Cursor updates, testing, install UX, and more).

## License

Copyright © Chadwick Casper.

Licensed under the [PolyForm Noncommercial License 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0). You may use, copy, modify, and distribute this kit for **noncommercial purposes** (personal, hobby, research, education, and similar uses). **Commercial use requires separate permission** from the licensor.

See [LICENSE](LICENSE) for the full text.
