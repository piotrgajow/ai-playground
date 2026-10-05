---
name: character-build
description: Build and advance a tabletop RPG character – create a character sheet and level-by-level plan from a character idea file, extend the plan to higher levels, or carry out a level-up on the sheet – verified against the game system's resources.
argument-hint: create <idea-file> <sheet-level> [plan-level] [context-file] | plan <character-dir> <plan-level> [context-file] | level-up <character-dir> [target-level] [context-file]
disable-model-invocation: true
allowed-tools: Read, Write, Edit, WebFetch, AskUserQuestion, Bash(curl:*), Bash(jq:*), Bash(sed:*), Bash(grep:*), Bash(head:*), Bash(tr:*), Bash(cut:*), Bash(ls:*)
---

# Character build

Guide the user through a character's mechanical life: every choice at level 1 and at each level-up, recorded in two files:

- `sheet.md` – what the character **has** at their current level ("sheet level").
- `plan.md` – how the character was built and how they will develop, level by level, possibly beyond the sheet level.

## Modes

The first word of `$ARGUMENTS` selects the mode:

| Mode | Arguments | Does |
|---|---|---|
| `create` | `<idea-file> <sheet-level> [plan-level] [context-file]` | Creates `sheet.md` and `plan.md` from an idea file. |
| `plan` | `<character-dir> <plan-level> [context-file]` | Extends `plan.md` up to a higher level. `sheet.md` is not touched. |
| `level-up` | `<character-dir> [target-level] [context-file]` | Advances the character on `sheet.md` (default: one level) and marks the reached levels in `plan.md` as done. |

- **Idea file** – a character file produced by the `character-ideas` skill (concept, personality, build notes, sources). Its header line gives the system (e.g. `D&D 5e (2014)`).
- **Character dir** – the directory containing `sheet.md` and `plan.md`. The idea file is found through the link in their header line.
- **Context file** (optional) – the adventure context: party composition, setting, house rules, allowed sourcebooks.

If the mode is missing, infer it: an idea file → `create`; a character directory → ask whether to `plan` or `level-up`. If a required argument is missing, ask for it before doing anything else. Levels must make sense (plan level ≥ sheet level, target level > current sheet level); if not, ask.

## Language

- **Sheet:** entirely in English – headings, labels and items.
- **Plan:** in Polish, following the Language rules of the `character-ideas` skill (`.claude/skills/character-ideas/SKILL.md`): game mechanics keep their English names, with a Polish translation in parentheses where it helps; generic rules vocabulary may be Polish.
- Chat with the user in the language they write in.

## Using the resources

- Treat the idea file's **Build notes** as a starting point, not the final build. They may be written for a different level, contain mistakes, or conflict with the story. Recompute everything for the levels being worked on.
- Verify every choice against the resources listed in the idea file's and plan's **Sources**, plus class, subclass, race, background, feat and spell pages as needed. Follow the "Using the resources" section of the `character-ideas` skill for fetching, including the MediaWiki API fallback when WebFetch is blocked.
- Mark anything that could not be verified.

## Asking for decisions

Collect choices that change the build with the AskUserQuestion tool, batching related questions (max 4 per call). Every question must include an "I don't know" option – when chosen, use the recommended default and say so. Mark the recommended option first. Don't ask about things already settled by the idea file, context, plan or sheet. When an open choice has an obvious best fit for the concept, propose it in the draft and let the user override it instead of asking.

## File rules

Read both templates before writing a file. Compute relative links between the sheet, the plan and the idea file.

### Sheet – `.claude/skills/character-build/templates/sheet.md`

The character **at the sheet level**. The `character-cheatsheet` skill builds from the sheet alone, so the sheet must record every choice that can't be derived from the rules:

- Names only – no descriptions, derived stats or rules text. The only numbers allowed are ability scores (final, with all bonuses), the hit point maximum, counts (`Torch ×10`), gold, spell slot counts, levels, CR in feature names, and the value of costly material components (`Diamond (worth 300 gp)`).
- Only what the character has: no suggestions, alternatives, things to buy, or features from higher levels.
- Mark skills with expertise as `<Skill> (expertise)` and attuned magic items as `<Item> (attuned)`.
- Include the contents of packs, and background equipment.
- Record all money in the Gold section, not in Equipment.
- Story items from the idea file (e.g. keepsakes described in its Visual description) go into Equipment.
- Omit the Spells section for non-casters. Rename the spell groups to fit the class: `Domain spells (always prepared)`, `Oath spells (always prepared)`, `Prepared`, `Known`, `Spellbook`, etc.
- For a multiclass character, list each class with its level on the class line.

