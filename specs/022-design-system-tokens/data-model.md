# Phase 1 Data Model: Design System Tokens

**Feature**: 022-design-system-tokens | **Date**: 2026-08-08

The token entities from [spec.md](./spec.md) § Key Entities, with concrete values. Every
value is either an M3 spec value, a value read from the installed SDK, or a measurement
from the approved brand guide — sources named. These are the numbers the implementation
encodes; they are not re-derived during implementation.

All five entities are `ThemeExtension`s under `lib/core/design/`, constructed from `const`
defaults with **no `BrandConfig` parameter** — the structural guarantee behind `FR-010`
(see research R8).

---

## Tier resolution

Four tiers, reusing `LayoutBreakpoints` unchanged (Verbatim Constraint):

| Tier | Width | Role |
|---|---|---|
| `compact` | `< 600` | phone — values decided, layouts out of scope (`FR-014`, `FR-025`) |
| `medium` | `600–839` | small tablet |
| `expanded` | `840–1199` | desktop / large tablet — primary target |
| `large` | `>= 1200` | wide desktop |

Resolved once in `MaterialApp.builder`; every extension below is **already tier-resolved**,
so accessors return plain values (research R1).

---

## 1. Spacing

Eight steps, every one a multiple of 4 (`FR-004`). Tier-invariant.

| Field | dp | Use |
|---|---|---|
| `none` | 0 | — |
| `xxs` | 4 | badge insets, icon↔text in a dense chip |
| `xs` | 8 | icon↔label, chip gaps |
| `sm` | 12 | table cell padding, list row vertical padding |
| `md` | 16 | default; field gaps |
| `lg` | 24 | section gaps, pane gutter |
| `xl` | 32 | between major form sections |
| `xxl` | 48 | page header ↔ content |
| `xxxl` | 64 | hero / branding pane insets |

### Layout metrics — tier-dependent (`FR-012`)

| Field | compact | medium | expanded | large |
|---|---|---|---|---|
| `screenMargin` | 16 | 24 | 24 | 24 |
| `paneGutter` | — (stacked) | 24 | 24 | 24 |
| `cardPadding` | 16 | 16 | 24 | 24 |
| `fieldGapVertical` | 16 | 16 | 16 | 16 |
| `fieldGapHorizontal` | — (1 col) | 16 | 24 | 24 |
| `sectionGap` | 24 | 32 | 32 | 32 |
| `contentMaxWidth` | unbounded | unbounded | unbounded | 1440 |

**Validation**: every field except `contentMaxWidth` and the two `—` entries must be a
positive multiple of 4. `contentMaxWidth` is `double.infinity` where unbounded — never
`null`, so call sites need no null branch.

**Off-grid brand values** (`FR-026`): the brand guide's most frequent gap is 14 px
(26 occurrences), which is not on the 4 dp grid. Snapped to 12 or 16 by context; the
discrepancy is raised with the brand owner, not resolved silently.

---

## 2. Shapes

Seven radii (`FR-005`), tier-invariant. Delivered as a `ThemeExtension` because Flutter has
no `ShapeScheme` (research R3).

| Field | Radius | M3 name | Applied to |
|---|---|---|---|
| `none` | 0 | none | table cells, dividers, full-bleed |
| `xs` | 4 | extraSmall | filled text field, snackbar |
| `sm` | 8 | small | chips, badges, menu items |
| `md` | 12 | medium | inner containers |
| `lg` | **16** | large | **cards and panels** (Verbatim Constraint) |
| `xl` | 28 | extraLarge | dialogs, side sheets, bottom sheets |
| `full` | `StadiumBorder` | full | buttons, nav indicators, filter pills |

**Validation**: `none <= xs <= sm <= md <= lg <= xl`, all non-negative; `full` is a
`ShapeBorder`, not a radius, and is never converted to one.

**Deviations from Flutter defaults**, both deliberate: cards 12 → 16 (brand guide's
dominant radius); the navigation indicator's ad-hoc `BorderRadius.circular(28)` becomes
`full`, so it survives a height change.

---

## 3. Elevations

Six levels (`FR-006`). Depth is carried by **surface tone**; shadow is reserved for
transient overlays.

| Field | Level | Surface role | Shadow dp | Used by |
|---|---|---|---|---|
| `flat` | 0 | `surface` | 0 | page background |
| `sunken` | 0 | `surfaceContainerLowest` | 0 | well behind a card list |
| `raised` | 1 | `surfaceContainerLow` | 0 | **cards, panels at rest** |
| `engaged` | 2 | `surfaceContainer` | 0 | search bar, filter bar, selected row |
| `floating` | 3 | `surfaceContainerHigh` | 6 | popup menu, autocomplete, FAB |
| `modal` | 4–5 | `surfaceContainerHighest` | 8–12 | dialog, side sheet, drag proxy |

**Invariant**: a level with `shadow == 0` is a persistent surface; a level with
`shadow > 0` is transient. No level may set both a shadow and be used for a persistent
surface — this is what keeps dense table screens visually flat.

**Hard dependency**: `raised` is unusable until `surfaceContainerLow` is pinned for the
light scheme (`FR-002`). Today it is dark-only, so light mode resolves a seed-derived
value. `FR-002` is therefore sequenced before any elevation work.

**Shadow dp values** are M3 spec figures; confirm against the SDK's component defaults
during implementation and correct here if they differ.

---

## 4. Density

Keyed on **platform**, not width (research R2 — this corrects the spec's assumption that
`navigationModeOf` carries this signal).

