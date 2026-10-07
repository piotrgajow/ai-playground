---
name: setup-workflow
description: >
  Set up the agentic development workflow in the current repository. Inspects the
  repo, proposes config values with evidence, confirms every one of them with the
  user, and writes `.workflow/config.md`. Run once per repository, or again to
  update the config.
disable-model-invocation: true
---

## Role

You are configuring the workflow for this repository. Your job is to find out how
this project is built, verified and documented, and to record it so the other
workflow steps can rely on it. Everything you find is a proposal until the user
confirms it. Do not write anything before the final confirmation, except the
permission rule in Phase 0.

## Phase 0 — Allow plugin reads

Before anything else, make sure `<git root>/.claude/settings.json` contains
`Read(~/.claude/plugins/cache/piotrgajow/piotrgajow-workflow/**)` in
`permissions.allow`, so the other workflow steps can read their templates without
prompting.

- If the file does not exist, create it (and `.claude/`) with:
  `{"permissions": {"allow": ["Read(~/.claude/plugins/cache/piotrgajow/piotrgajow-workflow/**)"]}}`
- If it exists, merge the entry in and keep everything else unchanged. Use `jq`.
  Do not add the entry twice.
- Do this without asking, and mention it in the final report.

Only after this is done, read `${CLAUDE_PLUGIN_ROOT}/reference/lifecycle.md`.

## Phase 1 — Inspect

Find the git root. If `.workflow/config.md` already exists, read it: this is an
update, and existing values are the starting proposals.

Look for evidence for each config field:

| Field | Where to look |
|---|---|
| `verify` | `package.json` scripts (root and workspaces), `Makefile`, `pyproject.toml`, CI workflows in `.github/workflows/`, lint/test config files |
| `docs` | `docs/`, `resources/`, `README.md` links, files named like PRD, spec, architecture |
| `conventions.docs` | Convention-like documents that are not `CLAUDE.md` or `.claude/rules/*` (those load ambiently and must not be listed) |
| `conventions.skills` | `.claude/skills/*/SKILL.md` whose description reads like a how-to for changing code |
| `git.base_branch` | Default branch from `git symbolic-ref refs/remotes/origin/HEAD` or `main`/`master` presence |
| `git.branch_format`, `git.commit_format` | Recent `git log` subjects and branch names |
| `work_dir`, `work_dir_gitignored` | Existing `.workflow/` dir, `.gitignore` |
| `tickets.source` | Issue templates, links in README, mentions of Jira/Linear/GitHub issues |

Do not run build or test commands during inspection. Reading scripts is enough.

## Phase 2 — Confirm findings

Present one table with every field, the proposed value and the evidence
(`file:line` or "not found"). Then walk through the fields one at a time and ask the
user to confirm or correct. Group closely related fields (the `verify` list, the
`git.*` fields) into one question each. Use `AskUserQuestion` where the choice is
between concrete options; ask in plain text where the answer is free-form.

Rules for this phase:

- Every field is confirmed explicitly, including the ones you are sure about.
- A field with no evidence is asked as an open question with the template default
  as the suggested answer.
- For `verify`, confirm each command separately: name, command, working directory.
  Ask which ones must pass before a task is considered done; drop the rest.
- For `work_dir_gitignored`, explain the trade-off in one sentence: tracked means
  specs and task history live in the repo and get committed with the code; ignored
  means they stay local.
- `retry_limit` default is 2. Ask only if the user has not stated a preference.

## Phase 3 — Write

Print the complete config file exactly as it will be written. Ask for a final OK.
On OK:

1. Write `<git root>/.workflow/config.md` from `assets/config-template.md` with
   the confirmed values. Keep the body sections; fill them only with guidance the
   user gave during the interview.
2. Create `work_dir` if it does not exist.
3. If `work_dir_gitignored` is true, add `work_dir` to `.gitignore` unless already
   covered.

Report what was written and how to start: `refine <ticket>`.

## Rules

- No guessing. If you cannot find evidence, say so and ask.
- Never list `CLAUDE.md` or `.claude/rules/*` in `conventions.docs`.
- Do not modify anything outside `.workflow/`, `.gitignore` and
  `.claude/settings.json` (Phase 0 only).
