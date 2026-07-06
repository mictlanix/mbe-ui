# Tasks: Catalog UI Improvements Round 2

**Input**: Design documents from `/specs/007-catalog-ui-improvements-2/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all present)

**Tests**: Included. The constitution's Development Workflow & Quality Gates section mandates unit/widget/integration test coverage for `core/widgets/` components and per-module screens, and every file this feature touches already has an existing test file — these are updated to match the new contracts, not written from a blank TDD slate.

**Organization**: Tasks are grouped by user story (spec.md priorities P1/P2/P2/P3/P3/P3) so each can be implemented and validated independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no unresolved dependency on an incomplete task)
- **[Story]**: Maps the task to spec.md's US1–US6
- File paths are exact and repo-relative

## Important cross-cutting note on parallelism

Several stories touch the **same files** (`product_detail_screen.dart` is touched by US1, US3, US4, US5; `products_list_screen.dart` is touched by US1, US2, US5, US6). `[P]` is only applied where the *specific* task's file doesn't overlap another in-flight task. If one person is implementing this feature, treat "parallel" as "can be done in any order relative to its siblings," not "must be split across people" — the story-priority order (P1 → P2 → P2 → P3 → P3 → P3) is the recommended default sequencing regardless.

---

## Phase 1: Setup

**Purpose**: Confirm the starting baseline before any change.

- [X] T001 Run `dart analyze lib` and `flutter test` to record the current baseline. `dart analyze` is expected to show exactly one pre-existing error (`lib/features/catalog/domain/entities/product.dart:86` — `ProductResponse.prices` no longer exists, per plan.md's Pre-Implementation Note) which Phase 2 fixes; confirm no *other* errors exist and note the current passing test count. Confirm no new pubspec dependencies are needed for this feature (clipboard access comes from the Flutter SDK's `flutter/services.dart`; `LabelMultiPicker`, `FilledButton`, etc. already exist in the codebase).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Fix the pre-existing build break caused by mbe-api's upstream removal of `ProductResponse.prices`, which also delivers FR-012/FR-013 (drop the price section, reposition labels into its place) as a side effect of the fix — see plan.md's Pre-Implementation Note and research.md §5.

**⚠️ CRITICAL**: No user story can be built or run until this phase compiles cleanly.

- [X] T002 Remove the `prices` field, its constructor parameter, and the `response.prices` mapping from `Product`/`Product.fromResponse` in lib/features/catalog/domain/entities/product.dart, and drop the now-unused `product_price.dart` import. This fixes the current `dart analyze` failure.
- [X] T003 [P] Delete the now-orphaned lib/features/catalog/domain/entities/product_price.dart (nothing will reference `ProductPrice` once T002 lands).
- [X] T004 Remove the `prices` field and its `loadForEdit` seeding (`prices: product.prices`) from `ProductFormState`/`ProductFormController` in lib/features/catalog/presentation/product_form_controller.dart (depends on T002).
- [X] T005 Remove the price sub-panel and reposition the existing `LabelMultiPicker` labels section into the vacated two-column band — rename `_SwitchesPricesBand` to `_SwitchesLabelsBand` and drop its `prices` parameter — in lib/features/catalog/presentation/product_detail_screen.dart (depends on T004). Delivers FR-012 and FR-013.
- [X] T006 Regenerate freezed code for the entities/state touched by T002/T004: `dart run build_runner build --delete-conflicting-outputs` (depends on T002, T004).
- [X] T007 [P] Update test/unit/features/catalog/product_form_controller_test.dart to remove price-related fixtures/assertions.
- [X] T008 [P] Update test/widget/features/catalog/product_detail_screen_test.dart to assert no price section renders and that labels appear in the repositioned band.
- [X] T009 [P] Update test/unit/features/catalog/product_repository_impl_test.dart if it asserts on a `Product.prices`/`ProductPrice` mapping.
- [X] T010 Run `dart analyze lib` to confirm zero errors and `flutter test test/unit/features/catalog test/widget/features/catalog` to confirm the updated tests pass. **Checkpoint: build is unblocked, all user stories can proceed.**

---

## Phase 3: User Story 1 - Browse and open a product without accidentally editing it (Priority: P1) 🎯 MVP

**Goal**: Row clicks and row actions across every catalog/list screen default to a safe, read-only view; Edit becomes the only row-level action; the read-only screen is titled "View" and offers an explicit switch to editing.

**Independent Test**: Open the products list, click a row body (not an icon) → detail opens read-only, titled "View Product", no Save button. Press the provided Edit affordance → switches to the editable form. Repeat on `/users`.

- [X] T011 [P] [US1] Remove the `frozen` field from `DataTableColumn`, the frozen branch in `DataTableColumn.text`, the frozen-related `assert`s, and the `_fixedLeftColumns` logic in lib/core/widgets/data_table_view.dart. Delivers FR-001.
- [X] T012 [P] [US1] Reduce `buildCatalogRowActions` to Edit-only in lib/core/widgets/catalog_action_icons.dart — drop the `onView`/`onDelete` parameters and their tooltips, and remove the now-unused `view`/`delete` entries from the `CatalogAction` enum (confirm via `grep -rn "CatalogAction\."` that nothing else references them). Delivers FR-002.
- [X] T013 [P] [US1] Add `viewProductTitle`, `viewUserTitle`, and Edit-affordance tooltip/label l10n keys to lib/l10n/app_es.arb (default) and lib/l10n/app_en.arb. Needed by T015/T016.
- [X] T014 [US1] Update lib/features/catalog/presentation/products_list_screen.dart: drop `frozen: true` from the code column, change `onRowTap` to `context.push('/products/${p.productId}?view=true')`, and pass only `onEdit` to `buildCatalogRowActions` (drop `onView`/`onDelete` and the now-unreachable row-level `_confirmDeactivate` path). Depends on T011, T012. Delivers FR-001/003/004.
- [X] T015 [P] [US1] Update lib/features/auth/presentation/admin/users_list_screen.dart the same way: drop `frozen: true`, change `onRowTap` to `context.push('/users/${u.userId}?view=true')`, pass only `onEdit` to `buildCatalogRowActions` (drop `onView`/`onDelete`/`_confirmDelete` — user deletion stays reachable via `user_detail_screen`'s own app-bar delete button). Depends on T011, T012.
- [X] T016 [US1] Update lib/features/catalog/presentation/product_detail_screen.dart: show `l10n.viewProductTitle` instead of `editProductTitle` when read-only, and add an Edit affordance (visible only when `canUpdate`) that navigates to the editable route via `context.replace('/products/$productId')`. Depends on T013. Delivers FR-005/006.
- [X] T017 [P] [US1] Apply the same read-only-title + Edit-affordance treatment to lib/features/auth/presentation/admin/user_detail_screen.dart ("View User" vs "Edit User", `context.replace('/users/$userId')`) for cross-screen consistency (research.md §3). Depends on T013.
- [X] T018 [P] [US1] Update test/widget/core/widgets/data_table_view_test.dart to remove frozen-column test cases.
- [X] T019 [P] [US1] Update test/widget/core/widgets/catalog_action_icons_test.dart to assert Edit-only row actions.
- [X] T020 [P] [US1] Update test/widget/features/catalog/products_list_screen_test.dart for row-click-to-view, Edit-only row action, and no frozen column.
- [X] T021 [P] [US1] Update test/widget/features/auth/users_list_screen_test.dart for the same behavior.
- [X] T022 [P] [US1] Update test/widget/features/catalog/product_detail_screen_test.dart for the "View Product" title and the Edit-switch affordance (both read-only-with-rights and read-only-without-rights cases).
- [X] T023 [P] [US1] Create test/widget/features/auth/user_detail_screen_test.dart (none existed) covering the "View User" title and Edit-switch affordance.
- [X] T024 [US1] Manually validate per quickstart.md US1 steps 1–5. **Checkpoint: US1 is fully functional and independently testable — MVP-shippable.**

---

## Phase 4: User Story 2 - Filter products by more than one label at a time (Priority: P2)

**Goal**: The products label filter becomes multi-select with OR semantics, and the active-filter count reflects the number of labels chosen.

**Independent Test**: Select two labels in the filter panel, apply — result set matches either label; badge count shows 2; Clear All empties the selection.

- [X] T025 [P] [US2] Change `ProductFilter.label` (`int?`) to `labels` (`List<int>`, default `const []`); update `activeFilterCount` (`+= labels.length`), `hasActiveFilters`, and `reset`; replace `labelChanged(int?)` with a multi-value setter (e.g. `labelsChanged(List<int>)`) in lib/features/catalog/presentation/products_list_controller.dart. Delivers FR-007/009.
- [X] T026 [US2] Verify the generated products-list method's label-filter query-param cardinality (single vs. repeatable `label`) in lib/generated/openapi/lib/src/api/products_api.dart. If mbe-api only accepts a single value, document that limitation inline rather than silently dropping extra selections (research.md §4 risk).
- [X] T027 [US2] Update `ProductRepository.list`/`ProductRepositoryImpl.list` in lib/features/catalog/domain/repositories/product_repository.dart and lib/features/catalog/data/product_repository_impl.dart to accept `labels: List<int>` and forward per T026's finding. Depends on T026. Delivers FR-008.
- [X] T028 [US2] Replace the `DropdownButton` label filter in `_ProductFiltersPanel` with the existing `LabelMultiPicker`, driven by `filter.labels`, in lib/features/catalog/presentation/products_list_screen.dart. Depends on T025.
- [X] T029 [P] [US2] Update test/unit/features/catalog/products_list_controller_test.dart for the multi-label filter count/reset behavior.
- [X] T030 [P] [US2] Update test/widget/features/catalog/products_list_screen_test.dart for the multi-select label filter UI.
- [X] T031 [P] [US2] Update test/unit/features/catalog/product_repository_impl_test.dart for the `labels` list parameter.
- [X] T032 [US2] Manually validate per quickstart.md US2 steps 1–3. **Checkpoint.**

---

## Phase 5: User Story 3 - See and manage all of a product's real attributes (Priority: P2)

**Goal**: SKU is visible and editable on the product form; supplier assign/change is confirmed working end-to-end.

> FR-012/FR-013 (drop the price section, reposition labels) were already delivered in **Phase 2 (Foundational)** as a build-fix prerequisite — see T005. This phase covers the remaining FR-010/FR-011.

**Independent Test**: Open a product with a SKU and a supplier — SKU is visible/editable and persists; supplier can be changed and persists.

- [X] T033 [US3] Add a `sku` parameter to `ProductRepository.create`/`update` and wire `b.sku = sku` in lib/features/catalog/domain/repositories/product_repository.dart and lib/features/catalog/data/product_repository_impl.dart. Delivers FR-010.
- [X] T034 [US3] Add a `sku` field and `skuChanged` setter to `ProductFormState`/`ProductFormController`, seeded from `Product.sku` in `loadForEdit`, and pass it through `submitCreate`/`submitUpdate` in lib/features/catalog/presentation/product_form_controller.dart. Depends on T033.
- [X] T035 [US3] Add a `sku_field` `TextFormField` to the form in lib/features/catalog/presentation/product_detail_screen.dart. Depends on T034.
- [X] T036 [P] [US3] Add a `skuLabel` l10n key to lib/l10n/app_es.arb and lib/l10n/app_en.arb.
- [X] T037 [US3] Add a doc comment on `ProductRepository.update`'s `supplier` parameter in lib/features/catalog/domain/repositories/product_repository.dart noting that clearing to "no supplier" is not deliverable against current mbe-api semantics (`supplier: null` means "leave unchanged" server-side, per research.md §5) — no behavior change, just making the known gap traceable in code and not only in the spec.
- [X] T038 [P] [US3] Update test/unit/features/catalog/product_form_controller_test.dart for the `sku` field.
- [X] T039 [P] [US3] Update test/widget/features/catalog/product_detail_screen_test.dart to assert the SKU field renders, is editable, and seeds from the loaded product.
- [X] T040 [P] [US3] Update test/unit/features/catalog/product_repository_impl_test.dart to assert `sku` is sent on create and update.
- [X] T041 [US3] Manually validate per quickstart.md US3 steps 1–4 (including the known supplier-clear gap — confirm assign/change work, and confirm clear is *not* expected to work this round). **Checkpoint.**

---

## Phase 6: User Story 4 - Delete a product from a safer, more visible control (Priority: P3)

**Goal**: Replace the app-bar soft-deactivate icon with a warning-styled hard-Delete button below Save, calling mbe-api's real `DELETE` endpoint.

**Independent Test**: No app-bar delete icon; a warning "Delete" button sits below Save; confirming removes the product permanently and returns to the list; a deactivated product can still be deleted.

- [X] T042 [US4] Add `delete({required int productId})` to `ProductRepository` (lib/features/catalog/domain/repositories/product_repository.dart) and implement it in lib/features/catalog/data/product_repository_impl.dart, calling `deleteProductApiV1ProductsProductIdDelete` and mapping `DioException` via the existing `_toAppError`. Update the interface's doc comment (currently states delete is "intentionally never added"). Delivers FR-016a/016b.
- [X] T043 [US4] Replace `ProductFormController.deactivate()` with `delete()` in lib/features/catalog/presentation/product_form_controller.dart: call `ProductRepository.delete`, set a `deleted` flag on success, map failures to the existing error state; rename `ProductFormErrorCode.deactivate*` constants to `delete*`. Depends on T042.
- [X] T044 [US4] Update lib/features/catalog/presentation/product_detail_screen.dart: remove the app-bar `deactivate_product_button`, add a `delete_product_button` `FilledButton` styled with `colorScheme.error`/`onError` directly below Save, change its visibility to `isEdit && canDelete && !forceReadOnly` (no longer gated by `deactivated`), reword the confirmation dialog to state the deletion is permanent/irreversible, and wire `formState.deleted` to `context.pop()`. Depends on T043. Delivers FR-014/015/016/016c.
- [X] T045 [P] [US4] Update/rename delete-related l10n keys (`deleteProductButton`, `deleteProductConfirmTitle`, `deleteProductConfirmMessage` with permanence wording, etc.) in lib/l10n/app_es.arb and lib/l10n/app_en.arb, removing the now-unused `deactivateProduct*` keys.
- [X] T046 [P] [US4] Update test/unit/features/catalog/product_form_controller_test.dart for `delete()`, the `deleted` flag, and error mapping.
- [X] T047 [P] [US4] Update test/widget/features/catalog/product_detail_screen_test.dart for the removed app-bar icon, the warning Delete button (including that it's shown for a deactivated product), and the permanence-worded confirmation dialog.
- [X] T048 [P] [US4] Update test/unit/features/catalog/product_repository_impl_test.dart for the new `delete()` method and its error mapping (including a referential-integrity-style rejection).
- [X] T049 [US4] Manually validate per quickstart.md US4 steps 1–5. **Checkpoint.**

---

## Phase 7: User Story 5 - See product photos at a usable size and uncropped (Priority: P3)

**Goal**: Product photo thumbnails render 75% larger with `BoxFit.contain` everywhere they appear.

**Independent Test**: A non-square photo displays fully (no cropping) at the larger size on both the list and the detail screen.

- [X] T050 [P] [US5] Update lib/core/widgets/product_photo.dart: raise the default `size` from 48 to 84 and change `fit` from `BoxFit.cover` to `BoxFit.contain`. Delivers FR-017/018.
- [X] T051 [US5] Update the detail-screen thumbnail and pending-photo preview size from 96 to 168 in `_PhotoSection` in lib/features/catalog/presentation/product_detail_screen.dart.
- [X] T052 [US5] Adjust the products list photo column's `fixedWidth` in lib/features/catalog/presentation/products_list_screen.dart to fit the enlarged thumbnail (this column is also touched by T054 in US6 — do this one first).
- [X] T053 [P] [US5] Update test/widget/core/widgets/product_photo_test.dart, test/widget/features/catalog/product_detail_screen_test.dart, and test/widget/features/catalog/products_list_screen_test.dart for the new sizes/fit.
- [X] T054 [US5] Manually validate per quickstart.md US5 steps 1–2. **Checkpoint.**

---

## Phase 8: User Story 6 - Scan and reuse product codes faster from the list (Priority: P3)

**Goal**: The photo becomes the first, header-less column; the code cell gets a copy-to-clipboard affordance.

**Independent Test**: Photo is column 1 with a blank header; the copy control on a code cell places the exact code on the clipboard with a confirmation.

- [X] T055 [US6] Move the photo `DataTableColumn` to index 0 with an empty header label (`label: ''`) in lib/features/catalog/presentation/products_list_screen.dart. Depends on T052 (US5's width adjustment). Delivers FR-019.
- [X] T056 [US6] Add a copy-code affordance to the code cell — `Clipboard.setData(ClipboardData(text: p.code))` (from `flutter/services.dart`) plus a `SnackBar` confirmation — in lib/features/catalog/presentation/products_list_screen.dart. Delivers FR-020.
- [X] T057 [P] [US6] Add `codeCopiedMessage`/`copyCodeTooltip` l10n keys to lib/l10n/app_es.arb and lib/l10n/app_en.arb.
- [X] T058 [P] [US6] Update test/widget/features/catalog/products_list_screen_test.dart for the photo-first column, blank header, and copy-code interaction.
- [X] T059 [US6] Manually validate per quickstart.md US6 steps 1–3. **Checkpoint: all user stories independently functional.**

---

## Phase 9: Polish & Cross-Cutting Concerns

- [X] T060 Rename `LEGACY_PHOTOS_BASE_URL` to `PHOTOS_BASE_URL` in lib/core/network/photo_url.dart — the `String.fromEnvironment` key, the Dart const name (`legacyPhotosBaseUrl` → `photosBaseUrl`), and its doc comments. Delivers FR-021.
- [X] T061 [P] Update all other references (`.vscode/launch.json` dart-defines, `.env*` files, any docs) via `grep -rn "LEGACY_PHOTOS_BASE_URL\|legacyPhotosBaseUrl"` across the repo and fix each hit.
- [X] T062 [P] Update test/unit/core/network/photo_url_test.dart for the renamed constant.
- [X] T063 Update DESIGN.md §4.3's "switches|prices two-column band" reference example to "switches|labels" now that product_detail_screen.dart reflects it — clears the Follow-up TODO recorded in the constitution's v1.5.0 Sync Impact Report.
- [X] T064 Run `dart analyze lib` and `flutter test` across the whole repo to confirm zero regressions.
- [X] T065 Run the full quickstart.md validation walkthrough end-to-end across all six user stories as final sign-off.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup — **BLOCKS all user stories** (the app doesn't compile until it's done).
- **User Stories (Phase 3–8)**: All depend on Foundational. Recommended order follows spec.md priority: US1 → US2 → US3 → US4 → US5 → US6. US5 before US6 specifically (both touch the photo column; T052 before T055).
- **Polish (Phase 9)**: Independent of all user stories except T063 (depends on T005's labels-reposition having landed) — can otherwise run any time after Foundational.

### User Story Dependencies

- **US1 (P1)**: No dependency on other stories.
- **US2 (P2)**: No dependency on US1, but touches `products_list_screen.dart` which US1 also touches — do US1 first to avoid rebasing its row-tap/row-action changes under US2's filter-panel edit.
- **US3 (P2)**: No dependency on US1/US2; its FR-012/FR-013 portion is already satisfied by Foundational.
- **US4 (P3)**: No dependency on US1/US2/US3, but shares `product_detail_screen.dart` with all three — sequencing after them avoids repeated merge conflicts in the same file.
- **US5 (P3)**: No dependency on other stories except the shared photo column with US6.
- **US6 (P3)**: Depends on US5's column-width adjustment (T052) landing first.

### Within Each User Story

- Shared/core widget changes before the screens that consume them.
- l10n keys before the screen code that references them.
- Repository/controller changes before the UI that calls them.
- Tests updated alongside (or immediately after) the implementation they cover.
- Manual quickstart validation is the story's completion checkpoint.

### Parallel Opportunities

- Within **US1**, T011, T012, and T013 are mutually independent and can run in parallel.
- T014 and T015 (products vs. users list) can run in parallel once T011/T012 land.
- T016 and T017 (product vs. user detail screen) can run in parallel once T013 lands.
- All test-update tasks marked [P] within a phase can run in parallel with each other.
- T007/T008/T009 (Foundational tests) can run in parallel with each other.

---

## Parallel Example: User Story 1

```bash
# Once Foundational (Phase 2) is done, these three can start together:
Task: "Remove frozen-column logic in lib/core/widgets/data_table_view.dart"
Task: "Reduce buildCatalogRowActions to Edit-only in lib/core/widgets/catalog_action_icons.dart"
Task: "Add viewProductTitle/viewUserTitle l10n keys"

