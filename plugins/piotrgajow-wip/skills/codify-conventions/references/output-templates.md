# Output templates

Three artifacts. Fill from WIP.md; nothing goes in that the user did not accept.

---

## 1. `.claude/skills/<slug>/SKILL.md`

```markdown
---
name: <slug>
description: >
  How <topic> are built in this repository. Use this skill whenever you add a new
  <thing>, change or extend an existing one, fix a bug in one, refactor or move one,
  or review code that touches <where they live>. Trigger even when the task is
  described indirectly ("the round page shows the wrong date", "add a column to the
  ranking table") as long as the files involved are <thing>s.
---

# <Topic>

<One or two sentences: what a <thing> is here and what it is responsible for.>

This skill is self-sufficient: the anatomy, rules and canonical example below are
everything needed for the task. Do not search the codebase for other examples; read
only the canonical example and the files you are changing. Explore further only when a
task needs something this skill does not cover, and say so.

## Anatomy

<Where things live and how they connect, so nothing has to be discovered. Concrete
paths and name patterns, not prose.>

- Files per <thing>: `<dir>/<Name>/<Name>.tsx`, `<Name>.test.tsx`, ... — <what each holds>
- Naming: <pattern>
- Wiring: <every place a new <thing> must be registered or imported: router, index,
  barrel, DI module, config; each as a path plus what to add>

## Canonical example

Read this one file before writing a new instance. Match it.

- `<path>` — <why it was chosen>

What to copy from it, in order:
1. <part, e.g. "imports and props type at the top"> — <the convention it shows>
2. <...>

Variants (only when the user accepted more than one valid shape):
- `<path>` — use when <condition>; differs in <what>

## Rules

<Grouped by the scan categories that have accepted rules. Each rule: one imperative
line, plus a half-sentence why where the why is not obvious. Rules the code does not
follow yet carry a `(new convention)` suffix.>

### Layout and wiring
- ...

### Structure
- ...

### Data and state
- ...

### Tests
- ...

## Don't

<Accepted anti-patterns, each one line. This list is usually read more carefully
than the rules; put the costly mistakes here.>

- ...

## Procedures

<Only when a flow has steps that are easy to miss. Otherwise omit the section.>

### Adding a new <thing>
1. ...

### Changing or fixing an existing one
- <checks that apply: keep the shape, update sibling files, run X tests>

## See also

- `references/rationale.md` — why the rules are what they are, for when a task seems
  to call for breaking one
- <existing CLAUDE.md or rule this skill extends, if any>
```

Guidance:

- The description is the only thing in context before the skill triggers. Name the
  lifecycle verbs explicitly (add, change, extend, fix, refactor, review) and the file
  area, and include one or two indirect phrasings. Be pushy; under-triggering is the
  common failure.
- Prefer "do X" over "always do X". Reserve emphasis for rules whose violation is
  expensive, and say why it is expensive.
- Reference files by path. Verify every path exists before finishing.
- The canonical example must itself follow every accepted rule. If no existing file
  does, say so in the skill and name the closest one with the rules it breaks; never
  pick a file that contradicts the skill.
- Anatomy and the example walkthrough are what spare a future session from running
  discovery. If a session would still have to grep to know where a new file goes or
  what to register, the anatomy is incomplete.
- Last line of SKILL.md: `Verified against <short commit hash> on <date>.` so
  staleness is visible.
- Under ~150 lines. Put long how-tos in `references/`.

## 2. `.claude/skills/<slug>/references/rationale.md`

One `##` per rule that had a discussed trade-off or an explicit alternative the user
considered. Record what was chosen, what was rejected, and why, in two to four
sentences. Skip rules nobody questioned. This file exists so a future session that is
tempted to deviate can see whether the deviation was already considered.

## 3. `.claude/rules/<slug>.md` (companion rule, optional)

```markdown
---
paths:
  - <glob derived from evidence file locations>
  - <...>
---
# <Topic>: hard constraints

- <must/never item 1>
- <must/never item 2>
- <at most ~8 items>

Procedure, reference implementations and rationale: skill `<slug>`.
```

Guidance:

- Only rules whose violation is clearly wrong, not preferences. If every rule is a
  preference, propose no companion rule and say why.
- Globs cover where instances live, not the whole app. Derive them from the evidence
  file paths and check them against the actual tree.
- This file loads on every Read/Edit of a matching file. Keep it short.

## 4. Deviations list (printed, saved only on request)

```markdown
# <Topic> — deviations from accepted conventions

## <rule, one line>
- `<path>` — <what is off, few words>
- ...

## <rule> (new convention)
- ...
```

Group by rule, rules in the same order as in SKILL.md, new conventions last.
