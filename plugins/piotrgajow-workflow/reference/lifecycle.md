# Workflow lifecycle reference

Every workflow step reads this file first, whether it runs as a skill in the main
session or as a subagent. It defines where things live, the file formats, the task
status machine and the rules that are shared by all steps. Steps that write task
files (`plan`, `amend`) also read `task-authoring.md`.

## Config

The config lives at `<git root>/.workflow/config.md`. It is markdown with YAML
frontmatter. Frontmatter is for machine-readable values; the body holds optional
free-text guidance per step.

If the config does not exist, stop and tell the user to run
`/piotrgajow-workflow:setup-workflow` first. Never guess config values.

Frontmatter fields:

| Field | Meaning |
|---|---|
| `work_dir` | Directory (relative to git root) holding feature directories |
| `work_dir_gitignored` | `true` if `work_dir` is ignored by git; affects what `commit` stages and what `review` diffs |
| `docs` | List of paths to product/domain documentation (`refine` reads these) |
| `conventions.docs` | List of paths to convention documents that are not loaded ambiently |
| `conventions.skills` | List of skill names to invoke before changing or reviewing code |
| `verify` | List of `{ name, command, cwd }` verification commands (lint, typecheck, test, build) |
| `git.branch_format` | Feature branch name pattern; placeholders `{slug}` |
| `git.commit_format` | Commit subject pattern for task commits; placeholders `{slug}`, `{task_id}`, `{task_title}` |
| `git.docs_commit_format` | Commit subject pattern for spec, plan and task-file commits made by `commit <slug>`; placeholders `{slug}`, `{summary}` |
| `git.base_branch` | Branch feature branches are created from |
| `tickets.source` | Where tickets come from: `text`, `github-issues`, `url` or a short description |
| `retry_limit` | Max re-executions of a task after a failed review before a human must step in |

Body sections (all optional): `## refine`, `## plan`, `## execute`, `## review`.
A step reads its own section and treats it as additional instructions. `amend` reads
`## plan`, since it writes tasks the same way.

## Conventions

Conventions a step must apply are the union of:

1. Ambient instructions: `CLAUDE.md` files and `.claude/rules/` already loaded by Claude Code.
2. Documents listed in `conventions.docs` — read them.
3. Skills listed in `conventions.skills` — invoke them before starting the work.

## Feature directory

```
<work_dir>/<slug>/
  spec.md          # written by refine
  plan.md          # written by plan: overview, ordering, cross-cutting decisions
  tasks/
    01-<slug>.md   # one file per task, written by plan
    02-<slug>.md
```

The task file path is the task id. The numeric prefix is the execution order.
Nothing else in the repo refers to a task by any other identifier.

## Feature branch

Every feature lives on its own branch, `git.branch_format` with the slug, created
from `git.base_branch`. The branch is created by the first `commit <slug>` run after
`refine` (and again by `commit <slug>` after `amend`, when the merged branch was
deleted). Every later step that touches git (`execute`,
`commit` in both modes) only checks that it is the current branch and stops
otherwise. No other step creates, switches or deletes branches.

Commits on the branch, in order:

1. the spec — `commit <slug>` after `refine`
2. the plan and its task files — `commit <slug>` after `plan` (and after every
   `plan` revise or `amend` run)
3. one commit per task — `commit <task path>` after `execute-and-review`

Document commits use `git.docs_commit_format`, task commits `git.commit_format`.
When `work_dir_gitignored` is true there are no document commits; `commit <slug>`
then only creates or checks the branch.

## Task file

```markdown
---
feature: <feature slug>
status: todo
attempts: 0
depends_on: []
files:
  - path/to/file.ts
---
# 01 Short task title

## Goal
## Changes
## Acceptance checks
## Notes for executor

## Execution report (attempt 1)
## Review (attempt 1)
```

`execute` and `review` append their reports as new sections at the end of the file,
numbered by attempt. Earlier reports are never edited or removed.

## Task status machine

| Status | Set by | Meaning |
|---|---|---|
| `todo` | plan | Not started |
| `in-progress` | execute | Execute is working on it |
| `ready-for-review` | execute | Execute finished and verification passed |
| `review-failed` | review | Review found problems; execute runs again with the review report |
| `blocked` | execute or review | The task itself is wrong; plan must revise |
| `done` | review | Review passed; ready to commit |
| `committed` | commit | Changes committed |
| `dropped` | plan (revise) | Superseded by other tasks; never executed |

Tasks added after the fact by `amend` start at `todo` like any other and follow the
same transitions. `amend` never changes the status of an existing task.

Transitions:

```
todo → in-progress → ready-for-review → done → committed
                  ↘ blocked          ↘ review-failed → in-progress (retry)
                                     ↘ blocked
```

Retry rule: `attempts` counts every execute run. Execute refuses to start when
`attempts > retry_limit`, and the `execute-and-review` orchestrator stops before
spawning it, telling the user to step in.

## Subagent steps

`execute` and `review` are subagents (`agents/execute.md`, `agents/review.md`),
driven by the `execute-and-review` skill. They run in a fresh context with only the
prompt, which names the task file, and they cannot ask the user anything. Where a
skill would ask, a subagent stops and reports an error instead.

A subagent's final message is for the orchestrator: a few lines at most, the last
one `RESULT: <status>`. The orchestrator still re-reads the task file after every
run; the frontmatter is the source of truth, the message only explains it.

## Shared rules

- One step never does another step's job. Execute does not review, review does not
  edit source, commit does not verify, amend does not edit existing tasks.
- Steps communicate only through files in the feature directory. Never rely on chat
  history from a previous step.
- When a step is asked to run on a task in the wrong status, stop and say which
  status it expected.
- A subagent step never asks the user anything; it stops with an error and lets the
  orchestrator or the human decide.
- When diffing source changes, ignore everything under `work_dir`.
- Keep reports factual and short. State what was done and what was found, not how
  hard it was.
- When telling the user which step to run next, write it as the full command with
  the plugin prefix and its argument, e.g. `/piotrgajow-workflow:commit <task path>`,
  never a bare step name like `commit`.