# Then, once those land, these two can run together:
Task: "Update products_list_screen.dart (view-on-tap, Edit-only actions)"
Task: "Update users_list_screen.dart (view-on-tap, Edit-only actions)"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup) and Phase 2 (Foundational — unblocks the build).
2. Complete Phase 3 (US1).
3. **STOP and VALIDATE**: run quickstart.md US1 steps independently.
4. This alone ships the biggest risk reduction (safe-by-default row clicks) across every catalog/list screen.

### Incremental Delivery

1. Setup + Foundational → build is green.
2. US1 → validate → ship (MVP).
3. US2 → validate → ship.
4. US3 → validate → ship.
5. US4 → validate → ship.
6. US5 → US6 (order matters, shared column) → validate → ship.
7. Polish (rename, DESIGN.md, final full-repo verification) → ship.

### Solo/Small-Team Strategy

Given the file overlaps noted above, prefer sequencing by priority over parallel team assignment unless deliberately coordinating around shared files (`product_detail_screen.dart`, `products_list_screen.dart`). Tasks marked `[P]` within a phase are safe to interleave regardless.

---

## Notes

- `[P]` tasks touch different files with no unresolved dependency on an incomplete task.
- `[Story]` labels map every user-story-phase task back to spec.md's US1–US6 for traceability.
- Phase 2 (Foundational) is unusually load-bearing for this feature: it isn't just infrastructure scaffolding, it's an active build break inherited from a sibling repo (`mbe-api`) — see plan.md's Pre-Implementation Note.
- FR-011's supplier-*clear* capability is intentionally not a task here — see T037 and plan.md's Complexity Tracking; it requires an mbe-api change out of this feature's scope.
- Commit after each task or logical group; stop at any **Checkpoint** to validate a story independently before moving on.
