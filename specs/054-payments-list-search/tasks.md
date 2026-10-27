---
description: "Task list for 054-payments-list-search"
---

# Tasks: Payments List and Search

**Input**: Design documents from `specs/054-payments-list-search/`

**Prerequisites**: plan.md, spec.md, wireframes.md, research.md (R1–R13), data-model.md, contracts/ui-contracts.md (C1–C6), quickstart.md

**Tests**: The spec does not ask for a test suite as such, but the constitution's quality gates and research R13 require tests. Test tasks are included inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US3, spec.md). US2 and US3 build on the list, repository and routes that Foundational and US1 deliver. US3 extends the filter, controller and screen that US1 delivers, so it edits the same files.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 browse and filter the facility's payments · US2 open a payment and see its applications · US3 find a payment across facilities

## Cross-story notes

- **Shared files.** Several stories edit the same files, so do these sequentially, not in parallel:
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: every phase adds keys (contracts C5). Run `flutter gen-l10n` after each arb task and commit the regenerated `lib/l10n/app_localizations*.dart` files. Never hand-edit those.
  - `lib/features/sales/presentation/payments/payments_filter.dart`, `payments_list_controller.dart` and `payments_list_screen.dart`: US1 then US3.
  - `lib/features/sales/presentation/payments/payment_link_providers.dart`: US1 (cash-session label) then US2 (order link).
  - `lib/app/router/app_router.dart`: US1 (list route) then US2 (detail route).
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs`.
- **No backend work and no client regeneration.** All four operations and their models already exist in the generated client (R1, C6). If a generated method is missing, stop and re-check the plan instead of regenerating.
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`.
- **Amounts and dates.** Every displayed amount and date goes through `formattersProvider` (constitution §V; `test/unit/core/formatting_guard_test.dart` fails the suite otherwise). No widget builds a `NumberFormat` or calls `toStringAsFixed`. Amounts are decimal strings, and sums use `package:decimal`, never `double`.
- **Language.** User-visible text is in Spanish and English. The Spanish wording in contracts C5 is the starting point. The payment-type words are fixed by FR-017.
- **Read-only.** No task adds a create, verify, reject, apply or reverse call (FR-003). If a task seems to need one, stop.
- **Facility rule.** The facility-scoped list always sends the user's own facility, and the detail screen applies the guard in R4. Treat both as load-bearing security code, the same as the sales-orders scoping: never simplify either to "trust the server" (mbe-api#271 is open).
- **Mirror, don't copy blindly.** The closest precedents are the cash-sessions list (`cash_sessions_screen.dart`, `cash_sessions_list_controller.dart`), the sales-orders list (`orders/sales_orders_list_controller.dart`, for the date facets) and `cash_session_detail_screen.dart` (for the detail layout). Read the matching file before writing each new one, and keep its structure, comment density and naming style.
- **Spacing tokens, not literals.** Constitution §V requires every padding, margin and gap to come from the design tokens (`Theme.of(context).spacing`). No automated guard catches a literal such as `EdgeInsets.all(24)`, so check it in review.
- **User without a facility.** If `userFacilityIdProvider` is `null`, the facility-scoped list shows its empty state and sends no request, because there's no facility to scope to (the spec is silent on this; flagged in the Phase 6 hand-off).

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [ ] T001 Run `flutter analyze` and the existing tests that this feature touches: `test/**/cash_session*_test.dart`, `test/**/customer_payment*_test.dart`, `test/**/sale_payment*_test.dart`, `test/**/payment_method*_test.dart`, `test/unit/core/formatting_guard_test.dart` and the router and navigation tests. Note any pre-existing failures so they are not blamed on this feature.

---

## Phase 2: Foundational (blocks every story)

**Purpose**: the enums, helpers, entities and repository methods that all three stories use.

