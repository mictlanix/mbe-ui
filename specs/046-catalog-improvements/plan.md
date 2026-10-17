# Implementation Plan: Catalog Improvements

**Branch**: `046-catalog-improvements` | **Date**: 2026-10-16 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/046-catalog-improvements/spec.md`

## Summary

This plan covers three independent slices across three catalogs. None needs a backend change.

1. **Customers (P1)**
   - Add Addresses, Contacts and Taxpayers sections to the existing customer side-sheet form. They are three instances of one generic `LinkedRecordsSection<T>`.
   - The links live in form state and are saved as replace-all id lists. This also fixes the bug where a save drops every RFC but the first.
   - New records come from the existing address and contact inline-create dialogs, plus a new taxpayer dialog that hosts the existing `TaxpayerRecipientForm`.
   - Records can be linked, unlinked or created here, but never edited in place (clarified).
2. **Facilities (P2)**
   - Remove the `isStore` gates so production sites fetch and show points of sale and cash drawers.
   - Delete the "warehouses only" note and its arb key.
   - Rename the Spanish label to "Planta".
3. **Products (P3)**
   - Add an optional `onTap` to `ProductPhoto` that only fires once the photo has loaded, and a `showProductPhotoPreview` dialog.
   - In the list, size the photo to fit inside the shared row height, with symmetric padding from the spacing tokens.

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter 3.44.2 stable (unchanged)

**Primary Dependencies**: Riverpod (`riverpod_annotation`), `freezed`, `go_router`, `data_table_2` 2.7.2, and the generated `mbe_api_client`. No new packages. No codegen re-run: the client already exposes everything this plan uses (contracts C7).

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter_test` + `mocktail`.
- Widget tests use `ProviderScope` overrides; `customer_form_test.dart:82-116` is the pattern to follow.
- One existing live integration test is updated: `facility_children_controller_live_test.dart`.

**Target Platform**: Web/desktop first (Expanded tier). Compact gets a full-width bottom sheet from `showAppSideSheet`.

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:
- No new list fetches on the customer form beyond the debounced picker searches.
- Production sites now make the two child fetches that stores already make.

**Constraints**:
- Customers stay on the shared panel (§VI, research R1).
- Spacing comes only from tokens, with symmetric row insets asserted by tests (§VI).
- Actions the user lacks RBAC for are hidden, never disabled (§IV).
- The committed l10n files are regenerated, not hand-edited.

**Scale/Scope**:

| | Files |
|---|---|
| **New (3 source files, plus tests)** | `linked_records_section.dart`, `taxpayer_recipient_inline_create.dart`, `core/widgets/product_photo_preview.dart` |
| **Edited, customers** | `customer_form.dart`, `customer_form_controller.dart`, `customer_inline_create.dart` (POS), `address_list_item.dart`, `address_repository.dart` + impl, `taxpayer_recipient_form.dart` + controller, `taxpayer_recipient_list_item.dart` (factory) |
| **Edited, facilities** | `facility_children_controller.dart` (drops the `facilityType` family key), `facility_form_controller.dart` (`_invalidateOwnChildren`), `facility_card.dart` |
| **Edited, products** | `product_photo.dart`, `products_list_screen.dart`, `product_detail_screen.dart` |
| **Edited, l10n** | both `.arb` files, plus the regenerated `app_localizations*.dart` |

l10n detail:
- 1 key removed (`productionSiteChildrenNote`).
- 1 Spanish value changed.
- About 10 keys added: section titles, empty texts, "Desvincular", "Nuevo", the preview close tooltip, and the taxpayer dialog title.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | Customer and facility work stays in `features/catalog/{domain,data,presentation}`. The photo preview goes in `core/widgets/` next to `ProductPhoto`, because both are shared across features. Presentation reaches repositories only through their providers, as the repo already does. |
| **II. Riverpod** | Pass | The new state lives in the existing freezed `CustomerFormState` (`Notifier`). `LinkedRecordsSection` is stateless and driven by callbacks. Repositories stay provider-overridable. |
| **III. Contract-driven API** | Pass | Uses only generated methods and fields: the customer link lists, `listAddresses(status:)`, and `AddressResponse.status`. No hand-written DTOs, no generated-file edits, no bypass of dio. **No mbe-api change**, so no issue to file. Discounts and shipping are excluded rather than built around (R10). |
| **IV. Deny-by-default RBAC** | Pass | Section editing follows the form's existing `customers` update/create gate. "Link existing" needs `<obj>` read, and "Nuevo" needs `<obj>` create (`addresses` 11, `contacts` 12, `taxpayerRecipients` 54). Actions are hidden when not allowed, and no new `SystemObject` is added (R8). |
| **V. Material 3 design system** | Pass | Uses `Dialog`, `ListTile`, `TextButton.icon`, `IconButton`, `InkWell`, and the shared `CatalogEntityPicker` and status badge. All strings are in `.arb` files. No formatting calls are added (the formatting guard is unaffected). |
| **VI. Desktop/web-first layout** | Pass, with a note | The customer form stays on `showRecordSheet`, and §VI lists Customers as a panel entity. The new sections are multi-value **link** fields, not nested child collections with their own record surfaces, so the "full detail screen for nested child collections" rule does not apply (R1). The sections go full-width below the grid and are separated by the shared divider. The row-click, Edit and `RecordFormActions` behaviour is unchanged. The product list keeps the shared row height (R14), and the thumbnail insets come from tokens and are asserted by measuring tests. The photo preview is a modal dialog, not a record surface, and the row click still opens the read-only view when the click lands outside the photo. |
| **VII. Online-only** | Pass | Nothing is cached. The preview loads the same photo URL. |
| **Quality gates** | Pass | Unit tests: controller add/remove/dedupe, replace-all save, the POS single-select path, and the facility controller for all types. Widget tests: the section, the customer form, the taxpayer dialog, the photo and preview, measured thumbnail insets, and the facility card. One live integration test is updated. |

