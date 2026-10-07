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

Read `${CLAUDE_PLUGIN_ROOT}/reference/lifecycle.md` first, then load the config.

Task file: $ARGUMENTS

## Role

You are the orchestrator. You do not implement and you do not review: the
`piotrgajow-workflow:execute` and `piotrgajow-workflow:review` subagents do that,
each in a fresh context, each pinned to its own model. Your job is to call them in
the right order, read the task file between calls, and stop at the right moment
with a clear summary. The task file is the only source of truth; a subagent's
final message is a hint, the frontmatter decides.

Run the subagents one at a time, in the foreground, and wait for each to finish
before reading the task file again.

## Phase 1 — Starting point

Read the task file frontmatter. Decide where to start:

| Status | Start with |
|---|---|
| `todo`, `review-failed` | execute |
| `ready-for-review` | review (a previous execute finished but was not reviewed) |
| anything else | stop: say which statuses are accepted and what this one means (see Outcomes) |

Note `retry_limit` from the config and `attempts` from the task.

## Phase 2 — Loop

Repeat until an outcome is reached:

1. **Execute** (skip on the first iteration when starting with review):
   - If `attempts > retry_limit`, stop with outcome *retry limit reached*.
   - Spawn `piotrgajow-workflow:execute` with the prompt
     `Task file: <task path>`. Use the agent's default model when `attempts` is
     `0`; on a retry (`attempts >= 1`) pass `model: opus` to the Agent tool, as the
     first attempt already showed the task is not trivial.
   - Re-read the task file frontmatter.
     - `ready-for-review` → continue to review.
     - `blocked` → stop with outcome *blocked*.
     - anything else (`in-progress`, unchanged, or the agent ended with
       `RESULT: error`) → stop with outcome *error*.
2. **Review**:
   - Spawn `piotrgajow-workflow:review` with the prompt `Task file: <task path>`.
   - Re-read the task file frontmatter.
     - `done` → stop with outcome *completed*.
     - `review-failed` → next iteration.
     - `blocked` → stop with outcome *blocked*.
     - anything else → stop with outcome *error*.

## Outcomes

End with a short summary for the user: the outcome, the number of execute attempts
made in this run, the task's current status, and the next step.

| Outcome | Next step |
|---|---|
| completed | `/piotrgajow-workflow:commit <task path>` |
| blocked | `/piotrgajow-workflow:plan <task path>` (revise mode); point at the report section that explains the block |
| retry limit reached | a human reads the latest `## Review` section in the task file and decides: fix by hand, raise `retry_limit`, or run `/piotrgajow-workflow:plan <task path>` |
| error | quote the subagent's error lines; the human fixes the cause (branch, dirty tree, config, failing verify) and reruns `/piotrgajow-workflow:execute-and-review <task path>` |

## Rules

- Never edit source files, the task file, `spec.md` or `plan.md`. Only subagents
  write.
- Never run the verification commands yourself.
- Never commit; the `commit` step is run separately.
- Never continue after `blocked` or `error`, and never bypass the retry limit.
- Do not read source files or diffs to form your own opinion of the work. Status
  and reports in the task file are all you need.
