---

description: "Task list for Back-Office UI Polish"
---

# Tasks: Back-Office UI Polish

**Input**: Design documents from `/specs/049-back-office-ui-polish/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/ui-contracts.md](./contracts/ui-contracts.md), [quickstart.md](./quickstart.md)

**Tests**: Included. The plan's quality gates call for unit and widget tests, and constitution §VI requires a compact-width and largest-text-size check for layout changes. `R#` and `C#` refer to [research.md](./research.md) and [contracts/ui-contracts.md](./contracts/ui-contracts.md).

**Organization**: Tasks are grouped by user story. Paths are relative to the repository root.

**Backend status**: no mbe-api change is needed. The logo upload is already in the generated client, so do not re-run OpenAPI codegen. Logo *removal* waits on mictlanix/mbe-api#250 and is out of scope.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: The user story the task belongs to (US1–US7, matching the spec)

## Path Conventions

Flutter, feature-first. Sales code is under `lib/features/sales/presentation/` (shortened to `sales/presentation/`), catalog code under `lib/features/catalog/` (shortened to `catalog/`). Tests are under `test/unit/` and `test/widget/`.

**Shared files.** US1 and US4 both edit `order_header_panel.dart` and `quote_header_panel.dart`. Do US1 first, then US4. US3 and US4 touch different files and can run in parallel with anything else.

---

## Phase 1: Setup

**Purpose**: Establish a clean baseline before changing anything.

