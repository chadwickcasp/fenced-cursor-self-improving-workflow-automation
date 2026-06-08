# Project goal
Describe what this project must demonstrate in one short paragraph.

- small enough to finish
- reproducible
- easy to demo
- well documented

# Human-owned decisions
The human owns final decisions for:
- problem framing
- dataset choice
- label definitions
- primary evaluation metric
- model family choice
- architecture changes
- deployment tradeoffs

Before changing any of those, present tradeoffs and ask for approval.

# Working style
For any non-trivial task:
1. restate the task in plain English
2. identify the files likely to change
3. state assumptions / risks
4. define how success will be verified
5. keep the diff as small as possible

# ML-specific expectations (optional — trim if not an ML repo)
For changes involving training, evaluation, data processing, or inference:
- explain the hypothesis before editing
- prefer the smallest valid baseline first
- change one major experimental variable at a time unless explicitly told otherwise
- preserve reproducibility: note config, seed, dataset version, and metrics touched

# Code quality
- prefer small, reviewable diffs
- do not introduce a new framework or dependency without justification
- preserve existing patterns unless there is a clear reason to refactor
- write or update focused tests for non-trivial logic

# Documentation
When behavior, interfaces, metrics, or workflows change:
- update docs/feature-plan.md if scope changed
- append to docs/experiment-log.md if ML behavior changed
- append to docs/decision-log.md for important tradeoffs

# Cursor workflow automation
Installed from [fenced-cursor-self-improving-workflow-automation](https://github.com/YOUR_USER/fenced-cursor-self-improving-workflow-automation) (local path may differ).

- Daily digests: `.cursor/workflow-review/daily/`
- Weekly rule review: `.cursor/workflow-review/latest.md` — apply only after **yes / no / edit**
- Monday suggestions: `.cursor/workflow-suggestions/KICKOFF.md` in Agent mode; external dirs in `.cursor/workflow-paths.json`

# Definition of done
A task is not done unless:
- the code runs
- relevant tests / checks pass or failures are clearly reported
- the change is summarized in plain English
- risks / limitations are stated
