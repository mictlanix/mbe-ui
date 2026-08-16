# Specification Quality Checklist: Point of Sale — Delivery Step Look & Feel

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-08-15
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed (User Scenarios, Requirements, Success Criteria)

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Each Functional Requirement is a single, testable MUST/SHOULD statement
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into the specification

## Notes

- Seven clarifications were accepted, two more than the standard five, and the
  seventh arrived after planning when mbe-api#163 shipped. The last three were
  not in the drafted queue: the requester's correction — that
  quantities belong in the destination's own card, which the mock does draw that
  way — opened an area the first draft had closed with FR-013 ("lines inside an
  expanded card MUST be read-only"). That requirement is gone; assignment in the
  card is now the feature's second P1 story.
- **No longer blocked.** Both gaps this design needed — adding a line to an
  existing destination (mbe-api#163) and creating one that carries nothing
  (#165) — shipped on 2026-08-15 with the client regenerated. Every requirement
  is buildable as written, and the Status says so.
- Both gaps were verified against mbe-api's own source rather than inferred from
  the client, which is what caught the second one: #163's commit touched no
  schema, so "the endpoint landed" did not mean "the flow is unblocked". The
  same reading caught two behaviours that would have been bugs — a duplicate
  `POST` is a 409 rather than a fold, and the "already fully delivered" guard
  runs before the narrowing step, so an empty create is refused on a
  fully-assigned sale.
- That last one is the only requirement the API work changed: FR-016 now
  disables the add action when nothing is left unassigned, rather than making a
  request the server would refuse.
- FR-003 was widened when the deferred-creation alternative came up: it now
  forbids a card with no server record behind it by name, alongside the
  placeholder line and the cancel-and-recreate substitutes.
- Three judgement calls are assumptions rather than requirements, so the plan may
  revise them without touching a requirement: the two-region threshold (1200 px —
  FR-004/FR-005 state *that* the shape changes with width, not at which pixel),
  the stepper's one-unit step, and whether rapid identical assignments are
  coalesced before being sent.
- The scope fence moved. FR-001 no longer claims the feature is visual-only —
  it names the one behaviour added (assigning quantities after a destination
  exists) and fences everything else. SC-010 was rewritten to match: requests do
  change now, and the criterion bounds which ones.
- Widget test keys, file paths and the named code symbols appear only under
  Verbatim Constraints, where user-pinned literals belong. Two key families are
  flagged there as moving between widgets rather than being preserved in place.
- Items marked incomplete require spec updates before `/speckit-plan`.
