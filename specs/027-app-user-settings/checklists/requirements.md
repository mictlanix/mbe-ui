# Specification Quality Checklist: App Settings, User Settings & Cross-Widget Consistency

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-08-16
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
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
- [x] No implementation details leak into specification

## Notes

- **Validation run 1 (2026-08-16)** — one issue found and resolved:
  - *No [NEEDS CLARIFICATION] markers remain* initially **failed**: US5 carried an open question on where the open/close-shift panel should live. Resolved with the user — a dialog/side sheet launched from a toolbar action — and encoded as FR-027, FR-028, FR-028a/b/c, plus a Clarifications entry recording the accepted cost (one extra click; state no longer visible inline) and its mitigation.
- **Named-file references are deliberate.** This spec cites concrete source files (`money_formatters.dart`, `sale_line_row.dart`, `cash_sessions_screen.dart`, …) because the feature *is* a consolidation of specific existing code paths; naming them is what makes the scope bounded and verifiable, not an implementation leak. Requirements themselves stay behavioral — none prescribe a class, package, or API shape.
- **The four decisions confirmed before drafting** (scope, build-time `.env`, device-local preferences, two-level locale) are recorded in Clarifications and MUST NOT be re-opened at planning time without a spec revision.
- **Re-validated 2026-08-16 after the formatting descope.** All items still
  pass. US1, FR-008…FR-015 and SC-001/002/010 were removed; the remaining
  numbering is deliberately left with gaps so `plan.md`, `research.md` and
  `contracts/` cross-references stay valid. Scope is *more* clearly bounded
  than before, and the descope is recorded with its reasoning in
  Clarifications rather than silently applied.
- **FR-024 (largest text size) carries the main unknown into planning.** The POS capture screen's fixed-width column budget was tuned at specific text sizes; whether it absorbs the largest level or needs a bounded ceiling is a research item, not an open spec question.
