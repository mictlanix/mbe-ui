# Contract: Design Token API & Component Theming

**Feature**: 022-design-system-tokens

The contract between the design system and every screen in the product. Consumers: every
feature module author, and any future spec that adds a screen.

---

## The one access rule

Every token is reached through `Theme.of(context)`. No widget imports a token class or a
palette constant directly.

```dart
final theme = Theme.of(context);

theme.spacing.lg              // 24.0
theme.spacing.screenMargin    // tier-resolved: 16 on compact, 24 elsewhere
theme.shapes.lg               // BorderRadius for cards — 16
theme.elevations.raised       // surface role + shadow for a card at rest
theme.density.minTargetSize   // 48 on touch platforms, 40 on pointer
theme.typeRoles.sectionHeading // a ready TextStyle for the current tier
theme.brandInk.primary        // contrast-safe brand foreground (already shipped)
```

**Values are already resolved.** `screenMargin` is a `double`, not a function of context —
the tier was resolved once in `MaterialApp.builder`. A call site never asks "which tier am
I in?"

**Banned at call sites** — each of these is a `SC-001`/`SC-002` violation:

```dart
EdgeInsets.all(24)                              // use theme.spacing.lg
BorderRadius.circular(16)                       // use theme.shapes.lg
TextStyle(fontFamily: 'Archivo', fontSize: 14)  // use theme.typeRoles.navHeader
Color(0xFF7A5600)                               // use theme.brandInk.primary
XbePalette.gold                                 // brand token, never at a call site
```

The single legitimate exception is `lib/core/branding/`'s own token definitions and
`lib/app/theme/`'s assembly.

---

## What is customizable per deployment, and what is not

| Layer | Per-deployment | Mechanism |
|---|---|---|
| Color roles | **Yes** | `BRAND_SEED_COLOR` |
| Typefaces | **Yes** | brand config |
| Logo / brand assets | **Yes** | `BRAND_LOCKUP_ASSET`, `BRAND_MARK_ASSET` |
| Contrast-safe brand ink | **Yes** (derived) | follows the deployment's own `primary` |
| **Spacing** | **No** | const, no brand input |
| **Shape / radius** | **No** | const, no brand input |
| **Elevation** | **No** | const, no brand input |
| **Density / targets** | **No** | platform-derived |
| **Type role assignment** | **No** | const mapping; only the *typeface* is brandable |

Constitution §V: customization is limited to "color scheme, typography, and branding
assets, **not layout/structure**." The `lib/core/design/` classes take no `BrandConfig`
parameter, so this is enforced by construction rather than by review.

**Isolation guarantee, unchanged from spec 019 FR-007**: a deployment setting
`BRAND_SEED_COLOR` receives a wholly seed-derived `ColorScheme` and no XBE-specific value
of any kind — including `XbePalette.goldInk` via `BrandInk`.

---

## Tier contract

| Tier | Width | Built by this feature? |
|---|---|---|
| `compact` | `< 600` | Token values: **yes**. Layouts: **no** (`FR-025`) |
| `medium` | `600–839` | Yes |
| `expanded` | `840–1199` | Yes — primary target |
| `large` | `>= 1200` | Yes |

Tier is resolved from width. **Density is not** — it is resolved from platform, so a wide
Android tablet gets touch metrics (research R2).

Out of scope for this feature, deferred to a follow-up spec: bottom navigation bar, the
table→card list transformation, bottom-sheet filters, pinned action bars, full-screen
dialogs.

---

## Component sub-themes

20 distinct `Theme`/`ThemeData` classes are defined centrally (`FR-016`), grouped below into
14 rows where several classes share one concern (e.g. the three button themes). Once a
sub-theme owns a property, screens must not restate it (`FR-017`).

