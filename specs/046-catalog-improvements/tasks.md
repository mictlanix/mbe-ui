---
description: "Task list for 046-catalog-improvements"
---

# Tasks: Catalog Improvements

**Input**: Design documents from `specs/046-catalog-improvements/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R14), data-model.md, contracts/ui-contracts.md (C1–C7), quickstart.md

**Tests**: The spec does not ask for a test suite as such, but the constitution's quality gates and §VI (measured insets) require tests. Several existing tests also assert the behavior being changed and must be updated. Test tasks are therefore included and sit inside each story.

**Organization**: Grouped by user story (US1–US5, spec.md). The stories are independent and can ship in any order. The plan's suggested delivery order is US2 + US3, then US1, then US4 + US5.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 customer links · US2 production sites · US3 "Planta" label · US4 photo preview · US5 thumbnail spacing

## Cross-story notes

- **Shared files.** Several stories edit the same files. Do these sequentially, not in parallel:
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: US1, US2, US3 and US4 all touch them. Run `flutter gen-l10n` after each arb task and commit the regenerated `lib/l10n/app_localizations*.dart` files.
  - `lib/features/catalog/presentation/products_list_screen.dart`: US4 then US5.
  - `test/widget/features/catalog/products_list_screen_test.dart`: US4 then US5.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs`.
- **No backend work.** Nothing here touches mbe-api, and no codegen re-run is needed (plan, contracts C7).

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [X] T001 Run `flutter analyze` and the test files listed in `specs/046-catalog-improvements/quickstart.md` § Automated checks on the clean branch; note any pre-existing failures so they are not blamed on this feature

---

## Phase 2: Foundational

No blocking prerequisites. Each story is self-contained; the small shared domain changes live inside US1, the only story that needs them.

---

## Phase 2b: Code-generator upgrade (added during implementation)

**Purpose**: `build_runner` could not run on Flutter 3.47.7, so no `@freezed`/`@riverpod` change could be generated (research R15). Done before the stories' generated code could compile.

- [X] T045 Bump `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`, `freezed`, `freezed_annotation`, `build_runner` and `json_serializable` in `pubspec.yaml`; `flutter pub get`
- [X] T046 Mechanical migration across `lib/` and `test/`: freezed classes `abstract`, typed refs to `Ref`, `valueOrNull` to `value`, `legacy.dart`/`misc.dart` imports, `authNotifierProvider` to `authProvider`, the `TrackedEditing.ref` type; regenerate with `dart run build_runner build --delete-conflicting-outputs`
- [X] T047 Turn Riverpod 3's automatic retry off at the app root in `lib/main.dart` and in every test `ProviderScope`/`ProviderContainer`
- [X] T048 Keep async writes alive across their request (`ref.keepAlive()`) in `lib/features/sales/presentation/tracked_editing.dart`, `sale_editing.dart`, `quote_editing.dart`, `delivery/delivery_controller.dart` and `close_session_form_controller.dart`; guard `UnconfirmedEdits.remove` in `lib/core/async/critical_action_guard.dart` with `ref.mounted`; watch the repository before the `await` in `capture/product_lookup_controller.dart`
- [X] T049 Subscribe the auto-disposed controllers that `test/widget/features/sales/sale_editor_isolation_test.dart` reads, as a real screen would; mark the `copyWithPrevious` fixture in `test/widget/core/widgets/list_state_views_test.dart` as a deliberate use of an internal member
- [X] T050 `flutter analyze` clean; full suite run, with the failures that predate this work identified (research R15)

---

## Phase 3: User Story 1 — Manage a customer's addresses, contacts and taxpayers (Priority: P1)

**Goal**: The customer form shows, links, creates and unlinks addresses, contacts and taxpayers, and saving a multi-RFC customer no longer drops RFCs.

**Independent Test**: Quickstart scenarios 1–6. Open a customer with 2+ RFCs, change an unrelated field, save, and reopen: all RFCs remain. Then link, create and unlink records, save, and confirm each change.

### Domain and data

