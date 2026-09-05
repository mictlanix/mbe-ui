# Implementation Plan: Sales Order Refinements — Header, Customer Bar & Navigation

**Branch**: `037-sales-order-refinements` | **Date**: 2026-09-04 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/037-sales-order-refinements/spec.md`

## Summary

Eight items from a live testing session, all on the back-office Sales Orders screen and the customer
bar it shares with the register. Six are small and self-evident: drop a duplicated balance, drop a
duplicated payment-terms field, relabel the terms control, reorder seven disclosed fields, put the
header panel below the customer bar, and move one navigation entry after another.

The two that carry actual risk are the ones Phase 0 research reshaped.

**The credit-terms default is not the change it looked like.** mbe-api already derives credit terms
when an order is *created* with a credit customer — so a brand-new back-office order for such a
customer already lands on credit today. What never happens is terms being revisited on *update*.
That makes the real gaps the register (whose sale is opened by the first scan, before any customer)
and changing the customer on an existing order. The plan therefore leaves the working path
untouched and adds terms only to the update path — and does so asymmetrically, because the server
validates credit terms against facts the client cannot see (a customer's overdue orders), so
bundling credit into the customer-attach write would let an unrelated refusal block the customer
from attaching at all.

**The density change is wider than "selections".** The panel's fields sit in a `Wrap`-based grid
whose every run is as tall as its tallest child. Converting only the selection fields, as asked,
would leave a full outlined box pinning each row and deliver no height reduction whatsoever. So
every control in the panel converts except the comment field, through one shared widget extracted
into `core/widgets/` — which is also where the constitution requires form-field wrappers to live.

A mock gates that work and nothing else: the six mechanical items and the credit-terms fix proceed
without it.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.44.2 (stable)

**Primary Dependencies**: `flutter_riverpod` (state), `go_router` (navigation — reordered, not
otherwise touched), `freezed` (value types), generated `mbe_api_client`. **No new dependency, no
codegen, no schema change** — every endpoint and payload field this feature uses already exists.

**Storage**: none client-side. All state is server-owned; the disclosure state stays per-visit.

**Testing**: `flutter test` — `test/unit`, `test/widget`, `test/golden`, `test/screenshots`,
`test/integration` (live mbe-api, credentials in `.env`).

**Target Platform**: desktop/web first, compact tier supported and verified —
`sales_orders_compact_test.dart` is this feature's overflow guard and gets extended, not just re-run.

**Project Type**: single Flutter application, feature-first layered architecture.

**Performance Goals**: no new network call on the path that matters. The back-office new-order flow
stays at **one** request (protecting it is an explicit requirement, not an optimization); attaching a
credit customer to an already-open sale costs one extra write, which is the POS path where the
alternative is a manual step on every sale.

**Constraints**: two defects were discovered that this feature does **not** fix — string-detail 422s
losing the server's message, and mbe-api refusing to create an order for a credit customer with
overdue orders. Both are recorded in research.md; the second would need an mbe-api issue under §III
rather than a client workaround.

**Scale/Scope**: 2 screens + 1 shared widget + 1 nav entry; 5 user stories, 25 functional
requirements; 1 new shared widget; 1 l10n key retired and 1 relocated; 0 new entities; 4 test files
updated, 1 added, 1 re-verified, 4 goldens + 6 screenshots re-baselined.

## Constitution Check

*GATE: evaluated against `.specify/memory/constitution.md` v1.13.0.*

| Principle | Verdict | Notes |
|---|---|---|
| I. Feature-First Layered Architecture | **PASS** | The one shared addition (`CompactField`) goes to `core/widgets/`, which is where §VI requires it. Everything else stays inside `features/sales/presentation/`. Presentation reads a domain entity (`CustomerListItem.creditLimit`) it is already handed — no new `data` import. |
| II. Riverpod for State & DI | **PASS** | No new provider. The credit derivation is a pure function of a value already in hand — deliberately not a provider, since it needs no caching, async or lifecycle. Writes go through the existing `SaleEditing.updateHeader`. |
| III. Contract-Driven API Integration | **PASS** | No new/changed endpoint, no codegen, no generated-file edit. The sibling `mbe-api` checkout was read to establish server behaviour and **never modified**. The one behaviour that would need a backend change (order creation refused for an overdue credit customer) is recorded as a discovered issue to file upstream, not patched. |
| IV. Deny-by-Default RBAC | **PASS** | No new mutable action. Field gating (`canEdit`, `canEditPriority`) is preserved verbatim and asserted (contract C6). The nav move changes order only — each destination keeps its `PrivilegeGate`, so a user without register access still sees Sales Orders. |
| V. Material 3, White-Labeled Design System | **PASS** | The new widget resolves through spec 022 tokens and *removes* a token bypass (`_TermsFact`'s raw `labelSmall` → `typeRoles.metricLabel`). The l10n change touches both `.arb` catalogues. §V's largest-text-size requirement is met by extending the compact test across all four `TextSizeLevel` factors rather than assuming absorption. |
| VI. Desktop/Web-First, Compact-Ready Layout | **PASS** | The shared `ResponsiveFormGrid` stays the layout (§VI requires it for multi-field forms); only cell contents change. The new form-field wrapper lives in `core/widgets/`, per §VI. §VI's measuring-test rule is treated as binding: the density work ships a test asserting real insets and baselines, not visual sign-off. Padding comes from `spacing` tokens; the existing hard-coded 132 px is not carried into the grid. |
| VII. Online-Only, Server-Rendered Documents | **N/A** | No document or PDF surface touched. |

No gate fails, so **Complexity Tracking carries no entries**.

One judgment call worth naming, since it sits close to §V's "one formatting surface" spirit: this
feature *withdraws* a rule from a previous spec (023 FR-028/029/030, "never write terms except by
explicit choice"). That is a product decision the requester made explicitly, recorded in spec.md's
Assumptions and in `contracts/payment-terms-default.md`, not a constitutional deviation — the
constitution has nothing to say about defaulting policy.

## Project Structure

### Documentation (this feature)

```text
specs/037-sales-order-refinements/
├── plan.md                              # This file
├── spec.md                              # Feature specification (amended after research: FR-006,
│                                        #  FR-010a, FR-016a, 2 edge cases, 1 assumption)
├── research.md                          # Phase 0 — R1..R11 + discovered/out-of-scope
├── data-model.md                        # Phase 1 — entities, terms state table, widget contract
├── quickstart.md                        # Phase 1 — validation guide
├── contracts/
│   ├── payment-terms-default.md         # C1..C5 — the trigger, three routes, refusal handling
│   └── order-header-surface.md          # C1..C7 — strip, fields, order, density, terms caption
├── checklists/
│   └── requirements.md
└── tasks.md                             # Phase 2 (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── widgets/
│   │   └── compact_field.dart               # NEW — caption over control + supporting text
│   │                                        #  (§VI: form-field wrappers live here)
│   └── navigation/
│       └── nav_destinations.dart            # sales-orders moves after pos; the comment that
│                                            #  justifies the old placement is rewritten
├── features/sales/presentation/
│   ├── capture/
│   │   └── customer_bar.dart                # terms caption → salesOrderPaymentTermsLabel;
│   │                                        #  _TermsFact adopts CompactField;
│   │                                        #  onSelected derives + applies terms (C2)
│   └── orders/
│       ├── order_header_panel.dart          # strip loses balance; payment-terms field removed;
│       │                                    #  disclosed group reordered; fields → CompactField
│       └── order_screen.dart                # OrderHeaderPanel moves below CustomerBar
└── l10n/
    ├── app_en.arb                           # retire posCustomerCreditLabel
    └── app_es.arb                           # retire posCustomerCreditLabel

