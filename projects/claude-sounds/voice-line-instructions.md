# Instructions: generate character voice lines for Claude Code sound notifications

You will be given a **character** (name, game, and links to pages listing their actual voice lines) at the end of these instructions. Your task is to produce short spoken notification lines in that character's voice, one set per Claude Code event listed below.

The lines will be turned into audio clips and played automatically while a developer works, so they will be heard hundreds of times. They must be short, natural when spoken aloud, and varied enough not to get annoying.

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
| **SessionStart**      | A brand-new Claude Code session begins. Once or a few times a day.                                                          | Greeting, boot-up, "systems online", first meeting of the day.                                       | 2     |
| **SessionResume**     | An earlier session is resumed; the character remembers the previous work.                                                   | Welcoming the user back, picking up where you left off, "where were we?".                            | 2     |
| **SessionClear**      | The session's context is cleared and work restarts from a blank slate.                                                      | Memory wiped, fresh slate, rebooting — amnesia played straight or for laughs.                        | 2     |
| **PermissionRequest** | Claude is blocked, waiting for the user to approve a permission (run a command, edit a file). The user must react.          | Asking for orders/authorization, awaiting confirmation. Attention-getting but not alarming.          | 5     |
| **Idle**              | Claude has been waiting for the user's input for over a minute; the user seems to have wandered off.                        | Gentle impatience, calling the user back, "are you still there?"                                     | 3     |
| **Stop**              | Claude finished its task and handed control back to the user. The single most frequent event — fires after every response.  | Work complete, mission accomplished, reporting results ready for review. Widest variety needed.      | 10    |
| **StopFailure**       | Claude finished, but the task failed or ended with errors.                                                                  | Reporting failure or trouble — disappointment, dry criticism, or alarm, whatever fits the character. | 3     |
| **SessionEnd**        | The session is closing.                                                                                                     | Sign-off, shutdown, farewell.                                                                        | 2     |

## Output format

Return **only** the following, grouped per event, in the table's order:

```
## <Event name>
1. [REUSED] "<line>"
2. [NEW] "<line>"
...
```

No commentary, no explanation of choices, no style profile in the output — just the six groups of tagged lines.

---

## Character

<character description and links go here>
