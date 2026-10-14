# Execute → review loop

Shared by the orchestrators that drive a task through the `execute` and `review`
subagents: `execute-and-review` (one task) and `implement` (every task of a
feature). Read it after `lifecycle.md`.

The orchestrator does not implement and does not review. It spawns the
`piotrgajow-workflow:execute` and `piotrgajow-workflow:review` subagents, each in a
fresh context, each pinned to its own model, one at a time and in the foreground,
and waits for each to finish. It re-reads the task file frontmatter after every run:
the frontmatter decides, the subagent's final message only explains it.

## Starting point

| Status | Start with |
|---|---|
| `todo`, `review-failed` | execute |
| `ready-for-review` | review (a previous execute finished but was not reviewed) |
| anything else | not loopable; the orchestrator decides what it means (see the status table in `lifecycle.md`) |

Note `retry_limit` from the config and `attempts` from the task.

## Loop

Repeat until an outcome is reached:

1. **Execute** (skipped on the first iteration when starting with review):
   - If `attempts > retry_limit`, stop with outcome *retry limit reached*.
   - Spawn `piotrgajow-workflow:execute` with the prompt `Task file: <task path>`.
     Use the agent's default model when `attempts` is `0`; on a retry
     (`attempts >= 1`) pass `model: opus` to the Agent tool, as the first attempt
     already showed the task is not trivial.
   - Re-read the task file frontmatter:
     - `ready-for-review` → continue to review.
     - `blocked` → stop with outcome *blocked*.
     - anything else (`in-progress`, unchanged, or the agent ended with
       `RESULT: error`) → stop with outcome *error*.
2. **Review**:
   - Spawn `piotrgajow-workflow:review` with the prompt `Task file: <task path>`.
   - Re-read the task file frontmatter:
     - `done` → stop with outcome *completed*.
     - `review-failed` → next iteration.
     - `blocked` → stop with outcome *blocked*.
     - anything else → stop with outcome *error*.

## Outcomes

| Outcome | Meaning | What follows |
|---|---|---|
| completed | status `done`; the task's changes are in the working tree | `commit <task path>` |
| blocked | a subagent set `blocked`; the task itself is wrong | `plan <task path>` (revise mode); point at the report section that explains the block |
| retry limit reached | `attempts > retry_limit` | a human reads the latest `## Review` section and decides: fix by hand, raise `retry_limit`, or run `plan <task path>` |
| error | a subagent could not start or could not finish | quote the subagent's error lines; the human fixes the cause (branch, dirty tree, config, failing verify) and reruns |

## Rules

- Never edit source files, the task file, `spec.md` or `plan.md`. Only subagents
  write.
- Never run the verification commands yourself.
- Never continue after `blocked` or `error`, and never bypass the retry limit.
- Do not read source files or diffs to form your own opinion of the work. Status
  and reports in the task file are all you need.
