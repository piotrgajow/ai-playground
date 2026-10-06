`---
name: refine-idea
description: Guide through a process of refining an idea into product requirements (PRD).
argument-hint: [idea]
disable-model-invocation: true
---

# Idea Refinement Workflow

This skill guides you through refining a raw idea into a well-documented, actionable specification.

## Phases

### Phase 1 — Analyse the Idea

Read the user's idea carefully. Identify:
- The core goal or problem being solved
- Implicit assumptions being made
- Scope boundaries (what's in vs. out)
- Key technical or product decisions that haven't been made yet
- Risks, unknowns, or areas that need clarification

Present your analysis in a short structured summary:
Core goal: ...
Assumptions: ...
Scope: ...
Open decisions: ...
Risks / unknowns: ...

### Phase 2 — Structured Discussion

Generate a prioritised list of questions and concerns. For each item:
- Ask one question at a time (do not overwhelm the user with a list)
- For ambiguous decisions, propose 2–3 concrete options with trade-offs
- For concerns, raise them clearly and ask how the user wants to handle them
- After each answer, update your mental model and either ask the next question or confirm you have enough clarity

Continue until all critical unknowns are resolved. Before moving on, summarise what was decided:
Decisions made:
- [decision 1]
- [decision 2]
  ...

### Phase 3 — Document Structure

Propose a document outline based on what you now know. The structure should be appropriate to the idea's nature (feature spec, architecture doc, product brief, etc.). A typical structure:

1. Overview
2. Goals & non-goals
3. Background / context
4. Proposed solution / approach
5. Key decisions and trade-offs
6. Open questions
7. Implementation notes (if technical)
8. Success criteria

Ask the user to approve or adjust the structure before proceeding.

If no file path has been specified, ask where to save the document now.

### Phase 4 — Section-by-Section Drafting

For each section in the approved outline:
1. Propose content for that section based on everything discussed
2. Present it to the user for review
3. Incorporate feedback and revise until approved
4. Move to the next section

Do not write multiple sections in a single response. One section at a time ensures focused review.

Once all sections are approved, write the complete document to the specified file.

### Phase 5 — Independent Review

Spawn a subagent with this prompt:

You are a critical reviewer. Read the document at [FILE_PATH].

Your job is to catch blind spots the original author may have missed. Look for:
- Unstated assumptions that could prove wrong
- Logical gaps or missing steps
- Scope creep risks or under-specified boundaries
- Conflicts or contradictions between sections
- Missing stakeholders, dependencies, or constraints
- Anything that would cause someone implementing this to get stuck

Return a list of specific, actionable concerns. Be direct.

Present the subagent's findings to the user. For each concern, discuss whether to address it and if so, update the document accordingly.

## Rules

- Do not skip phases or merge them — each phase has a distinct purpose
- Do not write to file until Phase 4 is complete
- Do not move to Phase 5 until the user has approved the final document
- Keep responses focused: one question, one section, one concern at a time
- If the user asks to skip a phase, confirm once and proceed — user instructions override this workflow
