# Tasks: Advanced Product Search

**Input**: Design documents from `/specs/038-advanced-product-search/`
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Not requested as TDD, but this project's own established practice (specs 035/036/037) is
to include test tasks per story, right after that story's implementation — followed here.

**Organization**: Phases 3+ follow spec.md's priority order (P1: US1; P2: US2, US3; P3: US4, US5).
Route registration and the checkbox/confirm mechanics land in US1 because nothing else is
independently testable without them; the filters button is deliberately deferred to US2, since
forcing it into US1 would make that phase test two stories' worth of acceptance criteria at once.

**Revision (2026-09-09)**: task IDs renumbered after `/speckit-analyze` — five test tasks added
(T021–T024, T037) and eight descriptions tightened, closing findings C1, G1–G7 and A1.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: US1–US5, matching spec.md
- Every description carries its exact file path

---

## Phase 1: Setup

**Purpose**: Nothing to scaffold — this feature edits existing, fully configured files and adds two
new ones. No new dependency, no project init.

- [X] T001 Confirm `flutter analyze && flutter test` pass on the current branch before any change, as
      the baseline for every later regression check.

---

## Phase 2: Foundational

**Purpose**: The pieces every story's code needs to compile against — the deployment setting, the
selection/result channel, the localized strings, and the one contract change to
`ProductSearchField` — none of which depends on the new screen existing yet.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T002 [P] Add `productSearchMultiSelect` (`bool`, default `true`) to `AppSettings` in
      `lib/core/config/app_settings.dart`: a `_productSearchMultiSelectEnv` `String.fromEnvironment`
      const, a private parser that accepts `'true'`/`'false'` case-insensitively and falls back to
      the default on anything else, the field wired into the constructor and
      `AppSettings.fromEnvironment()`, and an entry in the `kDebugMode` debug-print audit line
      (data-model.md §5; contracts/app-settings-additions.md C1).
- [X] T003 [P] Add `productSearchMultiSelectProvider` to `lib/core/config/app_settings_provider.dart`,
      mirroring `inputDebounceProvider`'s one-line pattern (depends on T002).
- [X] T004 [P] Document `PRODUCT_SEARCH_MULTI_SELECT` in `.env.template`'s app-settings block, near
      `POS_DEFAULT_CUSTOMER_ID`, with the two-line comment from
      contracts/app-settings-additions.md C1.
- [X] T005 [P] Add `PRODUCT_SEARCH_MULTI_SELECT=true` to `.env.settings` so the VS Code run
      configuration exercises it (quickstart.md "Run").
- [X] T006 Add two tests to `test/unit/core/config/app_settings_test.dart`: (a) add
      `productSearchMultiSelect` to the existing all-fields-default assertion, and (b) a new group
      mirroring the parser's rule inline the way the debounce group does —
      `'true'`/`'TRUE'`→true, `'false'`→false, `''`/`'yes'`/`'1'`→default (depends on T002, T003).
- [X] T007 [P] Add the 8 new keys from contracts/advanced-search-screen.md §5
      (`advancedSearchButton`, `advancedSearchTitle`, `advancedSearchAddButton`,
      `advancedSearchSelectionCount`, `advancedSearchClearSelection`, `advancedSearchNoSaleHint`,
      `advancedSearchSkipped`, `advancedSearchAdding`) to `lib/l10n/app_es.arb`, each with its
      `@key` metadata object.
