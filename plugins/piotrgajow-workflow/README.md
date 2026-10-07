# piotrgajow-workflow

Agentic development workflow. Each step reads and writes files in a feature
directory, so steps can run in separate sessions. The human-facing steps are skills
invoked by hand; the inner execute → review loop is driven by an orchestrator skill
that calls two subagents, each pinned to its own model.

## Steps

| Step | Kind | Input | Output | Model |
|---|---|---|---|---|
| `setup-workflow` | skill | repo inspection + interview | `.workflow/config.md` | Sonnet 5.5 |
| `refine <ticket>` | skill | ticket text/id/link, project docs | `<work_dir>/<slug>/spec.md` | Opus 5.5 |
| `plan <slug>` | skill | spec, codebase, conventions | `plan.md` + `tasks/NN-<slug>.md` | Opus 5.5, high effort (Fable 5.1 for large or cross-cutting features) |
| `plan <blocked task path>` | skill | blocked task report | revised tasks | Opus 5.5 |
| `execute-and-review <task path>` | skill (orchestrator) | task file | runs the loop below, stops with an outcome | any; it only spawns subagents and reads the task file |
| `execute` | subagent | task, conventions, latest review | source changes, execution report, status `ready-for-review` | Sonnet 5.5 (Opus 5.5 on a retry) |
| `review` | subagent | task, diff, verify commands | review report, status `done` / `review-failed` / `blocked` | Opus 5.5 |
| `commit <task path>` | skill | task with status `done` | one commit, status `committed` | Haiku 4.5 |

Why these:

- **Plan** has the most leverage: a bad split costs several execute/review cycles. Spend there.
- **Refine** is about asking the right questions and noticing what is missing; weaker models accept vague answers.
- **Execute** gets a small, fully specified task, so the cheaper model is usually enough. The orchestrator bumps it to Opus on a retry: the first attempt already showed the task is not trivial.
- **Review** should be at least as strong as execute and ideally a different model, so the two do not share blind spots.
- **Commit** is mechanical.

For skills, switch with `/model` before invoking. The `execute` and `review`
subagents carry their model in the `model` field of `agents/execute.md` and
`agents/review.md`; the retry bump is a per-invocation override made by the
orchestrator.

## The execute → review loop

`execute-and-review <task path>` runs:

```
execute → review → done                     (outcome: completed → run commit)
               ↘ review-failed → execute …  (until attempts > retry_limit)
execute or review → blocked                 (outcome: blocked → run plan on the task)
execute or review → error                   (outcome: error → human fixes the cause, reruns)
```

It stops on the first of: review passed, a subagent set `blocked`, a subagent
reported an error (wrong branch, dirty tree, failing verify outside scope, missing
config), or the retry limit was reached. It never commits; run `commit` afterwards.
A task already in `ready-for-review` starts at the review step.

Subagents cannot ask questions, so every situation where a skill would ask the
user ends the loop with an error and a message instead.

To run one step by hand, address the subagent directly:
`@agent-piotrgajow-workflow:execute Task file: <path>`.

## Files

- `.workflow/config.md` — per-repository config, markdown with YAML frontmatter.
  See `reference/lifecycle.md` for the fields.
- `<work_dir>/<slug>/spec.md` — business spec with numbered acceptance criteria.
- `<work_dir>/<slug>/plan.md` — approach, cross-cutting decisions, task order.
- `<work_dir>/<slug>/tasks/NN-<slug>.md` — one file per task; the path is the id.
  Execution and review reports are appended to it.

Statuses and transitions are in `reference/lifecycle.md`.

## Conventions

Steps apply `CLAUDE.md` and `.claude/rules/` automatically, plus the documents and
skills listed under `conventions` in the config.

Human gates for now: after `refine`, after `plan`, after each `execute-and-review`
run (before `commit`).

## Later

- Fold `commit` into the loop once it has proven itself, or turn it into a script.
- A higher-level orchestrator can loop over `todo` tasks and chain
  `execute-and-review` → `commit`, keeping plan approval as the human gate.