| Sub-theme | Owns | Retires |
|---|---|---|
| `AppBarTheme` | `titleTextStyle`, `centerTitle: false`, scrolled elevation | — |
| `CardThemeData` | `shapes.lg`, `surfaceContainerLow`, elevation 0, tier margin | home tiles, `facility_card` |
| `InputDecorationTheme` | filled, `shapes.xs`, label/helper/error styles, tier `isDense` | fields on 18 detail screens |
| `ChipThemeData` | `typeRoles.chipLabel`, `shapes.sm`, density, container colors | `entity_status_controls:46`, `cash_session_status_chip:48` |
| `DataTableThemeData` | `headingTextStyle`, `dataTextStyle`, `headingRowColor` | `data_table_view` styling |
| `DividerThemeData` | `outlineVariant`, thickness 1, space | 13 ad-hoc borders |
| `DialogThemeData` | `shapes.xl`, `titleTextStyle` | delete confirmations |
| `NavigationRailThemeData` | `indicatorShape: shapes.full`, `secondaryContainer`, labels | `app_navigation:96` (`Colors.transparent`), `:112` (raw `TextStyle`) |
| `NavigationDrawerThemeData` | same as rail | drawer styling |
| `FilledButtonTheme` / `OutlinedButtonTheme` / `TextButtonTheme` | `shapes.full`, tier padding, `buttonLabel` | `record_form_actions` |
| `ListTileThemeData` | title/subtitle styles, `minVerticalPadding`, density | `facility_child_row` |
| `SegmentedButtonThemeData` | shape, density | status facet filters |
| `BottomSheetThemeData` | `shapes.xl` top corners | compact filter sheet |
| `SnackBarThemeData`, `TooltipThemeData`, `PopupMenuThemeData`, `SwitchThemeData`, `ProgressIndicatorThemeData` | type + shape + color | scattered defaults |

**Not fully covered by `DataTableThemeData`**: `DataTable2` carries its own
`dataRowHeight`, `headingRowHeight` and `dividerThickness` parameters
(`data_table_2 2.7.2`). These are passed by `core/widgets/data_table_view.dart` from
`theme.density`, in that one wrapper — never per screen (research R5).

---

## Shared status indicator

`FR-018` collapses two near-identical implementations into one shared control in
`lib/core/widgets/`, generic over its status enum. `EntityStatus` and `CashSessionStatus`
both adopt it. Its label style comes from `ChipThemeData`, so the `labelStyle:
TextStyle(color: …)` in both current copies disappears.

---

## Verification contract

| Gate | Requirement | Mechanism |
|---|---|---|
| Golden coverage | `FR-020`, `FR-023` | Every shared control, light/dark × narrow/wide. A control with no golden **fails**; it does not pass silently. |
| Sequencing | `FR-021` | Goldens exist and pass **before** any sub-theme lands. |
| Default-brand contrast | `FR-022`, `SC-003` | Text roles ≥ 4.5:1, meaningful non-text ≥ 3:1, both modes. |
| **Deployment contrast** | `FR-027`, `SC-011` | A test run with the deployment's own `--dart-define` values, **before** `flutter build`. Non-zero exit fails the deployment. |
| Isolation | `FR-003`, `SC-004` | Overridden-seed config yields zero XBE-traceable values. |
| Structure not brandable | `FR-010`, `SC-008` | Token values identical under two different brand configs. |
| No hardcodes | `SC-001`, `SC-002` | Zero typeface/size/color literals outside the token definitions. |

**Deployment pipeline requirement** (from `FR-027`): the contrast test and the build MUST
receive identical `--dart-define` values. Keep them in one pipeline script — two scripts
drift, and a drifted gate verifies a build that was never shipped.

```bash
flutter test test/contract/brand_contrast_test.dart --dart-define=BRAND_SEED_COLOR=$SEED
flutter build web --dart-define=BRAND_SEED_COLOR=$SEED
```

---

## Migration contract for feature authors

While this feature rolls out, a screen is in one of two states. Both are valid; mixing
them **within one widget** is not.

- **Not yet migrated** — keeps its literals. Do not partially convert.
- **Migrated** — every spacing, radius, color and text style comes from the theme.

A new screen written during the rollout starts migrated. A screen touched for an unrelated
reason is not migrated opportunistically — that would land untested visual change outside a
golden-covered task.
