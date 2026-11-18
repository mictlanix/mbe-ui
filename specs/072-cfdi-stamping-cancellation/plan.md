# Implementation Plan: CFDI Stamping, Refresh and Cancellation

**Branch**: `072-cfdi-stamping-cancellation` | **Date**: 2026-11-17 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/072-cfdi-stamping-cancellation/spec.md`. Wireframes are in [wireframes.md](./wireframes.md).

## Summary

This spec extends spec 066's `lib/features/invoicing` with mbe-api spec 039's stamp, cancel
and refresh. It covers roadmap#52 and the mbe-ui#274 handoff. The work, in order:

1. **States.** The domain status grows from four values to six. The mapper no longer falls
   back to draft; a test checks that every generated enum constant is mapped (R1). This
   fixes a bug that is live on dev today, where a document in the stamping or
   cancellation-pending state opens as an editable draft.
2. **Detail changes.** The detail gains the stamp facts and the simulated badge, state
   banners, a cancellation-history section, and three actions: Timbrar, Cancelar ante el
   SAT, and Consultar estado. Each action is present only in the state it applies to and
   with Update on 23 (R2).
3. **Two dialogs.** A stamp confirmation, and a cancel dialog with SAT reasons 01–04. For
   01 the cancel dialog uses a substitute picker extracted from spec 066's add-relation
   dialog (R7).
4. **Error codes.** Twelve new codes are localized, and three reused ones are reworded so
   they read correctly in any action (R9).

No new route, no nav change, no new package and no client regeneration: the client at
`f4271b49` already has spec 039.

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter 3.47.7 stable (unchanged)

**Primary Dependencies**:
- Riverpod 3 (riverpod_generator), freezed, `go_router` and `decimal`.
- The generated `mbe_api_client` (`FiscalDocumentsApi.stampFiscalDocument`, `cancelFiscalDocument`, `refreshFiscalDocument`). `PacSimulatorApi` is used only by the live test.
- No new packages.

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter_test` + `mocktail` with `ProviderScope` overrides and spec 066's `InvoiceHarness`.
- The live repository-level test `test/integration/fiscal_documents_live_test.dart` is extended. It runs behind `MBE_WRITE=true` on dev only, and the user is asked first (R13).

**Target Platform**: web and desktop first, with a compact tier required (§VI)

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:

| Action | Requests |
|---|---|
| Detail | 1 (as 066), +1 employee name per distinct requester (cached family) |
| Stamp / cancel / refresh | 1 write, then the detail refetches (+1) |
| Substitute picker | 1 list per page or search |

**Constraints**:
- Use `formattersProvider` for dates, and tokens for spacing and colours (R10).
- Every string goes in both `.arb` files.
- Format only the changed files.
- Status, outcome and reason labels come from l10n, never from `enum.name`.
- The PAC text is shown only from `pac.rejected` params and history fields (R9).

**Scale/Scope**:

| | Files |
|---|---|
| **New source (≈5)** | `features/invoicing/domain/entities/{fiscal_stamp, fiscal_cancellation, sat_cancellation_reason}.dart` (+ generated parts), `presentation/{cancel_fiscal_document_dialog, fiscal_document_candidate_picker}.dart` |
| **Edited source (≈12)** | `domain/entities/fiscal_document.dart`; `domain/repositories/fiscal_document_repository.dart`; `data/fiscal_document_repository_impl.dart`; `presentation/{fiscal_document_actions, fiscal_document_detail_screen, fiscal_document_status_chip, fiscal_documents_filter, fiscal_documents_list_screen, add_relation_dialog, invoice_action_dialogs, fiscal_document_refusal}.dart`; `core/errors/localize_problem.dart`; both `.arb` files; `specs/058-localized-api-errors/contracts/code-scope.tsv` (+12 `IN`) |
| **New tests (≈3)** | `cancel_fiscal_document_dialog_test`, `fiscal_document_candidate_picker_test`, a `localize_problem` group test for the param cases |
| **Edited tests (≈9)** | `fiscal_document_repository_impl_test`, `fiscal_document_actions_test`, `fiscal_documents_filter_test`, `fiscal_document_detail_screen_test`, `fiscal_document_status_chip_test`, `invoice_action_dialogs_test`, `fiscal_document_fixtures`, `catalog_coverage_test` (165 → 177), `problem_fixtures`; live test extended |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

