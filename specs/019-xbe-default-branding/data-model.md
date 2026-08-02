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
| `displayName` | `String` | `BRAND_DISPLAY_NAME` | `"Mictlanix Business Essentials"` | Existing. Now also drives `MaterialApp.title` and the nav header (FR-018). |
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

**Light-scheme pins** (added to the brand guide after initial planning —
research R2 — transcribed, not derived): `primary` #ECAB03 (kept as the gold
**fill**), `onPrimary` #241900, `primaryContainer` #FFE7A8,
`onPrimaryContainer` #5C4000, `secondary` #5A5349, `onSecondary` white,
`tertiary` #EC672A, `onTertiary` white, `error` #C4262E (contrast-adjusted
1795 C), `onError` white, `errorContainer` #FBDEDF, `onErrorContainer`
#A31219, `surface` #FBF8F3, `onSurface` #1C1A16, `surfaceContainerLowest`
white, `surfaceContainer` #F3EDE3, `onSurfaceVariant` #5A5349, `outline`
#C4BBAC, `outlineVariant` #E3DACC.

**`xbeGoldInk` (`#7A5600`)**: not a `ColorScheme` role — a standalone
constant used wherever gold is rendered as **text or an icon glyph** on a
light surface (e.g. an active nav-item label/icon). Raw gold `primary`
(#ECAB03) is correct and contrast-safe as a **fill** (buttons, FAB, the
active nav pill background) because it's paired with the dark `onPrimary`
ink; it is not safe as foreground text against light surfaces, which is
what `xbeGoldInk` (5.4:1 on white) is for.

**Placement constants** (from the brand guide's logo rules, FR-003/004/010):

| Constant | Value | Used by |
|---|---|---|
| `lockupLoginWidth` | 236.0 | Login screen |
| `lockupMinWidth` | 51.0 | Minimum for the full lockup |
| `markMinWidth` | 37.0 | Minimum for the mark |
| `markNavHeight` | 34.0 | Expanded nav header |
| `clearSpaceRatio` | 0.08 | Clear space = 8% of rendered lockup width |
| `watermarkOpacityDark` | 0.07 | Decorative white mark, dark surfaces |
| `watermarkOpacityLight` | 0.06 | Decorative full-color mark, light surfaces |

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

---

## Static Home content (FR-016)

Not a data model in the persisted sense — a fixed `const` list rendered by
the rebuilt `HomeWelcome`/dashboard widget, transcribed verbatim from the
brand guide's example content. No repository, no provider, no API call.

**Indicator tiles** (`DashboardIndicatorTile { icon, value, label }`):

| Icon | Value | Label |
|---|---|---|
| `point_of_sale` | `$184,320` | Ventas de hoy |
| `sell` | `3` | Listas por autorizar |
| `inventory_2` | `21,542` | Productos activos |
| `apartment` | `9 / 14` | Instalaciones activas |

**Recent activity** (`ActivityFeedEntry { icon, text, time }`):

| Icon | Text | Time |
|---|---|---|
| `sell` | Lista de precios «Mayoreo Q3» enviada a autorización | 08:42 |
| `inventory_2` | 38 productos GREENFIELD actualizados por importación | 08:15 |
| `point_of_sale` | Corte de caja CMC3 cerrado | Ayer 21:10 |
| `badge` | Alta de empleado: J. Domínguez · CMHU | Ayer 17:55 |

**Greeting card copy**: a static greeting ("Buen día" + the signed-in user's
name, already available from the session — not hardcoded) plus the guide's
example summary line ("Tienes 3 listas de precios por autorizar y 2
instalaciones sin corte de caja de ayer.") and two action buttons ("Revisar
pendientes", "Nueva venta"); the buttons render but their target routes are
whatever the equivalent existing actions already resolve to today (no new
navigation destinations are introduced by this feature).

**Login tagline**: the guide's headline/subhead copy ("Toda la operación, en
un solo lugar." / "Catálogos, precios, instalaciones y ventas de tus
sucursales sincronizados en tiempo real.") renders as static copy in the
branding pane.

All values above are placeholders per FR-016 and Assumptions — replacing
them with live data is explicitly out of scope for this feature.

**Reconciling with the existing `welcomeAsset` seam (spec 010 US3)**:
`HomeWelcome` already has deployment-specific behavior — a configured
`BrandConfig.welcomeAsset` shows that deployment's own welcome image +
`displayName`; unset falls back to a bundled placeholder. The new dashboard
is XBE-specific placeholder content (tiles/activity match *this* brand
guide's example data), so it must not leak into other white-labeled
deployments (FR-007/US5). Resolution: `HomeWelcome` branches on
`brand.hasWelcomeAsset` —

- **`true`** (a deployment configured its own welcome image): keep today's
  existing simple layout (image + `displayName` + welcome message)
  unchanged.
- **`false`** (the XBE default, and any deployment that overrides only
  `displayName`/palette without a welcome asset): render the new dashboard
  (greeting card + indicator tiles + activity panel) instead of the old
  bundled placeholder image.

This keeps the dashboard strictly a default-palette-flavor enhancement, not
a general Home redesign forced onto every deployment.