| Field | Touch (Android/iOS/Fuchsia) | Pointer (Linux/macOS/Windows) |
|---|---|---|
| `visualDensity` | `VisualDensity.standard` | `VisualDensity.compact` |
| `minTargetSize` | 48 | 40 |
| `tableHeadingRowHeight` | n/a (cards) | 48 |
| `tableDataRowHeight` | n/a (cards) | 44 |
| `listRowMinHeight` | 56 | 48 |
| `iconButtonSize` | 48 | 40 |
| `inputIsDense` | `false` | `true` |

Source: `VisualDensity.adaptivePlatformDensity` → `defaultDensityForPlatform`
(`material/theme_data.dart:3240-3257`). On web, `defaultTargetPlatform` reports the host
platform, so a desktop browser gets pointer metrics and a mobile browser touch metrics.

**Validation**: `minTargetSize >= 40` always, and `>= 48` whenever the platform is a touch
platform — the accessibility floor, asserted in tests.

**Consumers**: `tableHeadingRowHeight`/`tableDataRowHeight` are passed explicitly by
`core/widgets/data_table_view.dart` because `DataTable2` carries its own height parameters
rather than reading them from the theme (research R5).

---

## 5. TypeRoles

The slot → M3 role mapping (`FR-008`), tier-resolved so each field returns a ready
`TextStyle`. The M3 ramp itself is inherited from `Typography.material2021` and never
restated (`SC-001`).

| Slot field | compact | medium | expanded / large | Family |
|---|---|---|---|---|
| `screenTitle` | titleLarge | titleLarge | titleLarge | Archivo |
| `heroHeading` | headlineMedium | displaySmall | displaySmall | Archivo |
| `heroSubhead` | bodyLarge | bodyLarge | bodyLarge | Roboto |
| `pageHeading` | headlineSmall | headlineMedium | headlineMedium | Archivo |
| `sectionHeading` | titleMedium | titleMedium | titleLarge | Archivo |
| `cardTitle` | titleMedium | titleMedium | titleMedium | Archivo |
| `metricValue` | headlineSmall | headlineMedium | headlineMedium | Archivo |
| `metricLabel` | bodySmall | bodySmall | bodySmall | Roboto |
| `navLabel` | labelLarge | labelLarge | labelLarge | Archivo |
| `navHeader` | titleSmall | titleSmall | titleSmall | Archivo |
| `tableHeader` | labelLarge | labelLarge | labelLarge | Archivo |
| `tableCell` | bodyMedium | bodyMedium | bodyMedium | Roboto |
| `fieldInput` | bodyLarge | bodyLarge | bodyMedium | Roboto |
| `fieldLabel` | bodySmall | bodySmall | bodySmall | Roboto |
| `chipLabel` | labelLarge | labelLarge | labelMedium | Archivo |
| `buttonLabel` | labelLarge | labelLarge | labelLarge | Archivo |
| `money` | bodyMedium | bodyMedium | bodyMedium | Roboto, tabular figures |
| `recordId` | bodyMedium | bodyMedium | bodyMedium | **RobotoMono** |
| `timestamp` | bodySmall | bodySmall | bodySmall | **RobotoMono** |
| `productCode` | bodyMedium | bodyMedium | bodyMedium | **Roboto** — see below |
| `overlayText` | bodyMedium | bodyMedium | bodySmall | Roboto |

**`productCode` is deliberately not monospaced** (`FR-028`, clarified 2026-08-08). Spec
019's typography contract assigned codes and SKUs to RobotoMono, but the product never did
so; the contract narrows to match reality. The field exists as a **named slot** precisely so
the decision is visible and reversible in one place rather than implicit in every table.
Updating `specs/019-xbe-default-branding/contracts/brand-tokens.md` § Typography to match
is a task in this feature.

**Brand weight deviation**: `app_theme.dart` sets w600 on headline/title/label and w700 on
display, against M3's w400/w500. Retained, except `labelMedium`/`labelSmall` revert to w500
for legibility at 11–12 px (spec Assumptions, pending brand-owner confirmation).

**Tracking**: M3 values retained everywhere until the R7 measurement lands; corrections, if
any, are expected only on `display*` / `headlineLarge`.

---

## Relationships

```
BrandConfig ──> XbePalette ──> ColorScheme ──> BrandInk        (lib/core/branding/)
                                    │                           per-deployment
                                    ▼
              AppTheme.of(brand) ──> ThemeData (tier-agnostic base)
                                    │
                     MaterialApp.builder resolves tier
                                    ▼
              DesignTheme.forTier(base, tier) ──> ThemeData
                     │                              (memoized per brightness × tier)
                     ├── Spacing      ┐
                     ├── Shapes       │  lib/core/design/ — const, no brand input
                     ├── Elevations   ├─ identical across every deployment (FR-010)
                     ├── Density      │
                     ├── TypeRoles    ┘
                     └── 20 component sub-theme classes (FR-016), consuming the above
```

**The direction of the arrows is the guarantee**: brand values flow into `ColorScheme` and
stop there. No arrow runs from `BrandConfig` into any `lib/core/design/` entity, so no
deployment can alter spacing, shape, elevation, density or type roles.

---

## State transitions

Only one entity has state: the resolved theme.

```
brand config changes  ──> full ThemeData rebuild, cache cleared
brightness changes    ──> cache lookup (brightness, tier)
window resize         ──> tier recomputed; cache hit unless the tier boundary was crossed
platform (fixed)      ──> density resolved once at startup
```

Crossing a tier boundary is the only resize that changes anything, which is what keeps the
rebuild cost negligible (research R1).
