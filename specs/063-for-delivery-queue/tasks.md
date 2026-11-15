---
description: "Task list for 063-for-delivery-queue"
---

# Tasks: For Delivery Queue

**Input**: Design documents from `specs/063-for-delivery-queue/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R12), data-model.md, contracts/ui-contracts.md (C1–C9), quickstart.md, wireframes.md (its Open Questions are resolved in research R5, R9, R10)

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates and research R12 require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US3, spec.md). US1 (see today's pending deliveries, P1) is the MVP: it adds the data layer, the screen, the navigation entry and the route, with the period fixed at Hoy. US2 (P2) adds the period filter panel. US3 (P2) makes rows open the order. Phase 2 holds what the stories share, including the filter state, because the controller is keyed by it.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 see today's pending deliveries · US2 look ahead and behind (period filter) · US3 open the delivery order behind a line

## Cross-story notes

- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/sales/presentation/for_delivery/pending_deliveries_screen.dart`: T012 (US1) creates it, then T017 (US2) adds the filter button and panel and T019 (US3) adds the row tap.
  - `test/widget/features/sales/pending_deliveries_screen_test.dart`: T015 (US1) creates it; T018 (US2) and T020 (US3) extend it.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: every key is added once, in T002. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
- **Generated code.** After editing a `@riverpod` or `@freezed` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once. No client regeneration is needed: `DeliveryItinerariesApi` already has `pendingDeliveriesApiV1DeliveryItinerariesDeliveriesGet(skip, limit)` returning `PendingDeliveriesResponse` (`buckets`: `key`, `date`, `total`, `items`; each item is a `PendingDeliveryLine`).
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Dates and quantities** go through `formattersProvider` (`display.date`, `display.quantity`; constitution §V). No `DateFormat`, no `toStringAsFixed`.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Never match server prose** (§III). The endpoint returns only the generic `auth.*` codes, already localized; show failures through `CatalogListStateView`'s error state.
- **No facility guard on purpose.** The endpoint lists every active facility and takes no facility parameter. Don't copy the facility guard from the delivery orders list controller (R4).
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`.
- **Don't regress specs 061/062.** T007 refactors `DeliveryOrderShipTo`. `test/widget/features/sales/delivery_orders_list_screen_test.dart`, `delivery_order_detail_screen_test.dart` and `delivery_order_approval_screen_test.dart` must keep passing unchanged.
- **Mirror, don't copy blindly.** Closest precedents:
  - Queue screen and controller: `sales/presentation/delivery_order_approval/{delivery_order_approval_screen, delivery_order_approval_queue_controller}.dart` (spec 062), built on `fetchClampedPage` in `lib/core/widgets/catalog_pagination.dart`.
  - Filter state, URL round trip, filters button, panel and dropdown facet: `sales/presentation/delivery_orders/{delivery_orders_filter, delivery_orders_list_screen}.dart` (spec 061).
  - Name cells: `sales/presentation/delivery_orders/delivery_order_name_cells.dart`. Warehouse by id: `warehouseDisplayNameProvider` in `lib/features/catalog/data/warehouse_repository_impl.dart`.
  - Repository and provider shape: `sales/data/delivery_order_admin_repository_impl.dart`.
  - Live test: `integration_test/delivery_order_approval_quickstart_test.dart`.

---

## Phase 1: Setup

- [X] T001 Confirm the starting point: on branch `063-for-delivery-queue`, run `flutter analyze` and `flutter test test/unit/features/sales test/widget/features/sales`, and note anything already failing so it isn't blamed on this feature. (Spec 062's notes list 7 failures already present on clean HEAD: 6 `core_widgets` goldens and the `pos_screens` screenshot "sales list desktop".) No file changes.

---

## Phase 2: Foundational (blocks every story)

**Purpose**: strings, the domain types, the repository, the filter, the controller, and the two name cells. Nothing here is user-visible on its own.

- [X] T002 Add every new string to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`, each with an `@key` description starting `spec 063:`, then run `flutter gen-l10n`. Use the `forDelivery…` prefix (C9) for: the nav label and screen title ("Por entregar" / "For delivery"); the filter label ("Periodo" / "Period"); the six period names (Anteriores, Ayer, Hoy, Mañana, Pasado mañana, Posteriores / Earlier, Yesterday, Today, Tomorrow, Day after tomorrow, Later); the panel item formats with placeholders (`{label} · {date} ({total})` and `{label} ({total})`); "Sin fecha" / "No date"; the empty text ("No hay entregas pendientes para este periodo." / "No deliveries pending for this period."); and the column headers "Prio.", "Producto", "Almacén", "Pendiente" where no spec 061 key already says the same (`deliveryOrderColumnSerial`, `deliveryOrderColumnCustomer`, `deliveryOrderColumnDestination` and `deliveryOrderColumnScheduled` exist; reuse them). Reuse the existing filters, "Clear all", "Apply" and retry keys the delivery orders list uses rather than adding duplicates.
- [X] T003 Create `lib/features/sales/domain/entities/pending_delivery.dart` (data-model §1–2): the `PendingDeliveryPeriod` enum (`earlier`, `yesterday`, `today`, `tomorrow`, `dayAfter`, `later`, in that order) with `key` (the server's bucket key, `day_after` for `dayAfter`) and `fromKey(String?)` returning `today` for null or unknown; the `PendingDeliveryLine` entity with the fields in data-model §2, `PendingDeliveryLine.fromResponse(api.PendingDeliveryLine)` and `openQuantity` kept as the server's decimal string; and `PendingDeliveriesResult`, a map from period to a record of `(DateTime? date, int total, List<PendingDeliveryLine> items)`. The generated bucket `date` is a `Date?` (not `DateTime?`); convert it to a `DateTime` when mapping (data-model §3). Follow the style of `destination.dart` (plain Dart or freezed, whichever the neighbours use). A bucket key the client doesn't know is ignored when mapping.
- [X] T004 Create the repository: `lib/features/sales/domain/repositories/delivery_itinerary_repository.dart` with `DeliveryItineraryRepository.pendingDeliveries({required int skip, required int limit}) → Future<PendingDeliveriesResult>` (C6, doc comment naming the endpoint), and `lib/features/sales/data/delivery_itinerary_repository_impl.dart` with the impl over `DeliveryItinerariesApi` plus `deliveryItineraryRepositoryProvider`, built like `DeliveryOrderAdminRepositoryImpl` (same Dio provider, same error mapping). Send no facility. Needs T003.
- [X] T005 Create `lib/features/sales/presentation/for_delivery/pending_deliveries_filter.dart` (data-model §4, R3): a `@freezed` `PendingDeliveriesFilter` with `period` (default `today`) and `pageIndex`; `fromQuery(ListQuery)` reading facet `period` through `PendingDeliveryPeriod.fromKey`; `toQuery()` omitting the facet when `today`; `activeFilterCount` (1 when `period != today`); `isNarrowed`; `cleared()`. Also export `const forDeliveryPath = '/sales/for-delivery'`. Run build_runner. Needs T003.
- [X] T006 Create `lib/features/sales/presentation/for_delivery/pending_deliveries_controller.dart` (C7, R4): `PendingDeliveriesView` (`periods`: six `PendingDeliveryPeriodSummary(period, date, total)` in display order, and `page`: `CatalogPage<PendingDeliveryLine>`), and the `@riverpod` `PendingDeliveriesController`, an `AsyncNotifier` family keyed by `(PendingDeliveryPeriod period, int pageIndex)`, page size 20. `build` uses `fetchClampedPage` with a `fetch` that calls `pendingDeliveries(skip: pageIndex * 20, limit: 20)`, takes the selected period's items and total for the `CatalogPage`, and builds all six summaries from the same response. In the same file, add the `@Riverpod(keepAlive: true)` `LastPendingDeliverySummaries` notifier (state `List<PendingDeliveryPeriodSummary>?`, `null` initially, a `set` method); after each successful load the controller writes its summaries there, so the panel's counts survive a period change (R5, C7). The doc comment states the endpoint is cross-facility by design and has no facility parameter, so there is no client guard (R4). Run build_runner. Needs T004 and T005.
- [X] T007 [P] Edit `lib/features/sales/presentation/delivery_orders/delivery_order_name_cells.dart` (C8, R7): extract `DeliveryOrderShipTo`'s delivery branch (the saleCustomerController lookup of the address label) into a public `DeliveryOrderCustomerAddress({customerId, shipToId, truncate = true})` that shows the placeholder for a null id, and make `DeliveryOrderShipTo` call it. No visible change on specs 061/062 screens. Add a short widget test for the new cell (label found, id not found falls back to `#id`, null id shows the placeholder) to the existing name-cells test file if one exists, otherwise to `test/widget/features/sales/delivery_order_name_cells_test.dart`.
- [X] T008 [P] Create `test/unit/features/sales/delivery_itinerary_repository_impl_test.dart`: `pendingDeliveries` sends `skip` and `limit` and no other query parameter; maps all six buckets with their `date` and `total`; maps a line including a null `serial`, null `ship_to`, null `date` and a decimal-string quantity; ignores an unknown bucket key.
- [X] T009 [P] Create `test/unit/features/sales/pending_deliveries_filter_test.dart` (templated on `delivery_orders_filter_test.dart`): absent or unknown `period` parses to `today`; each server key round trips through `toQuery`/`fromQuery`; `today` is omitted from the URL; `activeFilterCount` is 0 for `today` and 1 otherwise; `cleared()` returns the default; the page index is read from the query.
- [X] T010 [P] Create `test/unit/features/sales/pending_deliveries_controller_test.dart` (templated on `delivery_order_approval_queue_controller_test.dart`): the offset and limit sent; the selected period's items and total become the page, and the other five periods appear only as summaries with their dates and totals; the clamp back to the last non-empty page when a later page comes back empty with a non-zero total; no facility is sent; a successful load writes its summaries to `LastPendingDeliverySummaries`, and a failed load leaves the previous ones in place.

**Checkpoint**: `flutter analyze` is clean and `flutter test test/unit/features/sales` passes.

---

## Phase 3: User Story 1 — See today's pending deliveries (P1) 🎯 MVP

**Goal**: A warehouse coordinator opens "Por entregar" and sees today's pending delivery lines, highest priority first, with the open quantity of each, paginated.

**Independent Test** (spec US1): with a delivery order scheduled for today in En preparación with two lines, open "Por entregar" as a user with ForDeliver read. The list shows both lines with their full quantities, no filter badge, and the footer total includes them.

- [X] T011 [US1] Edit `lib/core/navigation/nav_destinations.dart` (C1): add `NavBranch.forDelivery = 28` with a doc comment in the style of its neighbours, a `_forDeliveryLabel(AppLocalizations l10n)` function beside `_deliveryOrderApprovalLabel`, and a `NavDestination(id: 'for-delivery', route: '/sales/for-delivery', icon: Icons.local_shipping_outlined, selectedIcon: Icons.local_shipping, branchIndex: NavBranch.forDelivery, gate: PrivilegeGate(SystemObject.forDeliver, AccessRight.read))` in the `logistics` group right after `delivery-order-approval`. Comment that it is gated on 91 read, matching the server's pending-deliveries endpoint. Until T013 adds the router branch, the destination points at a branch that doesn't exist, so do T013 right after T012 and don't run the nav or router tests in between.
- [X] T012 [US1] Create `lib/features/sales/presentation/for_delivery/pending_deliveries_screen.dart` (C2, C4, C5): `PendingDeliveriesScreen(query)`. Parse `PendingDeliveriesFilter.fromQuery(query)`; watch `pendingDeliveriesControllerProvider(filter.period, filter.pageIndex)`; render `CatalogListStateView<PendingDeliveryLine>` (loading, error with retry that invalidates the provider, empty with the T002 message and no clear button yet) over a `DataTableView<PendingDeliveryLine>` with key `for_delivery_table` and the eight columns of C4 in order: Folio (placeholder when `serial` is null), Cliente (`DeliveryOrderCustomerName`), Destino (`DeliveryOrderCustomerAddress`, dropped when compact), Programada (`display.date`, or "Sin fecha" when null), Prio. (right-aligned), Producto (`"$code $name"`, truncated), Almacén (`WarehouseNameById` in `delivery_order_name_cells.dart`, over `warehouseDisplayNameProvider`, falling back to `#id`; placed there rather than private to the screen so it reuses the file's `_NameText` and `_resolved`), Pendiente (`display.quantity(openQuantity)`, right-aligned). Pagination through `CatalogPagination` over `view.page`, page changes via `context.go(filter.copyWith(pageIndex: …).toQuery().toUri(forDeliveryPath))`. Use `CatalogFilterBar` with no search and no filters yet (T017 adds the button). No row actions, no `onRowTap` yet. Spacing from tokens.
- [X] T013 [US1] Edit `lib/app/router/app_router.dart` (C1): append a `StatefulShellBranch` (index 28) with a `GoRoute` at `forDeliveryPath` building `PendingDeliveriesScreen(query: ListQuery.fromUri(state.uri))`, commented like the neighbours, and a `_routeGate` clause `location.startsWith(forDeliveryPath)` returning `PrivilegeGate(SystemObject.forDeliver, AccessRight.read)`. Needs T011 and T012.
- [X] T014 [P] [US1] Extend `test/unit/core/navigation/nav_destinations_test.dart` (the `NavBranch` pin gets `forDelivery == 28`; the entry appears after Aprobación de entregas only with 91 read) and `test/unit/app/router/app_router_test.dart` (the branch exists; `/sales/for-delivery` redirects without 91 read and opens with it). Mirror what spec 062 added for `deliveryOrderApproval`.
- [X] T015 [US1] Create `test/widget/features/sales/pending_deliveries_screen_test.dart` (templated on `delivery_order_approval_screen_test.dart`): populated rows show folio, customer, ship-to, scheduled date, priority, product code and name, warehouse and the formatted open quantity; a line with no date says "Sin fecha"; a null serial shows the placeholder; names fall back to `#id` without Customers or Warehouses read; the controller is asked for period `today` (badge assertions belong to T017, once the button exists); the pagination footer shows the period's total and a page change keeps the period; the empty message appears for an empty page; the error state retries; no action column and no search box; compact layout renders cards without Destino. Needs T012.

**Checkpoint**: US1 works alone. A user can open "Por entregar" and see today's pending lines. Run `flutter test test/unit test/widget` for the touched files.

---

## Phase 4: User Story 2 — Look ahead and behind (P2)

**Goal**: The coordinator opens the filters, sees every period's count, and picks Anteriores, Ayer, Mañana, Pasado mañana or Posteriores.

**Independent Test** (spec US2): with pending lines scheduled three days ago, yesterday, tomorrow, the day after and a week from now, the filter panel shows each period's count, and picking each period lists its line with its scheduled date.

- [X] T016 [US2] Edit `lib/features/sales/presentation/for_delivery/pending_deliveries_screen.dart` (C2, C3, R5): add to the `CatalogFilterBar` the badged filters button (`Badge.count(count: filter.activeFilterCount)` over `IconButton.outlined(Icons.tune)`, key `for_delivery_filter_button`) opening `showCatalogFilterSheet` with `onClearAll: () => context.go(forDeliveryPath)`, as in `delivery_orders_list_screen.dart`. The builder is `CurrentListQueryBuilder` → a private `_PendingDeliveriesFiltersPanel` with one `DropdownButtonFormField<PendingDeliveryPeriod>` (key `for_delivery_period_filter`, label from T002, wrapped in `KeyedSubtree(ValueKey(period))`, no "all" item). Item text follows C3: `label · date (total)` for single-day periods using `display.date`, `label (total)` for Anteriores and Posteriores, counts and dates read from `LastPendingDeliverySummaries` (no new request), so they stay visible while a newly picked period loads; labels only while it is still `null`. Selecting goes to page 0 with the new period, dropping the facet for Hoy. Also set the empty state's `isFiltered: filter.isNarrowed`, `clearFiltersLabel` and `onClearFilters` (back to the default path) so a non-Hoy empty period shows the shared filtered-empty state with its clear button.
- [X] T017 [US2] Extend `test/widget/features/sales/pending_deliveries_screen_test.dart`: the badge shows 1 for a non-Hoy period and nothing for Hoy; the panel lists six options in order with counts, and dates on the four single-day ones; selecting a period navigates to its URL at page 0, and selecting Hoy drops the facet; "Borrar todo" returns to the default path; Anteriores and Posteriores lines show their scheduled date, and a null date shows "Sin fecha"; an unknown `?period=` value shows Hoy; an empty non-Hoy period shows the shared filtered-empty state and its clear button (back to Hoy), an empty Hoy shows the "no deliveries pending" message and no button; before any load has succeeded the panel shows labels without counts; after picking another period, the panel still shows the previous counts while the new period loads.

**Checkpoint**: US1 and US2 both work. The coordinator can see and pick any period.

---

## Phase 5: User Story 3 — Open the delivery order behind a line (P2)

**Goal**: Tapping a row opens the delivery order's detail screen (spec 061), and returning reloads the queue on the same period and page.

**Independent Test** (spec US3): as a user with ForDeliver read and Delivery Orders read, tap a row, check the matching order opens, go back, and check the period and page are kept.

- [X] T018 [US3] Edit `lib/features/sales/presentation/for_delivery/pending_deliveries_screen.dart` (R6, R8, FR-009): set `onRowTap` to `(line) => context.push('$deliveryOrdersPath/${line.deliveryOrderId}').then((_) => ref.invalidate(pendingDeliveriesControllerProvider(filter.period, filter.pageIndex)))` only when `can(SystemObject.deliveryOrders, AccessRight.read)`, and leave it null otherwise so rows show no tap affordance. Guard the `.then` with `context.mounted`. Import `deliveryOrdersPath` from the delivery orders list screen.
- [X] T019 [US3] Extend `test/widget/features/sales/pending_deliveries_screen_test.dart`: with 71 read, tapping a row pushes `/sales/delivery-orders/<id>` for that line's order, and on return the controller is refetched with the same period and page; without 71 read, rows are not tappable (no hover affordance) and everything else still renders.

**Checkpoint**: all three stories work. The whole spec is built.

---

## Phase 6: Polish and cross-cutting

- [X] T020 [P] Create `integration_test/for_delivery_quickstart_test.dart` (templated on `integration_test/delivery_order_approval_quickstart_test.dart`, with the `reference_macos_integration_test_traps` conventions: frame-stall watchdog, hitTestable login, finders for the filter button and dropdown). Read-only: log in with the `MBE_POS_*` admin account, open `/sales/for-delivery`, check the screen loads, open the filter panel, check the six periods appear with counts that match a direct call to the endpoint, pick a period with lines and check its rows appear with their dates. Skip with a message when every period is empty. Needs US1–US3 done.
- [X] T021 Format only the files this feature changed (`dart format <files>`, never the repo, never `lib/generated/`) and run `flutter analyze`. It must be clean.
- [X] T022 Run the full suite, `flutter test`, and confirm it passes apart from the known pre-existing failures noted in T001, with spec 061/062 tests untouched. Fix any regression from T007 at its cause.
- [X] T023 Run the live quickstart: `flutter test integration_test/for_delivery_quickstart_test.dart -d macos`. Record the result and which periods held lines.
- [ ] T024 (tracked in mictlanix/mbe-ui#247) Walk the manual quickstart steps (quickstart.md 1–11) that the automated tests don't cover: the real navigation entry, returning from an order after cancelling or approving it, the compact tier and the filter bottom sheet, and the largest text size. Time SC-001 (today's lines and every period's count within 5 seconds of opening). For SC-005, compare two or three periods against the legacy "Por entregar" screen on the same data: same lines (apart from counter pickups), same priority order, same remaining quantities. Record anything found.
- [X] T025 Write `specs/063-for-delivery-queue/pr-description.md`: a summary, the Roadmap section (`Closes mictlanix/mbe-roadmap#40`), the test evidence from T022 and T023, the manual checks left, and the follow-ups worth filing: scoping the queue to the user's facility needs an mbe-api facility parameter, and "Add to itinerary" belongs to mictlanix/mbe-roadmap#41.

---

## Dependencies and execution order

**Phases.** Setup (T001) → Foundational (T002–T010) → US1 → US2 → US3 → Polish. The stories share the screen file and its test file, so they run in order, not in parallel.

**Inside Foundational.**
- T003 before T004, T005, T006 (the types). T004 and T005 before T006.
- T002 is independent of the code but T012 and T016 need its keys.
- T007 is independent of everything else in the phase, but T012 needs it.
- T008 needs T004. T009 needs T005. T010 needs T006.

**Inside the stories.**
- US1: T011 and T012 need Foundational. T013 needs T011 and T012. T014 needs T011 and T013. T015 needs T012.
- US2: T016 needs T012. T017 needs T016 and T015.
- US3: T018 needs T012. T019 needs T018 and T015.
- T020 needs US1–US3 done.

```text
T001 → T002
T003 ─┬─ T004 ─┬─ T006 → T010
      │        └─ T008
      └─ T005 ─┬─ T006
               └─ T009
T007
Foundational ─→ T011 ─→ T013 ─→ T014
             ─→ T012 ─↗        ─→ T015
T012 → T016 → T017
T012 → T018 → T019
All stories ─→ T020 → T021 → T022 → T023 → T024 → T025
```

## Parallel opportunities

- **Foundational:** T002, T003 and T007 can start together. After T003, T004 and T005 run together. T008, T009 and T010 each run as soon as their code exists.
- **US1:** T011 runs beside T012 (different files). T014 runs beside T015.
- **Polish:** T020 can be written while T021–T022 run on the rest.

## Implementation strategy

**MVP.** Phases 1, 2 and US1 (T001–T015). A coordinator can open "Por entregar" and see today's pending lines with their open quantities. That alone replaces the legacy screen's default tab.

**Increments.**
1. Add US2 (T016–T017): the period filter, which gives tomorrow, the day after, yesterday and the overdue and later buckets, with counts.
2. Add US3 (T018–T019): row tap to the order, and reload on return.
3. Finish with Polish (T020–T025): the live test, formatting, the full run, and the PR description.

**Risks to watch while implementing.**
- T007 refactors a spec 061 cell that specs 061 and 062 screens use. Run their screen tests right after the edit.
- The server pages all six buckets together, so a page past the end of the selected period may still carry items for another. The controller must clamp on the **selected** period's page only (T006, T010).
- The live test depends on delivery orders in En preparación (30240 and 30242 on the local tenant). If every period is empty, say so in the result rather than counting a skip as a pass.