- [X] T008 Add the same 8 keys, in English, to `lib/l10n/app_en.arb` (depends on T007 — this
      project's convention is Spanish first, then English).
- [X] T009 Run `flutter gen-l10n` to regenerate `AppLocalizations` (depends on T007, T008) — a
      missed regeneration produces a stale getter, not a compile error.
- [X] T010 [P] Create `lib/features/sales/presentation/capture/advanced_search_state.dart` with
      `advancedSearchSelectionProvider` (`StateProvider<List<ProductListItem>>`, default `const []`)
      and `advancedSearchResultProvider` (`StateProvider<List<ProductListItem>?>`, default `null`) —
      both plain, non-autoDispose (data-model.md §4; research.md R2).
- [X] T011 [P] In `lib/features/sales/presentation/capture/product_search_field.dart`, change
      `onProductSelected`'s type from `ValueChanged<ProductLookupResult>` to
      `Future<void> Function(ProductLookupResult)` (data-model.md §6). Verify (no code change
      expected) that both host call sites — `capture_step.dart:207` and `order_screen.dart:276` —
      still compile: their closures already return `_addLine`'s `Future<void>`, so only the field's
      declared parameter type needs to change (research.md R3).

**Checkpoint**: `flutter analyze` is clean, the setting and its tests pass, and the field's contract
has changed with nothing yet consuming it. User story implementation can now begin.

---

## Phase 3: User Story 1 — Browse the catalog and add a product without leaving the sale (Priority: P1) 🎯 MVP

**Goal**: From the product search field, open a paged table of active, salable products, tick one,
confirm, and get back to the sale with a correctly priced line — and nothing else about the sale
disturbed.

**Independent Test**: From a sale with a customer, open Advanced search, search a term, select one
product, confirm, and verify a correctly priced line appears on the sale and nothing else changed.

### Implementation for User Story 1

- [X] T012 [US1] Add a new top-level `GoRoute(path: '/sales/product-search', builder: (context,
      state) => AdvancedSearchScreen(query: ListQuery.fromUri(state.uri)))` to
      `lib/app/router/app_router.dart`, as a sibling of `/sales/pos/new` — **not** a shell branch —
      and a new `_routeGate` clause `if (location.startsWith('/sales/product-search')) return
      PrivilegeGate(SystemObject.products, AccessRight.read);` placed with the other `/sales/*`
      clauses (contracts/advanced-search-screen.md §1; constitution IV).
- [X] T013 [US1] Create `lib/features/sales/presentation/capture/advanced_search_screen.dart`:
      `AdvancedSearchScreen(query: ListQuery)`, a `ConsumerWidget` with a `Scaffold` (AppBar titled
      `l10n.advancedSearchTitle`, leading control cancels), a forced filter
      `ProductFilter.fromQuery(query).copyWith(status: EntityStatus.active, salable: true)`, and a
      private `_replaceWith(BuildContext, ListQuery)` helper that calls
      `GoRouter.of(context).replace(query.toUri('/sales/product-search').toString())` — **never**
      `context.go`, which would unmount the sale beneath (research.md R1). Wire `CatalogSearchBar`
      through it (unchanged-term → re-invalidate, changed term → `_replaceWith` with page reset to
      0, mirroring `submitCatalogSearch`'s two-branch rule since that helper itself calls `go` and
      cannot be reused as-is).
- [X] T014 [US1] In the same file, render the table via `CatalogListStateView<ProductListItem>` fed
      by `productsListControllerProvider(filter)`, supplying its **required** state parameters:
      `emptyMessage: l10n.noProductsFound`, `retryLabel: l10n.retryButton` with `onRetry`
      invalidating `productsListControllerProvider(filter)`, `clearFiltersLabel:
      l10n.clearFiltersButton` with `onClearFilters` calling `_replaceWith` on the bare route, and
      `createLabel`/`onCreate` left `null` — this screen creates nothing (FR-013). Inside `onData`,
      use `DataTableView<ProductListItem>` with: a leading `DataTableColumn` (`fixedWidth: 56`,
      `cellBuilder` returning `IgnorePointer(child: Checkbox(value: selected, onChanged: null))`),
      then photo (120), code (200), name (L), brand (S), unit (M) — **no** status column, **no**
      `rowActionsBuilder`. `onRowTap` toggles the tapped product in
      `advancedSearchSelectionProvider` by `productId` (append if absent, remove if present) — the
      checkbox cell has no handler of its own, so there is exactly one way to toggle a row
      (contracts/advanced-search-screen.md §2, §3; research.md R4).
- [X] T015 [US1] In the same file, add a bottom action bar: `advanced_search_selection_count` (the
      running count, hidden at zero), `advanced_search_cancel_button` (pops, leaving
      `advancedSearchResultProvider` at `null` and resetting the selection to `const []`), and
      `advanced_search_add_button` — enabled iff the selection is non-empty **and**
      `Navigator.of(context).canPop()`; when it cannot pop, disabled with
      `l10n.advancedSearchNoSaleHint` (research.md R8). Confirming sets
      `advancedSearchResultProvider` to the current selection (preserving tick order) and pops, and
      is guarded so a second tap landing before the pop completes cannot set the result twice
      (FR-022).
- [X] T016 [US1] In `lib/features/sales/presentation/capture/product_search_field.dart`, add the
      `advanced_search_button` affordance beside the field: visible when
      `ref.watch(accessControlProvider).can(SystemObject.products, AccessRight.read)`, disabled
      when `!widget.enabled`; on press, reset `advancedSearchSelectionProvider` to `const []` and
      `context.push('/sales/product-search${_controller.text.trim().isEmpty ? '' :
      '?search=${Uri.encodeQueryComponent(_controller.text.trim())}'}')` so the field's current text
      carries over as the screen's initial search (FR-004; contracts/advanced-search-screen.md §4).
- [X] T017 [US1] In the same file, add `ref.listen(advancedSearchResultProvider, (prev, next) {
      ... })`: on a non-null `next`, immediately reset the provider to `null`, enter an internal
      `_advancedAdding` state (disabling the field and the button — FR-022), and for each product in
      `next`, **sequentially**: resolve
      `ref.read(productLookupControllerProvider(product.code, warehouse: widget.warehouse).future)`,
      take the row whose `product == product.productId` (or record a skip if none matches — the
      lookup matches code/name/brand/SKU/barcode and can return several rows), `await
      widget.onProductSelected(result)` and on a thrown `AppError` record a skip instead of
      propagating it. Publish the running progress as `l10n.advancedSearchAdding` while the loop
      runs (SC-005). After the loop, render `advanced_search_skipped` (one `code — name` per skipped
      product; nothing when the list is empty) and clear `_advancedAdding`
      (contracts/advanced-search-screen.md §4; data-model.md §2, §7; research.md R3).

### Tests for User Story 1

- [X] T018 [P] [US1] Widget tests in `test/widget/features/sales/advanced_search_screen_test.dart`
      (new file): the table renders photo/code/name/brand/unit plus a leading checkbox and **no**
      status column and **no** row action icons; tapping anywhere on a row toggles its checkbox and
      tapping the checkbox cell itself does nothing extra; Add is disabled with an empty selection;
      Cancel pops leaving the result provider `null`. Include one assertion that merely **opening**
      the screen fires no product-lookup call and no sale mutation before Add is pressed (FR-005).
- [X] T019 [P] [US1] Widget tests in `test/widget/features/sales/product_search_field_test.dart`: the
      Advanced search button is present and opens the screen carrying the field's current text as
      the initial search; confirming one selected product adds exactly one correctly priced line to
      the sale and clears the field's own input; Cancel leaves the sale untouched.
- [X] T020 [US1] Widget test proving research.md R1/R2's core property — pump the field inside
      `pumpPosRouted` (`test/widget/features/sales/pos_test_harness.dart:173`), open Advanced
      search, submit a new search term (exercising `_replaceWith`), and assert the sale's provider
      state is unchanged and no second draft sale was created — i.e. `GoRouter.replace`, not
      `context.go`, is what ran. Then return via the router's own `pop()` — the closest stand-in
      `WidgetTester` has for the browser Back control — and assert the sale is still intact; real
      browser Back stays a manual check (quickstart.md V7, SC-003). Depends on T013.
- [X] T021 [P] [US1] Widget test in `advanced_search_screen_test.dart` for the list states (FR-013):
      a failed fetch renders `list_state_failed` and its retry affordance re-issues the request; an
      empty filtered result renders `list_state_filtered_empty` and its clear-filters affordance
      restores the unfiltered table.
- [X] T022 [P] [US1] Widget test in `product_search_field_test.dart` for FR-022: hold the repository
      future open mid-batch and assert the field **and** the Advanced search button are disabled
      while `_advancedAdding` is true, that a second confirm cannot enqueue a second batch, and that
      no duplicate line results.
- [X] T023 [P] [US1] Widget test in `product_search_field_test.dart` for FR-023 (spec.md edge case
      "no sale exists yet"): with no sale open, confirm one product from Advanced search and assert
      exactly one sale is opened (a single `open()` call — `ensureOpen` is not concurrency-safe,
      research.md R3) and exactly one line added.
- [X] T024 [P] [US1] Widget test in `product_search_field_test.dart` for FR-001's second surface:
      pump the field under an `OrderScreen`-style nested `ProviderScope` overriding
      `saleEditorProvider` (mirroring `order_screen.dart:48-58`) and assert the affordance renders
      and the confirmed selection reaches **that** editor, not the register's `PosSaleController`
      (research.md R2).

**Checkpoint**: User Story 1 is fully functional and independently testable.

---

## Phase 4: User Story 2 — Narrow the list down by supplier, label or attribute (Priority: P2)

**Goal**: The same badged-filters pattern every list screen has, offering Stockable, Purchasable,
Supplier and Label — with no Status and no Salable control, since those are forced.

**Independent Test**: Open Advanced search, apply a supplier and a label filter, confirm the table
narrows, the badge counts two, clearing resets the table, and the filters survive a page change.

### Implementation for User Story 2

- [X] T025 [US2] In `advanced_search_screen.dart`, add the badged filters button to the
      `CatalogFilterBar` (`Badge.count` + `IconButton.outlined(Icons.tune)`), opening
      `showCatalogFilterSheet` with a screen-owned filter panel: `_TriStateFilterChip`s for
      Stockable and Purchasable, a `CatalogEntityPicker<SupplierListItem>` for supplier, and a
      `LabelMultiPicker` for labels — no status control, no salable control
      (contracts/advanced-search-screen.md §2; FR-008, FR-009). Each control change calls
      `_replaceWith` with `pageIndex: 0` (FR-011).
- [X] T026 [US2] In the same file, compute the filters badge as
      `(stockable != null ? 1 : 0) + (purchasable != null ? 1 : 0) + (supplier != null ? 1 : 0) +
      labels.length` — **not** `ProductFilterBadge.activeFilterCount`, which would count the two
      forced facets and show 2 on a virgin screen — and compute `CatalogListStateView.isFiltered` as
      `query.search.isNotEmpty || <any panel facet present>` — **not**
      `isFilteredBeyondStatusDefault` (data-model.md §3; research.md R5).
- [X] T027 [US2] Wire `productLabelFacetsProvider(filter)` with the **same** forced `filter`
      (`status: active, salable: true`) the table uses, so label chip counts match exactly what the
      table can reveal (research.md R5).
- [X] T028 [US2] Wire the filter sheet's `onClearAll` to `_replaceWith` the bare
      `/sales/product-search` (search cleared, no facets), matching
      `showCatalogFilterSheet`'s `onClearAll` contract.

### Tests for User Story 2

- [X] T029 [P] [US2] Widget tests in `advanced_search_screen_test.dart`: the filter panel shows
      Stockable, Purchasable, Supplier and Label and neither Status nor Salable; a supplier + one
      label selected shows a badge of 2 (not 4); applying them narrows the table; and applying a
      filter while on page 2 returns the table to page 1 (FR-011).
- [X] T030 [P] [US2] Widget test: a `ListQuery` hand-constructed with `status=all` and
      `salable=false` facets still yields a table restricted to active + salable products — the
      forced facet cannot be overridden by the URL (FR-008, SC-004).

**Checkpoint**: User Stories 1 and 2 both work independently.

---

## Phase 5: User Story 3 — Add several products in one trip (Priority: P2)

**Goal**: Selection persists across paging and filtering within one visit, a running count is
visible, and a failure on one product never blocks the rest.

**Independent Test**: With multiple selection enabled, tick three products across two pages, confirm,
and verify three lines appear on the sale and the count shown before confirming matched.

### Implementation for User Story 3

- [X] T031 [US3] In `advanced_search_screen.dart`, verify/adjust the row-tap toggle from T014 reads
      and writes `advancedSearchSelectionProvider` directly (never local widget state), so a tick
      survives the `key: ValueKey(pagination.pageIndex)` remount `DataTableView` performs on every
      page change (`lib/core/widgets/data_table_view.dart`).
- [X] T032 [US3] Add the running count and a `advanced_search_clear_selection` action to the bottom
      bar, both visible only when `productSearchMultiSelectProvider` is `true` and the selection is
      non-empty; clearing resets `advancedSearchSelectionProvider` to `const []` without leaving the
      screen (contracts/advanced-search-screen.md §3).
- [X] T033 [US3] Confirm (adjust `product_search_field.dart`'s T017 loop if needed, no behavioural
      change expected) that selection order is preserved end-to-end into line order (FR-019) and
      that a skip on one product never halts the remaining ones in the same batch.

### Tests for User Story 3

- [X] T034 [P] [US3] Widget test: tick two products on page 1, page to page 2 and tick a third,
      change a filter and page back — the count stays 3 and every earlier tick is still selected;
      confirming adds all three, in tick order.
- [X] T035 [P] [US3] Widget test: one selected product's lookup returns no matching row (simulate via
      the mock repository returning no row for that code, or `onProductSelected` throwing
      `AppError`) — the other selected products are still added, and `advanced_search_skipped` names
      the skipped one by code and name (FR-021, SC-006).
