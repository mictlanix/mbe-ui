---

description: "Task list for Product Pricing (Price Lists, Product Prices & Exchange Rates)"

---

# Tasks: Product Pricing (Price Lists, Product Prices & Exchange Rates)

**Input**: Design documents from `/specs/011-product-pricing/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Included per constitution §"Development Workflow & Quality Gates"
(unit/widget/integration tests are a quality gate, not optional, for this
project). Write each story's tests first; confirm they fail before
implementing.

**Organization**: Tasks are grouped by user story (spec.md priorities P1/P1/P2)
to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no unmet dependencies)
- **[Story]**: Maps the task to US1 (Manage price lists), US2 (Price a product
  across price lists), or US3 (Manage daily exchange rates)
- File paths are relative to the repository root

## Path Conventions

Single Flutter project per plan.md "Project Structure": `lib/`, `test/` at
repository root. This feature adds the new `lib/features/pricing/` module and
`lib/core/domain/currency.dart`, and edits three existing files
(`lib/app/router/app_router.dart`, `lib/core/navigation/nav_destinations.dart`,
`lib/l10n/app_*.arb`). Integration tests live in `test/integration/` (there is
no top-level `integration_test/` directory in this repo).

**No codegen and no new dependency**: the pricing API client is already
committed under `lib/generated/openapi/` and is treated as current
(research.md §2). Generated files MUST NOT be edited.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the module skeleton and confirm the generated client this
feature builds against is actually present. No dependency or tooling change is
needed (plan.md "Technical Context").

- [ ] T001 Create the feature module directory structure `lib/features/pricing/{data,domain/entities,domain/repositories,presentation}` and the matching test directories `test/unit/features/pricing/` and `test/widget/features/pricing/`
- [ ] T002 Confirm the generated pricing client is present and untouched: `lib/generated/openapi/lib/src/api/{price_lists_api,product_prices_api,exchange_rates_api}.dart` and the `PriceListResponse` / `ProductPriceResponse` / `ExchangeRateResponse` / `*Create` / `*Update` / `ListResponse_*` models exist (contracts/mbe-api-pricing.md). Do NOT regenerate; if anything is missing, stop and re-open the no-codegen decision in research.md §2

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Validation, formatting, and localization shared by all three user
stories.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T003 [P] Create `lib/features/pricing/domain/pricing_validators.dart` exposing: required-non-empty-name, non-negative-decimal (prices, profit figures, margins — FR-006/FR-011), and positive-decimal (exchange rates, where zero is invalid — FR-016). Validators operate on `String` and MUST NOT parse money to `double` (research.md §3)
- [ ] T004 [P] Create `lib/features/pricing/presentation/pricing_formatters.dart` using `intl`: MXN currency formatting for money (FR-013), decimal→percent for margins (`"0.40"` → `40%`, FR-006), and locale-aware date formatting for exchange rates (FR-018). No manual string formatting (constitution §V)
- [ ] T005 [P] Add l10n keys to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: nav titles (`priceListsMenuTitle`, `pricingMenuTitle`, `exchangeRatesMenuTitle`), column headers, form labels, validation messages, and empty states (including "no price lists exist yet" and "select a product" — spec Edge Cases, US2 §8)

**Checkpoint**: Foundation ready — user story implementation can now begin

---

## Phase 3: User Story 1 - Manage price lists (Priority: P1) 🎯 MVP

**Goal**: A full price-lists catalog at `/price-lists` — browse with
search/pagination, create, view (read-only), edit, and delete — gated by
`SystemObject.priceLists` (5).

**Independent Test**: Sign in with the price-list privilege, open
`/price-lists`, create a list with a name and margins, confirm it appears with
margins rendered as percentages, search for it, click the row to open a
read-only view, edit its margins, and delete an unused list — all without
touching any product (quickstart §1).

### Tests for User Story 1 ⚠️

> **Write these FIRST; confirm they FAIL before implementing**

- [ ] T006 [P] [US1] Unit test `test/unit/features/pricing/price_list_repository_impl_test.dart` — `PriceListResponse`→`PriceList` mapping, list/search/pagination params, create/update/delete, and error mapping to the shared error types (mocktail-faked `PriceListsApi`)
- [ ] T007 [P] [US1] Unit test `test/unit/features/pricing/price_lists_list_controller_test.dart` — search and pagination state, `AsyncValue` transitions
- [ ] T008 [P] [US1] Unit test `test/unit/features/pricing/price_list_form_controller_test.dart` — required name, non-negative margins, negative margin rejected before submit (FR-006), update sends only changed fields
- [ ] T009 [P] [US1] Widget test `test/widget/features/pricing/price_lists_list_screen_test.dart` — columns and right-aligned numerics, search + pagination present, Edit row icon **hidden** (not disabled) without `update` privilege, row click opens read-only view (constitution §VI)
- [ ] T010 [P] [US1] Widget test `test/widget/features/pricing/price_list_detail_screen_test.dart` — create vs. view vs. edit modes, margins shown as percentages, delete button hidden without `delete` privilege, server rejection on delete surfaced and list left in place (US1 §6)

### Implementation for User Story 1

- [ ] T011 [P] [US1] Create the `PriceList` freezed entity in `lib/features/pricing/domain/entities/price_list.dart` per data-model.md §1 (`priceListId`, `name`, `highProfitMargin`, `lowProfitMargin` — margins as `String`), with a `fromResponse` mapper
- [ ] T012 [US1] Define the `PriceListRepository` interface in `lib/features/pricing/domain/repositories/price_list_repository.dart` (list with `search`/`skip`/`limit`, getById, create, update, delete)
- [ ] T013 [US1] Implement `lib/features/pricing/data/price_list_repository_impl.dart` wrapping the generated `PriceListsApi`, building `PriceListCreate`/`PriceListUpdate` (margins via their `AnyOf` String arm — research.md §4), mapping errors to the shared error types, and expose it as a Riverpod provider for test overrides (constitution §II)
- [ ] T014 [US1] Implement `PriceListsListController` (`Notifier`) in `lib/features/pricing/presentation/price_lists_list_controller.dart` — search + pagination state driving `AsyncValue<List<PriceList>>`
- [ ] T015 [US1] Implement `PriceListFormController` (`Notifier`) in `lib/features/pricing/presentation/price_list_form_controller.dart` — form state, client-side validation via T003, create/update/delete submission
- [ ] T016 [US1] Implement `PriceListsListScreen` in `lib/features/pricing/presentation/price_lists_list_screen.dart` using the shared `DataTableView`, `CatalogFilterBar`/`CatalogSearchBar`, `CatalogPagination`, single Edit row action from `catalog_action_icons.dart`, toolbar-only Create, row-click → read-only view (contracts/routes.md §"Per-constitution §VI list-screen conventions")
- [ ] T017 [US1] Implement `PriceListDetailScreen` in `lib/features/pricing/presentation/price_list_detail_screen.dart` — create + view/edit modes using `ResponsiveFormGrid`, margins displayed as percentages, warning-styled Delete in the form body (007's FR-014/FR-015 pattern), errors via the shared `ErrorBanner`
- [ ] T018 [US1] Add `/price-lists`, `/price-lists/new`, and `/price-lists/:priceListId` to `lib/app/router/app_router.dart` with their `routeSystemObject` gates per contracts/routes.md (the list route is a `StatefulShellRoute` branch; the two form routes sit outside the shell)
- [ ] T019 [US1] Add the `price-lists` `NavDestination` (gate: `priceLists` + `read`) to the `catalogs` group and the `NavBranch.priceLists` index in `lib/core/navigation/nav_destinations.dart` — **branch index order MUST match the router's branch order** (invariant documented at `nav_destinations.dart:10-11`)

**Checkpoint**: `/price-lists` is fully functional and independently testable. This is a shippable MVP — pricing tiers can be defined even before products can be priced.

---

## Phase 4: User Story 2 - Price a product across price lists (Priority: P1)

**Goal**: The pricing tool at `/pricing` — pick a product, see its price on
**every** price list (including lists with no price set), and set or update any
of them. Gated by `SystemObject.pricing` (106).

**Independent Test**: Open `/pricing`, confirm the empty state prompts for a
product, select a known product, confirm every price list appears with "not
set" visibly distinct from `0.00`, set a price on an unpriced list and change
one on a priced list, reselect the product, and confirm both persisted
(quickstart §2).

**⚠️ Depends on US1's `PriceList` entity + repository (T011–T013)** — the left
join needs the full price-list set. This is the one intentional cross-story
dependency; it mirrors the domain (a price cannot exist without a list). US1
does **not** depend on US2.

> **⚠️ Highest-risk phase.** T020 and T026 cover the codebase's first
> `one_of`/`AnyOf` construction site. A broken serializer can still look like a
> successful save in the UI — do not trust the screen, assert the wire format.

### Tests for User Story 2 ⚠️

- [ ] T020 [P] [US2] Unit test `test/unit/features/pricing/product_price_repository_impl_test.dart` — **including a round-trip test asserting the `AnyOf` write path serializes `price`/`low_profit`/`high_profit` as JSON decimal *strings* (e.g. `"120.00"`), not `num`, `null`, or `{}`** (research.md §4, plan.md Risks); plus `ProductPriceResponse`→`ProductPrice` mapping with its **nested `price_list` object** (not an id), and that an explicit `limit` is passed rather than relying on the API's default of 20 (contracts/mbe-api-pricing.md G5)
- [ ] T021 [P] [US2] Unit test `test/unit/features/pricing/pricing_controller_test.dart` — the client-side left join (research.md §5): every price list yields a row; a list with no price row yields `price == null` ("not set") and is distinct from a `0.00` price (FR-008); save routes to **create** when `productPriceId == null` and **update** otherwise; negative price rejected before submit (FR-011)
- [ ] T022 [P] [US2] Widget test `test/widget/features/pricing/pricing_screen_test.dart` — empty state with no product selected (US2 §8), "not set" vs. zero rendering, MXN formatting, read-only with `pricing` read but not `update` (FR-012), empty state when zero price lists exist (spec Edge Cases)

### Implementation for User Story 2

- [ ] T023 [P] [US2] Create the `ProductPrice` freezed entity in `lib/features/pricing/domain/entities/product_price.dart` per data-model.md §2 — note `priceList` is a nested `PriceList`, not an id
- [ ] T024 [P] [US2] Create the `ProductPriceRow` view model in `lib/features/pricing/presentation/product_price_row.dart` per data-model.md §3 (`priceList` always present, `price` nullable) — this is what makes "not set" ≠ `0.00` representable
- [ ] T025 [US2] Define the `ProductPriceRepository` interface in `lib/features/pricing/domain/repositories/product_price_repository.dart` (list by `product`, create, update)
- [ ] T026 [US2] Implement `lib/features/pricing/data/product_price_repository_impl.dart` wrapping the generated `ProductPricesApi`. Build `ProductPriceCreate` with the **String arm** of the `AnyOf` wrappers — `Price((b) => b..anyOf = AnyOf2<num, String>(values: {1: '120.00'}))` (index `1` is String; research.md §4). Pass an explicit `limit` covering the price-list count (G5). Expose as a provider
- [ ] T027 [US2] Implement `PricingController` (`Notifier`) in `lib/features/pricing/presentation/pricing_controller.dart` — fetch price lists (US1 repo) + the product's prices, build the left-joined `ProductPriceRow` list, and route each save to create-vs-update (research.md §5)
- [ ] T028 [US2] Implement `PricingScreen` in `lib/features/pricing/presentation/pricing_screen.dart` — product selection via the shared `catalog_entity_picker.dart` (FR-007b), the price grid via the shared `DataTableView` with right-aligned money columns, inline edit gated on `pricing` + `update`, empty states, errors via `ErrorBanner`
- [ ] T029 [US2] Add the `/pricing` route (shell branch, gate `pricing` + `read`) to `lib/app/router/app_router.dart` and the `pricing` `NavDestination` + `NavBranch.pricing` index to `lib/core/navigation/nav_destinations.dart`. No detail route — product selection is in-screen state (contracts/routes.md). **Sequential with T019/T044** (same two files)

**Checkpoint**: US1 and US2 both work independently. Products can now be priced per tier — the feature's headline capability.

---

## Phase 5: User Story 3 - Manage daily exchange rates (Priority: P2)

**Goal**: An exchange-rates catalog at `/exchange-rates` — browse with
date-range and currency-pair filters plus pagination, create, view, edit, and
delete. Gated by `SystemObject.exchangeRates` (43).

**Independent Test**: Open `/exchange-rates`, add a rate for today (USD→MXN,
`17.50`), filter by date range and currency pair, edit the rate, delete it —
independently of price lists or products (quickstart §4).

**Fully independent** of US1 and US2 — no shared entities.

### Tests for User Story 3 ⚠️

- [ ] T030 [P] [US3] Unit test `test/unit/core/domain/currency_test.dart` — `Currency.fromValue` for `0`/`1`/`2`, and `null` for an unrecognized code
- [ ] T031 [P] [US3] Unit test `test/unit/features/pricing/exchange_rate_repository_impl_test.dart` — `ExchangeRateResponse`→`ExchangeRate` mapping incl. `int`→`Currency`, date-range/currency filter params, create/update/delete, and that an **unrecognized currency code does not crash the list** (falls back to the raw code — data-model.md §4)
- [ ] T032 [P] [US3] Unit test `test/unit/features/pricing/exchange_rates_list_controller_test.dart` — date-range and currency-pair filter state, pagination
- [ ] T033 [P] [US3] Unit test `test/unit/features/pricing/exchange_rate_form_controller_test.dart` — required date/base/target, **rate must be positive** (zero rejected, unlike prices — FR-016)
- [ ] T034 [P] [US3] Widget test `test/widget/features/pricing/exchange_rates_list_screen_test.dart` — columns, filters, pagination, Edit icon hidden without `update`
- [ ] T035 [P] [US3] Widget test `test/widget/features/pricing/exchange_rate_detail_screen_test.dart` — currency **pickers** (never raw ints — FR-018), locale-aware date input, duplicate date+pair surfaces the server's response clearly (research.md §8)

### Implementation for User Story 3

- [ ] T036 [P] [US3] Create the `Currency` enum in `lib/core/domain/currency.dart` — `mxn(0)`, `usd(1)`, `eur(2)` with `final int value` and `static Currency? fromValue(int)`, mirroring `lib/core/access/system_object.dart`'s shape and legacy `mbe/docs/constants.md` §CurrencyCode (data-model.md §5, research.md §6)
- [ ] T037 [P] [US3] Create the `ExchangeRate` freezed entity in `lib/features/pricing/domain/entities/exchange_rate.dart` per data-model.md §4 (`date` as `DateTime`, `rate` as `String`, `base`/`target` as `Currency`)
- [ ] T038 [US3] Define the `ExchangeRateRepository` interface in `lib/features/pricing/domain/repositories/exchange_rate_repository.dart` (list with `dateFrom`/`dateTo`/`base`/`target`/`skip`/`limit`, getById, create, update, delete)
- [ ] T039 [US3] Implement `lib/features/pricing/data/exchange_rate_repository_impl.dart` wrapping the generated `ExchangeRatesApi`, mapping `Currency`↔`int` with a safe fallback for unknown codes, and expose as a provider
- [ ] T040 [US3] Implement `ExchangeRatesListController` (`Notifier`) in `lib/features/pricing/presentation/exchange_rates_list_controller.dart` — date-range + currency-pair filters, pagination
- [ ] T041 [US3] Implement `ExchangeRateFormController` (`Notifier`) in `lib/features/pricing/presentation/exchange_rate_form_controller.dart` — form state, positive-rate validation via T003, create/update/delete
- [ ] T042 [US3] Implement `ExchangeRatesListScreen` in `lib/features/pricing/presentation/exchange_rates_list_screen.dart` — shared `DataTableView`, date-range + currency filters via `CatalogFilterBar`, `CatalogPagination`, single Edit row action, row-click → read-only view
- [ ] T043 [US3] Implement `ExchangeRateDetailScreen` in `lib/features/pricing/presentation/exchange_rate_detail_screen.dart` — `ResponsiveFormGrid`, `Currency` dropdowns for base/target, shared date picker, warning-styled Delete in the form body
- [ ] T044 [US3] Add `/exchange-rates`, `/exchange-rates/new`, `/exchange-rates/:exchangeRateId` to `lib/app/router/app_router.dart` and the `exchange-rates` `NavDestination` + `NavBranch.exchangeRates` index to `lib/core/navigation/nav_destinations.dart` per contracts/routes.md. **Sequential with T019/T029** (same two files)

**Checkpoint**: All three user stories are independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T045 Write the integration test `test/integration/pricing_flow_test.dart` — golden path against a live mbe-api: create price list → price a product on it → record an exchange rate (constitution §"Development Workflow & Quality Gates"; quickstart §"Automated tests")
- [ ] T046 **Regression guard for feature 007**: add/extend a widget test asserting the product detail screen shows **no** prices anywhere and that labels still occupy the `switches|labels` band (`product_detail_screen.dart` `_SwitchesLabelsBand`). This feature deliberately does not touch the product form (007 FR-012/FR-013; spec FR-007a; research.md §1) — a price section reappearing there is a regression (quickstart §6)
- [ ] T047 Verify the RBAC gating matrix from quickstart §5 with a non-administrator user: no privileges → no nav entries and direct-URL denial; `pricing` read-only → read-only grid; `pricing` without `priceLists` → pricing works, Price Lists nav absent; `priceLists` read without update → Edit icon **hidden**, not disabled (FR-019, constitution §VI)
- [ ] T048 Run `flutter analyze` and `dart format` — zero new analyzer findings; confirm no file under `lib/generated/openapi/` was modified (constitution §III)
- [ ] T049 Run the full quickstart.md validation against a live mbe-api, including §3's **wire-format check** on the `AnyOf` write path (confirm `"price": "120.00"` arrives as a JSON string) and the >20-price-lists truncation check (G5)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories
- **US1 (Phase 3)**: Depends on Foundational. No dependency on other stories
- **US2 (Phase 4)**: Depends on Foundational **and US1's T011–T013** (`PriceList` entity + repository, needed for the left join)
- **US3 (Phase 5)**: Depends on Foundational only — fully independent of US1/US2
- **Polish (Phase 6)**: Depends on all desired stories being complete

### Cross-story file conflicts (NOT parallelizable)

T019, T029, and T044 all edit `lib/app/router/app_router.dart` **and**
`lib/core/navigation/nav_destinations.dart`. Run them **sequentially**, and keep
`NavBranch` index order identical to the router's branch order in both files:

```text
NavBranch: home(0), users(1), products(2), priceLists(3), pricing(4), exchangeRates(5)
```

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Entities → repository interface → repository impl → controllers → screens → routes/nav

### Parallel Opportunities

- T003, T004, T005 (Foundational) — different files
- All tests within a story ([P]-marked) — different files
- US1 and US3 can be built **in parallel by different developers** once Phase 2 lands (no shared files except the router/nav pair — see conflicts above)
- US2 must wait on US1's T011–T013

---

## Parallel Example: User Story 1

```bash
# Launch all US1 tests together (write first, confirm they fail):
Task: "Unit test price_list_repository_impl_test.dart"
Task: "Unit test price_lists_list_controller_test.dart"
Task: "Unit test price_list_form_controller_test.dart"
Task: "Widget test price_lists_list_screen_test.dart"
Task: "Widget test price_list_detail_screen_test.dart"
```

## Parallel Example: Foundational

```bash
Task: "Create pricing_validators.dart"
Task: "Create pricing_formatters.dart"
Task: "Add l10n keys to app_en.arb and app_es.arb"
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Phase 1: Setup (T001–T002)
2. Phase 2: Foundational (T003–T005) — **blocks everything**
3. Phase 3: User Story 1 (T006–T019)
4. **STOP and VALIDATE**: quickstart §1 — price lists CRUD works standalone
5. Deploy/demo — pricing tiers are definable

