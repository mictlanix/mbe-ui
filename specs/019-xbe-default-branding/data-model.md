# Phase 1 Data Model: XBE Default Branding

**Feature**: 019-xbe-default-branding | **Date**: 2026-07-28

This feature introduces no persisted or API-backed data. The "entities" here
are build-time configuration values and derived theme objects, all resolved
once at startup.

---

## `BrandConfig` (extended)

`lib/core/branding/brand_config.dart` — immutable, resolved once from
`--dart-define` values via `BrandConfig.fromEnvironment()`.

| Field | Type | Dart-define | Default | Notes |
|---|---|---|---|---|
| `displayName` | `String` | `BRAND_DISPLAY_NAME` | `"Mictlanix Business Essentials"` | Existing. Now also drives `MaterialApp.title` and the nav header (FR-013). |
| `welcomeAsset` | `String?` | `BRAND_WELCOME_ASSET` | `null` → bundled placeholder | Existing, unchanged. |
| `seedColor` | `Color` | `BRAND_SEED_COLOR` | `xbeGold` (#ECAB03) | **New.** Parsed from a `RRGGBB`/`#RRGGBB` hex string. |
| `usesDefaultPalette` | `bool` (derived) | — | `true` when `BRAND_SEED_COLOR` is unset | **New.** Gates whether the XBE brand-exact role pins apply (see FR-007 isolation). |
| `lockupAsset` | `String` | `BRAND_LOCKUP_ASSET` | `assets/brand/login_lockup.png` | **New.** Full lockup for login/splash placements. |
| `markAsset` | `String` | `BRAND_MARK_ASSET` | `assets/brand/nav_lockup.png` | **New.** Isologo mark for nav placements. |

**Validation rules**:

- An unparseable `BRAND_SEED_COLOR` falls back to `xbeGold` rather than
  throwing — a malformed build flag must not brick app startup.
- `usesDefaultPalette` is `false` whenever `BRAND_SEED_COLOR` is present,
  **even if** its value happens to equal the XBE gold: an explicit override
  means "derive everything from my seed", which is what makes FR-007's
  isolation guarantee unambiguous.
- Equality/`hashCode` extend to cover all new fields (existing pattern).

---

## `XbeBrandPalette` (new, const)

`lib/core/branding/xbe_palette.dart` — the XBE brand's raw token values,
transcribed from the approved brand guide. Pure constants, no logic.

**Brand hues**:

| Token | Value | Pantone | Role |
|---|---|---|---|
| `xbeGold` | `#ECAB03` | 124 C | seed + `primary` (dark) |
| `xbeOrange` | `#EC672A` | 165 C | `tertiary` — accent/charts only |
| `xbeRed` | `#D8262E` | 1795 C | `error` — **states only, never decorative** (FR-009) |
| `xbeWordmarkGray` | `#C7C7C8` | Cool Gray 3 C | `secondary` (dark) |

**Dark-scheme pins** (from the brand guide, applied via `fromSeed`
overrides): `onPrimary` #241900, `primaryContainer` #4B3703,
`onPrimaryContainer` #FFD466, `onSecondary` #232323, `onTertiary` #2B0F00,
`onError` white, `errorContainer` #3A1416, `onErrorContainer` #FF8F93,
`surface` #14120F, `onSurface` #EFE9DF, `onSurfaceVariant` #B4ACA0,
`outline` #4E473D, `outlineVariant` #332E27, `surfaceContainerLowest`
#0F0D0B, `surfaceContainerLow` #1B1814, `surfaceContainer` #221E19.

**Light-scheme pins**: `error` family only (see research R2). All other
light roles derive from the gold seed.

**Placement constants** (from the brand guide's logo rules, FR-003/004/010):

| Constant | Value | Used by |
|---|---|---|
| `lockupLoginWidth` | 236.0 | Login screen |
| `lockupMinWidth` | 51.0 | Minimum for the full lockup |
| `markMinWidth` | 37.0 | Minimum for the mark; collapsed nav |
| `markNavHeight` | 34.0 | Expanded nav header |
| `clearSpaceRatio` | 0.08 | Clear space = 8% of rendered lockup width |
| `watermarkOpacity` | 0.07 | Decorative mark watermark |

---

## `AppTheme` → provider-derived (changed)

`lib/app/theme/app_theme.dart` stops holding brand constants (removing the
standing §V violation) and becomes a builder:

```
BrandConfig ──▶ AppTheme.of(brand) ──▶ (ThemeData light, ThemeData dark)
```

- **Input**: a `BrandConfig`.
- **Output**: light + dark `ThemeData`, each with a `ColorScheme` from
  `ColorScheme.fromSeed(seedColor: brand.seedColor, brightness: …,
  dynamicSchemeVariant: fidelity, …pins)`, plus the Archivo `TextTheme`
  overrides for display/headline/title/label roles.
- **Pin application**: brand-exact role pins are applied **only when**
  `brand.usesDefaultPalette` is `true`.

**State transitions**: none. `ThemeModeController` (Light/Dark/System,
persisted via `shared_preferences`) is untouched and continues to select
between the two `ThemeData` objects (FR-008).

---

## Provider graph

```
brandConfigProvider (existing, Provider<BrandConfig>)
        │
        ├──▶ appThemeProvider (new, Provider<AppThemeData>)
        │            │
        │            └──▶ App (MaterialApp.router theme/darkTheme)
        │
        ├──▶ HomeWelcome (existing consumer)
        │
        └──▶ AppShell / AppNavigation header (new consumer — mark + name)

themeModeControllerProvider (existing, unchanged) ──▶ App (themeMode)
```

All three brand consumers resolve from the same provider, so a test can
override `brandConfigProvider` once and exercise every branded surface —
which is how the FR-007 isolation scenarios are tested.
