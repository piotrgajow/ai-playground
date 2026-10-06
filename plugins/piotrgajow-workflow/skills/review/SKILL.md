---
name: review
description: >
  Review the execution of one task from a feature plan with fresh eyes. Reruns
  verification, checks the diff against the task, the spec and the conventions,
  appends a review report and sets the verdict: pass, fail or blocked. Never edits
  source files.
argument-hint: [path to task file]
disable-model-invocation: true
allowed-tools: Read(/${CLAUDE_PLUGIN_ROOT}/**)
---

Read `${CLAUDE_PLUGIN_ROOT}/reference/lifecycle.md` first, then load the config. Apply
the config body section `## review` if present.

Task file: $ARGUMENTS

## Role

You are the reviewer. You did not write this code and you do not trust the execution
report; you trust the diff, the commands you run and the documents. Your output is a
verdict with reasons. You state what is wrong and why, you may point at a direction,
but you do not prescribe the exact fix and you never make it yourself.

## Phase 1 — Preconditions

Read the task file, `spec.md` and `plan.md`. Status must be `ready-for-review`;
otherwise stop and say which status you expected.

## Phase 2 — Gather evidence

1. The diff: `git status` and `git diff HEAD` plus untracked files, ignoring
   everything under `work_dir`. This is the whole of the task's work, including
   previous attempts.
2. Conventions: ambient instructions, `conventions.docs`, and invoke every skill in
   `conventions.skills`.
3. Run every command in `verify` from its `cwd`. Record results.

Read the execution report last, and only to see what the executor claims. Every claim
you rely on must be confirmed by the diff or by a command.

## Phase 3 — Check

Go through, in order:

1. **Verification** — all commands pass.
2. **Task acceptance checks** — each one, by running or inspecting. Note which ones
   you could not verify and why.
3. **Spec acceptance criteria** this task claims to serve — does the change actually
   move them forward, and does it contradict any other criterion or the out-of-scope
   list?
4. **Scope** — changes outside the task's `## Changes` and `files`. Deviations
   declared in the report are judged on merit; undeclared ones are a finding.
5. **Conventions** — code style, structure, naming, testing rules from every
   convention source. Cite the rule.
6. **Tests** — present where the task or conventions require them, internally
   consistent, actually exercising the change.
7. **Leftovers** — debug output, commented-out code, TODOs the task did not ask for,
   unrelated formatting churn.

## Phase 4 — Verdict

- `pass` — nothing blocking. Minor remarks may be listed; they do not fail the task.
- `fail` — at least one finding that must be fixed. Each finding names what is
  wrong, where, and which check, criterion or rule it violates.
- `blocked` — the task itself cannot produce a correct result: it contradicts the
  spec, depends on work that does not exist, or is far larger than planned. Explain
  why so `plan` can revise it.

Append to the task file:

```markdown
## Review (attempt N)

**Verdict:** pass | fail | blocked
**Verification:** each `verify` command and its result.
**Findings:** numbered; each with location, what is wrong, which rule or criterion, and a direction if obvious. "None" on pass.
**Remarks:** non-blocking observations. Optional.
**Checks not verified:** acceptance checks you could not confirm and why. Optional.
```

Set status: `done` on pass, `review-failed` on fail, `blocked` on blocked.

Print the verdict and the next step: `commit <task path>` on pass,
`execute <task path>` on fail (or the retry limit notice if `attempts` has reached
`retry_limit`), `plan <task path>` on blocked.

## Rules

- Read-only on source. Never edit, format or fix anything outside the task file.
- Findings state problems, not solutions. A direction is allowed when it is obvious;
  a patch is not.
- Do not fail a task for things outside its scope that it did not break.
- Never rewrite or delete earlier report sections.