- [ ] T002 Create the `PaymentType` enum in `lib/features/sales/domain/payment_type.dart` with the six codes in data-model.md §3 (na 0, immediate 1, creditPayment 2, paymentInAdvance 3, creditNote 4, expense 5), a `fromApi(api.PaymentType)` mapper that throws `AppError.server()` for an unrecognised value, and `paymentTypeLabel(AppLocalizations, PaymentType)`, in the style of `lib/core/domain/payment_method.dart`. Labels come from the l10n keys added in T005, so do T005 first: this task can't compile before it.
- [ ] T003 [P] Promote the private `_methodCodeFromApi` in `lib/features/sales/domain/entities/sale_payment.dart` (line ~70) to a top-level `paymentMethodCodeFromApi(api.PaymentMethod)` in `lib/core/domain/payment_method.dart`, and make `sale_payment.dart` call it. Behaviour is unchanged (R10).
- [ ] T004 [P] Add `String currencyCodeLabel(Currency)` to `lib/core/domain/currency.dart`, returning `MXN`, `USD` or `EUR` (R9). Do **not** touch the two private `_currencyLabel` copies in `order_header_panel.dart` and `quote_header_panel.dart`.
- [ ] T005 Add the foundational l10n keys to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` (contracts C5): `navPayments`, the six `paymentType*` keys (Spanish: N/A, Contado, Pago de crédito, Pago anticipado, Nota de crédito, Gasto), `paymentVerified`, `paymentUnverified` and `paymentApplicationReversed`. Run `flutter gen-l10n`.
- [ ] T006 Create the freezed `CustomerPayment` and `PaymentApplication` entities in `lib/features/sales/domain/entities/customer_payment.dart` with the fields and mappings in data-model.md §1–§2 (`fromResponse` for each). `CustomerPayment.isVerified` is `verifierId != null`. An unknown `CurrencyCode` or `PaymentType` throws `AppError.server()`. Depends on T002–T004. Run build_runner.
- [ ] T007 Add `list`, `searchAcrossFacilities`, `get` and `listApplications` to the `CustomerPaymentRepository` interface in `lib/features/sales/domain/repositories/customer_payment_repository.dart`, with the signatures in contracts C4 (`facilityId` is required on `list`). Depends on T006.
- [ ] T008 Implement the four methods in `lib/features/sales/data/customer_payment_repository_impl.dart` over the generated operations named in research R1. Send date range edges through the same `wireDate` / `wireDateEnd` helpers the sales-orders repository uses (read `sales_order_repository_impl.dart` ~392–405). Map `ListResponseCustomerPaymentResponse` to a `CatalogPage` (see how `sales_order_repository_impl.dart` builds one). Reuse the existing `_toAppError`; a 404 must surface as `AppError.notFound`. Depends on T007.
- [ ] T009 [P] Unit tests in `test/unit/features/sales/payment_type_test.dart` and `test/unit/features/sales/customer_payment_entity_test.dart`: every code maps to its type and Spanish label (FR-017), an unknown code throws `AppError.server()`, `CustomerPayment.fromResponse` and `PaymentApplication.fromResponse` carry every field, `isVerified` follows `verifierId`, and `currencyCodeLabel` covers the three currencies.
- [ ] T010 Unit tests in `test/unit/features/sales/customer_payment_repository_impl_test.dart` (extend the file if it exists): `list` forwards `facility`, the filters, `verified` true, false and null, and the date edges; `searchAcrossFacilities` forwards `reference`, `customer` and the dates; `get` and `listApplications` map their responses; a 404 becomes `AppError.notFound`; the existing create, apply and reverse tests still pass.

**Checkpoint**: the repository returns typed payments and applications. Nothing is visible yet.

---

## Phase 3: User Story 1 — Browse and filter the facility's payments (P1)

**Story goal**: a Pagos screen in the Sales section lists the user's facility's payments, newest first, with the five facets.

**Independent test**: record a couple of payments through the POS, open Pagos, confirm they appear newest first with customer name, amount, method and verified state, then apply each filter and confirm the list narrows (quickstart steps 1–3 and 10).

- [ ] T011 [US1] Add `int cashDrawerFacilityId` to the `CashSession` entity in `lib/features/sales/domain/entities/cash_session.dart`, mapped from the embedded `cash_drawer.facility` (R7), and update every place that builds a `CashSession` (the repository impl `lib/features/sales/data/cash_session_repository_impl.dart` and the test fixtures that construct one; search with `rg "CashSession\(" lib test`). Run build_runner.
- [ ] T012 [US1] Add an optional `int? facilityId` to `CashSessionRepository.list` in `lib/features/sales/domain/repositories/cash_session_repository.dart` and pass it to the generated `facility` parameter in `cash_session_repository_impl.dart`. Existing callers are unchanged.
- [ ] T013 [P] [US1] Add `customerDisplayNameProvider` (`FutureProvider.family<String?, int>`, null on any error) to `lib/features/catalog/data/customer_repository_impl.dart`, mirroring `employeeDisplayNameProvider` in `employee_repository_impl.dart` (R2).
- [ ] T014 [P] [US1] Add `paymentMethodOptionNameProvider` (same shape) to `lib/features/catalog/data/payment_method_option_repository_impl.dart`, calling `get({paymentMethodOptionId})` (R3).
- [ ] T015 [US1] Create `lib/features/sales/presentation/payments/payment_link_providers.dart` with `cashSessionLabelProvider(id)` (`#id · cashierName · date`, null on error) and a `cashSessionPickerOptions` helper implementing R7: an all-digits query does `get`, and returns the session only when its `cashDrawerFacilityId` is the user's facility; any other query does `list(facilityId:, limit: 20)`. Depends on T011 and T012.
- [ ] T016 [US1] Add the list keys to both `.arb` files (contracts C5): the column labels, the filter labels, `paymentsVerifiedAny/Yes/No`, `paymentsFilterMethodAll`, and `paymentsListEmpty` and `paymentsListEmptyFiltered`. Run `flutter gen-l10n`.
- [ ] T017 [US1] Create `PaymentsFilter` in `lib/features/sales/presentation/payments/payments_filter.dart` (freezed, facility mode only for now): `fromQuery(ListQuery)` reads `customer`, `date-from`, `date-to` (`yyyy-MM-dd`, copy the encode and decode helpers from `SalesOrdersFilter`), `method`, `verified` (`true` / `false`, anything else is any), `cash-session` and `page`; a range whose end is before its start is dropped; `activeFilterCount` counts the set facets. There is **no** default date range (R6). Run build_runner.
- [ ] T018 [US1] Create `PaymentsListController(filter)` in `lib/features/sales/presentation/payments/payments_list_controller.dart` (`@riverpod`), returning `CatalogPage<CustomerPayment>` through `fetchClampedPage`. It calls `list` with `facilityId: ref.read(userFacilityIdProvider)`, always the user's own, never a facet. If that is `null`, return an empty page without a request. Page size 20. Depends on T008 and T017. Run build_runner.
- [ ] T019 [US1] Create `PaymentsListScreen` in `lib/features/sales/presentation/payments/payments_list_screen.dart` per contracts C2: `CatalogFilterBar` with no `search:` slot and the badged filter button, `CatalogListStateView` with empty (filtered and unfiltered), error-with-retry and loading, and `DataTableView` with the facility-mode columns (Folio, Fecha, Cliente, Importe, Forma de pago, Referencia, Tipo, Sin aplicar, Verificado). Cells:
  - **Cliente:** `customerDisplayNameProvider`, "…" while loading, `#<id>` when null.
  - **Importe and Sin aplicar:** right-aligned currency plus `currencyCodeLabel`, never truncated.
  - **Forma de pago:** `paymentMethodLabel`, plus " · option name" from T014, or `#<id>` when the option is gone.
  - **Verificado:** `StatusChip`, with its colour mapping in this file.
  - **Row tap:** `context.push('/sales/payments/<id>')`; no row actions.

  The filter drawer is `showCatalogFilterSheet` over a `CurrentListQueryBuilder`, with Cliente (`CatalogEntityPicker<CustomerListItem>`), Fecha (`DateRangeFilterChip`), Forma de pago, Verificado (three `ChoiceChip`s, Todos by default) and Sesión de caja (`CatalogEntityPicker<CashSession>` using T015, **only** when `can(pos, read)`). Every facet change resets to page 0, and "Limpiar todo" clears every facet. The filtered and empty states key off `filter.activeFilterCount > 0`, not `query.isFiltered`, so a stray `search` in the URL doesn't count as a filter in facility mode. Depends on T013–T018.
