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

Read `${CLAUDE_PLUGIN_ROOT}/reference/lifecycle.md` and
`${CLAUDE_PLUGIN_ROOT}/reference/task-authoring.md` first, then load the config. Apply
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

Apply the rules for a good task from `task-authoring.md`. In addition, in initial
planning: every acceptance criterion in the spec is covered by at least one task,
and no task exists that serves none.

Also draft the plan overview: approach, cross-cutting decisions (names, placement,
patterns), and the ordered table.

Before writing, check the draft against the rules yourself. If a criterion cannot
be covered by any task you can specify concretely, go back to Phase 2: it is an open
point, not something to paper over.

## Phase 4 — Write

1. `plan.md` from `${CLAUDE_PLUGIN_ROOT}/skills/plan/assets/plan-template.md`.
2. One task file per task, as `task-authoring.md` describes.

Print the task paths in order, each with its one-line goal, and the next steps:
`/piotrgajow-workflow:commit <slug>` to commit the plan, then
`/piotrgajow-workflow:execute-and-review <first task path>`.

## Revise mode

Input is a blocked task file. Read its latest execution or review report: that is
the reason the plan must change.

1. Re-read `spec.md`, `plan.md` and every task file to see the current state.
2. If the block comes from the spec (a business question the executor or reviewer
   could not answer, or a contradiction in the spec), fail with the refine report.
   Change no files.
3. Decide the change: split the blocked task, reorder, add tasks, rewrite its
   content, or drop it. Follow "Changing an existing plan" in `task-authoring.md`:
   `done` and `committed` tasks are never changed; if the only fix requires changing
   one, fail and say which task and why.
4. Apply it as `task-authoring.md` describes, and append the `## Revisions` entry:
   which task was blocked, why, what changed.

Print what changed, the updated order and the next steps:
`/piotrgajow-workflow:commit <slug>` to commit the revised plan, then
`/piotrgajow-workflow:execute-and-review <next task path>`.

## Failure output

A failed run writes no files and ends with:

```
PLAN FAILED: <one-line reason>
```

followed by one of the two forms below.

**Spec problems** (open points from Phase 2, or a spec-caused block in revise mode):
print a short note that the block below is meant for `/piotrgajow-workflow:refine`,
then a single fenced block the user can paste as the `/piotrgajow-workflow:refine`
argument unchanged. It must stand on its own, without this chat:

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
the user should run instead (as a `/piotrgajow-workflow:<step>` command), or what
they must fix by hand.

## Rules

- No user interaction. Never use `AskUserQuestion` or ask anything in plain text;
  decide technical questions yourself, fail on business ones.
- Technical content only. Business questions go back to `refine`, not into tasks.
- Never plan work outside the spec's scope. If the codebase needs a refactor to make
  the feature possible, that is a task of its own with its own acceptance checks,
  and it is called out in the overview.
- All or nothing, as `task-authoring.md` says: a failed run leaves the feature
  directory exactly as it was.
- Adding tasks to a plan whose tasks are all `committed` (a gap found after the
  feature shipped) is `amend`'s job, not revise mode's. Revise mode starts from a
  blocked task only.
