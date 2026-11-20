# Implementation Plan: Casa Maestra Branding

**Branch**: `077-casa-maestra-branding` | **Date**: 2026-11-20 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/077-casa-maestra-branding/spec.md`

## Summary

A `BRAND_ID` build setting selects one brand definition from a const registry in `lib/core/branding/`: the default `xbe`, or `xbe.cm` for Casa Maestra.

**The Casa Maestra brand** brings:
- pinned light and dark color roles on top of `ColorScheme.fromSeed(#00325F)`;
- Bitter and Roboto, bundled, with Roboto Mono kept for mono styles;
- three raster logos, including a reversed lockup for the dark theme.

**Shared chrome, for every brand**:
- a `SemanticColors` theme extension (accent, success, warning);
- a status-tone `StatusChip` with an icon and a word;
- a 3px accent rule on every app bar;
- four navigation sections;
- a tier-aware nav header;
- mono ID and timestamp list columns;
- icons on inline errors.

**Packaging**: a release brand `deploy/brands/xbe.cm` and a deployment `cm`, with fixes to spec 045's overlay manifest and web rewrite that the first non-default brand exposes. XBE's colors, fonts and logos stay byte-identical.

## Technical Context

**Language/Version**: Dart 3 / Flutter 3.44.2. Bash for `tool/release`.

**Primary Dependencies**: `flutter_riverpod`, `go_router`, `intl`/`flutter_localizations`. For release artwork, `flutter_launcher_icons` and `flutter_native_splash`, both already present. No new packages.

**Storage**: N/A, build-time values only.

**Testing**: `flutter_test` unit and widget tests, goldens through `test/golden/golden_harness.dart`, the contract test `test/contract/brand_contrast_test.dart`, `shellcheck`, and manual quickstart V3 and V6.

**Target Platform**: Web, macOS, iOS and Android, with the same codebase per brand.

**Project Type**: Flutter app, white-labeled.

**Performance Goals**: No startup regression. Brand resolution is a const map lookup, and fonts are bundled.

**Constraints**:
- §V: only color, typography and logos vary by brand, `fromSeed` is required, and no flavors are allowed.
- FR-004: XBE stays pixel-identical outside the shared chrome.
- The four text-size levels must not overflow.

**Scale/Scope**: About 70 files.

| Area | Approximate files |
| --- | --- |
| Branding core | 6 |
| Theme and component themes | 3 |
| Status-chip callers | 16 |
| Navigation and l10n | 4 |
| List screens for mono columns | ~25 |
| Inline error sites | ~16 |
| Release scripts and deploy files | ~8 |
| Assets | 3 PNGs plus variants, 2 fonts |
| Tests and goldens | many |

## Constitution Check

*GATE: checked before Phase 0 and again after Phase 1.*

| Principle | Status | How |
| --- | --- | --- |
| I. Feature-first layers | Pass | Brand values are in `core/branding/`; product tokens stay in `core/design/`; `app/theme/` only consumes them. |
| II. Riverpod | Pass | `brandConfigProvider` and `appThemeProvider` are unchanged in shape. |
| III. Contract-driven API | N/A | No endpoints or error codes. |
| IV. Deny-by-default RBAC | Pass | Nav gates are unchanged. A section with no visible destinations is hidden by the existing filter. |
| V. Material 3, white-label | Pass | Both brands use `ColorScheme.fromSeed` plus role overrides. Brand tokens are set at build time (`BRAND_ID`, added to `.env.template` with an empty default). An unknown value falls back without failing. Native identity comes from `tool/release.sh` generated config, with no flavors. Nothing is hardcoded in `app/theme/`. |
| VI. Desktop-first layout | Pass | Status badges and data-table columns stay shared `core/widgets`. No app-bar actions are added. The nav keeps the rail and drawer per tier. |
| VII. Server-rendered documents | Pass | Printing is untouched. The reversed lockup is not used on documents. |
| Quality gates | Pass | Unit, widget, golden and contract tests are listed in quickstart.md. No mbe-api change is needed. |

Post-design re-check: still passing. The design adds one ThemeExtension and one enum and needs no exceptions.

## Project Structure

### Documentation (this feature)

```text
specs/077-casa-maestra-branding/
├── plan.md
├── research.md          # R1–R12 + follow-ups
├── data-model.md
├── quickstart.md        # V1–V6
├── contracts/
│   ├── brand-definition.md
│   ├── status-tones.md
│   ├── nav-sections.md
│   └── release-brand.md
└── tasks.md             # /speckit-tasks
```

### Source Code (repository root)

```text
lib/core/branding/
├── brand_definition.dart      # NEW: BrandDefinition, BrandColors, BrandTypography, LoginPaneStyle, registry
├── brands/xbe_brand.dart      # NEW: XBE definition (values moved from XbePalette/AppTheme, unchanged)
├── brands/casa_maestra_brand.dart  # NEW: xbe.cm definition
├── semantic_colors.dart       # NEW: ThemeExtension (accent/success/warning)
├── brand_config.dart          # BRAND_ID resolution; holds the resolved BrandDefinition
├── brand_ink.dart             # unchanged behaviour for XBE
└── xbe_palette.dart           # constants stay; pins referenced by xbe_brand.dart
lib/app/theme/app_theme.dart   # builds schemes/text theme from BrandDefinition; registers SemanticColors
lib/core/design/component_themes.dart  # AppBarTheme 3px accent rule; chip avatar sizing
lib/core/widgets/
├── status_chip.dart           # StatusTone + icon
├── brand_logo.dart            # reversed lockup in dark
├── brand_nav_header.dart      # mark-only below 840px
├── data_table_view.dart       # DataTableColumn.id / .timestamp
├── record_id_text.dart        # NEW
├── inline_error_text.dart     # NEW
└── responsive_dialog.dart     # compact header rule
lib/core/navigation/nav_destinations.dart  # four sections
lib/features/auth/presentation/login/login_branding_pane.dart  # brand-driven
lib/features/**/*_status_chip.dart, list screens, inline-error sites
lib/l10n/app_en.arb, app_es.arb  # 3 new group keys, 4 removed
assets/fonts/  Bitter[wght].ttf, Roboto[wdth,wght].ttf, OFL-Bitter.txt, OFL-Roboto.txt
assets/brand/xbe.cm/  (+2.0x/, 3.0x/)  casa-maestra-logo.png, -logo-reversed.png, -mark.png
pubspec.yaml                   # Bitter + BrandRoboto families, assets/brand/xbe.cm/
.env.template                  # BRAND_ID=
deploy/brands/xbe.cm/{brand.properties,src/,overlay/}
deploy/cm.release, deploy/cm.env
tool/release/{lib.sh,web.sh,ios.sh,android.sh,overlay-manifest.txt}
test/golden/golden_harness.dart  # brand parameter, new fonts
test/contract/brand_contrast_test.dart  # every brand + semantic roles
```

**Structure Decision**: This follows the existing split, where `core/branding` holds per-brand values, `core/design` holds product tokens and component themes, and `app/theme` assembles them. No new layers.

## Delivery order

The stories can ship in independent increments:

1. **US1 foundation**: registry, `BRAND_ID`, `SemanticColors`, `AppTheme`, fonts, logos, login pane and contrast gate. XBE parity is proven first (V1, V2).
2. **US2**: status tones, inline error icons, mono seam and list columns.
3. **US3**: app-bar rule, nav sections and nav header.
4. **US4**: release brand, deployment and script fixes (V6).

Goldens are regenerated per increment, and every changed PNG is reviewed.

## Risks

- **Changing XBE through the refactor.** Moving the XBE pins could change XBE by accident. Mitigation: `app_theme_test.dart` and XBE goldens run unchanged before and after the move, in step 1.
- **Status-tone choices.** The mapping in contracts/status-tones.md is a product call and needs review before US2 merges.
- **Generator output.** The exact Android and web files the generator writes are not yet confirmed; a dry run is the first US4 task.
- **Bitter overflow.** Bitter is wider than Archivo at title sizes, so there is some overflow risk at text scale 1.3. Covered by SC-007 and quickstart V3.

## Complexity Tracking

No constitution violations to justify.