### Plan – `.claude/skills/character-build/templates/plan.md`

- A section for level 1 with numbered creation steps, the resulting numbers ("Wynik") and short tactics.
- A section per level-up, listing only what changes. Mark warnings with ⚠️.
- Sections up to the sheet level are plain (`## Poziom N`) and record what was actually chosen. Sections above the sheet level are marked as planned (`## Poziom N (planowany)`).
- A summary ("Wynik na poziomie N") with ability scores, core stats and attacks, placed at the end of the **sheet level** section. If the plan goes beyond the sheet level, add a second summary at the end of the **last planned level** section. There are never more than these two summaries.
- Sources at the end.

## Mode `create`

1. **Decisions.** Read the idea file (and the context file, if given). Ask the choices that change the build. Typical questions:
   - ability scores: point buy, standard array or rolled (if rolled, ask for the rolls)
   - hit points on level-up: fixed average or rolled
   - starting equipment: class/background equipment or starting gold
   - additional gold to spend or items to get, beyond class/background equipment – always ask whether the character has any
   - background, if the idea's background doesn't match its story
   - optional rules the GM may not allow (e.g. Tasha's optional class features, feats, variant races)
   - open choices from the class, race or background: languages, tools, weapons, fighting style, skills
2. **Draft.** Present in chat, concisely:
   - **Level 1** – ability scores (with racial bonuses), race, class, background, equipment and spells, with the resulting HP, AC, attacks, spell DC, saves, skills.
   - **Each level-up** to the plan level – HP, new features, ASI/feat choice, spell slots, new and prepared/known spells, cantrips, and changes to the numbers.
   - **Purchases** – if the character has additional gold or items, suggest what to buy or pick. Show the gold left over.
   - **Warnings** – rules traps, interactions with the party (e.g. effects that also hit allies), costly material components, things to ask the GM.

   Iterate on the user's feedback until they are happy. Keep changes targeted.
3. **Saving.** Ask for the **directory** for the files; suggest the parent directory of the idea file's directory (next to `ideas/`). Write `sheet.md` and `plan.md` there; if either already exists, ask before overwriting.

## Mode `plan`

1. Read `sheet.md`, `plan.md` and the linked idea file (and the context file, if given).
2. Ask the choices for the new levels: ASI or feat, subclass or multiclass decisions, fighting styles, invocations, new spells, and anything the plan's assumptions don't settle.
3. Draft the new levels in chat in the same form as `create` step 2, starting from the last level in the plan. If a new choice makes an earlier planned level worse (e.g. a feat that changes which ASI is best), say so and propose the change.
4. After the user accepts, update `plan.md`:
   - append a `## Poziom N (planowany)` section per new level, before `## Źródła`,
   - move the last-level summary to the new last level (keep the sheet-level summary where it is),
   - apply any accepted changes to earlier planned levels,
   - add new sources.

## Mode `level-up`

Advance one level at a time, repeating the steps below until the target level is reached.

1. Read `sheet.md`, `plan.md` and the linked idea file (and the context file, if given).
2. **Planned level.** If `plan.md` has no section for the new level, run the `plan` mode for it first.
3. **Changes from play.** Ask what changed since the sheet was last updated and isn't part of levelling: equipment gained, lost or bought, gold, new languages or proficiencies from the story, magic items. Include an option "Nothing changed".
4. **Level-up choices.** Walk through the planned section. Ask only about things that need a decision now:
   - HP roll, if the plan uses rolled HP (ask for the roll),
   - whether to follow the plan or deviate – offer the planned choice as recommended, plus sensible alternatives when the character's situation changed (e.g. items gained in play),
   - per-day choices that are best made now (e.g. which spells to prepare).
5. **Draft.** Show in chat the changes to the sheet (added and removed items, per section) and the updated numbers.
6. After the user accepts:
   - **`sheet.md`** – update the header level, class line and hit point maximum, and add/remove features, proficiencies, spells, slots, equipment and languages. Apply the file rules: names only, only what the character has.
   - **`plan.md`** – remove `(planowany)` from the reached level and record what was actually chosen there (including HP rolled and deviations). Move the sheet-level summary to the new sheet level, recomputed. If a deviation affects later planned levels, update them and tell the user what changed. If the new sheet level is the last level of the plan, keep a single summary there.

## Finishing

Report the paths of the written files and propose a commit message.
