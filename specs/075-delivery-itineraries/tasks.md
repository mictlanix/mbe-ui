---
description: "Task list for 075-delivery-itineraries"
---

# Tasks: Delivery Itineraries

**Input**: Design documents from `specs/075-delivery-itineraries/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R15), data-model.md, contracts/ui-contract.md, contracts/repository.md, contracts/error-messages.md, quickstart.md, wireframes.md

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US5, spec.md).
- **P1 (the MVP)**: US1 plan a trip and load it, US2 send the truck out, US3 close each stop.
- **P2**: US4 find trips (the filter drawer and states), US5 print.

Phase 2 holds what two or more stories share: the error messages, strings, entities, repository, lookups, status chips, controllers and the actions notifier. The trip is reached from the list, so US1 also creates the list screen as a plain paginated table with "Nuevo itinerario". US4 adds the filter drawer and the list's states on top of it.

**Wireframe open questions 1–3 were not answered when this was generated.** The tasks follow the wireframes' assumptions. Change the tasks named here if the answer differs:
- Q2 ("Nada entregado" needs a reason on every line): one reason picker per line, no "reason for all" control (T027).
- Q4 (unloaded lines on an open stop): the stop card lists loaded lines only (T019).
- Q3 (unit column) is resolved: #343 shipped with the line's unit, so Unidad shows its symbol (T019).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 plan and load · US2 depart · US3 close stops · US4 find trips · US5 print

## Cross-story notes

- **This feature builds on specs 061–063.** `lib/features/sales/` already has the delivery-order screens, repositories and tests. Before writing an itinerary file, open its delivery-order counterpart and mirror it: `delivery_order_detail_screen.dart`, `delivery_order_actions.dart`, `delivery_orders_list_screen.dart`, `delivery_order_status_chip.dart`, `delivery_order_dialogs.dart`, `pickup_dialog.dart` (the image picker), and their tests. The 063 `DeliveryItineraryRepository` is extended, not replaced.
- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/sales/presentation/delivery_itineraries/delivery_itinerary_detail_screen.dart`: T016 (US1) creates it with the header band, stops and the Abierto controls. T024 (US2) adds Dar salida and Cancelar itinerario, T028 (US3) adds Cerrar parada and the closed-stop view, and T033 (US5) adds the print buttons. Every control is a nullable callback or a collection-`if`, so an absent right means the control is not in the tree.
  - `lib/features/sales/presentation/delivery_itineraries/itinerary_dialogs.dart`: T021 (US1) creates it with the quantity, release and remove-stop prompts, and T023 (US2) adds the depart and cancel prompts.
  - `lib/features/sales/presentation/delivery_itineraries/delivery_itineraries_list_screen.dart`: T014 (US1) creates it, and T030 (US4) adds the filter drawer and states.
  - `lib/app/router/app_router.dart` and `lib/core/navigation/nav_destinations.dart`: T012 (US1) adds the list branch, the nav entry, the detail route and the gate.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: T003 adds the error-message keys and T004 adds every itinerary key once. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
  - `test/widget/features/sales/delivery_itinerary_harness.dart`: T011 creates it, and later tests only use it.
