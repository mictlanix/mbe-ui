---
description: "Task list for Merge Products"
---

# Tasks: Merge Products

**Input**: Design documents from `/specs/008-merge-products/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/)

**Tests**: Included — the plan's Testing section, quickstart's automated-coverage list, and constitution §"Development Workflow & Quality Gates" require unit + widget + integration tests for this feature.

**Organization**: Grouped by user story (spec priorities). US1 is the MVP and, because US2–US4 all edit the same `merge_products_screen.dart` / router / list screen, US1's screen must exist before US2–US4 layer onto it (see Dependencies).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: US1–US4 (maps to spec user stories); Setup/Foundational/Polish carry no story label

## Path Conventions

Single Flutter app, feature-first layered: `lib/features/catalog/…`, shared `lib/core/…`, `lib/app/router/…`, `lib/l10n/…`, tests under `test/{unit,widget,integration}/…` (mirrors existing catalog tests).

---

## Phase 1: Setup

**Purpose**: Confirm preconditions; no scaffolding beyond verification.

- [X] T001 Verify no codegen is needed: confirm `mergeProductsApiV1ProductsMergePost` and `ProductMergeRequest` exist in `lib/generated/openapi/lib/src/api/products_api.dart` and `.../model/product_merge_request.dart` (research §1). If absent, stop and re-run OpenAPI codegen before proceeding.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Repository method, state/controller, and localization that every UI story depends on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T002 Add `Future<void> mergeProducts({required int productId, required int duplicateId})` to the domain interface in `lib/features/catalog/domain/repositories/product_repository.dart` with the doc/error contract from [contracts/product-repository.md](./contracts/product-repository.md).
- [X] T003 Implement `mergeProducts()` in `lib/features/catalog/data/product_repository_impl.dart` calling `_api.mergeProductsApiV1ProductsMergePost(productMergeRequest: ProductMergeRequest((b) => b..productId = …..duplicateId = …))`, wrapping `DioException` via the existing `_toAppError` (no body/`204` handling needed).
- [X] T004 [P] Add merge localization keys to `lib/l10n/app_es.arb` (default) and `lib/l10n/app_en.arb`, then regenerate (`flutter gen-l10n`): `mergeProductsTitle`, `mergeProductLabel` ("Producto"), `duplicatedLabel` ("Duplicado"), `mergeButton` ("Fusionar"), `mergeProductsTooltip`, `mergeBothRequiredMessage`, `mergeSameProductMessage`, `mergeConfirmTitle`, `mergeConfirmMessage` (params: canonical name, duplicate name; state permanence), `mergeSuccess`, `mergeBackTooltip`. Follow the existing `deleteProductConfirm*` key style.
- [X] T005 [P] Create `MergeProductsState` in `lib/features/catalog/presentation/merge_products_state.dart` (fields `canonical`/`duplicate: ProductListItem?`, `submission: AsyncValue<void>`; derived `bothSelected`/`isSameProduct`/`canSubmit`; validation message selector) per [data-model.md](./data-model.md).
- [X] T006 Create `MergeProductsController` (Riverpod `Notifier<MergeProductsState>`) + `mergeProductsControllerProvider` in `lib/features/catalog/presentation/merge_products_controller.dart`: `canonicalSelected`/`duplicateSelected`/`canonicalCleared`/`duplicateCleared`/`submit()`; `submit()` guards on `canSubmit`, sets `AsyncLoading`, calls `mergeProducts(...)`, sets `AsyncData` on success and `AsyncError(AppError)` on failure **without** clearing selections (FR-011). Depends on T002/T005.
- [X] T007 [P] Unit test `ProductRepositoryImpl.mergeProducts` in `test/unit/features/catalog/product_repository_impl_test.dart` (extend): success (`204`), 400 self-merge → `ServerError(statusCode:400)`, 404 → `NotFoundError`, network → `NetworkError`, with the API client mocked. Depends on T003.
- [X] T008 [P] Unit test `MergeProductsController` in `test/unit/features/catalog/merge_products_controller_test.dart`: selection transitions, `canSubmit`/validation-message rules, submit success (`AsyncData`), submit failure preserves selections. Depends on T006.

**Checkpoint**: Repository + controller + l10n ready — the screen can be built.

---

## Phase 3: User Story 1 - Fuse a confirmed duplicate into the canonical product (Priority: P1) 🎯 MVP

**Goal**: A working Merge Products screen: pick canonical + duplicate, confirm permanence, submit, succeed, return to the list.

**Independent Test**: Pump `MergeProductsScreen` with a fake repository; select two distinct products, confirm the dialog, submit — the repository is called with the right ids, a success confirmation shows, and the screen navigates back.

- [X] T009 [US1] Create `MergeProductsScreen` in `lib/features/catalog/presentation/merge_products_screen.dart`: app bar (`mergeProductsTitle`) with a back affordance (`Key('merge_back_button')`) that returns to `/products` without merging (FR-013), two `CatalogEntityPicker<ProductListItem>` (`Key('merge_canonical_field')`, `Key('merge_duplicate_field')`) whose `optionsBuilder` returns `[]` for queries under 3 chars else `(await productRepository.list(search: q.trim(), deactivated: null, limit: 15)).items`, `displayStringForOption` = name, `onSelected` → controller; laid out using the shared `core/widgets/responsive_form_grid.dart` (single column, width-capped) per §VI. Text-only options for now (photos added in US2).
- [X] T010 [US1] Add the permanence confirm dialog (inline `showDialog<bool>` + `AlertDialog`, mirroring `product_detail_screen._confirmDelete`) gating submit: `mergeConfirmTitle`/`mergeConfirmMessage`, error-styled confirm (`Key('merge_confirm_button')`), cancel (`Key('merge_confirm_cancel_button')`); only on `true` call `controller.submit()`. In `merge_products_screen.dart`.
- [X] T011 [US1] Add the merge submit button (`Key('merge_submit_button')`, `mergeButton`) that opens the confirm dialog, disabled unless `state.canSubmit`, showing progress while `state.submission.isLoading` (FR-009); in `merge_products_screen.dart`.
- [X] T012 [US1] Wire success handling: `ref.listen` the controller's `submission` for the success edge → show `mergeSuccess` SnackBar and `context.go('/products')` (FR-010); in `merge_products_screen.dart`.
- [X] T013 [P] [US1] Widget test `test/widget/features/catalog/merge_products_screen_test.dart`: with a fake repo, select two distinct products, tap Merge, confirm → repo `mergeProducts` called with correct `(productId, duplicateId)`, success SnackBar shown, navigation invoked; in-flight state disables the button; tapping the back affordance (`Key('merge_back_button')`) navigates to `/products` without calling `mergeProducts`.
- [X] T014 [P] [US1] Integration test in `test/integration/product_merge_flow_test.dart`: golden-path merge (select → confirm → success → back to list) against the test flow harness used by `product_catalog_flow_test.dart`.

**Checkpoint**: US1 is a functional, independently-testable MVP (text pickers).

---

## Phase 4: User Story 2 - Find the two products by searching as you type (Priority: P2)

**Goal**: Rich picker suggestions — photo thumbnail + name/code/model — with min-length and no-results behavior.

**Independent Test**: Type ≥3 chars in a picker → suggestions show a photo + name + code/model; typing <3 chars shows none; a no-match term shows a no-results state; selecting fills the field (single-select) and it can be cleared.

- [X] T015 [US2] Extend the shared `CatalogEntityPicker<T>` in `lib/core/widgets/catalog_entity_picker.dart` with optional `String? Function(T)? optionImageUrl` and `String? Function(T)? optionSubtitle`; when either is set, supply a custom `Autocomplete.optionsViewBuilder` rendering each option as a `ListTile` (leading `ProductPhoto`/thumbnail, title `displayStringForOption`, subtitle `optionSubtitle`); when both null, keep today's text-only behavior. Per [contracts/ui-contracts.md](./contracts/ui-contracts.md) §1.
- [X] T016 [US2] Wire both merge pickers to the new params in `merge_products_screen.dart`: `optionImageUrl: (p) => p.photo`, `optionSubtitle: (p) => code/model/sku`; verify min-length and no-results UX. **SKU resolved**: [mictlanix/mbe-api#76](https://github.com/mictlanix/mbe-api/issues/76) landed; the client was regenerated (`tool/generate_api_client.sh`), `sku` added to the domain `ProductListItem`, and the subtitle extended to include it (`"${code} · ${model} · ${sku}"`, blank parts omitted). Depends on T009, T015.
- [X] T017 [P] [US2] Widget test `test/widget/core/widgets/catalog_entity_picker_test.dart`: photo/subtitle option rendering when params supplied; unchanged text-only path when omitted (guards the existing supplier/SAT pickers). Depends on T015.
- [X] T018 [P] [US2] Widget test (extend `merge_products_screen_test.dart`): <3-char query yields no options; ≥3-char query maps `list()` results into suggestions with photo/subtitle, including a deactivated product returned by the fake repo (asserting the picker calls `list(..., deactivated: null, ...)` and surfaces it — spec Clarifications 2026-07-12); single-select + clear behavior. Depends on T016.

**Checkpoint**: US1 + US2 both work; pickers are visually confirmable.

---

## Phase 5: User Story 3 - Be protected from an irreversible mistake (Priority: P2)

**Goal**: Client guards (both-required, self-merge) and server-error recovery that preserves selections.

**Independent Test**: Empty or same-product selections block submit with a clear message and submit nothing; a forced server rejection shows an error and keeps both selections; cancelling the confirm dialog is a no-op.

- [X] T019 [US3] Add inline validation display (`Key('merge_validation_message')`) in `merge_products_screen.dart` showing `state.validationMessage` (both-required / self-merge) and keeping the submit button disabled accordingly (uses controller derived props from T005/T006).
- [X] T020 [US3] Add the shared `error_banner` (`Key('merge_error_banner')`) shown when `state.submission` is `AsyncError`, rendering the mapped `AppError` message; confirm the error path preserves `canonical`/`duplicate` (FR-011); in `merge_products_screen.dart`.
- [X] T021 [P] [US3] Widget test (extend `merge_products_screen_test.dart`): empty-selection and same-product cases keep submit disabled with the right message and never call the repo; a fake repo error surfaces the banner while both fields stay populated; cancelling the confirm dialog performs no merge. Depends on T019, T020.

**Checkpoint**: US1–US3 functional; the destructive action is safe.

---

## Phase 6: User Story 4 - Only authorized users can reach the tool (Priority: P3)

**Goal**: Route + entry point gated on `productsMerge`/Create, denied by default.

**Independent Test**: With the privilege, the list shows the Merge entry point and the route renders; without it, the entry point is hidden and direct navigation to `/products/merge` redirects to `/`.

- [X] T022 [US4] Register the `GoRoute` for `/products/merge` → `MergeProductsScreen` in `lib/app/router/app_router.dart`, placed above `/products/:productId` (contracts/routes.md).
- [X] T023 [US4] Gate the route on `productsMerge`/Create: refactor `_routeSystemObject` into a per-route `(SystemObject, AccessRight)` gate (default Read for existing routes) that returns `(SystemObject.productsMerge, AccessRight.create)` for `/products/merge` matched **before** the generic `/products` rule, and update `_redirect` to use the returned right; in `lib/app/router/app_router.dart`. Depends on T022.
- [X] T024 [US4] Add the Merge entry point to the app-bar `actions` in `lib/features/catalog/presentation/products_list_screen.dart` (`Key('merge_products_button')`, `Icons.merge`, tooltip `mergeProductsTooltip`), shown only when `access.can(SystemObject.productsMerge, AccessRight.create)`, `onPressed: () => context.push('/products/merge')`.
- [X] T025 [P] [US4] Tests: extend `test/widget/features/catalog/products_list_screen_test.dart` (entry point visible with privilege, hidden without) and add router redirect tests (`test/unit/app/router/…` or existing router test) covering (a) `/products/merge` renders with the `productsMerge`/Create privilege and redirects to `/` without it, and (b) a regression check that `/users` and `/products` still gate on `AccessRight.read` exactly as before the T023 refactor. Depends on T023, T024.

**Checkpoint**: All user stories independently functional and access-gated.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T026 [P] Run `dart analyze lib` and `flutter test`; fix any lints/failures introduced by this feature.
- [X] T027 [P] Verify no hardcoded strings (all copy via l10n) and that `flutter gen-l10n` output is committed.
- [X] T028 Execute the [quickstart.md](./quickstart.md) manual walkthrough (US4 → US2 → US3 → US1) against a test mbe-api and record any gaps.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: none.
- **Foundational (Phase 2)**: after Setup — BLOCKS all user stories.
- **User Stories (Phase 3–6)**: all depend on Foundational. Note the intra-file coupling: US2, US3, and US4 all modify `merge_products_screen.dart` (and US4 also the router/list screen), so in practice **US1 (which creates the screen) must land before US2/US3/US4**. They are independently *testable* (each pumps the screen or a target widget directly) but not independently *authorable* on the shared screen file.
- **Polish (Phase 7)**: after the desired stories.

### Within Each User Story

- Foundational: repo (T002→T003) and state→controller (T005→T006) precede their unit tests (T007, T008).
- US1: T009 (screen) → T010/T011/T012 (same file, sequential) → T013/T014 (tests, [P]).
- US2: T015 (picker extension) → T016 (wire, same screen file) → T017/T018 (tests, [P]).
- US3: T019 → T020 (same screen file, sequential) → T021 (test).
- US4: T022 → T023 (same router file) ; T024 (list screen, independent file) ; then T025 (test).

### Parallel Opportunities

- Foundational: T004 (l10n), T005 (state) run in parallel with T002/T003 (repo); T007 and T008 run in parallel once their deps land.
- Within a story, the [P] test tasks run together; T024 (list screen) can proceed in parallel with T022/T023 (router) since they are different files.
- Cross-story parallelism is limited by the shared `merge_products_screen.dart` (see above).

---

## Parallel Example: Foundational

```bash
# After T003 and T006 land, run the two unit test tasks together:
Task: "Unit test ProductRepositoryImpl.mergeProducts (T007)"
Task: "Unit test MergeProductsController (T008)"

# T004 (l10n) and T005 (state) can be authored in parallel with T002/T003 (repo).
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Phase 1 Setup → Phase 2 Foundational (repo + controller + l10n).
2. Phase 3 US1 → a working merge with text pickers.
3. **STOP and VALIDATE**: widget + integration test US1 independently; demo the merge.

### Incremental Delivery

1. Foundational ready.
2. US1 (MVP: functional merge) → validate → demo.
3. US2 (photo-rich pickers) → validate.
4. US3 (guardrails + error recovery) → validate.
5. US4 (RBAC route + entry point) → validate.
6. Polish (analyze/tests/quickstart).

Each story builds on US1's screen without breaking the previous increment.

---

## Notes

- [P] = different files, no incomplete-task dependency.
- The heaviest coupling is `merge_products_screen.dart` (US1 creates it; US2/US3 extend it) — keep those edits sequential.
- No OpenAPI regeneration was in scope for the merge action itself (T001 guarded this). SKU-in-suggestion (FR-003) was a separate, external dependency on [mictlanix/mbe-api#76](https://github.com/mictlanix/mbe-api/issues/76) — it has landed; the client was regenerated and T016's subtitle now includes SKU.
- Commit after each task or logical group; stop at any checkpoint to validate a story independently.
