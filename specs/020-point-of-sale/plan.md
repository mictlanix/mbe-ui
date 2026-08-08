# Implementation Plan: Point of Sale — Sale Capture

**Branch**: `020-point-of-sale` | **Date**: 2026-08-03, revised 2026-08-05 |
**Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/020-point-of-sale/spec.md`

## Summary

The first screen in this application that sells rather than maintains. A
cashier opens it, captures a sale line by line, takes payment, and — when the
goods are being delivered — says where each unit goes. Two steps for a counter
sale, three for a delivery. As of this revision, a fourth precondition sits in
front of all of it: a cash session must already be open.

No new backend endpoint is required — the checked-in generated client already
exposes every call the flow needs, **including all eight capabilities this
plan originally had to work around** (research §§9–12, §17; mbe-api PR #139,
verified 2026-08-05). The work is an extension of the `lib/features/sales/`
module spec 021 (cash sessions) already built, one screen with three steps
plus a gate, and reuse of infrastructure 021 already shipped in the same
module — no new decimal dependency, no new money-formatting promotion, both
already done.

Seven findings shape this revision, four of which materially shrink the
feature from its first draft:

1. **The delivery split is no longer client-side arithmetic**
   (research §3, resolved). `DeliveryOrderCreate` now accepts a named line
   subset in one call. The create-then-trim orchestrator this plan's first
   draft called "the highest-risk logic in the feature" — its own dedicated
   unit test, its serialization constraint, its per-destination write
   ordering — is deleted, not merely simplified. What replaces it is a pure
   function computing *what to request*, with no sequencing to get wrong.

2. **Three backend gaps this plan filed issues for have all shipped**
   (research §9–§11, resolved): a customer's addresses and contacts are now
   reachable, and a sale's payments can be listed back. Every stopgap they
   drove — the global-address-search fallback, contact-info stuffed into a
   delivery order's `comment`, the session-scoped payment list with its
   explanatory note — is removed outright. SC-004's original promise
   ("every captured line, payment and destination intact") is restored to its
   full form; a prior revision of this spec had to walk it back specifically
   because the payments gap existed.

3. **The line's tax rate is genuinely editable now** (research §12, resolved).
   FR-023's read-only amendment and its Complexity Tracking entry are both
   reverted — the mock's per-line tax control can be built as originally
   designed.

4. **A cash session is now a hard precondition, by explicit product
   decision** (research §18). Spec 021 shipped a complete, independent cash
   session feature and deliberately decided *against* coupling it to this one
   — recorded in 021's own spec as D-002, "wiring POS to the session state is
   a deliberate follow-up." That follow-up is this revision: entering the
   screen now checks `GET /cash-sessions/current` before anything else, and no
   sale opens without one. This is a considered reversal of 021's own
   decision, not an oversight in either spec — both are amended to record why
   (spec.md D-006, research §18).

5. **This feature no longer owns an empty module.** `lib/features/sales/` was
   fully populated by 021 before this feature's first line of code. Reused
   directly: `decimal` (already a dependency), `domain/money.dart` (extended,
   not duplicated), the promoted `MoneyFormatters`, the shared `PaymentMethod`
   enum, and `currentSessionControllerProvider` itself. This plan's original
   file count is smaller as a result — money arithmetic and formatting were
   both already built for a different reason and turn out to be exactly what
   this feature needed too.

6. **`requires_reference` is server-computed now** (research §6, resolved).
   The client-side `payment_method_rules.dart` table this plan's first draft
   specified is deleted from the plan entirely — the field reads directly off
   `PaymentMethodOptionResponse`.

7. **The screen's own RBAC gate follows 021's precedent, not this plan's
   original guess.** Legacy's `SystemObject.pos` (44) — "Point of sale
   terminal (POS module)," confirmed against `mbe/docs/constants.md` — is what
   021 already gates session read/open on. This plan's first draft gated the
   route and "open a sale" on `salesOrders` instead; that's corrected to `pos`,
   matching the established precedent, while line-level mutations (add/edit/
   confirm) keep using `salesOrders`, the resource actually being mutated.

Net effect on scope: fewer new files than originally planned (two shared
utilities already exist), a small number of new shared **catalog** files this
feature needs but 021 didn't (a `ContactRepository` and its inline-create
dialog, extending `Customer`/`CustomerRepository` to map addresses/contacts,
extending `PaymentMethodOption` to map `requiresReference`), and one new
screen state (the cash-session gate) that did not exist in any prior
revision.

## Technical Context

**Language/Version**: Dart 3.10 / Flutter (stable)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_generator`, `go_router`,
`freezed`, `dio` via the generated `mbe_api_client`, `flutter_localizations`/`intl`,
`decimal` (^3.2.6, **already present** — added by 021-cash-sessions for the
identical reason this feature needs it; no new dependency).

