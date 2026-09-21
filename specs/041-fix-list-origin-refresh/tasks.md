---

description: "Task list for Fix List Origin Filtering and Cash Session List Refresh"
---

# Tasks: Fix List Origin Filtering and Cash Session List Refresh

**Input**: Design documents from `/specs/041-fix-list-origin-refresh/`
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Included. The constitution's Development Workflow & Quality Gates
mandate unit/widget/integration coverage for this kind of change, and
[research.md](./research.md) R8 already names which existing suite each new
case belongs in — this task list follows that disposition file by file rather
than inventing new ones.

**Organization**: Tasks are grouped by user story (spec.md's US1–US3). All
three are priority P1 in the spec, and — unlike a typical feature — they share
almost no runtime code path: US1 and US2 share the origin-plumbing built in
Phase 2, but US3 (the cash-session refresh) depends on none of it and could be
built in complete isolation. This is called out explicitly at the Foundational
checkpoint so it is not mistaken for a blocking dependency.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no unresolved dependency)
- **[Story]**: US1–US3, or omitted for Setup/Foundational/Polish
- File paths are exact and relative to the repository root

---

## Phase 1: Setup

**Purpose**: Confirm the branch and establish a pre-change baseline so a later
regression is attributable to this feature rather than pre-existing.

- [ ] T001 Confirm `041-fix-list-origin-refresh` is checked out and run
      `flutter pub get` at the repository root
- [ ] T002 [P] Run `flutter analyze` and
      `flutter test test/unit/features/sales test/widget/features/sales`, and
      record the baseline pass count — every currently-passing test in this
      baseline must still pass, unmodified in assertion, once this feature is
      complete (FR-012, SC-005)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Stand up the origin plumbing that US1 and US2 both build on — the
`OpenSale.origin` field, the repository's `excludeOrigin` parameter, and the
shared `SaleOriginChip` widget and strings. **US1 and US2 cannot start their
implementation tasks until this phase is complete.**

**US3 has no dependency on this phase** and its tasks (Phase 5) may proceed at
any time, including in parallel with Phase 2.

- [ ] T003 Add `SaleOrigin? origin` to the `OpenSale` factory and map
      `origin: SaleOrigin.fromApi(r.origin)` in `fromResponse`, plus the
      `sale_origin.dart` import, in
      `lib/features/sales/domain/entities/open_sale.dart:11-48`; then run
      `dart run build_runner build --delete-conflicting-outputs` to regenerate
      `open_sale.freezed.dart` — data-model.md §2
- [ ] T004 Add an optional `SaleOrigin? origin` parameter to the `testOpenSale`
      fixture helper (`test/widget/features/sales/pos_test_harness.dart:377-400`),
      forwarding it into the `OpenSale(...)` it builds (depends on T003)
- [ ] T005 [P] Add `SaleOrigin? excludeOrigin` to the `listSales` (lines
      151-159) and `listOrders` (lines 174-184) declarations in
      `lib/features/sales/domain/repositories/sales_order_repository.dart`,
      documented per contracts/origin-filter.md §1-2 — data-model.md §4
- [ ] T006 Add `excludeOrigin` to the `listSales` and `listOrders`
      implementations in
      `lib/features/sales/data/sales_order_repository_impl.dart:273-334`,
      forwarding as `excludeOrigin: excludeOrigin?.toApi()` to the generated
      `_api.listSalesOrdersApiV1SalesOrdersGet(...)` call (depends on T005) —
      contracts/origin-filter.md §2
- [ ] T007 [P] Add `saleOriginPointOfSale`, `saleOriginBackOffice` and
      `saleOriginUnrecorded` keys (with `"@key": {}` stubs in `app_en.arb`) to
      `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` — reuse "Punto de venta"
      for `saleOriginPointOfSale`, matching the wording already established by
      `salesOrderForeignOrderMessage` (`app_es.arb:881-882`); then run
      `flutter gen-l10n` — contracts/origin-filter.md §6, research.md R7
