---
description: "Task list for Faceted Label Filtering (spec 009)"
---

# Tasks: Faceted Label Filtering

**Input**: Design documents from `/specs/009-label-filter-facets/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Included — the plan's Testing section explicitly requests widget/unit/integration tests.

**Organization**: Grouped by user story (US1–US3 from spec.md) for independent implementation and testing.

**External dependency status**: [mictlanix/mbe-api#78](https://github.com/mictlanix/mbe-api/issues/78) (`GET /api/v1/products/labels/facets`) is **RESOLVED and the client is regenerated** (commit `7e9446a` — `ProductLabelFacet` model + `getProductLabelFacetsApiV1ProductsLabelsFacetsGet`). All tasks below are unblocked.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: US1 / US2 / US3 (Setup, Foundational, Polish carry no story label)
- File paths are relative to the repo root.

## Path Conventions

Single Flutter app, feature-first layered: `lib/features/catalog/{domain,data,presentation}/`, shared `lib/core/widgets/`, generated client under `lib/generated/openapi/`, tests under `test/`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the regenerated client surface is present before wiring against it.

- [ ] T001 Confirm the regenerated `mbe_api_client` exposes `ProductLabelFacet` (`label_id`, `count`) and `ProductsApi.getProductLabelFacetsApiV1ProductsLabelsFacetsGet({search,label,deactivated,stockable,salable,purchasable,supplier})` in `lib/generated/openapi/lib/src/model/product_label_facet.dart` and `lib/generated/openapi/lib/src/api/products_api.dart` (committed in `7e9446a`); no codegen re-run needed if present.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain/data/provider plumbing shared by US2 and US3. (US1 does not depend on this phase.)

**⚠️ CRITICAL**: US2 and US3 cannot begin until this phase is complete.

- [ ] T002 [P] Create `ProductLabelFacet` freezed domain entity (`labelId`, `count`; `fromResponse(api.ProductLabelFacet)` via `mbe_api_client as api` to avoid the name collision) in `lib/features/catalog/domain/entities/product_label_facet.dart` (data-model.md "ProductLabelFacet").
- [ ] T003 Add `Future<List<ProductLabelFacet>> productLabelFacets({search, deactivated, stockable, salable, purchasable, labels})` to the `ProductRepository` interface in `lib/features/catalog/domain/repositories/product_repository.dart` (contracts/product-repository.md).
- [ ] T004 Implement `productLabelFacets()` in `lib/features/catalog/data/product_repository_impl.dart`: extend the `mbe_api_client` import to `hide ProductLabelFacet, ProductListItem`, call `getProductLabelFacetsApiV1ProductsLabelsFacetsGet` (send `label: labels.isEmpty ? null : BuiltList<int>(labels)`), map rows via `ProductLabelFacet.fromResponse`, return `const []` on null body, reuse `_toAppError` on `DioException` (contracts/product-repository.md).
- [ ] T005 Add the autodispose `@riverpod Future<Set<int>> productLabelFacets(...)` provider (watches `productFilterControllerProvider`, calls `productRepositoryProvider.productLabelFacets`, reduces to a label-id `Set<int>`) in `lib/features/catalog/presentation/products_list_controller.dart` (data-model.md, research.md §4/§5).
- [ ] T006 Run `dart run build_runner build --delete-conflicting-outputs` to generate `product_label_facet.freezed.dart` and refresh `products_list_controller.g.dart` (new `productLabelFacetsProvider`/`ProductLabelFacetsRef`).

**Checkpoint**: Repository + provider compile; availability data is fetchable.

---

## Phase 3: User Story 1 - Narrow products by combining labels (Priority: P1) 🎯 MVP

**Goal**: Confirm and document that combining labels narrows via AND ("contains all"). Behavior already ships server-side and mbe-ui already sends every selected label; this story corrects the stale "OR" docs and locks the behavior with a test.

**Independent Test**: With P1={A,B}, P2={A}: selecting A lists P1+P2; also selecting B lists only P1 (see quickstart US1).

- [ ] T007 [US1] Correct the stale "OR semantics" docstring on `ProductRepository.list` (state AND / "contains all", server-side since 2026-07-05) in `lib/features/catalog/domain/repositories/product_repository.dart`; sweep for any other "OR"/"match any" label wording in `lib/features/catalog/` and align it to AND (contracts/product-repository.md "Docstring correction").
- [ ] T008 [P] [US1] Widget/unit regression test asserting multi-label selection narrows (AND): selecting a second label yields a subset of the single-label result, in `test/features/catalog/products_and_label_filter_test.dart` (spec FR-001/FR-002, SC-003).

**Checkpoint**: AND narrowing is documented accurately and covered by a test; MVP behavior verified.

---

## Phase 4: User Story 2 - See which labels still narrow the results (Priority: P2)

**Goal**: After each filter change, disable label chips that no product in the current filtered set carries; selected chips stay interactive; fail open on loading/error.

**Independent Test**: With P1={Trupper,DeWalt}, P2={Trupper}, P3={Makita}: select Trupper → DeWalt enabled, Makita disabled, Trupper still deselectable (see quickstart US2).

**Depends on**: Phase 2 (entity/repo/provider).

- [ ] T009 [US2] Extend `LabelMultiPicker` with an optional `Set<int>? availableIds` param and per-chip enabled logic `enabled && (availableIds == null || selectedIds.contains(id) || availableIds!.contains(id))`; disabled chips use native `onSelected: null` in `lib/core/widgets/label_multi_picker.dart` (contracts/ui-contracts.md, FR-004/FR-006/FR-010).
- [ ] T010 [US2] Add a localized disabled-chip tooltip key (es default: "Sin productos que coincidan"; en: "No matching products") to `lib/l10n/app_es.arb` + `lib/l10n/app_en.arb`, regenerate localizations, and apply it as a `Tooltip` on disabled chips in `label_multi_picker.dart` (constitution §V, research §7).
- [ ] T011 [US2] Wire availability into the drawer: in `_ProductFiltersPanel`, `ref.watch(productLabelFacetsProvider).valueOrNull` and pass it as `availableIds:` to the existing `LabelMultiPicker` (null → all enabled) in `lib/features/catalog/presentation/products_list_screen.dart` (contracts/ui-contracts.md, FR-003/FR-010).
- [ ] T012 [P] [US2] Unit test `ProductRepositoryImpl.productLabelFacets`: filter params forwarded, rows mapped to entities, null body → `[]`, `DioException` → mapped `AppError`, with the API client mocked, in `test/features/catalog/product_repository_facets_test.dart`.
- [ ] T013 [P] [US2] Unit test `productLabelFacetsProvider`: maps response to id set and refetches when `ProductFilter` changes, with the repository overridden, in `test/features/catalog/product_label_facets_provider_test.dart`.
- [ ] T014 [P] [US2] Widget test `LabelMultiPicker` availability: with `availableIds` given, selected + available chips interactive and others disabled; a selected-but-unavailable chip stays interactive; `availableIds == null` → all interactive, in `test/core/widgets/label_multi_picker_test.dart`.
- [ ] T015 [P] [US2] Widget test `_ProductFiltersPanel` wiring with `productLabelFacetsProvider` overridden: loading/error → all chips enabled (fail open); data set → correct chips disabled, in `test/features/catalog/product_filters_panel_facets_test.dart`.

**Checkpoint**: Selecting a label greys out non-co-occurring labels; failures never block filtering.

---

## Phase 5: User Story 3 - Recover and reset the label selection (Priority: P3)

**Goal**: Deselecting a label and "Clear all" broaden the results and re-enable the labels that become applicable again.

**Independent Test**: From a narrowed state, deselect one label → previously-disabled co-occurring labels re-enable; "Clear all" → every applicable label re-enabled (see quickstart US3).

**Depends on**: Phase 4 (the availability wiring is what re-enables reactively).

- [ ] T016 [US3] Verify "Clear all" (`ProductFilterController.reset`, preserving search) and single-label deselect both drive a `productLabelFacetsProvider` refetch; add the missing wiring only if a gap is found (expected: none — the provider already re-runs on `ProductFilter` change) in `lib/features/catalog/presentation/products_list_controller.dart` / `products_list_screen.dart` (FR-007/FR-008).
- [ ] T017 [P] [US3] Widget test: deselecting a label re-enables co-occurring labels and "Clear all" restores the all-enabled drawer (subject to remaining search/attribute filters), in `test/features/catalog/product_filters_reset_test.dart` (SC-005).

**Checkpoint**: Users can always broaden back out in one interaction.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T018 [P] Run `flutter analyze` and resolve any warnings introduced by this feature.
- [ ] T019 [P] Add/refresh the integration test for the faceted-narrowing golden path against a test mbe-api (drawer open → select → chips disable → clear) in `integration_test/` (plan Testing; run when a test mbe-api with #78 is available).
- [ ] T020 Execute the `quickstart.md` manual validation (US1–US3 + fail-open) against an mbe-api that has #78.
- [ ] T021 [P] Update `specs/009-label-filter-facets/spec.md` Status to reflect completion and note any deviations discovered during implementation.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: none — start immediately.
- **Foundational (Phase 2)**: after Setup. Blocks US2 and US3. (US1 is independent of it.)
- **US1 (Phase 3)**: after Setup — needs neither the entity nor the provider (docs + AND regression test only).
- **US2 (Phase 4)**: after Foundational.
- **US3 (Phase 5)**: after US2 (re-enable behavior is emergent from US2's wiring).
- **Polish (Phase 6)**: after all targeted stories.

### User Story Dependencies

- **US1 (P1)**: independent; can proceed in parallel with Phase 2.
- **US2 (P2)**: depends on Foundational (Phase 2).
- **US3 (P3)**: depends on US2 (Phase 4).

### Within Each Story

- Foundational: T002 → T003 → T004 (same file after T003) → T005 → T006 (codegen after entity+provider exist).
- US2: T009 before T010/T011 (picker param must exist); tests T012–T015 [P] after their targets exist.
- Verify tests fail before implementing where practical.

### Parallel Opportunities

- T002 (entity) is [P] relative to T007 (US1 docs) — different concerns, though both touch domain; sequence T003/T007 in `product_repository.dart` (not parallel — same file).
- US2 test tasks T012, T013, T014, T015 are all [P] (distinct test files) once their targets compile.
- US1 (T007–T008) can run alongside Phase 2 by a second contributor.

---

## Parallel Example: User Story 2 tests

```bash
# After T009–T011 land, run these in parallel (distinct files):
Task: "Unit test ProductRepositoryImpl.productLabelFacets in test/features/catalog/product_repository_facets_test.dart"   # T012
Task: "Unit test productLabelFacetsProvider in test/features/catalog/product_label_facets_provider_test.dart"             # T013
Task: "Widget test LabelMultiPicker availability in test/core/widgets/label_multi_picker_test.dart"                       # T014
Task: "Widget test _ProductFiltersPanel wiring in test/features/catalog/product_filters_panel_facets_test.dart"           # T015
```

---

## Implementation Strategy

### MVP First

1. Phase 1 Setup → Phase 3 US1 (docs + AND regression test). Ships an accurate, tested AND-narrowing baseline.
2. **STOP and VALIDATE**: quickstart US1.

### Incremental Delivery

1. Setup + Foundational → provider fetchable.
2. US1 → accurate docs + AND test (MVP).
3. US2 → the faceted enable/disable (the headline feature) → validate quickstart US2 + fail-open.
4. US3 → recover/reset → validate quickstart US3.
5. Polish → analyze, integration test, quickstart, status.

---

## Notes

- [P] = different files, no dependency on an incomplete task.
- The whole feature is unblocked: #78 shipped and the client is regenerated (`7e9446a`).
- Fail-open is the critical safety property (FR-010) — assert it explicitly in T015.
- Commit after each task or logical group; the spec-kit `after_*` git hooks may auto-commit.
