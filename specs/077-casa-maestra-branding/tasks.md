---
description: "Task list for 077-casa-maestra-branding"
---

# Tasks: Casa Maestra Branding

**Input**: Design documents from `specs/077-casa-maestra-branding/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R12), data-model.md, contracts/ (brand-definition, status-tones, nav-sections, release-brand), quickstart.md (V1–V6)

**Tests**: The constitution's quality gates require them. Test tasks sit inside each story, before the code they cover.

**Organization**: Grouped by user story (spec.md).
- **P1**: US1 (the Casa Maestra look, including mono IDs) and US2 (status tones and error icons).
- **P2**: US3 (app-bar rule, four nav sections, nav header) and US4 (release packaging).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 Casa Maestra look · US2 status tones · US3 chrome · US4 packaging

## Cross-story notes

- **XBE parity is the gate.** Before Phase 3 starts, `app_theme_test.dart` and `brand_independence_test.dart` must pass **unchanged** after the Phase 2 refactor. If one needs editing to pass, the refactor changed XBE: fix the refactor, not the test.
- **Shared files, do sequentially**:
  - `lib/app/theme/app_theme.dart`: T009, T014.
  - `test/golden/golden_harness.dart`: T010 only.
  - `test/golden/core_widgets_golden_test.dart`: T018, T039, T050.
  - `test/unit/core/navigation/nav_destinations_test.dart`: T045 only.
  - `lib/l10n/app_en.arb` and `app_es.arb`: T043 (add keys) then T048 (remove old keys).
  - `tool/release/lib.sh`: T054 only.
- **Generated code.** After editing the `.arb` files run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart` or `lib/generated/openapi/**`.
- **Formatting.** Run `dart format` on the changed files only, never repo-wide.
- **Golden baseline drift (found 2026-11-20).** This machine runs Flutter 3.47.7 and the baselines are from 3.44.2, so six existing goldens already fail on clean `main` (DataTableView, EntityStatusCell, LabelMultiPicker, both DateRangeFilterChip cases, StatusChip). They are not caused by this spec. When regenerating, update only the goldens this spec changes or adds (`--update-goldens` with `--plain-name`), never the whole directory, and list the six as pre-existing in the PR.
- **Goldens.** There is no CI. Regenerate with `flutter test --update-goldens <file>` per the `test/golden/README.md` workflow, and review every changed PNG. XBE login, home and theme goldens MUST NOT change (SC-002).
- **Needs the user.**
  - T002 needs the logo files, and T051 needs them again. Their scratchpad copies may be gone, so re-read them from the design system artifact (asset ids are in T002).
  - T057 builds for iOS and Android and needs signing set up on this Mac. It is `--build-only`, so nothing is uploaded or tagged.
  - `deploy/cm.env` keeps the placeholder API URL (T052). Never invent a real one.
- **Out of scope** (spec Assumptions, research Follow-ups): the Compact-tier data-table card list, the Compact status dot, the bool ✓/✗ columns, field-error icons, product codes in mono (spec 022 FR-028), and the remaining mono display sites.

---

## Phase 1: Setup

