# Specification Quality Checklist: Point of Sale — Write Gating & Field Discard

**Purpose**: Validate Companion specification completeness before planning
**Created**: 2026-08-23
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed (User Scenarios, Requirements, Success Criteria)

## Requirement Completeness

- [x] Any [NEEDS CLARIFICATION] markers are genuine ambiguities (≤3) deferred to clarify — not unresolved guesses
      *(none used: the two open choices — what happens when continue is pressed with unconfirmed
      text, and how a confirmed-but-unsent change is handled — are recorded as informed defaults
      under Assumptions and FR-004/FR-005, and remain open to `clarify`)*
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
      *(the one exception is Verbatim Constraints, which quotes `PosStepController.writeInFlight`
      from the request itself — an identifier the user pinned, not a design choice)*

## Notes

- FR-022's audit is stated as a requirement and its current findings recorded under
  Assumptions; the design phase must confirm no field was missed rather than
  re-deciding which are in scope.
- Two requirements deliberately pull in opposite directions and must stay that way:
  FR-004 (a confirmed-but-unsent change blocks a transition) and FR-005 (unconfirmed
  text does not).