- [ ] T020 [US1] Wire the route and navigation (contracts C1): append `NavBranch.salesPayments` in `lib/core/widgets/app_navigation.dart` (never renumber the others), add the `/sales/payments` shell branch to `lib/app/router/app_router.dart`, map the `/sales/payments` prefix to `PrivilegeGate(SystemObject.customerPayments, AccessRight.read)` in `_routeGate`, and add the "Pagos" entry right after cash-sessions in `lib/core/navigation/nav_destinations.dart` with the same gate and `Icons.payments_outlined`. Depends on T019.
- [ ] T021 [P] [US1] Unit tests in `test/unit/features/sales/payments_filter_test.dart`: each facet parses and round-trips; `verified` true, false and absent; an inverted date range is dropped; `activeFilterCount`; no default dates.
- [ ] T022 [P] [US1] Unit tests in `test/unit/features/sales/payments_list_controller_test.dart` (ProviderContainer with overrides, modelled on `cash_sessions_list_controller_test.dart`): the repository is always called with the user's facility whatever the URL says; filters are forwarded; a user with no facility gets an empty page and **no** repository call.
- [ ] T023 [P] [US1] Unit tests in `test/unit/features/sales/payment_link_providers_test.dart` and `test/unit/features/catalog/customer_display_name_provider_test.dart`: the name providers return null on error; the picker helper does `get` for digits and accepts only the user's facility (a foreign-facility or 404 session gives no options), does `list(facilityId:)` otherwise; `cashSessionLabelProvider` formats `#id · cashier · date`. Extend `test/unit/features/sales/cash_session_repository_impl_test.dart` for the new `facilityId` and `cashDrawerFacilityId`.
- [ ] T024 [US1] Widget tests in `test/widget/features/sales/payments_list_screen_test.dart` (modelled on `sales_orders_list_screen_test.dart`): populated rows with every column; the customer placeholder then name, and the `#<id>` fallback; foreign-currency amount shows its code; empty with and without filters (and the clear button); error with retry and the filters kept; row tap navigates to the detail route; no search box and no row actions.
- [ ] T025 [US1] Widget tests in `test/widget/features/sales/payments_filters_test.dart`: each facet writes the URL and resets the page; the verified chips are tri-state with "Todos" selected by default; the Sesión de caja facet is absent without POS read and present with it; the badge counts active filters; "Limpiar todo" clears them.
- [ ] T026 [P] [US1] Router and navigation tests: extend `test/unit/app/router/app_router_test.dart` and `test/unit/core/navigation/nav_destinations_test.dart` so that a user without Customer Payments read has no "Pagos" entry and `/sales/payments` redirects them (FR-001, Story 1 scenario 10), and a user with it has both.