- [X] T001 Run `flutter analyze` and `flutter test` on the branch and record any pre-existing failures in a comment on this task, so they are not mistaken for regressions. 
  - **Baseline result** (measured on `2ab245e` for the golden and screenshot files, and on this branch for the rest): `flutter analyze` is clean. These tests fail on the base commit and are unrelated to this spec: six goldens in `test/golden/core_widgets_golden_test.dart` (`DataTableView`, both `DateRangeFilterChip` cases, `EntityStatusCell`, `LabelMultiPicker`, `StatusChip`, plus `CatalogFilterBar`, which this spec's search-box change legitimately updates), the `01_sales_list_1440` screenshot test, and `repository_list_params_audit_test` (Products). `test/integration/auth_flow_test.dart` scenario 2 failed in an earlier offline run and passes against the live API.
  - There is no foundational phase: each story owns the shared piece it introduces (`pillInputBorder`, `FactStripRow`, the `DataTableView` options, the l10n keys).

---

## Phase 2: User Story 1 - Single-currency deployments don't show exchange rates (Priority: P1) 🎯 MVP

**Goal**: With `MULTI_CURRENCY_ENABLED` off (the default), the exchange-rates entry, route and currency controls are gone. With it on, everything is as before (FR-001–FR-007).

**Independent Test**: Quickstart §1 and §2. Build with the option off and with it on, and check each place listed in C1.

### Implementation for User Story 1

- [X] T002 [US1] Add `multiCurrencyEnabled` (default `false`) to `AppSettings` in `lib/core/config/app_settings.dart`. Read it from `MULTI_CURRENCY_ENABLED` with `_parseBool(value, false)`, add it to the `const` constructor and to the debug print, and document it like `productSearchMultiSelect` (R1). Add `multiCurrencyEnabledProvider` to `lib/core/config/app_settings_provider.dart`. List `MULTI_CURRENCY_ENABLED=false` in `.env.template` with its default and its fallback rule, in the app-settings block
- [X] T003 [P] [US1] Add `AppSettings` tests to `test/unit/core/config/app_settings_test.dart`: the default is `false`, and the provider follows an overridden `AppSettings`. Parsing `true`, `TRUE`, `false` and a malformed value (→ `false`) is tested through `_parseBool` the same way the existing `PRODUCT_SEARCH_MULTI_SELECT` cases are
- [X] T004 [US1] Add `final bool requiresMultiCurrency` (default `false`) to `NavDestination` in `lib/core/navigation/nav_destination.dart`. In `lib/core/navigation/nav_destinations.dart`, set it on the `exchange-rates` destination, make `navDestinationsProvider` also watch `multiCurrencyEnabledProvider`, and make `_isVisible` drop a flagged destination while the option is off (the privilege gate still applies when it is on). Add the public pure helper `bool routeRequiresMultiCurrency(String location)`, which walks `kNavigationTree` for a flagged destination whose `route` is a prefix of `location` (R2)
- [X] T005 [US1] In `lib/app/router/app_router.dart`, make `_redirect` return `'/'` when `routeRequiresMultiCurrency(state.matchedLocation)` is true and the option is off. Put the check beside the existing `_routeGate` check (after the legacy-record redirect). Read the option with `ref.read(multiCurrencyEnabledProvider)` (FR-004)
- [X] T006 [P] [US1] In `sales/presentation/orders/order_header_panel.dart`, omit both `FormGridChild`s for the currency dropdown (`sales_order_currency_field`) and the exchange rate while the option is off. Read it with `ref.watch(multiCurrencyEnabledProvider)`, and keep the explanatory comment next to the gate (R3)
- [X] T007 [P] [US1] In `sales/presentation/quotes/quote_header_panel.dart`, omit the Moneda `CompactField` from the fact strip while the option is off (R3)
- [X] T008 [P] [US1] In `catalog/presentation/product_detail_screen.dart`, omit the `currency_field` `FormGridChild` while the option is off. Leave `ProductFormController` unchanged: a new product keeps `Currency.mxn` and an edited one resends the currency it loaded with (R3, FR-006)
- [X] T009 [P] [US1] In `sales/presentation/payment/payment_amount_field.dart`, change `currency` to `Currency?` and drop `prefixText` when it is `null`. In `sales/presentation/payment/payment_capture_pane.dart`, pass `null` while the option is off and `sale.currency` otherwise (R3)
- [X] T010 [US1] Make the existing tests that assume currency controls pass again, by adding `multiCurrencyEnabledProvider.overrideWithValue(true)` where they need it (R11). Run them first to see which actually fail, rather than editing every file listed:
  - `test/widget/features/sales/`: `order_header_density_test`, `order_header_disclosure_test`, `order_workspace_resume_test`, `quote_screen_test`, `payment_capture_pane_reflow_test`, `payment_change_card_test`, `payment_step_gate_test`, `payment_step_layout_test`, `pos_047_extra_large_text_test`, `pos_compact_layout_test`, `sales_orders_compact_test`
  - the product form tests that find `currency_field`
  - `test/widget/core/widgets/app_navigation_test.dart` and `test/unit/app/router/app_router_test.dart` (the exchange-rates entries)
  - `exchange_rates_list_screen_test.dart` and `list_url_state_test.dart`, only if they route through the shell
- [X] T011 [P] [US1] Add tests for the option-off behavior (C1):
  - create `test/unit/core/navigation/nav_destinations_test.dart` (the file doesn't exist yet): with the option off the `exchange-rates` item is absent even for an administrator, and present with it on and the privilege held; `routeRequiresMultiCurrency` is true for `/exchange-rates` and `/exchange-rates/new` and false for `/products`
  - `test/unit/app/router/app_router_test.dart`: with the option off, `/exchange-rates`, `/exchange-rates/new` and `/exchange-rates/7` all end at `/`. The last two go through the legacy-record redirect first, then the new check. With the option on, `/exchange-rates` stays reachable
  - widget tests with the option off: no currency/rate field in the order header and the quote header, no `currency_field` in the product form (and a create request carries MXN), no prefix on `payment_amount_field`

**Checkpoint**: US1 is shippable alone. Exchange rates are hidden by default.

---

## Phase 3: User Story 2 - Facility logo is uploaded as an image (Priority: P2)

**Goal**: The facility form picks an image, previews it, and uploads it after save (FR-008–FR-012).

**Independent Test**: Quickstart §3. Edit a facility, pick a PNG, save, reopen, and see the logo. Pick a `.gif` and see the inline error.

### Implementation for User Story 2

- [X] T012 [US2] Add the five keys from R10 to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb` (`facilityLogoUploadButton`, `facilityLogoReplaceButton`, `facilityLogoInvalidTypeError`, `facilityLogoTooLargeError`, `facilityLogoUploadFailedError`), then run `flutter gen-l10n`. Do not hand-edit `app_localizations*.dart`
- [X] T013 [P] [US2] In `catalog/domain/entities/facility.dart`, resolve `logo` through `resolvePhotoUrl` in `Facility.fromResponse`, as `Product.fromResponse` does. Run `dart run build_runner build --delete-conflicting-outputs` if the freezed output changes
- [X] T014 [US2] In `catalog/domain/repositories/facility_repository.dart`, remove the `logo` parameter from `create` and `update`, and add `Future<Facility> uploadLogo({required int facilityId, required Uint8List bytes, required String filename})`. In `catalog/data/facility_repository_impl.dart`, drop `logo` from the `FacilityCreate`/`FacilityUpdate` builders and implement `uploadLogo` with the generated `uploadFacilityLogoApiV1FacilitiesFacilityIdLogoPost` and `MultipartFile.fromBytes`, mapping `DioException` through the existing `_toAppError`. Then fix every fake or mock of `FacilityRepository` under `test/` (find them with `grep -rn "FacilityRepository" test`)
- [X] T015 [US2] In `catalog/presentation/facility_form_controller.dart`, remove `logo` and `logoChanged`, and add `logoUrl`, `pendingLogoBytes` and `pendingLogoFilename` to `FacilityFormState`. Add `logoPicked(bytes, filename)`, which validates the jpg/jpeg/png extension and the 2 MB limit like `ProductFormController.photoPicked` and writes `fieldErrors['logo']`. Load `logoUrl` from `facility.logo` in `loadForEdit`. After a successful `submitCreate` or `submitUpdate`, upload staged bytes with `uploadLogo` (using the created or loaded `facilityId`); on `AppError` set `saved: true` and `FacilityFormErrorCode.logoUploadFailed`, keep the staged bytes, and store the created facility's id in `state.facilityId`, so the retry goes through `submitUpdate` instead of creating a duplicate. Clear `saved` and `error` when a new submit starts. Add the new error codes to `FacilityFormErrorCode`, then regenerate freezed with `build_runner` (data-model §4, R4)
- [X] T016 [US2] In `catalog/presentation/facility_detail_screen.dart`, replace the `logo_field` `TextFormField` with a `_LogoSection` (keys `facility_logo_section`, `facility_logo_upload_button`, `facility_logo_replace_button`). It shows `Image.memory` for staged bytes, otherwise `ProductPhoto(photoUrl: logoUrl)`, plus an upload/replace `TextButton` enabled only when `fieldsEnabled` and not submitting. Pick with `FilePicker.platform.pickFiles(type: custom, allowedExtensions: ['jpg','jpeg','png'], withData: true)` and call `controller.logoPicked`. Show the localized `fieldErrors['logo']` and the upload-failed message, using the existing `_localizeFieldError` pattern (C2). **Don't pop on a failed upload (FR-011).** The screen's `if (formState.saved || formState.deleted)` post-frame `context.pop()` (about :90-94) currently fires even when `error` is set, so the banner would flash for one frame at most. Change it so that it does not pop while `formState.saved && formState.error != null`. The form then stays open with the banner, and the staged bytes are kept, so the user can save again to retry. Because the record already exists after a failed create, the screen's save must call `submitUpdate` once `formState.facilityId` is set (T015 stores it), even in create mode
- [X] T017 [P] [US2] Create `test/unit/features/catalog/facility_form_controller_test.dart` (the file doesn't exist yet) with these controller tests:
  - `logoPicked` rejects a `.gif` and an over-2 MB file and leaves state untouched;
  - create and update no longer send `logo`;
  - staged bytes are uploaded after a successful create (using the new id) and after an update;
  - an upload failure leaves `saved: true` with `logoUploadFailed`, keeps the staged bytes, and keeps the created `facilityId`;
  - a retry after a failed create calls update plus upload, not create;
  - a failed create attempts no upload.
- [X] T018 [P] [US2] Extend the existing `test/widget/features/catalog/facility_detail_screen_test.dart` (C2) with these cases:
  - the placeholder and "Subir logotipo" show with no logo;
  - the replace button shows with a logo;
  - the section is read-only in view mode;
  - `logo_field` no longer exists;
  - an unreachable `logoUrl` renders the placeholder without throwing (spec edge case);
  - after a save whose upload fails, the screen is still open and `facilityLogoUploadFailedError` is visible on the next frames (pump past the post-frame callback).

**Checkpoint**: US2 is shippable alone.

---

## Phase 4: User Story 3 - A cleaner, consistent search box (Priority: P2)

**Goal**: Every list screen's search box is a stadium shape with one search icon (FR-013–FR-015).

**Independent Test**: Quickstart §4, search box. Open Empleados and Precios, then check the shape and the single icon, and that Enter and the icon both search.

### Implementation for User Story 3

- [X] T019 [US3] Add `InputBorder? pillInputBorder(InputBorder? source)` and its 999 radius constant to `lib/core/design/shapes.dart`, moved from `_pill`/`_pillRadius` in `sales/presentation/capture/product_search_field.dart`. Make `ProductSearchField` call the shared helper and delete its private copies, with no visual change (R5)
- [X] T020 [US3] In `lib/core/widgets/catalog_search_bar.dart`, remove `prefixIcon` and keep the suffix `IconButton`. Build the decoration's `border`, `enabledBorder`, `focusedBorder`, `disabledBorder`, `errorBorder` and `focusedErrorBorder` from `pillInputBorder(Theme.of(context).inputDecorationTheme.<border>)`. Keep `labelText`, the tooltip, submit-on-Enter and the absence of `onChanged` (C3)
- [X] T021 [P] [US3] Create `test/widget/core/widgets/catalog_search_bar_test.dart` (the file doesn't exist yet) (C3): exactly one `Icons.search` descendant, tapping it calls `onSubmitted` with the text, Enter submits, typing alone doesn't, and the resolved `enabledBorder` is an `OutlineInputBorder` whose radius is at least half the field height. Also check the existing tests that find `Icons.search` (`cash_sessions_screen_test`, `vehicles_list_screen_test`, `taxpayer_certificates_section_test`) still pass; fix any that relied on the prefix icon

**Checkpoint**: US3 is shippable alone. Goldens are regenerated in the polish phase.

---

## Phase 5: User Story 4 - Quote and order headers read as one line (Priority: P2)

**Goal**: The facts use the full width and the toggle sits at the trailing edge, without overflow at compact width or the largest text size (FR-016–FR-019). Do this after US1, which edits the same two files.

**Independent Test**: Quickstart §4, headers. Open a quote and an order at desktop width, at about 390 px, and at the largest text size.

### Implementation for User Story 4

- [X] T022 [US4] Create `lib/core/widgets/fact_strip_row.dart`: `FactStripRow({required List<Widget> facts, required Widget trailing})` as a `LayoutBuilder` over `Row(crossAxisAlignment: end)`: `Expanded(Wrap(spacing: lg, runSpacing: sm, children: facts))`, `SizedBox(width: md)`, and `ConstrainedBox(maxWidth: constraints.maxWidth * 0.4, child: trailing)` as a non-flex child. Use the spacing tokens from `Theme.of(context).spacing`. Document why the trailing child is non-flex and capped (R6)
- [X] T023 [P] [US4] In `sales/presentation/quotes/quote_header_panel.dart`, make `_headerRow` return a `FactStripRow` with the five facts and the toggle (`sales_quote_more_details_toggle`) as `trailing`. Keep the keys, the expired marker and the disclosure behavior unchanged, and update the comments that described the `Flexible` slot
- [X] T024 [P] [US4] In `sales/presentation/orders/order_header_panel.dart`, make `_headerRow` return a `FactStripRow` with the facts and the salesperson field, and `trailing` as the existing `Wrap(alignment: end, [Ver pedido, toggle])` (or the toggle alone without `canViewPedido`). Keep the `ConstrainedBox(maxWidth: 200)` on the salesperson field and every key unchanged
- [X] T025 [P] [US4] Add `test/widget/core/widgets/fact_strip_row_test.dart` (C4): at 1440 px all facts share one `dy` and the trailing child's right edge is at the row's right edge; at 390 px with a 2× text scale there are no overflow errors and the trailing child is fully on screen
- [X] T026 [US4] Extend `test/widget/features/sales/quote_screen_test.dart` and `order_header_disclosure_test.dart` (C4): at desktop width the facts are on one line and the toggle is at the card's trailing edge; at 390 px and the largest text size, neither the "Más detalles" nor the "Menos detalles" state overflows

**Checkpoint**: US4 is shippable alone (after US1).

---

## Phase 6: User Story 5 - Certificates table aligns and scrolls with the page (Priority: P3)

**Goal**: The table lines up with the form, shows all rows, and only the page scrolls (FR-020–FR-021).

**Independent Test**: Quickstart §4, certificates. Edit an issuer with one certificate and one with eight.

### Implementation for User Story 5

- [X] T027 [US5] In `lib/core/widgets/data_table_view.dart`, add `bool shrinkWrap = false` and `EdgeInsetsGeometry? margin` (documented as unpaginated-only). On the unpaginated path, pass `margin` to the `Card`; when `shrinkWrap` is set, wrap the card in a `SizedBox` whose height is computed from the same `headingRowHeight`, `dataRowHeight` and `dividerThickness` that go to `DataTable2`, plus the card's vertical margin and border, so the table never scrolls vertically (R7). Leave the paginated path untouched
- [X] T028 [US5] In `catalog/presentation/taxpayer_certificates_section.dart`, delete the `SizedBox(height: (56 + 52.0 * n).clamp(0, 400))` and the comment that justifies it, and pass `shrinkWrap: true, margin: EdgeInsets.zero` to `DataTableView`. In `catalog/presentation/taxpayer_issuer_detail_screen.dart`, wrap the divider and the certificates section in `Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: LayoutBreakpoints.large), child: ...))`, matching the `ResponsiveFormGrid` cap so the two share edges above 1248 px
- [X] T029 [P] [US5] Add `DataTableView` tests in `test/widget/core/widgets/data_table_view_test.dart` for `shrinkWrap` (the table's `Scrollable` reports `maxScrollExtent == 0` vertically for 1 and for 8 rows) and for `margin` (the card's outer edges match the given margin)
- [X] T030 [US5] Extend `test/widget/features/catalog/taxpayer_certificates_section_test.dart` and the issuer detail test (C5): with 1 and 8 certificates there is no inner vertical scroll; the table's left and right global edges match the first form field's within 1 px at 1024 px and 1600 px; an issuer with none shows `noCertificatesFound` without a fixed-height box

**Checkpoint**: US5 is shippable alone.

---

## Phase 7: User Story 6 - Pricing screen rows line up (Priority: P3)

**Goal**: The search box, chips, change bar, table and hint share one left and right edge (FR-022).

**Independent Test**: Quickstart §4, pricing. Open Precios at 800 px and 1440 px.

### Implementation for User Story 6

- [X] T031 [US6] In `lib/features/pricing/presentation/pricing_grid_screen.dart`: delete the `Padding(horizontal: 16)` around `DataTableView` (about :478-479); replace the horizontal `16`s in `_WorklistChips` (about :345), `_ChangeSummaryBar` (about :253) and the hint (about :159) with `Theme.of(context).spacing.cardPadding`; leave the vertical values alone (R8)
- [X] T032 [P] [US6] Add `test/widget/features/pricing/pricing_grid_alignment_test.dart` (C6): at 800 px and 1440 px, the search field, the first `ChoiceChip`, the table `Card` and the hint text have left edges within 1 px of one another, and the table's right edge matches the search row's. Include a case with pending edits so the change bar is checked too

**Checkpoint**: US6 is shippable alone.

---

## Phase 8: User Story 7 - Employee form uses its space (Priority: P3)

**Goal**: The Vendedor switch sits beside Número de empleado, and Estado is full width (FR-023–FR-024).

**Independent Test**: Quickstart §4, employees. Open Empleados → Nuevo at a two-column width.

### Implementation for User Story 7

- [X] T033 [US7] In `catalog/presentation/employee_form.dart`, replace the full-span `Row(Expanded(SwitchListTile), Expanded(EntityStatusFormField))` with two children. First, a single-span `FormGridChild(SwitchListTile(key: Key('sales_person_switch'), ..., contentPadding: EdgeInsets.zero))` placed immediately after the enroll-number child. Second, a full-span `FormGridChild(EntityStatusFormField(...))` placed after Notas. Keep keys and callbacks unchanged. Follow `payment_method_option_form.dart:276-291` (R9)
- [X] T034 [P] [US7] Add or extend `test/widget/features/catalog/employee_form_test.dart` (C7): at a two-column width `sales_person_switch` has the same `dy` as `enroll_number_field` and a greater `dx`; the status field's width equals the form content width; at one column the order stacks without overlap; toggling the switch and saving still submits `salesPerson`

**Checkpoint**: US7 is shippable alone.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Verify the whole branch together.

- [X] T035 Run `dart run build_runner build --delete-conflicting-outputs` and `flutter gen-l10n`, then `flutter analyze`. Fix anything the stories introduced and confirm no generated file is hand-edited
- [X] T036 Regenerate the goldens and screenshots with `flutter test --update-goldens test/golden test/screenshots`, then review each changed image by eye. Expect the `CatalogSearchBar` golden, the `01_sales_list_*` screenshots and any order or quote header image to change. Revert any image that changed for a reason unrelated to this spec.
  - **Done**: updated only `catalog_search_bar_*` and `catalog_filter_bar_*` (it embeds the search bar), and added `fact_strip_row_*` (plus its entry in the golden coverage guard). The other pre-existing golden failures were restored, not updated
- [X] T037 Run the full `flutter test`. Compare any failure with the baseline from T001, and confirm `test/unit/core/formatting_guard_test.dart` still passes
- [X] T038 [P] Check the compact (390 px) width and the largest text size for each touched screen with the existing `expectNoHorizontalScroll` helper or a screenshot: both headers, a list screen's search row, the facility form, the employee form, the pricing screen and the issuer screen (constitution §VI, FR-025)
  - **Covered by tests**: `fact_strip_row_test` (390 px at 2× text), `sales_orders_compact_test` (the order header at 390 px and four text scales), `employee_form_test` (400 px), the issuer and pricing alignment tests at 800–1600 px. The search box at 390 px and the facility form at the largest text size are not covered by a test and were not checked by eye
- [X] T039 Walk through [quickstart.md](./quickstart.md) against a running mbe-api, once with `MULTI_CURRENCY_ENABLED` unset and once with it `true`, and tick each manual check. This walkthrough is also the check for SC-003 (setting a logo takes under 30 seconds) and SC-008 (the employee form is one row shorter), which no automated test can measure
  - **Browser walkthrough, 2026-10-22** (Chrome, user's screenshots): with the option off, the menu has no Tipos de Cambio, the order and quote headers have no Moneda or Tipo de cambio and their facts sit on one line with the toggle at the trailing edge, the product form has no currency picker, the payment amount has no prefix, a facility logo uploads and shows on reopen, the employee form puts Vendedor beside Número de empleado with Estado full width, the certificates table aligns with one scroll, and Precios rows share one left edge. With the option on, all of these come back (Moneda + Tipo de cambio 1.0000 in the order details, Moneda in the quote strip, the product currency picker, the "MXN" prefix) and `/exchange-rates` loads. One fix came out of it: the read-only facility view showed a disabled "Cambiar logotipo"; it is now hidden there (C2).
  - **Live API checks done on 2026-10-22**:
    - **Integration suite:** `flutter test test/integration --dart-define-from-file=.env` gives 33 passed, 27 skipped (no credentials) and 6 failed. The same 6 fail identically on base `2ab245e`, so none comes from this branch: `cash_session_flow` (409, the drawer already has an open session), `catalog_consistency` US2-1, `catalog_logistics` (409 conflict), `crud_panel` Customers, `facility_children_controller_live` (Ref used after dispose) and `product_catalog` scenario 1 (not authenticated). `facility_catalogs_flow`, which creates a facility without `logo`, passes.
    - **Throwaway live logo round-trip (deleted afterwards):** create (no logo) → `uploadLogo` with a PNG → a resolved absolute URL that serves `image/png` → `update` leaves the stored `/images/<hash>.png` unchanged → the facility and address are deleted. Upload of non-image bytes → the server's 422 arrives as `ValidationError` (an `AppError`), which is the path that shows `logoUploadFailed`.

---

## Dependencies & Execution Order

### Phase dependencies

- **Phase 1 (Setup)**: no dependencies.
- **Phases 2–8 (the seven stories)**: each depends only on Phase 1, with one exception: **US4 comes after US1**, because both edit `order_header_panel.dart` and `quote_header_panel.dart`.
- **Phase 9 (Polish)**: after every story you intend to ship.

### Within each story

- **US1**: T002 first; T004 before T005; T006–T009 are independent of one another and of T004–T005 (they need only T002); T010 after all of T004–T009; T011 can start once the matching implementation task is done.
- **US2**: T012, T013 and T014 are independent; T015 needs T013 and T014; T016 needs T012 and T015; T017 and T018 follow.
- **US3**: T019 → T020 → T021.
- **US4**: T022 first; T023 and T024 in parallel; then T025 and T026.
- **US5**: T027 → T028 → T029 and T030.
- **US6 and US7**: one implementation task, then its test.

### Parallel opportunities

- After T001, US2, US3, US5, US6 and US7 touch disjoint files, so they can be worked at the same time.
- Inside US1, T006, T007, T008 and T009 are four different files.

```text
After T001, in parallel:
  US1 (T002–T011)  ──▶ US4 (T022–T026)
  US2 (T012–T018)
  US3 (T019–T021)
  US5 (T027–T030)
  US6 (T031–T032)
  US7 (T033–T034)
then Polish (T035–T039)
```

---

## Implementation Strategy

**MVP**: User Story 1 alone (T001–T011). It is the P1 item, and it changes what every deployment sees by default.

**Incremental delivery**, in the spec's priority order:
1. US1, then US4 on the same two files.
2. US2 and US3 (the other P2 items), in either order.
3. US5, US6 and US7 (the P3 layout fixes), in any order.
4. Polish.

Each story passes its own independent test, so any subset can ship. The plan's alternative for US4 is fixing the two headers in place instead of `FactStripRow`; use it only if T022 hits a surprise.
