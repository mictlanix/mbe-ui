# Implementation Plan: Invoice List, View, PDF and Editor

**Branch**: `066-invoice-list-editor` | **Date**: 2026-11-16 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/066-invoice-list-editor/spec.md`

Roadmap: Closes mictlanix/mbe-roadmap#48 and mictlanix/mbe-roadmap#49.

Upstream: none. Every endpoint used already exists in the generated client, and no mbe-api change is needed. Stamping (roadmap#46) is a known limit, not a dependency: invoices made here stop at sealed.

## Summary

The back office gets a "Facturación" group with **Facturas**: a list of every fiscal document and a full detail screen per document.
- **Any document**: issued documents offer the server's PDF (preview, print, save) and their stored XML.
- **Invoice drafts**: can be created for a customer's RFC, filled from completed sales orders or by hand, edited (lines, header, relations 04/07), and confirmed to a sealed invoice. A sealed invoice can be reopened.

**Technical approach:**
- **Data**: a new `features/invoicing` module with a `FiscalDocumentRepository` over the generated `FiscalDocumentsApi`, freezed entities, and wire-trap mapping (R3).
- **List**: copies the delivery-orders list, with a URL-backed filter and drawer facets for status, type, issuer and date (R4).
- **Detail**: one screen. It is editable in place only for an invoice draft held by a 23-update user, and read-only otherwise (R5).
- **Writes**: a keep-alive `FiscalDocumentActions` that returns `AppError?` and invalidates (R6). Edits go through dialogs (R7, R8).
- **PDF**: a new `DocumentKind.fiscalDocument` on the spec 044 document module (R9). **XML**: a new `core/files` saver over `file_picker` (R10).
- **Draft totals**: the server returns no total for a draft, so a pure domain mirror of mbe-api's `line_amounts` computes them. The live test checks it against the server after sealing (R11).
- **Errors**: 29 codes and 2 validation types newly localized, plus 2 resource nouns (R13).
- **Bug fix**: spec 065's `FiscalDocumentKind` has the right codes but the wrong names (1/2/3, and 101 and 200 swapped). It is renamed here, because this feature shows those names (R2).

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter stable (unchanged)

**Primary Dependencies**:
- Riverpod 3 (riverpod_generator), freezed, `go_router`, `data_table_2`, `decimal`, `printing` (via `core/documents`), `file_picker` (already a dependency, now also used for saving), and the generated `mbe_api_client`.
- No new packages, and no client regeneration.

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter_test` + `mocktail` with `ProviderScope` overrides.
- Templates: `delivery_order_admin_repository_impl_test.dart`, `delivery_orders_filter_test.dart`, `delivery_orders_list_screen_test.dart`, `delivery_order_detail_screen_test.dart`, `delivery_order_actions_test.dart`, `add_line_dialog_test.dart`, `test/unit/core/documents/*`.
- One live test, `integration_test/fiscal_documents_quickstart_test.dart` (R14).

**Target Platform**: web and desktop first, with a compact tier required (§VI)

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:

| Action | Requests |
|---|---|
| List page | 1, plus cached per-customer name lookups on the detail only |
| Detail | 1 (document), +1 customer name |
| Any edit | 1 write, then the document refetches (+1) |
| Add order | Picker: 1 per page; add: 1 write + refetch |
| Nueva factura | 1 customer get (for taxpayers), 1 create |
| PDF / XML | 1 each |

**Constraints**:
- Use `Decimal` and `formattersProvider` only.
- Spacing comes from tokens.
- Every string goes in both `.arb` files.
- Format only the changed files.
- Status and type names come from l10n, never from `enum.name`.
- Draft totals use the R11 mirror only. No other client arithmetic on amounts.

**Scale/Scope**:

