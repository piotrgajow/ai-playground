---
name: generate-voice-lines
description: >
  Generate character voice lines for Claude Code sound notifications. Takes a
  character description (name, game, links to pages with their actual voice
  lines) as input, researches the real lines, and produces short spoken
  notification lines in the character's voice, one set per Claude Code event.
argument-hint: [character name, game, and links to voice line pages]
disable-model-invocation: true
allowed-tools: WebFetch, Write, Bash(curl:*)
---

## Task

Produce short spoken notification lines in the voice of the character described in the input, one set per Claude Code event listed below.

The lines will be turned into audio clips and played automatically while a developer works, so they will be heard hundreds of times. They must be short, natural when spoken aloud, and varied enough not to get annoying.

The character (name, game, and links to pages listing their actual voice lines) is given in the input:

> $ARGUMENTS

If the input is missing the character name or the links, ask for them before proceeding.

## Step 1 — Research the character

1. Fetch and read every link provided with the character description.
2. Collect the character's actual voice lines from those pages.
3. From the real lines (not from your general memory of the character), build a style profile:
   - tone and emotional register
   - sentence length and structure
   - vocabulary level, recurring words, catchphrases
   - recurring devices (sarcasm, repetition, technical jargon, archaic phrasing, etc.)
   - how the character addresses the listener
4. Shortlist real lines that could map directly onto the events below.

## Step 2 — Write the lines

For each event, produce **exactly the requested number of lines**. For every line, decide:

- **[REUSED]** — an existing voice line, quoted verbatim, that fits the event's context. Prefer this whenever a real line genuinely works.
- **[MODIFIED]** - a voice line built *only* by cutting and/or merging text lifted verbatim from one or more existing voice lines — no authored wording added. If any word isn't traceable to a source line, the line is [NEW], not [MODIFIED]. Second best.
- **[NEW]** — a line you wrote. It must match the style profile so closely that a fan could believe it shipped with the game. New lines may nod to the coding/terminal context, but only in ways the character plausibly would.

Constraints for every line:

- 2–10 words typically, never more than 15. It has to work as a short audio clip.
- Must sound natural spoken aloud — no markdown, no stage directions, no text-only formatting.
- Within one event, vary phrasing, rhythm, and energy level. No near-duplicates or simple synonym swaps.
- Match the event's mood (see table). Don't make every line a joke; the character's normal register should dominate, with occasional standout lines.
- Nothing offensive out of proportion to the source material.

## Events

| Event                 | Trigger / context                                                                                                           | Mood of the lines                                                                                    | Count |
|-----------------------|-----------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|-------|
| **SessionStart**      | A brand-new Claude Code session begins. Once or a few times a day.                                                          | Greeting, boot-up, "systems online", first meeting of the day.                                       | 3     |
| **SessionResume**     | An earlier session is resumed; the character remembers the previous work.                                                   | Welcoming the user back, picking up where you left off, "where were we?".                            | 2     |
| **SessionClear**      | The session's context is cleared and work restarts from a blank slate.                                                      | Memory wiped, fresh slate, rebooting — amnesia played straight or for laughs.                        | 5     |
| **PermissionRequest** | Claude is blocked, waiting for the user to approve a permission (run a command, edit a file). The user must react.          | Asking for orders/authorization, awaiting confirmation. Attention-getting but not alarming.          | 7     |
| **Stop**              | Claude finished its task and handed control back to the user. The single most frequent event — fires after every response.  | Work complete, mission accomplished, reporting results ready for review. Widest variety needed.      | 7     |
| **StopFailure**       | Claude finished, but the task failed or ended with errors.                                                                  | Reporting failure or trouble — disappointment, dry criticism, or alarm, whatever fits the character. | 2     |
| **SessionEnd**        | The session is closing.                                                                                                     | Sign-off, shutdown, farewell.                                                                        | 3     |

## Step 3 — Present for approval

Show the user **only** the generated lines, grouped per event, in the table's order:

```
## <Event name>
1. [REUSED] "<line>" — <source url>
2. [MODIFIED] "<line>" — from: "<original line>" (<source url>), "<original line>" (<source url>)
3. [NEW] "<line>"
...
```

- **[REUSED]** lines cite the exact source URL (from the input links) the line was taken from.
- **[MODIFIED]** lines enumerate every original line it was built from (cutting, merging), each with its source URL. If two lines were merged, list both.
- **[NEW]** lines carry no citation.
- Only cite a URL if the line actually came from that fetched page — never cite from memory. If a line can't be traced to one of the given pages, it isn't REUSED or MODIFIED; write it as NEW instead.

No commentary, no explanation of choices, no style profile in the output — just the groups of tagged lines.

Then ask the user whether the lines are approved. If they request changes, revise the affected lines and present the full set again for another round of approval. Repeat until approved.
