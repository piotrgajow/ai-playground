---
name: character-create
description: Turn a character idea file (from character-ideas) into a character sheet at a given level and a level-by-level plan up to a given (possibly higher) level, verified against the game system's resources.
argument-hint: <idea-file> <sheet-level> [plan-level] [context-file]
disable-model-invocation: true
allowed-tools: Read, Write, WebFetch, AskUserQuestion, Bash(curl:*), Bash(jq:*), Bash(sed:*), Bash(grep:*), Bash(head:*), Bash(tr:*), Bash(cut:*), Bash(ls:*)
---

# Character creation from an idea

Guide the user from a finished character idea to a playable character: every choice made at level 1 and at each level-up, and a sheet listing what the character has.

## Inputs

`$ARGUMENTS` should contain:

1. **Idea file** – a character file produced by the `character-ideas` skill (concept, personality, build notes, sources). Its header line gives the system (e.g. `D&D 5e (2014)`).
2. **Sheet level** – the level the character is being created at.
3. **Plan level** (optional) – how far the level-up plan goes. Defaults to the sheet level. Must be ≥ sheet level; if lower, ask.
4. **Context file** (optional) – the adventure context: party composition, setting, house rules, allowed sourcebooks.

If the idea file or sheet level is missing, ask for it before doing anything else.

## Language

- **Sheet:** entirely in English – headings, labels and items.
- **Plan:** in Polish, following the Language rules of the `character-ideas` skill (`.claude/skills/character-ideas/SKILL.md`): game mechanics keep their English names, with a Polish translation in parentheses where it helps; generic rules vocabulary may be Polish.
- Chat with the user in the language they write in.

## Using the resources

- Treat the idea file's **Build notes** as a starting point, not the final build. They may be written for a different level, contain mistakes, or conflict with the story (e.g. a background that no longer fits a rewritten Historia). Recompute everything for the requested levels.
- Verify every choice against the resources listed in the idea file's **Sources**, plus class, subclass, race, background, feat and spell pages as needed. Follow the "Using the resources" section of the `character-ideas` skill for fetching, including the MediaWiki API fallback when WebFetch is blocked.
- Mark anything that could not be verified.

## Step 1 – Decisions

Read the idea file (and the context file, if given). Then collect the choices that change the build, with the AskUserQuestion tool, batching related questions (max 4 per call). Every question must include an "I don't know" option – when chosen, use the recommended default and say so. Mark the recommended option first. Typical questions:

- ability scores: point buy, standard array or rolled (if rolled, ask for the rolls)
- hit points on level-up: fixed average or rolled
- starting equipment: class/background equipment or starting gold
- background, if the idea's background doesn't match its story
- optional rules the GM may not allow (e.g. Tasha's optional class features, feats, variant races)
- open choices from the class, race or background: languages, tools, weapons, fighting style, skills

Don't ask about things the idea file or context already settles. When there are open choices with an obvious best fit for the concept, propose it and let the user override it in Step 2 instead of asking.

## Step 2 – Draft

Present in chat, concisely:

1. **Level 1** – ability scores (with racial bonuses), race, class, background, equipment and spells, with the resulting HP, AC, attacks, spell DC, saves, skills.
2. **Each level-up** to the plan level – HP, new features, ASI/feat choice, spell slots, new and prepared/known spells, cantrips, and changes to the numbers.
3. **Warnings** – rules traps, interactions with the party (e.g. effects that also hit allies), costly material components, things to ask the GM.

Iterate on the user's feedback (swaps of spells, equipment, feats, languages) until they are happy. Keep changes targeted.

## Step 3 – Saving

Read both templates first. Ask for the **directory** for the files. Suggest the parent directory of the idea file's directory (next to `ideas/`). Write two files there, `sheet.md` and `plan.md`; if either already exists, ask before overwriting. Compute the relative links between the sheet, the plan and the idea file.

### Sheet – `.claude/skills/character-create/templates/sheet.md`

The character **at the sheet level**:

- Names only – no descriptions, stats, numbers or rules text. The only numbers allowed are counts (`Torch ×10`, `10 gp`), spell slot counts, levels, and CR in feature names.
- Only what the character has: no suggestions, alternatives, things to buy, or features from higher levels.
- Include the contents of packs, and background equipment.
- Story items from the idea file (e.g. keepsakes described in its Visual description) go into Equipment.
- Omit the Spells section for non-casters. Rename the spell groups to fit the class: `Domain spells (always prepared)`, `Oath spells (always prepared)`, `Prepared`, `Known`, `Spellbook`, etc.
- For a multiclass character, list each class with its level on the class line.

### Plan – `.claude/skills/character-create/templates/plan.md`

- A section for level 1 with numbered creation steps, the resulting numbers ("Wynik") and short tactics.
- A section per level-up up to the plan level, listing only what changes. Mark warnings with ⚠️.
- A summary ("Wynik na poziomie N") with ability scores, core stats and attacks, placed **at the sheet level**. If the plan goes beyond the sheet level, add the same summary at the plan level too, and mark the sections above the sheet level as planned (`## Poziom N (planowany)`).
- Sources at the end.

After saving, report the paths and propose a commit message.
