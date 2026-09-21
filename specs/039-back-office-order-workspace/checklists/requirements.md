# Specification Quality Checklist: Back-Office Order Workspace — Customer, Capture, Delivery

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-09-11
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

- Items marked incomplete require spec updates before `/speckit-clarify` or `/speckit-plan`

### Validation record

**Iteration 1 (2026-09-11).** Four items failed and were corrected before this
checklist was marked complete:

1. *No implementation details* — the first draft named source files, provider
   symbols and line numbers in the requirements (carried over from the feature
   description). Rewritten: FR-041…FR-046 now state the sharing rule as
   behaviour ("hostable by both", "affect only that host's document") and the
   technical detail is confined to Assumption A10 as a stated risk.
2. *Success criteria technology-agnostic* — an early SC referred to provider
   overrides. Replaced by SC-006, which states the observable property (one
   definition, used by both, a change visible in both).
3. *Scope clearly bounded* — the list screen's status was implicit. Now explicit
   in three places: the Context note, A1, and OS-2.
4. *Edge cases identified* — the consequence of committing on the first
   destination (lines lock) was not surfaced. Now an explicit edge case, an
   assumption (A2), and a requirement boundary (FR-006 limits the return to
   Venta to draft orders).

**Decisions taken by the user and recorded without a clarification marker**: the
commitment point, delivery-only fulfilment, editor-only scope, and acceptance of
point-of-sale blast radius. These were settled before drafting, so no
[NEEDS CLARIFICATION] markers were raised.

**Resolved after an API audit (2026-09-11).** The open item recorded above — that
committing on the first destination locks the lines — is **not** a design choice
and cannot be revisited: the server refuses to record a delivery against an
uncommitted order, so that ordering is forced. A2 and FR-032 were rewritten to
say so.

**Scope decision recorded (2026-09-11).** An origin marker was added to the
requirements (FR-051…FR-054) after the audit established that the two workflows
produce documents identical in every readable field. The "Pedidos" list was
deliberately **not** narrowed by it (OS-2): the backfill policy for orders
predating the marker belongs with the field, not with this screen.

**Two deployment dependencies carried to planning** (A13, A14), neither of which
this specification can settle on its own: the sweep that cancels committed,
unpaid, undelivered orders, and the server option that gates delivery on payment.
Both need checking against the target environment before implementation.