**Storage**: N/A — online-only, every read and write goes to mbe-api
(constitution §VII). Nothing about a sale is cached locally; that is what makes
an interrupted sale recoverable (SC-004), and it is now also true of applied
payments, which were the one exception to this in a prior revision.

**Testing**: `flutter_test` (unit + widget), `integration_test` against a live
mbe-api with runtime-discovered fixtures (research §16), including a real open
cash session as a fixture precondition.

**Target Platform**: Web (Chrome) primary at 1440 px, desktop; compact tier down
to 360 px

**Project Type**: Single Flutter application, feature-first layering. This
feature **extends** an existing module (`lib/features/sales/`, populated by
021-cash-sessions) rather than creating a new one.

**Performance Goals**: A scanned product appears within 1 s (SC-002) — one
`product-lookup` call plus one line `POST`, no client-side recomputation. The
step transition into payment is one `confirm` call. Creating a delivery
destination is now one call, not a create-plus-N-trims sequence (research §3)
— a three-destination split issues three requests total for the split itself,
plus whatever edits the cashier makes afterward, down from the prior
create-then-trim design's serialized sequence of roughly `3 + 2n` requests.

**Constraints**: mbe-api caps list requests at 100 records; a payment cannot be
applied to an unconfirmed order; a delivery order cannot be raised from an
unconfirmed order; `fulfillment_type` is immutable after creation; no offline
capture (constitution §VII); **no sale opens without a current cash session**
(new, product decision, research §18).

**Scale/Scope**: 1 screen, 1 gate state + 3 steps, 3 dialogs (new customer,
new address, new contact — the last two new to this feature), extends an
existing module rather than a ~28-file new one, 60 functional requirements
(58 original + 2 new for the session gate), 5 prioritized user stories (one
gains a precondition, none added).

**Reference-tenant reality**: the counter-sale path, the delivery path and the
payment-history path can all now be verified end to end against a live
mbe-api — no degraded-mode testing is required for any of them, unlike the
prior revision where three of the five user stories could only be verified in
a stopgap form.

## Constitution Check

*GATE: evaluated before Phase 0 and re-evaluated after Phase 1 design. Version
1.10.0.*