- [X] T036 [P] [US3] Widget test: "Clear selection" empties the count and every tick without
      navigating away.
- [X] T037 [P] [US3] Widget test for SC-005: confirm a selection of **10** products against a mock
      repository and assert the `advancedSearchAdding` progress text advances as the batch proceeds,
      all 10 lines are added in tick order, and exactly 10 lookup calls and 10 add calls are issued
      — no duplicates, none dropped. Real-backend timing stays a manual check (quickstart.md V10).

**Checkpoint**: User Stories 1–3 all work; multi-select delivers its intended value.

---

## Phase 6: User Story 4 — A deployment chooses how many products may be picked at once (Priority: P3)

**Goal**: `PRODUCT_SEARCH_MULTI_SELECT` genuinely gates single- vs multi-selection, with a safe,
documented default.

**Independent Test**: Build with the option set to single selection and confirm only one product can
ever be ticked; build with no configuration file at all and confirm the documented default applies.

### Implementation for User Story 4

- [X] T038 [US4] In `advanced_search_screen.dart`'s row-tap handler, branch on
      `ref.read(productSearchMultiSelectProvider)`: when `false`, ticking a row **replaces** the
      selection with `[product]` instead of appending, releasing whatever was previously selected
      (contracts/advanced-search-screen.md §3 "Single mode"; FR-015, FR-016).