test/
├── widget/features/sales/
│   ├── order_header_disclosure_test.dart    # UPDATE — drop balance; scope the terms finder;
│   │                                        #  assert disclosed order by position; CustomerBar
│   │                                        #  precedes OrderHeaderPanel
│   ├── customer_bar_test.dart               # UPDATE — terms caption; the four C2 cases
│   ├── sales_orders_compact_test.dart       # UPDATE — loop 4 TextSizeLevel factors
│   ├── order_screen_readonly_test.dart      # VERIFY — the only FR-017 edit-gating coverage
│   │                                        #  OrderHeaderPanel has; type-casts the very widgets
│   │                                        #  the density work converts (research R9a)
│   └── order_header_density_test.dart       # NEW — measured insets/baselines (§VI)
├── unit/app/router/
│   └── app_router_test.dart                 # UPDATE — nav order assertion, reusing the file's
│                                            #  existing _flattenDestinations helper (nothing
│                                            #  asserts display order today)
├── golden/pos_capture_golden_test.dart      # RE-BASELINE — 4 customer-bar PNGs
└── screenshots/pos_screens_screenshot_test.dart  # RE-BASELINE — shots 02..07
```

**Structure Decision**: single Flutter app, feature-first. One file is added to `core/widgets/`
because the constitution puts shared form-field wrappers there and the widget has two adopters;
everything else is an edit to a file that already exists. No new feature module, no new layer.

## Implementation Sequencing

Not tasks (that is `/speckit-tasks`), but the dependency shape matters because one stage is gated.

1. **Mechanical corrections** — FR-001, FR-003, FR-004, FR-005, FR-011, FR-012, FR-013, FR-014,
   plus the l10n retirement. Independent of everything else; delivers US1 and US3 on its own.
2. **Navigation** — FR-020, FR-021. Independent of stage 1; one list reorder, one comment rewrite,
   one new assertion.
3. **Credit-terms default** — FR-006 – FR-010a. Independent of stages 1–2. The riskiest logic, and
   the one place where "it works in the UI" is not sufficient evidence: the back-office new-order
   path must still be a single request.
4. **Mock** — FR-015. Produced and put to the user for approval. **Blocks stage 5 and nothing else.**
5. **Density** — FR-016 – FR-019. Requires the approved mock, and requires stage 1 first (there is no
   point converting a field that is about to be deleted).

Stages 1–3 can proceed in any order or in parallel; 4 gates 5.

## Risks

| Risk | Mitigation |
|---|---|
| Adding terms to the attach write regresses the back-office new-order flow from one request to two | Contract C2.1 forbids it explicitly; quickstart §3 asserts the request count, not just the resulting terms |
| A credit refusal blocks the customer from attaching | Contract C2.3/C3 — credit never rides in the attach payload; the follow-up write's refusal is swallowed |
| Converting only selection fields yields no height reduction | Research R5 / FR-016a — every control in a run converts; SC-004 is measured, not eyeballed |
| The hard-coded 132 px width overflows inside a grid cell, or after the wider caption | Research R7 — the shared widget takes no fixed width; the customer bar is re-verified at 390 px |
| Density verified against a bare `MaterialApp` rather than the real theme | Spec 027's T031 is the precedent for exactly this mistake; measurements use the app theme |
| An unscoped `find.text` silently passes because the string moved to the customer bar | Research R9 — every ambiguous finder is scoped by ancestor |
| The density conversion replaces the control widgets, breaking the type-casts that carry FR-017's only edit-gating coverage | Research R9a — `CompactField` wraps rather than replaces; the `Key`-bearing widget keeps its type, and T034 re-verifies |
