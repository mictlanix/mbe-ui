# Research: Back-Office UI Polish

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-10-22

Each entry gives the decision, why, and what else was considered. Line references are as of `main` at `2ab245e`.

## R1 — Multi-currency option: where it lives and how it is read

**Decision**:
- **The setting.**
  - Add `multiCurrencyEnabled` (default `false`) to `AppSettings` (`lib/core/config/app_settings.dart`), read from `MULTI_CURRENCY_ENABLED` with the existing `_parseBool(value, false)` helper.
  - Expose it as `multiCurrencyEnabledProvider` in `app_settings_provider.dart`, beside `productSearchMultiSelectProvider`.
  - List it in `.env.template` under the app-settings block, with its default and its fallback rule.
- **Consumers** read the narrow provider, never `AppSettings` directly. Tests override it with `multiCurrencyEnabledProvider.overrideWithValue(true)`.

**Rationale**:
- Constitution §V says app settings resolve once at startup from `--dart-define-from-file`, are listed in `.env.template`, fall back on malformed input, and are never mutable from the UI.
- `PRODUCT_SEARCH_MULTI_SELECT` (spec 038) is an exact precedent: a bool, a narrow provider, and a default that reflects the common deployment.

**Alternatives considered**:
- *A per-user display preference.* Rejected: this is deployment configuration, and §V forbids conflating the two levels.
- *Server-side tenant setting.* Rejected by the user (decision 1, "environment flag"), and it would need an mbe-api change.

## R2 — Hiding the exchange-rates destination and route

**Decision**:
- **The flag on the destination.**
  - `NavDestination` gains `final bool requiresMultiCurrency` (default `false`). Only the `exchange-rates` destination sets it.
  - `navDestinationsProvider` also watches `multiCurrencyEnabledProvider`, and `_isVisible` drops a destination whose flag is set while the option is off. The `NavGate` check is unchanged and still applies when the option is on.
- **Blocking the route.**
  - A pure helper in `nav_destinations.dart`, `bool routeRequiresMultiCurrency(String location)`, walks `kNavigationTree` for a destination with the flag whose `route` prefixes `location`.
  - `_redirect` in `app_router.dart` returns `'/'` when that helper is true and the option is off. This check sits next to the existing privilege gate, and `'/'` is the same target an unauthorized route gets (spec FR-004).
  - Because the helper reads the tree, the menu and the router share one source of truth.
- **Kept as is.** The `StatefulShellBranch` for `/exchange-rates` and `NavBranch.exchangeRates` stay, because branch indices are positional and removing a branch would renumber every later one.

**Rationale**:
- `NavGate` is a single sealed value per destination, and the exchange-rates entry already uses its slot for `PrivilegeGate`.
- A separate boolean composes with the privilege gate without nesting gates. The setting adds a condition; it doesn't replace the permission check.

**Alternatives considered**:
- *A new `NavGate` subtype wrapping an inner gate (`SettingGate(inner)`).* Rejected: it adds a recursive sealed case for one destination.
- *`bool Function(AppSettings)? enabledWhen`.* Rejected: nothing else needs that flexibility (CLAUDE.md §2).
- *Removing the branch when the option is off.* Rejected: branch indices are `const`, and `StatefulShellRoute` is built once.

## R3 — Which currency controls are hidden, and how

**Decision**: each place reads `multiCurrencyEnabledProvider` and omits its control when the option is off.

| Place | File | When off |
|---|---|---|
| Order header, disclosed group | `orders/order_header_panel.dart:285-325` | Omit both `FormGridChild`s: the currency dropdown and the exchange rate. |
| Quote header, fact strip | `quotes/quote_header_panel.dart:220-225` | Omit the Moneda `CompactField`. |
| Product form | `catalog/presentation/product_detail_screen.dart:310-320` | Omit the `currency_field` `FormGridChild`. The controller is unchanged: a new product keeps `Currency.mxn` (`product_form_controller.dart:86`), and an edited product resends the currency it loaded with, so stored data is never rewritten (FR-006). |
| Payment amount | `payment/payment_amount_field.dart:62` | `currency` becomes `Currency?`. With `null`, the field shows no `prefixText`. `payment_capture_pane.dart:107` passes `null` when the option is off. |

**Rationale**:
- Display-only hiding satisfies the user's decision 2 and the spec's assumption that nothing stored changes.
- The order header comment at `order_header_panel.dart:280-284` explains why currency and rate live together in the disclosed group, so both go together.

