# Implementation Plan: Customer Discounts

**Branch**: `052-customer-discounts` | **Date**: 2026-10-24 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/052-customer-discounts/spec.md`

Roadmap: mictlanix/mbe-roadmap#16 · Also fixes mbe-ui#207

## Summary

The customer detail page gains a **Discounts** section: per-product discount overrides, listed by product code and shown as percentages. One dialog adds a discount (product picker plus percentage) or edits one (percentage only, with Remove inside). Each change saves on its own, separate from the customer's Save. The pattern is spec 050's supplier agreements.

Two related changes:
- **Stay after create.** After creating a customer, the page reopens it in edit mode so discounts can be added at once (FR-007a). This needs `CustomerFormController` keyed by customer id, which is also the fix for mbe-ui#207 (R8).
- **Sales need no change.** mbe-api #253 starts new order and quote lines at the customer's discount, and capture already leaves the line's discount blank. A regression test pins that (R10).

No backend change and no client regeneration are needed: mbe-api #251 and #253 are merged, and the generated client already has every operation.

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter 3.47.7 stable (unchanged)

**Primary Dependencies**: Riverpod 3 (`riverpod_annotation` / riverpod_generator 4), freezed 4, `go_router`, `data_table_2`, `decimal`, and the generated `mbe_api_client`. No new packages. T001 regenerates the OpenAPI client once as a drift check and expects no diff (contracts C7).

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter_test` + `mocktail` with `ProviderScope` overrides (the spec 050 agreements tests are the template).
- One live repository test in `test/integration/` that discovers its fixtures at runtime (R11).

**Target Platform**: Web/desktop first (the Expanded tier). On the compact tier the table drops the Code column into the Product cell (C3).

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:
- Opening a customer adds one read, the discounts list. A discount change re-fetches only that list.
- The product picker keeps the existing debounced search (20 results).

**Constraints**:
- Percentages render only through `formattersProvider` (§V guard). The spec was amended to the app's percent format (R3).
- Actions the user lacks rights for are hidden, never disabled (§IV).
- Spacing comes only from tokens. The l10n files are regenerated, not hand-edited.
- No change to `core/widgets/`, `AppError` or generated code.
- Format only the changed files.

**Scale/Scope**:

| | Files |
|---|---|
| **New (6 source files, plus tests)** | `entities/customer_discount.dart`, `customer_discounts_section.dart`, `customer_discounts_controller.dart`, `customer_discount_dialog.dart` + controller |
| **Edited (6 source files)** | `customer_repository.dart` + impl, `customer_form.dart`, `customer_form_controller.dart` (family key), `customer_detail_screen.dart`, `sales/presentation/customer_inline_create.dart` (reads the `null` key) |
| **Edited, l10n** | both `.arb` files (23 keys, C6) and the regenerated `app_localizations*.dart` |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

These verdicts are against **v1.14.0**.

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | Everything stays in `features/catalog/{domain,data,presentation}`. The one `sales/` touch is a provider-key update in `customer_inline_create.dart`. Presentation reaches the repository only through providers. |
| **II. Riverpod** | Pass | New `@riverpod` families: `CustomerDiscountsController(customerId)` and `CustomerDiscountDialogController(customerId, existing)`. `CustomerFormController` becomes a family (R8). Mutations invalidate the list family (R7). |
| **III. Contract-driven API** | Pass | Only generated methods and models are used, through a freezed `CustomerDiscount` mapping (C5, C7). No hand-written DTOs. **No mbe-api change**, so there is no issue to file. Errors map to the shared `AppError` types. A 409 is read from `ServerError.statusCode` (R6), as suppliers do. |
| **IV. Deny-by-default RBAC** | Pass | The rights matrix is in R9: Customers Read, Customers Update, and Products Read for the picker. These match the server's dependencies. The route is already gated. No new `SystemObject`. |
| **V. Material 3 / one formatting surface** | Pass | Percentages use `fmt.display.percent` (list) and `fmt.field.rate` / `parseRate` (dialog). There are no `NumberFormat` or `toStringAsFixed` calls in widgets. All strings are in `.arb` files. Uses `DataTableView`, `CatalogEntityPicker`, `ErrorBanner`, `buildCatalogRowActions` and `showRecordDeleteConfirmation`. |
| **VI. Record surface** | Pass | Customers are already a full detail screen, and a child collection keeps that surface. |
| **VI. Row and delete rules** | Pass | A row has a single Edit icon, and there is no row Delete: removing lives in the dialog behind a confirmation. Add is a section-level control, the same as agreements. A read-only view shows no mutation controls until Edit. Compact reflows (C3). |
| **VII. Online-only** | Pass | Nothing is cached. Every view reads from the server. |
| **Quality gates** | Pass | Unit, widget and live tests are listed in R11. The codegen drift check is T001. Every FR maps to at least one test (see tasks). |

**Post-design re-check** (after Phase 1): still passing. The design added no core-widget change, no `AppError` variant and no codegen. The family-key change is a correction that #207 already asked for, not a new pattern: suppliers did the same in 424c940.

## Project Structure

### Documentation (this feature)

```text
specs/052-customer-discounts/
├── spec.md              # /speckit-specify (+ plan-time amendments to FR-003, FR-005, edge case)
├── plan.md              # This file
├── research.md          # Phase 0 (R1–R11)
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/
│   └── ui-contracts.md  # Phase 1 (C1–C7)
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── features/catalog/
│   ├── domain/
│   │   ├── entities/customer_discount.dart              # NEW
│   │   └── repositories/customer_repository.dart        # + 4 discount methods
│   ├── data/
│   │   └── customer_repository_impl.dart                # + 4 methods, _setDiscount
│   └── presentation/
│       ├── customer_detail_screen.dart                  # + onCreated (C1)
│       ├── customer_form.dart                           # family key, onCreated, section (C2)
│       ├── customer_form_controller.dart                # build(int? customerId) (R8)
│       ├── customer_discounts_section.dart              # NEW (C3)
│       ├── customer_discounts_controller.dart           # NEW (R7)
│       ├── customer_discount_dialog.dart                # NEW (C4)
│       └── customer_discount_dialog_controller.dart     # NEW (data-model)
├── features/sales/presentation/customer_inline_create.dart  # provider key → (null)
└── l10n/app_en.arb, app_es.arb                          # + 23 keys (C6)

test/
├── unit/features/catalog/      # customer_repository_impl, customer_form_controller (extended);
│                               # customer_discounts_controller, customer_discount_dialog_controller (new)
├── widget/features/catalog/    # customer_detail_screen, customer_form (extended);
│                               # customer_discounts_section, customer_discount_dialog (new)
├── widget/features/sales/      # capture regression: addLine sends no discountRate (R10)
└── integration/customer_discounts_live_test.dart   # NEW
```

**Structure Decision**: a single Flutter project with feature-first layering. All the work stays in `features/catalog`, beside the supplier agreements code it mirrors.

## Complexity Tracking

There are no violations to justify.
