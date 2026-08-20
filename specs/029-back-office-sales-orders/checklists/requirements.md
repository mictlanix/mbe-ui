# Specification Quality Checklist: Back-Office Sales Orders ("Pedidos")

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-08-19
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

- **Content Quality, item 1 — deliberate, bounded exception.** The Clarifications,
  Assumptions and Dependencies sections state backend constraints in concrete
  terms (a mandatory register column on every order, an equality-only register
  filter, a single-facility listing predicate, a derived due date, no
  server-rendered order document). This is intentional: those constraints are
  what *decided* the answers to all four clarification questions, and burying
  them behind neutral language would let planning re-litigate settled scope. No
  language, framework, file path or endpoint signature appears in any user story,
  functional requirement or success criterion.
- **FR-014 is load-bearing.** Creating an order is impossible for a user with no
  point of sale configured — the server refuses it. The blocked state is a
  first-class requirement, not an edge case, because the failure would otherwise
  land *after* a salesperson has typed a whole order.
- **A1 records a request that could not be granted.** "Exclude point-of-sale
  orders" was the user's original hope; it is not expressible against the current
  backend and was confirmed as out of scope (OS-1) rather than silently dropped.
- **The reuse refactor (A9, FR-029–FR-031) is the feature's main technical risk**
  and is the first thing `/speckit-plan` should size: the point-of-sale capture
  widgets read one screen-scoped sale directly, and two screens must be able to
  hold two independent orders without the register's behaviour changing (SC-007).
