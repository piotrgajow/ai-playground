---
name: session-retro
description: Run a retrospective on the current conversation. Identify every place the user corrected Claude's plan or actions and propose targeted updates so the same mistake will not repeat.
disable-model-invocation: true
---

# Retro

Turn corrections in the current chat into durable knowledge that prevents the same correction next time.

Work through the phases below in order. Do not skip ahead — Phase 4 (the plan) is worthless without Phases 1–3 done honestly.

---

## Phase 1 — Identify corrections

Scan the conversation from the start of the session up to the `/session-retro` invocation and find all "corrections". A "correction" is any user turn where they:

- Reject or stop a plan ("no", "stop", "don't do that")
- Reroute ("actually", "instead", "I meant", "what I want is")
- Demand a different format, length, tool, language, library, or file location
- Point out a factual or logical error
- Express frustration that you skipped a step, asked too late, or asked too much
- Redo your work themselves
- Tell you to use, or not use, an approach you didn't pick

Implicit corrections also count: if the user accepted your first output but then re-asked and got something different that they kept, the first try was wrong.

For each correction, capture:
- Approximate location (e.g. "after the first edit to `foo.py`")
- One-line summary of what you did or proposed
- A short verbatim snippet of the user's correction (so the user can place it)
- The corrected behavior — what you should have done
- Whether it recurred in the same session

Skip non-corrections: clarifying questions, scope expansions ("also do X"), natural follow-ups.

If you find no genuine corrections, say so plainly and stop. Do not invent corrections to have something to report.

---

## Phase 2 — Delegate inventory + matching to a subagent

Dispatch a single subagent (via the Task tool) that does both the inventory and the matching, then returns compact structured findings.

The subagent does not have access to the conversation, so the corrections list from Phase 1 must be passed in full inside the prompt.

**Dispatch the subagent with a prompt of this shape:**

```
You are auditing a Claude Code project's knowledge base to determine whether
documented guidance could have prevented a set of corrections the user made
during a recent session.

# Corrections to evaluate
<paste the full Phase 1 list here, numbered, with: summary of what Claude did,
verbatim user correction, the corrected behavior, recurrence flag>

# Knowledge sources to scan (in this order, stop when you have enough context)
1. ./CLAUDE.md (walk up to repo root if not in cwd)
2. ~/.claude/CLAUDE.md
3. ./.claude/skills/*/SKILL.md 
4. ~/.claude/skills/*/SKILL.md 
5. ./README.md, ./README.*
6. ./docs/**/*.md, ./doc/**/*.md
7. Other documentation (e.g. referenced in the sources above)

# For each correction, classify as exactly one of:
- covered-and-ignored — relevant guidance exists and was missed. Cite path:line
  and diagnose *why* it didn't fire (skill description didn't match the user's
  phrasing, rule buried in a long file, skill not auto-loadable, conflict with
  another rule, etc).
- covered-but-ambiguous — guidance touches the topic but doesn't settle it.
  Cite the ambiguous text.
- not-covered — genuine gap.
- user-override — user knowingly chose differently from documented guidance
  for this one case.

When deciding "covered", check both literal wording and intent. Do NOT claim
coverage based on a vague related sentence.

# Output format — return ONLY this, nothing else
For each correction, one block:

## Correction <N>
- classification: <one of the four labels>
- citation: <path:line> | none
- evidence: "<short verbatim snippet from the cited file>" | none
- diagnosis: <one or two sentences>

After the per-correction blocks, add:

## Knowledge map
- <file path>: <one-line summary of what it covers>
- ...
(Only include files that are actually relevant to one or more corrections.)
```

The subagent will return a compact analysis. Use it directly in Phase 3 — do not re-read the source files yourself unless something in the subagent's output looks wrong or incomplete.

---

## Phase 3 — Sanity-check the subagent's output

Before building the plan, scan the returned analysis:

- Is every correction classified?
- Do citations look real (plausible paths, line numbers in range)?
- Is any diagnosis hand-wavy or contradictory?

If something is clearly off, either re-dispatch with a sharper prompt for the specific corrections in question, or read the one or two files directly to verify. Do not silently accept a bad analysis — Phase 4 depends on this being right.

---

## Phase 4 — Build the plan

For each correction that needs a fix, pick a placement using this table:

| Type of fix                                        | Placement                                                                                                |
|----------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| Generic project-specific rule, fact, or convention | `./CLAUDE.md`                                                                                            |
| Personal preference across projects                | `~/.claude/CLAUDE.md`                                                                                    |
| Multi-step workflow or repeatable procedure        | new skill: `./.claude/skills/<name>/SKILL.md` (project) or `~/.claude/skills/<name>/SKILL.md` (personal) |
| Reference data (API shape, glossary, schema)       | new file in `./docs/` + one-line pointer from CLAUDE.md                                                  |
| Existing skill failed to trigger                   | tweak that skill's `description` (front-load trigger phrases)                                            |
| Existing rule was buried or unclear                | restructure: hoist it, add a heading, or split the file                                                  |

Each proposal must include:
- File path
- Action: `create`, `edit`, or `tweak-frontmatter`
- The exact text being added or changed (keep it minimal)
- One-sentence rationale

Watch for:
- **CLAUDE.md bloat** — over ~200 lines is a yellow flag. Suggest moving content into skills before adding more.
- **Conflicts** — if a proposal contradicts existing guidance, surface the conflict and ask the user to choose.
- **Over-codification** — if a correction was a one-off taste call, ask before adding a permanent rule.

---

## Phase 5 — Present the plan

Use this format. Keep entries terse — no padding.

```
## Retro: <N> corrections found

### 1. <short title>
- What happened: <one line>
- User said: "<verbatim snippet>"
- Existing guidance: <path:line> | none
- Diagnosis: <why it wasn't prevented>
- Proposal: <action> `<path>` — <one-line summary>

### 2. ...

---
Edits queued: <N> file edits, <N> new files, <N> description tweaks.
Reply "approve all", or comment per item ("skip 2; change 3 to ...").
```

Ask clarifying questions only if you genuinely need them to proceed. Don't pad with optional questions.

---

## Phase 6 — Self-improve based on the user's feedback

This skill exists to make Claude better. It should hold itself to the same standard. After the user has reviewed the plan in Phase 5 but **before** any edits are applied, compare what you proposed against what the user approved or modified. If a clear signal emerges, draft an improvement to *this skill itself*.

This skill is distributed as a plugin. Its `SKILL.md` lives in a managed, read-only plugin directory — editing that copy in place is pointless: a plugin update overwrites it and the change never reaches other users. So **do not write to the skill file**. Instead, emit the improvement as a suggestion the maintainer can take upstream to the plugin's source repo.

Watch for these patterns:

| User did | Signal | Likely fix in SKILL.md |
|---|---|---|
| Said "this wasn't a real correction" | Phase 1 over-triggered | Tighten correction criteria, add a non-correction example |
| Pointed out a correction you missed | Phase 1 under-triggered | Expand correction criteria to cover that pattern |
| Rejected a "covered_and_ignored" classification | Phase 2 subagent over-claimed coverage | Tighten the "covered" rubric in the subagent prompt |
| Rejected a "not_covered" when guidance existed | Phase 2 subagent missed a source | Add the missed location to the inventory list |
| Moved a fix from CLAUDE.md → skill (or vice versa) | Phase 4 placement table is off for this user/project | Adjust the placement table or add a note |
| Reworded a proposal substantially | Phase 4 proposal style needs tuning | Adjust proposal format or rationale criteria |
| Did this multiple times in the same retro | Strong signal — weight accordingly | Bigger change |

Do **not** propose self-changes for:
- Pure typo fixes or whitespace tweaks
- Single-instance taste calls with no clear pattern
- Cases where the user explicitly said "this is fine, just one-off"

If no pattern is clear enough, skip this phase — say one line ("No skill-level changes warranted from this retro") and move on. False-positive self-changes degrade the skill faster than missing real ones.

If a pattern is clear, present the improvement as a standalone block labelled `[skill-improvement suggestion]`, separate from the Phase 7 edit queue (it is a recommendation, not a queued write). Include:
- **Target**: the section of this `SKILL.md` to change (e.g. "Phase 1 correction criteria").
- **Proposed change**: the exact diff or replacement text.
- **Rationale**: one sentence tying it to what the user did this session.
- **How to apply**: "Open an issue or PR against the plugin's source repo with this change — it cannot be applied to the installed copy."

---

## Phase 7 — Apply edits

After the user reviews and approves the full queue, for each edit in order (the Phase 6 skill-improvement suggestion is not part of this queue — it is emitted as a recommendation, not written):

1. Show the exact diff (or full content for new files).
2. Ask "apply?" — accept any clear yes/no.
3. Write only on yes.
4. Move to the next.

If the user said "approve all" upfront, batch the writes but still print each diff as you go so they can interrupt.

For new skill files, include valid YAML frontmatter (`name`, `description`, optionally `disable-model-invocation`). Front-load trigger keywords in the description so the skill actually loads when needed.

---

## Tone

Direct and factual. No flattery, no apologies for the corrections — just analyze them. The user ran this skill to make Claude better, not to extract contrition.
