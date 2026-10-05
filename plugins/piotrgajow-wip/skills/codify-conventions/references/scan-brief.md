# Scan brief

Hand this to a subagent (Explore or general-purpose) together with the three inputs.
The subagent reads the files; only its structured report comes back.

---

## Inputs to fill in

- **Topic**: `<topic as the user phrased it>`
- **Scope**: `<directories and glob patterns to scan>`
- **Ignore**: `<things a linter/formatter/type checker already enforces, so they are not
  reported as conventions>`

## Prompt

You are analysing a repository to discover how `<topic>` is built in it. Read every file
under `<scope>` that is part of this topic, plus the files they import from inside the
repo when that is needed to understand the pattern (shared layout components, base
classes, helpers). Do not read unrelated areas.

Report **patterns**: things most of the files do the same way that a newcomer would have
to be told. Think in these categories, in this order:

1. File and directory layout: where a new instance goes, how it is named, what sibling
   files it has (index, test, styles, hook, types), how it is registered or wired
   (router, module, barrel export).
2. Structure of the unit itself: how it is composed, what it delegates to, what it
   never does itself (data fetching, state, side effects).
3. Data and state: how data arrives, how loading and error states are handled, what
   shared stores or services are used and how.
4. Naming and shapes: prop/parameter conventions, types location, exports style.
5. Testing: whether instances have tests, where, what they cover, test naming.
6. Anything else repeated in 3 or more files that is not in `<ignore>`.

For each pattern give:

- `rule`: one imperative sentence
- `evidence`: 2–3 file paths that show it best
- `adherence`: `<n of m>` scanned instances that follow it
- `non_conforming`: paths that do not follow it, each with a few words on how
- `variants`: when the files split into two or more ways of doing the same thing,
  list each variant with its evidence files and the most recent commit date among them
  (`git log -1 --format=%cs -- <file>`; if git history is unavailable say so)
- `reference_implementation`: the single file that is the cleanest, most complete
  example of the whole pattern set, if one stands out

Also report:

- `existing_docs`: any CLAUDE.md, README section or comment block that already
  describes part of this topic, with path
- `smells`: up to five things you noticed that look like accidental inconsistency or
  structural weakness (duplication across instances, logic in the wrong layer,
  untestable coupling), each with evidence. These feed improvement suggestions, so be
  concrete.

Output as markdown with one `###` heading per pattern. Keep file paths exact and
relative to the repository root. Do not include code snippets longer than two lines.
