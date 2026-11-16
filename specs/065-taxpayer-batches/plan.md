# Implementation Plan: Taxpayer Batches (Folio Series)

**Branch**: `065-taxpayer-batches` | **Date**: 2026-11-15 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/065-taxpayer-batches/spec.md` (mictlanix/mbe-roadmap#45)

## Summary

Let administrators maintain an issuer's folio series from the taxpayer issuer detail screen, using the four batch endpoints mbe-roadmap#44 already shipped.

- **Where.** A new "Series" section under Certificados on `TaxpayerIssuerDetailScreen`, for saved issuers only. Rows are sorted by document type, then series, and show a lock when the series is in use.
- **How.** Each series opens in a dialog:
  - A row tap opens it read-only, with an in-place Editar toggle.
  - The Edit icon opens it editable.
  - "Nuevo" creates a series.
  - Delete lives inside the dialog through the shared `RecordFormActions`.
  - An in-use series has its series and type locked up front, and only the template stays editable.
  - Bank accounts are an ordered, repeatable group in the template.
- **Domain.** A new `FiscalDocumentKind` enum maps the type codes 0/1/2/3/100/101/200 to localized labels. An unknown code still renders.
- **Error codes.** `taxpayer_batch.in_use` and `taxpayer_batch_series_blank` get es/en messages, and `taxpayer_batch` gets a resource noun, as constitution §III requires.

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter stable (unchanged)

**Primary Dependencies**:
- Riverpod 3 (riverpod_generator), freezed, `go_router` and the generated `mbe_api_client`.
- No new packages and no codegen re-run: all four batch methods are already generated on `TaxpayerIssuersApi`.

**Storage**: N/A (online-only)

**Testing**:
- `flutter_test` + `mocktail` with `ProviderScope` overrides.
- Existing templates: `taxpayer_certificates_section_test.dart`, the customer discount dialog and controller tests, and the `localize_problem` group tests and `catalog_coverage_test`.
- A live macOS integration test following the spec 052 quickstart.

**Target Platform**: web and desktop first, with a compact tier required (§VI)

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:

| Action | Requests |
|---|---|
| Open the issuer | +1 (list series) |
| Save or delete a series | 1, then 1 to reload the list |

**Constraints**:
- Spacing comes from tokens.
- Every string goes in both `.arb` files.
- Actions are absent, never disabled, without the right.
- Format only the changed files (memory: no repo-wide `dart format`).

**Scale/Scope**:

| | Files |
|---|---|
| **New source (≈8)** | `domain/entities/fiscal_document_kind.dart`, `domain/entities/taxpayer_batch.dart` (+ `TaxpayerBatchTemplate`, `TaxpayerBatchAccount`), `domain/repositories/taxpayer_batch_repository.dart`, `data/taxpayer_batch_repository_impl.dart`, `presentation/taxpayer_batches_controller.dart`, `presentation/taxpayer_batches_section.dart`, `presentation/taxpayer_batch_dialog_controller.dart`, `presentation/taxpayer_batch_dialog.dart` (all under `lib/features/catalog/`) |
| **Edited source (≈4)** | `taxpayer_issuer_detail_screen.dart` (host the section), `core/errors/localize_problem.dart` (code, validation type, noun and gender), `l10n/app_es.arb`, `l10n/app_en.arb` |
| **New tests (≈6)** | unit `fiscal_document_kind_test`, `taxpayer_batch_test` (mapping), `taxpayer_batch_repository_impl_test`, `taxpayer_batch_dialog_controller_test`; widget `taxpayer_batches_section_test`, `taxpayer_batch_dialog_test`; live `integration_test/taxpayer_batches_quickstart_test.dart` |
| **Edited tests (≈4)** | `catalog_coverage_test` (113→114), `problem_fixtures.dart`, a `localize_problem` group test, `localize_validation_type_test` |
| **Edited docs (1)** | `specs/058-localized-api-errors/contracts/code-scope.tsv` (2 rows OUT→IN, 2 resource rows added) |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Result |
|---|---|---|
| **I. Feature-first layers** | Entities and the repository interface are in `catalog/domain`, the impl in `catalog/data`, and the section, dialog and controllers in `catalog/presentation`, next to Certificates. Generated types never pass the repository | PASS |
| **II. Riverpod** | `taxpayerBatchRepositoryProvider`, plus a family `TaxpayerBatchesController(rfc)` and a family `TaxpayerBatchDialogController(rfc, existing)`. Tests override the repository | PASS |
| **III. Contract-driven API** | Generated methods only, no hand DTOs, and errors go through the existing `_toAppError`. **API error text:** every code the four endpoints return is covered; two are flipped to IN and a resource noun is added (research R9, contracts/consumed-endpoints.md). Recognition (in-use, duplicate, issuer gone) is keyed on `code`. No mbe-api change is needed (R12) | PASS |
| **IV. Deny-by-default RBAC** | Taxpayers (24): the route is already gated on read; create gates "Nuevo", update gates the Edit icon and the Editar toggle, and delete gates Eliminar. All of these are also behind the parent's `readOnly` (research R3). Hidden, not disabled | PASS |
| **V. Material 3** | `ResponsiveDialog`, `ResponsiveFormGrid`, `RecordFormActions`, `DataTableView`, `buildCatalogRowActions`, `FormErrorBanner` and `ListFailedView`. No new shared widgets | PASS |
| **VI. Layout and actions** | The issuer stays a full screen (it owns child collections). A series has 6 own fields, and its bank accounts are a repeating group inside the template value rather than a child collection, so a dialog is right (research R1). A row tap opens read-only "Ver serie" with an in-place Editar; the Edit icon is the only row action; Delete lives on the record surface with confirmation; the section is divider-delimited; the dialog is fullscreen on compact and drops the Plantilla column | PASS |
| **VII. Server-rendered documents** | Not touched. The template only feeds mbe-api's PDF renderer | PASS |
| **Workflow gates** | Consumed endpoints and their error codes are listed (contracts/consumed-endpoints.md). No codegen re-run needed. RBAC object documented | PASS |

**Post-design re-check (after Phase 1):** still PASS.

- **Interpretation recorded.** Bank accounts are not a §VI "child collection" (R1). If a reviewer reads them as one, the series would need a full screen with its own URL, and that would be a spec-level change.
- **Spec kept as written.** The spec's ordering assumption (type, then series) differs from the server's order (series only), so it is applied client-side (R5).

## Project Structure

### Documentation (this feature)

```text
specs/065-taxpayer-batches/
├── plan.md              # This file
├── research.md          # Phase 0 (R1–R13)
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/
│   ├── consumed-endpoints.md
│   └── ui-contract.md
├── checklists/requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── core/errors/localize_problem.dart                 # + taxpayer_batch.in_use, series_blank, noun
├── features/catalog/
│   ├── domain/entities/fiscal_document_kind.dart     # NEW
│   ├── domain/entities/taxpayer_batch.dart           # NEW (+ template, account)
│   ├── domain/repositories/taxpayer_batch_repository.dart   # NEW
│   ├── data/taxpayer_batch_repository_impl.dart      # NEW
│   └── presentation/
│       ├── taxpayer_batches_controller.dart          # NEW: family(rfc), sorted list
│       ├── taxpayer_batches_section.dart             # NEW
│       ├── taxpayer_batch_dialog_controller.dart     # NEW: draft, validate, save, delete
│       ├── taxpayer_batch_dialog.dart                # NEW
│       └── taxpayer_issuer_detail_screen.dart        # + section after Certificates
└── l10n/app_{es,en}.arb                              # + ~45 keys

test/
├── unit/features/catalog/                            # kind, entity, repository, dialog controller
├── unit/core/errors/                                 # coverage 114, fixtures, messages
└── widget/features/catalog/                          # section, dialog

integration_test/taxpayer_batches_quickstart_test.dart
```

**Structure Decision**: Flutter feature-first layout (constitution §I). Series are a per-issuer child collection, so they live in `features/catalog` beside the existing taxpayer issuer and certificate code, and mirror the Certificates section's shape and the customer discount dialog's controller pattern.

## Complexity Tracking

No constitution violations to justify.
