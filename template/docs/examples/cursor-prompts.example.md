/plan-feature

Use plan mode thinking for this feature.

Goal:
[describe the feature]

Constraints:
- keep the diff small
- prefer the simplest end-to-end baseline
- do not change architecture unless necessary
- optimize for interview explainability

Please:
1. inspect the repo and identify the exact files likely to change
2. propose the smallest viable implementation plan
3. identify risks / unknowns
4. define verification steps
5. separate “ship now” from “later”
Do not edit code yet.


/implement-baseline

Implement only the baseline version of this task.

Before editing:
- explain the current code path
- explain why this is the right smallest step
- list the files to change

While editing:
- keep changes localized
- avoid new abstractions unless they remove obvious duplication
- write or update focused tests

After editing:
- summarize what changed
- state how it was verified
- tell me what I should understand from this change as the human owner


/experiment-readout

Analyze this experiment like an ML engineer writing an internal update.

Use:
- docs/experiment-log.md
- relevant configs
- logs / metrics
- changed files

Return:
1. what changed
2. whether the result is trustworthy
3. likely mechanism behind the result
4. best next experiment
5. one paragraph I can reuse in a portfolio writeup


/ship-check

Perform a final shipping check for this task.

Check:
- correctness against the requested behavior
- tests / checks
- obvious edge cases
- docs that should be updated
- interview explanation quality

Return:
1. pass / fail
2. missing checks
3. risky areas
4. exact docs to update
5. concise PR-style summary


/write-tests-first

Do not implement the feature yet.

Write the smallest useful set of tests that define the desired behavior.
Prefer descriptive, targeted tests over broad ones.
After writing tests, explain:
- what behavior is now pinned down
- what is still ambiguous
- what the minimum implementation would need to satisfy