### Tests for User Story 4

- [X] T039 [P] [US4] Widget test with `productSearchMultiSelectProvider` overridden to `false`:
      ticking a second row releases the first tick; the selection never exceeds length 1 and the Add
      button reads "Add (1)".
- [X] T040 [P] [US4] Widget test with the provider at its default (`true`, no override): unaffected —
      still multi-select (regression guard against T038).
- [X] T041 [US4] Manual verification per quickstart.md V5: run with
      `--dart-define=PRODUCT_SEARCH_MULTI_SELECT=false` and with no `--dart-define` at all, and
      confirm the built app matches each case (SC-008).

**Checkpoint**: A deployment can switch selection modes with a configuration change and a rebuild
only.

---

## Phase 7: User Story 5 — An operator without catalog access is never offered a dead end (Priority: P3)

**Goal**: No affordance, no reachable route, for a user lacking `products` read.

**Independent Test**: Sign in as a role without catalog read access, open a sale, confirm no Advanced
search affordance is present, and confirm navigating directly to the screen's address is refused the
same way the catalog list is.

### Implementation for User Story 5

*(Structural gating already shipped in T012 and T016 — this story is verification-only, per its own
"low risk, self-contained" priority. Add fixes here only if a test below finds a gap.)*

### Tests for User Story 5

