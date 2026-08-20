# Implementation Plan: Back-Office Sales Orders ("Pedidos")

**Branch**: `029-back-office-sales-orders` | **Date**: 2026-08-19 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/029-back-office-sales-orders/spec.md`

## Summary

A back-office twin of the register: a facility-scoped sales-order list plus a
capture/confirm screen for salespeople who are not standing at a point of sale.
No backend change, no codegen, no new dependency — every filter, field and action
the feature needs is already on the wire ([research.md](./research.md) §R2, §R3).

The work is shaped by five findings, two of which contradict a naive reading of
the spec:

1. **The reuse coupling is four call sites, not five files** (R1). Of the widgets
   that read the POS singleton, `capture_step.dart` and
   `fulfillment_mode_selector.dart` are POS *step* machinery and are not shared at
   all — the back-office screen composes the pieces itself and uses a plain
   ship-to picker, since delivery is out of scope. That leaves `customer_bar`,
   `product_lookup_controller` and `sale_line_editing` — four reads — swapped to a
   `saleEditorProvider` indirection **whose default is the POS controller**. The
   default is load-bearing: it is why no existing POS test needs an edit (SC-007).

2. **Price must not be editable, and the spec says it is** (R9.1). The shared
   capture surface makes price read-only by design (spec 020 FR-038c), and legacy
   "Pedidos" agrees — in the attached screenshot only quantity, discount, tax and
   comment carry the editable underline. FR-020 needs correcting; building it as
   written would fork the shared widget or change POS behaviour, violating FR-029
   or FR-031.

3. **`Sale` carries none of the header fields this feature exists to expose**
   (R2). `date`, `dueDate`, `contact`, `recipient`, `recipientName`, `priority`
   and `comment` are all already on the wire in `SalesOrderResponse` and simply
   never mapped. The extension is additive and invisible to POS, but it also means
   a new hand-mapped `Priority` enum (the generator emits `number0/1/2`), the same
   gap `PaymentTerms` and `CurrencyCode` already work around in `sale.dart`.

4. **`mine=true` is trustworthy** (R4). mbe-api's `mine` filter is guarded by
   `current.employee_id is not None`, which reads like a hole — but `employee_id`
   has been NOT NULL since mbe-api migration 012, so the narrowing can never
   silently degrade to "everything". FR-006 is safe to build on. The guard is
   applied in the *controller*, from `access.isAdministrator`, never from URL
   state — which is what makes a hand-edited address a non-event.

5. **Every facet already has a working precedent** (R6). The two admin facets are
   the pattern `cash_sessions_screen.dart` already uses: a `CatalogEntityPicker`
   inside the filter drawer, seeded from a `*DisplayNameProvider` so an id arriving
   in the URL still renders a name. Nothing is invented.

One smaller consequence the spec did not anticipate: **the per-line comment is new
UI on a shared widget** (R9.2). It ships as an opt-in `showComment` parameter
defaulting to `false`, so the register's line layout is untouched.

Net: ~14 new files, edits to 8 existing ones (4 of them one-line provider swaps),
both `.arb` files, the router and the nav tree.

## Technical Context

**Language/Version**: Dart 3.x / Flutter (stable)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_generator`, `go_router`,
`freezed`, `dio` via the generated `mbe_api_client`, `data_table_2`,
`flutter_localizations`/`intl`. **No new dependency.**

**Storage**: N/A — online-only, every read and write goes to mbe-api
(constitution §VII)

**Testing**: `flutter_test` (unit + widget), `integration_test` against a live
mbe-api

**Target Platform**: Web (Chrome) primary, macOS/desktop; compact tier at < 600 px

**Project Type**: Single Flutter application, feature-first layering

**Performance Goals**: One list request per view (page size 20). The order screen
issues one request per mutation and holds the server's response — no local
recomputation. Opening the screen issues **zero** writes until the first line or
header edit (FR-015, SC-005).

**Constraints**: mbe-api caps list requests at 100 rows
(`limit: Query(20, ge=1, le=100)`); a listing is always exactly one facility;
`sales_order.point_sale` is NOT NULL, so creation needs a configured register;
no backend change is in scope.

**Scale/Scope**: 2 new screens (list + order), 1 new list controller, 1 new order
controller, 1 shared-editor indirection, 2 admin facets. An unfiltered
`GET /sales-orders` measured 19,277 rows for one register (spec 023 R6), which is
why the date range defaults bounded (R5).

## Constitution Check

*GATE: evaluated before Phase 0 and re-evaluated after Phase 1 design. Both passes
below reach the same verdict.*