- **mbe-api#343 shipped** (2026-11-18, mbe-api#344), and the client was regenerated in a8290511. Names come from the server: there are no vehicle, operator, warehouse or stop→order lookups and no session memory (research R2–R3). The one stop case left is a legacy stop with no stored order (R2). Migration 036 is applied on mbe_dev (2026-11-18). T002 confirms it from the API.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once: tasks that both need it are not marked [P] against each other. Regenerating the API client is only for T002, with `tool/generate_api_client.sh`.
- **Generated method names are long** (for example `pendingDeliveriesApiV1DeliveryItinerariesDeliveriesGet`). Read the exact names from `lib/generated/openapi/lib/src/api/delivery_itineraries_api.dart` and never guess them.
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Quantities and dates** go through `formattersProvider` (constitution §V). No `NumberFormat`, no `toStringAsFixed`. Quantities are `Decimal`, never `double`; the wire carries them as strings.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Never match or show server prose** (§III). Show refusals through `AppError.localizedMessage` / `ErrorBanner`, which build the text from the error's `code`. Recognition keys on the code. The server's licence warning (`warnings`) is never shown.
- **Status, outcome and reason names come from l10n**, never from `enum.name`.
- **Row icons (§VI document reading).** List rows have no icons, and only loaded-line rows on an Abierto stop get ✎ and 🗑. This is intentional; see the Complexity Tracking row in plan.md. Don't add a row Edit icon or a View toggle. The AppBar has no actions.
- **Rights.** Every control follows the availability table in data-model.md and the rights lines in contracts/ui-contract.md. A missing right means the control is absent, never disabled. The one disabled control is Dar salida's guard, and its reason is shown. Document the system-object codes (DeliveryItineraries = 87, DeliveryOrders = 71) in a comment where a route, nav entry or control is gated.
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`.
- **Closest precedents**:
  - Repository: `data/delivery_itinerary_repository_impl.dart` (063) and `data/delivery_order_admin_repository_impl.dart` (the multipart `confirmPickup`).
  - Test builders: the delivery-order tests under `test/unit/features/sales/`. Widget wiring: `test/widget/features/sales/delivery_order_detail_screen_test.dart`.
  - Printing: `delivery_order_print.dart` and `delivery_order_print_test.dart`.
  - Live test: `test/integration/` (a spec 070 or 072 live test, for the runtime-discovered fixtures). Device test: `integration_test/delivery_orders_quickstart_test.dart`.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable, and a check that the dev server runs #343.

- [ ] T001 Run `flutter analyze` and the tests this feature touches: all of `test/unit/features/sales/` and `test/widget/features/sales/`, plus `test/unit/core/errors/catalog_coverage_test.dart`, `test/unit/core/navigation/nav_destinations_test.dart`, `test/unit/app/router/app_router_test.dart`, `test/unit/core/documents/` and `test/unit/core/formatting_guard_test.dart`. Record any failure that predates this feature, so it isn't blamed on the new code.
- [ ] T002 Confirm the dev server serves #343. Read one itinerary with a stop (`GET /delivery-itineraries/{id}`): the stop has `delivery_order` and the lines have `product_name`. The user reported migration 036 applied on 2026-11-18. If the fields are still missing, stop and tell the user before T035/T038/T039. The unit and widget work doesn't need the server. The client is already regenerated (a8290511): don't regenerate, and never hand-edit `lib/generated/`. Record the date checked under R2 in `specs/075-delivery-itineraries/research.md`.

---

## Phase 2: Foundational (blocks all user stories)

**Purpose**: the error messages, strings, entities, repository, lookups, chips, controllers and actions that two or more stories share.

- [ ] T003 Localize the itinerary error codes (research R13, contracts/error-messages.md "New" and "Resources"). Mirror how `delivery_order.quantity_exceeds_remaining` is wired end to end.
  - In `lib/core/errors/localize_problem.dart`:
    - add the 15 codes to `localizedErrorCodes` and the `switch`: `itinerary.not_open`, `itinerary.not_departed`, `itinerary.cancelled`, `itinerary.nothing_committed`, `itinerary.lines_overcommitted`, `itinerary.stop_already_resolved`, `itinerary.stop_lines_incomplete`, `itinerary.stop_lines_malformed`, `itinerary.stop_delivered_exceeds_sent`, `itinerary.stop_shortfall_needs_reason`, `vehicle.open_itinerary_exists`, `delivery_order.not_in_preparation`, `delivery_order.pickup_not_loadable`, `delivery_order_line.nothing_to_load` and `delivery_order_line.quantity_unavailable`;
    - quantities (`available`, `requested`, `sent`, `delivered`) go through the shared formatter; `status` uses the itinerary or delivery-order status label;
    - `line_id` and the `lines` list in `lines_overcommitted` resolve to a product name when the caller supplies a lookup, and fall back to the number;
    - add resource nouns `delivery_itinerary_stop` (parada, feminine) and `delivery_itinerary_line` (partida del itinerario, feminine) beside the existing `delivery_itinerary` (lines ~801 and ~863), and make sure `delivery_itinerary` also works for `resource.not_found`.
  - Add the es and en text (Spanish is in contracts/error-messages.md) to `lib/l10n/app_es.arb` and `app_en.arb`, then `flutter gen-l10n`.
  - In `test/unit/core/errors/problem_fixtures.dart`, add a fixture for each code. In `test/unit/core/errors/catalog_coverage_test.dart`, add `delivery_order_line.quantity_unavailable`, `itinerary.stop_delivered_exceeds_sent`, `itinerary.stop_shortfall_needs_reason`, `vehicle.open_itinerary_exists` and `delivery_order.not_in_preparation` to the `needParams` set, and change `expect(checked, 191)` to `206`.
  - In `specs/058-localized-api-errors/contracts/code-scope.tsv`, switch the 15 `code` rows to `IN` and fill their route and note columns, as the neighbouring `IN` rows do ("reachable from the Itinerarios screens (spec 075)"). Add `resource` rows for `delivery_itinerary_stop` and `delivery_itinerary_line`, and a `resource.not_found` row for `delivery_itinerary`.
  - **Check:** `flutter test test/unit/core/errors/` passes, including `catalog_coverage_test.dart`.
- [ ] T004 Add every itinerary string to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`, then run `flutter gen-l10n`. Each key gets an `@key` description starting "spec 075". Cover:
  - the nav label "Itinerarios", screen titles and column headers;
  - the four trip statuses, four stop outcomes and five shortfall reasons (data-model.md);
  - every action, dialog title, field label, helper text and confirmation text in ui-contract.md and wireframes.md;
  - the licence warning (placeholders for operator and date), the depart guard captions ("Nada cargado" and "La parada {n} no tiene nada cargado"),  the cancelled-trip line, and "cerrada {hora}";
  - the close-dialog "what's missing" lines (receiver, ID, proof, a reason for {product}).
  - **Check:** `flutter gen-l10n` runs clean, and no Spanish string is left in English.
