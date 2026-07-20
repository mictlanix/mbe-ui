# Specification Quality Checklist: Facility-Scoped Operational Catalogs (Warehouses, Points of Sale, Cash Drawers)

**Purpose**: Validate Companion specification completeness before planning
**Created**: 2026-07-19
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed (User Scenarios, Requirements, Success Criteria)

## Requirement Completeness

- [x] Any [NEEDS CLARIFICATION] markers are genuine ambiguities (≤3) deferred to clarify — not unresolved guesses
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

- Items marked incomplete require spec updates before clarify or plan.

**Self-check pass (2026-07-19)** — findings and how they were resolved:

- *Content Quality / no implementation details*: the spec's **Verbatim Constraints** section names access-control objects, a source file path, and query-parameter names. This is the one section where exact, user-pinned identifiers legitimately belong; the four narrative sections stay free of framework, endpoint, and type names. **Pass.**
- *Requirement Completeness / NEEDS CLARIFICATION*: two markers, both genuine and neither resolvable by an informed default —
  1. **FR-022** — whether the backend enforces that a point of sale's warehouse belongs to its facility, or whether a cross-facility pairing is deliberately permitted. This changes a hard UI constraint into a soft warning, and materially changes SC-004.
  2. **FR-025** — which access-control object governs reading facilities. Facilities merged the legacy Store and Production Site concepts and inherited neither object; no facility object exists. Not blocking (the in-scope screens gate on their own objects and only *read* facilities), but it must be settled before the deferred Facilities feature.

  Both are deferred to `clarify`. **Pass** (2 ≤ 3).
- *Success criteria technology-agnostic*: SC-004 originally referenced the endpoint parameter by name; rewritten in domain terms ("whose warehouse belongs to a facility other than the record's own"). **Fixed in place.**
- *Scope boundedness*: Facilities is named in the original request but excluded as a screen. The exclusion, its four upstream blockers, and the read-only consumption that remains are stated in Clarifications, Key Entities, Assumptions, and FR-023–FR-025 — so a reader cannot mistake the boundary. Adjacent concerns that could be assumed in scope (cash drawer sessions, warehouse stock, bulk import) are explicitly excluded under Assumptions. **Pass.**
- *Dependencies identified*: the open cross-repository search dependency is recorded under Clarifications and Assumptions with its interim mitigation (facet filters) and its explicit non-substitute (client-side filtering of one page). **Pass.**