| | Files |
|---|---|
| **New source (≈22)** | `features/invoicing/domain/entities/{fiscal_document, invoice_amounts}.dart`, `domain/repositories/fiscal_document_repository.dart`, `data/fiscal_document_repository_impl.dart`; `presentation/{fiscal_documents_list_screen, fiscal_documents_filter, fiscal_documents_list_controller, fiscal_document_detail_screen, fiscal_document_detail_controller, fiscal_document_actions, fiscal_document_status_chip, fiscal_document_labels, new_invoice_dialog, invoice_header_dialog, invoice_line_dialog, add_sales_order_dialog, add_product_dialog, add_relation_dialog, invoice_action_dialogs, invoice_totals}.dart`; `core/files/{file_saver, file_saver_impl}.dart`; `features/invoicing/domain/xml_filename.dart`; plus generated parts |
| **New tests (≈20)** | listed in research R14 |
| **Edited source (≈12)** | `features/catalog/domain/entities/fiscal_document_kind.dart` + `presentation/fiscal_document_kind_label.dart` + `data/taxpayer_batch_repository_impl.dart` (R2 rename); `features/catalog/domain/repositories/sat_catalog_repository.dart` + `data/sat_catalog_repository_impl.dart` (`listCfdiUsages`); `core/documents/domain/document_kind.dart` + `data/document_source_impl.dart` (R9); `core/navigation/nav_destinations.dart`; `app/router/app_router.dart`; `core/errors/localize_problem.dart`; both `.arb` files; `specs/058-localized-api-errors/contracts/code-scope.tsv` (29 + 2 rows to `IN`) |
| **Edited tests (≈6)** | 065's Series and batch tests (renamed kinds), `catalog_coverage_test` (114 → 143), `problem_fixtures`, `resource_noun_test`, `document_source_impl_test`, `sat_catalog_repository_impl_test` |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

These verdicts are against **v1.15.0**.

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | It is the first `features/invoicing` module, named in §I. Presentation reaches data only through repository providers. Shared things stay shared: `FiscalDocumentKind` (catalog kernel), the SAT catalog repository, `core/documents`, and the new `core/files`. The totals mirror is a pure domain function. |
| **II. Riverpod** | Pass | The list is an `AsyncNotifier` family keyed by filter, and the detail is a family keyed by id. Writes go through one keep-alive notifier. The filter is URL state, and dialogs hold local form state. `fileSaverProvider` and `documentSourceProvider` are overridable in tests. |
| **III. Contract-driven API** | Pass | Only generated operations are used, mapped to freezed entities. **API error text**: R13 lists every code the newly called endpoints can return. 29 codes and 2 validation types are added in both locales and flipped to `IN`; 4 were already localized; receipt and credit-note codes stay `OUT`, because their endpoints aren't called. **Upstream**: nothing needed. The draft-totals mirror (R11) reproduces a documented, SAT-fixed formula rather than inventing one, and the live test checks it against the server. |
| **IV. Deny-by-default RBAC** | Pass | The route and nav are gated on 23 read. Create is 23 create; every edit, confirm and reopen is 23 update. A manual line needs 56 create (the server checks only 56 there), and the store field needs 103 update. Pickers need SalesOrders, Customers and Taxpayers read. The route, nav entry and each control document the codes (R12, C9). A missing right means the control is absent. |
| **V. Material 3 / design system** | Pass | Only shared components: `CatalogFilterBar`, `CatalogSearchBar`, `showCatalogFilterSheet`, `DataTableView`, `CatalogPagination`, `CatalogListStateView`, `StatusChip`, `FactStripRow`, `CompactField`, `ResponsiveFormGrid`, `ResponsiveDialog`, `ErrorBanner`/`FormErrorBanner`, `CatalogEntityPicker`, `DateRangeFilterChip`, `buildCatalogRowActions`, the document preview dialog. Amounts and dates go through `formattersProvider`. **Largest text level**: checked in quickstart step 14. |
| **VI. List and record-surface rules** | Pass (reading recorded) | **List**: a filter row (search, facets button, Nueva factura), a table, pagination; facets only in the drawer. **Surface**: a full detail screen, since it meets all three criteria (child collections, > 15 fields, per-record URL). **AppBar actions**: empty. **No row Edit icon, no View toggle**: the §VI document reading of specs 056, 057, 060 and 061 applies. A fiscal document has a lifecycle and can only be edited as a draft, so it opens editable as a draft (with 23 update) and read-only otherwise. Line and relation rows use `buildCatalogRowActions`, with ✎ and 🗑 within the two-icon limit. **Delete**: none. A draft is not deletable through the API; cancellation is roadmap#52. |
| **VII. Online-only, server-rendered documents** | Pass | The PDF is the server's, shown through `printing` (§VII). The XML is the server's stored bytes, saved untouched. Nothing is persisted or cached. |
| **Quality gates** | Pass | Unit, widget and live tests are listed in R14. `flutter analyze` must be clean, and catalog coverage is enforced by `catalog_coverage_test.dart`. |

