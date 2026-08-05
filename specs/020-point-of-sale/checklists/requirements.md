# Specification Quality Checklist: Point of Sale — Sale Capture

**Purpose**: Validate Companion specification completeness before planning
**Created**: 2026-08-03
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
- **Zero `[NEEDS CLARIFICATION]` markers.** The four decisions that would have
  produced them — flow scope, when the sale is recorded and confirmed, how a
  customer code is obtained, and where the screen lives in the shell — were
  settled with the requester before drafting and are recorded in the Overview
  and Assumptions.
- **Revised 2026-08-03 — delivery moved to the end of the flow** (Venta → Cobro
  → Entrega, departing from the mock's order). Re-checked after the change: the
  three affected stories, the edge cases, FR-005, FR-018, FR-029 through FR-037,
  FR-038, FR-041, FR-049 through FR-051, SC-004, A-008 and D-002 were all
  updated, and FR-056 through FR-058 were added to keep the fulfilment mode
  durable across a reopened sale. Every checklist item above still passes.
- **Deliberate exception to "no implementation details".** The Dependencies
  section names backend behaviours (a delivery record needs a confirmed sale;
  splitting quantities takes a create-then-trim sequence; one deployment setting
  can move FR-036). These are external constraints that change *what* the
  product can promise, not *how* it is built, and hiding them would push the
  discovery into implementation. FR-030 carries the same constraint in
  business language.
- **Verbatim Constraints holds literal Spanish UI copy** pinned by the request.
  Exact identifiers are permitted there by design; the rest of the spec keeps
  them out.
- **Revised 2026-08-04 — post-`/speckit-analyze` remediation.** The analysis
  pass (run after plan.md and tasks.md existed) found 2 CRITICAL and 3 HIGH
  findings spanning spec/research/contracts/tasks — a payment never refreshing
  `Sale.balance` (blocked the payment-close gate entirely), the open-sales
  selector never querying `status=paid` (made FR-058's paid-undistributed sale
  unreachable, contradicting its own requirement), SC-004 overpromising
  itemized payment recovery against a documented backend limitation, and two
  requirements (FR-016 payment terms, FR-041 post-confirm read-only) with zero
  task coverage. All 11 findings were fixed same session: FR-004 and SC-004
  reworded, research.md and contracts/pos-screen.md updated to match, and
  tasks.md gained 3 tasks net (later 2, see below) plus 9 amendments — see
  tasks.md's own revision note for the full list.
- **Revised again 2026-08-04 — FR-015 redesigned.** mbe-api's team confirmed
  the legacy system re-priced a sale's lines on a customer change; the current
  backend does not (verified directly against `update_order`'s source, not
  assumed). FR-015, its Edge Cases entry and US4's acceptance scenario 5 were
  rewritten around the *intended* behavior (reprice, no notice needed) rather
  than today's actual behavior (freeze, notice required), with the change
  tracked as a **blocking** dependency, D-005, against
  [mbe-api#131](https://github.com/mictlanix/mbe-api/issues/131). This is the
  one place in the spec where a requirement's correctness is contingent on an
  unshipped backend change — D-005 states the interim risk explicitly rather
  than leaving it implicit.
