---
description: "Task list for Catalog UI/Layout Improvements"
---

# Tasks: Catalog UI/Layout Improvements

**Input**: Design documents from `/specs/006-catalog-ui-improvements/`

**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ui-components.md ✅

**Tests**: Included — this is presentation-only work over screens that already have widget/unit
tests, and plan.md §Testing requires those tests be updated (facet chips move into a sheet;
the responsive form must be verified). These test tasks are therefore **required**, not
optional TDD.

**Organization**: Grouped by user story. US1 (filtering) and US2/US3 (detail layout) touch
**disjoint files** and can be delivered fully independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1, US2, US3 (maps to spec.md user stories)
- Exact file paths included in every task

## Path Conventions

Single Flutter project, feature-first (plan.md §Project Structure):
`lib/core/`, `lib/features/catalog/presentation/`, `lib/l10n/`, `test/`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish a green baseline before layout changes.

- [ ] T001 Run the existing catalog tests to confirm a green baseline before any change: `flutter test test/widget/features/catalog/ test/unit/features/catalog/` and record which tests currently pass (they will be intentionally updated in later phases).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Cross-story prerequisites.

**None.** The two user stories are independent and modify disjoint files:
US1 → `products_list_screen.dart` + `products_list_controller.dart` + list l10n + list tests;
US2/US3 → `product_detail_screen.dart` + `breakpoints.dart` + `responsive_form_grid.dart` +
detail tests. There is no shared blocking work, so user-story phases may begin immediately
after Setup and may proceed in parallel.

**Checkpoint**: Foundation ready (trivial) — user stories can begin.

---

## Phase 3: User Story 1 - Decluttered product-list filtering (Priority: P1) 🎯 MVP

**Goal**: Replace the inline filter chips/dropdown with a single **Filters** button carrying an
active-filter count badge that opens a responsive sheet (bottom on compact, right side sheet on
expanded) holding all facets, with **Clear all** and **Apply/Done**. Filtering stays live.

**Independent Test**: Load the products list → only the search box + a Filters button show; tap
it → the sheet opens with all facets; toggle facets → list updates live and the badge count
matches; Clear all resets facets and removes the badge while preserving search text.

### Implementation for User Story 1

- [ ] T002 [P] [US1] Add filter-panel localized strings (`filtersButton`, `filtersTooltip`, `clearAllFilters`, `applyFilters`) with `@`-metadata to `lib/l10n/app_en.arb`.
- [ ] T003 [P] [US1] Add the Spanish translations of the same four keys to `lib/l10n/app_es.arb` (e.g. "Filtros", "Filtrar", "Limpiar filtros", "Aplicar").
- [ ] T004 [US1] Add an `extension ProductFilterBadge on ProductFilter` with `int get activeFilterCount` and `bool get hasActiveFilters` to `lib/features/catalog/presentation/products_list_controller.dart`, per the count definition in data-model.md (facets only; search excluded; `deactivated == false` counts as active).
- [ ] T005 [US1] Add `ProductFilterController.reset()` to `lib/features/catalog/presentation/products_list_controller.dart` that clears all facets while preserving `search` (`state = ProductFilter(search: state.search)`).
- [ ] T006 [US1] Create the shared launcher `showCatalogFilterSheet(context, {title, builder, onClearAll})` in `lib/core/widgets/catalog_filter_sheet.dart`: `showModalBottomSheet` (drag handle, scrollable) when width `< LayoutBreakpoints.expanded`, else a right-anchored modal side sheet via `showGeneralDialog` (~360dp, scrim, slide-from-right, Escape-to-close); footer with Clear all (calls `onClearAll`) and an Apply/Done button that pops. Contract in contracts/ui-components.md §1.
- [ ] T007 [US1] Rewire `lib/features/catalog/presentation/products_list_screen.dart`: replace the `CatalogFilterBar` `filters:` list with a single Filters `IconButton` (new key `products_filter_button`) wrapped in an M3 `Badge` showing `filter.activeFilterCount` (badge hidden when 0); on press call `showCatalogFilterSheet`, whose `builder` renders the existing show-inactive `FilterChip`, the three `_TriStateFilterChip`s, and the label `DropdownButton` — **all existing keys unchanged** (`products_filter_show_inactive`, `products_filter_stockable`, `products_filter_salable`, `products_filter_purchasable`, `products_filter_label`); wire `onClearAll` to `filterController.reset()`. Keep the search bar in the bar.
- [ ] T008 [US1] Update `test/widget/features/catalog/products_list_screen_test.dart`: assert `products_search_field` + `products_filter_button` are present initially and facet chips are **not**; tap the button, then assert each facet chip is findable and the tri-state cycle test still passes (opening the sheet first); add a test that N active facets render a `Badge`/count of N and that Clear all resets facets + removes the badge.
- [ ] T009 [P] [US1] Add unit tests to `test/unit/features/catalog/products_list_controller_test.dart` for `ProductFilter.activeFilterCount`/`hasActiveFilters` across representative states and for `reset()` clearing facets while preserving `search`.

