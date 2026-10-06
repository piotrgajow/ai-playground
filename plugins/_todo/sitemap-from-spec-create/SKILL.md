---
name: sitemap-from-spec-create
description: Generate a sitemap from a specification document — one markdown file per route/screen/overlay, written to a user-specified directory.
argument-hint: [spec path] [output dir]
disable-model-invocation: true
---

# Sitemap Generation from Spec

## Inputs

1. **Spec document** (required) — primary source of truth for what the app does
2. **Output directory** (required) — where to write the page files; ask the user if not provided
3. **Design guidelines** (optional) — include only if they describe navigation patterns (e.g. whether management screens are modals vs. dedicated routes); skip visual/styling content as it adds noise without sitemap value

## Step 1 — Read and analyse the spec

Read the full spec. Extract:
- Every distinct screen, view, or overlay that has unique content or user interactions
- Navigation relationships (what links to what, what is a child/sub-screen)
- Screens explicitly deferred or marked out of scope — note them but exclude from output files
- Open questions that affect screen count or structure (e.g. "modal vs. route") — flag these in the relevant page file

If design guidelines are provided, scan only for decisions that affect whether a management action lives on its own page vs. as an overlay. Ignore color, typography, and spacing.

## Step 2 — Determine the page list

Group screens before writing files:

- **Core screens** — always present, always navigable (e.g. dashboard, main list views)
- **Management screens** — CRUD editors, settings, detail views
- **Overlays** — confirmations, pickers, inline forms that appear over another page

Every group gets individual files. Overlays are separate files (not embedded in parent pages) so they can be worked on as independent tasks.

When the spec is ambiguous about modal-vs-route, default to treating management actions as **overlays** (not separate routes) unless the spec or design guidelines say otherwise. Note the assumption in the file.

Exclude trivial system dialogs (e.g. browser confirm prompts, toast notifications) — these are not pages.

## Step 3 — Write the page files

Create one `.md` file per page/overlay in the output directory. Filename format: `NN-page-name.md` where `NN` is a two-digit sequence number reflecting navigation order.

Examples: `01-dashboard.md`, `02-task-editor.md`, `03-delete-confirmation.md`

### Page file template

```markdown
# [Page Name]

## Route
`/path` — or `overlay` / `modal` if not a dedicated route

## Purpose
One sentence: what the user comes here to do.

## Key content & components
- Bullet list of the main UI elements and data shown on this page

## User interactions
- Bullet list of actions the user can take (CRUD operations, navigation triggers, toggles)

## Navigation
- **Enters from**: [list of pages/triggers that lead here]
- **Exits to**: [list of pages/triggers this leads to]

## Data dependencies
- List of data entities read or written (e.g. Task, Character, Event)

## Open questions / assumptions
- Any spec ambiguities relevant to this page, and the assumption made
```

Omit sections that genuinely have nothing to say — don't write empty bullets.

## Step 4 — Write the index file

Always create `00-index.md` in the same output directory. This is the navigable overview of the entire sitemap.

### Index file template

```markdown
# Sitemap Index

## Pages

| # | File | Route | Description |
|---|------|-------|-------------|
| 01 | [page-name.md](01-page-name.md) | `/path` | One-line description |

## Assumptions
- List any cross-cutting assumptions made during generation

## Deferred / out of scope
- Screens explicitly excluded and why
```

## Quality checks before finishing

- Every CRUD entity in the spec has a corresponding editor/manager page accounted for
- No page exists without a purpose clearly distinct from other pages
- Navigation is consistent — if page A exits to B, then B's "Enters from" includes A
- Trivial confirmations and system dialogs are not listed as pages
- All deferred/out-of-scope items are noted in the index
