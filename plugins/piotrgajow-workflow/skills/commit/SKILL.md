---
name: commit
description: >
  Commit the changes of one reviewed task from a feature plan. Stages the task's
  files, builds the commit message from the config format and marks the task
  committed. Deterministic; no judgement calls.
argument-hint: [path to task file]
disable-model-invocation: true
allowed-tools: Read(/${CLAUDE_PLUGIN_ROOT}/**)
---

Read `${CLAUDE_PLUGIN_ROOT}/reference/lifecycle.md` first, then load the config.

Task file: $ARGUMENTS

## Steps

1. Read the task file. Status must be `done`; otherwise stop and say which status
   you expected.
2. Check you are on the feature branch (`git.branch_format` with the feature slug).
   If not, stop and ask.
3. Compare `git status` (ignoring `work_dir`) against the task's `files`:
   - Files changed but not listed: stop and show them. The user decides whether to
     add them to the task's `files` or leave them out.
   - Files listed but unchanged: ignore.
4. Set `status: committed` in the task frontmatter.
5. Stage the task's `files`. If `work_dir_gitignored` is false, also stage the task
   file, and `spec.md` and `plan.md` when they have uncommitted changes.
6. Build the subject from `git.commit_format` with `{slug}`, `{task_id}` (the task
   file name without extension) and `{task_title}` (the title line without its
   number). Body: the task's `## Goal` text. Do not add anything else to the message.
7. Commit. Print the short hash, the subject, and the next task to execute, or
   "all tasks committed" when none is left in `todo`.

## Rules

- Never run verification; review already did.
- Never push.
- Never amend or rewrite history.
- Never stage files outside the task's `files` and the feature directory.
