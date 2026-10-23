# Implementation Plan: Supplier Sub-Panels

**Branch**: `050-supplier-sub-panels` | **Date**: 2026-10-22 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/050-supplier-sub-panels/spec.md`, with [wireframes.md](./wireframes.md)

Roadmap: mictlanix/mbe-roadmap#14

## Summary

Suppliers move from the side panel to a full detail screen, the same way Customers did in spec 046. The supplier form gains four sections.

| Section | How it works | What it reuses or adds |
|---|---|---|
| Addresses, Contacts | Link and unlink, kept in the form state and saved as replace-all id lists on Save | The existing `LinkedRecordsSection<T>` plus the existing inline-create dialogs |
| Bank accounts | The same as above | New: a `BankAccount` entity, a repository and an inline-create dialog |
| Agreements | A child table backed by its own provider. One dialog adds or edits and takes effect at once; delete lives inside the dialog | The certificates child-table pattern |

Other behaviour:
- After a **create**, the screen replaces itself with the saved supplier in edit mode, so agreements can be added straight away.
- A 409 on save shows one combined message. A 409 on delete shows a message that names the links and agreements.

No backend change and no client regeneration are needed: mbe-api #251 and #252 are live, and the generated client already has every operation.

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter 3.47.7 stable (unchanged)

**Primary Dependencies**: Riverpod 3 (`riverpod_annotation` / riverpod_generator 4), freezed 4, `go_router`, `data_table_2`, and the generated `mbe_api_client`. No new packages. The OpenAPI client is not expected to change (contracts C8). Because mbe-api #252–#254 merged the same day as the last regeneration, T001 regenerates it once as a drift check and expects no diff, per the quality gate on endpoint changes.

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter_test` + `mocktail`, with `ProviderScope` overrides (the `customer_form_test.dart` pattern).
- One new live repository-level test in `test/integration/`, which discovers its fixtures at runtime (research R13).

**Target Platform**: Web/desktop first (the Expanded tier). Compact reflows to one column, and the agreements table drops Notes there.

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:
- Opening a supplier makes two reads: the detail, which carries the links, and the agreements list.
- An agreement change re-fetches only the agreements list.
- Pickers keep the existing debounced search.

**Constraints**:
- §VI v1.14.0 requires the full screen (R1). The amendment merged in #205 on 2026-10-22.
- Spacing comes only from tokens. Actions the user lacks rights for are hidden, never disabled (§IV).
- The l10n files are regenerated, not hand-edited.
- No change to `LinkedRecordsSection`, `DataTableView` or `AppError`.
- *Added during implementation:* two additive `core/widgets/` changes, both made so that existing code could be reused instead of copied.
  - `buildCatalogRowActions` gains an optional `editKey`, so agreement rows can be keyed for tests.
  - The delete-confirmation dialog inside `RecordFormActions` is extracted unchanged into a public `showRecordDeleteConfirmation`, so the agreement dialog's Delete reuses it.
  - Existing callers are unaffected.

**Scale/Scope**:

| | Files |
|---|---|
| **New (11 source files, plus tests)** | `supplier_detail_screen.dart`, `supplier_agreements_section.dart`, `supplier_agreements_controller.dart`, `supplier_agreement_dialog.dart` + controller, `bank_account_inline_create.dart` + controller, `entities/bank_account.dart`, `entities/supplier_agreement.dart`, `bank_account_repository.dart` + impl |
| **Edited (7 source files)** | `supplier.dart` (entity), `supplier_repository.dart` + impl, `supplier_form.dart`, `supplier_form_controller.dart`, `suppliers_list_screen.dart`, `app_router.dart` |
| **Edited, l10n** | both `.arb` files (about 30 keys) and the regenerated `app_localizations*.dart` |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