- [ ] T008 Create `SaleOriginChip` in
      `lib/features/sales/presentation/widgets/sale_origin_chip.dart`,
      wrapping the shared `StatusChip<SaleOrigin?>`
      (`lib/core/widgets/status_chip.dart:14-42`) and mirroring
      `PosSaleStatusChip`
      (`lib/features/sales/presentation/widgets/pos_sale_status_chip.dart:24-49`),
      rendering all three states with the T007 strings (depends on T007) —
      contracts/origin-filter.md §5

**Checkpoint**: `OpenSale` carries origin, both repository methods can exclude
one workflow, and a shared chip exists to render any of the three states. US1
and US2 implementation can now begin.

---

## Phase 3: User Story 1 - Hide back-office orders from the point-of-sale sales list (Priority: P1) 🎯

**Goal**: A register user can hide back-office-originated orders from the POS
sales list in one action, without losing orders whose origin was never
recorded.

**Independent Test**: From the point-of-sale sales list, turn on the filter
that hides back-office orders, and confirm every remaining row is either a
point-of-sale sale or an order with no recorded origin, and that all
back-office orders disappear.

### Tests for User Story 1

- [ ] T009 [P] [US1] Unit test: `PosSalesFilter.fromQuery` decodes the
      `hide-back-office` facet (absent ⇒ `false`; `"true"` ⇒ `true`), and
      `activeFilterCount`/`hasActiveFilters` include it, in
      `test/unit/features/sales/pos_sales_filter_test.dart`
- [ ] T010 [P] [US1] Unit test: `listSales` forwards
      `excludeOrigin: SaleOrigin.backOffice` to the wire as `exclude_origin=1`,
      and sends no `exclude_origin` parameter at all when `excludeOrigin` is
      `null`, added to the `'listSales query parameters'` group in
      `test/unit/features/sales/sales_order_list_open_test.dart` (depends on
      Foundational T006)
- [ ] T011 [P] [US1] Widget test: the POS sales list's filter drawer shows a
      "hide back-office orders" chip; toggling it updates the URL facet,
      resets to page 0, and raises the filter badge count by one, in
      `test/widget/features/sales/pos_sales_list_screen_test.dart`
- [ ] T012 [P] [US1] Widget test: the POS sales list renders a distinct
      `SaleOriginChip` per row for point-of-sale, back-office and unrecorded
      origins, with no layout overflow at desktop width and at the largest of
      the four text-size levels, in
      `test/widget/features/sales/pos_sales_list_screen_test.dart` (depends on
      Foundational T003, T004, T008)

### Implementation for User Story 1

- [ ] T013 [US1] Add `hideBackOffice` (`bool`, default `false`) to
      `PosSalesFilter`, decode it in `fromQuery`, and include it in
      `activeFilterCount`/`hasActiveFilters` in the `PosSalesFilterBadge`
      extension, in `lib/features/sales/presentation/pos_sales_list_controller.dart:26-64,91-122`
      — data-model.md §3, contracts/origin-filter.md §3
- [ ] T014 [US1] In `PosSalesListController.build` (line ~155), pass
      `excludeOrigin: filter.hideBackOffice ? SaleOrigin.backOffice : null` to
      `.listSales(...)` (depends on T013, Foundational T006) —
      contracts/origin-filter.md §2
- [ ] T015 [US1] Add the "hide back-office orders" `FilterChip` to
      `_PosSalesFiltersPanel` (`lib/features/sales/presentation/pos_sales_list_screen.dart:303-374`),
      placed after the status `Wrap` with its own `titleSmall` label,
      navigating with `query.withFacet('hide-back-office', ...)` and
      `.copyWith(pageIndex: 0)` on every change (depends on T013) —
      contracts/origin-filter.md §4
- [ ] T016 [US1] Add an origin column to the POS sales list's
      `DataTableView` columns (`pos_sales_list_screen.dart:185-223`),
      immediately after Status, rendering
      `SaleOriginChip(origin: sale.origin)` with a `fixedWidth` (depends on
      Foundational T003, T008) — contracts/origin-filter.md §5
