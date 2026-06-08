# Future improvements

Possible enhancements for the **fenced Cursor workflow kit** (this distributable template), not a running application. Work splits into two tracks:

- **Kit track** — make the template releasable, versioned, and updatable after `install-to-project.sh`
- **Installed workflow track** — make the hooks smarter once the kit lives in a target project

Suggested priority at the bottom.

---

## Release, versioning, and in-Cursor updates

Today there is no version manifest, changelog, CI, or update path after the initial install.

| Improvement | Rationale |
|-------------|-----------|
| **`VERSION` or `template/.cursor/workflow-kit.json`** | Record kit semver and source repo URL; install script writes `installed_version` into target state |
| **GitHub Releases + tagged artifacts** | CI builds a `.tar.gz` of `template/` + `scripts/` per tag; optional checksums |
| **Release gate workflow** | GitHub Action: run tests → bump version → generate `CHANGELOG.md` → create release only on tag push |
| **`check-for-updates` hook/script** | On `sessionStart`, compare installed version to GitHub Releases API (`/releases/latest`) |
| **Fenced update prompt in Cursor** | If a newer release exists, inject `additional_context`: “Kit v0.3.0 available. Update? (yes / no / show diff)” |
| **`upgrade-kit.sh`** | Merge strategy: rsync new template files but **preserve** user-owned state (`workflow-paths.json`, customized rules, `queue.json`, dailies) |
| **Diff preview before upgrade** | Show what would change in `.cursor/hooks/` vs user-local files |
| **Pin or channel support** | `stable` vs `main`; some adopters may want to stay on a known version |

**Design choice:** updates should overwrite hook Python but **never** silently overwrite customized `AGENTS.md`, rules, or gitignored state.

---

## Install and bootstrap

Several steps are still manual and error-prone.

| Improvement | Rationale |
|-------------|-----------|
| **Auto-detect Cursor project slug** | Avoid silent empty digests when `DEFAULT_PROJECT_SLUG` is wrong |
| **`install-to-project.sh --launchd`** | Substitute `REPO_ROOT_PLACEHOLDER` and install launchd plists in one step |
| **`--verify` / `workflow doctor`** | Confirm slug, transcripts, git repo, hook executability, launchd status |
| **`--uninstall`** | Remove kit files without touching user rules/docs |
| **Idempotent re-install** | Safe to re-run install; merge rather than clobber |
| **Auto-merge `gitignore.snippet`** | Append gitignore patterns during install |
| **Merge workflow section into existing `AGENTS.md`** | Today existing files are kept but section must be merged by hand |
| **Write `workflow-kit.json` on install** | Record install date, version, source URL, slug |

---

## Testing and CI

The Python hooks contain real logic but have no automated tests or CI.

**High-value test targets:**

- `normalize_user_query()` / transcript parsing with fixture JSONL files
- `kickoff_delivered_in_text()` edge cases (placeholders, partial headings)
- `should_run_weekly()` with synthetic state and fake daily files
- `prune_daily_digests()` week-boundary behavior
- `install-to-project.sh` smoke test in a temporary git repo

**CI TODO:** GitHub Actions on push/PR — `pytest`, `shellcheck` on hooks, dry-run install into `/tmp/test-repo`.

---

## Weekly approval loop

The weekly pipeline writes `latest.md` and nudges the agent, but several steps remain manual or incomplete.

| Improvement | Rationale |
|-------------|-----------|
| **Detect approval intent in chat** | Parse yes / no / edit and call `finalize-approval` automatically |
| **Optional fenced apply mode** | After “yes”, agent applies diffs with a confirmation hook (opt-in) |
| **Reconcile weekly trigger logic** | Python `should_run_weekly()` vs bash `days_since >= 7` in `on-agent-stop.sh` may diverge |
| **Fill “Proposed diffs” structurally** | Today placeholder text; agent fills in chat only |
| **Generic default `sources.json`** | Template still includes mlops-project-specific URLs (e.g. MLflow) |