**Checkpoint**: Pagos works for the facility, end to end. This is the MVP.

---

## Phase 4: User Story 2 — Open a payment and see where it went (P2)

**Story goal**: each payment has its own read-only screen with its fields, the Importe · Aplicado · Sin aplicar summary and its applications, with links to the order and cash session.

**Independent test**: apply a POS payment to an order, open that payment from Pagos, confirm the fields and the application, then follow the order link and the cash-session link (quickstart steps 4, 5, 9 and 11).

- [ ] T027 [US2] Add `orderLinkTargetProvider(saleId)` to `lib/features/sales/presentation/payments/payment_link_providers.dart` (R8): when the user can read Sales Orders (7), fetch the sale with `SalesOrderRepository.getById` and decide with `isForeignOrder` (`orders/foreign_order_guard.dart`). Foreign gives `/sales/pos/:id` when `can(pos, read)`; otherwise `/sales/orders/:id`; anything else, including a fetch error or no Sales Orders read, gives `null` (plain text). Depends on T015.
- [ ] T028 [US2] Create `lib/features/sales/presentation/payments/payment_detail_controller.dart` with two `@riverpod` controllers (data-model.md §6):
  - **`PaymentDetailController(paymentId)`:** loads the payment, then applies the guard from R4. If `payment.facilityId` is not the user's facility and the user can't read Payments Editor (100), it throws `AppError.notFound()`.
  - **`PaymentApplicationsController(paymentId)`:** returns the applications. It is watched only after the guard passes, and it exposes an `applied` total, the `package:decimal` sum of the non-reversed applications.

  Depends on T008. Run build_runner.
