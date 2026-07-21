# Specification Quality Checklist: Facilities and their Facility-Scoped Operational Catalogs

**Purpose**: Validate Companion specification completeness before planning
**Created**: 2026-07-19
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed (User Scenarios, Requirements, Success Criteria)

## Requirement Completeness

- [x] Any [NEEDS CLARIFICATION] markers are genuine ambiguities (≤3) deferred to clarify — **none remain; both were resolved 2026-07-20 against the mbe-api source**
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

**Scope re-check (2026-07-20, after Facilities was folded back in)** — 4 user stories, 35 requirements, 10 success criteria, 0 clarification markers:

- *Scope boundedness*: the boundary moved but stayed explicit. Facilities is now managed (User Story 4); **Addresses** is the new edge — reachable only through the facility form's picker and inline-create path, with no screens of its own, stated in Assumptions, Key Entities, and FR-031/FR-032. **Pass.**
- *Requirement completeness*: FR-023 previously forbade any facility create/edit path and directly contradicted the new User Story 4. Caught and rewritten to describe shared read consistency instead. **Fixed in place** — this was the one requirement the reversal would have left self-contradictory.
- *No unresolved guesses*: the taxpayer gap is a genuine blocker resolved by an explicit, documented UX compromise (FR-034) rather than a marker — the spec states plainly that the user gets no issuer list and no confirmation until the server rejects. It is not presented as a solved problem. **Pass.**
- *Dependencies identified*: three follow-ups filed (#100 taxpayer issuers, #101 address expansion, #102 point-of-sale cross-FK validation), each recorded with why it does not block and what changes when it lands. **Pass.**
- *Success criteria measurable*: SC-008/009/010 added for the new surface, including a bound on address resolution requests (SC-009) so FR-035's bulk-resolve rule is testable rather than aspirational. **Pass.**

**Self-check pass (2026-07-19)** — findings and how they were resolved:

- *Content Quality / no implementation details*: the spec's **Verbatim Constraints** section names access-control objects, a source file path, and query-parameter names. This is the one section where exact, user-pinned identifiers legitimately belong; the four narrative sections stay free of framework, endpoint, and type names. **Pass.**
- *Requirement Completeness / NEEDS CLARIFICATION*: two markers, both genuine and neither resolvable by an informed default —
  1. **FR-022** — whether the backend enforces that a point of sale's warehouse belongs to its facility, or whether a cross-facility pairing is deliberately permitted. This changes a hard UI constraint into a soft warning, and materially changes SC-004.
  2. **FR-025** — which access-control object governs reading facilities. Facilities merged the legacy Store and Production Site concepts and inherited neither object; no facility object exists. Not blocking (the in-scope screens gate on their own objects and only *read* facilities), but it must be settled before the deferred Facilities feature.

  Both are deferred to `clarify`. **Pass** (2 ≤ 3).

  **Update 2026-07-20 — both resolved from the mbe-api source; the spec now carries zero clarification markers and `clarify` can be skipped.**
  1. **FR-022** — the backend does **no** facility↔warehouse validation, so the picker guard is UI-only. FR-022 and SC-004 reworded to claim a UI guarantee rather than a backend invariant, and to require that an already-mismatched record still loads. The missing server-side validation is recorded as a follow-up.
  2. **FR-025** — the governing object is `facilities(29)`, which **reuses the legacy stores slot**; `STORES` and `PRODUCTION_SITES` were removed upstream entirely. This surfaced a defect the spec had not anticipated: the app's own object mirror still says `stores(29)` and `productionSites(107)`. **New FR-027** requires correcting it.
- *Success criteria technology-agnostic*: SC-004 originally referenced the endpoint parameter by name; rewritten in domain terms ("whose warehouse belongs to a facility other than the record's own"). **Fixed in place.**
- *Scope boundedness*: Facilities is named in the original request but excluded as a screen. The exclusion, its four upstream blockers, and the read-only consumption that remains are stated in Clarifications, Key Entities, Assumptions, and FR-023–FR-025 — so a reader cannot mistake the boundary. Adjacent concerns that could be assumed in scope (cash drawer sessions, warehouse stock, bulk import) are explicitly excluded under Assumptions. **Pass.**
- *Dependencies identified*: the open cross-repository search dependency is recorded under Clarifications and Assumptions with its interim mitigation (facet filters) and its explicit non-substitute (client-side filtering of one page). **Pass.**
