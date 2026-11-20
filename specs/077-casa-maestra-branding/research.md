# Research: Casa Maestra Branding (077)

Sources: the Casa Maestra design system (artifact `XqxMRRyKYvf5auFTjWZ24t`: README, `tokens.json`, Logos, component guidelines), the code read on 2026-11-20, and the user's answers recorded in spec.md › Clarifications.

## R1. How a build picks its brand

**Decision**: Add a `BrandDefinition` value in `lib/core/branding/` and a const registry with two entries, `xbe` (default) and `xbe.cm`. `BrandConfig.fromEnvironment()` reads `BRAND_ID`. If the value is empty, absent, `mbe`, `xbe` or unknown, it resolves to `xbe`. For any non-default ID, the brand's own values win over the legacy `BRAND_*` flags (seed, display name, lockup, mark, welcome asset). With no `BRAND_ID`, the legacy flags work exactly as today.

**Rationale**: The constitution says brand tokens are set at build time and never hardcoded in `app/theme/`; `core/branding/` is the brand layer (spec 019 R6). A typed Dart definition keeps the ~60 color values reviewable and type-checked, which is what the user chose. The value is tested for non-empty, not with `hasEnvironment`, because `--dart-define-from-file` with an empty `KEY=` line may count as defined. The same trap may already affect `BRAND_SEED_COLOR=` in `.env.template`. That stays out of scope here and is noted under Follow-ups.

**Alternatives**: JSON brand files loaded at startup (rejected by the user). Gradle/Xcode flavors (forbidden by §V).

## R2. Colors: pinned roles on top of `fromSeed`

**Decision**: Casa Maestra builds both schemes with `ColorScheme.fromSeed(seedColor: #00325F, dynamicSchemeVariant: fidelity)` and overrides every role the design system names. The override list is longer than XBE's 20 because it adds `surfaceContainerHigh`, `surfaceContainerHighest` and `scrim`. Roles the design system does not name stay seed-derived, such as `secondary`, `tertiary`, `inverse*` and `fixed*`. XBE's pins move from `AppTheme` into the XBE definition unchanged, so the default theme is byte-identical.

**Rationale**: §V requires both schemes to come from `fromSeed`. XBE already uses fromSeed plus overrides, so Casa Maestra follows the same pattern and stays compliant.

## R3. New shared roles: accent, success, warning

**Decision**: Add a `SemanticColors` ThemeExtension to `lib/core/branding/` with `accent`, `onAccent`, `accentContainer`, `onAccentContainer`, `success`, `onSuccess`, `successContainer`, `onSuccessContainer`, `warning`, `onWarning`, `warningContainer` and `onWarningContainer`. Every brand supplies all twelve for each theme.

- **Casa Maestra** uses the design system's values. `onSuccess` and `onWarning`, which the design system leaves out, are `#FFFFFF` in light. In dark they reuse the design system's darkest ink of the same hue: `#00210D` for `onSuccess` and `#2A1700` for `onWarning`. These come from its light on-container values, so no new color is invented. The contrast test checks them.
- **XBE accent** reads the theme's own `tertiary`, `onTertiary`, `tertiaryContainer` and `onTertiaryContainer`, so it adds no new XBE color. Accent is XBE orange `#EC672A`, as spec 019 FR-009 already reserves it for accents.
- **XBE success and warning** reuse Casa Maestra's values. They are neutral M3 green and amber tones, and the XBE brand guide defines neither. The contrast test checks them on XBE's warm surfaces.

**Rationale**: The fourth `ColorScheme` slot does not exist, and borrowing `secondary` or `tertiary` for status is the inconsistency R5 removes. A ThemeExtension is how this codebase already adds roles (`BrandInk`). The extension lives in `core/branding/` because its values are per brand. Its getter fallback is XBE's values, so a theme without it never crashes.

## R4. Typography

**Decision**:

- **Fonts**: bundle Bitter (variable `Bitter[wght].ttf`, weights 600 and 700 declared) and Roboto (variable `Roboto[wdth,wght].ttf`, weights 400 and 500), with their OFL license files, under `assets/fonts/`. Roboto Mono is already bundled.
- **Roboto's family name**: Roboto is declared under the family name `BrandRoboto`, not `Roboto`. Flutter's Material typography already names `Roboto` for Android and web. A bundled asset family called `Roboto` would replace the platform font for the default brand too, and break FR-004.
- **Text theme per brand**: `AppTheme._brandTextTheme` reads its family, weights and letter spacing from `BrandDefinition.typography`.
  - XBE keeps Archivo with w700 display and w600 headline, title and label. Body styles keep the base text theme.
  - Casa Maestra sets Bitter on display, headline and title, and `BrandRoboto` on body and label. It also sets the design system's sizes, line heights, weights and tracking from spec.md › Verbatim Constraints.
