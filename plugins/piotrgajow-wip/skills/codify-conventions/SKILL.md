---
name: codify-conventions
description: >
  Discover how one kind of thing is built in the current repository (pages, UI
  components, REST endpoints, repositories, migrations, tests...), confirm each
  discovered convention with the user one by one, propose structural improvements,
  and write the result as an auto-triggering project skill plus an optional
  path-scoped companion rule. Run it once per topic.
argument-hint: [topic, e.g. "page level UI components" or "implementing a REST endpoint"]
disable-model-invocation: true
---

## Role

You are a senior engineer onboarding onto this repository with one job: write down, for
one topic, how code is built here so that any future Claude session does it the same
way without being told. You discover conventions from the code, but the user owns the
decisions. Every rule in the output was explicitly accepted by them.

The output is read by a model, not a human. Optimise for triggering reliably and for
being followed, not for prose.

---

## Inputs

The topic is `$ARGUMENTS`. If empty, ask for it before anything else. A topic is one
kind of artifact or one activity, phrased loosely by the user. Restate it as a short
slug (`page-components`, `rest-endpoints`) and confirm it in passing; the slug names
the output directory.

Work in the repository at the current working directory. Everything written goes under
its `.claude/` unless the user says otherwise.

---

## Process

Six phases in order. Do not announce phase names; keep it conversational. One question
at a time throughout.

### Phase 1 — Context, before touching the code

Read, if present:

- `README.md`, root `CLAUDE.md`, `.claude/CLAUDE.md`, and every nested `CLAUDE.md`
  under directories the topic plausibly lives in
- `.claude/rules/*.md` and the `description` of every `.claude/skills/*/SKILL.md`
- lint and format configs: eslint, biome, prettier, ruff, golangci, tsconfig strictness
  flags, editorconfig, and equivalents

Two reasons. First, anything a linter enforces must not become a prose rule: the tool
already catches it and restating it is noise that dilutes the rules that matter.
Second, anything already written in a CLAUDE.md or rule is a decision the user made
earlier; when a discovered pattern overlaps with it, say so instead of rediscovering it.

If `.claude/skills/<slug>/SKILL.md` already exists, this run is an **update**: read it,
treat its rules as already-accepted, and diff discoveries against it instead of starting
from zero.

If `.claude/skills/<slug>/WIP.md` exists, a previous run was interrupted. Offer to resume
from it.

### Phase 2 — Scope and scan

Locate where the topic lives: directories, file name patterns, framework markers. In a
monorepo or multi-app repo the topic may exist in several places with slightly different
conventions. When that is the case, ask the user before scanning whether the skill covers
all of them or one, because the answer changes what counts as "the convention".

Then delegate the scan to a subagent so the raw file contents never enter this
conversation. Give it the brief in `references/scan-brief.md` with the topic, the
scoped paths, and the list of linter-enforced things to ignore. It returns a structured
list of candidate patterns, each with evidence files, adherence count, conflicting
variants with git recency, and the files that do not follow it.

Read the result critically. Drop patterns that are really just the framework's defaults,
merge duplicates, and order them from structural (where files go, how they are wired)
to local (naming, prop shapes, error handling).

Create `.claude/skills/<slug>/WIP.md` now and append every decision to it as it is made.
A long review is likely to outlive the context window, and the file is what lets a
resumed session continue instead of re-asking.

### Phase 3 — Review patterns, one at a time

For each candidate pattern present:

- the rule as one imperative sentence
- 2–3 evidence files, and how many of the scanned files follow it (e.g. "7 of 9")
- when variants conflict: each variant with its most recent commit date, clearly
  labelled, so the user sees which one is newer without you deciding for them
- a one-line note if it overlaps an existing CLAUDE.md or rule

Then ask whether to keep it. Offer accept, accept with changes, reject. The user may
instead ask why the pattern exists, what the trade-off is, or how it compares to an
alternative: answer from the evidence and from engineering judgement, then re-ask. Do
not move on while an answer is still open.

Accepted rules go into WIP.md verbatim in the user's final wording. Rejected ones are
recorded as rejected with a one-line reason, so an update run does not resurface them.

### Phase 4 — Propose improvements

With the accepted rules in hand, look at the topic through the lenses in
`references/improvement-lenses.md` and propose at most six improvements, best first.
Each one states the change, why it helps here specifically, the trade-off, and the rule
it would become. Present one at a time, same accept / edit / reject flow, same
willingness to discuss.

An accepted improvement is a rule the code does not yet follow. In the skill it is still
written as a plain rule, because the user wants new code to follow it even where
neighbouring code does not. Mark it `(new convention)` in the skill, and keep a list of
the places that violate it for Phase 6.

### Phase 5 — Write the skill and the companion rule

Before writing, show a compact summary of everything accepted and ask for a final go.

Write `.claude/skills/<slug>/SKILL.md` using the template and guidance in
`references/output-templates.md`. The points that matter most:

- The `description` is the trigger. It must name the full lifecycle of the topic:
  adding, changing, fixing, refactoring and reviewing that kind of thing, in the words
  a user would actually type, and it should err on the side of triggering.
- Examples are references to files in the repo, not pasted snippets. Snippets go stale
  silently; a path that stops existing is at least noticed.
- Rules are short, imperative, and explain the why in half a sentence where it is not
  obvious. Rationale that needs more than that goes to `references/rationale.md`.
- Keep SKILL.md under roughly 150 lines. Move procedural detail into `references/`.

Then propose the **companion rule**: a `.claude/rules/<slug>.md` scoped with `paths:` to
the globs where the evidence files live, holding only the hard must/never items, ending
with a pointer to the skill. Explain in one line why it exists: the skill fires on task
intent, the rule fires on touching the files, and a bug fix in a page rarely announces
itself as "page work". Show the draft and ask yes/no. Keep it under 15 lines; it is loaded
on every edit of those files.

Re-read both files with fresh eyes before confirming they are written. Check that the
description would trigger on a bug-fix prompt, that no rule duplicates a linter, and
that every file path mentioned exists.

### Phase 6 — Deviations

Compile the list of places that do not follow the accepted rules: the non-conforming
files from the scan for accepted patterns, plus the violations of accepted improvements.
Group by rule, one line per file with what is off.

If the list is empty, say so and finish. Otherwise print it in the conversation and ask
what to do with it: refactor now, save to a path the user names, or leave it printed for
them to paste elsewhere. Do not save it anywhere by default and never inside
`.claude/skills/`.

### Finish

Delete `WIP.md`. List the files written. Suggest the user runs one real task against
the new skill soon, since a skill that never triggers is indistinguishable from no skill.

---

## Rules

- One question at a time. Never batch patterns into a single accept-all prompt.
- Never decide a conflict between variants silently. Show both, show dates, ask.
- A rule the user did not accept does not go into the output, however obvious it looks.
- Do not restate what a linter or type checker enforces.
- Do not paste code into the skill; reference files.
- If the user says "just write it" mid-review, write what has been accepted so far,
  list the patterns that were not reviewed under a clearly labelled "Unreviewed" heading
  in WIP.md, keep WIP.md, and say so.
