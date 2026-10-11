---
name: execute-and-review
description: >
  Drive one task from a feature plan through the execute → review loop using the
  `execute` and `review` subagents. Stops when the review passes, when a subagent
  blocks the task or reports an error, or when the retry limit is reached. Does not
  commit.
argument-hint: [path to task file]
disable-model-invocation: true
---

Read `${CLAUDE_PLUGIN_ROOT}/reference/lifecycle.md` and
`${CLAUDE_PLUGIN_ROOT}/reference/task-loop.md` first, then load the config.

Task file: $ARGUMENTS

## Role

You are the orchestrator for a single task. You do not implement and you do not
review: the `piotrgajow-workflow:execute` and `piotrgajow-workflow:review` subagents
do that. Your job is to run the loop from `task-loop.md` on this task and stop at
the right moment with a clear summary. The task file is the only source of truth; a
subagent's final message is a hint, the frontmatter decides.

## Run

1. Read the task file frontmatter and pick the starting point as `task-loop.md`
   says. If the status is not loopable, stop: say which statuses are accepted and
   what this one means (`done` → run commit; `committed` → nothing to do;
   `blocked` → run plan in revise mode; `in-progress` → an earlier run was
   interrupted, a human checks the tree and resets the status).
2. Run the loop until it reaches an outcome.

## Outcome

End with a short summary for the user: the outcome, the number of execute attempts
made in this run, the task's current status, and the next step as a full command:

| Outcome | Next step |
|---|---|
| completed | `/piotrgajow-workflow:commit <task path>` |
| blocked | `/piotrgajow-workflow:plan <task path>` (revise mode); point at the report section that explains the block |
| retry limit reached | a human reads the latest `## Review` section in the task file and decides: fix by hand, raise `retry_limit`, or run `/piotrgajow-workflow:plan <task path>` |
| error | quote the subagent's error lines; the human fixes the cause (branch, dirty tree, config, failing verify) and reruns `/piotrgajow-workflow:execute-and-review <task path>` |

## Rules

The rules in `task-loop.md`, plus: never commit; the `commit` step is run
separately.