| Principle | Assessment |
|---|---|
| **I. Feature-First Layered Architecture** | PASS. Everything lands in `lib/features/sales/`. `Sale`/`SaleLine` gain fields in `domain/entities/`; the repository method is declared in `domain/repositories/` and implemented in `data/`; controllers and screens in `presentation/`. `SaleEditor` is a presentation-layer façade over notifiers and lives there. `presentation` reaches `data` only through the existing repository providers, exactly as every sibling controller does. |
| **II. Riverpod for State & DI** | PASS. The list is a `@riverpod` family keyed by the freezed filter (the `PosSalesFilter` shape); the order is a `@riverpod` autoDispose family keyed by order id. `saleEditorProvider` is a plain `Provider` overridden in a nested `ProviderScope` — DI, which is what Riverpod is for. Form-local state (text controllers, drawer open/closed) stays view-local `State`, per §II's "form state and selections are local UI state". |
| **III. Contract-Driven API Integration** | PASS. No codegen, no new DTO, no hand-written model, no mbe-api edit. New fields are mapped from the **already-generated** `SalesOrderResponse`. Errors continue to surface as domain error types through `ErrorBanner`. No multipart is involved, so §III's binary-upload rule does not apply. |
| **IV. Deny-by-Default RBAC** | PASS. Route gated on `SystemObject.salesOrders` read; create/update/cancel each hidden (not disabled) behind `can(salesOrders, …)`. The admin-only facets are gated on `access.isAdministrator`. **Stated plainly**: the facet restriction and the own-orders rule are client-side product rules — mbe-api enforces neither (spec A2, R4). Nothing in this plan claims otherwise. |
| **V. Material 3, White-Labeled** | PASS. All colour/elevation/typography from `Theme.of(context)`; spacing from the spec 022 tokens; every string localized in both `.arb` files, `es-MX` authored first; every date, money and percentage rendered through the spec 028 formatting surface (`formattersProvider`). |
| **VI. Desktop/Web-First, Compact-Ready** | PASS. The list is `CatalogFilterBar` + `DataTableView` + `CatalogPagination` with **all** facets behind the badged drawer (§VI rule (a)) and no form stacked above it (rule (b)) — the order screen is its own route. Row actions are Edit only, with the whole row opening the order read-only; cancel lives on the order's own screen, never on a row. Compact tier degrades to the established card treatment. |
| **VII. Online-Only** | PASS. No caching beyond ordinary provider lifetime, no offline storage, no client-side document rendering — and nothing to render, since mbe-api has no sales-order document (spec A5). |

**No entries in Complexity Tracking.** The one structural addition — the
`SaleEditor` indirection — exists to *avoid* the simpler-looking alternatives
(fork the widgets, or re-key the POS controller), both of which are rejected with
reasons in R1.

## Project Structure

### Documentation (this feature)

```text
specs/029-back-office-sales-orders/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── routes.md
│   ├── sales-orders-screen.md
│   └── mbe-api-sales-orders.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── app/router/
│   └── app_router.dart                      # EDIT: 1 branch + 2 top-level routes + 1 guard
├── core/navigation/
│   └── nav_destinations.dart                # EDIT: NavBranch.salesOrders = 20, Sales destination
└── features/sales/
    ├── domain/
    │   ├── entities/
    │   │   ├── sale.dart                    # EDIT: +date, dueDate, contact, recipient,
    │   │   │                                #       recipientName, priority, comment; +Priority enum
    │   │   └── sale_line.dart               # unchanged (comment already mapped)
    │   └── repositories/
    │       └── sales_order_repository.dart  # EDIT: +listOrders(); +optional header params
    ├── data/
    │   └── sales_order_repository_impl.dart # EDIT: implement the above
    └── presentation/
        ├── sale_editor.dart                 # NEW: SaleEditor interface + saleEditorProvider
        ├── sale_editing.dart                # NEW: mixin with the shared mutation bodies
        ├── pos_sale_controller.dart         # EDIT: `with SaleEditing`, implements SaleEditor
        ├── orders/
        │   ├── sales_orders_list_controller.dart   # NEW: filter + page family
        │   ├── sales_orders_list_screen.dart       # NEW: /sales/orders
        │   ├── sales_orders_filters_panel.dart     # NEW: drawer facets (admin-aware)
        │   ├── order_editor_controller.dart        # NEW: autoDispose family by order id
        │   ├── order_screen.dart                   # NEW: /sales/orders/new|:orderId
        │   ├── order_header_panel.dart             # NEW: the header fields
        │   └── order_no_register_notice.dart       # NEW: FR-014 blocked state
        └── capture/
            ├── customer_bar.dart            # EDIT: 1 provider read → saleEditorProvider
            ├── product_lookup_controller.dart # EDIT: same
            ├── sale_line_editing.dart       # EDIT: 2 reads → saleEditorProvider
            └── sale_line_row.dart / _card.dart  # EDIT: opt-in showComment (default false)

test/
├── unit/features/sales/
│   ├── sales_orders_filter_test.dart        # NEW
│   ├── sales_orders_scoping_test.dart       # NEW  (mine / facility rule)
│   ├── sale_mapping_test.dart               # EDIT: the new header fields
│   └── sales_order_list_orders_test.dart    # NEW  (repository, mocked client)
├── widget/features/sales/
│   ├── sales_orders_list_screen_test.dart   # NEW
│   ├── order_screen_test.dart               # NEW
│   ├── order_screen_readonly_test.dart      # NEW
│   ├── sale_editor_isolation_test.dart      # NEW  (FR-030 — the two screens do not collide)
│   └── pos_test_harness.dart                # unchanged (that is the point)
└── integration/
    └── sales_orders_flow_test.dart          # NEW  (live golden path)
```

**Structure Decision**: single Flutter application, feature-first. The feature is
an addition to the existing `features/sales` module — it introduces no new module
and no shared-kernel entity. New screens are grouped under
`presentation/orders/` to keep them legible beside the register's own files,
which already number 40+ in `presentation/`.

## Phase 2 note

`/speckit-tasks` will phase the work by user story. The dependency order that
matters: the `Sale` extension and the repository method (R2, R3) unblock
everything; the `SaleEditor` refactor (R1) must land **with the POS suite green**
before the order screen is built on it; the list (US3) and the admin facets (US5)
are independent of the order screen and can proceed in parallel.
