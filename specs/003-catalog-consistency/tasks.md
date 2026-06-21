---

description: "Task list for Catalog Screen Consistency"

---

# Tasks: Catalog Screen Consistency

**Input**: Design documents from `/specs/003-catalog-consistency/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Included per constitution §"Development Workflow & Quality Gates"
(unit/widget/integration tests are a quality gate, not optional, for this
project). Write each story's tests first; confirm they fail before
implementing.

**Organization**: Tasks are grouped by user story (spec.md priorities
P1/P1/P2/P2) to enable independent implementation and testing of each
story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no unmet dependencies)
- **[Story]**: Maps the task to US1 (Search/page the Users catalog), US2
  (Consistent Create/View/Edit/Delete actions), US3 (Frozen identity
  column), or US4 (Single-row filter layout + explicit-submit search)
- File paths are relative to the repository root

## Path Conventions

Single Flutter project per plan.md "Project Structure": `lib/`, `test/` at
repository root. This feature modifies the shared `lib/core/widgets/`
layer plus the existing `auth` (Users) and `catalog` (Products) feature
modules and `lib/app/router/app_router.dart` — no new top-level
directories or feature modules.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Bring in the new third-party dependency this feature relies
on (plan.md "Technical Context" / research.md §1) before any shared
widget work begins.

- [X] T001 Add `data_table_2` to `pubspec.yaml` `dependencies`, run
  `flutter pub get`, and confirm it resolves cleanly alongside existing
  `flutter_riverpod`/`go_router`/`dio` versions.

**Checkpoint**: `data_table_2` is available for import.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Rewrite/add the shared `core/widgets/` components every user
story depends on (constitution §VI — implemented once, not per screen),
and migrate both existing catalog screens onto the new `DataTableView`
signature so they keep compiling/rendering before story-specific behavior
is layered on.

**⚠️ CRITICAL**: No user story work can begin until this phase is
complete.

- [X] T002 [P] Create `lib/core/widgets/catalog_pagination.dart` defining
  `CatalogPage<T>` (`items`, `total`, `pageIndex`, `pageSize`) — the shared
  state shape `DataTableView` (T003) accepts via its `pagination`
  parameter, replacing the ad hoc "load more" pattern (research.md §2).
  This is a data shape, not a render widget — no UI code in this file
  (depends on T001).
- [X] T003 Rewrite `lib/core/widgets/data_table_view.dart` as the
  single shared table widget: renders `data_table_2`'s `DataTable2` when
  its new optional `pagination` parameter is `null`, or
  `PaginatedDataTable2` when given a `CatalogPage<T>` (T002) — both
  branches honor a `frozen` flag on `DataTableColumn` (`fixedLeftColumns`,
  research.md §1) and ellipsis overflow on non-frozen text columns per the
  existing constitution §VI truncation rule, so frozen columns and
  pagination are never on two different render paths (depends on T001,
  T002).
- [X] T004 [P] Create `lib/core/widgets/catalog_search_bar.dart`: a search
  field exposing only `onSubmitted` (Enter key) and a trailing search
  `IconButton` — no `onChanged` parameter, so per-keystroke filtering
  cannot be wired by a caller (research.md §3, FR-010).
- [X] T005 [P] Create `lib/core/widgets/catalog_filter_bar.dart`: lays out
  a search bar plus facet filter widgets in one `Row` at/above
  `LayoutBreakpoints.expanded` (840px) and in a `Wrap` below it
  (research.md §4, FR-009).
- [X] T006 [P] Create `lib/core/widgets/catalog_action_icons.dart`: a
  `CatalogAction` enum (`create`, `view`, `edit`, `delete`) with the fixed
  icon table from contracts/catalog-action-icons.md and a builder that
  renders row actions in `[view, edit, delete]` order, each conditional on
  an `AccessControlService.can(...)` check passed in by the caller
  (FR-003, FR-004, FR-005, FR-012).
- [X] T007 Migrate `lib/features/catalog/presentation/products_list_screen.dart`
  and `products_list_controller.dart` to the rewritten `DataTableView`'s
  `pagination` parameter, replacing the `_skip`/`loadMore()`
  incremental-fetch pattern with `CatalogPage<ProductListItem>` state
  (data-model.md "CatalogPage\<T\>") — existing filter chips/search field
  behavior is left as-is for now (depends on T002, T003).
- [X] T008 Migrate `lib/features/auth/presentation/admin/users_list_screen.dart`
  to the rewritten `DataTableView` (new constructor signature, `pagination`
  left `null` for now), still rendering the existing unfiltered/unpaginated
  `List<UserSummary>` for now (depends on T003).

**Checkpoint**: Shared widgets exist; both catalog screens compile and
render through the new `DataTableView`. No new user-facing search/
pagination/action behavior yet — user story implementation can now begin.

---

## Phase 3: User Story 1 - Search and page through the Users catalog (Priority: P1) 🎯 MVP

**Goal**: An administrator can search the Users catalog by username/email
(applied only on Enter/submit) and navigate bounded pages of results
(FR-001, FR-002, FR-010).

**Independent Test**: quickstart.md "Users search + pagination" — type a
partial username, confirm no change until Enter/submit, confirm filtered
results, navigate to page 2, clear search and confirm the full list
returns.

### Tests for User Story 1

- [X] T009 [P] [US1] `UserRepositoryImpl.list` test covering
  `search`/`skip`/`limit` → query param mapping and `UserListResponse` →
  `UserListResult` mapping in
  `test/unit/features/auth/user_repository_impl_test.dart` (mocktail
  `UsersApi` fake).
- [X] T010 [P] [US1] `UserFilterController`/paginated `UsersController`
  tests: filter state → re-fetch page 0; `nextPage`/`previousPage` →
  correct `skip` value, in
  `test/unit/features/auth/users_controller_test.dart`.
- [X] T011 [P] [US1] Widget test for `UsersListScreen`: typing into the
  search box issues no request until Enter/submit-button press; page
  navigation control changes the displayed rows, in
  `test/widget/features/auth/users_list_screen_test.dart`.
- [X] T012 [P] [US1] Integration test: sign in as administrator, search
  Users by partial username, confirm only matching users shown, navigate
  to page 2, clear search and confirm full paginated list returns, in
  `test/integration/catalog_consistency_flow_test.dart` (quickstart
  "Users search + pagination" scenarios).

### Implementation for User Story 1

- [X] T013 [US1] Extend `UserRepository`/`UserRepositoryImpl.list()` to
  accept `search`/`skip`/`limit` and return a new `UserListResult`
  (`items`, `total`), passing through to
  `UsersApi.listUsersApiV1UsersGet` per
  contracts/mbe-api-users-list.md (depends on T009).
- [X] T014 [US1] Add `UserFilterController` (mirrors
  `ProductFilterController`, holds `{search}`) in
  `lib/features/auth/presentation/admin/users_controller.dart`.
- [X] T015 [US1] Convert `UsersController` to hold
  `AsyncValue<CatalogPage<UserSummary>>` state (`pageIndex`, fixed
  `pageSize` of 20), re-fetching page 0 whenever `UserFilterController`'s
  state changes (depends on T002, T013, T014).
- [X] T016 [US1] Update `UsersListScreen` to use `CatalogSearchBar`
  (submit-on-Enter/button, FR-010) and pass `UsersController`'s
  `CatalogPage<UserSummary>` into `DataTableView`'s `pagination` parameter
  (depends on T004, T008, T015).

**Checkpoint**: Users catalog has search + pagination parity with
Products, independently testable.

---

## Phase 4: User Story 2 - Recognize and use the same row actions on every catalog (Priority: P1)

**Goal**: Users and Products catalogs expose identical Create/View/Edit/
Delete icons in a fixed left-to-right order, each gated by existing RBAC
checks; View opens the same form as Edit, forced read-only (FR-003 through
FR-006, FR-012).

**Independent Test**: quickstart.md "Consistent row actions" — compare
icon set/order between catalogs as an administrator and as a Read-only
account; confirm View renders the Edit form read-only.

### Tests for User Story 2

- [X] T017 [P] [US2] Widget test: `CatalogActionIcons`' builder renders
  `[view, edit, delete]` in that fixed order and omits any action whose
  `can(...)` check returns `false`, in
  `test/widget/core/widgets/catalog_action_icons_test.dart`.
- [X] T018 [P] [US2] Widget tests confirming `UsersListScreen` and
  `ProductsListScreen` render the same icon glyphs/order for row actions
  and the same toolbar Create icon, in
  `test/widget/features/auth/users_list_screen_test.dart` and
  `test/widget/features/catalog/products_list_screen_test.dart`.
- [X] T019 [P] [US2] Integration test: as administrator, click View on a
  row and confirm the Edit form opens read-only; as a Read-only account,
  confirm Edit/Delete icons and the toolbar Create icon are absent while
  View remains, in `test/integration/catalog_consistency_flow_test.dart`
  (quickstart "Consistent row actions" scenarios).

### Implementation for User Story 2

- [X] T020 [US2] Confirm `/users/:userId` and `/products/:productId`
  navigate with a `view=true` query parameter when invoked from a View
  action (no `GoRoute` path/table change needed — `go_router` already
  exposes query params via `state.uri.queryParameters`; this task is just
  the navigation call sites used by T023/T024) (research.md §5).
- [X] T021 [P] [US2] Add a forced-read-only param to
  `lib/features/auth/presentation/admin/user_detail_screen.dart`, read
  from `state.uri.queryParameters['view']`, composing with its existing
  permission-derived `readOnly` check (depends on T020).
- [X] T022 [P] [US2] Add a forced-read-only param to
  `lib/features/catalog/presentation/product_detail_screen.dart`, read
  from `state.uri.queryParameters['view']`, composing with its existing
  `readOnly = _isEdit && !canUpdate` check
  (`product_detail_screen.dart:65`) (depends on T020).
- [X] T023 [US2] Wire `CatalogActionIcons` row actions (View/Edit/Delete)
  and the toolbar Create icon into `UsersListScreen`, gated by
  `access.can(SystemObject.users, ...)` (depends on T006, T016, T021).
- [X] T024 [US2] Wire `CatalogActionIcons` row actions and the toolbar
  Create icon into `ProductsListScreen`, replacing the existing
  `Icons.add_box` toolbar icon, gated by
  `access.can(SystemObject.products, ...)` (depends on T006, T007, T022).

**Checkpoint**: Both catalogs show identical, RBAC-gated Create/View/
Edit/Delete icons in a fixed order.

---

## Phase 5: User Story 3 - Keep the record's identity visible while scanning wide rows (Priority: P2)

**Goal**: The product code column (Products) and username column (Users)
stay pinned during horizontal scroll (FR-007, FR-008).

**Independent Test**: quickstart.md "Frozen identity column" — scroll each
catalog horizontally and confirm the identity column stays visible.

### Tests for User Story 3

- [X] T025 [P] [US3] Widget test: a `DataTableView` column marked
  `frozen: true` remains visible/pinned while the table is scrolled
  horizontally, in `test/widget/core/widgets/data_table_view_test.dart`.

### Implementation for User Story 3

- [X] T026 [US3] Mark the product code column `frozen: true` in
  `ProductsListScreen`'s `DataTableColumn` list — exercised through
  `DataTableView`'s `PaginatedDataTable2` branch since Products always
  supplies `pagination` (T003, T007) (depends on T003, T007, T024).
- [X] T027 [US3] Mark the username column `frozen: true` in
  `UsersListScreen`'s `DataTableColumn` list — exercised through
  `DataTableView`'s `PaginatedDataTable2` branch since Users always
  supplies `pagination` (T003, T016) (depends on T003, T016, T023).

**Checkpoint**: Both catalogs keep their identity column visible while
scrolling horizontally.

---

## Phase 6: User Story 4 - Filter without the layout fighting back (Priority: P2)

**Goal**: Filter controls lay out on one row at tablet-landscape/Expanded
width on both catalogs, and Products' search no longer fires on every
keystroke (FR-009, FR-010, FR-011's Products conformance call-out).

**Independent Test**: quickstart.md "Single-row filters at Expanded
width" — resize the window above/below 840px and confirm layout behavior;
confirm no network request fires from Products' search box until Enter/
submit.

### Tests for User Story 4

- [X] T028 [P] [US4] Widget test: `CatalogFilterBar` lays out children in
  one `Row` at width ≥ 840px and in a `Wrap` below it, in
  `test/widget/core/widgets/catalog_filter_bar_test.dart`.
- [X] T029 [P] [US4] Widget test: `ProductsListScreen`'s search box issues
  no filter update until Enter/submit-button press (regression test for
  the existing per-keystroke `onChanged` behavior), in
  `test/widget/features/catalog/products_list_screen_test.dart`.

### Implementation for User Story 4

- [X] T030 [US4] Replace `ProductsListScreen`'s `TextField(onChanged:
  filterController.searchChanged)` + `Wrap` with `CatalogFilterBar`
  wrapping `CatalogSearchBar` (submit-on-Enter/button) and the existing
  stockable/salable/purchasable/show-inactive filter chips (depends on
  T004, T005, T024).
- [X] T031 [US4] Wrap `UsersListScreen`'s search bar in `CatalogFilterBar`
  for layout consistency with Products (depends on T005, T016).

**Checkpoint**: Filter controls behave and lay out consistently on both
catalogs; no catalog issues a request before explicit search submission.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Regenerate generated code, and validate the full feature
end-to-end.

- [X] T032 [P] Run `dart run build_runner build --delete-conflicting-outputs`
  to regenerate `freezed`/`riverpod` code for `UserFilterController`,
  `UsersController`, and `ProductsListController`.
- [X] T033 [P] Run `flutter analyze` and `dart format --output=none
  --set-exit-if-changed .` across all files touched by this feature.
- [ ] T034 Run quickstart.md's full validation sequence end-to-end against
  a local mbe-api instance (all four user stories).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all
  user stories (both screens must compile against the new `DataTableView`
  signature before any story-specific work lands).
- **User Stories (Phase 3-6)**: All depend on Foundational completion.
  - US1 (Users search/pagination) has no dependency on US2/US3/US4.
  - US2 (action icons) depends on T007/T008 (screens already migrated to
    the new `DataTableView`) but not on US1's search/pagination work.
  - US3 (frozen column) depends on US2 having already wired row actions
    into each screen (T023/T024), since it edits the same
    `DataTableColumn` lists.
  - US4 (filter layout) depends on US2 for the same reason (T023/T024).
- **Polish (Phase 7)**: Depends on all four user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational — independently
  testable on its own (Users catalog only).
- **User Story 2 (P1)**: Can start after Foundational — independently
  testable on its own (both catalogs' action icons), though it should
  land before US3/US4 since those touch the same screen files.
- **User Story 3 (P2)**: Starts after US2 lands in each screen (shared
  file edits, not a logical dependency).
- **User Story 4 (P2)**: Starts after US2 lands in each screen (shared
  file edits, not a logical dependency); also fixes Products' pre-existing
  per-keystroke search regression called out in FR-011.

### Within Each User Story

- Tests MUST be written and FAIL before implementation.
- Repository/controller changes before screen wiring.
- Story complete before moving to the next priority (or in parallel by
  file, per the Parallel Opportunities below).

### Parallel Opportunities

- T002, T004, T005, T006 (all new shared widgets/data shapes) can be
  implemented in parallel — different files. T003 (`DataTableView`
  rewrite) depends on T002 (`CatalogPage<T>`) but can still run in
  parallel with T004-T006; only T007/T008 depend on T003.
- All Setup (T001) and most Foundational tasks marked [P] can run in
  parallel.
- US1's tests (T009-T012) can run in parallel; US1's implementation tasks
  are sequential (repository → controller → screen).
- US2's `user_detail_screen.dart`/`product_detail_screen.dart` edits
  (T021/T022) can run in parallel once T020 lands.
- US3 and US4 touch different aspects of the same screen files
  (`DataTableColumn` list vs. filter bar), so within a screen they should
  be sequenced rather than parallelized; across the two screens (Users vs.
  Products) they can run in parallel.

---

## Parallel Example: Foundational Phase

```bash
# Launch the independent new shared widgets/data shapes together
# (different files; data_table_view.dart waits on catalog_pagination.dart):
Task: "Create lib/core/widgets/catalog_pagination.dart (CatalogPage<T>)"
Task: "Create lib/core/widgets/catalog_search_bar.dart"
Task: "Create lib/core/widgets/catalog_filter_bar.dart"
Task: "Create lib/core/widgets/catalog_action_icons.dart"
```

## Parallel Example: User Story 1 Tests

```bash
Task: "UserRepositoryImpl.list test in test/unit/features/auth/user_repository_impl_test.dart"
Task: "UserFilterController/UsersController tests in test/unit/features/auth/users_controller_test.dart"
Task: "UsersListScreen widget test in test/widget/features/auth/users_list_screen_test.dart"
Task: "Integration test in test/integration/catalog_consistency_flow_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories).
3. Complete Phase 3: User Story 1 (Users search + pagination).
4. **STOP and VALIDATE**: run quickstart.md's Users search + pagination
   steps independently.
5. Deploy/demo if ready — this alone closes the most visible gap (Users
   catalog had neither search nor pagination).

### Incremental Delivery

1. Setup + Foundational → shared widgets exist, both screens compile.
2. Add User Story 1 → Users catalog reaches parity with Products → demo.
3. Add User Story 2 → both catalogs show identical action icons/order →
   demo.
4. Add User Story 3 → identity columns stay visible while scrolling →
   demo.
5. Add User Story 4 → filter layout is consistent and search is
   explicit-submit everywhere → demo.
6. Polish → regenerate code, lint, full quickstart validation.

---

## Notes

- [P] tasks = different files, no unmet dependencies.
- [Story] label maps task to specific user story for traceability.
- Verify tests fail before implementing.
- Commit after each task or logical group.
- Stop at any checkpoint to validate a story independently.
- Avoid: vague tasks, same-file conflicts within a story, cross-story
  dependencies that break independence.
