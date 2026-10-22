# Implementation Plan: Back-Office UI Polish

**Branch**: `049-back-office-ui-polish` | **Date**: 2026-10-22 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/049-back-office-ui-polish/spec.md` (tracked by mictlanix/mbe-ui#200)

## Summary

Seven user stories. None needs a backend change.

1. **Multi-currency option (P1).**
   - A new `MULTI_CURRENCY_ENABLED` app setting (default `false`) is exposed as `multiCurrencyEnabledProvider`.
   - `NavDestination.requiresMultiCurrency` hides "Tipos de Cambio" from the menu. A tree-derived `routeRequiresMultiCurrency` check in `_redirect` sends `/exchange-rates` to `/`.
   - With the option off, the order header (currency and rate), the quote header (Moneda), the product form (currency picker) and the payment amount (prefix) omit their currency controls. Stored values are untouched (R1–R3).
2. **Facility logo (P2).**
   - An image picker with preview replaces the text field. The image is uploaded after save through the generated `POST /facilities/{id}/logo`, mirroring the product photo flow.
   - `logo` is removed from create/update, so saving the form no longer writes the resolved URL back over the stored filename (R4).
   - Logo removal waits on mictlanix/mbe-api#250.
3. **Search box (P2).** `CatalogSearchBar` keeps only its suffix submit icon and takes a pill border from a shared `pillInputBorder` helper, also used by `ProductSearchField` (R5).
4. **Quote and order headers (P2).** A shared `FactStripRow` gives the facts all the width the trailing control doesn't need, and caps the trailing control at 40% so it can't overflow. This fixes the 50/50 flex split in both panels (R6).
5. **Certificates table (P3).** `DataTableView` gains `shrinkWrap` and `margin` for its unpaginated path. The section uses both and drops its wrong height formula. The issuer screen caps the certificates block at the form's maximum width (R7).
6. **Pricing alignment (P3).** The extra `Padding(16)` around the grid is removed, and the hard-coded 16s become `spacing.cardPadding` (R8).
7. **Employee form (P3).** The salesperson switch moves into the cell beside the enroll number, and Estado spans the full width (R9).

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter stable (unchanged)

**Primary Dependencies**:
- Riverpod (`riverpod_annotation`/generator), `freezed`, `go_router`, `data_table_2`, `file_picker` `^8.1.2`, and the generated `mbe_api_client`.
- **No new packages.** No OpenAPI regeneration is needed: the logo endpoint is already generated.
- `build_runner` re-runs for the `FacilityFormState` changes.

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter_test` + `mocktail` with `ProviderScope` overrides. The new `multiCurrencyEnabledProvider` is overridden per test.
- Goldens for `core_widgets_golden_test` and `test/screenshots` are regenerated and reviewed by eye.

**Target Platform**: Web and desktop first (Expanded tier). Compact (390px) and the largest text size are verified for the header strip, the search box and the employee form.

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**: no new reads. Saving a facility adds one upload request, and only when a logo is staged.

**Constraints**:
- §V: app settings resolve at build time, are listed in `.env.template`, fall back on malformed values, and are never mutable from the UI.
- §VI: shared tables stay in `core/widgets`, and nothing may clip at the largest text size.
- `formattersProvider` is untouched, and no new display formatting is added.

**Scale/Scope**:

| | Files |
|---|---|
| **New** | `lib/core/widgets/fact_strip_row.dart` |
| **Edited, core** | `config/app_settings.dart`, `config/app_settings_provider.dart`, `navigation/nav_destination.dart`, `navigation/nav_destinations.dart`, `design/shapes.dart` (`pillInputBorder`), `widgets/catalog_search_bar.dart`, `widgets/data_table_view.dart`; `app/router/app_router.dart` |
| **Edited, sales** | `orders/order_header_panel.dart`, `quotes/quote_header_panel.dart`, `payment/payment_amount_field.dart`, `payment/payment_capture_pane.dart`, `capture/product_search_field.dart` |
| **Edited, catalog** | `product_detail_screen.dart`; facility: `domain/entities/facility.dart`, `domain/repositories/facility_repository.dart`, `data/facility_repository_impl.dart`, `presentation/facility_form_controller.dart`, `presentation/facility_detail_screen.dart`; `taxpayer_certificates_section.dart`, `taxpayer_issuer_detail_screen.dart`, `employee_form.dart` |
| **Edited, pricing** | `pricing_grid_screen.dart` |
| **Edited, other** | `.env.template`; both `.arb` files plus the regenerated `app_localizations*.dart` (5 keys) |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | The logo upload goes through `FacilityRepository` (domain interface) and `FacilityRepositoryImpl` (data), and the controller stages the bytes. The layout widgets stay in `presentation` or `core/widgets`. |
| **II. Riverpod** | Pass | `multiCurrencyEnabledProvider` is a plain `Provider<bool>` derived from `appSettingsProvider`, the same pattern as `productSearchMultiSelectProvider`. No other DI. |
| **III. Contract-driven API** | Pass | The logo upload uses the generated `uploadFacilityLogoApiV1FacilitiesFacilityIdLogoPost`. No hand-written endpoint, no regeneration. |
| **IV. Deny-by-default RBAC** | Pass | The setting only narrows: the exchange-rates entry still needs `PrivilegeGate(exchangeRates, read)` when the option is on. The logo upload buttons follow the form's existing `fieldsEnabled`, and the server checks `facilities` update. No new privileges. |
| **V. Material 3 / l10n / settings split** | Pass | The setting is build-time, listed in `.env.template`, falls back to `false`, and isn't reachable from the UI. The 5 new strings are in both `.arb` files. The pill border derives from the theme's resolved `OutlineInputBorder`, so only the radius changes. |
| **VI. Desktop-first, compact-ready** | Pass | `FactStripRow` caps its trailing slot so labels wrap rather than overflow. The certificates table uses the shared `DataTableView` with no inner vertical scroll. Compact width and the largest text size are verified in tests (C4, C7). |
| **VII. Online-only** | Pass | Nothing new is persisted locally. |
| **Quality gates** | Pass | **Unit tests**: `AppSettings` parsing of `MULTI_CURRENCY_ENABLED`; `routeRequiresMultiCurrency`; the nav filter; the router redirect; `FacilityFormController.logoPicked` validation and post-save upload (including the failure path); create/update no longer sending `logo`. **Widget tests**: C1–C7. **Goldens**: regenerated. |

