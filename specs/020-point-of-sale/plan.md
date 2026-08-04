# Implementation Plan: Point of Sale — Sale Capture

**Branch**: `020-point-of-sale` | **Date**: 2026-08-03 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/020-point-of-sale/spec.md`

## Summary

The first screen in this application that sells rather than maintains. A
cashier opens it, captures a sale line by line, takes payment, and — when the
goods are being delivered — says where each unit goes. Two steps for a counter
sale, three for a delivery.

No new backend endpoint is required for the counter sale and payment path: the
checked-in generated client already exposes every call the flow needs
(research §2, §15). The work is a new `sales` feature module, one screen with
three steps, and one new dependency (`decimal`).

Six findings shape the plan, four of which contradict a naive reading of the
spec or the mock:

1. **Every write returns the whole order** (research §1). Line add, line edit,
   line delete, header update and confirm all return the complete
   `SalesOrderResponse` with server-computed `subtotal`, `tax_total`, `total`
   and `balance`. So the feature is *one* `AsyncNotifier` holding one `Sale`,
   replaced wholesale on every mutation — not a line list plus a totals cache.
   FR-008's "show what the server returns" is free; hand-rolling it is the only
   way to get it wrong.

2. **The delivery split is create-then-trim, and it must be serialized**
   (research §3). Creating a delivery order claims *everything not yet covered*
   by another delivery order for that sale; the client then trims it down. So
   destination *n+1* cannot be created until destination *n* has been trimmed,
   and the counter-pickup remainder must be created **last**. `fulfillment_type`
   is immutable after creation, which is why the remainder is its own create
   rather than an edit. This is the highest-risk sequence in the feature and the
   reason the split algorithm is unit-tested against a fake repository before it
   is wired to a screen.

3. **Three capabilities the delivery step needs do not exist in mbe-api**
   (research §9, §10, §11): a customer's addresses cannot be listed, there is no
   contacts API, and a sale's payments cannot be read back. None of them touch
   P1. Each gets an mbe-api issue and a documented stopgap; the constitution
   forbids patching mbe-api from this repo (§III).

4. **The mock's per-line IVA dropdown cannot save anything** (research §12). No
   line endpoint accepts a tax rate. The control is rendered read-only and
   FR-023 is amended rather than a dead control being built.

5. **The fulfilment mode has to be persisted, and `ship_to` is the only place
   that fits** (research §4). Counter pickup writes the facility's own address —
   which is exactly the test mbe-api itself uses to detect counter pickup — and
   delivery writes the customer's. Mixed is not encoded at all: it only gates
   the close action, so a resumed sale asks about the remainder instead of
   guessing.

6. **The stepper and open-sales selector go in a screen header band, not the app
   bar** (research §13). `AppShell` owns the only app bar and carries exactly one
   trailing control by contract (spec 010 FR-009). Putting screen-owned widgets
   there means changing the shell every other screen depends on. The band sits
   directly beneath it and reads as one header.

Net: one new feature module (~28 new files), 2 shared-widget promotions, one
new dependency, three mbe-api issues filed, and edits to the router, the nav
tree and both `.arb` files.

## Technical Context

**Language/Version**: Dart 3.10 / Flutter (stable)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_generator`, `go_router`,
`freezed`, `dio` via the generated `mbe_api_client`, `flutter_localizations`/`intl`.
**One new dependency: `decimal`** — the POS is the first screen that does
arithmetic on money (outstanding balance, change, quantity distribution, the
paid == total gate) rather than only displaying it, and `double` cannot back a
paid/not-paid decision (research §8).

**Storage**: N/A — online-only, every read and write goes to mbe-api
(constitution §VII). Nothing about a sale is cached locally; that is what makes
an interrupted sale recoverable (SC-004).

**Testing**: `flutter_test` (unit + widget), `integration_test` against a live
mbe-api with runtime-discovered fixtures (research §16)

**Target Platform**: Web (Chrome) primary at 1440 px, desktop; compact tier down
to 360 px

**Project Type**: Single Flutter application, feature-first layering

**Performance Goals**: A scanned product appears within 1 s (SC-002) — one
`product-lookup` call plus one line `POST`, no client-side recomputation. The
step transition into payment is one `confirm` call. The delivery step's writes
are serialized per destination by necessity (research §3), so a three-destination
split is ~3 creates + ~2n line trims, issued as the cashier works rather than in
a burst at the end.

**Constraints**: mbe-api caps list requests at 100 records; a payment cannot be
applied to an unconfirmed order; a delivery order cannot be raised from an
unconfirmed order; `fulfillment_type` is immutable after creation; a line's tax
rate is not writable; no offline capture (constitution §VII).

**Scale/Scope**: 1 screen, 3 steps, 2 dialogs (new customer, new address —
the latter already exists), ~28 new files under `lib/features/sales/`, 58
functional requirements, 5 prioritized user stories.