**Post-design re-check** (after Phase 1): still passing.
- `LinkedRecordsSection` is kept in `features/catalog/presentation/widgets/`, because customers are its only consumer. Promoting it to `core/widgets/` waits for a second consumer, such as suppliers once mbe-api exposes their links.
- No amendment is needed.

## Project Structure

### Documentation (this feature)

```text
specs/046-catalog-improvements/
├── plan.md              # This file
├── research.md          # Phase 0 (R1–R14)
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
├── core/widgets/
│   ├── product_photo.dart                 # + onTap (C3)
│   └── product_photo_preview.dart         # NEW (C4)
├── features/catalog/
│   ├── domain/
│   │   ├── entities/address_list_item.dart          # + status
│   │   ├── entities/taxpayer_recipient_list_item.dart # + fromRecipient
│   │   └── repositories/address_repository.dart     # list(status:)
│   ├── data/address_repository_impl.dart            # pass status
│   └── presentation/
│       ├── customer_form.dart                       # 3 sections, drop taxpayer_field
│       ├── customer_form_controller.dart            # list state, replace-all save
│       ├── taxpayer_recipient_form.dart             # pop(created)
│       ├── taxpayer_recipient_form_controller.dart  # + created
│       ├── taxpayer_recipient_inline_create.dart    # NEW (C2)
│       ├── facility_children_controller.dart        # drop isStore gate + facilityType family key
│       ├── facility_form_controller.dart            # _invalidateOwnChildren(id)
│       ├── products_list_screen.dart                # photo cell (C5) + preview
│       ├── product_detail_screen.dart               # preview + thumbnail padding
│       └── widgets/
│           ├── linked_records_section.dart          # NEW (C1)
│           └── facility_card.dart                   # drop isStore branches + note
├── features/sales/presentation/customer_inline_create.dart # taxpayers list adapter (R4)
└── l10n/app_en.arb, app_es.arb (+ regenerated app_localizations*.dart)

test/
├── unit/features/catalog/{customer_form_controller,facility_children_controller,taxpayer_recipient_form_controller}_test.dart
├── widget/features/catalog/{customer_form,linked_records_section,taxpayer_recipient_inline_create,facilities_list_screen,products_list_screen}_test.dart
├── widget/features/sales/{customer_inline_create,quote_customer_inline_create}_test.dart
├── widget/core/widgets/{product_photo,product_photo_preview}_test.dart
└── integration/facility_children_controller_live_test.dart
```

**Structure Decision**: This uses the existing feature-first layout. The only new shared widget, the photo preview, goes in `core/widgets/` because `ProductPhoto` is used by catalog, sales and pricing.

## Delivery order

The three slices are independent and can each ship and be tested on their own.

1. **US2 + US3, facilities and "Planta".** The smallest slice, and it unblocks plant operations. Verify by inverting the tests and running the live facility test.
2. **US1, customers.** In order:
   1. Domain tweaks (R9, factory).
   2. Controller state and save, with unit tests.
   3. `LinkedRecordsSection`, with a widget test.
   4. The taxpayer dialog (R7).
   5. Form wiring and the POS adapter, with the customer form and POS inline-create tests.
3. **US4 + US5, products.** First `ProductPhoto.onTap` and the preview, then the list cell sizing and the detail-screen hookup, then the measuring tests.

## Complexity Tracking

No constitution violations. The §VI note on the customer panel is explained in research R1 and needs no amendment.