**Checkpoint**: US1 fully functional and independently testable — MVP deliverable.

---

## Phase 4: User Story 2 - Responsive multi-column product form (Priority: P2)

**Goal**: Constrain the product form to a max content width and lay fields out in 1/2/3 columns
by breakpoint tier, preserving all fields, order, validation, keys, and read-only behavior.

**Independent Test**: Open a product for edit at ≥1200px → 3 columns within a centered
max-width container; resize to ~900px → 2 columns; <600px → 1 column; no horizontal scroll;
errors render in-grid; view mode keeps the same layout with fields disabled.

### Implementation for User Story 2

- [ ] T010 [US2] Extend `lib/core/layout/breakpoints.dart`: add `static const double large = 1200`, add `LayoutTier.large` to the enum, update `tierOf` to return `LayoutTier.large` for `width >= large`, and add `isLarge(context)`. Audit every `LayoutTier`/`tierOf`/`isExpanded` call site (notably `lib/core/widgets/catalog_filter_bar.dart`) so the new value is handled correctly (no non-exhaustive `switch`).
- [ ] T011 [P] [US2] Create the shared `ResponsiveFormGrid`, `FormGridChild`, and `FormGridSpan` in `lib/core/widgets/responsive_form_grid.dart` per contracts/ui-components.md §2: `LayoutBuilder` + `Wrap`, columns from `LayoutBreakpoints.tierOf` (compact→1, medium/expanded→2, large→3), `single` cells sized `(inner - spacing*(cols-1))/cols`, `full` cells span the row, centered inside `ConstrainedBox(maxWidth: maxContentWidth)`, no horizontal scroll.
- [ ] T012 [US2] Rewire the field section of `lib/features/catalog/presentation/product_detail_screen.dart` to use `ResponsiveFormGrid`: wrap the single-column text fields/pickers as `single` children and the multiline comment field, section headers, switches, prices, and labels blocks (and the save button) as `full` children; keep every existing `Key`, `enabled`/read-only gating, `errorText`, and error banner intact (FR-010, FR-013).
- [ ] T013 [US2] Update `test/widget/features/catalog/product_detail_screen_test.dart`: pump at a wide viewport (`tester.view.physicalSize`/`devicePixelRatio`) and assert the form renders with all field keys present and editable/disabled per mode; assert no `RenderFlex`/overflow errors; confirm a triggered validation error still displays. Keys unchanged.

**Checkpoint**: US1 and US2 both work independently.

---

## Phase 5: User Story 3 - Photo thumbnail with inline actions (Priority: P3)

**Goal**: Place the photo's Change/Remove/Upload actions beside the thumbnail on the same row
(stacking on compact), reclaiming the wasted row; preserve keys, gating, and error display.

**Independent Test**: Edit a product with a photo → Change/Remove appear beside the thumbnail;
without a photo → Upload beside the placeholder; compact width → actions may stack; view mode →
no actions; upload/replace/remove still work and photo errors still show.

### Implementation for User Story 3