- [ ] T017 [US1] Add the new facet to the screen's `onClearAll` and to its
      `isFiltered` expression (`pos_sales_list_screen.dart:147-153,172-175`)
      (depends on T013) — contracts/origin-filter.md §3

**Checkpoint**: US1 is independently functional and testable — a register user
can hide back-office orders from the POS sales list, and every row shows its
origin.

---

## Phase 4: User Story 2 - Hide point-of-sale orders from the back-office "Pedidos" list (Priority: P1)

**Goal**: A back-office user can hide point-of-sale-originated sales from
"Pedidos" in one action, without losing orders whose origin was never
recorded.

**Independent Test**: From the "Pedidos" list, turn on the filter that hides
point-of-sale sales, and confirm every remaining row is either a back-office
order or an order with no recorded origin, and that all point-of-sale sales
disappear.

### Tests for User Story 2

- [ ] T018 [P] [US2] Unit test: `SalesOrdersFilter.fromQuery` decodes the
      `hide-point-of-sale` facet (absent ⇒ `false`), and
      `activeFilterCount`/`hasActiveFilters` include it, in
      `test/unit/features/sales/sales_orders_filter_test.dart`
- [ ] T019 [P] [US2] Unit test: `listOrders` forwards
      `excludeOrigin: SaleOrigin.pointOfSale` to the wire as
      `exclude_origin=0`, and sends no parameter when `null`, added to the
      `'listOrders query parameters'` group in
      `test/unit/features/sales/sales_order_list_orders_test.dart` (depends on
      Foundational T006)
- [ ] T020 [P] [US2] Widget test: the "Pedidos" list's filter drawer shows a
      "hide point-of-sale sales" chip with the same toggle/reset-page/badge
      behavior as US1's, placed before the admin-only facets, in
      `test/widget/features/sales/sales_orders_filters_test.dart`
- [ ] T021 [P] [US2] Widget test: the "Pedidos" list renders a distinct
      `SaleOriginChip` per row for all three origin states, with no layout
      overflow at desktop width and at the largest text-size level, in
      `test/widget/features/sales/sales_orders_list_screen_test.dart`
      (depends on Foundational T003, T004, T008)

### Implementation for User Story 2

- [ ] T022 [US2] Add `hidePointOfSale` (`bool`, default `false`) to
      `SalesOrdersFilter`, decode it in `fromQuery`, and include it in
      `activeFilterCount`/`hasActiveFilters` in the `SalesOrdersFilterBadge`
      extension, in
      `lib/features/sales/presentation/orders/sales_orders_list_controller.dart:34-75,98-123`
      — data-model.md §3, contracts/origin-filter.md §3
- [ ] T023 [US2] In `SalesOrdersListController.build` (line ~156), pass
      `excludeOrigin: filter.hidePointOfSale ? SaleOrigin.pointOfSale : null`
      to `.listOrders(...)` (depends on T022, Foundational T006) —
      contracts/origin-filter.md §2
- [ ] T024 [US2] Add the "hide point-of-sale sales" `FilterChip` to
      `_SalesOrdersFiltersPanel`
      (`lib/features/sales/presentation/orders/sales_orders_list_screen.dart:283-427`),
      placed after the status `Wrap` and before the `if (isAdministrator)`
      block (depends on T022) — contracts/origin-filter.md §4
- [ ] T025 [US2] Add an origin column to the "Pedidos" list's `DataTableView`
      columns (`sales_orders_list_screen.dart:208-246`), immediately after
      Status, mirroring T016 (depends on Foundational T003, T008) —
      contracts/origin-filter.md §5
- [ ] T026 [US2] Add the new facet to the screen's `onClearAll` and to its
      `hasActiveFilters`-based `isFiltered` expression
      (`sales_orders_list_screen.dart:172-180,197-198`) (depends on T022) —
      contracts/origin-filter.md §3