- [X] T002 [P] [US1] In `lib/features/catalog/domain/entities/address_list_item.dart`, add `@Default(EntityStatus.active) EntityStatus status`, mapped from `AddressResponse.status` in `fromResponse` (data-model §2); re-run build_runner
- [X] T003 [P] [US1] In `lib/features/catalog/domain/entities/taxpayer_recipient_list_item.dart`, add `TaxpayerRecipientListItem.fromRecipient(TaxpayerRecipient r)` carrying `taxpayerRecipientId`, `name`, `email`. Only `fromResponse` exists today, and `Customer.taxpayers` holds full `TaxpayerRecipient` entities, so this factory is required (data-model §4)
- [X] T004 [P] [US1] Add an optional `EntityStatus? status` parameter to `list(...)` in `lib/features/catalog/domain/repositories/address_repository.dart` and pass it to the generated `listAddresses(status:)` in `lib/features/catalog/data/address_repository_impl.dart` (data-model §3). Existing callers must compile unchanged
- [X] T005 [US1] In `lib/features/catalog/presentation/taxpayer_recipient_form_controller.dart`, add `TaxpayerRecipient? created` to the state and set it from the repository's return value in `submitCreate`. In `lib/features/catalog/presentation/taxpayer_recipient_form.dart`, on `saved` call `Navigator.pop(state.created)` instead of a bare pop; update flow must still pop with no value (research R7, data-model §5); re-run build_runner

### Localization