**Post-design re-check** (after Phase 1): unchanged.
- **Shared touches**:
  - `core/documents` gets one `DocumentKind` value and a switch arm.
  - `core/files` is new: a small saver interface plus an implementation.
  - The `SatCatalogRepository` gains a method.
  - `FiscalDocumentKind` is renamed (a bug fix with visible effect on spec 065's Series section).
- No deviation needs Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/066-invoice-list-editor/
├── spec.md                # /speckit-specify (2026-11-16), amended in plan (FR-014, FR-015, FR-022, edge cases)
├── plan.md                # This file
├── research.md            # Phase 0 (R1–R14)
├── data-model.md          # Phase 1
├── quickstart.md          # Phase 1
├── contracts/
│   └── ui-contracts.md    # Phase 1 (C1–C14)
├── checklists/
│   └── requirements.md
└── tasks.md               # /speckit-tasks (not yet)
```

### Source Code (repository root)

```text
lib/features/invoicing/                                  # new module (R1)
├── domain/
│   ├── entities/fiscal_document.dart                    # summary, document, line, relation, enums
│   ├── entities/invoice_amounts.dart                    # lineAmounts / invoiceAmounts mirror (R11)
│   ├── xml_filename.dart                                # {RFC}-{series}{serial:000000}.xml (R10)
│   └── repositories/fiscal_document_repository.dart
├── data/
│   └── fiscal_document_repository_impl.dart             # wire traps (R3)
└── presentation/
    ├── fiscal_documents_list_screen.dart                # C2
    ├── fiscal_documents_filter.dart                     # data-model §6, C3
    ├── fiscal_documents_list_controller.dart
    ├── fiscal_document_detail_screen.dart               # C5
    ├── fiscal_document_detail_controller.dart
    ├── fiscal_document_actions.dart                     # writes + invalidations (R6)
    ├── fiscal_document_status_chip.dart                 # C4
    ├── fiscal_document_labels.dart                      # terms, tax rate, relation type labels
    ├── invoice_totals.dart                              # totals block (T019)
    ├── new_invoice_dialog.dart                          # C6
    ├── invoice_header_dialog.dart                       # C7
    ├── invoice_line_dialog.dart                         # C8
    ├── add_sales_order_dialog.dart                      # C10
    ├── add_product_dialog.dart                          # C11
    ├── add_relation_dialog.dart                         # C12
    └── invoice_action_dialogs.dart                      # confirm, reopen, remove line/relation (C8, C12, C13)
lib/core/files/{file_saver.dart, file_saver_impl.dart}   # new (R10)
lib/core/documents/domain/document_kind.dart             # + fiscalDocument (R9)
lib/core/documents/data/document_source_impl.dart        # + arm (R9)
lib/features/catalog/domain/entities/fiscal_document_kind.dart      # rename (R2)
lib/features/catalog/presentation/fiscal_document_kind_label.dart   # rename (R2)
lib/features/catalog/data/taxpayer_batch_repository_impl.dart       # rename (R2)
lib/features/catalog/{domain/repositories,data}/sat_catalog_repository*.dart  # listCfdiUsages (R8)
lib/core/navigation/nav_destinations.dart                # Facturación group, NavBranch 29 (C1)
lib/app/router/app_router.dart                           # branch, detail route, gate (C1)
lib/core/errors/localize_problem.dart                    # 29 codes, 2 validation types, 2 nouns (R13)
lib/l10n/app_{es,en}.arb
specs/058-localized-api-errors/contracts/code-scope.tsv
test/unit/features/invoicing/…, test/widget/features/invoicing/…, test/unit/core/files/…,
integration_test/fiscal_documents_quickstart_test.dart
```

**Structure Decision**: a single Flutter app. Fiscal documents get their own `features/invoicing` module, as §I anticipates. It reuses the catalog kernel for document kinds, issuers, series and SAT catalogs, and `core/documents` for the PDF.

## Dependencies and risks

- **Nothing new reaches "issued" (roadmap#46)**: PDF and XML can only be exercised on legacy-issued documents until stamping ships. The sealed banner says so on screen.
- **No remaining-to-invoice figure**: the order picker lists fully invoiced orders, and the server refuses them with a localized message (R7). A server "invoiceable" filter would be a nice-to-have, not filed.
- **Totals mirror drift**: if mbe-api changes `line_amounts`, the draft estimate drifts. Sealed and issued documents always show the server's total, and the live test (step 9) catches drift on the next run.
- **Sealing in the live test depends on tenant certificates**: the test skips with a reason on `no_valid_certificate` rather than failing.
- **Live writes consume a folio** (quickstart). Run them only on the dev tenant.
- **Visible change to spec 065**: the Series section's type names change (R2). It is a correction, and it is called out in the PR.
- **`issued` write round trip**: wall-clock time without an offset. It is checked live (quickstart step 6) before relying on it.

## Complexity Tracking

No constitution violations need justification. §VI's document reading (no row Edit icon, no View toggle for a lifecycle document editable only as a draft) is relied on here as in specs 056, 057, 060 and 061. Stating it as a criterion in §VI remains a separate `/speckit-constitution` change (061 analysis D3).
