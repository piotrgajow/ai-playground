---
name: find-voice-sources
description: >
  Search the web for pages containing a character's real voice lines —
  wiki quote pages, soundboards, and script transcripts — for a given
  character from a game, show, or movie. Produces a curated list of links
  formatted to feed directly into the generate-voice-lines skill.
argument-hint: [character name and game/show/movie]
disable-model-invocation: true
allowed-tools: WebSearch, WebFetch, Write, Bash(curl:*)
---

## Task

Given a character (name + the game/show/movie they're from), find real pages on the internet that contain their actual voice lines or quotes in text form, so those links can be handed to the `generate-voice-lines` skill.

The input is given below:

> $ARGUMENTS

If the input is missing the character name or the source work (game/show/movie), ask for it before proceeding.

## Step 1 — Search for sound samples first

Sound sources are the priority — the whole point of this search is to find actual audio of the character speaking. Searching for transcriptions is only worthwhile once at least one real sound source is confirmed, so do this step first and don't move on until it succeeds.

1. **Soundboards** — `<character> soundboard`, `site:101soundboards.com <character>`, `site:voicy.network <character>`, `site:myinstants.com <character>`.
2. **Game-specific dialogue/audio dumps** — for games, wikis or fan sites sometimes host full "voice lines" or "unused/cut dialogue" pages with embedded audio for major characters. Search `<character> voice lines <source>` or `<character> all dialogue <source>`.
3. Any other query angle likely to surface actual audio clips (fan archives, mod/datamine resources, etc.).

Fetch each candidate and confirm it actually hosts audio clips of *this* character speaking (not just a fan discussion mentioning them, and not a different character with a similar name).

**Known site quirks:**
- `101soundboards.com/tts/...` pages are AI/TTS voice-clone boards (synthetic speech generated from a text prompt), not real recorded lines — exclude these even if captioned with the real voice actor's name. Only `101soundboards.com/board/...` pages are curated real-audio soundboards.
- `soundboard.com` is often stale — pages can load with a track count of 0 despite claiming to be complete. Check the actual track count before trusting it.

**If WebFetch fails on a candidate** (403, 402, a Cloudflare/"just a moment" challenge page, etc. — common on fandom.com, 101soundboards.com, myinstants.com, soundboard.com): retry with `curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" <url>` before giving up on the candidate. If that also fails, fall back to treating the WebSearch result snippets as verification — accept the candidate only if multiple search results (or one result quoting specific, non-generic character dialogue) corroborate it, and mark it in Step 4's output as verified via snippet only, not fetched directly, so the user knows to sanity-check it themselves.

**If no sound source survives verification, stop here.** Do not proceed to Step 2. Instead, tell the user plainly that no sound samples could be found, and list every search query that was tried, so they can see what was attempted and try their own search or supply links manually.

## Step 2 — Search for transcriptions

Only run this step if Step 1 found at least one verified sound source.

1. **Wiki quote pages** — `"<character> quotes" <source> wiki`, `site:fandom.com <character> quotes`, `site:wiki.gg <character> dialogue`. Fandom/wiki.gg character pages often have a dedicated "Quotes" or "Dialogue" section or subpage — look for it specifically, not just the main character page.
2. **Soundboards** — the same soundboard pages found in Step 1 usually also work here, since entries are typically captioned with the line's text alongside the audio clip.
3. **Script/transcript archives** (for shows/movies) — `<source> transcript <episode>`, `site:subslikescript.com <source>`, `site:springfieldspringfield.co.uk <source>`. These aren't organized per-character, so expect heavier filtering, but they're the best source for exact wording.

Collect a broad set of candidate URLs before filtering.

## Step 3 — Verify each transcription candidate

For every candidate URL, fetch it and confirm:

- It actually contains lines attributed to *this* character, quoted in text (not just a general bio/plot summary without quotes).
- The lines are real, sourced from the work — not fan-written, paraphrased, or from a different character with a similar name.

Discard pages that fail either check. Note roughly how many usable lines each surviving page contains (a rough count, not exhaustive) — this tells the user which sources are worth the most.

Apply the same blocked-fetch fallback described in Step 1 (retry with `curl` and a browser User-Agent, then fall back to snippet-based verification if needed) when WebFetch fails here too.

## Step 4 — Present results

Show the user the surviving links, grouped by type, sound sources first:

```
## Sources for <Character> (<Source work>)

**Sound sources**
- <url> — ~<N> clips, <brief note>[, snippet-verified only]

**Wiki quote pages**
- <url> — ~<N> lines, <brief note>[, snippet-verified only]

**Scripts/transcripts**
- <url> — ~<N> lines, <brief note>[, snippet-verified only]
```

Append `, snippet-verified only` to a link's note whenever it was confirmed through the Step 1/3 snippet fallback rather than a direct successful fetch.

If a search angle turned up nothing usable, omit that group entirely rather than listing it empty. No other commentary.

## Step 5 — Save the results

Ask the user for the file path to save the results to. Write the results (the same grouped list from Step 4, including the character name and source work) to that path.

Then ask whether the user wants to:

- run another round of searches (a different angle, or more results within one group), or
- proceed straight to `generate-voice-lines` using these links.

If they choose to proceed, invoke `generate-voice-lines` with the character name, source work, and the collected links as its input.