**Reference-tenant reality**: the counter-sale path can be verified end to end
today. The delivery path can be verified only in its degraded form until the
mbe-api issues in research §9/§10 ship — the address picker searches globally
instead of by customer, and the destination contact is written into the delivery
order's comment.

## Constitution Check

*GATE: evaluated before Phase 0 and re-evaluated after Phase 1 design. Version
1.10.0.*

| Principle | Status | How this feature satisfies it |
|---|---|---|
| **I. Feature-first layered architecture** | PASS | New `lib/features/sales/` with `presentation/`, `domain/`, `data/`. Shared entities (Customer, Product, Warehouse, Address) are **imported from `features/catalog/domain`**, the shared master-data module principle I names by name — not redefined. `presentation` imports `domain` only. |
| **II. Riverpod for state and DI** | PASS | One `AsyncNotifier` for the sale (research §1), plain `Notifier`s for step/mode/draft-entry UI state, repositories exposed as providers and overridable in tests. |
| **III. Contract-driven API integration** | PASS with recorded dependencies | No hand-written DTOs; the generated client already covers every call (research §2, §15). Codegen parity is re-verified before implementation. Three missing backend capabilities are recorded below and filed as mbe-api issues — **not** patched from this repo. |
| **IV. Deny-by-default RBAC** | PASS | Route gated on `salesOrders:read`; opening a sale requires `salesOrders:create`; capture requires `salesOrders:update`; the payment step requires `customerPayments:create`; the delivery step requires `deliveryOrders:create`. A step the cashier cannot perform is absent, never disabled. |
| **V. Material 3, white-labeled** | PASS | The mock's dark canvas is reference only; the screen uses the app theme and `ColorScheme`. All copy from `.arb` in `es`/`en`; money and quantities via `intl` (`PricingFormatters`, promoted to `core/`). |
| **VI. Desktop/web-first, compact-ready** | PASS with 2 deviations | Expanded tier is the primary target; compact down to 360 px via the central breakpoints. Deviations for the line grid's row actions and the header band are recorded in Complexity Tracking. |
| **VII. Online-only, server-rendered documents** | PASS | No local persistence of any kind. Ticket printing is explicitly out of scope and stays server-side when it arrives. |

### RBAC mapping (constitution §IV requires each module to document this)

| Surface | SystemObject | Right |
|---|---|---|
| `/sales/pos` route + nav entry | `salesOrders` (7) | `read` |
| Opening a sale | `salesOrders` (7) | `create` |
| Capturing/editing/removing lines, confirming | `salesOrders` (7) | `update` |
| Recording and applying a payment | `customerPayments` (8) | `create` |
| Reversing an application | `customerPayments` (8) | `update` |
| Creating destinations | `deliveryOrders` (71) | `create` |
| Creating a customer from the sale | `customers` | `create` |
| Creating an address from the sale | `addresses` | `create` |

## Project Structure

### Documentation (this feature)

```text
specs/020-point-of-sale/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output — 16 findings, 4 backend gaps
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   ├── mbe-api-pos.md   # The backend calls this feature consumes
│   └── pos-screen.md    # The screen's own step/state contract
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── app/router/app_router.dart                    # + /sales/pos route and guard
├── core/
│   ├── navigation/nav_destinations.dart          # + Point of Sale destination
│   └── widgets/
│       ├── money_formatters.dart                 # promoted from features/pricing
│       └── number_pad.dart                       # new shared touch keypad
├── features/sales/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── sale.dart                         # header + lines + totals + balance
│   │   │   ├── sale_line.dart
│   │   │   ├── product_lookup_result.dart        # incl. per-warehouse availability
│   │   │   ├── destination.dart                  # a delivery order in POS terms
│   │   │   ├── destination_line.dart
│   │   │   ├── sale_payment.dart
│   │   │   ├── fulfillment_mode.dart             # counter | delivery | mixed
│   │   │   └── open_sale.dart                    # selector row
│   │   ├── repositories/
│   │   │   ├── sales_order_repository.dart
│   │   │   ├── delivery_order_repository.dart
│   │   │   └── customer_payment_repository.dart
│   │   ├── money.dart                            # decimal helpers (research §8)
│   │   ├── destination_split.dart                # create-then-trim algorithm
│   │   └── payment_method_rules.dart             # reference-required table
│   ├── data/
│   │   ├── sales_order_repository_impl.dart
│   │   ├── delivery_order_repository_impl.dart
│   │   └── customer_payment_repository_impl.dart
│   └── presentation/
│       ├── pos_screen.dart                       # step host + header band
│       ├── pos_sale_controller.dart              # the one AsyncNotifier
│       ├── pos_step_controller.dart              # step + mode UI state
│       ├── pos_header_band.dart                  # open-sales selector + stepper
│       ├── open_sales_selector.dart
│       ├── capture/
│       │   ├── capture_step.dart
│       │   ├── customer_bar.dart
│       │   ├── fulfillment_mode_selector.dart
│       │   ├── product_search_field.dart
│       │   ├── product_lookup_controller.dart
│       │   ├── sale_line_row.dart                # expanded tier
│       │   ├── sale_line_card.dart               # compact tier
│       │   └── sale_totals_bar.dart
│       ├── payment/
│       │   ├── payment_step.dart
│       │   ├── payment_controller.dart
│       │   ├── payment_method_grid.dart
│       │   ├── payment_amount_field.dart
│       │   └── applied_payments_panel.dart
│       ├── delivery/
│       │   ├── delivery_step.dart
│       │   ├── delivery_controller.dart
│       │   ├── destination_card.dart
│       │   ├── destination_editor.dart
│       │   └── line_distribution_panel.dart
│       └── customer_inline_create.dart           # wraps the catalog form
└── l10n/{app_en.arb, app_es.arb}                 # + POS strings

test/
├── unit/sales/
│   ├── destination_split_test.dart               # the highest-risk logic
│   ├── money_test.dart
│   ├── payment_method_rules_test.dart
│   └── sale_mapping_test.dart
├── widget/sales/
│   ├── sale_line_row_test.dart
│   ├── payment_step_gate_test.dart
│   ├── step_indicator_test.dart
│   └── pos_compact_layout_test.dart
└── integration/
    └── pos_counter_sale_flow_test.dart           # live mbe-api, runtime fixtures
```