**Alternatives considered**: *Hiding the currency only when it equals the default.* Rejected: the user asked to hide the fields, not to make them conditional on the data (the spec's edge case covers non-default currencies).

## R4 — Facility logo upload

**Findings** (mbe-api `0d52b46`):
- `POST /api/v1/facilities/{id}/logo` runs the image through `image_service.process_and_save_image`. That function rejects anything over 2 MB, normalises the image to PNG at most 150px wide, stores the filename, and returns `FacilityResponse`. `FacilityResponse.logo` passes through the same `image_url` validator as product photos, so the client resolves it with the existing `resolvePhotoUrl`.
- **Today's form sends the resolved value back.** `FacilityFormController.submitUpdate` sends `logo: state.logo`, and `state.logo` is the *resolved* value from the response. `update_facility` stores any non-`None` `logo` it receives.
  - This only keeps working because `image_url` passes through any value containing `/`.
  - With `IMAGES_BASE_URL` set, a save replaces the stored filename with an absolute URL tied to that base.
- **No clean way to remove a logo.**
  - `update_facility` ignores `logo: null`, because it checks `is not None`, unlike products, which check `model_fields_set`.
  - `logo: ""` does clear the column, but `image_url('')` then resolves to a broken `/images/`.
  - Filed as **mictlanix/mbe-api#250**. Removal stays out of scope until it ships.

**Decision**:
- **Domain.** `Facility.fromResponse` resolves `logo` through `resolvePhotoUrl`, as `Product.fromResponse` does.
- **Repository.**
  - `FacilityRepository` loses the `logo` parameter on `create` and `update`.
  - It gains `Future<Facility> uploadLogo({required int facilityId, required Uint8List bytes, required String filename})`, implemented with the **generated** `uploadFacilityLogoApiV1FacilitiesFacilityIdLogoPost` and `MultipartFile.fromBytes` (constitution §III).
  - The product repository's raw-`_dio` upload predates the generated method and is not copied.
- **Controller.**
  - `FacilityFormState` drops `logo` (the text value) and `logoChanged`.
  - It gains `String? logoUrl` (loaded, display only), `Uint8List? pendingLogoBytes` and `String? pendingLogoFilename`.
  - `logoPicked(bytes, filename)` validates the extension (jpg/jpeg/png) and the size (2 MB) the same way `ProductFormController.photoPicked` does, writing `fieldErrors['logo']`.
  - After a successful create or update, if bytes are staged, the controller calls `uploadLogo` with the created or loaded facility id.
  - When the upload fails, it sets `saved: true` and `error: FacilityFormErrorCode.logoUploadFailed`, the same "saved, but…" pattern products use (FR-011).
- **UI.**
  - A facility-local `_LogoSection` replaces the `logo_field` `TextFormField`. It shows an `Image.memory` preview while bytes are staged, otherwise `ProductPhoto(photoUrl: logoUrl)` with its placeholder, and an upload or replace `TextButton` gated on `fieldsEnabled`.
  - Picking uses `FilePicker.platform.pickFiles(type: custom, allowedExtensions: [jpg, jpeg, png], withData: true)`, as `_pickPhoto` does.

**Rationale**:
- Staging and uploading after save mirrors the product flow users already know.
- With `logo` removed from the PUT body, the upload endpoint is the only thing that writes the stored value. This prevents the round-trip rewrite.

**Alternatives considered**:
- *Extracting product's `_PhotoSection` into a shared `core/widgets` image field.* Rejected for now: `_PhotoSection` is typed to `ProductFormState` and carries remove/preview-dialog behavior the logo doesn't need. A shared widget would mean refactoring the product screen, which this spec doesn't ask for (CLAUDE.md §3). Revisit if a third image field appears.
- *Uploading immediately on pick.* Rejected: it can't work for a facility that doesn't exist yet, and it diverges from the product flow.

## R5 — Search box: one icon, stadium shape

**Decision**:
- In `CatalogSearchBar` (`lib/core/widgets/catalog_search_bar.dart`), remove `prefixIcon` and keep the `suffixIcon` `IconButton`, which is the one that submits (FR-014).
- Give the decoration pill borders: `border`, `enabledBorder`, `focusedBorder`, `disabledBorder`, `errorBorder` and `focusedErrorBorder` are each the theme's resolved `OutlineInputBorder` with `borderRadius: BorderRadius.circular(999)`.
- Move the existing `_pill` helper and the `_pillRadius` constant out of `product_search_field.dart` into one shared function, `InputBorder? pillInputBorder(InputBorder? source)`, in `lib/core/design/shapes.dart`. Both fields call it.
- Keep `labelText`. `ProductSearchField` already shows a floating label on the same stadium shape, so the two stay consistent.

**Rationale**:
- One change fixes all 20 screens that use `CatalogSearchBar`.
- Two callers justify the shared helper, and it removes the risk of the two pills drifting apart.
- Keeping the suffix button (not the prefix) preserves the submit-only contract and the existing tooltip.

**Alternatives considered**:
- *Keep the prefix icon and make the suffix a clear (×) button.* Rejected: the user asked for one search icon, and a clear button is a new feature.
- *Change the global `InputDecorationTheme` radius.* Rejected: it would turn every form field into a pill.

## R6 — Quote and order header strip layout

**Cause**:
- Both panels lay out `Row[Expanded(Wrap(facts)), SizedBox, Flexible(trailing)]`.
- `Expanded` and `Flexible` both have `flex: 1`, so `RenderFlex` splits the free space 50/50. The facts get half the card, and the trailing slot starts at the midpoint.
- `Flexible` exists so the "Menos detalles" label (and, on the order screen, "Ver pedido") can't overflow at compact width or large text scale (order :500-502, quote :230-231).

**Decision**:
- Add `FactStripRow({required List<Widget> facts, required Widget trailing})` in `lib/core/widgets/fact_strip_row.dart`. It builds:
  - `LayoutBuilder`, then `Row(crossAxisAlignment: end)` with children `Expanded(Wrap(spacing: lg, runSpacing: sm, children: facts))`, `SizedBox(width: md)`, and `ConstrainedBox(maxWidth: constraints.maxWidth * 0.4, child: trailing)`.
  - The trailing child is non-flex, so it is laid out first at its intrinsic width, capped at 40% of the row. `Expanded` then takes everything else. The trailing child therefore sits at the trailing edge (FR-017), and the facts get all the remaining width (FR-016).
  - At a narrow width or a large text scale, the cap lets the toggle's label wrap inside its slot instead of overflowing (FR-019).
- Both panels' `_headerRow` return a `FactStripRow`.
  - The quote panel passes its toggle as `trailing`.
  - The order panel passes its existing `Wrap(alignment: end, [Ver pedido, toggle])`, or the toggle alone. A `Wrap` inside a bounded `ConstrainedBox` shrink-wraps to its widest run, so the two buttons stack when they don't fit.

**Rationale**:
- The defect exists because two copies of one layout drifted together, so sharing the row makes the fix and its test single.
- The 40% cap covers the order panel's two-button trailing group at the Medium tier while leaving the facts most of the row.

**Alternatives considered**:
- *`Expanded(flex: 3)` + `Flexible(Align(end))`.* Rejected: the facts are still capped at 75% even when the trailing group needs far less.
- *Fix both copies in place.* This is viable and touches fewer files, but leaves two copies that must keep agreeing and need two tests. Rejected narrowly; it is the fallback if the shared widget meets a surprise.
- *`IntrinsicWidth` on the trailing child.* Rejected: it gives no cap, so a long label at large text scale would starve the facts.

## R7 — Certificates table: alignment and a single scroll

**Cause**:
- The section is `SizedBox(height: (56 + 52n).clamp(0, 400), child: DataTableView(...))`.
- `DataTableView`'s unpaginated path is `Card(child: DataTable2)`. The card gets the theme margin `spacing.cardPadding` (16 or 24) on every side, which indents the table and shortens its height.
- Real row heights are `density.tableHeadingRowHeight ?? 48` and `tableDataRowHeight ?? 44`, not 56/52. With 1-4 rows the box is too short, so `DataTable2` scrolls internally inside the page's `SingleChildScrollView`.

**Decision**:
- `DataTableView` gains two optional parameters, both honored only on the unpaginated path:
  - `bool shrinkWrap = false`: wrap the card in a `SizedBox` whose height is computed **inside `DataTableView`** from the same `headingRowHeight`, `dataRowHeight` and `dividerThickness` values it passes to `DataTable2`, plus the card's border. The table then never needs to scroll. Keeping the computation in `DataTableView` respects its rule that it is "the one place any screen touches table sizing".
  - `EdgeInsetsGeometry? margin`: passed to the `Card` (default: the theme's).
- `TaxpayerCertificatesSection` drops its own `SizedBox` and passes `shrinkWrap: true, margin: EdgeInsets.zero`.
- `TaxpayerIssuerDetailScreen` wraps the certificates block (divider, header row and table) in the same centred `ConstrainedBox(maxWidth: LayoutBreakpoints.large)` that `ResponsiveFormGrid` applies to the form. The two then share edges at every width, including above 1248px, where the form is centred and the table currently isn't.
- **Verification**: a widget test asserts that the table's `Scrollable` has `maxScrollExtent == 0` for 1 and 8 certificates, and that the table's global left and right edges equal the first form field's, to within 1px (SC-006). Asserting this behavior avoids hard-coding the border arithmetic in the test.

**Rationale**: these are the minimum `DataTableView` changes that let an embedded table size to its content. Callers can't get the sizing wrong, because they never supply heights.

**Alternatives considered**:
- *Fix the constants in the caller (48/44 + 2×margin).* Rejected: it repeats `DataTableView`'s internals in a screen and breaks again when density changes.
- *Use Flutter's plain `DataTable` for this section.* Rejected: constitution §VI requires the shared table.
- *Change the global `cardTheme` margin.* Rejected: it would shift every list screen (spec assumption).

## R8 — Pricing screen alignment

**Cause** (`lib/features/pricing/presentation/pricing_grid_screen.dart`):
- The search row uses `CatalogFilterBar`, which pads by `spacing.cardPadding`.
- The worklist chips (:344-345) and the change summary bar (:252-253) use a fixed `fromLTRB(16, 0, 16, 8)`, and the hint (:158-159) a fixed `symmetric(horizontal: 16, vertical: 8)`.
- The grid adds a `Padding(horizontal: 16)` (:478-479) around a `DataTableView` whose card already carries the `cardPadding` margin.

**Decision**:
- Delete the `Padding(horizontal: 16)` at :478-479. The table card's own `cardPadding` margin then matches the search row on both sides.
- Replace the hard-coded horizontal `16`s in the chips, the change bar and the hint with `Theme.of(context).spacing.cardPadding`. The vertical values stay as they are.

**Rationale**: the search bar and the paginated table both already use `cardPadding`, so every row follows that one value (FR-022, SC-007). This screen is the only one that adds outer padding around `DataTableView`.

**Alternatives considered**: *Pass `margin: EdgeInsets.zero` (R7) and keep the 16 padding.* Rejected: that only aligns on the compact and medium tiers, where `cardPadding` is 16.

## R9 — Employee form layout

**Decision**:
- In `employee_form.dart`, split the full-span `Row(Expanded(SwitchListTile), Expanded(EntityStatusFormField))` (:309-330) into two children:
  - a single-span `FormGridChild(SwitchListTile(..., contentPadding: EdgeInsets.zero))` placed right after the enroll-number child (:282-296);
  - a full-span `FormGridChild(EntityStatusFormField(...))` placed after Notas.
- Keys and callbacks are unchanged.

**Rationale**:
- In two-column mode the switch fills the free cell beside "Número de empleado", and Estado gets the full width (FR-023, FR-024). In one-column mode the order still reads naturally (US7 scenario 3).
- `payment_method_option_form.dart:276-291` is the exact precedent, including `contentPadding: EdgeInsets.zero`, which aligns the switch label with the text fields.

## R10 — Localization

**Decision**: add these keys to both `.arb` files, then regenerate:
- `facilityLogoUploadButton` (es "Subir logotipo")
- `facilityLogoReplaceButton` (es "Cambiar logotipo")
- `facilityLogoInvalidTypeError` (es "El logotipo debe ser un archivo JPEG o PNG.")
- `facilityLogoTooLargeError` (es "El logotipo debe ser de 2 MB o menos.")
- `facilityLogoUploadFailedError` (es "La instalación se guardó, pero el logotipo no se pudo subir. Intenta de nuevo.")

`facilityLogoLabel` is reused as the section caption.

**Rationale**: the existing photo strings name the product ("La foto…", "El producto se guardó…"), so reusing them would show the wrong noun.

## R11 — Tests and goldens affected

- **Tests that assume currency fields exist need `multiCurrencyEnabledProvider.overrideWithValue(true)`**, because the new default is off. The existing tests that touch the affected fields are:
  - `order_header_density_test`, `order_header_disclosure_test`, `order_workspace_resume_test`, `quote_screen_test`
  - payment tests: `payment_capture_pane_reflow`, `payment_change_card`, `payment_step_gate`, `payment_step_layout`
  - `pos_047_extra_large_text`, `pos_compact_layout`, `sales_orders_compact`
  - product form tests that find `currency_field`
  - `app_navigation_test`, `app_router_test` (exchange-rates entries)
  - `exchange_rates_list_screen_test` and `list_url_state_test`, only if they navigate through the router
- **Goldens and screenshots that change**:
  - the `CatalogSearchBar` case in `test/golden/core_widgets_golden_test.dart`;
  - the POS/sales-list screenshots in `test/screenshots/` (`01_sales_list_*` contains a search bar);
  - any order or quote header golden. All are regenerated with `--update-goldens` and reviewed by eye.
