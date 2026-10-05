# Improvement lenses

Use these to generate Phase 4 suggestions. Each lens is a question to ask of the accepted
patterns and the scan's `smells`. Only propose something when the evidence shows the
problem actually exists in this repo; a lens that does not apply is skipped, not forced.

Propose at most six, ordered by expected payoff for this codebase. For each: the change,
why it helps *here* (cite evidence), the trade-off, the rule it would become.

## Clean code

- **One reason to change**: do instances mix concerns (rendering + fetching, routing +
  business rules, persistence + validation)? Suggest the split the repo is already
  closest to.
- **Duplication across instances**: same 10 lines in several files. Suggest the
  extraction and where it would live under the existing layout.
- **Naming drift**: same concept, different names across files. Suggest the name with
  the most recent usage.
- **Dead or vestigial structure**: boilerplate every instance carries but none uses.

## Domain design

- **Where do domain rules live**: are they in the UI layer, the controller, the
  database layer, or a domain module? If scattered, suggest the single home that fits
  the current structure.
- **Primitive obsession at boundaries**: ids, dates, money, enums passed as raw strings
  or numbers across layers where the repo already has types for them.
- **Contract between layers**: is the shape crossing a boundary (API ↔ UI, service ↔
  repository) defined once and shared, or re-declared?

## Testability

- **Can an instance be tested without the world**: does it need a server, a database, a
  router, or a store to render or run? Suggest the seam that is cheapest given how the
  repo already structures things.
- **Where are the tests**: if the topic has no tests, propose the minimum useful
  shape (one test per instance covering X) rather than a testing philosophy.
- **Hidden inputs**: globals, module-level singletons, environment reads inside the
  unit.

## Consistency with the rest of the repo

- A pattern used elsewhere in the repo for a sibling topic that this topic does not
  follow. Point at the sibling as the example.

## What not to propose

- Framework or library swaps.
- Anything the user rejected in Phase 3.
- Style points a formatter could enforce.
- Large rewrites; every suggestion must be applicable to the next instance written,
  independently of refactoring the old ones.