**Structure Decision**: A new `lib/features/sales/` module, the second business
module after `catalog` and the first named in constitution §I's list
(`auth`, `sales`, `inventory`, …). It owns the sale, delivery and payment
repositories; it owns no master data. Route `/sales/pos` follows the
`/sales/...` scheme DESIGN.md §2.2 reserves. Two widgets earn promotion to
`core/widgets/` because a second consumer is foreseeable and the constitution
requires shared widgets to live there: money formatting (already duplicated
intent in `features/pricing`) and the number pad.

## Complexity Tracking

> Deviations from the constitution, with justification.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| §VI row-action rules (Edit-only row action, row click opens read-only, no per-row Delete icon, mandatory pagination and filtering) do not apply to the POS line grid | The line grid is a **data-entry surface**, not a catalog list of records: every cell is directly editable by design, removing a line is the primary corrective action, and the dataset is the sale's own lines (bounded by what the cashier typed, so pagination is meaningless). FR-020–FR-028 describe exactly this. | Applying the catalog rules literally would put a cashier through a row click → read-only detail → Edit toggle for every quantity change — the opposite of a point of sale. The shared table component is not used at all here, so no cross-module consistency is lost. |
| §VI "screen-level controls in the body, `AppBar.actions` empty" is honoured, but the requester asked for the open-sales selector and stepper "on the app bar" | Rendered as a header band at the top of the screen body, directly beneath the shell app bar (research §13). Visually one header; structurally the screen's own. | Injecting them into `AppShell`'s app bar requires either a global provider leaking screen state into shared navigation, or a route-keyed slot in the shell — a change to shared code every screen depends on, for one screen. Recorded here because it is a conscious reading of the requester's instruction; reversing it is a contained change. |
| FR-023 lists the line's tax treatment as editable in place | mbe-api has no writable tax rate on a sale line (research §12). The control is rendered read-only. | Building a dropdown that silently fails to save is worse than showing the rate as a fact. An mbe-api issue is filed if per-line override is genuinely wanted. |
| New dependency `decimal` | Money arithmetic backs a paid/not-paid gate and a quantity distribution that must sum exactly (SC-005, FR-049). | `double` is disqualified for money comparisons; hand-rolled scaled integers are the same work with more places to be wrong. |
| Three mbe-api capabilities missing (research §9, §10, §11) | Recorded as external dependencies per constitution §III; issues filed against mbe-api; stopgaps documented and scoped to P2/P3 only. | Patching mbe-api from this repo is forbidden by §III. Blocking the whole feature on them would stall P1, which needs none of them. |

## Phase 0 — Outline & Research

**Status**: complete → [research.md](./research.md)

16 findings. All Technical Context unknowns resolved; no `NEEDS CLARIFICATION`
markers remain. Four are backend gaps (§9, §10, §11, §12), each with an
mbe-api issue to file and a documented stopgap.

## Phase 1 — Design & Contracts

**Status**: complete

- [data-model.md](./data-model.md) — the eight domain entities, their mapping
  from generated DTOs, validation rules traced to requirements, and the sale's
  state machine.
- [contracts/mbe-api-pos.md](./contracts/mbe-api-pos.md) — every backend call
  this feature makes, with preconditions and failure modes.
- [contracts/pos-screen.md](./contracts/pos-screen.md) — the screen's own
  contract: step machine, what each step owns, what survives a reload.
- [quickstart.md](./quickstart.md) — how to run and validate the feature end to
  end.

**Post-design constitution re-check**: PASS. The design adds no principle
violation beyond the four recorded in Complexity Tracking. Layering holds
(`presentation` → `domain` only; `data` implements `domain` interfaces); every
mutable action is RBAC-gated; nothing is cached locally.
