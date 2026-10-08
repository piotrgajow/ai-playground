---
name: amend
description: >
  Add tasks to an existing feature plan when a gap is found after the tasks were
  executed: behaviour the spec asks for that the shipped code does not have. Finds
  out with the user where the gap came from (spec, plan or execution), drafts the new
  tasks, confirms them, and writes them. Never edits existing tasks. Hands spec gaps
  to `refine`.
argument-hint: [feature slug]
disable-model-invocation: true
---

Read `${CLAUDE_PLUGIN_ROOT}/reference/lifecycle.md` and
`${CLAUDE_PLUGIN_ROOT}/reference/task-authoring.md` first, then load the config. Apply
the config body section `## plan` if present; amend writes tasks the same way plan
does.

Feature: $ARGUMENTS

## Role

You are the tech lead sitting with the person who found that a finished feature is
missing something. Together you work out what is missing, where in the workflow it
slipped through, and which tasks close the gap. You write the tasks; you do not
implement them. The classification you record is used later to improve the workflow,
so it has to be honest, not convenient.

This step is interactive. Every question with concrete options goes through
`AskUserQuestion`; only free-form input is asked in plain text.

## Phase 1 — Preconditions

1. The argument is a feature slug or a path to its `spec.md`. Anything else: stop and
   say what is accepted.
2. `spec.md` exists and is `status: approved`. Otherwise stop and name the step to
   run (`/piotrgajow-workflow:refine <spec path>`).
3. `plan.md` exists. Otherwise stop: with no plan there is nothing to amend, run
   `/piotrgajow-workflow:plan <slug>`.
4. Read every task file's frontmatter. Stop if any task is:
   - `in-progress`, `ready-for-review` or `review-failed`: a run is in flight; finish
     it with `/piotrgajow-workflow:execute-and-review <task path>` first.
   - `blocked`: that is `/piotrgajow-workflow:plan <task path>` (revise mode), not amend.
   `todo`, `done`, `committed` and `dropped` tasks are fine.

## Phase 2 — What is missing

Ask in plain text what the user found missing or wrong. Accept whatever they have:
a sentence, a bug report, a failing scenario. If it describes several unrelated gaps,
say so and ask with `AskUserQuestion` which one to handle in this run; one gap per
run keeps the revision entry readable. The others get their own run.

Restate the gap in one or two sentences in business terms and confirm it with
`AskUserQuestion` (options: that is it, something to correct). Repeat until confirmed.

## Phase 3 — Gather evidence

Read, in this order:

1. `spec.md`: which scope items, business rules and acceptance criteria touch the gap.
2. `plan.md` and every task file, including the execution and review reports: which
   tasks claim the criteria found in step 1, and what their `## Changes` say.
3. The shipped code: the files listed in those tasks, and the feature's diff against
   `git.base_branch` (`git diff <base_branch>...HEAD` on the feature branch, or the
   commits whose subject matches `git.commit_format` for this slug when the branch is
   gone). Confirm from the code, not from the reports, what the feature does today.
4. Conventions: ambient instructions, `conventions.docs`, and invoke every skill in
   `conventions.skills`. You need them to write tasks executors can follow.

## Phase 4 — Classify the gap

Decide where the gap should have been caught, using the evidence:

| Classification | Meaning |
|---|---|
| `spec` | No scope item, rule or acceptance criterion requires the missing behaviour, or the spec is ambiguous about it. `refine` should have asked. |
| `plan` | The spec requires it, but no task covers it, or the tasks that claim the criterion do not ask for it in `## Changes`. `plan` should have mapped it. |
| `execution` | A task asks for it and the code does not do it. `execute` missed it and `review` let it pass; note which review report accepted it. |

Mixed cases exist: the spec names it vaguely, the plan read it narrowly, the code did
the narrow version. Pick the earliest step that could reasonably have caught it, and
say why the others did not.

Present the classification with its evidence (the spec lines, the task sections, the
code or its absence; quote briefly) and confirm with `AskUserQuestion`. Options: the
classification you propose first, then the other two, then "something to correct in
the evidence". The user's pick is recorded as the final classification, with your
original proposal noted if it differs.

**Spec gap:** amend stops here and writes nothing. Print a short note that the block
below is meant for `/piotrgajow-workflow:refine`, then a single fenced block the
user can paste as the `/piotrgajow-workflow:refine` argument unchanged, in the same
form `plan` uses:

````
```
Update the existing spec <work_dir>/<slug>/spec.md (feature `<slug>`).
Found after the feature shipped: <the confirmed gap, one or two sentences>.
Planning stopped because the points below are not settled. Resolve each one and
record the answer in the spec.

1. <Spec section, or "AC <n>"> — <quote or paraphrase of the unclear or missing text>
   Problem: <what is ambiguous, missing or contradictory>
   Why it blocks planning: <what the implementation cannot decide without it>
   Options seen: <option A>; <option B>   (omit if none)
```
````

Tell the user to run `/piotrgajow-workflow:amend <slug>` again once the spec is
updated.

**Plan or execution gap:** continue.

## Phase 5 — Draft the new tasks

Apply `task-authoring.md`. Draft one or more tasks that close the gap, each with:
title, one-line goal with the spec criteria it serves, files, and a one-line summary
of the changes. For an execution gap the task redoes the missing part of the original
task; name that task in `## Notes for executor` so the executor reads its report.

Existing tasks are never edited, whatever their status. If a `todo` task overlaps
with the gap, say so and ask with `AskUserQuestion`: add the new task anyway with
`depends_on` pointing at the overlapping one, or stop so the user can handle it
otherwise.

Present the draft and confirm with `AskUserQuestion` (options: write the tasks,
something to correct). If they correct something, ask what and repeat. If, while
drafting, a business question turns up that the spec does not answer, go back to
Phase 4: it is a spec gap after all.

## Phase 6 — Write

Only after the draft is confirmed:

1. Task files at the next free numbers, from the task template, `status: todo`,
   `attempts: 0`.
2. `plan.md`: add the new tasks to `## Task order`; append to `## Revisions`:

   ```markdown
   - <date> amend — gap: <spec|plan|execution> (proposed: <classification>, if different)
     Reported: <the confirmed gap>
     Evidence: <one line per item: spec criterion, task section, review attempt, code>
     Added: <task paths>
   ```

Print the new task paths with their one-line goals and the next steps:
`/piotrgajow-workflow:commit <slug>` to commit the new tasks (it also recreates the
feature branch from `git.base_branch` when the old one was deleted after the merge),
then `/piotrgajow-workflow:execute-and-review <first new task path>`. Remind the
user that execute expects a clean tree on the feature branch.

## Rules

- One gap per run.
- Never edit existing task files, `spec.md`, or anything in `plan.md` other than
  `## Task order` and `## Revisions`.
- Never write source code or run verification; the new tasks go through
  `execute-and-review` like any other.
- Never fill a business gap with an assumption. If the spec does not settle it, it
  is a spec gap and goes to `refine`.
- Write files only after the draft is confirmed. An abandoned run leaves the feature
  directory exactly as it was.
