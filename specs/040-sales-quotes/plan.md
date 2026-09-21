# Implementation Plan: Sales Quotes — Cotizaciones

**Branch**: `040-sales-quotes` | **Date**: 2026-09-20 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/040-sales-quotes/spec.md`

## Summary

Add a Cotizaciones screen: write a priced offer to a named customer on the same capture surface
the register and the back-office order workspace use, confirm it, and convert an accepted one
into a back-office order. One screen, one step, no payment, no delivery.

Everything the feature was specified against has shipped. The server is complete, the dio
client is generated and committed, the permission slot exists, and `039` made the capture step
host-agnostic. **No codegen against mbe-api is required and no mbe-api issue is open.** That is
unusual for this project and it makes the screen itself the cheap part.

The cost is concentrated in one place the feature description does not hint at. `Sale` and
`SaleLine` were shaped for sales orders: `pointSale`, `promiseDate`, `priority`, `balance` and
`cost` are all `required`, and a quote has none of them. The seam forecloses a separate entity —
`SaleEditor.ensureOpen()` returns `Future<Sale>` and every shared widget takes `Sale` — so the
entity must widen. Four of the five fields cost seven edits between them. **`balance` costs
eleven, ten of them in the POS payment surface**, for a feature with no payment step. Research
R2 argues that price is worth paying, because nullability is what turns "a quote reached the
payment code" from a silent behaviour into a compile error.

The second real cost is that the capture step still assumes stock. Its warehouse picker renders
unconditionally and *writes*, and it resolves a default warehouse through the signed-in user's
register — wrong twice for a quote. One new parameter, `showWarehouse`, gates the picker, the
stock-cache seed and the point-of-sale lookup together.

Net: 2 shared entities widened, 5 shared capture files touched, ~10 new files, and a
three-way generalization of the host-isolation test.

## Technical Context

**Language/Version**: Dart 3.x / Flutter (stable channel)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` (codegen), `go_router`,
`freezed`, `dio` via the generated `mbe_api_client` (`lib/generated/openapi`),
`flutter_localizations` + `intl`. **No new dependency.**

**Storage**: None client-side (constitution VII — online only). All state is mbe-api's.

**Testing**: `flutter_test` (unit + widget) and live-backend flows under `test/integration/`
(this repo has no top-level `integration_test/`). No golden work is tasked: `test/golden/`
goldens the *leaf* widgets directly, and the one changed leaf — a line row without its
warehouse column — is covered by a widget test at a pinned width instead (research R1).

**Target Platform**: Web and desktop first, compact (phone) tier supported — constitution VI

**Project Type**: Single Flutter application; feature-first layering under `lib/features/sales/`

**Performance Goals**: No new budget. One consequence to preserve: a quote host must issue
**fewer** requests than an order host, not more — `showWarehouse: false` removes a point-of-sale
fetch and a per-facility warehouse list that a quote has no use for.

**Constraints**:
- Point-of-sale and back-office order behaviour must be observably unchanged (FR-040, SC-007).
  Every existing test in `test/widget/features/sales/` must pass **unmodified** except the
  isolation test and the shared harness.
- No mbe-api source may be edited from this repo (constitution, Development Workflow).

**Scale/Scope**: One list screen, one quote screen, one repository, one controller, one
widened entity pair. ~10 new files; 5 shared capture files and 4 order/POS files edited;
~35-45 new l10n keys; ~15 test files added or touched.

**External dependencies**: **none open.** For the record, all three that this feature was
specified against have closed:

| Dependency | What it blocked | Status |
|---|---|---|
| `039-back-office-order-workspace` | The host-agnostic capture step; the conversion landing target | **Merged to `main`.** Its published contract is stale — see below. |
| [mbe-api#213](https://github.com/mictlanix/mbe-api/issues/213) | Customer names and name search on the quote list (US3) | **Shipped and closed 2026-09-12.** |
| [mbe-api#209](https://github.com/mictlanix/mbe-api/issues/209) | Recognising a converted order's origin | **Shipped.** `convert_to_order` stamps `origin = BACK_OFFICE`, so with `041`'s scoping a converted quote lands in "Pedidos" and not the register list, with no work here. |

⚠ **`039/contracts/shared-step-seam.md` documents a four-parameter `CaptureStep`; the shipped
widget takes eight and `continueLabel` is optional.** Tasks must be written against the code.
[`contracts/quote-capture-host.md`](./contracts/quote-capture-host.md) records the real
signature.

Two items remain that the client cannot assert and that are therefore **release checks, not
tasks**, both in [quickstart.md](./quickstart.md): that the quote list is facility-scoped
server-side (the endpoint has no `facility` parameter), and the live shape of convert's refusal
bodies.

## Constitution Check

*GATE: evaluated before Phase 0 and re-evaluated after Phase 1.*

| Principle | Verdict | Notes |
|---|---|---|
| **I. Feature-first layered architecture** | PASS | Everything lands under `lib/features/sales/` in the existing `data`/`domain`/`presentation` split, with the screens in a `presentation/quotes/` sub-feature mirroring `presentation/orders/`. `presentation` continues to depend only on `domain`. |
| **II. Riverpod for state & DI** | PASS | The quote host installs the same four-provider nested `ProviderScope` the order workspace uses. The controller is a family-keyed `@riverpod` notifier mirroring `OrderEditorController`. No new DI mechanism. |
| **III. Contract-driven API integration** | PASS | No hand-written DTO. The quote client is already generated and committed; **no codegen against mbe-api is needed**, so the workflow rule about regenerating on an API change does not fire. Generated DTOs are mapped to `freezed` entities in `domain/` before reaching `presentation`, and errors go through the shared `AppError` types. |
| **IV. Deny-by-default RBAC** | PASS | `SystemObject.salesQuotes` (already declared, currently unused) gates the route and the actions; convert additionally requires `salesOrders/create`, mirroring the server. Actions are **hidden, not disabled**, per the house pattern. |
| **V. Material 3, white-labeled design system** | PASS | Composes existing themed components and reads spacing from the theme. One new status marker for `hasExpired`, built on the shared `StatusChip`, not a bespoke widget. No new hard-coded colour, size or formatting path. |
| **VI. Desktop/web-first, compact-ready** | PASS | The list is a filter row + list + pagination, built from the shared `CatalogFilterBar` / `DataTableView` / `fetchClampedPage` stack, with a search box and facets. The quote screen inherits the capture step's compact tier. The line-row column budget is explicitly re-derived for the warehouse-less variant rather than left to fall back (research R1). |
| **VII. Online-only, server-rendered documents** | PASS | No caching, no offline behaviour. No document output is added — printing is out of scope and has no endpoint (spec §Out of Scope). |
| **Quality gates** (unit / widget / integration) | PASS | All three planned: unit for the filter, the request shape, the DTO mapping and **each error-mapping shape**; widget for the list, the quote screen, the router group and three-way host isolation; one live flow for create → confirm → convert. |

**No violations. Complexity Tracking is therefore omitted.**

Two points deserve stating rather than a silent pass.

**Widening `Sale` touches the POS payment surface.** Ten of the eleven `balance` edits are in
`payment/`, which this feature never renders. That reads like collateral damage, and against
"surgical changes" it needs a justification, not a shrug. It is justified because the
alternative — keeping `balance` required and having the quote supply `total` or `'0'` — buys a
smaller diff by making a quote *look payable* to the one code path that must never accept one.
The edits are mechanical (one getter, ten call sites), and the assumption they encode is
asserted once with a comment instead of ten times anonymously. Research R2 records the
alternatives and why each was rejected.

**Editing shared capture files is required, not opportunistic.** `showWarehouse` and the three
un-forwarded `SaleTotalsBar`/line-row parameters are demanded by FR-014, FR-015 and FR-023;
none changes register-visible behaviour, and the blast radius is enumerated in research R1 and
pinned by SC-007 and the quickstart's regression section.

## Project Structure

### Documentation (this feature)

```text
specs/040-sales-quotes/
├── plan.md                              # This file
├── spec.md                              # Feature specification (amended 2026-09-20)
├── research.md                          # Phase 0 — R1-R8
├── data-model.md                        # Phase 1 — the widened entities
├── quickstart.md                        # Phase 1 — validation guide
├── contracts/
│   ├── quote-capture-host.md            # Phase 1 — the quote as a third capture host
│   └── sales-quote-repository.md        # Phase 1 — the domain interface + error mapping
├── checklists/requirements.md
└── tasks.md                             # Phase 2 — NOT created by /speckit-plan
```

### Source code (repository root)

```text
lib/
├── core/
│   ├── access/system_object.dart              # unchanged — salesQuotes(30) already present
│   └── navigation/nav_destinations.dart       # EDIT: NavBranch.salesQuotes = 21, + destination
├── app/router/app_router.dart                 # EDIT: shell branch, 2 top-level routes, 1 gate
├── l10n/app_en.arb, app_es.arb                # EDIT: ~35-45 keys
└── features/sales/
    ├── domain/
    │   ├── entities/
    │   │   ├── sale.dart                      # EDIT: 4 fields nullable, +hasExpired,
    │   │   │                                  #       +balanceOrZero, +fromQuoteResponse
    │   │   ├── sale_line.dart                 # EDIT: cost nullable, +priceAdjustment,
    │   │   │                                  #       +fromQuoteLineResponse
    │   │   └── sales_quote_summary.dart       # NEW: list row + SalesQuotePage
    │   └── repositories/
    │       └── sales_quote_repository.dart    # NEW: interface
    ├── data/
    │   └── sales_quote_repository_impl.dart   # NEW: impl + provider + _toQuoteError
    └── presentation/
        ├── sale_editing.dart                  # EDIT: extract TrackedEditing
        ├── quote_editing.dart                 # NEW: QuoteEditing mixin
        ├── sales_quote_write_scope.dart       # NEW: salesQuoteWritesScope constant
        ├── capture/
        │   ├── capture_step.dart              # EDIT: +showWarehouse, forward showAction/
        │   │                                  #       actionKey/showComment, gate :189-192
        │   ├── sale_line_row.dart             # EDIT: +showWarehouse
        │   ├── sale_line_card.dart            # EDIT: +showWarehouse
        │   └── sale_line_layout.dart          # EDIT: warehouse-less column budget
        ├── orders/order_header_panel.dart     # EDIT: null-handle promiseDate, priority
        ├── pos_workspace_screen.dart          # EDIT: null-handle pointSale (3 sites)
        ├── orders/foreign_order_guard.dart    # EDIT: balanceOrZero
        ├── payment/                           # EDIT: balanceOrZero (10 sites, 3 files)
        └── quotes/                            # NEW sub-feature
            ├── sales_quotes_list_screen.dart
            ├── sales_quotes_list_controller.dart
            ├── quote_screen.dart
            └── quote_editor_controller.dart

test/
├── unit/features/sales/                       # filter, request shape, mapping, error shapes
├── unit/app/router/app_router_test.dart       # EDIT: + the quotes group (incl. branch index)
├── widget/features/sales/
│   ├── pos_test_harness.dart                  # EDIT: +testQuote/testQuoteLine/pumpQuotesRouted
│   ├── sale_editor_isolation_test.dart        # EDIT: generalize to three hosts
│   └── sales_quotes_*_test.dart               # NEW
└── integration/sales_quotes_flow_test.dart    # NEW
```

**Structure Decision**: mirrors `presentation/orders/` exactly — a sub-feature folder for the
screens and controllers, the repository split across `domain/repositories` and `data`, entities
in `domain/entities`. The quote screens are a sibling of the order workspace, not a variant of
it: they share the capture step, not the host.

### Post-design constitution re-check

Re-evaluated after Phase 1. **Still no violations.** Two things the design settled that the
pre-Phase-0 check could only assume:

- **III holds more strongly than expected.** The generated quote client is already committed, so
  this feature adds no codegen step and no hand-written DTO. The one place a contract could have
  leaked is the error path, and `contracts/sales-quote-repository.md` §2 pins it: the quote
  repository carries its own 422 mapper rather than letting a plain-string `detail` be silently
  discarded by the shared interceptor.
- **VI's list rules are satisfied without a date facet.** The quote endpoint has no date range,
  and the constitution's rule is that a screen must ship *with* filtering, not with a specific
  facet — a search box plus status and customer facets meets it. The rule that a filter row must
  omit a control the endpoint cannot serve is what keeps the date chip off, rather than shipping
  one that silently does nothing.
