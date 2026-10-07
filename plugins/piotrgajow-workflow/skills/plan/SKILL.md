---
name: plan
description: >
  Turn an approved feature spec into an ordered list of small implementation tasks,
  one file per task. Technical focus. Also revises an existing plan when a task was
  blocked. Writes `<work_dir>/<slug>/plan.md` and `tasks/NN-<slug>.md`.
argument-hint: [feature slug, or path to a blocked task file]
disable-model-invocation: true
---

Read `${CLAUDE_PLUGIN_ROOT}/reference/lifecycle.md` first, then load the config. Apply
the config body section `## plan` if present.

Argument: $ARGUMENTS

Mode:
- The argument is a feature slug (or a path to `spec.md`) → **initial planning**.
- The argument is a path to a task file with `status: blocked` → **revise**.
- Anything else → stop and ask with `AskUserQuestion`.

## Role

You are the tech lead breaking a spec into tasks that one developer can finish in a
single sitting, with no memory of this planning session. The tasks will be executed
sequentially, each committed on its own, so after every task the repository must
build and pass verification.

## Phase 1 — Understand

1. Read `spec.md`. If it is not `status: approved`, stop and say so.
2. Load conventions: ambient instructions, `conventions.docs`, and invoke every skill
   in `conventions.skills`.
3. Explore the codebase: the modules the spec touches, existing patterns for similar
   features, tests and their fixtures, contract/types shared between packages.
   Read enough to name the files each task will change.

## Phase 2 — Draft the task list

Rules for a good task:

- Small: a handful of files, one concern. If you cannot name the files, it is not
  ready to be a task.
- Self-contained: after it is done, `verify` commands pass and nothing is half-wired.
  Prefer "add the type, then the backend, then the UI" over one task per layer that
  leaves the build broken in between.
- Independently reviewable: its acceptance checks can be verified without later tasks.
- Ordered by dependency; use `depends_on` only when the order alone does not express
  it.
- Maps to spec criteria: every acceptance criterion in the spec is covered by at
  least one task; no task exists that serves none.

Also draft the plan overview: approach, cross-cutting decisions (names, placement,
patterns), and the ordered table.

## Phase 3 — Confirm

Present the overview and the task list as an outline in chat: for each task its
title, files and one-line goal. Then ask with `AskUserQuestion` whether to approve
or adjust (options: approve, adjust the tasks); if they adjust, ask what to change
and repeat. Do not write files before approval.

## Phase 4 — Write

1. `plan.md` from `assets/plan-template.md`.
2. `tasks/NN-<slug>.md` for each task from `assets/task-template.md`, zero-padded
   two-digit numbers starting at `01`. Every section filled; `Notes for executor`
   may be empty.

Print the task paths in order and the next step: `execute <first task path>`.

## Revise mode

Input is a blocked task file. Read its latest execution or review report: that is
the reason the plan must change.

1. Re-read `spec.md`, `plan.md` and every task file to see the current state.
2. Decide the change: split the blocked task, reorder, add tasks, rewrite its
   content, or drop it. Tasks with status `done` or `committed` are never changed.
   Tasks with other statuses may be edited, renumbered or dropped.
3. Present the change in chat and get approval, as in Phase 3.
4. Apply it:
   - Edited tasks keep their history sections and get `status: todo`, `attempts: 0`.
   - New tasks get the next free numbers, or renumber the not-yet-done tail if the
     order must change. Update `depends_on` references accordingly.
   - A task that is replaced gets `status: dropped` and a one-line note under its
     title saying which tasks replace it.
   - Append an entry to `## Revisions` in `plan.md`: which task was blocked, why,
     what changed.

Print the updated order and the next task to execute.

## Rules

- Technical content only. Business questions go back to `refine`, not into tasks.
- Never plan work outside the spec's scope. If the codebase needs a refactor to make
  the feature possible, that is a task of its own with its own acceptance checks,
  and it is called out in the overview.
- Do not write task files before the outline is approved.
