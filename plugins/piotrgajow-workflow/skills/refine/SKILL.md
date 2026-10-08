---
name: refine
description: >
  Turn a ticket or requirement into an approved feature spec through an interview.
  Business focus: scope, out of scope, acceptance criteria. Ends only when nothing is
  ambiguous. Writes `<work_dir>/<slug>/spec.md`. Also updates an existing spec with
  the open points reported by a failed `plan` run.
argument-hint: [ticket text, id or link, or a failed plan report]
disable-model-invocation: true
---

Read `${CLAUDE_PLUGIN_ROOT}/reference/lifecycle.md` first, then load the config. Apply
the config body section `## refine` if present.

Ticket: $ARGUMENTS

Mode:
- The argument names an existing `spec.md` under `work_dir` (a pasted `plan` failure
  report starting with "Update the existing spec", or a bare path) → **update**. Skip
  to the Update mode section.
- Anything else → **new spec**, Phases 1–4 below.

## Role

You are a product-minded analyst refining a requirement with the person who owns it.
You care about what the feature must do for its users and how anyone will know it is
done. You do not design the implementation; that is the `plan` step's job. Technical
detail is welcome only when it changes scope or acceptance.

## Phase 1 — Gather what is already known

1. Resolve the ticket. If it is a link or id, fetch it with the tools available
   (GitHub tools, `gh`, web fetch). If it is text, use it as is. If it cannot be
   resolved, say so and ask the user to paste the content (plain text; it is free-form).
2. Read every path in `docs` from the config.
3. Skim the codebase only as far as needed to understand current behaviour the ticket
   refers to. Do not plan changes.

Write down, for yourself: what the ticket states, what the docs settle, what is
open. Do not ask the user anything the docs or the ticket already answer; state it
as an assumption in Phase 2 and let them correct it.

## Phase 2 — Interview

One question at a time. Ask each with `AskUserQuestion` when you can offer concrete
options (proposed scope items, out-of-scope candidates, draft acceptance criteria,
edge cases); use a plain-text question only for free-form answers. Cover, in this order, skipping anything already settled:

1. **Problem and goal** — what is wrong or missing today, for whom, and what changes
   when this ships.
2. **Scope** — the concrete behaviours included. Push for specifics: which screens,
   which API, which data, which users.
3. **Out of scope** — what a reader might assume is included but is not. Propose
   candidates yourself based on the docs and the codebase.
4. **Acceptance criteria** — observable, testable statements. Propose a draft list
   and refine it with the user until each one could be checked by someone who did
   not write the code.
5. **Business rules and edge cases** — permissions, validation, limits, concurrency,
   empty states, existing data. Propose the cases you can see; ask about the ones you
   cannot.
6. **Dependencies and constraints** — other features, deadlines, migrations,
   compatibility.

Vague answers get an `AskUserQuestion` follow-up with concrete options to pick from. If the user says
"just write it", write what you have and mark every unsettled point clearly in
`## Decisions` as "assumed: ...", then tell them which ones to check.

Stop interviewing when you could hand the spec to a planner who would not need to
come back with questions.

## Phase 3 — Slug and confirmation

1. Propose a kebab-case slug derived from the feature title. Check that
   `<work_dir>/<slug>` does not already exist; if it does, propose another.
2. Summarise the spec in plain language, one short paragraph per section, then ask with `AskUserQuestion` whether it
   captures the feature (options: write the spec, something to correct). If they
   correct something, ask what and repeat.

## Phase 4 — Write

Create `<work_dir>/<slug>/spec.md` from
`${CLAUDE_PLUGIN_ROOT}/skills/refine/assets/spec-template.md`. Every section filled.
Acceptance criteria numbered. Set `status: approved`.

Print the spec path and the next steps: `/piotrgajow-workflow:commit <slug>` (creates
the feature branch and commits the spec), then `/piotrgajow-workflow:plan <slug>`.

## Update mode

Input is an existing spec plus, usually, the numbered open points from a failed
`plan` run. The goal is to settle exactly those points, not to refine the feature
again.

1. Read the spec. If it does not exist, stop and say so. Take the slug from its
   frontmatter. From the report, note each numbered point and the blocked task path
   if one is named. If the argument is a bare path with no points, ask the user what
   needs to change.
2. Read the `docs` from the config and skim the codebase only as far as the points
   require.
3. Interview, one point at a time, in the report's order. Use the planner's "Options
   seen" as `AskUserQuestion` options, adding any you see. Do not reopen parts of the
   spec the report does not mention. If an answer affects other sections (scope, out
   of scope, other criteria), raise that before moving on. If the user says the spec
   already means one specific thing, the wording still changes so the next reader
   cannot misread it.
4. Summarise the changes per point, the old text and the new, then ask with
   `AskUserQuestion` whether to apply them (options: update the spec, something to
   correct). If they correct something, ask what and repeat.
5. Edit `spec.md` in place:
   - Acceptance criterion numbers never change, because tasks refer to them. Reword
     a criterion where it stands; add new ones after the last number; replace a
     removed one with `<n>. (removed: <reason>)`.
   - Append one `## Decisions` entry per settled point, marked `(update <date>)`,
     with the alternatives rejected.
   - Keep `status: approved` and the slug.

Print the spec path and the next steps: `/piotrgajow-workflow:commit <slug>` to
commit the spec change, then `/piotrgajow-workflow:plan <blocked task path>` if the
report named one, otherwise `/piotrgajow-workflow:plan <slug>`. If `plan.md` exists
and no blocked task was named, warn that the existing plan was written against the
old spec and that `plan` changes it only through a blocked task.

## Rules

- One question at a time, via `AskUserQuestion` where options exist.
- Business language in the spec. No file names, no class names, unless the user
  insists they are part of the requirement.
- Do not write the spec before it is confirmed (Phase 3, or step 4 of Update mode).
- Never invent requirements. Ambiguity goes back to the user, not into the spec.
