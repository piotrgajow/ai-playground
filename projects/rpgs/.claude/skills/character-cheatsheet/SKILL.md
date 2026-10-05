---
name: character-cheatsheet
description: Build a printable HTML cheatsheet for a tabletop RPG character from its sheet – spells, usable items, features and feats with their rules, grouped by situation (combat, exploration, social, recovery), plus the character's numbers, resources and rules that matter to them – verified against the game system's resources.
argument-hint: <character-dir> [context-file]
disable-model-invocation: true
allowed-tools: Read, Write, WebFetch, AskUserQuestion, Bash(curl:*), Bash(jq:*), Bash(sed:*), Bash(grep:*), Bash(head:*), Bash(tr:*), Bash(cut:*), Bash(ls:*)
---

# Character cheatsheet

Turn a character into a printable, self-contained HTML document the player keeps at the table. It answers "what can I do right now, and how does it work?" without opening a rulebook.

## Inputs

`$ARGUMENTS` should contain:

1. **Character dir** – the directory containing `sheet.md` created by the `character-build` skill.
2. **Context file** (optional) – the adventure context: setting, party, house rules. It shapes which rules matter (e.g. a pirate campaign makes swimming, drowning and ship combat relevant).

If the character dir is missing, ask for it. If no context file is given but the parent directories contain a `CONTEXT.md`, ask whether to use it.

Read `sheet.md` – the only source for what the character has. Don't read the plan or the idea file it links to. The system comes from the sheet's header line; also read the `SYSTEM.md` of its top-level system directory and follow it for every rule. Never mix systems.

If the sheet lacks something the cheatsheet needs and the rules can't derive it (e.g. an older sheet without the hit point maximum), ask the user for it and suggest adding it to the sheet with the `character-build` skill.

## Language

The cheatsheet is entirely in English, like the sheet, so it matches the names and rules text in the resources. Chat with the user in the language they write in.

## Using the resources

Look up **every** spell, cantrip, class/subclass feature, feat, racial trait, background feature and item with a rules meaning. Don't write rules text from memory. Follow the "Using the resources" section of the `character-ideas` skill (`.claude/skills/character-ideas/SKILL.md`) for fetching, including the MediaWiki API fallback when WebFetch is blocked. Mark anything that could not be verified with `⚠ not verified` in the document and tell the user.

Collect per entry:

- **Spells:** level, school, casting time, range/area, components (material text, gp cost, whether consumed), duration, concentration, ritual, effect, effect at higher levels.
- **Features/feats:** trigger, action type, number of uses and recharge (short/long rest), effect.
- **Items:** what they do in play – weapon stats and properties, armor AC and drawbacks, consumables, tools, utility gear. Skip pure flavour items unless they have a plausible use (e.g. an insignia of rank as social leverage).

## Numbers

Compute the numbers from the sheet and the rules: ability modifiers, proficiency bonus, saves, skills (double proficiency for expertise), passive Perception, initiative, AC, speed, spell save DC and attack, weapon attacks and damage, hit dice. Take the hit point maximum from the sheet.

Substitute the character's numbers everywhere instead of formulas: "DC 15 WIS save", "+7 to hit, 1d8+4 bludgeoning", "heals 1d4+4", not "spell save DC" or "+ spellcasting modifier". Cantrip damage and feature uses are at the character's current level.

Note interactions between features, spells and items, e.g. a feat that lets the character cast a spell as an opportunity attack, a component covered by a holy symbol on a shield, a costly component the character carries, armor with a strength requirement or a stealth penalty.

## Resources

List every limited resource with its count and recharge only – spell slots per level, uses of each limited feature (e.g. `Channel Divinity 1 / short rest`, `War Priest 4 / long rest`). No checkboxes or tracking fields; the player tracks usage elsewhere.

## Grouping by situation

Every entry goes in the section where it is used most. If it genuinely matters in another section too, add a one-line cross-reference there ("→ Combat: Spirit Guardians") rather than duplicating the card.

1. **Combat** – split into *Actions*, *Bonus actions*, *Reactions* and *Always on*. Start with a one-line "Turn one opener" when there is an obvious strong opening (e.g. a buff + a bonus-action attack).
2. **Exploration & travel** – detection, utility, movement, survival, rituals, gear such as rope and torches.
3. **Social & NPC encounters** – Insight, Intimidation, Persuasion, charm and compulsion spells, background features, insignia and similar.
4. **Healing, support & recovery** – healing, condition removal, resurrection, what comes back on a short or long rest.
5. **Inventory** – usable items only, one line each, with key numbers (quantity, value, charges).
6. **Rules reference** – see [Rules](#rules).

Order entries within a section by how often they are likely to be used, not alphabetically. Omit sections that end up empty.

## Rules

Before writing the document, compile the general rules that matter for this character – things they will run into often or can easily get wrong. For example:

- **Spellcasters:** concentration checks, the one-leveled-spell-per-turn rule with bonus-action spells, material components and focuses.
- **Melee characters:** opportunity attacks, grappling and shoving, two-weapon fighting.
- **Armor:** heavy armor strength requirement and stealth disadvantage, donning/doffing times.
- **From the context:** swimming, underwater combat, drowning/suffocation, falling, mounted or vehicle combat, house rules.
- **Always handy:** death saving throws, cover, conditions the character inflicts or often suffers.

Ask which to include with the AskUserQuestion tool: multi-select, up to 4 questions of up to 4 options each, the most relevant first. Every question must include an "I don't know" option – when chosen, include the rules you consider most relevant and say which. Accept rules the user adds through "Other".

## Writing the document

Read the template `.claude/skills/character-cheatsheet/templates/cheatsheet.html` and write `cheatsheet.html` to the character dir. If the file already exists, ask before overwriting.

- Replace every `{{PLACEHOLDER}}`, repeat the card, row and resource patterns as needed, and delete unused sections.
- Keep the document self-contained: inline CSS, no external fonts, scripts or images.
- Keep text short: effects in 1–3 sentences with the numbers that matter, not the full rulebook prose. Bold the key number in each card (damage, DC, healing, duration).
- Tag each card with the template's tag classes: `action`, `bonus`, `reaction`, `conc`, `ritual`, `rest-short`, `rest-long`.
- Aim for 2–4 A4 pages. If it runs longer, tighten the wording before dropping content.

## Checking

Render the document to PDF with headless Chrome, read it and fix cards split across pages, overflowing text and empty trailing pages:

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --disable-gpu --no-pdf-header-footer --print-to-pdf=<scratchpad>/cheatsheet.pdf <character-dir>/cheatsheet.html
```

If Chrome isn't available, skip this step and say so.

## Finishing

Report the path of the written file, the number of printed pages, the rules included, any `⚠ not verified` entries and any values the user had to provide. Propose a commit message.