### Incremental Delivery

1. Setup + Foundational → foundation ready
2. **+ US1** → price-lists catalog → validate → demo (**MVP**)
3. **+ US2** → the pricing tool → validate (**including the `AnyOf` wire-format check — do this early**) → demo
4. **+ US3** → exchange rates → validate → demo
5. Polish → integration test, 007 regression guard, RBAC matrix, quickstart

### Parallel Team Strategy

Once Phase 2 completes:

- **Developer A**: US1 (price lists) → then US2 (needs A's T011–T013)
- **Developer B**: US3 (exchange rates) — fully independent
- Coordinate on the router/nav pair (T019 → T029 → T044, sequential)

### Risk-first suggestion

The `AnyOf` write path (T020/T026) is the feature's only genuinely unproven
mechanism (plan.md Risks). If capacity allows, spike **T020's round-trip test**
against a live mbe-api right after Phase 2 — before building US2's UI. It is
cheap to test and expensive to discover late, and a broken serializer is
invisible from the screen.

---

## Notes

- [P] tasks = different files, no unmet dependencies
- Money is `String` end-to-end — never parse to `double` (research.md §3)
- Never edit `lib/generated/openapi/` (constitution §III)
- Missing privilege ⇒ **hide** the control, never disable it (constitution §VI)
- Commit after each task or logical group
- Stop at any checkpoint to validate a story independently