- [ ] T005 Create the domain entities in `lib/features/sales/domain/entities/delivery_itinerary.dart` (data-model.md), as `freezed` classes:
  - the enums `ItineraryStatus`, `StopOutcome` and `ShortfallReason`, with the wire numbers;
  - `ItinerarySummary`, `ItineraryPage`, `Itinerary`, `ItineraryStop`, `ItineraryLine`, `StopClosure`, `StopClosureLine` and `ProofImage`;
  - the #343 fields (data-model.md): nullable `vehicleName`, `operatorName`, `warehouseName`, a stop's `deliveryOrderId`, `customerName` and `shipToLabel`, and a line's `unitSymbol`; non-null a stop's `deliveryOrderIds` and a line's `deliveryOrderId`, `productCode` and `productName`;
  - the derived getters on `Itinerary`: `loadedLineCount`, `emptyStops`, `canDepart` and `pendingStops`.
  - Run build_runner.
- [ ] T006 Extend the repository (contracts/repository.md): the interface `lib/features/sales/domain/repositories/delivery_itinerary_repository.dart` and the implementation `lib/features/sales/data/delivery_itinerary_repository_impl.dart`.
  - Add the 13 methods in the contract table. Keep `pendingDeliveries` unchanged.
  - Map the DTOs to the entities with an **exhaustive** enum mapping. An unknown wire value is `AppError.server()`. Map the #343 fields (stop `delivery_order`, `delivery_orders`, `customer_display_name`, `ship_to_label`; line `delivery_order`, `product_code`, `product_name`, `unit_of_measurement.symbol`; summary and detail `vehicle_name`, `vehicle_operator_name`, `warehouse_name`).
  - Ignore the response's `warnings` (R4).
  - `closeStop` posts the generated multipart call: `lines` is `jsonEncode` of `[{line, delivered_quantity (decimal string), reason_code (wire int or null)}]` and `image` is `MultipartFile.fromBytes(bytes, filename: …)`. Deserialize with `appSerializers`, never the raw `standardSerializers` (§III, spec 043).
  - Map `DioException` to `AppError` with the shared mapper.
- [ ] T007 [P] Test the repository: create `test/unit/features/sales/delivery_itinerary_fixtures.dart` (builders for the entities and the generated DTOs) and extend `test/unit/features/sales/delivery_itinerary_repository_impl_test.dart` (the 063 file). Cover:
  - the exhaustive enum mapping and the unknown-value case;
  - each method's path, verb and query or body (`commitLine` always sends the quantity; `updateHeader` sends only changed fields);
  - the `closeStop` `lines` JSON and that `image` is a real file part, not a plain field;
  - `warnings` ignored;
  - `DioException` → `AppError`, including a coded 409 and 422.
- [ ] T008 [P] Create the lookups, `lib/features/sales/presentation/delivery_itineraries/itinerary_lookups.dart`, and `test/unit/features/sales/itinerary_lookups_test.dart` (research R2, R4, contracts/repository.md):
  - `itineraryOrderProvider.family(orderId)`: one cached `DeliveryOrderAdminRepository.getById`. It's used only on an Abierto trip, for open quantities.
  - `vehicleOperatorProvider.family(id)`: the operator's licence expiry, from the catalog `VehicleOperatorRepository`.

  A failed or forbidden lookup returns null. The caller then shows "—" for open quantities, and no licence warning. Test caching per id and the null case.
- [ ] T009 [P] Create the chips, `lib/features/sales/presentation/delivery_itineraries/itinerary_status_chip.dart`: `ItineraryStatusChip` (four tones) and `StopOutcomeChip` (four tones), both built on the shared `StatusChip`, with labels from l10n. Test in `test/widget/features/sales/itinerary_status_chip_test.dart`: every value renders its own label, and none shows the enum name.
- [ ] T010 Create the controllers and actions in `lib/features/sales/presentation/delivery_itineraries/`, mirroring `delivery_order_detail_controller.dart` and `delivery_order_actions.dart`:
  - `delivery_itinerary_detail_controller.dart`: `AsyncNotifier` family by id.
  - `delivery_itinerary_actions.dart`: a `keepAlive` notifier with `create`, `updateHeader`, `addStop`, `removeStop`, `commitLine`, `commitWholeOrder`, `adjust`, `release`, `depart`, `cancel` and `closeStop`. Each returns `AppError?` (`create` returns the new id or an error). On success it sets the detail controller's state to the returned trip, invalidates the list controller and the touched `itineraryOrderProvider` entries, and, after `depart`, `cancel` or `closeStop`, invalidates the 061 delivery-order list and detail providers and the 063 pending queue (R10). A network failure returns the "result unknown" error and reloads the trip.
  - Run build_runner, then add `test/unit/features/sales/delivery_itinerary_actions_test.dart`: each action calls the repository and updates the detail state without an extra GET, a refusal returns the error and reloads, the 061 and 063 providers are invalidated after depart, cancel and close.
