

SessionStart: startup / resume / clear

PermissionRequest: 
Notification: permission_prompt idle_prompt


Stop:


StopFailure


SessionEnd





```
Generate 5 short voice notification lines for the event: [EVENT NAME].

Context: [what triggers this event, e.g. "Claude Code has finished
executing a task and is waiting for the user to review"]

Style: [your style description — e.g. "deadpan robot butler",
"sarcastic sidekick", "calm sci-fi computer voice", "hype gamer announcer"]

Constraints:
- Max 6-8 words per line
- No filler words, get straight to the point
- Each line should sound distinct from the others (vary phrasing,
  not just synonyms)
- Should make sense said by a voice assistant, not read as text
- Avoid exclamation overload — vary energy level across the 5

Output as a numbered list, nothing else.
```

> Run this once per event with the same style description, swap the event/context block each time.
On style — be specific rather than generic. "Friendly" gives bland results. Something like "dry British butler, mildly judgmental but professional" or "retro 80s computer, robotic but warm" gives the model (and later the TTS voice) much more to grab onto.
Want me to draft the actual 5 events × 5 lines now? If so, tell me the style/persona you're going for and I'll write them out.

```
A few approaches, roughly in order of effort vs. fidelity:
1. Just name it, let the model fill in.
If the persona is well-known enough, you can sometimes get away with:
Style: narrator from Darkest Dungeon — grim, weary, archaic phrasing, 
treats mundane events like cosmic dread
Risky — depends on how well the model actually "knows" the voice vs just knowing it exists. Worth testing before relying on it.
2. Reverse-engineer a style description from real lines.
This is more reliable. Find a handful of actual quotes from the source, then ask the model to extract a style profile from them rather than from its memory of the persona. Something like:
Here are some lines from [persona]:
"[quote 1]"
"[quote 2]"
"[quote 3]"

Analyze the style: tone, sentence structure, vocabulary level, rhythm, 
recurring devices (metaphors, archaic words, repetition, etc), 
and emotional register. Write this up as a reusable style guide 
I can hand to a writer who needs to produce new lines in this voice.
This gives you a style description grounded in actual text, not the model's vague impression of "what Darkest Dungeon sounds like."
3. Use that extracted style guide as the persistent "Style:" block in the generation prompt from before, instead of just the one-line persona name.
For Darkest Dungeon's narrator specifically, the real lines lean on: short declarative sentences mixed with longer ominous ones, archaic/formal diction ("affliction," "ruin," "folly"), treating small failures as portents, and a weary-but-resigned tone rather than panic. I'm summarizing the style here, not quoting him — for actual quotes you'd want to pull a few yourself and feed them through step 2, since I shouldn't reproduce game dialogue verbatim.
Want me to build out that style-guide-extraction step for a specific persona you have in mind, or draft a generic version of the Darkest Dungeon style description so you can test it?
```
