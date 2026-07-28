# Contract: Brand Tokens & Build-Time Configuration

**Feature**: 019-xbe-default-branding

The UI contract between a deployment's build configuration and what the app
renders. Consumers: anyone producing a white-labeled MBE build.

---

## Dart-define surface

| Flag | Type | Default when unset | Effect |
|---|---|---|---|
| `BRAND_DISPLAY_NAME` | string | `Mictlanix Business Essentials` | Window/tab title, nav header, home welcome |
| `BRAND_WELCOME_ASSET` | asset path | bundled placeholder | Home welcome image |
| `BRAND_SEED_COLOR` | hex `RRGGBB` | `ECAB03` (XBE gold) | Seed for both `ColorScheme`s |
| `BRAND_LOCKUP_ASSET` | asset path | XBE lockup | Login screen lockup |
| `BRAND_MARK_ASSET` | asset path | XBE mark | Nav header / collapsed nav mark |

**Default build** (no flags) → full XBE brand identity.

**Overridden build** — example:

```
flutter build web \
  --dart-define=BRAND_DISPLAY_NAME="CASA MAESTRA" \
  --dart-define=BRAND_SEED_COLOR=1B5E20 \
  --dart-define=BRAND_LOCKUP_ASSET=assets/branding/casa_maestra_lockup.png
```

## Isolation guarantee (FR-007)

Setting `BRAND_SEED_COLOR` switches the app to a **wholly seed-derived**
palette: the XBE brand-exact role pins (Pantone orange/red/gray, warm
neutral ramp) are **not** applied. A deployment that overrides the seed can
never inherit XBE-specific colors.

Flags are independent: a deployment overriding only `BRAND_DISPLAY_NAME`
keeps the XBE palette and assets. This is intended — an unset flag means
"use the product default", and the product default is now XBE.

## Color role contract

| Role | Dark (XBE default) | Light (XBE default) |
|---|---|---|
| `primary` | `#ECAB03` (pinned) | derived from gold seed |
| `secondary` | `#C7C7C8` (pinned) | derived |
| `tertiary` | `#EC672A` (pinned) | derived |
| `error` | `#D8262E` (pinned) | `#D8262E` (pinned) |
| surfaces/neutrals | pinned warm ramp | derived (warm via `fidelity`) |

Every unpinned role is produced by `ColorScheme.fromSeed` from the single
seed under `DynamicSchemeVariant.fidelity`, per constitution §V.

**Semantic rule (FR-009)**: `error`/`errorContainer` are the only legitimate
homes for the brand red. It MUST NOT appear as a decorative fill, a chart
series color, or a primary interactive color. Chart/accent needs use
`tertiary`.

## Typography contract

| Text role | Family | Source |
|---|---|---|
| `display*`, `headline*`, `title*`, `label*` | **Archivo** (400/500/600/700) | bundled `assets/fonts/` |
| `body*` | **Roboto** | Flutter's Material 3 default (not bundled) |
| Codes / SKUs / monospaced data | **Roboto Mono** (400/500) | bundled `assets/fonts/` |

Fonts are bundled, never fetched at runtime (research R3).

## Logo placement contract

| Placement | Asset | Size | Rule |
|---|---|---|---|
| Login | full lockup | 236 px wide | Clear space = 8% of width, kept free |
| Splash (native) | full lockup | ~38% screen width | On `#14120F` |
| Nav header (expanded) | mark | 34 px tall | + display name beside it |
| Nav header (collapsed) | mark | 37 px | Mark only, no wordmark |
| Watermark (decorative) | white mark | any | 7% opacity, never behind text |
| Brand-color background | white single-ink lockup | ≥ 51 px | Never the full-color variant |
| Light background | grayscale/full-color lockup | ≥ 51 px | Never the white variant |

**Hard minimums**: full lockup ≥ 51 px wide; below that, switch to the mark.
Mark ≥ 37 px. A placement that cannot honor its minimum renders nothing
rather than an illegibly small logo.

## Native touchpoints — single change list (FR-013)

Dart-rendered surfaces read `BrandConfig.displayName`. These five are
platform manifest values that must be edited directly if the product is ever
renamed. All currently read **"Mictlanix Business Essentials"**:

| # | File | Key | Current value |
|---|---|---|---|
| 1 | `android/app/src/main/AndroidManifest.xml` | `android:label` | `mbe_ui` → set to display name |
| 2 | `ios/Runner/Info.plist` | `CFBundleDisplayName` | `Mbe Ui` → set to display name |
| 3 | `web/index.html` | `<title>`, `apple-mobile-web-app-title` | `Mictlanix Business Essentials` / `MBE` |
| 4 | `web/manifest.json` | `name`, `short_name` | `Mictlanix Business Essentials` / `MBE` |
| 5 | `pubspec.yaml` | `description` | product description string |

Note that #1 and #2 currently carry raw package identifiers (`mbe_ui`,
`Mbe Ui`) rather than the product name — this feature corrects them.
