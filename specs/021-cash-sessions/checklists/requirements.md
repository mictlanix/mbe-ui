# Specification Quality Checklist: Cash Session Open, Close and Count

**Purpose**: Validate Companion specification completeness before planning
**Created**: 2026-08-04
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

- Items marked incomplete require spec updates before clarify or plan

### Self-check pass — 2026-08-04

Every item passes. Four judgements are recorded here rather than left implicit, because each is a
deliberate call a later reader could otherwise mistake for an oversight.

1. **Implementation detail in Verbatim Constraints is intentional.** Endpoint paths, generated
   operation names, wire field names, backend refusal strings and privilege identifiers appear in
   that section only. They are values the request pinned, and the template designates this the one
   place exact identifiers belong. Paraphrasing them would force a later step to guess. The two
   same-status open conflicts in particular are discriminated *only* by their message text, so the
   literal strings are load-bearing, not decorative.

2. **Zero [NEEDS CLARIFICATION] markers is a real result, not avoidance.** The three scope questions
   that genuinely required a decision — standalone versus POS-coupled, whether to compute a
   variance, and whether history is in scope — were put to the requester and are recorded under
   Clarifications. What remains open is *how*, not *what*: resolving cashier and drawer ids to
   display names (A-005) and exact route paths (A-004) are planning decisions with no business
   ambiguity, so recording them as informed defaults is correct and a marker would be noise.

3. **Three requirements are verified by success criteria rather than a story scenario.** FR-038
   (localized currency and dates), FR-039 (both locales) and FR-040 (compact tier) are cross-cutting
   presentation rules that do not belong inside any one user journey's Given/When/Then. They are
   measurable through SC-010 and SC-004 respectively. This is a conscious placement, not a gap.

4. **Two constitutional constraints are surfaced as dependencies rather than silently satisfied.**
   The house rule that every list screen ships with a search box cannot be met here: the backend
   exposes only a cash drawer filter, and a session has no free-text field to search on. D-003
   records this as a backend enhancement to request, and explicitly rejects client-side filtering
   across a page as producing results that are wrong at page boundaries. Separately, the house rule
   that Edit is a row's primary action does not apply, because a cash session is never editable —
   FR-030 and FR-032 replace it with read-only row navigation and no edit affordance at all. Both
   deviations are stated in the spec rather than discovered during planning.