- [X] T042 [P] [US5] Widget test in `product_search_field_test.dart`: with `accessControlProvider`
      overridden so `can(SystemObject.products, AccessRight.read)` is `false`, the Advanced search
      button is absent from the field.
- [X] T043 [P] [US5] Widget test: with the field's own `enabled: false`, the Advanced search button
      is also disabled (FR-003) — confirms T016's `widget.enabled` wiring.
- [X] T044 [P] [US5] Test (alongside this repo's existing router-gate tests, wherever `_routeGate` is
      covered — search `test/` for the existing `/products` gate assertion and mirror it) asserting
      `/sales/product-search` resolves to `PrivilegeGate(SystemObject.products, AccessRight.read)`
      and that a denied `accessControlProvider` redirects it to `/`, exactly like `/products`
      (SC-007).

**Checkpoint**: every story is delivered; a user without catalog access sees no trace of the feature.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: The properties that span every story rather than belonging to one.

- [X] T045 [P] Compact-layout widget test in `advanced_search_screen_test.dart` using
      `pos_test_harness.dart`'s `phoneSurface` and `expectNoHorizontalScroll`: the filter row wraps,
      the table scrolls horizontally within itself, the page never scrolls horizontally, and the
      Add/Cancel bar stays reachable (FR-014; quickstart.md V8).
- [X] T046 [P] Confirm the existing scan/type-ahead widget tests in `product_search_field_test.dart`
      pass unmodified in substance after T011/T016/T017 — the debounced-search and
      auto-add-on-exact-match paths are unchanged (SC-009).
- [X] T047 Check `test/widget/features/sales/pos_compact_layout_test.dart`'s existing
      `ProductSearchField` expectations still hold with the new affordance present; adjust only if
      the new button changes the field's measured layout.
- [X] T048 Run `flutter analyze && flutter test` for the full suite; fix any fallout from the
      `onProductSelected` signature change or the new route/gate clause.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies.
- **Foundational (Phase 2)**: depends only on Setup. **Blocks every user story** — the setting, the
  selection/result providers, the localized strings and the field's changed contract are all
  referenced starting in US1.
