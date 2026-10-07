---
name: plan
description: >
  Turn an approved feature spec into an ordered list of small implementation tasks,
  one file per task. Technical focus. Also revises an existing plan when a task was
  blocked. Runs without user interaction: either writes `<work_dir>/<slug>/plan.md`
  and `tasks/NN-<slug>.md`, or fails with a report to paste into `refine`.
argument-hint: [feature slug, or path to a blocked task file]
disable-model-invocation: true
---

Read `${CLAUDE_PLUGIN_ROOT}/reference/lifecycle.md` first, then load the config. Apply
the config body section `## plan` if present.

Argument: $ARGUMENTS

Mode:
- The argument is a feature slug (or a path to `spec.md`) → **initial planning**.
- The argument is a path to a task file with `status: blocked` → **revise**.
- Anything else → fail (see Failure output) and say which arguments are accepted.

## Role

You are the tech lead breaking a spec into tasks that one developer can finish in a
single sitting, with no memory of this planning session. The tasks will be executed
sequentially, each committed on its own, so after every task the repository must
build and pass verification.

You work alone. Nobody answers questions during this step: you either produce a plan
you stand behind or stop with a precise list of what prevents it.

## Phase 1 — Understand

1. Read `spec.md`. If it is not `status: approved`, fail.
2. In initial planning, if `plan.md` already exists, fail: an existing plan is
   changed only through revise mode.
3. Load conventions: ambient instructions, `conventions.docs`, and invoke every skill
   in `conventions.skills`.
4. Explore the codebase: the modules the spec touches, existing patterns for similar
   features, tests and their fixtures, contract/types shared between packages.
   Read enough to name the files each task will change.

## Phase 2 — Check the spec is plannable

Go through every scope item, business rule and acceptance criterion and ask: can I
name the observable behaviour the code must have? Collect every point where you
cannot. Typical causes:

- An acceptance criterion that cannot be checked as written (vague, subjective, no
  expected value).
- Two statements that contradict each other, or contradict current behaviour the
  spec does not mention changing.
- A business rule or edge case the spec is silent on, where the possible answers
  lead to different behaviour users would notice (permissions, validation, limits,
  empty states, existing data, error handling).
- Scope that depends on something the spec does not settle: another feature, data
  that does not exist, an external system.

Technical choices are yours, not gaps: names, placement, patterns, data shapes,
libraries already in use. Decide them and record them in `## Cross-cutting
decisions`. Never fill a business gap with an assumption; that is `refine`'s job.

If you collected any open points, fail with the refine report (see Failure output).
Do not write any files.

## Phase 3 — Draft the task list

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

Before writing, check the draft against these rules yourself. If a criterion cannot
be covered by any task you can specify concretely, go back to Phase 2: it is an open
point, not something to paper over.

## Phase 4 — Write

1. `plan.md` from `${CLAUDE_PLUGIN_ROOT}/skills/plan/assets/plan-template.md`.
2. `tasks/NN-<slug>.md` for each task from
   `${CLAUDE_PLUGIN_ROOT}/skills/plan/assets/task-template.md`, zero-padded
   two-digit numbers starting at `01`. Every section filled; `Notes for executor`
   may be empty.

Print the task paths in order, each with its one-line goal, and the next step:
`execute <first task path>`.

## Revise mode

Input is a blocked task file. Read its latest execution or review report: that is
the reason the plan must change.

1. Re-read `spec.md`, `plan.md` and every task file to see the current state.
2. If the block comes from the spec (a business question the executor or reviewer
   could not answer, or a contradiction in the spec), fail with the refine report.
   Change no files.
3. Decide the change: split the blocked task, reorder, add tasks, rewrite its
   content, or drop it. Tasks with status `done` or `committed` are never changed;
   if the only fix requires changing one, fail and say which task and why.
   Tasks with other statuses may be edited, renumbered or dropped.
4. Apply it:
   - Edited tasks keep their history sections and get `status: todo`, `attempts: 0`.
   - New tasks get the next free numbers, or renumber the not-yet-done tail if the
     order must change. Update `depends_on` references accordingly.
   - A task that is replaced gets `status: dropped` and a one-line note under its
     title saying which tasks replace it.
   - Append an entry to `## Revisions` in `plan.md`: which task was blocked, why,
     what changed.

Print what changed, the updated order and the next task to execute.

## Failure output

A failed run writes no files and ends with:

```
PLAN FAILED: <one-line reason>
```

followed by one of the two forms below.

**Spec problems** (open points from Phase 2, or a spec-caused block in revise mode):
print a short note that the block below is meant for `refine`, then a single fenced
block the user can paste as the `refine` argument unchanged. It must stand on its
own, without this chat:

````
```
Update the existing spec <work_dir>/<slug>/spec.md (feature `<slug>`).
Blocked task: <task path>   (revise mode only; omit otherwise)
Planning stopped because the points below are not settled. Resolve each one and
record the answer in the spec.

1. <Spec section, or "AC <n>"> — <quote or paraphrase of the unclear text>
   Problem: <what is ambiguous, missing or contradictory>
   Why it blocks planning: <what the implementation cannot decide without it>
   Options seen: <option A>; <option B>   (omit if none)

2. ...
```
````

List every open point found, not only the first. Business language only: no file
or class names unless the spec itself uses them. In revise mode, quote the relevant
part of the blocked task's report in the points it causes.

**Anything else** (bad argument, missing config, spec not approved, existing plan,
a fix that would change a `done` or `committed` task): print the reason and the step
the user should run instead, or what they must fix by hand.

## Rules

- No user interaction. Never use `AskUserQuestion` or ask anything in plain text;
  decide technical questions yourself, fail on business ones.
- Technical content only. Business questions go back to `refine`, not into tasks.
- Never plan work outside the spec's scope. If the codebase needs a refactor to make
  the feature possible, that is a task of its own with its own acceptance checks,
  and it is called out in the overview.
- All or nothing: write files only once the whole plan (or revision) is decided. A
  failed run leaves the feature directory exactly as it was.