---

## Monday kickoff flow

| Improvement | Rationale |
|-------------|-----------|
| **Persist kickoff reply into stub file** | Structured chat output is not written back to `*-monday.md` |
| **Backlog summary in `sessionStart`** | Surface multiple unviewed queue entries |
| **Validate `workflow-paths.json` on install** | Fail fast on missing paths or invalid modes |
| **Reminder for stale unviewed items** | Nudge if kickoff incomplete for N weeks |
| **Ask mode documentation / workaround** | `stop` / `afterAgentResponse` do not run in Ask mode |

---

## Cross-platform and scheduling

Current implementation is macOS-centric (`launchd`, BSD `date -j` in stop hook).

| Improvement | Rationale |
|-------------|-----------|
| **systemd user units** | Linux equivalent of launchd jobs |
| **cron examples** | Minimal scheduler fallback |
| **Windows Task Scheduler docs** | Or explicit “manual CLI only” path for Windows |
| **`schedule install` subcommand** | Single entry point for platform-specific scheduler setup |

---

## Smarter analysis

Digests use keyword lists and regex only—no summarization, clustering, or session metrics.

| Improvement | Rationale |
|-------------|-----------|
| **Session duration / tool-call metrics** | If available in transcripts |
| **Better friction detection** | Repeated errors, CI failures from git messages |
| **Theme deduplication across days** | Cleaner weekly rollup |
| **Optional LLM summarization step** | Manual or scheduled, with approval gate |
| **Configurable keywords without editing Python** | JSON or config file for `AREA_KEYWORDS` / `THEME_KEYWORDS` |

---

## Observability and operator experience

Hook failures are mostly invisible except `launchd.log`.

| Improvement | Rationale |
|-------------|-----------|
| **Structured logging** | Level, event, error across all hook scripts |
| **`workflow doctor` command** | Slug OK? transcripts found? git repo? hooks executable? launchd loaded? |
| **Surface last hook error in `sessionStart`** | Operator-visible failure nudge |
| **Debug mode** | e.g. `WORKFLOW_DEBUG=1` |

---

## Kit repo meta / productization

| Improvement | Rationale |
|-------------|-----------|
| **`CHANGELOG.md`** | Required once releases exist |
| **`CONTRIBUTING.md`** | How to change hooks without breaking installed projects |
| **Issue templates** | Bug vs installed-project vs kit-feature |
| **Adopter upgrade docs** | “I installed v0.2 — how do I upgrade?” |
| **Commercial license path** | Document how to request commercial use under PolyForm NC |
| **Clean up README placeholders** | e.g. `YOUR_USER`, stale mlops-project links |

---

## Cursor ecosystem integrations

| Improvement | Rationale |
|-------------|-----------|
| **Cursor Skill for kit upgrade / Monday kickoff** | Repeatable operator workflows |
| **Cursor Automation on release** | Notify opt-in adopters when a new kit version ships |
| **Rule (`.mdc`) for safe kit updates** | Teaches agent merge strategy during upgrades |
| **SDK-based scheduled agent** | Weekly synthesis if hook follow-ups are insufficient |

---

## Suggested priority

```text
Phase 1 — Trust & ship
  VERSION manifest, CHANGELOG, pytest + CI, release workflow

Phase 2 — Update loop
  check-for-updates on sessionStart, upgrade script, preserve user files

Phase 3 — Reduce install pain
  verify/doctor, auto slug, launchd from install, merge gitignore

Phase 4 — Complete the fences
  approval detection, optional fenced apply, write Monday kickoff to stub

Phase 5 — Polish
  cross-platform schedulers, smarter digests, backlog UX
```

---

## Naming note

Adopters install a **workflow kit** into their repo, not a standalone app. Version and update UX should say **workflow-kit vX.Y.Z** to avoid confusion with the host project’s own releases.