- [ ] T029 [US2] Add the detail keys to both `.arb` files (contracts C5): `paymentViewTitle`, `paymentHeaderTitle`, the three `paymentSummary*`, the `paymentField*` labels, `paymentApplications*` (title, empty, six columns), `paymentNotFound` and `paymentBackToList`. Run `flutter gen-l10n`.
- [ ] T030 [US2] Create `PaymentDetailScreen` in `lib/features/sales/presentation/payments/payment_detail_screen.dart` per contracts C3: AppBar "Ver pago" with Back and no actions; loading, error-with-retry and not-found (with "Volver a Pagos"); the header with the verified `StatusChip` and the Importe · Aplicado · Sin aplicar line (Aplicado shows a progress indicator while loading and "—" if the applications failed); the `ResponsiveFormGrid` of fields (Cliente, Fecha, Forma de pago, Opción de pago, Referencia, Tipo, Sucursal, Sesión de caja, Verificado por), with "—" for empty values and the raw number for an unresolved name (`employeeDisplayNameProvider`, `facilityDisplayNameProvider`, T013, T014); Sesión de caja links only with `can(pos, read)`; and the Aplicaciones section as an unpaginated `DataTableView<PaymentApplication>`: Pedido link from T027 or plain `#id`, reversed rows muted with the "Revertida" chip, an empty message, an inline error with retry, and no `onRowTap`. Depends on T027–T029.
- [ ] T031 [US2] Add the top-level `/sales/payments/:paymentId` route to `lib/app/router/app_router.dart`, covered by the existing `/sales/payments` gate. A non-numeric id renders the not-found state, not an exception. Depends on T030.
- [ ] T032 [P] [US2] Unit tests in `test/unit/features/sales/payment_detail_controller_test.dart`: the guard throws not-found for another facility's payment without Payments Editor and **never calls** `listApplications`; a Payments Editor can open it; `applied` excludes reversed applications and sums in decimal (for example 0.1 + 0.2 = 0.3); a failing applications call leaves the payment loaded.
- [ ] T033 [P] [US2] Unit tests in `test/unit/features/sales/payment_link_providers_test.dart` (extend T023's file): a POS-origin order resolves to `/sales/pos/:id`, a back-office one to `/sales/orders/:id`, no Sales Orders read gives `null` without a fetch, and a fetch error gives `null`.
- [ ] T034 [US2] Widget tests in `test/widget/features/sales/payment_detail_screen_test.dart` (modelled on `cash_session_detail_screen_test.dart`): the header summary; every field, and "—" for empty ones; reversed rows muted, marked and excluded from Aplicado; the no-applications message; order and cash-session numbers are links only with the matching rights and plain text otherwise; the not-found state for a foreign facility and for a 404; the applications error with retry while the fields stay visible; **no** verify, reject, reverse or edit control anywhere (FR-003, SC-006).

**Checkpoint**: US1 and US2 both work. The list opens the detail.

---

## Phase 5: User Story 3 — Find a payment across facilities by reference (P3)

**Story goal**: Payments Editor readers can switch Pagos to "Todas las sucursales" and search by reference, customer and dates.

**Independent test**: as a user with Payments Editor read access, search a fragment of a reference recorded at another facility and open the result; as a user without it, confirm no mode switch and that `?scope=all` is ignored (quickstart steps 6–8).

- [ ] T035 [US3] Extend `PaymentsFilter` in `lib/features/sales/presentation/payments/payments_filter.dart` (data-model.md §4): add `PaymentsScope { facility, allFacilities }`, a `scope` field read from the `scope` facet, a `reference` read from `ListQuery.search`, and a `canSearchAllFacilities` parameter on `fromQuery`; `scope=all` is forced to `facility` when it is false, and in `all` mode the method, verified and cash-session facets are ignored. Add `switchScope(ListQuery, PaymentsScope)`: it keeps `customer`, `date-from` and `date-to`, drops every other facet and the search, and resets the page (FR-012). `activeFilterCount` counts only facets valid in the mode. Run build_runner.
- [ ] T036 [US3] Make `PaymentsListController` in `payments_list_controller.dart` call `searchAcrossFacilities` (reference, customer, dates) when `filter.scope` is `allFacilities`, and `list` otherwise. The facility rule from T018 is unchanged for the facility mode. Run build_runner.
- [ ] T037 [US3] Add `paymentsScopeFacility`, `paymentsScopeAll` and `paymentsSearchReferenceHint` to both `.arb` files. Run `flutter gen-l10n`.
- [ ] T038 [US3] Extend `PaymentsListScreen` in `payments_list_screen.dart` per contracts C2: a `SegmentedButton<PaymentsScope>` in `CatalogFilterBar.actions`, **only** when `can(paymentsEditor, read)`, that navigates through `switchScope`; a `CatalogSearchBar` in the `search:` slot in `all` mode only (writing `ListQuery.search`); the Sucursal column (via `facilityDisplayNameProvider`) in `all` mode only; and a drawer with just Cliente and Fecha in `all` mode. Depends on T035–T037.
- [ ] T039 [P] [US3] Extend `test/unit/features/sales/payments_filter_test.dart`: `scope=all` is honoured only with `canSearchAllFacilities`; the reference comes from the search text; facility-only facets are ignored in `all` mode; `switchScope` keeps customer and dates and drops the rest in both directions.
- [ ] T040 [P] [US3] Extend `test/unit/features/sales/payments_list_controller_test.dart`: `all` mode calls `searchAcrossFacilities` with the reference, customer and dates and **not** `list`; facility mode still always sends the user's facility.
- [ ] T041 [US3] Extend `test/widget/features/sales/payments_list_screen_test.dart` and `payments_filters_test.dart`: the mode switch exists only with Payments Editor read; a user without it who opens `?scope=all` sees the facility list; switching modes clears the facility-only facets; `all` mode shows the search box, the Sucursal column and only the Cliente and Fecha facets; searching a reference writes `search`; opening a result and pressing Back returns to the same mode, search and page (quickstart step 7).

**Checkpoint**: all three stories work.

---

## Phase 6: Polish & cross-cutting

- [ ] T042 Write the live repository test `test/integration/payments_list_live_test.dart` per research R13 (copy the setup of `pos_sales_list_flow_test.dart`: raw `Dio`, `AuthRepositoryImpl.login`, `--dart-define=MBE_POS_USERNAME/PASSWORD`, skipped when empty). Discover a payment at runtime through `list`, re-read it with `get` and `listApplications`, and, when its applications share the payment's currency, assert `unapplied == amount − Σ non-reversed applications` (SC-003). Also assert that `searchAcrossFacilities` with the admin account finds it by a fragment of its reference, when it has one. Run it against the dev tenant.
- [ ] T043 [P] Layout checks at both tiers (FR-019, constitution §VI). In the list and detail widget tests, copy the surface-size setup from `test/widget/features/sales/cash_sessions_screen_test.dart`:
  - **Expanded width (1280 px):** both tables fit with no horizontal scroll in both modes; only the text columns (Cliente, Referencia, Sucursal) are ellipsized, and amounts and status chips are shown in full.
  - **Phone width:** each screen pumps with no overflow exception, the filter row wraps, and the tables scroll horizontally with every column kept.
- [ ] T044 [P] Run `flutter analyze`, `test/unit/core/formatting_guard_test.dart` and the full test suite, then `dart format` on **only** the changed files (`git diff --name-only` filtered to `.dart`). Fix anything this feature caused. In the sales tests, check that T003's helper move changed nothing.
- [ ] T045 Walk through the quickstart on the dev tenant, all 12 steps (as admin, as a non-editor and as a user without POS read; see `test/integration/TEST_ACCOUNTS.md`), and note the result of each step. Steps 8–10 need the non-admin accounts.
- [ ] T046 Check whether mbe-api#270 (customer name on payment rows) and #271 (facility checks) have shipped (`gh issue view 270 --repo mictlanix/mbe-api`, same for 271). Don't change code for them here, because the fields don't exist yet. Record each status in the PR description, with the follow-ups from plan.md ("Follow-ups").
- [ ] T047 Prepare the PR description: a Roadmap section with `Closes mictlanix/mbe-roadmap#25`, the follow-ups from T046, the note that the two private `_currencyLabel` copies were left alone (R9), and the decision about a user with no facility.

---

## Dependencies & execution order

- **Phase 1** → **Phase 2** → **Phase 3 (US1)** → **Phase 4 (US2)** → **Phase 5 (US3)** → **Phase 6**.
- **US2 depends on US1** for the shared providers file (T015), the `/sales/payments` gate (T020) and the list that opens it. **US3 depends on US1** for the filter, controller and screen it extends.
- US2 and US3 don't depend on each other, so they can be done in either order or by two people, apart from the shared `.arb` files and `app_router.dart` (see cross-story notes).
- Within Phase 2: T005 first (T003 and T004 can run alongside it), then T002, then T006, T007, T008; T009 and T010 follow their code.
- Within US1: T011 → T012 → T015; T013 and T014 are independent; T017 → T018 → T019 → T020.

## Parallel opportunities

- **Phase 2:** T003, T004 and T005 together; T009 once T006 is done.
- **US1:** T013 and T014 together; T021, T022, T023 and T026 together once their code exists.
- **US2:** T032 and T033 together once T027 and T028 exist.
- **US3:** T039 and T040 together.
- **Phase 6:** T043 and T044.

## Implementation strategy

- **MVP:** Phases 1–3. It delivers the facility list with all five facets, which already answers "did this customer pay?" and "what is unverified?". It doesn't finish roadmap#25 on its own: the issue's legacy actions include opening a payment (US2) and the cross-facility search (US3).
- **Release:** Phases 1–6 in one PR (`Closes mictlanix/mbe-roadmap#25`). US2 and US3 are small additions to US1's screen.
- **Order inside US1:** do T011 and T012 (the cash-session changes) early. They touch a shared entity that other screens and tests construct, so breakage shows up before the list work builds on it.
- **Risk to watch:** T011 changes the `CashSession` entity that the cash-sessions screens and many tests use. Run the whole `cash_session*` test group after it, not only the new tests.

## Requirement coverage

| Requirement | Tasks |
|---|---|
| FR-001 route and nav access | T020, T026 |
| FR-002 mode only with Payments Editor | T035, T038, T041 |
| FR-003 read-only | T034 (and the cross-story note) |
| FR-004 own-facility list, newest first, no session scope | T018, T022 |
| FR-005 row columns | T019, T024 |
| FR-006, FR-006a facets, cash-session picker | T015, T017, T019, T023, T025 |
| FR-007 tri-state verified | T017, T019, T025 |
| FR-008 shared filter drawer, no search box in facility mode | T019, T024 |
| FR-009 no facility picker | T018, T022 |
| FR-010, FR-011 reference search, Sucursal column | T035, T036, T038, T040, T041 |
| FR-012 modes clear unsupported facets | T035, T039, T041 |
| FR-013, FR-013a payment screen and summary | T028, T030, T034 |
| FR-013b other facility's payment by link | T028, T032, T034 |
| FR-014 applications, reversed marked | T028, T030, T032, T034 |
| FR-015 links by rights and origin | T027, T030, T033, T034 |
| FR-016 amounts and dates in the payment's own currency | T004, T019, T030, T044 |
| FR-017 labels | T002, T005, T009 |
| FR-018 customer names with fallback | T013, T019, T023, T024 (preferring the server's name is the #270 follow-up, T046) |
| FR-019 states and compact layout | T019, T030, T043 |
| SC-001, SC-002 time to find | T045 |
| SC-003 totals match the server | T032, T042 |
| SC-004 no other-facility payments | T022, T032, T034, T041 |
| SC-005 names on every row | T024, T045 |
| SC-006 nothing changes a payment | T034, T045 |