- **User Story 1 (Phase 3)**: depends on Foundational. Delivers the route, the screen, the checkbox
  mechanic and the confirm/add loop. **Nothing else can be built or tested without it.**
- **User Story 2 (Phase 4)**: depends on Foundational + US1 (extends the same screen file with the
  filters button).
- **User Story 3 (Phase 5)**: depends on Foundational + US1 (extends the same screen file's selection
  handling). Independent of US2's filters, though both touch the same file.
- **User Story 4 (Phase 6)**: depends on Foundational (the setting) + US1 (the tick handler it
  branches inside). Independent of US2 and US3.
- **User Story 5 (Phase 7)**: depends on Foundational + US1 (the gating it verifies was built there).
  Test-only — no new production code expected.
- **Polish (Phase 8)**: depends on every story being complete.

### Within Each User Story

Implementation tasks generally precede that story's tests. Tasks touching different files are
parallelizable; tasks marked without `[P]` touch a file another task in the same phase already
opened, or read a result an earlier task produced.

### Parallel Opportunities

- Within Foundational: T002, T003, T004, T005, T007, T010, T011 touch disjoint files and can run
  together; T006, T008, T009 each depend on one of them.
- Within US1: the six test tasks T018, T019, T021, T022, T023, T024 target distinct scenarios and
  can be written in parallel once T012–T017 land; T020 depends specifically on T013.
- Within US2/US3/US4/US5: every `[P]`-marked test task targets a distinct scenario in a shared test
  file and can be written in parallel, then merged.

---

## Parallel Example: Foundational Phase

```
Task: "Add productSearchMultiSelect to AppSettings in lib/core/config/app_settings.dart"
Task: "Document PRODUCT_SEARCH_MULTI_SELECT in .env.template"
Task: "Add PRODUCT_SEARCH_MULTI_SELECT=true to .env.settings"
Task: "Add the 8 new keys to lib/l10n/app_es.arb"
Task: "Create lib/features/sales/presentation/capture/advanced_search_state.dart"
Task: "Change ProductSearchField.onProductSelected's type"
```

---

## Implementation Strategy

### MVP checkpoint (User Story 1 only)

Complete Phases 1–3, then stop and validate: an operator can open Advanced search, pick one product
from a paged table of active/salable products, confirm, and get a correctly priced line — with the
sale intact if they cancel instead.

This is an **internal checkpoint, not a release**. US1 alone leaves the screen with a search box but
no facet filters, and constitution §VI requires every list screen for an entity with obvious facets
(products plainly qualifies) to ship *with* filtering. A merge or deploy must therefore include at
least through **US2**. The deployment setting needs no such caveat: it defaults to multi-select,
which behaves identically to single-select when only one row is ever ticked.

### Recommended Order

1. **Setup + Foundational** (T001–T011) — nothing compiles against the new contract without this.
2. **User Story 1** (T012–T024) — the MVP checkpoint. Validate before continuing.
3. **User Story 2** (T025–T030) — filters, additive to the same screen file. **Release floor**: the
   earliest point the feature may be merged or deployed (constitution §VI).
4. **User Story 3** (T031–T037) — multi-select UX, additive and independent of US2.
5. **User Story 4** (T038–T041) — the configuration gate, small and low-risk once US1's tick handler
   exists.
6. **User Story 5** (T042–T044) — verification of gating already in place; catches any gap before
   calling the feature done.
7. **Polish** (T045–T048) — compact layout, regression guards, final full-suite run.

### Incremental Delivery

Each user story phase ends at a checkpoint where the feature is demonstrably further along without
anything earlier regressing — US2/US3/US4 each add one dimension (filters, multi-select persistence,
configurability) to the same US1 screen, and US5 only ever subtracts capability for a specific role,
never behaviour for anyone else.

## Notes

- `[P]` tasks touch different files (or different, independent scenarios in a shared test file) and
  have no completed-task dependency within their phase.
- Every task lists its exact file path except T001 (a whole-suite baseline check) and T041/T048
  (build/test-run verification steps with no single file to name).
- Two success criteria are validated manually rather than by the suite, and deliberately so: SC-001
  (a sub-30-second find-and-add, quickstart V1) and the real-backend half of SC-005 (quickstart
  V10); SC-003's browser-Back clause is covered by quickstart V7, with T020 asserting the closest
  in-test equivalent.
- Commit after each task or logical group, per this repo's usual practice; this tasks.md does not
  prescribe commit boundaries beyond that.
