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

- Six clarifications were accepted, one more than the standard five. The last
  two were not in the drafted queue: the requester's correction — that
  quantities belong in the destination's own card, which the mock does draw that
  way — opened an area the first draft had closed with FR-013 ("lines inside an
  expanded card MUST be read-only"). That requirement is gone; assignment in the
  card is now the feature's second P1 story.
- **The feature is blocked, and the spec says so in its Status.** In-card
  assignment needs a line added to a delivery order that already exists, and
  mbe-api has no endpoint for it. Verified at the source rather than inferred:
  `app/api/v1/endpoints/delivery_orders.py` has `PUT`/`DELETE` on
  `/{delivery_order_id}/lines/{line_id}` and no `POST` counterpart, and
  `DeliveryOrderCreate.lines` is `Field(default=None, min_length=1)`, so an
  explicit empty list is refused as well. Filed as mbe-api#163 and recorded as a
  blocking dependency; FR-003 forbids building a client-side substitute.
- The dependency is partitioned rather than total: the Dependencies section
  names the client work that can proceed without it — the two-region layout, the
  destination grouping, the counter row, the rail, the badges, the pinned foot.
  Planning can sequence around the block.
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