**Checkpoint**: US2 is independently functional and testable — a back-office
user can hide point-of-sale sales from "Pedidos", and every row shows its
origin. US1 and US2 together mean both lists honor origin symmetrically.

---

## Phase 5: User Story 3 - See a session's status change reflected in the cash sessions list (Priority: P1)

**Goal**: Opening or closing a cash session from the cash sessions screen
updates the session history list on that same screen immediately, with no
manual refresh.

**Independent Test**: Open a new cash session from the cash sessions screen,
and confirm the session history list shows it as soon as the open form closes,
with no other action taken. Repeat for closing the current session.

**No dependency on Phase 2** — this story touches none of the origin plumbing
and can be implemented and tested independently of US1/US2.

### Tests for User Story 3

- [ ] T027 [P] [US3] Widget test: opening a session from the shift sheet
      causes `cashSessionRepository.list(...)` to be called a second time (the
      initial load, then the post-open refresh) and the new session to appear,
      with no further user action, in
      `test/widget/features/sales/cash_sessions_screen_test.dart`
- [ ] T028 [P] [US3] Widget test: closing the current session — via the shift
      card, which navigates to the session's detail screen and back — causes
      the history list to re-fetch and show it closed, using the harness's
      existing `/sales/cash-sessions/:id` stand-in route, in
      `test/widget/features/sales/cash_sessions_screen_test.dart`
- [ ] T029 [P] [US3] Widget test: cancelling/dismissing the open form without
      submitting does not trigger any additional
      `cashSessionRepository.list(...)` call, in
      `test/widget/features/sales/cash_sessions_screen_test.dart`

### Implementation for User Story 3

- [ ] T030 [US3] Add `ref.invalidate(cashSessionsListControllerProvider);` in
      `OpenSessionFormController.submit()`
      (`lib/features/sales/presentation/open_session_form_controller.dart:104-143`),
      beside the existing `ref.invalidate(currentSessionControllerProvider);`
      — contracts/list-refresh.md §1-2
- [ ] T031 [US3] Add `ref.invalidate(cashSessionsListControllerProvider);` in
      `CloseSessionFormController.submit()`
      (`lib/features/sales/presentation/close_session_form_controller.dart:98-140`,
      beside the existing invalidation at line ~136) — contracts/list-refresh.md §1-2
- [ ] T032 [US3] Correct the stale comment at
      `lib/features/sales/presentation/cash_sessions_screen.dart:176-184`,
      which currently claims the history list is "already refreshing" once
      `currentSessionControllerProvider` is invalidated — state instead that
      the history list refresh comes from the form controller's own
      invalidation (depends on T030) — contracts/list-refresh.md §5

**Checkpoint**: US3 is independently functional and testable — opening or
closing a session updates the history list on the same screen with no manual
action, and a cancelled form leaves it untouched.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Confirm nothing outside this feature's own three stories moved,
and that the constitution's guardrails hold.

- [ ] T033 [P] Run `flutter analyze` with zero new findings, and confirm
      `git diff --stat lib/generated/openapi/` is empty — this feature
      requires no OpenAPI codegen (constitution §III; quickstart.md Stage 0-1)
- [ ] T034 [P] Run
      `flutter test test/unit/features/sales test/widget/features/sales` and
      compare against the Phase 1 baseline (T002): every previously-passing
      test still passes, unmodified in assertion (FR-012, SC-005)
- [ ] T035 Run the live integration suites —
      `flutter test --dart-define-from-file=.env -j 1 test/integration/pos_sales_list_flow_test.dart test/integration/sales_orders_flow_test.dart test/integration/cash_session_flow_test.dart`
      — asserting the live `exclude_origin` round trip on both lists and the
      open→close cycle on cash sessions (quickstart.md Stage 3)