- [X] T006 [US1] Add the US1 strings to `lib/l10n/app_en.arb` (with `@` metadata) and `lib/l10n/app_es.arb`, then run `flutter gen-l10n`:
  - section titles: Addresses, Contacts, Tax recipients (es: Direcciones, Contactos, Receptores fiscales — matching the existing `taxpayerRecipientsMenuTitle` wording);
  - "No addresses linked" / contacts / taxpayers empty texts;
  - "Unlink" (es: Desvincular);
  - "New" (es: Nuevo) as the link-section create button;
  - "Link existing…" picker label per section;
  - taxpayer inline-create dialog title (es: reuse the existing `newTaxpayerRecipientTitle` "Nuevo receptor fiscal" if it fits; add a key only if it doesn't).

### Controller and widgets

- [X] T007 [US1] In `lib/features/catalog/presentation/customer_form_controller.dart`, implement data-model §1:
  - replace `taxpayerId` / `taxpayerDisplayText` with `taxpayers`, and add `addresses` and `contacts`;
  - add `addressAdded/Removed`, `contactAdded/Removed`, `taxpayerAdded/Removed`, each deduplicating and clearing field errors;
  - keep `taxpayerSelected(rfc, name)` as a single-item replace for the POS (research R4);
  - seed the three lists in `loadForEdit`;
  - in `submitCreate` and `submitUpdate`, always pass all three id lists;
  - delete `_taxpayersOf`;
  - re-run build_runner.
  
  The permission re-checks in create/update/delete stay as they are
- [X] T008 [P] [US1] Create `lib/features/catalog/presentation/widgets/linked_records_section.dart` per contracts C1: header with count, rows with an optional subtitle and inactive badge, a keyed remove button (`ValueKey('unlink-<id>')`), a bare `CatalogEntityPicker<T>` that leaves out already-linked ids, a "New" button, read-only and empty rendering, and `Spacing` tokens only. No I/O inside the widget (depends on T006)
- [X] T009 [P] [US1] Create `lib/features/catalog/presentation/taxpayer_recipient_inline_create.dart` per contracts C2: `showTaxpayerRecipientInlineCreateDialog` hosts `TaxpayerRecipientForm` in a `Dialog` (max width 640, scrollable) and returns the created record mapped to `TaxpayerRecipientListItem` (depends on T003, T005, T006)
- [X] T010 [US1] In `lib/features/sales/presentation/customer_inline_create.dart`, adapt the POS quick-create to the list state: the picker's `initialDisplayText` comes from `taxpayers.firstOrNull`, and `onSelected` keeps calling `taxpayerSelected`. Behavior must not change (research R4; depends on T007)
- [X] T011 [US1] In `lib/features/catalog/presentation/customer_form.dart`, remove the `taxpayer_field` picker. After `comment` and before `EntityStatusFormField`, add three full-width `LinkedRecordsSection`s separated by the shared divider, wired as in contracts C1's instance table:
  - search from `addressRepositoryProvider` (with `status: active`), `contactRepositoryProvider` and `taxpayerRecipientRepositoryProvider`;
  - create from the two existing inline dialogs and the new taxpayer dialog;
  - `editable` is the form's existing `!readOnly`;
  - gate "link existing" on `can(<obj>, read)` and "New" on `can(<obj>, create)`, using `SystemObject.addresses`, `.contacts` and `.taxpayerRecipients` (research R8).
  
  Update the class doc comment that says the form has no inline address/contact creation (depends on T007, T008, T009)

### Tests

- [X] T012 [P] [US1] Update `test/unit/features/catalog/customer_form_controller_test.dart`:
  - add/remove/dedupe for all three lists;
  - `loadForEdit` seeds the three lists;
  - update sends all three id lists complete: a customer with 2 RFCs keeps both after saving an unrelated change (FR-006);
  - create sends the lists;
  - `taxpayerSelected` replaces the list with one item;
  - `isDirty()` flips on a link change;
  - unlinking never deletes the record: `verifyNever` on any address, contact or taxpayer-recipient delete/update call (spec US1 scenario 5).
- [X] T013 [P] [US1] Create `test/widget/features/catalog/linked_records_section_test.dart`: rows and counts; unlink calls back; an already-linked record is excluded from the picker options; "New" result is passed to `onLinked`; read-only shows no controls; inactive badge; empty text; a long list does not overflow at a compact width
- [X] T014 [P] [US1] Create `test/widget/features/catalog/taxpayer_recipient_inline_create_test.dart` (returns the created record; cancel returns null). Extend `test/unit/features/catalog/taxpayer_recipient_form_controller_test.dart` with `created` being set on create and null on update
- [X] T015 [P] [US1] Extend the address repository test under `test/unit/features/catalog/` (find the existing `address_repository_impl` test) to assert `status` is forwarded and that omitting it keeps the old request
- [X] T016 [US1] Update `test/widget/features/catalog/customer_form_test.dart`:
  - add provider overrides for the address, contact and taxpayer-recipient repositories;
  - cover the three sections listing linked records, read-only hiding every control, "New" hidden without the create privilege, link then Save sending the full lists, and cancel discarding changes with the dirty prompt;
  - cover a customer with 2 RFCs saved without losing either;
  - cover create-then-failed-save: a contact created with "Nuevo" stays in the section, the customer save fails and shows the error, and retrying Save sends that contact's id once, with no second contact created (spec edge case "Failure while creating a linked record") (depends on T011)
- [X] T017 [US1] Run and, if needed, update `test/widget/features/sales/customer_inline_create_test.dart` and `test/widget/features/sales/quote_customer_inline_create_test.dart`; behavior must be unchanged (depends on T010)
- [X] T018 [US1] Manual validation: quickstart scenarios 1–6 against the dev backend, including the read-only user (scenario 5) — *confirmed in the running app by the product owner, 2026-10-17*

**Checkpoint**: US1 is shippable on its own.

---

### Follow-up: customer form on its own screen (added 2026-10-17, FR-020)

- [X] T051 [US1] Amend constitution §VI to v1.13.3 (Customers moves to the full-screen list) and DESIGN.md §4.2 to match, in `.specify/memory/constitution.md` and `DESIGN.md`
- [X] T052 [US1] Create `lib/features/catalog/presentation/customer_detail_screen.dart` (titles per mode, Edit replaces the route, discard prompt on back); add `onEditRequested` and `didUpdateWidget` to `customer_form.dart`; pair Addresses and Contacts on wide tiers
- [X] T053 [US1] Extract the shared discard prompt `confirmDiscardChanges` in `lib/core/widgets/app_side_sheet.dart`
- [X] T054 [US1] Add the `/customers/new` and `/customers/:customerId` routes and drop `/customers` from the legacy redirects in `lib/app/router/app_router.dart`; push them from `customers_list_screen.dart` instead of `showRecordSheet`
- [X] T055 [US1] Tests: `test/widget/features/catalog/customer_detail_screen_test.dart` (new), `customers_list_screen_test.dart`, `test/unit/app/router/app_router_test.dart`

### Follow-up: the walk-in customer's links are fixed (added 2026-10-17, FR-021)

- [X] T056 [US1] In `customer_form_controller.dart`, add `genericTaxpayerRfc` and `isGenericCustomer` (via `AppSettings.isGenericCustomer`); ignore link additions and RFC removals for it; send only the generic RFC on update
- [X] T057 [US1] In `customer_form.dart`, hide link/New controls and RFC unlink for the walk-in customer and show the note (`customerGenericTaxpayerNote` in both `.arb` files)
- [X] T058 [US1] Tests: walk-in group in `customer_form_controller_test.dart`; walk-in widget test and an `appSettingsProvider` override in `customer_form_test.dart`

---

## Phase 4: User Story 2 — Production sites can have points of sale and cash drawers (Priority: P2)

**Goal**: A production site shows and manages Warehouses, Points of Sale and Cash Drawers exactly like a store.

**Independent Test**: Quickstart scenario 7. Expand a production site, see all three sections, create a point of sale and a cash drawer, and confirm both appear.

- [X] T019 [US2] In `lib/features/catalog/presentation/facility_children_controller.dart`, remove the `isStore` gate (lines ~40–49): `pointsOfSaleReadable` and `cashDrawersReadable` depend only on `can(..., read)`. **Drop the now-dead `FacilityType facilityType` family parameter** so the provider is keyed by `facilityId` alone, and update the doc comment about per-type fetching. Update every caller of `facilityChildrenControllerProvider(id, type)` to `(id)`:
  - `lib/features/catalog/presentation/facility_form_controller.dart:199-201`: `_invalidateOwnChildren(int facilityId)` drops its `type` argument, and its doc comment loses the remark about the type being part of the form state; update its callers in the same file;
  - `lib/features/catalog/presentation/widgets/facility_card.dart` and any other call site found with `grep -rn facilityChildrenControllerProvider lib test`.
  
  Re-run build_runner (research R11)
- [X] T020 [US2] In `lib/features/catalog/presentation/widgets/facility_card.dart`, remove every `isStore` branch on children (research R11):
  - the count badges;
  - the Points of Sale and Cash Drawers sections with their "+" actions;
  - the `productionSiteChildrenNote` block.
  
  Keep the type icon and label (FR-013): `_Header` still needs `isStore` for them. Remove the `isStore` parameter from the badge and body widgets, which no longer use it. Coordinate with T019, which edits the provider call in the same file
- [X] T021 [US2] Delete `productionSiteChildrenNote` (with its `@` entry) from `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`, then run `flutter gen-l10n` (depends on T020)
- [X] T022 [P] [US2] Invert `test/unit/features/catalog/facility_children_controller_test.dart` (~lines 149–178): a production site now requests all three child lists, and `pointsOfSaleReadable` / `cashDrawersReadable` follow the privilege. Update every `facilityChildrenControllerProvider(id, type)` reference to the single-key form (T019), here and in `test/unit/features/catalog/` facility form controller tests if they reference it
- [X] T023 [P] [US2] Invert `test/widget/features/catalog/facilities_list_screen_test.dart` (~lines 342–381): the production-site card shows Warehouses, Points of Sale and Cash Drawers with counts and "+" actions, the note is absent, and POS and drawer lists are fetched. Check the other uses of `_productionSite` (~lines 287, 498) still hold. Add a case for spec US2 scenario 3: a production site that has points of sale and cash drawers lists them under their sections with the right counts
- [X] T024 [P] [US2] Update `test/integration/facility_children_controller_live_test.dart` (~lines 88–93): drop the assertion that a production site's points of sale and cash drawers are empty
- [X] T025 [US2] Manual validation: quickstart scenario 7. Also change a store that has points of sale to a production site and confirm its children stay visible (spec US2 scenario 3) — *confirmed in the running app by the product owner, 2026-10-17*

**Checkpoint**: US2 is shippable on its own.

---

## Phase 5: User Story 3 — "Planta" label (Priority: P2)

**Goal**: Spanish users see "Planta" wherever the production-site type is named.

**Independent Test**: Quickstart scenario 8.

- [X] T026 [US3] In `lib/l10n/app_es.arb`, change `facilityTypeProductionSite` from "Sitio de producción" to "Planta"; leave English unchanged. Run `flutter gen-l10n` (after T021, since both edit the arb files)
- [X] T027 [US3] Run `grep -rni "sitio de producci" lib test` and fix any remaining occurrence. Add a Spanish-locale assertion in `test/widget/features/catalog/facilities_list_screen_test.dart` that the production-site card reads "Planta" and the facility form type dropdown offers "Planta" in `test/widget/features/catalog/facility_detail_screen_test.dart` (depends on T026)
- [X] T028 [US3] Manual validation: quickstart scenario 8 — *confirmed in the running app by the product owner, 2026-10-17*

**Checkpoint**: US3 is shippable on its own.

---

## Phase 6: User Story 4 — Larger product photo preview (Priority: P3)

**Goal**: Clicking a product photo opens an enlarged preview dialog, without triggering the row's own action.

**Independent Test**: Quickstart scenarios 9 and 10.

- [X] T029 [US4] Add the preview strings to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: close tooltip and the preview semantics label. Run `flutter gen-l10n` (after T026) — *as built: none needed; the close button reuses the existing `documentCloseTooltip`*
- [X] T030 [US4] In `lib/core/widgets/product_photo.dart`, add `VoidCallback? onTap` (contracts C3). When it is set, wrap the loaded image in an `InkWell` with a click cursor from `Image.network(frameBuilder:)` once `frame != null`. Placeholders (null URL or load error) are never wrapped. Behavior with `onTap == null` must not change
- [X] T031 [US4] Create `lib/core/widgets/product_photo_preview.dart` per contracts C4: `showProductPhotoPreview(context, {photoUrl, title})`, a `Dialog` with an ellipsized title, a close `IconButton` (`Key('photo_preview_close')`), an `Image.network(fit: BoxFit.contain)` limited to about 90% of the viewport, and the shared placeholder on load error. Escape, barrier tap and close all dismiss (depends on T029, T030)
- [X] T032 [US4] In `lib/features/catalog/presentation/products_list_screen.dart` (the photo cell, ~lines 128–132), pass `onTap: p.photo == null ? null : () => showProductPhotoPreview(context, photoUrl: p.photo!, title: p.name)` (depends on T031)
- [X] T033 [US4] In `lib/features/catalog/presentation/product_detail_screen.dart`, make only the saved-photo branch of `_thumbnail()` previewable; a pending (unsaved) upload is not (depends on T031)
- [X] T034 [P] [US4] Extend `test/widget/core/widgets/product_photo_test.dart`: `onTap` fires on a loaded photo; it does not fire on the null-URL or error placeholder; existing cases unchanged. To make a photo actually load, reuse the network-image stub pattern this file already uses for its "network image" case; the default test HTTP client returns errors, which would only exercise the placeholder
- [X] T035 [P] [US4] Create `test/widget/core/widgets/product_photo_preview_test.dart`: shows the title and image; Escape, barrier tap and the close button each dismiss; load error shows the placeholder; a tall portrait image fits inside the dialog without overflow or page scroll (spec edge case "Very large or portrait photos"). Use the same image stub as T034
- [X] T036 [US4] Extend `test/widget/features/catalog/products_list_screen_test.dart`: tapping a photo opens the preview and does **not** navigate to the product; tapping elsewhere in the row still opens the read-only view; a product without a photo has no preview (depends on T032)
- [X] T037 [US4] Manual validation: quickstart scenarios 9 and 10 — *confirmed in the running app by the product owner, 2026-10-17*

**Checkpoint**: US4 is shippable on its own.

---

## Phase 7: User Story 5 — Spacing around product thumbnails (Priority: P3)

**Goal**: Thumbnails have visible space on every side and are never clipped by the row, at every density.

**Independent Test**: Quickstart scenario 11.

- [X] T038 [US5] In `lib/features/catalog/presentation/products_list_screen.dart`, size the photo cell per contracts C5: `size = (density.tableDataRowHeight ?? 44) - 2 * spacing.xxs`, wrapped in a centered `Padding(symmetric(vertical: spacing.xxs, horizontal: spacing.xs))`, with the column's `fixedWidth` set to `size + 2 * spacing.xs`. Use the existing density and spacing providers; no literals (after T032)
- [X] T039 [P] [US5] In `lib/features/catalog/presentation/product_detail_screen.dart` `_PhotoSection`, add `spacing.xs` padding around the thumbnail so it keeps a gap from the upload, replace and remove buttons in both the wide and compact layouts (FR-019)
- [X] T040 [US5] Update `test/widget/features/catalog/products_list_screen_test.dart` (~lines 295–312): replace the `size == 84` assertion with the derived size, and add a measuring test (§VI) that the space above the photo equals the space below it and is greater than 0, at both pointer and touch densities (after T036)
- [X] T041 [US5] Manual validation: quickstart scenario 11, plus the detail screen at both layouts — *confirmed in the running app by the product owner, 2026-10-17*

**Checkpoint**: US5 is shippable on its own.

---

## Phase 8: Polish & cross-cutting

- [X] T042 Run `dart format` on every changed file and `flutter analyze`; fix anything this feature introduced. Mention, but do not fix, unrelated warnings
- [X] T043 Run the full `flutter test` suite, including `test/unit/core/formatting_guard_test.dart`; confirm nothing outside the files named in this list changed behavior — *as built: 2934 pass, 62 skipped, 19 fail; all 19 predate this feature (research R15: Flutter 3.47 golden diffs, the regenerated products client, the live backend's 500)*
- [X] T044 Run the whole of `specs/046-catalog-improvements/quickstart.md` once end to end (all 11 scenarios) in Spanish, then confirm the success criteria SC-001 to SC-006 in `spec.md` — *confirmed in the running app by the product owner, 2026-10-17*

---

## Dependencies & execution order

- **Phase 1** first. There is no blocking phase 2.
- **Stories are independent.** The only coupling is file-level:
  - `lib/l10n/app_*.arb`: T006 → T021 → T026 → T029, in that order;
  - `products_list_screen.dart` and its test: US4 (T032, T036) before US5 (T038, T040).
- **Inside US1:**
  - T002, T003, T004 and T005 are independent of each other.
  - T006 comes before T008 and T009.
  - T007 comes before T010 and T011.
  - T011 needs T007, T008 and T009.
  - The tests follow their implementations: T012 after T007, T013 after T008, T014 after T009, T016 after T011, T017 after T010.
- **Polish** after all stories you intend to ship.

## Parallel examples

```text
US1 domain:    T002 | T003 | T004            (then T005)
US1 widgets:   T008 | T009                   (after T006; T009 also after T005)
US1 tests:     T012 | T013 | T014 | T015     (each after its implementation)
US2:           T019 → T020 → T021 (T019 and T020 share facility_card.dart); T022 | T023 | T024
US4 tests:     T034 | T035
Across stories: US1 and US2 can run on separate branches/agents; US2 and US4 only meet in the arb files.
```

## Implementation strategy

- **MVP**: US1 (P1). It is the largest value and the only story that fixes data loss.
- **Quickest win**: US2 + US3. They are small, and unblock plant operations.
- **Incremental delivery**: Each story ends at a checkpoint that can ship alone. The suggested order is US2 + US3 → US1 → US4 → US5.
