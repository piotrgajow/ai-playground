---
name: commit
description: >
  Commit to the feature branch. With a feature slug: commits the uncommitted
  documents of the feature directory (spec, plan, tasks) and, on the first run after
  `refine`, creates the feature branch from the base branch. With a task file:
  stages the reviewed task's files, builds the commit message from the config format
  and marks the task committed. Deterministic; no judgement calls.
argument-hint: [feature slug, or path to task file]
disable-model-invocation: true
---

Read `${CLAUDE_PLUGIN_ROOT}/reference/lifecycle.md` first, then load the config.

Argument: $ARGUMENTS

Mode:
- The argument is a feature slug (or a path to `spec.md`) → **feature mode**: commit
  the feature's documents.
- The argument is a path to a task file → **task mode**: commit the task's changes.
- Anything else → stop and say which arguments are accepted.

Both modes start with the branch check.

## Branch check

The feature branch is `git.branch_format` with the feature slug (in task mode, the
`feature` field of the task frontmatter).

| Situation | Do |
|---|---|
| You are on the feature branch | Continue. |
| The branch exists, you are on another one | Ask with `AskUserQuestion`: switch to it (`git checkout <branch>`), or stop. |
| The branch does not exist, feature mode, you are on `git.base_branch` | Create it from there: `git checkout -b <branch>`. This is the normal start of a feature, right after `refine`. |
| The branch does not exist, feature mode, you are on another branch | Ask with `AskUserQuestion`: create it from `git.base_branch` (`git checkout -b <branch> <base_branch>`), or stop. |
| The branch does not exist, task mode | Stop: the branch is created by `/piotrgajow-workflow:commit <slug>`, never here. |

If git refuses a checkout because of local changes, show its message and stop.
Never stash, reset or discard anything to make a checkout work.

## Feature mode

1. `<work_dir>/<slug>/spec.md` must exist; otherwise stop and name
   `/piotrgajow-workflow:refine <ticket>`.
2. If `work_dir_gitignored` is true there is nothing to commit: report the branch
   state (created, or already on it) and skip to step 6.
3. List the uncommitted files, modified and untracked, under the feature directory.
   None → say so and skip to step 6. Split them into two groups: the spec
   (`spec.md`) and the plan (`plan.md` and everything under `tasks/`). Source
   changes of a task in flight stay in the working tree for
   `/piotrgajow-workflow:commit <task path>`.
4. For each non-empty group, spec first: stage only that group's files and build
   the subject from `git.docs_commit_format` with `{slug}` and `{summary}`:
   - spec group: `spec.md` new → `spec`; changed → `update spec`
   - plan group: `plan.md` new → `plan`; changed → `revise plan`; `plan.md`
     unchanged, only task files → `update tasks`

   No body.
5. Commit each group separately, in that order. Print the short hash and the
   subject of every commit made.
6. Print whether the branch was created, and the next step:
   - `plan.md` does not exist → `/piotrgajow-workflow:plan <slug>`
   - otherwise, for the first task in order that is neither `committed` nor
     `dropped`: `blocked` → `/piotrgajow-workflow:plan <task path>`; `done` →
     `/piotrgajow-workflow:commit <task path>`; anything else →
     `/piotrgajow-workflow:execute-and-review <task path>`
   - no such task → "all tasks committed"

## Task mode

1. Read the task file. Status must be `done`; otherwise stop and say which status
   you expected.
2. Compare `git status` (ignoring `work_dir`) against the task's `files`:
   - Files changed but not listed: stop and show them. Ask with `AskUserQuestion` whether to
     add them to the task's `files` or leave them out.
   - Files listed but unchanged: ignore.
3. Set `status: committed` in the task frontmatter.
4. Stage the task's `files`. If `work_dir_gitignored` is false, also stage the task
   file.
5. Build the subject from `git.commit_format` with `{slug}`, `{task_id}` (the task
   file name without extension) and `{task_title}` (the title line without its
   number). Body: the task's `## Goal` text. Do not add anything else to the message.
   **No `Co-Authored-By:` trailer and no other attribution line**, even if your
   default commit instructions ask for one. This step overrides them.
6. Commit. Print the short hash, the subject, and the next step,
   `/piotrgajow-workflow:execute-and-review <next task path>`, or "all tasks
   committed" when none is left in `todo`. If other files under the feature
   directory have uncommitted changes, list them and add
   `/piotrgajow-workflow:commit <slug>` as the step that commits them.

## Rules

- Never run verification; review already did.
- Never push.
- Never amend or rewrite history.
- Never add a `Co-Authored-By:` line or any other attribution to the commit message.
- Feature mode stages only files under the feature directory, and never mixes the
  spec and the plan in one commit. Task mode stages only the task's `files` and the
  task file itself.
- The only branch change made without asking is creating the feature branch from
  `git.base_branch` in feature mode. Every other switch or creation goes through
  `AskUserQuestion`; task mode never creates a branch.
- If `git.docs_commit_format` is missing from the config, stop and tell the user to
  add it (see the config template) or rerun `/piotrgajow-workflow:setup-workflow`.