- [ ] T036 Perform the six manual checks in quickstart.md Stage 4: unchanged
      default view on both lists, POS toggle, Pedidos toggle, the origin facet
      surviving an unrelated filter change, no horizontal scroll/clipping on
      either table at the largest text-size level, and cash-session
      open/close/cancel behavior in the running app

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Depends on Setup. **Blocks US1 (Phase 3) and
  US2 (Phase 4) only** — it does not block US3.
- **US1 (Phase 3)** and **US2 (Phase 4)**: Both depend on Foundational
  completion; independent of each other.
- **US3 (Phase 5)**: Depends only on Setup. May run at any time relative to
  Phase 2/3/4.
- **Polish (Phase 6)**: Depends on all three user stories being complete.

### Within Each User Story

- Tests are written first and must fail before the corresponding
  implementation task lands.
- Filter-class changes (e.g. T013) precede the controller call-site change
  that reads them (T014) and the drawer/table/clear-all changes that use them
  (T015-T017).

### Parallel Opportunities

- All Setup tasks marked [P].
- Within Foundational: T003 (entity), the T005→T006 chain (repository), and
  the T007→T008 chain (strings/chip) are three independent chains and can
  proceed in parallel; T004 depends on T003.
- Once Foundational completes, **all of US1's and US2's test tasks** (T009-T012,
  T018-T021) can be written in parallel — different files, no shared state.
- **US3 (Phase 5) can run entirely in parallel with Phase 2, 3 and 4** — it
  shares no file with any of them.
- With three developers: one takes US1, one takes US2, one takes US3 — all
  three can be in flight simultaneously once Setup is done (US3 doesn't even
  wait for Foundational).

---

## Parallel Example: Foundational + User Story 3 together

```bash
# These share no files and can start the moment Setup is done:
Task: "Add SaleOrigin? origin to OpenSale (open_sale.dart) + freezed regen"      # T003
Task: "Add excludeOrigin to sales_order_repository.dart declarations"           # T005
Task: "Add origin l10n strings + flutter gen-l10n"                              # T007
Task: "Widget test: opening a session refreshes the history list"              # T027
Task: "Widget test: closing a session refreshes the history list"              # T028
```

## Parallel Example: User Story 1 tests

```bash
Task: "Unit test: PosSalesFilter.fromQuery decodes hide-back-office"                      # T009
Task: "Unit test: listSales forwards excludeOrigin to the wire"                            # T010
Task: "Widget test: POS drawer shows and toggles the hide-back-office chip"                # T011
Task: "Widget test: POS list renders SaleOriginChip for all three states, no overflow"     # T012
```

---

## Implementation Strategy

All three stories are P1 — none is optional, and the feature is not complete
until all three ship. Unlike a typical MVP slice, "pick one story first" here
is purely a sequencing choice, not a scope cut:

1. Complete Setup (Phase 1).
2. Complete Foundational (Phase 2) — unblocks US1 and US2. (US3 does not need
   to wait for this and may already be in progress.)
3. Complete US1, US2 and US3 in any order (or in parallel, per the dependency
   graph above) — each is independently testable and ships value on its own:
   US1 alone already fixes the cashier-visible half of the origin complaint,
   US2 alone the back-office half, and US3 is a standalone bug fix unrelated
   to either.
4. Complete Polish (Phase 6) once all three stories are done.

### Suggested order for a single developer

Foundational → US3 (smallest, fully isolated, proves the pattern) → US1 →
US2 (near-mechanical repeat of US1 once it exists) → Polish.

## Notes

- [P] tasks touch different files with no unmet dependency.
- [Story] labels map each task to spec.md's US1/US2/US3 for traceability.
- Every task that adds an `excludeOrigin`/`hide*` parameter must leave the
  default (unset) request byte-identical to today's — this is FR-012 and is
  worth re-checking by hand at T014/T023, not just trusting the unit tests.
- Commit after each task or logical group.
- Avoid: sending the inclusive `origin` query parameter anywhere (contracts/origin-filter.md §1); widening either table past the point an overflow test can prove safe (fall back to the icon-only chip per contracts/origin-filter.md §5 instead).
