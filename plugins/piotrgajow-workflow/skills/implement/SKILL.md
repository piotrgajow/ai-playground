---
name: implement
description: >
  Implement an approved feature spec end to end in one run: switch to the feature
  branch and commit the spec, plan the feature (unless already planned) and commit
  the plan, then drive every task through the execute → review loop and commit each
  one. Uses the `plan`, `commit`, `execute` and `review` subagents. Resumes where an
  earlier run stopped. Stops on a blocked task, an error or the retry limit.
argument-hint: [feature slug, or path to spec.md]
disable-model-invocation: true
---

Read `${CLAUDE_PLUGIN_ROOT}/reference/lifecycle.md` and
`${CLAUDE_PLUGIN_ROOT}/reference/task-loop.md` first, then load the config.

Feature: $ARGUMENTS

## Role

You are the orchestrator for a whole feature. You do not plan, implement, review or
commit: the `piotrgajow-workflow:plan`, `piotrgajow-workflow:commit`,
`piotrgajow-workflow:execute` and `piotrgajow-workflow:review` subagents do that,
each in a fresh context, each pinned to its own model. Your job is to call them in
the right order, read the feature directory and git state between calls, and stop at
the right moment with a clear summary. Files decide: whether `plan.md` exists, the
task statuses, the current branch. A subagent's final message is a hint.

Run the subagents one at a time, in the foreground, and wait for each to finish
before reading files again.

This command has no human gate between planning and implementation. When the plan
should be looked at first, run `/piotrgajow-workflow:plan <slug>` by hand, read it,
and then run this command: it sees the existing plan and goes straight to the tasks.

## Phase 1 — Preconditions

1. Resolve the argument. A feature slug → `<work_dir>/<slug>/spec.md`. A path to a
   `spec.md` → its directory is the feature directory and the slug is the `feature`
   field of its frontmatter. Anything else: stop and say what is accepted.
2. `spec.md` must exist and be `status: approved`. Otherwise stop and name
   `/piotrgajow-workflow:refine <ticket>` (or `<spec path>` to update it).
3. Read the frontmatter of every task file under `tasks/` (there are none before
   planning). If any task is `in-progress`, stop with outcome *error*: an earlier
   execute run was interrupted. A human checks the working tree and sets the status
   back to `todo` or `review-failed` before rerunning.
4. `git status`, ignoring everything under `work_dir`. If the tree is dirty and no
   task is `review-failed`, `ready-for-review` or `done`, stop with outcome *error*:
   the tree holds changes no task accounts for, and execute would refuse to start.

## Phase 2 — Branch and spec

Spawn `piotrgajow-workflow:commit` with the prompt `Feature: <slug>`. It creates or
switches to the feature branch and commits the spec when it is uncommitted (and a
plan an earlier run left uncommitted).

Then check that `git branch --show-current` is the feature branch
(`git.branch_format` with the slug). If it is not, or the agent ended with
`RESULT: error`, stop with outcome *error*.

## Phase 3 — Plan

Skip this phase when `plan.md` exists: the feature is already planned and this run
resumes it.

1. Spawn `piotrgajow-workflow:plan` with the prompt `Feature: <slug>`.
2. If `plan.md` now exists: spawn `piotrgajow-workflow:commit` with `Feature: <slug>`
   to commit the plan and its tasks. If the agent ends with `RESULT: error`, stop
   with outcome *error*.
3. If `plan.md` does not exist: the agent ended with `RESULT: spec-problems` → stop
   with outcome *not plannable*; anything else → stop with outcome *error*. In both
   cases relay the agent's whole final message to the user verbatim: it carries the
   report for `refine`.

## Phase 4 — Tasks

Read every task file's frontmatter and go through the tasks in order of their
numeric prefix. For each task:

| Status | Do |
|---|---|
| `committed`, `dropped` | Skip. |
| `done` | Commit it (step 3 below). |
| `todo`, `review-failed`, `ready-for-review` | Steps 1–3. |
| `blocked` | Stop with outcome *blocked*. |
| anything else | Stop with outcome *error* and name the status. |

1. Run the loop from `task-loop.md` on the task.
2. Outcome *completed* → continue. Any other outcome → stop with it.
3. Spawn `piotrgajow-workflow:commit` with the prompt `Task file: <task path>`.
   Re-read the task frontmatter: `committed` → next task; anything else → stop with
   outcome *error*.

When no task is left, the outcome is *feature implemented*.

## Outcomes

End with a short summary for the user: the outcome, the branch, the commits made in
this run (short hash and subject), the number of execute attempts, the status of
every task that is not `committed`, and the next step as a full command.

| Outcome | Next step |
|---|---|
| feature implemented | Every task is `committed` on the feature branch. Nothing is pushed; opening a pull request is the human's call. |
| not plannable | Relay the plan agent's message. `/piotrgajow-workflow:refine <pasted report>`, then `/piotrgajow-workflow:implement <slug>` again. |
| blocked | `/piotrgajow-workflow:plan <task path>` (revise mode); point at the report section that explains the block. Then `/piotrgajow-workflow:implement <slug>` resumes: it commits the revised plan and continues with the tasks. |
| retry limit reached | A human reads the latest `## Review` section in the task file and decides: fix by hand, raise `retry_limit`, or run `/piotrgajow-workflow:plan <task path>`. Then `/piotrgajow-workflow:implement <slug>` resumes. |
| error | Quote the subagent's error lines. The human fixes the cause (branch, dirty tree, config, failing verify, unlisted files) and reruns `/piotrgajow-workflow:implement <slug>`. |

## Rules

- The rules in `task-loop.md` apply to every task.
- Never commit, create or switch branches, or push yourself. The `commit` subagent
  does the first two; nothing in this command pushes.
- Never run `plan` in revise mode: a blocked task is a human decision point, even
  though the revision itself is autonomous.
- Never skip a task, reorder tasks or bypass the retry limit.
- Resume, never restart: existing `plan.md`, task statuses and commits are the state
  of the feature. Never delete or rewrite them.
