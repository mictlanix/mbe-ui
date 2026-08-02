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
| `BRAND_MARK_ASSET` | asset path | XBE mark | Nav header mark |

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
| `primary` | `#ECAB03` (pinned) | `#ECAB03` (pinned — fill only, see below) |
| `secondary` | `#C7C7C8` (pinned) | `#5A5349` (pinned) |
| `tertiary` | `#EC672A` (pinned) | `#EC672A` (pinned) |
| `error` | `#D8262E` (pinned) | `#C4262E` (pinned — contrast-adjusted) |
| surfaces/neutrals | pinned warm-dark ramp | pinned warm-light ramp |

Every unpinned role (fixed/dim variants, inverse colors, scrim, shadow,
surfaceTint, surfaceBright, surfaceContainerHigh/Highest) is produced by
`ColorScheme.fromSeed` from the single seed under
`DynamicSchemeVariant.fidelity`, per constitution §V. Both schemes are now
fully specified by the brand guide (light was added after this feature's
initial planning — see research R2), not algorithmically guessed.

**`xbeGoldInk` (`#7A5600`, not a `ColorScheme` role)**: gold `primary` is
correct as a **fill** in light mode (paired with dark `onPrimary`), but MUST
NOT be used as text/icon foreground color on light surfaces — use
`xbeGoldInk` there instead (5.4:1 contrast on white vs. gold's failing
contrast as foreground).

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
| Login (branding pane) | full lockup | 236 px wide | Clear space = 8% of width, kept free |
| Splash (native) | full lockup | ~38% screen width | On `#14120F` |
| Nav header (rail + drawer) | mark | 34 px tall | + display name beside it — this app has no separate collapsed/icon-only nav state (out of scope; see spec.md Assumptions) |
| Watermark, dark surfaces | white mark | any | 7% opacity, never behind text |
| Watermark, light surfaces | full-color mark | any | 6% opacity, never behind text |
| Brand-color background | white single-ink lockup | ≥ 51 px | Never the full-color variant |
| Light background | grayscale lockup | ≥ 51 px | Never the white variant |

**Hard minimums**: full lockup ≥ 51 px wide; below that, switch to the mark.
Mark ≥ 37 px. A placement that cannot honor its minimum renders nothing
rather than an illegibly small logo.

## Login & Home layout contract (FR-014/015/016 — the scoped exception)

Unlike every other screen (retheme only, FR-011), login and home are
rebuilt to match the brand guide's own mockups:

- **Login**: two-pane layout — a dark branding pane (lockup, headline
  tagline, subhead, three accent-color bars, version string) beside the
  existing sign-in form. The form's fields, validation, submission, and
  error handling are unchanged; only its surrounding layout changes from
  today's single centered column.
- **Home**: a greeting card (dynamic user name + static summary copy) above
  a 4-tile indicator row above a recent-activity panel, replacing today's
  single placeholder image + display name. Tile/activity content is static
  placeholder data (`data-model.md` § Static Home content) — no live query.

## Native touchpoints — single change list (FR-018)

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
