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
- **Two asks were dropped, both recorded with their reason.** "Exclude
  point-of-sale orders" (A1) and "filter by the creating user" (A4) are each
  impossible against the current backend; both were discarded by the user on
  2026-08-19 rather than deferred, and OS-1 says so, so planning does not reopen
  them.
- **Scoping is a product rule the client enforces (A2).** The backend will serve
  any facility, any salesperson and everyone's orders to any caller holding
  sales-order read access. FR-006 therefore binds every request the screen makes,
  not just the controls it draws — an ordinary user hand-editing the address must
  still get only their own orders (SC-009). The spec does not claim this is a
  security boundary.
- **The reuse refactor (A9, FR-029–FR-031) is the feature's main technical risk**
  and is the first thing `/speckit-plan` should size: the point-of-sale capture
  widgets read one screen-scoped sale directly, and two screens must be able to
  hold two independent orders without the register's behaviour changing (SC-007).
- **One requirement was corrected during planning.** FR-020 originally listed the
  unit price as editable. It is not — the shared capture surface makes price
  read-only by design, and the legacy screenshot agrees. Building it as written
  would have forced a fork of the shared widget (breaking FR-029) or a change to
  the register (breaking FR-031). See research §R9.1.
- **Re-checked against specs 030 and 031 on 2026-08-23.** Both POS features shipped
  after this spec was written and are merged into this branch. Four requirements
  were added (FR-035–FR-038), FR-020 was amended (quantity is a stepped, debounced
  control floored at one), assumption A10 and criterion SC-011 were added, and
  research §R12 records what the reused widgets now bring with them. The load-bearing
  discovery: the shared line editor hard-codes the register's write scope, so without
  a second provider seam a back-office edit would hold the cashier's continue button
  shut — a defect no compiler or existing test would catch.

