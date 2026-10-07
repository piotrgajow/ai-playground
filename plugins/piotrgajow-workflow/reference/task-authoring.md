# Task authoring reference

Shared by every step that writes or changes task files: `plan` (initial and revise
mode) and `amend`. Read it after `lifecycle.md`. The templates live in
`skills/plan/assets/`.

## Rules for a good task

- Small: a handful of files, one concern. If you cannot name the files, it is not
  ready to be a task.
- Self-contained: after it is done, `verify` commands pass and nothing is half-wired.
  Prefer "add the type, then the backend, then the UI" over one task per layer that
  leaves the build broken in between.
- Independently reviewable: its acceptance checks can be verified without later tasks.
- Ordered by dependency; use `depends_on` only when the order alone does not express
  it.
- Maps to spec criteria: every task serves at least one acceptance criterion from
  the spec, named by number in `## Goal`. Taken together, the tasks of a feature
  cover every criterion.
- Technical content only. A task never carries an open business question; if one
  turns up while writing a task, the step stops and hands it to `refine`.

## Writing a task file

- Use `${CLAUDE_PLUGIN_ROOT}/skills/plan/assets/task-template.md`. Every section
  filled; `## Notes for executor` may be empty.
- File name `tasks/NN-<slug>.md`, zero-padded two-digit number, `01` first. The
  path is the task id; nothing else refers to a task by another identifier.
- New tasks added to an existing plan get the next free numbers. Renumbering is
  allowed only for tasks that are not `done` or `committed`, and only when the
  order must change; update every `depends_on` that refers to a renumbered task.
- Frontmatter starts as `status: todo`, `attempts: 0`. `files` lists the paths
  expected to change.
- Add every new task to the `## Task order` table in `plan.md`, with its spec
  criteria.

## Changing an existing plan

- Tasks with status `done` or `committed` are never changed. If the only fix
  requires changing one, stop and say which task and why.
- An edited task keeps its history sections and gets `status: todo`, `attempts: 0`.
- A task replaced by others gets `status: dropped` and a one-line note under its
  title naming the tasks that replace it.
- Every change to an existing plan appends an entry to `## Revisions` in `plan.md`:
  date, which step made it (`plan` revise or `amend`), what triggered it, what
  changed. For `amend`, the entry also records the gap classification (see the
  `amend` skill) so a later retrospective can trace where the gap came from.

## All or nothing

Write files only once the whole task list, or the whole change to it, is decided.
A failed or abandoned run leaves the feature directory exactly as it was.