- **Mono**: stays `RobotoMono` for every brand, as `TypeRoles` documents. The design system names the same family.
- **Golden harness**: `loadGoldenFonts()` also loads Bitter and `BrandRoboto` from `rootBundle`.

**Rationale**: §V lists typography as brandable. Bundling satisfies FR-007 and keeps goldens deterministic.

## R5. Status tones

**Decision**:

- **API**: `StatusChip<T>` drops its `colors` callback and takes `tone: StatusTone` plus an optional `icon`. `StatusTone` is `{success, warning, error, info, neutral, promo}`. Each tone owns a default icon and a container pair from `ColorScheme` or `SemanticColors` (contracts/status-tones.md).
- **Callers**: each of the 16 callers maps its enum to a tone with an exhaustive `switch`.
- **Cases the chip does not cover**:
  - `EntityStatus.active` keeps rendering as plain text. It is the default state, and a word is already shown.
  - The Compact "dot" variant (US2 scenario 4 is a MAY) is not built.

**Rationale**: Today the chips use six different meanings for `tertiaryContainer`, and "draft" and "cancelled" each have two colors. A tone enum makes the meaning explicit and lets the icon follow it. The per-status mapping is a product decision written down in the contract for review.

**Alternatives**: Keeping the `colors` callback and adding an icon would leave the inconsistency in place, and FR-014 asks for tone by meaning.

## R6. App-bar accent rule

**Decision**: Set `shape: Border(bottom: BorderSide(color: semantic.accent, width: 3))` on the one `AppBarTheme` in `lib/core/design/component_themes.dart`. That reaches all 47 `AppBar`s. Three more spots need their own change:

- The three screens that set their own 1px `outlineVariant` shape drop it: `pos_workspace_screen.dart:408`, `quote_screen.dart:290` and `order_workspace_screen.dart:241`.
- The compact full-screen dialog header in `responsive_dialog.dart` has no `AppBar`, so it gets the same rule directly.

**Rationale**: It is one place and changes no layout, because the border paints inside the bar. Adding `PreferredSize` at every site would touch 31 files.

## R7. Navigation sections

**Decision**:

- **Groups**: replace the five groups in `kNavigationTree` with four, with ids `operation`, `inventory`, `finance` and `system`. `inventory` keeps its id and its l10n key `navInventoryGroup`. New keys are `navOperationGroup`, `navFinanceGroup` and `navSystemGroup`, in `app_en.arb` and `app_es.arb`.
- **Order within each section**: chosen so today's adjacency tests survive:
  - pos is followed by sales-orders.
  - In Finanzas, payments → payment-verification → credit-notes → refunds.
  - In Inventario, the inventory documents come first.
  - The full order is in contracts/nav-sections.md.
- **What does not change**: `NavBranch` indices and the router. Rights filtering already hides a section with no visible destinations.
- **Clean-up**: the old group label keys are removed, since this change leaves them unused.
- **Header**: `BrandNavHeader` shows the mark alone below Expanded (840px) and the mark plus name at Expanded and up, for every brand (FR-012).

**Rationale**: Display order comes only from tree position, so the regroup is local to one file and the arb files.

## R8. Logos

**Decision**:

- **In-app assets**: put the design system's three PNGs under `assets/brand/xbe.cm/`, with 1x, 2.0x and 3.0x variants resized by `sips` from the originals. The lockups are 1642×854 and the mark is 852×562; the 1x lockup is 236px wide, the login width.
- **`BrandDefinition` assets**: `lockupAsset`, `lockupReversedAsset` (nullable) and `markAsset`.
- **Logo rendering**: `BrandLogo` uses the reversed lockup in the dark theme when the brand has one. XBE has none, so it is unchanged.
- **Login pane**: `LoginBrandingPane` stops reading `XbePalette` and takes its background, text colors, lockup and accent bars from the brand definition. XBE keeps its always-dark pane with three bars. Casa Maestra follows the theme, with a single `accent` bar.
- **Logo placement constants**: these live in `XbePalette` today (login width, minimum sizes, nav height). Brands share them, because the design system gives no different values.

**Rationale**: FR-009 and FR-010. Logos stay raster, so no `flutter_svg` is needed.

## R9. Release packaging

**Decision**:

- **Brand files**: `deploy/brands/xbe.cm/brand.properties` sets `BUNDLE_ID` and `APPLICATION_ID` to `com.mictlanix.xbe.cm`, `DISPLAY_NAME` and `WEB_TITLE` to `Casa Maestra`, `WEB_SHORT_NAME` to `Casa Maestra`, `IOS_TEAM_ID` to `4ZJ2FWD2BR` and `WEB_THEME_COLOR` to `#FFFFFF`.
- **Deployment**: `deploy/cm.release` sets `BRAND=xbe.cm`. `deploy/cm.env` sets `API_BASE_URL=https://api.cm.invalid`, and the preflight in `tool/release/lib.sh` refuses any host ending in `.invalid`.
- **`BRAND_ID`**: `tool/release/{web,ios,android}.sh` add `--dart-define=BRAND_ID=$BRAND`. The preflight refuses a deployment `.env` that sets `BRAND_ID` itself, so there is one source of truth. `mbe` resolves to XBE (R1).
- **Artwork sources**: three 1024px PNGs in `deploy/brands/xbe.cm/src/`, made from the mark with `sips` (contracts/release-brand.md). `brand_artwork.sh` then generates `overlay/`.
- **Overlay fixes**: `tool/release/overlay-manifest.txt` gains the generated files the first non-default brand needs and the manifest misses today:
  - `drawable-*/ic_launcher_foreground.png` and `values/colors.xml`, for the Android 8+ adaptive icon.
  - `drawable*/background.png` and `drawable-v21/launch_background.xml`, for the pre-Android-12 splash.
  - `values-night*/styles.xml`, which hardcode `#14120F`.
- **Web**: `rewrite_web_brand` also rewrites `manifest.json` `background_color` and the `index.html` splash body color to `WEB_THEME_COLOR`. The `mbe` brand's value is `#14120F` already, so its output does not change (FR-024).

**Rationale**: The deployment name allows only `[a-z0-9-]`, while the brand name is only used quoted in paths, so `xbe.cm` is safe as a brand. Spec 045 was only exercised with `mbe`, so the overlay gaps are latent bugs this brand exposes.

**To verify in tasks**: the generator's exact output list (a dry run), whether Flutter lets a command-line `--dart-define` win over `--dart-define-from-file` (moot because of the preflight), and ShellCheck staying clean.

## R10. Mono IDs: shared seam and list columns

**Decision**:

- **Seam**: add `DataTableColumn.id` and `DataTableColumn.timestamp` factories in `lib/core/widgets/data_table_view.dart`, and a `RecordIdText` widget in `lib/core/widgets/`. The factories render with `typeRoles.recordId` and `typeRoles.timestamp`. `RecordIdText` renders the "serial, else `#id`, else draft folio" text in `recordId`; that logic is repeated inline today.
- **Migration**: list screens' ID, folio, RFC and date/time columns, and detail-screen folio headers.
- **Unchanged**: product codes stay in body text (spec 022 FR-028; `type_roles_test.dart` stays as is). Detail-body dates, pickers and the `destination_*` misuse of `recordId` for quantities go to a follow-up.

**Rationale**: This is the user's chosen scope. One seam keeps later migration mechanical.

## R11. Error icons

**Decision**: Add an `InlineErrorText` widget to `lib/core/widgets/`: an `error_outline` icon plus text in `scheme.error`. Use it at the ~16 inline red error texts. The two hand-built banners (`pos_session_blocked_banner`, `refund_session_banner`) get the `ErrorBanner` icon. Field errors are unchanged.

**Rationale**: This is the user's chosen scope. Flutter's input theme has no setting for an error icon.

## R12. Tests and goldens

**Decision**:

- **Golden harness**: `golden_harness.dart` gains an optional brand parameter. `expectGoldenMatrix` callers stay XBE by default, and new Casa Maestra goldens cover the login pane, nav header, app bar, status chips and a list screen.
- **Contrast**: `test/contract/brand_contrast_test.dart` loops over every registered brand and also checks the twelve semantic roles.
- **Brand isolation**: `brand_independence_test.dart` keeps proving that product tokens do not vary by brand.
- **Expected golden changes for XBE**: app bars, status chips, error banners, navigation and nav header goldens change by design (FR-012 to FR-019). XBE login, home and theme-pin tests must not change (SC-002, FR-004).
- **Failing tests updated deliberately**: the nav, status-chip and router tests the explorers listed.

## Follow-ups (not in 077)

- Migrate the remaining mono display sites (detail-body dates, pickers, activity feed), and fix the `destination_*` misuse of `recordId`.
- Replace the bool glyph columns (Admin, salesperson, in use, payment verified/rejected icons, quote-expired marker) with icon-plus-word chips.
- `BRAND_SEED_COLOR=` empty in `.env.template` may already disable XBE pins under `--dart-define-from-file`. Check and fix.
- Make the four duplicated tri-state filter chips one shared widget.
- Use the reversed lockup on printed documents once the brand owner confirms it.