**Post-design re-check** (after Phase 1): still passing. Two shared-code additions are justified in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/049-back-office-ui-polish/
├── plan.md              # This file
├── research.md          # Phase 0 (R1–R11)
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/
│   └── ui-contracts.md  # Phase 1 (C1–C7)
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
.env.template                                          # + MULTI_CURRENCY_ENABLED=false
lib/
├── app/router/app_router.dart                         # _redirect: routeRequiresMultiCurrency (C1)
├── core/
│   ├── config/app_settings.dart                       # + multiCurrencyEnabled
│   ├── config/app_settings_provider.dart              # + multiCurrencyEnabledProvider
│   ├── design/shapes.dart                             # + pillInputBorder (moved from product_search_field)
│   ├── navigation/nav_destination.dart                # + NavDestination.requiresMultiCurrency
│   ├── navigation/nav_destinations.dart               # flag on exchange-rates; filter; routeRequiresMultiCurrency
│   └── widgets/
│       ├── catalog_search_bar.dart                    # one icon, pill (C3)
│       ├── data_table_view.dart                       # + shrinkWrap, margin (C5)
│       └── fact_strip_row.dart                        # NEW (C4)
├── features/sales/presentation/
│   ├── orders/order_header_panel.dart                 # FactStripRow; currency+rate gated (C1, C4)
│   ├── quotes/quote_header_panel.dart                 # FactStripRow; Moneda gated (C1, C4)
│   ├── payment/payment_amount_field.dart              # Currency? currency
│   ├── payment/payment_capture_pane.dart              # pass null when option off
│   └── capture/product_search_field.dart              # use shared pillInputBorder
├── features/catalog/
│   ├── domain/entities/facility.dart                  # logo via resolvePhotoUrl
│   ├── domain/repositories/facility_repository.dart   # - logo params; + uploadLogo
│   ├── data/facility_repository_impl.dart             # generated upload call
│   └── presentation/
│       ├── facility_form_controller.dart              # logoPicked, staged upload (C2)
│       ├── facility_detail_screen.dart                # _LogoSection replaces logo_field (C2)
│       ├── product_detail_screen.dart                 # currency_field gated (C1)
│       ├── taxpayer_certificates_section.dart         # shrinkWrap + margin zero (C5)
│       ├── taxpayer_issuer_detail_screen.dart         # cap certificates block at form width (C5)
│       └── employee_form.dart                         # switch beside enroll number (C7)
├── features/pricing/presentation/pricing_grid_screen.dart  # cardPadding everywhere (C6)
└── l10n/app_en.arb, app_es.arb (+ regenerated)

test/
├── unit/core/config/app_settings_test.dart
├── unit/core/navigation/nav_destinations_test.dart    # filter + routeRequiresMultiCurrency
├── unit/app/router/app_router_test.dart
├── unit/features/catalog/facility_form_controller_test.dart
├── widget/core/widgets/{catalog_search_bar,fact_strip_row,data_table_view}_test.dart
├── widget/core/widgets/app_navigation_test.dart
├── widget/features/catalog/{facility_detail_screen,taxpayer_certificates_section,employee_form}_test.dart
├── widget/features/pricing/pricing_grid_alignment_test.dart
├── widget/features/sales/{quote_screen,order_header_disclosure,payment_*}_test.dart  # + override flag
└── golden/core_widgets_golden_test.dart, screenshots/  # regenerated
```

**Structure Decision**: the existing feature-first layout, with no new feature module. Shared pieces (`FactStripRow`, `pillInputBorder`, the `DataTableView` parameters) go in `core`, because two or more features use each of them.

## Complexity Tracking

| Addition | Why needed | Simpler alternative rejected because |
|---|---|---|
| `FactStripRow` (new shared widget) | The quote and order headers are two copies of one layout and share the bug. One widget makes one fix and one test. | Fixing both copies in place works, but leaves two layouts that must keep agreeing. It is the documented fallback (R6). |
| `DataTableView.shrinkWrap` / `margin` | An embedded table has to size to its rows. Only `DataTableView` knows its row heights. | A height formula in the caller is the cause of today's bug (R7). |