- [ ] T014 [US3] Restructure the photo area in `lib/features/catalog/presentation/product_detail_screen.dart` from the centered `Column` to a `Row` (thumbnail + a `Column`/`Wrap` of actions beside it), falling back to stacked layout at compact width to avoid overflow; preserve keys `upload_photo_button`/`replace_photo_button`/`remove_photo_button`, the `canEditPhoto`/`hasPhoto` gating, read-only behavior (no actions), and the photo field-error text placement.
- [ ] T015 [US3] Extend `test/widget/features/catalog/product_detail_screen_test.dart` to assert the photo action buttons render beside the thumbnail in edit mode (with/without an existing photo), are absent in read-only mode, and still respond. (Same file as T013 — run after it.)

**Checkpoint**: All three stories independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T016 [P] Run `dart analyze` and `dart format` on all changed/new files; resolve any warnings.
- [ ] T017 Verify FR-015: grep `lib/features/catalog/presentation/` for hardcoded breakpoint widths (e.g. `600`, `840`, `1200`) and confirm all responsive decisions route through `LayoutBreakpoints`.
- [ ] T018 Run the full validation guide in quickstart.md (automated tests + manual US1/US2/US3 resize checks) and confirm SC-001..SC-006, including zero behavior regressions in existing product create/view/edit/deactivate and photo flows.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: none — start immediately.
- **Foundational (Phase 2)**: empty — does not block anything.
- **User Stories (Phase 3–5)**: each depends only on Setup. US1 is fully independent of US2/US3
  (disjoint files). US3 shares `product_detail_screen.dart` and its test file with US2, so US3
  runs **after** US2 on those files.
- **Polish (Phase 6)**: after the desired stories are complete.

### User Story Dependencies

- **US1 (P1)**: independent — MVP.
- **US2 (P2)**: independent of US1.
- **US3 (P3)**: independent of US1; sequenced after US2 because both edit
  `product_detail_screen.dart` and `product_detail_screen_test.dart`.

### Within Each User Story

- US1: l10n (T002/T003) and controller getters/reset (T004/T005) before the screen rewire
  (T007, needs the badge count + reset); the shared sheet (T006) before T007; tests (T008/T009)
  after implementation.
- US2: breakpoints (T010) and the grid widget (T011) before the screen rewire (T012); test
  (T013) last.
- US3: screen change (T014) before its test (T015).

### Parallel Opportunities

- T002 and T003 (two different `.arb` files) are [P].
- T004 and T005 touch the same file → sequential.
- T006 (new `catalog_filter_sheet.dart`) is [P] with the l10n and controller tasks.
- T009 (unit test, separate file) is [P] with other US1 work once T004/T005 land.
- T011 (new `responsive_form_grid.dart`) is [P] with T010.
- Across teams: one developer can own US1 while another owns US2→US3 concurrently.

---

## Parallel Example: User Story 1

```bash
# These touch different files and can run together:
Task T002: Add EN filter strings in lib/l10n/app_en.arb
Task T003: Add ES filter strings in lib/l10n/app_es.arb
Task T006: Create lib/core/widgets/catalog_filter_sheet.dart
# Then, after T004/T005 (controller) land:
Task T009: Unit tests in test/unit/features/catalog/products_list_controller_test.dart
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Phase 1 Setup → 2. (Foundational is empty) → 3. Phase 3 (US1) → **STOP & VALIDATE** the
   decluttered filtering independently → demo. This alone resolves the primary "cluttered
   filter bar" complaint.

### Incremental Delivery

1. US1 → test → demo (MVP). 2. US2 (responsive form) → test → demo. 3. US3 (inline photo
   actions) → test → demo. Each story ships without breaking the others.

### Parallel Team Strategy

- Developer A: US1 (list screen + controller + list tests).
- Developer B: US2 then US3 (detail screen + breakpoints + grid widget + detail tests).
- Integrate independently; only shared surface is `lib/core/` (new files + additive breakpoint
  change), which does not conflict.

---

## Notes

- [P] = different files, no incomplete-task dependency.
- No `build_runner`/codegen needed: `activeFilterCount`/`hasActiveFilters` are an **extension**
  (no freezed regen), `reset()` composes `copyWith`, and no new provider is added.
- Preserve **all** existing widget keys, RBAC gating, localized strings, error banners, and
  read-only behavior throughout (FR-013).
- Commit after each task or logical group; stop at any checkpoint to validate a story.
