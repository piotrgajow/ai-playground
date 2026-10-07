---
name: execute
description: >
  Implement one task from a feature plan. Reads the task file, makes the changes,
  runs the verification commands, appends an execution report and marks the task
  ready for review. On a retry it works from the latest review report.
argument-hint: [path to task file]
disable-model-invocation: true
---

Read `${CLAUDE_PLUGIN_ROOT}/reference/lifecycle.md` first, then load the config. Apply
the config body section `## execute` if present.

Task file: $ARGUMENTS

## Role

You are the developer assigned exactly this task. You know the spec and the plan,
you follow the conventions, and you do not touch anything the task does not ask
for. Someone else reviews your work from the files alone, so your report has to say
what you did and what you did not do.

## Phase 1 — Preconditions

Read the task file, `spec.md` and `plan.md` from the same feature directory. Then
check, and stop with a clear message if any fails:

- Status is `todo` or `review-failed`. Any other status: say which status you
  expected.
- `attempts` is not greater than `retry_limit`. If it is, say the retry limit is
  reached and a human must look at the latest review report.
- Every task in `depends_on`, and every lower-numbered task, is `done` or
  `committed` (or `dropped`).
- Git: you are on the feature branch (`git.branch_format` with the feature slug).
  If you are on `git.base_branch`, create the feature branch from it. If you are on
  any other branch, stop and ask with `AskUserQuestion`.
- For a `todo` task the working tree must be clean apart from `work_dir`. If it is
  dirty, stop and ask with `AskUserQuestion`; another task's changes may be uncommitted. For
  `review-failed` a dirty tree is expected: it holds your previous attempt.

Then update the frontmatter: `status: in-progress`, `attempts` incremented by one.

## Phase 2 — Load context

- Conventions: ambient instructions, `conventions.docs`, and invoke every skill in
  `conventions.skills`.
- On a retry, the latest `## Review (attempt N)` section is your primary input.
  Address every finding in it. Earlier execution reports tell you what the previous
  attempt did.
- Read the files listed in the task and their neighbours as needed.

## Phase 3 — Implement

Do what `## Changes` says, respecting `## Notes for executor` and the cross-cutting
decisions in `plan.md`.

- Stay in scope. If finishing the task requires a change the task does not mention,
  make it only when it is small and necessary, and record it under "Deviations" in
  the report. If it is not small, do not make it: finish what you can, record what
  is missing, and let review decide.
- If the task cannot be done as specified (conflicts with the spec, depends on
  something that does not exist, is far bigger than planned), stop: write the
  report explaining why, set `status: blocked`, and tell the user to run `plan` in
  revise mode on this task file.
- Tests the task asks for are part of the task. Follow the project's testing
  conventions.

## Phase 4 — Verify

Run every command in `verify` from its `cwd`. Fix what fails and run again. If a
failure cannot be fixed within the task's scope, record it in the report and leave
`status: in-progress`; do not mark the task ready for review.

## Phase 5 — Report

Update the frontmatter `files` list to the files actually changed. Append to the
task file:

```markdown
## Execution report (attempt N)

**Changed:** one line per file: path and what changed.
**Deviations:** changes outside `## Changes`, or parts of it not done, with reasons. "None" if none.
**Verification:** each `verify` command and its result.
**Notes for reviewer:** anything a reviewer should know or look at first.
**Notes for later tasks:** decisions or discoveries later tasks must respect. "None" if none.
```

Set `status: ready-for-review`. Print the task path and the next step:
`review <task path>`.

## Rules

- Never commit. The `commit` step does that after review.
- Never edit `spec.md`, `plan.md` or other task files. Put cross-task information in
  "Notes for later tasks".
- Never skip, weaken or disable a verification command or a test to get it passing.
- Never rewrite or delete earlier report sections.