| Principle | Status | How this feature satisfies it |
|---|---|---|
| **I. Feature-first layered architecture** | PASS | Extends `lib/features/sales/` (already `presentation/`, `domain/`, `data/`, populated by 021). Shared entities (Customer, Product, Warehouse, Address, Contact, PriceList) are **imported from `features/catalog/domain`**, extended there when a new field is needed (addresses/contacts on `Customer`, `requiresReference` on `PaymentMethodOption`) — never redefined per feature. `presentation` imports `domain` only. |
| **II. Riverpod for state and DI** | PASS | One `AsyncNotifier` for the sale (research §1), plain `Notifier`s for step/mode/draft-entry UI state, repositories exposed as providers and overridable in tests. `currentSessionControllerProvider` (021) is watched, not re-implemented. |
| **III. Contract-driven API integration** | PASS | No hand-written DTOs; the generated client covers every call, including all 8 capabilities this feature originally had to file issues for (research §15, done). No outstanding external dependency remains. |
| **IV. Deny-by-default RBAC** | PASS | Route and "open a sale" gated on `pos:read`/`pos:create` (research §14, §18 — corrected from `salesOrders` in this revision, matching 021's precedent); line capture/confirm on `salesOrders:update`; the payment step on `customerPayments:create`/`read`; the delivery step on `deliveryOrders:create`. A step the cashier cannot perform is absent, never disabled. |
| **V. Material 3, white-labeled** | PASS | The mock's dark canvas is reference only; the screen uses the app theme and `ColorScheme`. All copy from `.arb` in `es`/`en`; money and date/time via `MoneyFormatters` (`core/widgets/`, already promoted by 021). |
| **VI. Desktop/web-first, compact-ready** | PASS with 2 deviations | Expanded tier is the primary target; compact down to 360 px via the central breakpoints. Deviations for the line grid's row actions and the header band are recorded in Complexity Tracking — unchanged from the prior revision. |
| **VII. Online-only, server-rendered documents** | PASS | No local persistence of any kind. Ticket printing is explicitly out of scope and stays server-side when it arrives. |

### RBAC mapping (constitution §IV requires each module to document this)

| Surface | SystemObject | Right | Note |
|---|---|---|---|
| `/sales/pos` route + nav entry | `pos` (44) | `read` | **Revised** — was `salesOrders`; matches 021's precedent and legacy's own "POS module" privilege |
| Opening a sale (the register action) | `pos` (44) | `create` | **Revised**, same reason |
| Capturing/editing/removing lines, confirming | `salesOrders` (7) | `update` | Unchanged — the resource actually being mutated |
| Reading a sale's applied payments | `customerPayments` (8) | `read` | New surface (research §11, resolved) |
| Recording and applying a payment | `customerPayments` (8) | `create` | |
| Reversing an application | `customerPayments` (8) | `update` | |
| Creating destinations | `deliveryOrders` (71) | `create` | |
| Creating a customer from the sale | `customers` | `create` | |
| Creating an address from the sale | `addresses` | `create` | |
| Creating a contact from the sale | `contacts` (12) | `create` | New surface (research §10, resolved) |
| Reading current cash session state (the gate) | `pos` (44) | `read` | Reused from 021 |

## Project Structure

### Documentation (this feature)

```text
specs/020-point-of-sale/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output — 18 findings; 8 resolved backend gaps, 1 new (cash session)
├── data-model.md         # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   ├── mbe-api-pos.md   # The backend calls this feature consumes — all issues shipped
│   └── pos-screen.md    # The screen's own step/state contract, incl. the session gate
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── app/router/app_router.dart                    # + /sales/pos route and guard
├── core/
│   ├── navigation/nav_destinations.dart          # + Point of Sale destination (append, don't renumber — 021's own precedent)
│   └── widgets/
│       ├── money_formatters.dart                 # existing (021) — unchanged
│       └── number_pad.dart                       # new shared touch keypad — 021 built no equivalent
├── features/
│   ├── catalog/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── customer.dart                 # EDIT — map .addresses/.contacts
│   │   │   │   ├── contact.dart                  # NEW — mirrors AddressListItem
│   │   │   │   └── payment_method_option.dart     # EDIT — map .requiresReference
│   │   │   └── repositories/
│   │   │       ├── customer_repository.dart       # EDIT — accept addresses/contacts on create/update
│   │   │       └── contact_repository.dart         # NEW — mirrors address_repository.dart (list + create only)
│   │   ├── data/
│   │   │   ├── customer_repository_impl.dart      # EDIT
│   │   │   └── contact_repository_impl.dart        # NEW
│   │   └── presentation/
│   │       └── contact_inline_create.dart          # NEW — mirrors address_inline_create.dart
│   └── sales/                                      # EXTENDS 021's module, not a new one
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── sale.dart                       # header + lines + totals + balance
│       │   │   ├── sale_line.dart                  # taxRate now writable
│       │   │   ├── product_lookup_result.dart      # incl. per-warehouse availability
│       │   │   ├── destination.dart                # a delivery order in POS terms; created complete, not trimmed
│       │   │   ├── destination_line.dart
│       │   │   ├── line_distribution.dart          # in-progress draft view model (data-model.md §6, simplified)
│       │   │   ├── sale_payment.dart                # from OrderApplicationResponse now, not session state
│       │   │   ├── fulfillment_mode.dart            # counter | delivery | mixed
│       │   │   └── open_sale.dart                  # selector row
│       │   ├── repositories/
│       │   │   ├── sales_order_repository.dart
│       │   │   ├── delivery_order_repository.dart  # create() now takes lines
│       │   │   └── customer_payment_repository.dart # + listForOrder()
│       │   └── money.dart                          # EDIT (021 already created it) — add generic add/subtract/compare/isZero
│       ├── data/
│       │   ├── sales_order_repository_impl.dart
│       │   ├── delivery_order_repository_impl.dart
│       │   └── customer_payment_repository_impl.dart
│       └── presentation/
│           ├── pos_gate_screen.dart                 # NEW — §0, no session
│           ├── pos_screen.dart                      # step host + header band
│           ├── pos_sale_controller.dart             # the one AsyncNotifier
│           ├── pos_step_controller.dart             # step + mode UI state
│           ├── pos_header_band.dart                 # open-sales selector + stepper + stale-session banner
│           ├── open_sales_selector.dart
│           ├── capture/
│           │   ├── capture_step.dart
│           │   ├── customer_bar.dart                # + payment-terms toggle
│           │   ├── fulfillment_mode_selector.dart
│           │   ├── product_search_field.dart
│           │   ├── product_lookup_controller.dart
│           │   ├── sale_line_row.dart                # expanded tier — tax rate now editable
│           │   ├── sale_line_card.dart               # compact tier
│           │   └── sale_totals_bar.dart
│           ├── payment/
│           │   ├── payment_step.dart
│           │   ├── payment_controller.dart
│           │   ├── order_payments_controller.dart    # NEW — replaces the session-scoped list
│           │   ├── payment_method_grid.dart          # reads requiresReference directly
│           │   ├── payment_amount_field.dart
│           │   └── applied_payments_panel.dart
│           ├── delivery/
│           │   ├── delivery_step.dart
│           │   ├── delivery_controller.dart          # create() is one call now, not an orchestrator
│           │   ├── destination_card.dart
│           │   ├── destination_editor.dart           # picks/creates a real Contact, not comment text
│           │   └── line_distribution_panel.dart
│           └── customer_inline_create.dart           # wraps the catalog form
└── l10n/{app_en.arb, app_es.arb}                     # + POS strings, + gate screen strings

test/
├── unit/features/sales/
│   ├── line_distribution_test.dart                   # replaces destination_split_test.dart — arithmetic only, no sequencing
│   ├── money_test.dart                                # tests the added generic helpers, not countedTotal/expectedCash (021's own tests cover those)
│   └── sale_mapping_test.dart
├── unit/features/catalog/
│   └── customer_mapping_test.dart                     # NEW — addresses/contacts mapping
├── widget/features/sales/
│   ├── sale_line_row_test.dart                        # incl. the now-editable tax rate
│   ├── payment_step_gate_test.dart
│   ├── pos_gate_screen_test.dart                       # NEW — §0
│   ├── step_indicator_test.dart
│   ├── pos_compact_layout_test.dart
│   ├── pos_compact_delivery_test.dart
│   └── pos_compact_resume_and_customer_test.dart
└── integration/
    ├── pos_counter_sale_flow_test.dart                 # live mbe-api, runtime fixtures, incl. a real open session
    ├── pos_delivery_split_flow_test.dart
    └── pos_resume_flow_test.dart
```

**Structure Decision**: Extends `lib/features/sales/`, populated by
021-cash-sessions. Shared master-data extensions (Customer addresses/contacts,
Contact itself, PaymentMethodOption's `requiresReference`) live in
`features/catalog/`, per constitution §I — this feature needs them, but they
are not POS-specific, and a future feature needing a customer's contacts would
otherwise face the same gap this feature closes. Route `/sales/pos` follows
the `/sales/...` scheme DESIGN.md §2.2 reserves, alongside 021's
`/sales/cash-sessions`.

## Complexity Tracking

> Deviations from the constitution, with justification.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| §VI row-action rules (Edit-only row action, row click opens read-only, no per-row Delete icon, mandatory pagination and filtering) do not apply to the POS line grid | The line grid is a **data-entry surface**, not a catalog list of records: every cell is directly editable by design, removing a line is the primary corrective action, and the dataset is the sale's own lines (bounded by what the cashier typed, so pagination is meaningless). FR-020–FR-028 describe exactly this. | Applying the catalog rules literally would put a cashier through a row click → read-only detail → Edit toggle for every quantity change — the opposite of a point of sale. The shared table component is not used at all here, so no cross-module consistency is lost. |
| §VI "screen-level controls in the body, `AppBar.actions` empty" is honoured, but the requester asked for the open-sales selector and stepper "on the app bar" | Rendered as a header band at the top of the screen body, directly beneath the shell app bar (research §13). Visually one header; structurally the screen's own. | Injecting them into `AppShell`'s app bar requires either a global provider leaking screen state into shared navigation, or a route-keyed slot in the shell — a change to shared code every screen depends on, for one screen. |
| This feature's screen-level RBAC gate (`pos`) is checked *before* the sale-record-level gate (`salesOrders`) that the underlying writes use | Matches 021's own precedent and legacy's `SystemObject.pos` (44) module privilege; a user could in principle hold one without the other, in which case the screen should be reachable/openable but line capture would still correctly refuse. | Gating everything on a single `SystemObject` (either one alone) would either let a user without `salesOrders:update` open a sale they then cannot capture into (confusing), or gate the screen itself on the resource-level privilege, diverging from 021's already-shipped precedent for the same module. |
| A hard cash-session precondition (research §18) — reverses 021's own explicitly recorded D-002 decision against POS coupling | Explicit product decision: a register should not take money with no shift open, and 021 itself named this exact wiring a "deliberate follow-up" rather than a permanently closed door. Both specs' text is updated to record the reversal and why, rather than silently overriding 021's decision. | A soft gate (show state, don't block) was considered and rejected — it would let a cashier ring up and collect payment against no shift at all, producing the "permanently unattributed payment" condition 021's own D-007 already warns about. |

## Phase 0 — Outline & Research

**Status**: complete → [research.md](./research.md)

18 findings (16 original + 1 revised into two + 1 new). All 8 originally-filed
mbe-api issues (§9–§12, §17, plus §3, §5, §6's dependencies) verified shipped
2026-08-05. §18 is new: the cash-session hard gate. No `NEEDS CLARIFICATION`
markers remain.

## Phase 1 — Design & Contracts

**Status**: complete

- [data-model.md](./data-model.md) — the domain entities (a `CashSession`
  precondition section added, `Contact` added, `LineDistribution` simplified),
  their mapping from generated DTOs, validation rules traced to requirements,
  and the sale's state machine.
- [contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md) — every backend call
  this feature makes; the "issues to file" section is now "issues shipped."
- [contracts/pos-screen.md](./contracts/pos-screen.md) — the screen's own
  contract: the session gate (§0), step machine, what each step owns, what
  survives a reload.
- [quickstart.md](./quickstart.md) — how to run and validate the feature end to
  end, now including a live cash-session fixture.

**Post-design constitution re-check**: PASS. The design adds no principle
violation beyond the three recorded in Complexity Tracking (down from four —
the "3 missing backend capabilities" deviation from the prior revision no
longer applies; nothing is missing). Layering holds (`presentation` → `domain`
only; `data` implements `domain` interfaces; catalog extensions live in
`catalog`, not duplicated in `sales`); every mutable action is RBAC-gated;
nothing is cached locally.