- [ ] T011 [P] Create the widget harness, `test/widget/features/sales/delivery_itinerary_harness.dart`, mirroring how `delivery_order_detail_screen_test.dart` wires its overrides: a mocktail `MockDeliveryItineraryRepository`, the access control with a configurable rights set (87 and 71), the formatters, a router, and overrides for the lookups.

**Checkpoint**: the shared pieces compile, `flutter analyze` is clean, and the unit tests above pass.

---

## Phase 3: User Story 1 — Plan a trip and load it (Priority: P1) 🎯 MVP

**Goal**: a dispatcher creates a trip, assigns vehicle and operator, adds stops from orders in preparation, and loads their lines in full or in part, adjusting or releasing them as needed.

**Independent Test**: seed two delivery orders in En preparación. As a user with create and update on 87, create a trip, set vehicle and operator, add both orders as stops, load one in full and part of the other. Reload and check that the trip shows both stops in order and each line's loaded quantity, and that the orders' open quantities went down. As a user with read only, no control is offered.

- [ ] T012 [US1] Add the navigation and routes (ui-contract "Routes and navigation", depends on T014, T016).
  - In `lib/core/navigation/nav_destinations.dart`, add `NavBranch.deliveryItineraries` (confirm the next free index first; plan says 36, and `inventoryKardex` is 35) and a fourth destination in the `logistics` group, after "Por entregar" (`id: 'delivery-itineraries'`, `Icons.route_outlined` / `Icons.route`, route `/sales/delivery-itineraries`, `PrivilegeGate(SystemObject.deliveryItineraries, AccessRight.read)`). Remove the comment that says itineraries join the group when they ship.
  - In `lib/app/router/app_router.dart`, add the `StatefulShellBranch` at the end, in `NavBranch` order, with the list route and the `:itineraryId` detail route, and the `_routeGate` clause for the `deliveryItinerariesPath` prefix returning `PrivilegeGate(SystemObject.deliveryItineraries, AccessRight.read)`. Put it **before** the `deliveryOrdersPath` clause so the order never depends on how the prefixes overlap.
  - Update `test/unit/core/navigation/nav_destinations_test.dart` (the logistics group's ordered child ids, and the gating cases) and `test/unit/app/router/app_router_test.dart` (a gate case for the new branch): the entry appears after "Por entregar" with read on 87, is absent without it, and the URL is redirected to the home page.
- [ ] T013 [US1] Create the filter and the list controller in `lib/features/sales/presentation/delivery_itineraries/`: `delivery_itineraries_filter.dart` (freezed `DeliveryItinerariesFilter`: status, dateFrom, dateTo, vehicleId, operatorId, warehouseId, page, with URL encoding as in `delivery_orders_filter.dart`) and `delivery_itineraries_list_controller.dart` (`AsyncNotifier`, page size 20, newest first). Run build_runner. Test the filter's URL round-trip and the controller's request in `test/unit/features/sales/delivery_itineraries_filter_test.dart` and `delivery_itineraries_list_controller_test.dart`.
- [ ] T014 [US1] Create the list screen (ui-contract "List screen", wireframes "Screen: Itinerarios list", depends on T013): `delivery_itineraries_list_screen.dart`. Declare `const deliveryItinerariesPath = '/sales/delivery-itineraries';` at the top of this file.
  - `CatalogFilterBar` with **no search control**. Its actions hold "Nuevo itinerario" (`FilledButton.icon`, only with create on 87). The filter button and drawer come in T030.
  - `DataTableView<ItinerarySummary>` with Núm. (right-aligned), Fecha, Vehículo, Operador, Almacén (names from the row, #343; the number when the name is null but the id is set, "—" when there's no id), Estado (`ItineraryStatusChip`), Salida and Regreso (times via `formattersProvider`, "—" when absent). The row tap pushes `'$deliveryItinerariesPath/${id}'`. No row icons.
  - `CatalogPagination`. Loading, empty and error use `CatalogListStateView`.
- [ ] T015 [US1] Create `new_itinerary_dialog.dart` (wireframes "Dialog: Nuevo itinerario"): a `ResponsiveDialog` with date (default today), vehicle, operator (both `CatalogEntityPicker`, each needing read on its catalog) and dispatch warehouse (optional, with the helper text that blank uses the point of sale's), and a comment. Everything is optional. On confirm it calls `create` and opens the new trip. `vehicle.open_itinerary_exists` shows in `FormErrorBanner`, the dialog stays open, and the message names the trip holding the vehicle (US1 scenario 4). Launch it from T014's button.
- [ ] T016 [US1] Create the trip screen (ui-contract "Trip screen", wireframes "Screen: Trip", depends on T010, T018, T019): `delivery_itinerary_detail_screen.dart`. Declare the detail path helper beside the list's constant.
  - The AppBar has a title only. The header band is a `FactStripRow` with status chip, date, vehicle, operator, dispatch warehouse, departure and return times (when set) and the comment.
  - For an Abierto trip with update on 87, the action bar has "Agregar parada" (Dar salida and Cancelar come in T024), and "Editar encabezado" shows in the header (T017).
  - Render one `ItineraryStopCard` per stop, in sequence.
  - `ListStateViews` for loading and error, and a "not found" state that links back to the list (`resource.not_found` with the `delivery_itinerary` noun).
  - A user with read only sees no control (FR-021, SC-006).
- [ ] T017 [US1] Create `itinerary_header_dialog.dart` (wireframes, FR-006): a `ResponsiveDialog` with date, vehicle, operator and comment. The dispatch warehouse isn't editable. Confirm is enabled only when something changed. Wire "Editar encabezado" in T016. Add the licence warning (R4): read the assigned operator through `vehicleOperatorProvider` and, when the expiry is before today, show an `ErrorBanner` in warning tone, "La licencia de {operador} venció el {fecha}" (FR-007), on an Abierto trip. It blocks nothing.
- [ ] T018 [US1] Create `add_stop_dialog.dart` (wireframes "Dialog: Agregar parada", research R5): a `ResponsiveDialog` with `CatalogSearchBar` (folio), a single-select `DataTableView` over `DeliveryOrderAdminRepository.list` filtered to delivery-type orders in En preparación (Folio, Cliente, Dirección, Fecha), pagination, and orders already stops on this trip hidden. The empty state reads "No hay órdenes en preparación." It needs read on 71. Confirm calls `addStop`.
- [ ] T019 [US1] Create `itinerary_stop_card.dart` (wireframes "Trip" and "a stop whose order isn't known"): a titled section per stop.
  - The title has "Parada {n}", the order folio as a link to `/sales/delivery-orders/{id}` (only with read on 71), customer and ship-to. Names come from the stop (#343).
  - On an Abierto stop with update: "Cargar todo", "Cargar línea" and a ⋮ overflow with "Quitar parada".
  - The line table is a non-paginated `DataTableView` with Código, Producto, Unidad (the line's `unitSymbol`), Pendiente (the order line's open quantity) and Cargado. Loaded lines only (wireframe Q4). ✎ and 🗑 sit on each row. Quantities are right-aligned and use `formattersProvider`.
  - A legacy stop with no stored order (`deliveryOrderId == null`) shows "Parada {n}" with the folios from `deliveryOrderIds`. Its lines still show product names. "Cargar todo" and "Cargar línea" first ask for the order (reuse T018's dialog).
- [ ] T020 [US1] Create `load_line_dialog.dart` (wireframes "Dialog: Cargar línea"): a `ResponsiveDialog` listing the stop's order lines with open > 0 (from `itineraryOrderProvider`), a single selection, and a `CompactField` quantity that defaults to the open quantity and is greater than 0 and at most that (FR-010). Confirm calls `commitLine`. "Cargar todo" in T019 calls `commitWholeOrder` after one confirmation.
- [ ] T021 [US1] Create `itinerary_dialogs.dart` with the quantity prompt (✎: quantity at most open + already loaded, calls `adjust`, FR-011), the release prompt (🗑, calls `release`) and the remove-stop prompt (calls `removeStop`, naming what's released). All use `ResponsiveDialog` confirmations and the shared button order.
- [ ] T022 [US1] Test the US1 widgets, using the T011 harness. Create:
  - `test/widget/features/sales/new_itinerary_dialog_test.dart`: everything optional, the warehouse helper text, `vehicle.open_itinerary_exists` keeps the dialog open and names the trip, success opens the trip.
  - `itinerary_header_dialog_test.dart`: the warehouse isn't editable, confirm needs a change, and the licence warning shows for an expired operator and not for a valid one.
  - `add_stop_dialog_test.dart`: only delivery orders in En preparación are requested, orders already on the trip are hidden, folio search, empty state.
  - `load_line_dialog_test.dart`: the default is the open quantity, above-open is refused, lines with open 0 aren't offered, and the quantity prompt's maximum is open + loaded.
  - `delivery_itinerary_detail_screen_test.dart` (Abierto part): rights × status (read-only sees no control), stop cards with names, the legacy stop (title "Parada {n}" with folios), no folio link without read on 71, and ✎ and 🗑 on loaded rows only.
  - `delivery_itineraries_list_screen_test.dart` (the table part): rows, the draft-free columns, no row icons, "Nuevo itinerario" only with create, the null-name fallback, and the compact tier (two-line rows).

**Checkpoint**: US1 is demonstrable on its own: create a trip, add stops, load them, adjust, release and reload.

---

## Phase 4: User Story 2 — Send the truck out (Priority: P1) 🎯 MVP

**Goal**: the dispatcher departs a loaded trip, and can cancel an Abierto one. After departure the load is fixed.

**Independent Test**: depart a loaded trip as a user with update on 87. Check that it shows En ruta with a departure time, that each line's sent quantity equals what was loaded, that its orders are En tránsito, and that no edit, stop or load action remains. Cancel a separate Abierto trip and check that its quantities are open again.

- [ ] T023 [US2] Add the depart and cancel prompts to `itinerary_dialogs.dart` (wireframes "Dialog: Dar salida"): depart shows vehicle, operator or "Sin operador", the stop count and the line count, and says the load can't change afterwards (US2 scenario 1). Cancel names what's released and says the orders stay in En preparación.
- [ ] T024 [US2] In `delivery_itinerary_detail_screen.dart`, add the Abierto action bar's other two controls (FR-012, FR-014):
  - "Dar salida" (`FilledButton`) is enabled only when `canDepart`. While it fails, it is disabled with a caption naming the first empty stop ("La parada {n} no tiene nada cargado") or "Nada cargado todavía".
  - "Cancelar itinerario" (`OutlinedButton`) opens the cancel prompt.
  - After departure the screen shows En ruta, the departure time and each line's sent quantity, with no header edit, stop or load control (FR-013). After cancel it shows the Cancelado state: a single line saying the trip was cancelled before departure.
  - Refusals (`itinerary.lines_overcommitted`, `itinerary.nothing_committed`, `facility.no_in_transit_location`) show through `ErrorBanner`, and the trip reloads. For `lines_overcommitted` pass the product-name lookup from the loaded trip (T003).
- [ ] T025 [US2] Extend `delivery_itinerary_detail_screen_test.dart` and `itinerary_dialogs` tests: the depart guard (nothing loaded, an empty stop, both cleared), the confirmation content with and without an operator, En ruta hides every Abierto control and shows "Salida", Cancelado shows its line and no actions, a refusal reloads the trip, and `lines_overcommitted` names products.

**Checkpoint**: US1 and US2 give a complete plan → depart flow.

---

## Phase 5: User Story 3 — Close each stop with what the customer accepted (Priority: P1) 🎯 MVP

**Goal**: for each pending stop of an En ruta trip, the dispatcher records the receiver, what was delivered per line with a reason for any shortfall, and one proof (an uploaded image or a drawn signature). The trip closes itself after its last stop.

**Independent Test**: depart a trip with two stops. Close one with everything delivered and an uploaded image, and the other with a shortfall, a reason and a drawn signature. Check that each stop shows its outcome, the trip closes with a return time, and the second order shows partially delivered with a child order for the remainder.

- [ ] T026 [US3] Create the signature pad, `lib/features/sales/presentation/delivery_itineraries/signature_pad.dart`, and `test/widget/features/sales/signature_pad_test.dart` (research R9):
  - Capture strokes with a `GestureDetector` pan into a list of paths, draw them on a white canvas with a `CustomPainter` (black ink), and offer "Borrar".
  - Expose `isEmpty` and an async `toPng()` that renders through `PictureRecorder` → `Picture.toImage` → `toByteData(format: png)` at a fixed 1024 × 384 px.
  - The widget fills its width and keeps the fixed aspect ratio.
  - Test that an empty pad is `isEmpty`, a stroke makes it non-empty, "Borrar" clears it, and `toPng()` returns a PNG (the `89 50 4E 47` header) under 2 MB. Use no new package.
- [ ] T027 [US3] Create `close_stop_dialog.dart` (wireframes "Dialog: Cerrar parada", research R8, depends on T026): a `ResponsiveDialog` with three sections split by the M3 divider.
  - **Quién recibió**: name and identification shown, as `CompactField`s, not blank after trimming.
  - **Qué recibió**: one row per loaded line with product, Enviado, and a Delivered field starting at Enviado (0 ≤ delivered ≤ sent), and a reason dropdown (the five reasons) that appears only when delivered < sent. "Todo entregado" and "Nada entregado" set every row. There is no "reason for all" control (wireframe Q2): the user picks a reason per line.
  - **Prueba de entrega**: an M3 `SegmentedButton`, Imagen | Firma. Imagen uses the `FilePicker` flow from `pickup_dialog.dart` (jpg, jpeg, png; at most 2 MB, checked before sending, with `image.too_large` and `image.unsupported_format` shown inline as well). Firma is the T026 pad, rendered with `toPng()` and sent as `firma.png`. Switching keeps each side's input, but only the selected one is sent.
  - "Cerrar parada" stays disabled until FR-016 holds, and a list under the form names what's missing (receiver, ID, proof, a reason for {product}). A server refusal shows in `FormErrorBanner`, and the trip reloads. On the compact tier the dialog goes full screen and each line becomes two rows.
  - Build the `StopClosure` value object and call `closeStop`.
- [ ] T028 [US3] Finish the stop card and the trip screen for departed trips (`delivery_itinerary_detail_screen.dart`, `itinerary_stop_card.dart`, wireframes "En ruta" and "Cerrado"):
  - On an En ruta trip, each pending stop shows "Cerrar parada" (`FilledButton`, update on 87), which opens T027.
  - The line table shows Enviado, and, once the stop is closed, Entregado, Devuelto and Motivo (reason label from l10n).
  - A closed stop shows its `StopOutcomeChip` and "cerrada {hora}" from the stop's `arrivedAt`, plus the order link (US3 scenario 8).
  - When the response shows the last stop resolved, the trip shows Cerrado with its return time, without the user reloading (FR-019). The screen is read-only except for printing.
  - Refusals (`itinerary.stop_already_resolved`, `stop_lines_incomplete`, `stop_delivered_exceeds_sent`, `stop_shortfall_needs_reason`, `lock.busy`) show through `ErrorBanner` and reload the trip.
- [ ] T029 [US3] Test US3: create `test/widget/features/sales/close_stop_dialog_test.dart` and extend `delivery_itinerary_detail_screen_test.dart`.
  - Dialog: delivered starts at sent and is clamped to 0..sent, a reason appears only for a shortfall, "Todo entregado" and "Nada entregado" set every row, confirm stays disabled and the missing list names each gap, the Imagen and Firma proof paths each send exactly one image, an oversized or non-image file is refused before sending, an empty pad is not proof, a refusal shows in the banner, and the compact tier lays out in two-row lines.
  - Screen: a pending stop offers Cerrar parada only on En ruta with update, closed stops show outcome, quantities, reason and "cerrada {hora}", the trip flips to Cerrado with a return time after the last stop, and Cerrado is read-only.
  - Unit: `closeStop` in the actions test sends the `StopClosure` and invalidates the 061 providers.

**Checkpoint**: US1–US3 are the whole planning-to-settlement flow. This is the MVP.

---

## Phase 6: User Story 4 — Find trips (Priority: P2)

**Goal**: a supervisor filters the list of trips by status, date, vehicle, operator and warehouse.

**Independent Test**: seed trips in every status for two vehicles and two warehouses. Open the list as a user with read on 87. Check that it shows them newest first, paginated, that each filter narrows it, and that a row opens the trip.

- [ ] T030 [US4] In `delivery_itineraries_list_screen.dart`, add the filter button and drawer (wireframes "State: filter drawer open", FR-003): the badged `IconButton.outlined(Icons.tune)` in the filter bar's actions, opening `showCatalogFilterSheet` with status chips (Todos, Abierto, En ruta, Cerrado, Cancelado; one at a time), a date range, and `CatalogEntityPicker`s for vehicle, operator and dispatch warehouse, each shown only with read on its catalog (§IV). Apply and Limpiar update the filter and the URL. Add the loading, empty ("Aún no hay itinerarios"), filtered-empty (with "Limpiar filtros") and error states with "Reintentar".
- [ ] T031 [US4] Extend `delivery_itineraries_list_screen_test.dart` (and the filter and controller unit tests): each facet is sent to the repository, the filter badge shows the active count, a picker without catalog read is left out, "Limpiar" returns to the opening state, the empty and filtered-empty states render, a read error shows the banner, and the list has no search control.

**Checkpoint**: US4 completes the list.

---

## Phase 7: User Story 5 — Print the trip's papers (Priority: P2)

**Goal**: print the trip ticket and the delivery notes of an En ruta or Cerrado trip.

**Independent Test**: depart a trip and print both documents as a user with read on 87. Check that each previews and prints, and that neither is offered on an Abierto or Cancelado trip.

- [ ] T032 [US5] Add the two document kinds (research R11): in `lib/core/documents/domain/document_kind.dart` add `itineraryTicket` (`GET /delivery-itineraries/{id}/ticket`) and `itineraryDeliveryNotes` (`/delivery-notes`), both gated on `SystemObject.deliveryItineraries` read, with fallback names `itinerario-<id>.pdf` and `notas-entrega-<id>.pdf`. Route them in `lib/core/documents/data/document_source_impl.dart` through the generated `printItineraryTicket` and `printDeliveryNotes`, checking the PDF header as the other kinds do. Extend the existing document-source test (under `test/unit/core/documents/`) with the two kinds: the route, the gate, the fallback names, and a non-PDF body refused.
- [ ] T033 [US5] Create `itinerary_print.dart` (mirror `delivery_order_print.dart`): `canPrintItinerary(access, status)` is true for En ruta and Cerrado with `canOpenDocument`, and an opener for each kind that shows the shared spec 044 preview. Printing records nothing and reloads nothing. Add "Imprimir ticket" and "Imprimir notas de entrega" (`OutlinedButton.icon`) to the trip screen's action bar for those two statuses (FR-020). The server's 409s (`itinerary.not_departed`, `itinerary.cancelled`) show in the preview.
- [ ] T034 [US5] Test printing: create `test/unit/features/sales/itinerary_print_test.dart` (`canPrintItinerary` for each status and right) and extend `delivery_itinerary_detail_screen_test.dart`: both buttons appear for En ruta and Cerrado with read on 87 and are absent for Abierto, Cancelado and without the right, and each opens the preview for its kind.

**Checkpoint**: all five stories are done.

---

## Phase 8: Polish & cross-cutting

- [ ] T035 [P] Live API test (research R12, depends on T006): `test/integration/delivery_itineraries_live_test.dart`, with fixtures discovered at runtime (an admin account from `.env`, two delivery orders in En preparación, a vehicle, and an operator, created through the API when none exist). Writes run only with `MBE_WRITE=true`, tagged `QA075 <n>`. Cover:
  - list (with the status, vehicle and warehouse filters) and get;
  - create (empty), update the header, `vehicle.open_itinerary_exists` for a second trip on the same vehicle;
  - add stops, `commitWholeOrder`, `commitLine` with a partial quantity, adjust, release, remove a stop;
  - `quantity_unavailable` above open;
  - depart, with the orders En tránsito and the sent quantities fixed;
  - close one stop with an **uploaded PNG** and another with a **drawn signature PNG**, which verifies the generated multipart call before it's trusted (§III, R12). A shortfall closes as partially delivered with a child order, and the last close makes the trip Cerrado with a return time;
  - `stop_already_resolved` on a repeated close, and `stop_shortfall_needs_reason` without a reason;
  - cancel an Abierto trip, and its quantities are open again;
  - both print documents return a PDF for En ruta and Cerrado, and a 409 for Abierto.

  Note in the file header which accounts it needs and that the facility must have an in-transit location. Assert the #343 fields on a fresh read: the stop's order, customer and ship-to, and the line's product and unit (needs migration 036, T002).
- [ ] T036 [P] Device test (quickstart.md, depends on T033, T028): `integration_test/delivery_itineraries_quickstart_test.dart`, mirroring `delivery_orders_quickstart_test.dart` and the macOS traps in memory (frame-stall watchdog, picker and back-button finders). Walk quickstart steps 1–12 as the administrator. Run with `caffeinate -dimsu flutter test integration_test/delivery_itineraries_quickstart_test.dart -d macos --dart-define-from-file=.env`, since without `caffeinate` it stalls silently.
- [ ] T037 [P] Largest text level (quickstart step 13, depends on T028, T030): `test/widget/features/sales/delivery_itineraries_large_text_test.dart`. At the largest text scale, the list, the trip screen with a closed stop's table and the close dialog don't clip or scroll sideways at 1280 px.
- [ ] T038 Final checks (depends on all previous tasks).
  - Run `flutter analyze` (no new warnings), `dart format` on the changed files only, and `flutter test test/unit/features/sales test/widget/features/sales test/unit/core/errors test/unit/core/navigation test/unit/core/documents test/unit/core/formatting_guard_test.dart test/unit/app/router/app_router_test.dart`.
  - Run the itineraries live test (read-only, then with `MBE_WRITE=true`) and the 061 delivery-orders live and quickstart tests once, to prove the shared areas are untouched.
  - Search `lib/features/sales/presentation/delivery_itineraries/` for literal colours, sizes and spacing (§V), for `NumberFormat` and `toStringAsFixed`, and for any display of `enum.name` or server message text (§III).
  - Check that no `core/widgets/` file was added, that the only changes to 061–063 files are the extended 063 repository and the nav comment, and that no generated file was hand-edited.
- [ ] T039 Validate against the quickstart (depends on T038). Run the walkthrough in quickstart.md against the dev mbe-api. Check SC-001 and SC-002 with a stopwatch (trip with two loaded stops under 2 minutes, a stop closed from paper under 1 minute). Steps that need an account that isn't seeded (a non-administrator with read on 87 only) are listed as manual checks to track in a GitHub issue after merge, as 067–074 did. Record the result and any deviation in the PR description, with `Closes mictlanix/mbe-roadmap#41` under "Roadmap". If #343 hadn't shipped by the time of the run, say so, and note that stop names after a reload are the degraded fallback.

---

## Dependencies & execution order

- **Phase 1** before everything. T002 only gates the live tasks (T035, T038, T039).
- **Phase 2** blocks all stories. Inside it: T005 → T006 → (T007, T008, T010 in parallel); T003 and T004 can run alongside T005; T009 and T011 are independent.
- **US1 (Phase 3)** needs Phase 2. Inside it: T013 → T014 → T015; T018, T019, T020 and T021 can be built in parallel with each other (different files) before T016 ties them together; T012 comes after T014 and T016; T022 is last.
- **US2 (Phase 4)** needs US1's trip screen (T016). **US3 (Phase 5)** needs US2's departed state to be reachable, and T026 → T027 → T028. **US4** needs T014. **US5** needs T016 only (it adds buttons to the screen), but run it after US3 so the detail screen is edited one story at a time.
- **Phase 8**: T035, T036 and T037 are parallel. T038 and T039 close.

### Parallel opportunities

- Phase 2: T007, T008, T009, T011 together once T005–T006 are in; T003 and T004 with T005.
- US1: T018, T019, T020 and T021 together (separate files).
- US5's T032 is independent of every other story and can be done any time after Phase 2.
- Phase 8: T035, T036, T037.

## Implementation strategy

- **MVP = US1 + US2 + US3**: plan, depart, close. That's every order in En preparación put on a truck, sent and settled (SC-003). Stop after Phase 5, validate against the dev server (T035's core cases, quickstart steps 1–12), then add US4 and US5.
- **Commit per story** after its tests pass, in the house style (`feat(sales): …` for code, `docs(specs): …` for spec changes). Never `dart format .`.