These verdicts are against **v1.14.0**, merged to `main` in #205 on 2026-10-22.

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | Everything stays in `features/catalog/{domain,data,presentation}`. `LinkedRecordsSection` stays feature-local, because its second consumer is in the same feature (R11). Presentation reaches repositories only through providers. |
| **II. Riverpod** | Pass | `SupplierFormState` is extended (freezed `Notifier`). The new `@riverpod` controllers are the agreements family, the agreement dialog and the bank-account inline create. Mutations invalidate the agreements family (R4, R8). |
| **III. Contract-driven API** | Pass | Only generated methods and models are used (C8). There are no hand-written DTOs and no edits to generated files. **No mbe-api change**, so there is no issue to file. Conflicts are read from the status code, because the server's 409 body is generic; that limitation is recorded in R7 and is owned by mbe-api#147 / UI #148. |
| **IV. Deny-by-default RBAC** | Pass | The rights matrix is in R9. It covers `suppliers` (3) R/C/U/D, read and create on `addresses` (11), `contacts` (12) and `bankAccounts` (13), and agreements under `suppliers` Update, as the server enforces. The route is covered by the existing `PrivilegeGate`. No new `SystemObject`. |
| **V. Material 3 design system** | Pass | Uses `Dialog`, `DataTableView`, `ListTile`, `CatalogEntityPicker`, `ErrorBanner`, `RecordFormActions`, `RecordDeleteConfirmation` and `CatalogAction.edit`. All strings are in `.arb` files. Dates use `fmt.display.date`. |
| **VI. Desktop/web-first layout** | **Pass** | Suppliers gains linked-record sections, so the record-surface rule requires a full detail screen. (Before v1.14.0 this contradicted §VI\'s panel list; #205 resolved it.) |
| **VI.** Other rules | Pass | Row click opens the read-only view, with an Edit toggle. Delete lives in `RecordFormActions`. The `AppBar` has no actions. Each agreement row has a single Edit icon, with delete inside its dialog (Clarifications Q2). Compact reflows (R12). |
| **VII. Online-only** | Pass | Nothing is cached. Every view reads from the server. |
| **Quality gates** | Pass | Unit, widget and live tests are listed in R13. Every FR maps to at least one test (see tasks). |

**Post-design re-check** (after Phase 1): still passing. The design added no new principle exposure: no core widget changes, no new `AppError` variant, and no codegen.

## Project Structure

### Documentation (this feature)

```text
specs/050-supplier-sub-panels/
├── spec.md              # /speckit-specify + /speckit-clarify
├── wireframes.md        # /speckit-wireframes-draft
├── plan.md              # This file
├── research.md          # Phase 0 (R1–R14)
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/
│   └── ui-contracts.md  # Phase 1 (C1–C8)
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── app/router/app_router.dart                    # + /suppliers/new, /suppliers/:supplierId (C1)
└── features/catalog/
    ├── domain/
    │   ├── entities/supplier.dart                # + addresses, contacts, bankAccounts
    │   ├── entities/bank_account.dart            # NEW
    │   ├── entities/supplier_agreement.dart      # NEW
    │   ├── repositories/supplier_repository.dart # + id lists, agreement CRUD
    │   └── repositories/bank_account_repository.dart  # NEW
    ├── data/
    │   ├── supplier_repository_impl.dart         # + id lists, agreement CRUD, detail lists
    │   └── bank_account_repository_impl.dart     # NEW
    └── presentation/
        ├── suppliers_list_screen.dart            # sheet → context.push
        ├── supplier_detail_screen.dart           # NEW (C2)
        ├── supplier_form.dart                    # + sections, onCreated (C3, C4)
        ├── supplier_form_controller.dart         # + lists, created id, 409 codes
        ├── supplier_agreements_section.dart      # NEW (C5)
        ├── supplier_agreements_controller.dart   # NEW (R4)
        ├── supplier_agreement_dialog.dart        # NEW (C6)
        ├── supplier_agreement_dialog_controller.dart  # NEW
        ├── bank_account_inline_create.dart       # NEW (C7)
        └── bank_account_inline_create_controller.dart # NEW
lib/l10n/app_en.arb, app_es.arb                   # + ~30 keys

test/
├── unit/features/catalog/      # supplier_form_controller, supplier_repository_impl (extended);
│                               # bank_account_repository_impl, bank_account_inline_create_controller,
│                               # supplier_agreement_dialog_controller, supplier_agreements_controller (new)
├── widget/features/catalog/    # supplier_form, suppliers_list_screen (extended);
│                               # supplier_detail_screen, supplier_agreements_section,
│                               # supplier_agreement_dialog, bank_account_inline_create (new)
└── integration/supplier_sub_panels_live_test.dart   # NEW
```

**Structure Decision**: a single Flutter project with feature-first layering. All the work stays in the existing `features/catalog` module, beside the customer screens it mirrors.

## Complexity Tracking

There are no violations to justify.
