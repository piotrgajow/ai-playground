# piotrgajow-workflow

Agentic development workflow as a set of manually invoked steps. Each step is a
skill that reads and writes files in a feature directory, so steps can run in
separate sessions and later be driven by an orchestrator.

## Steps

| Skill | Input | Output | Model |
|---|---|---|---|
| `setup-workflow` | repo inspection + interview | `.workflow/config.md` | Sonnet 5.5 |
| `refine <ticket>` | ticket text/id/link, project docs | `<work_dir>/<slug>/spec.md` | Opus 5.5 |
| `plan <slug>` | spec, codebase, conventions | `plan.md` + `tasks/NN-<slug>.md` | Opus 5.5, high effort (Fable 5.1 for large or cross-cutting features) |
| `plan <blocked task path>` | blocked task report | revised tasks | Opus 5.5 |
| `execute <task path>` | task, conventions, latest review | source changes, execution report, status `ready-for-review` | Sonnet 5.5 (Opus 5.5 on a retry) |
| `review <task path>` | task, diff, verify commands | review report, status `done` / `review-failed` / `blocked` | Opus 5.5 |
| `commit <task path>` | task with status `done` | one commit, status `committed` | Haiku 4.5 |

Why these:

- **Plan** has the most leverage: a bad split costs several execute/review cycles. Spend there.
- **Refine** is about asking the right questions and noticing what is missing; weaker models accept vague answers.
- **Execute** gets a small, fully specified task, so the cheaper model is usually enough. Bump to Opus on a retry: the first attempt already showed the task is not trivial.
- **Review** should be at least as strong as execute and ideally a different model, so the two do not share blind spots.
- **Commit** is mechanical.

Switch with `/model` before invoking a skill. Once an orchestrator drives the steps, pin models per step with the `model` field of custom subagents instead.

Typical loop per task: `execute` → `review` → (`execute` again on fail) → `commit`.
Human gates for now: after `refine`, after `plan`, after each `review`.

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

## Later

- `commit` is deterministic and can become a script.
- An orchestrator can loop over `todo` tasks and chain `execute` → `review` →
  `commit`, keeping plan approval as the human gate. Step skills stay unchanged.