- [x] T001 [P] Add the two fonts and their licenses under `assets/fonts/`. Download from the `google/fonts` repository (`ofl/bitter/Bitter[wght].ttf`, `ofl/roboto/Roboto[wdth,wght].ttf`, and each folder's `OFL.txt`) and save them as `assets/fonts/Bitter-Variable.ttf`, `assets/fonts/Roboto-Variable.ttf`, `assets/fonts/OFL-Bitter.txt` and `assets/fonts/OFL-Roboto.txt`, matching the existing `Archivo-Variable.ttf` naming. If a path has moved, search that repository for the file. Download into an empty scratch directory, check each file with `file`, then copy it in.
- [x] T002 [P] Add the three logos under `assets/brand/xbe.cm/`. Read each from the design system artifact `https://claude.ai/artifact/XqxMRRyKYvf5auFTjWZ24t` with the Artifact tool's read action and the asset id as `path`: `f840f4919af5a09c792a696627b794aa` → `casa-maestra-logo.png` (1642×854), `c51a07e0348b46efb5c366141bcb6642` → `casa-maestra-logo-reversed.png` (1642×854), `93c35cb8bac02247a4d2ddcb0b7dd06d` → `casa-maestra-mark.png` (852×562). Then make variants with `sips`, keeping the aspect ratio: lockups at 236px wide (1x, in `assets/brand/xbe.cm/`), 472px (`2.0x/`) and 708px (`3.0x/`); the mark at 54px tall (1x), 108px (`2.0x/`) and 162px (`3.0x/`). Never redraw or recolor a logo (FR-010). Check the sizes with `sips -g pixelWidth -g pixelHeight`.
- [x] T003 Declare the assets in `pubspec.yaml` (after T001, T002): add `assets/brand/xbe.cm/` to `assets`, and two font families under `fonts:`: `Bitter` (`assets/fonts/Bitter-Variable.ttf` at weights 600 and 700) and `BrandRoboto` (`assets/fonts/Roboto-Variable.ttf` at weights 400 and 500), the same way `Archivo` is declared. The name is `BrandRoboto`, not `Roboto`, so the platform Roboto in the XBE build is not replaced (research R4). Run `flutter pub get`.
- [x] T004 [P] Add `BRAND_ID=` (empty default) to `.env.template` with a comment: empty or unknown means the default XBE brand, and release builds set it from the deployment's brand (never put it in a deployment `.env`). Keep the neighbouring `BRAND_*` entries as they are.

**Checkpoint**: assets exist and are declared. Nothing in the app reads them yet.

---

## Phase 2: Foundational (blocks every story)

**Goal**: a brand registry and a shared semantic-color extension, with XBE moved into it and unchanged.

- [x] T005 [P] Create `lib/core/branding/semantic_colors.dart`: a `ThemeExtension<SemanticColors>` with the twelve fields in data-model.md (accent, success and warning, each with `on…`, `…Container` and `on…Container`), `copyWith`, `lerp`, and a `ThemeData.semanticColors` getter whose fallback is XBE's values (contracts/brand-definition.md). Add `test/unit/core/branding/semantic_colors_test.dart`: lerp at 0 and 1, copyWith, and the fallback when the extension is missing.
- [x] T006 Create `lib/core/branding/brand_definition.dart` with `BrandDefinition`, `BrandColors`, `BrandTypography`, `LoginPaneStyle` as in data-model.md, and a const registry map holding `xbe` only for now. Add a `BrandDefinition.byId(String)` that returns `xbe` for an empty, `mbe`, `xbe` or unknown ID (FR-003).
- [x] T007 Create `lib/core/branding/brands/xbe_brand.dart` (after T005, T006): the XBE definition. **Move, do not change,** the values from `XbePalette` (the 16 dark and 18 light pins and the brand hues), the Archivo weights from `AppTheme._brandTextTheme`, the default lockup and mark asset paths and the always-dark login-pane colors from `login_branding_pane.dart`. Its `SemanticColors` take the accent family from the scheme's tertiary roles and use Casa Maestra's success and warning values (research R3). Keep `XbePalette` itself in place for the logo-placement constants.
- [x] T008 Update `lib/core/branding/brand_config.dart` (after T006, T007): add a `definition` field (default: the XBE definition, so every `BrandConfig(displayName: …)` in the ~20 existing tests still compiles) and `BrandConfig.resolve(String brandId, …)` that applies `BrandDefinition.byId`. `fromEnvironment()` reads `BRAND_ID` with `String.fromEnvironment` and tests it for non-empty, never `hasEnvironment` (research R1), then calls `resolve`. For `xbe` (and an unknown ID) the legacy `BRAND_*` flags work exactly as today. For `xbe.cm` the definition's display name, seed, lockup and mark win. An unknown non-empty ID logs one line under `kDebugMode`. Update `==` and `hashCode`. Extend `test/unit/core/branding/brand_config_test.dart`: empty, `mbe`, `xbe`, `xbe.cm`, an unknown ID, and the legacy flags still honored for `xbe`.
- [x] T009 Rework `lib/app/theme/app_theme.dart` (after T007, T008): build both schemes and the text theme from `brand.definition` instead of reading `XbePalette` and the `'Archivo'` literal. Keep `ColorScheme.fromSeed(... fidelity)` plus role overrides, and the gate that a deployment-supplied `BRAND_SEED_COLOR` still turns the XBE pins off. Register `SemanticColors` for each brightness in `extensions`. **Parity check**: run `flutter test test/widget/app/app_theme_test.dart test/unit/core/design/brand_independence_test.dart test/unit/core/branding`. All must pass **unchanged**.
- [x] T010 [P] Update `test/golden/golden_harness.dart`: add an optional `BrandConfig` parameter to the helpers that build the theme (today `_defaultBrand` is hardcoded at line ~25 and used at ~93), defaulting to the XBE brand so every existing caller is unchanged. Make `loadGoldenFonts()` also load `Bitter` and `BrandRoboto` from `rootBundle`. Keep `test/screenshots/pos_screens_screenshot_test.dart` working.
- [x] T011 Extend `test/contract/brand_contrast_test.dart` (after T005, T007): loop over every brand in the registry and both brightnesses. Check 4.5:1 for each `on*` / background pair (including the twelve semantic roles and `onSurface` / `onSurfaceVariant` on every `surface*` role) and 3:1 for `outline` on `surface` (FR-020). Today the file calls `BrandConfig.fromEnvironment()`, so build the brands from the registry instead. The XBE entry must pass: if a new semantic pair fails on XBE's warm surfaces, adjust XBE's own success or warning value, never the contrast threshold.

**Checkpoint**: the default build is byte-identical in the theme tests, and the registry holds one brand. Run V1's first command (quickstart).

---

## Phase 3: User Story 1 - The Casa Maestra build looks like Casa Maestra (Priority: P1) 🎯 MVP

**Goal**: with `BRAND_ID=xbe.cm`, login, shell and screens show Casa Maestra's colors, Bitter / Roboto / Roboto Mono and logos in both themes, and list ID, folio, RFC and date columns use mono in every brand.

**Independent Test**: quickstart V2 (values and contrast), V3 (run the app in both themes) and V4 (unknown ID falls back).

### Tests (write first, they fail until T014)

- [x] T012 [P] [US1] Create `test/unit/core/branding/casa_maestra_brand_test.dart`: every light and dark value in spec.md › Verbatim Constraints equals the built `ColorScheme` role or `SemanticColors` field (SC-001), `brand-navy` and `brand-red` constants, the type table (size, line height as `height`, weight, letter spacing, family per style), Roboto Mono for the two mono styles, and the `xbe.cm` display name and three asset paths. Spacing, shape and elevation tokens equal XBE's (FR-005).

### Implementation: the brand

- [x] T013 [US1] Create `lib/core/branding/brands/casa_maestra_brand.dart` (after T012) with the exact values from spec.md › Verbatim Constraints and contracts/brand-definition.md: seed `#00325F`, all `ColorScheme` overrides in both brightnesses, `SemanticColors` with `onSuccess` / `onWarning` as `#FFFFFF` in light and `#00210D` / `#2A1700` in dark, the Bitter / `BrandRoboto` typography with the full metrics table, the three assets under `assets/brand/xbe.cm/`, `lockupReversedAsset`, and a login-pane style that follows the theme with one accent bar. Register it under `xbe.cm` in `brand_definition.dart`.
- [x] T014 [US1] In `lib/app/theme/app_theme.dart` (after T013), confirm the generic text-theme builder applies per-style size, height (`lineHeight / fontSize`), weight, letter spacing and family from `BrandTypography`, and that `TypeRoles` mono styles still use `RobotoMono` for both brands. Fix gaps here, not with brand `if`s.
- [x] T015 [US1] Update `lib/core/widgets/brand_logo.dart`: in the dark theme use `lockupReversedAsset` when the brand has one (XBE has none, so it is unchanged); leave the mark, minimum sizes and clear space alone. Extend `test/widget/core/widgets/brand_logo_test.dart`: the Casa Maestra lockup in light and reversed in dark, and XBE in both.
- [x] T016 [US1] Make `lib/features/auth/presentation/login/login_branding_pane.dart` brand-driven: read its background, text colors, lockup and accent bars from the brand's `LoginPaneStyle` and theme instead of `XbePalette`. XBE keeps its always-dark pane with red, orange and gold bars; Casa Maestra follows the theme with one `accent` bar. Add `test/widget/features/auth/login_branding_pane_test.dart` (or extend the existing login test): both brands, both themes.
- [x] T017 [US1] Extend `test/contract/brand_contrast_test.dart` so its loop includes `xbe.cm` (T011 made it registry-driven). If a pair from the design system fails, **keep the source value and record the pair in a code comment and in the PR description** (the design system's own rule); fix only the two roles the design system left undefined.
- [x] T018 [US1] Add Casa Maestra goldens to `test/golden/core_widgets_golden_test.dart` (after T010, T013): the login branding pane, the brand logo and a text sample showing `display-small`, `title-large`, `body-medium`, `label-large` and a mono ID, in light and dark. Also a widget test at text scale 1.3 and 2.0 for the login pane and nav header with the Casa Maestra brand that fails on overflow (SC-007). Regenerate only the new baselines and review them.
- [ ] T019 [US1] Run quickstart V3 steps for login and shell in both themes and V4 on macOS, and fix what the eye catches. Record anything left over in the manual-checks issue (T062).

### Implementation: mono ID and timestamp columns (FR-019, research R10)

- [x] T020 [US1] Add `DataTableColumn.id` and `DataTableColumn.timestamp` factories to `lib/core/widgets/data_table_view.dart`, rendering with `typeRoles.recordId` and `typeRoles.timestamp`, and create `lib/core/widgets/record_id_text.dart`: one widget that renders "serial, else `#id`, else the localized draft folio" in `recordId`. Add `test/widget/core/widgets/record_id_text_test.dart` and extend the data-table tests. Do not touch `productCode` (spec 022 FR-028).
- [ ] T021 [P] [US1] Use the new column types and `RecordIdText` in the sales lists and headers: `lib/features/sales/presentation/orders/sales_orders_list_screen.dart`, `quotes/sales_quotes_list_screen.dart`, `pos_sales_list_screen.dart`, `refunds/refunds_list_screen.dart`, and the folio in the order and quote header panels. Update the widget tests that look for those texts.
- [ ] T022 [P] [US1] Same for payments: `lib/features/sales/presentation/payments/payments_list_screen.dart` (folio and date columns) and the folio heading in `payment_detail_screen.dart`. Keep the `payment_icon_verified` / `unverified` keys and tests as they are (the bool icons stay, out of scope).
- [ ] T023 [P] [US1] Same for invoicing: `lib/features/invoicing/presentation/fiscal_documents_list_screen.dart` (folio, both RFC columns, date) and the folio and RFC headings in `fiscal_document_detail_screen.dart`.
- [ ] T024 [P] [US1] Same for inventory lists: receipts, issues, transfers and counts list screens under `lib/features/inventory/presentation/` (folio and date columns) and their detail headers.
- [ ] T025 [P] [US1] Same for logistics lists: `lib/features/sales/presentation/delivery_orders/delivery_orders_list_screen.dart` and `delivery_itineraries/delivery_itineraries_list_screen.dart` (folio and date columns) and their detail headers.
- [ ] T026 [P] [US1] Same for catalog RFC columns: `lib/features/catalog/presentation/taxpayer_issuers_list_screen.dart` and the taxpayer recipients list (RFC via the mono column). Leave `products_list_screen.dart` `Text(p.code)` as it is.
- [ ] T027 [US1] Run `flutter test test/unit/core/design/type_roles_test.dart test/widget/core/widgets test/widget/features` and confirm the FR-028 test still passes unchanged (`productCode` is never mono; `recordId` and `timestamp` always are). Fix the screens, not the test.

**Checkpoint**: a `BRAND_ID=xbe.cm` build is fully branded for colors, fonts, logos and mono columns. XBE shows no change except the mono columns. This is the MVP.

---

## Phase 4: User Story 2 - Status reads by icon and word, in every brand (Priority: P1)

**Goal**: every status chip shows an icon, a word and a tone by meaning; inline errors and the two hand-built banners show an icon.

**Independent Test**: quickstart V5 (chip, banner and inline-error tests) and a visual pass over the main list screens in both brands and both themes.

- [ ] T028 [US2] Rewrite `lib/core/widgets/status_chip.dart` as in contracts/status-tones.md: add `enum StatusTone {success, warning, error, info, neutral, promo}`, replace the `colors` callback with `tone` plus an optional `icon`, render the icon as the chip's `avatar`, and take colors from `ColorScheme` and `SemanticColors`. Rewrite `test/widget/core/widgets/status_chip_test.dart`: every tone renders an icon and the label, the icon override works, `promo` is the only accent user, and the `error` and `promo` backgrounds differ in Casa Maestra.
- [ ] T029 [US2] Update `EntityStatusCell` in `lib/core/widgets/entity_status_controls.dart`: active stays plain text, inactive and archived become neutral chips with the icons in the contract. Keep the `status_badge_inactive` key (7 tests find it).
- [ ] T030 [P] [US2] Migrate `lib/features/invoicing/presentation/fiscal_document_status_chip.dart` (and the public `fiscalDocumentStatusColors`, replace it with a tone function), plus the simulated badge and the `_outcomeColors` chips in `fiscal_document_detail_screen.dart`. Update `test/widget/features/invoicing/fiscal_document_status_chip_test.dart`: assert tones instead of color pairs, and re-measure the 120px label bound with the icon (do not loosen it without measuring).
- [ ] T031 [P] [US2] Migrate `inventory_document_status_chip.dart`, `inventory_count_status_chip.dart` and `inventory_transfer_status_chip.dart` under `lib/features/inventory/presentation/`, and update their three chip tests (the transfer test pins color pairs today, assert tones).
- [ ] T032 [P] [US2] Migrate `delivery_order_status_chip.dart` and `itinerary_status_chip.dart` (which also holds `StopOutcomeChip`) under `lib/features/sales/presentation/`, and update `delivery_order_status_chip_test.dart` and `itinerary_status_chip_test.dart`.
- [ ] T033 [P] [US2] Migrate `cash_session_status_chip.dart`, `pos_sale_status_chip.dart`, `sales_quote_status_chip.dart` (it copies the POS switch: share one tone mapping), `RefundStatusChip` in `refunds/refund_detail_screen.dart`, and `PaymentVerifiedChip` and `PaymentReversedChip` in `payments/payment_widgets.dart`. Update the tests that find these chips.
- [ ] T034 [US2] Run `grep -rn "StatusChip<" lib` and `grep -rn "colors:" lib/features lib/core/widgets | grep -i status`. No caller may still pass a color callback. List every `StatusChip<` construction found against the 16 chips in contracts/status-tones.md and migrate any the explorers missed. Run `flutter analyze` on the touched files.
- [ ] T035 [P] [US2] Create `lib/core/widgets/inline_error_text.dart`: an `Icons.error_outline` icon plus text in `scheme.error`, using `typeRoles` styles. Add `test/widget/core/widgets/inline_error_text_test.dart` (icon and text present, wraps at narrow width).
- [ ] T036 [P] [US2] Use `InlineErrorText` at the inline red error texts in sales: `payment/payment_step.dart:70`, `capture/capture_step.dart:490`, `fulfillment_mode_selector.dart:335`, `credit_note_ticket_dialog.dart:155`, `record_payment_dialog.dart:383`, `refunds/refunds_list_screen.dart:524` (line numbers are from 2026-11-20, find the sites by their red `Text`).
- [ ] T037 [P] [US2] Same in delivery and catalog: `delivery_order_detail_screen.dart:1032`, `destination_card.dart:468`, `line_distribution_panel.dart:322`, `close_stop_dialog.dart:486`, `catalog/presentation/vehicle_operator_form.dart:554`, `product_detail_screen.dart:667`, `merge_products_screen.dart:137`.
- [ ] T038 [US2] Give the two hand-built banners the `ErrorBanner` icon: `pos_session_blocked_banner` in `lib/features/sales/presentation/pos_gate_screen.dart:125-145` and `refund_session_banner` in `refunds/refund_detail_screen.dart:838-860`. Prefer reusing `ErrorBanner` if it fits; keep the widget keys. Update their tests. Leave `component_themes.dart` field errors alone (spec FR-016).
- [ ] T039 [US2] Regenerate the goldens this changes in `test/golden/core_widgets_golden_test.dart` (status chip, entity status, error banners) and add a Casa Maestra tone golden: every tone in light and dark, with `error` next to `promo`. Review every changed PNG (XBE's chips change by design, nothing else).

**Checkpoint**: statuses and inline errors read by icon and word in both brands.

---

## Phase 5: User Story 3 - App chrome carries the brand rule and grouped navigation (Priority: P2)

**Goal**: a 3px accent rule under every app bar; four navigation sections; the nav header is mark-only below 840px.

**Independent Test**: quickstart V3 at 1200px and 700px, and V5 (nav and router tests).

- [ ] T040 [US3] In `lib/core/design/component_themes.dart` add `shape: Border(bottom: BorderSide(color: <semanticColors.accent>, width: 3))` to the `AppBarTheme` (research R6). Add `test/widget/core/design/app_bar_rule_test.dart`: an `AppBar` under the XBE and Casa Maestra themes paints a 3px bottom border in the accent color and its height is unchanged.
- [ ] T041 [P] [US3] Remove the local 1px `outlineVariant` `shape` override from the AppBar at `lib/features/sales/presentation/pos_workspace_screen.dart:408`, `quotes/quote_screen.dart:290` and `orders/order_workspace_screen.dart:241`, so the theme rule shows. Check their widget tests for any assertion on the old border.
- [ ] T042 [P] [US3] Draw the same 3px accent rule under the compact full-screen header in `lib/core/widgets/responsive_dialog.dart` (it has no `AppBar`, `_compact` at ~line 136), and extend its widget test.
- [ ] T043 [US3] Add the group labels to `lib/l10n/app_en.arb` and `app_es.arb`: `navOperationGroup` (Operations / Operación), `navFinanceGroup` (Finance / Finanzas), `navSystemGroup` (System / Sistema). Reuse the existing `navInventoryGroup`. Do not reuse `settingsAppearanceSystem` (it means the theme mode). Run `flutter gen-l10n`.
- [ ] T044 [US3] Replace the five groups in `kNavigationTree` in `lib/core/navigation/nav_destinations.dart` with `operation`, `inventory`, `finance` and `system` in the exact order of contracts/nav-sections.md (Home first, outside any section). Add the new top-level label tear-offs next to the existing ones (~line 597). Leave `NavBranch` indices, routes and gates untouched, and update the comments that name the old groups (~lines 272, 409, 416, 490, 574 and the `NavBranch` block).
- [ ] T045 [US3] Update `test/unit/core/navigation/nav_destinations_test.dart` for the new tree: the 37-id set is unchanged and each id appears once, section order, a section hides when all its destinations are hidden, the adjacency assertions (credit-notes after payments, payment-verification at payments+1, refunds at credit-notes+1, delivery-order-approval, for-delivery and itineraries order) now inside `operation` and `finance`, and replace the `logistics`, `invoicing` and old `inventory` lookups. Do this after T044.
- [ ] T046 [P] [US3] Update `test/widget/core/widgets/app_navigation_test.dart` (the `nav_group_catalogs` / `nav_group_sales` assertions and fixtures) and `test/unit/app/router/app_router_test.dart` (pos followed by sales-orders at ~2896). Keep `pos` then `sales-orders` adjacent in `operation`.
- [ ] T047 [P] [US3] Update the integration tests that name groups, without running them (they need a live server): `integration_test/inventory_receipts_quickstart_test.dart` (the vertical order at ~414-421 and `nav_group_inventory` findsNothing at ~849) and `inventory_issues_quickstart_test.dart` (~718). A user without inventory rights may now see Inventario through products: assert on the inventory destinations instead of the group.
- [ ] T048 [US3] Remove the l10n keys the regroup leaves unused: grep each of `catalogsGroupTitle`, `salesGroupTitle`, `logisticsGroupTitle` and `navInvoicingGroup` across `lib` and `test`, and delete a key from both `.arb` files only when nothing else uses it. Run `flutter gen-l10n` and `flutter analyze`.
- [ ] T049 [US3] Update `lib/core/widgets/brand_nav_header.dart` (research R7): mark alone below 840px (`LayoutBreakpoints.isExpanded`), mark plus `displayName` at 840px and up, for every brand. Extend `test/widget/core/widgets/app_shell_test.dart` (~155-171) with a Medium-width case (mark only) and keep the 1200px case, and check that the drawer header at Compact is mark-only too.
- [ ] T050 [US3] Regenerate the goldens this changes: `app_navigation_*` and `brand_nav_header_*` in `core_widgets_golden_test.dart`, and any golden that renders an `AppBar`. Review each PNG. Add Casa Maestra nav and app-bar goldens.

**Checkpoint**: the shell has the accent rule, four sections and a tier-aware header in both brands.

---

## Phase 6: User Story 4 - Casa Maestra ships as its own app (Priority: P2)

**Goal**: `tool/release.sh <platform> cm` builds Casa Maestra's own app; `demo` (brand `mbe`) is unchanged.

**Independent Test**: quickstart V6.

- [ ] T051 [US4] Create the three artwork sources in `deploy/brands/xbe.cm/src/` from `casa-maestra-mark.png` with `sips`, as contracts/release-brand.md describes: `app_icon_1024.png` (opaque white, mark 720px wide, centered), `android_adaptive_foreground_1024.png` (transparent, mark 600px wide, centered), `splash_1024.png` (transparent, mark 512px wide, centered). `sips` cannot composite, so pad with `sips --padToHeightWidth 1024 1024 --padColor FFFFFF` for the icon and use a transparent pad for the other two (or a short `swift`/`python3 -I` snippet with Pillow if `sips` cannot do transparent padding). Check all three are 1024×1024 and open each one to look at it.
- [ ] T052 [P] [US4] Create `deploy/brands/xbe.cm/brand.properties`, `deploy/cm.release` and `deploy/cm.env` with the exact values in contracts/release-brand.md. `API_BASE_URL=https://api.cm.invalid` is a placeholder; do not invent a real URL.
- [ ] T053 [US4] Dry-run the artwork generator: `tool/release/brand_artwork.sh xbe.cm` in a scratch worktree is what it already does. Before changing anything, list every file it writes under `android/` and `web/` (`git status` inside the worktree it prints, or run its two `dart run` commands by hand) and write the list into `specs/077-casa-maestra-branding/research.md` under R9, so T054 is built from facts. If the run cannot start, say what is missing.
- [ ] T054 [US4] Update the release tooling (`tool/release/lib.sh`, `web.sh`, `ios.sh`, `android.sh`, `overlay-manifest.txt`), as in contracts/release-brand.md: (1) add `--dart-define=BRAND_ID=$BRAND` beside `--dart-define-from-file` in the three platform scripts; (2) in `load_deployment` refuse a deployment `.env` that sets `BRAND_ID`, and refuse an `API_BASE_URL` whose host ends in `.invalid` with a message that says to fill in the real URL; (3) add the globs T053 found missing to `overlay-manifest.txt` (the Android adaptive-icon foreground and `colors.xml`, the pre-Android-12 splash backgrounds and `launch_background.xml`, the `values-night*` styles); (4) make `rewrite_web_brand` also set `manifest.json` `background_color` and the `index.html` splash body color to `WEB_THEME_COLOR`. The `mbe` value is `#14120F` already, so its output must not change.
- [ ] T055 [US4] Generate and commit the overlay: run `tool/release/brand_artwork.sh xbe.cm`, check `deploy/brands/xbe.cm/overlay/` against the manifest (the preflight requires every glob to match), and look at the generated Android adaptive icon, splash and `web/icons/*`. Commit the overlay on its own.
- [ ] T056 [US4] Run `shellcheck tool/release.sh tool/release/*.sh` (it must be clean) and `tool/release.sh web cm` (it must refuse because of the `.invalid` URL, with the message from T054).
- [ ] T057 [US4] Verify the builds (quickstart V6). With `deploy/cm.env` temporarily pointed at the test API: `tool/release.sh web cm --build-only`, `android cm --build-only`, `ios cm --build-only`, then `tool/release.sh web demo --build-only` and diff its `build/web/manifest.json` and `index.html` against a `demo` build made from `main` (FR-024). Check the APK badging (`aapt2 dump badging`) shows `com.mictlanix.xbe.cm` and "Casa Maestra". After each run `git status` must be clean; restore `deploy/cm.env`. **Ask the user before the iOS build** (it needs their signing identity).
- [ ] T058 [P] [US4] Document the brand in `deploy/README.md` and `deploy/RELEASING.md`: the `cm` deployment, `BRAND_ID` coming from the brand (never the `.env`), the `.invalid` placeholder, and a short "adding a brand" checklist that includes the overlay-manifest globs. Do not edit the spec 045 documents.

**Checkpoint**: Casa Maestra builds for web, Android and iOS with its own identity.

---

## Phase 7: Polish & cross-cutting

- [ ] T059 [P] Update `DESIGN-SYSTEM.md`: add `BRAND_ID` and the brand registry, `SemanticColors`, the status tones, the four nav sections, and the Casa Maestra type table. Mark RobotoMono's "broken promise" paragraph as partly resolved (list columns only). No constitution change is needed: §V already allows color, typography and logos per brand, and both brands use `fromSeed`.
- [ ] T060 Run `dart format` on the changed files only, `flutter analyze` (no new warnings), and the full `flutter test`. Compare the failure count with `main`; every failure must be a deliberate update from this spec.
- [ ] T061 Run quickstart V1 to V6 end to end and write down the outcome of each. Re-check SC-002: the XBE login, home and theme goldens are byte-identical to `main`.
- [ ] T062 File the follow-ups from research.md as GitHub issues in this repo (the remaining mono display sites and the `destination_*` misuse of `recordId`, the bool glyph columns, the possible empty-`BRAND_SEED_COLOR` bug in `.env.template`, the shared tri-state filter chip, the reversed lockup for print) and one manual-checks issue for what only a person can see: Casa Maestra on a real iOS and Android device, printed documents unchanged, and the largest text size on every main screen. Never put real URLs or secrets in an issue.
- [ ] T063 Save a project memory for this spec (`project_casa_maestra_branding_077.md` plus the MEMORY.md pointer): the `xbe.cm` brand ID, the `cm` deployment with its placeholder URL, the `BrandRoboto` family trap, the overlay-manifest gaps found, the white icon ground, and the decisions on FR-016 and FR-019.

---

## Dependencies & execution order

- **Phase 1** → **Phase 2** → everything else. T003 needs T001 and T002.
- **Phase 2 order**: T005 and T006 first (parallel), then T007, T008, T009. T010 can start any time after T006. T011 after T005 and T007.
- **US1** needs Phase 2. **T012** before **T013**; T013 before T014 to T018. T020 before T021 to T026 (those six are parallel).
- **US2** needs Phase 2 and T005. It does not need US1, but run it after US1 because both change `core_widgets_golden_test.dart`. T028 before T029 to T033. T035 before T036 to T038.
- **US3** needs Phase 2. T040 needs T005. T043 before T044, T044 before T045 to T048. T049 needs T006.
- **US4** is independent of US1 to US3 in code, but T057 only shows Casa Maestra if US1 is done (T013). T051 and T052 can run any time after T002.
- **Phase 7** last.

## Parallel examples

```text
Phase 1:   T001 + T002 + T004
Phase 2:   T005 + T006, later T010 alongside T007–T009
US1 mono:  T021 + T022 + T023 + T024 + T025 + T026 (after T020)
US2:       T030 + T031 + T032 + T033 (after T028); T036 + T037 (after T035)
US3:       T041 + T042 (after T040); T046 + T047 (after T045)
US4:       T051 + T052, then T058 anywhere
```

## Implementation strategy

- **MVP**: Phases 1 and 2, then US1 (T012 to T027). A Casa Maestra build is then fully branded; the XBE build only gains mono columns.
- **Increment 2**: US2 (status tones and error icons), which is also what makes the red brand safe to use.
- **Increment 3**: US3, then US4. US4 may ship in parallel with US2 and US3 if someone else takes it.
- Regenerate and review goldens at the end of each increment, never in bulk at the end.
- Stop at each checkpoint and run the matching quickstart section.
