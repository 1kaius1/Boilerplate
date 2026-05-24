# Planning

This document tracks project goals, milestones, open questions, and design decisions.
It is a living document - update it as the project evolves. Claude Code should read
this file at the start of every session to understand current project state.

Some projects benefit from companion documents alongside this one. Common examples:
- DESIGN.md - detailed design specifications for a major subsystem or feature
- SCHEMA.md - full database or data format schema reference
- RULES.md - domain rules, game mechanics, or business logic reference
- API.md - full API specification
If created, link to them from the relevant section of this file and from ARCHITECTURE.md.

---

## Project Goal

<!-- One or two sentences. What does success look like when this project is done? -->
<!-- Be specific enough that you could use it to decide if a feature belongs here. -->

---

## Non-Goals

<!-- What is explicitly out of scope? List things that might seem related but are not -->
<!-- part of this project. This prevents scope creep and helps prioritize. -->

- <!-- Example: this tool does not provide a GUI - CLI only -->
- <!-- Example: this service does not handle authentication - that is the caller's responsibility -->

---

## Current Status

<!-- One of: Planning, In Development, Alpha, Beta, Stable, Maintenance, Abandoned -->
**Status:** Planning

<!-- One or two sentences describing where things stand right now. -->
<!-- Example: Core scaffolding complete. Currently implementing X. Blocked on Y. -->

---

## Milestones

<!-- List milestones in order. Check them off as they are completed. -->
<!-- Each milestone should represent a meaningful, shippable state. -->

- [ ] **v0.1.0** - Initial working implementation
  - [ ] <!-- task -->
  - [ ] <!-- task -->
  - [ ] <!-- task -->

- [ ] **v0.2.0** - <!-- milestone description -->
  - [ ] <!-- task -->
  - [ ] <!-- task -->

- [ ] **v1.0.0** - Production-ready release
  - [ ] Full test coverage
  - [ ] Complete documentation
  - [ ] Cross-platform verification
  - [ ] <!-- task -->

---

## Current Sprint / Active Work

<!-- What is being worked on right now? Keep this section short and current. -->
<!-- Remove completed items; move them to the Decisions log below if they involved -->
<!-- a meaningful choice, or just delete them if they were routine. -->

- [ ] <!-- active task -->
- [ ] <!-- active task -->

---

## Open Questions

<!-- Questions that need an answer before work can proceed or a decision can be made. -->
<!-- Remove entries once resolved - log the resolution in Decisions below. -->

| # | Question | Raised | Notes |
|---|----------|--------|-------|
| 1 | <!-- question --> | YYYY-MM-DD | <!-- any context --> |

---

## Decisions Log

<!-- This is the most valuable section in this file over the long term.
     Every significant decision - architecture, library choice, data model,
     API design, licensing, deployment strategy - belongs here with its full
     rationale and a record of what alternatives were considered and rejected.

     The goal is that anyone (including a future AI session) can read this log
     and understand WHY the project is the way it is, not just what it does.
     A decision with no recorded rationale will be relitigated endlessly.

     What counts as significant: anything where a reasonable person could
     disagree, anything that took more than a few minutes to decide, anything
     that closes off a future option. When in doubt, log it.

     Never delete old entries. Superseded decisions stay in the log with a
     note pointing to the newer decision that replaced them. -->

| Date | Decision | Rationale | Alternatives Considered |
|------|----------|-----------|-------------------------|
| YYYY-MM-DD | <!-- what was decided --> | <!-- why --> | <!-- what else was considered --> |

---

## Known Issues and Technical Debt

<!-- Things that are known to be wrong, fragile, or suboptimal but are not being -->
<!-- fixed right now. Include a note on why they are being deferred. -->

| Issue | Severity | Deferred Because |
|-------|----------|-----------------|
| <!-- description --> | <!-- Low/Medium/High --> | <!-- reason --> |

---

## Dependencies and Blockers

<!-- Anything outside this project that must happen before work can proceed. -->
<!-- External APIs, third-party libraries, upstream bugs, other projects, etc. -->

- <!-- Example: waiting on upstream fix for issue #123 in some_library -->
- <!-- Example: need to decide on database before implementing persistence layer -->

---

## Future Ideas

<!-- A parking lot for ideas that are interesting but not planned. -->
<!-- Keeps them from cluttering the milestones while preserving them for later. -->

- <!-- idea -->
- <!-- idea -->