These verdicts are against **v1.15.0**.

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | Everything stays in `features/invoicing`. Presentation reaches data only through the repository and `FiscalDocumentActions`. The candidate picker is extracted feature-locally (R7) rather than duplicated. The employee name comes through catalog's existing `employeeDisplayNameProvider`, as 066 already does for customers and facilities. |
| **II. Riverpod** | Pass | Writes go through the existing keep-alive `FiscalDocumentActions` notifier. The detail stays a family keyed by id and is invalidated after every write (R3). Dialogs hold local form state. |
| **III. Contract-driven API** | Pass | Only generated operations are used, mapped to freezed entities. **API error text**: all 12 codes the three new endpoints can return are localized and flipped to `IN`, and 3 reused texts are reworded (R9). **The PAC text** is a `pac.rejected` param (`pac_message`) and history data, not `detail`, so showing it verbatim is consistent with "text from `code` + `params`". The `issue_date_out_of_range` hint on stamp branches on `code`, which is allowed. **Upstream**: nothing needed. `requested_by`'s name resolves client-side with the existing fallback (R8). |
| **IV. Deny-by-default RBAC** | Pass | Stamp, cancel and refresh each require 23 update, as the server does (spec 039 FR-028), and are absent otherwise. The banner drops its "you can…" advice for users without the right (C16). The substitute picker uses the list, which 23 read already covers. The employee name fails over to `#id` without Employees read. |
| **V. Material 3 / design system** | Pass | Only shared components are used: `StatusChip`, `CompactField`, `ResponsiveDialog`, `FormErrorBanner`, `DataTableView` and `CatalogSearchBar` inside the picker, plus 066's `FiscalDocumentRefusal`. The two new state colour pairs and the badge come from `ColorScheme` (R10); no hex. **Largest text level**: quickstart step 14. |
| **VI. List and record-surface rules** | Pass | **List**: unchanged structure; one facet gains values. **Surface**: the existing full detail screen. `AppBar.actions` stays empty and every action is in the body's action row (C18). History rows have no row actions. **Delete**: none. Cancellation is a lifecycle action, not a delete. |
| **VII. Online-only, server-rendered documents** | Pass | The PDF and XML are still the server's. Nothing is cached, and every action re-reads the document. |
| **Quality gates** | Pass | Unit, widget and live tests are listed in R13. `flutter analyze` must be clean. Coverage is enforced by `catalog_coverage_test`. |

**Post-design re-check** (after Phase 1): unchanged.
- **Shared touches**: only `core/errors/localize_problem.dart` (new arms and a list-param formatter) and the spec 058 code-scope TSV.
- The picker extraction is internal to the feature.
- No deviation needs Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/072-cfdi-stamping-cancellation/
├── spec.md
├── wireframes.md        # drawn before planning; its open questions are settled in research.md
├── plan.md              # this file
├── research.md          # R1–R13
├── data-model.md
├── quickstart.md
├── contracts/
│   └── ui-contracts.md  # C15–C24 (continuing 066's C1–C14)
├── checklists/
│   └── requirements.md
└── tasks.md             # /speckit-tasks
```

### Source Code (repository root)

```text
lib/features/invoicing/
├── domain/
│   ├── entities/
│   │   ├── fiscal_document.dart          # 6 states; stamp, stampingSince, substitution, cancellations; canStamp/canCancel/canRefresh
│   │   ├── fiscal_stamp.dart             # new
│   │   ├── fiscal_cancellation.dart      # new (+ CancellationOutcome)
│   │   └── sat_cancellation_reason.dart  # new
│   └── repositories/fiscal_document_repository.dart   # + stamp, cancel, refresh
├── data/fiscal_document_repository_impl.dart          # exhaustive status mappers (R1), new mappings
└── presentation/
    ├── fiscal_document_actions.dart          # + stamp, cancel, refresh (returns status)
    ├── fiscal_document_detail_screen.dart    # banners, stamp facts, badge, history, action row
    ├── fiscal_document_status_chip.dart      # 2 new colour pairs
    ├── fiscal_documents_filter.dart          # 6 states
    ├── fiscal_documents_list_screen.dart     # state picker lists 6
    ├── invoice_action_dialogs.dart           # + showStampFiscalDocumentDialog
    ├── cancel_fiscal_document_dialog.dart    # new
    ├── fiscal_document_candidate_picker.dart # new, extracted from add_relation_dialog
    ├── add_relation_dialog.dart              # re-hosts the picker
    └── fiscal_document_refusal.dart          # info variant + action-context hint

lib/core/errors/localize_problem.dart          # 12 arms, list-param join, 3 rewordings via arb
lib/l10n/app_{es,en}.arb
specs/058-localized-api-errors/contracts/code-scope.tsv

test/unit/features/invoicing/…   test/widget/features/invoicing/…
test/unit/core/errors/…          test/integration/fiscal_documents_live_test.dart
```

**Structure Decision**: Extend spec 066's `features/invoicing` module in place. This adds
no new feature module, route or navigation entry.

## Complexity Tracking

No constitution violations to justify.
