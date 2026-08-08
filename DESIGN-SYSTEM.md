# MBE-UI Design System — Proposal

**Status**: Proposal. **Nothing here is implemented.** This document exists to
be reviewed, argued with, and then turned into a spec (`specs/0NN-design-system-tokens/`)
that implements it in phases.

**Scope**: the token layers and component theming that [DESIGN.md](DESIGN.md) §4
and [constitution](.specify/memory/constitution.md) §V/§VI assume but never
define. Color and logo/asset tokens are already done — see
[spec 019](specs/019-xbe-default-branding/) — and are not re-litigated here.

**Audience**: anyone designing or building an MBE screen, and the spec author
who implements this. Every number below is either an M3 spec value, a value
read out of the installed Flutter SDK, or a measurement from the approved
brand guide — with the source named. Nothing is invented to fill a table.

---

## 1. Where we actually are

The design system is half-built, and the built half is the hard half.

| Layer | State | Source of truth |
|---|---|---|
| Color roles | ✅ **Done** — 20 dark / 19 light roles pinned, rest seed-derived | [xbe_palette.dart](lib/core/branding/xbe_palette.dart), [brand-tokens.md](specs/019-xbe-default-branding/contracts/brand-tokens.md) |
| Brand ink (contrast-safe foreground) | ✅ **Done** | [brand_ink.dart](lib/core/branding/brand_ink.dart) |
| Font families | ✅ **Done** — Archivo + Roboto + RobotoMono, bundled | [pubspec.yaml](pubspec.yaml), [assets/fonts/](assets/fonts/) |
| Logo placement | ✅ **Done** — 7 placements, min sizes, opacities | `XbePalette` placement block |
| Type **role assignment** | ⚠️ Metrics inherited from M3; no decision about which role goes where | §3 below |
| Spacing scale | ❌ Nothing | §4 |
| Shape / radius scale | ❌ Nothing | §5 |
| Elevation | ❌ Nothing | §6 |
| Density / touch targets | ❌ Nothing | §7 |
| Component sub-themes | ❌ **Zero** — no `AppBarTheme`, `CardThemeData`, `InputDecorationTheme`, `ChipThemeData`, `DataTableThemeData`, … | §8 |
| Form-factor behavior | ⚠️ Breakpoints exist; per-tier behavior is per-screen folklore | §9 |
| Component library | ⚠️ 20 widgets in [lib/core/widgets/](lib/core/widgets/), no index or reference render | §11 |

**One correction to the framing.** "Type scale ❌ nothing" is too harsh. Flutter's
`Typography.material2021` already ships the complete M3 ramp — sizes, line
heights, and letter-spacing for all 15 roles. What's missing isn't the ramp,
it's **the decision about which role each piece of UI uses**. That gap is
exactly why five `fontFamily:` strings and three `fontSize:` literals are
hardcoded across `lib/`: with no role assignment written down, the fastest path
for each screen was to re-specify type inline.

---

## 2. Design principles for this system

1. **M3 is the ramp; we choose the rungs.** Never redefine M3's metrics. Where
   this document adds value, it adds *semantic assignment* ("a section heading
   is `titleLarge` on desktop, `titleMedium` on phone"), not new numbers.
2. **Tokens are read from `Theme.of(context)`, always.** A widget that imports
   a token constant directly re-creates the drift this system exists to remove —
   and, for brand colors, breaks spec 019's FR-007 white-label isolation.
3. **Structure is not brandable.** Constitution §V: per-deployment
   customization is "limited to color scheme, typography, and branding assets,
   **not layout/structure**." Spacing, shape, elevation, and density are
   therefore *product* tokens, not brand tokens — a distinction that decides
   where they live (§10).
4. **Elevation is color first, shadow second.** M3's own preference, and it's
   already paid for here: the palette pins `surfaceContainerLowest/Low/Container`.
5. **Compact is designed now, built later.** Constitution §VI defers the phone
   tier, and this proposal does not change that. But every token below is
   specified across all four tiers so the deferral stays a scheduling decision
   instead of a redesign.

---

## 3. Type scale

### 3.1 The ramp — inherited verbatim from M3

Read out of the installed SDK (`packages/flutter/lib/src/material/typography.dart`,
`englishLike2021`). **Do not restate these in app code** — they arrive for free
via `useMaterial3: true`.

| Role | Size | Line height | Tracking | M3 weight |
|---|---|---|---|---|
| `displayLarge` | 57 | 1.12 | −0.25 | w400 |
| `displayMedium` | 45 | 1.16 | 0 | w400 |
| `displaySmall` | 36 | 1.22 | 0 | w400 |
| `headlineLarge` | 32 | 1.25 | 0 | w400 |
| `headlineMedium` | 28 | 1.29 | 0 | w400 |
| `headlineSmall` | 24 | 1.33 | 0 | w400 |
| `titleLarge` | 22 | 1.27 | 0 | w400 |
| `titleMedium` | 16 | 1.50 | +0.15 | w500 |
| `titleSmall` | 14 | 1.43 | +0.10 | w500 |
| `bodyLarge` | 16 | 1.50 | +0.50 | w400 |
| `bodyMedium` | 14 | 1.43 | +0.25 | w400 |
| `bodySmall` | 12 | 1.33 | +0.40 | w400 |
| `labelLarge` | 14 | 1.43 | +0.10 | w500 |
| `labelMedium` | 12 | 1.33 | +0.50 | w500 |
| `labelSmall` | 11 | 1.45 | +0.50 | w500 |

### 3.2 Brand deviation, stated honestly

[app_theme.dart](lib/app/theme/app_theme.dart) currently sets **w600 on
headline/title/label** and **w700 on display** — a deliberate brand choice, but
a real deviation: M3 specifies w400 for display/headline/title-large and w500
for title/label. Two consequences to decide on:

- M3's tracking values were optically tuned for Roboto at Roboto's weights.
  Archivo is a wider grotesque, and at w700 the display roles will look loose
  at M3's tracking. **Proposal**: keep M3 tracking everywhere except
  `display*` and `headlineLarge`, where Archivo w700 likely wants −0.5 to
  −1.0. These values must be *measured against the brand guide's own mockups*,
  not guessed — that measurement is a task in the implementing spec.
- **Proposal**: drop the w600 override on `body*`-adjacent label roles
  (`labelMedium`, `labelSmall`) back to M3's w500. At 11–12 px, w600 Archivo
  fills counters and costs legibility, which is the opposite of what a label
  role is for.

### 3.3 Semantic role assignment — the part that's actually missing

This table is the deliverable of §3. It replaces "pick a size at the call site"
with "name your slot, get a role." Assignments shift by tier per M3's guidance
(the ramp is fixed; you select different *rungs* at different window sizes).

| UI slot | Compact | Medium | Expanded / Large | Family |
|---|---|---|---|---|
| App bar / screen title | `titleLarge` | `titleLarge` | `titleLarge` | Archivo |
| Hero heading (login tagline) | `headlineMedium` | `displaySmall` | `displaySmall` | Archivo |
| Hero subhead | `bodyLarge` | `bodyLarge` | `bodyLarge` | Roboto |
| Page heading (home greeting) | `headlineSmall` | `headlineMedium` | `headlineMedium` | Archivo |
| Section heading (in-form) | `titleMedium` | `titleMedium` | `titleLarge` | Archivo |
| Card / panel title | `titleMedium` | `titleMedium` | `titleMedium` | Archivo |
| Metric value (dashboard tile) | `headlineSmall` | `headlineMedium` | `headlineMedium` | Archivo |
| Metric label | `bodySmall` | `bodySmall` | `bodySmall` | Roboto |
| Nav destination label | `labelLarge` | `labelLarge` | `labelLarge` | Archivo |
| Nav header (app name) | `titleSmall` | `titleSmall` | `titleSmall` | Archivo |
| Table column header | `labelLarge` | `labelLarge` | `labelLarge` | Archivo |
| Table cell | `bodyMedium` | `bodyMedium` | `bodyMedium` | Roboto |
| Form field input | `bodyLarge` | `bodyLarge` | `bodyMedium` | Roboto |
| Form field label / helper | `bodySmall` | `bodySmall` | `bodySmall` | Roboto |
| Chip / badge label | `labelLarge` | `labelLarge` | `labelMedium` | Archivo |
| Button label | `labelLarge` | `labelLarge` | `labelLarge` | Archivo |
| **Code / SKU / folio / ID** | `bodyMedium` | `bodyMedium` | `bodyMedium` | **RobotoMono** |
| Money / quantity (numeric cell) | `bodyMedium` | `bodyMedium` | `bodyMedium` | Roboto, tabular figures |
| Timestamp / relative time | `bodySmall` | `bodySmall` | `bodySmall` | RobotoMono |
| Snackbar / tooltip | `bodyMedium` | `bodyMedium` | `bodySmall` | Roboto |

**What this table retires** (all currently hardcoded):

| Hardcode | Becomes |
|---|---|
| [brand_nav_header.dart:33](lib/core/widgets/brand_nav_header.dart#L33) — `Archivo/w600/14` | `titleSmall` (14, w500 → w600 via brand weight) |
| [login_branding_pane.dart:33](lib/features/auth/presentation/login/login_branding_pane.dart#L33) — `Archivo/w700/32` | `displaySmall` (36) at Expanded |
| [login_branding_pane.dart:44](lib/features/auth/presentation/login/login_branding_pane.dart#L44) — `15` | `bodyLarge` (16) |
| [home_welcome.dart:169](lib/features/home/presentation/home_welcome.dart#L169) — `copyWith(fontFamily: 'Archivo')` | already `headlineMedium`; the family override becomes redundant |
| [home_dashboard_tiles.dart:88](lib/features/home/presentation/home_dashboard_tiles.dart#L88) — same | already `headlineSmall`; override redundant |
| [home_activity_feed.dart:93](lib/features/home/presentation/home_activity_feed.dart#L93) — `'RobotoMono'` | a `monoFor(context)` token helper (§10) |

**RobotoMono is currently a broken promise.** [brand-tokens.md](specs/019-xbe-default-branding/contracts/brand-tokens.md#L70)
assigns it to "codes / SKUs / monospaced data"; it appears in exactly one place
(activity-feed timestamps), while every SKU and product-code column renders in
body text. Either honor the contract in the table columns or amend the contract
— but not both as-is.

---

## 4. Spacing scale

M3 is built on a **4 dp grid**. Proposal: an 8-step ramp, all multiples of 4.

| Token | dp | Typical use |
|---|---|---|
| `space.none` | 0 | — |
| `space.xxs` | 4 | icon↔text in a dense chip, badge insets |
| `space.xs` | 8 | icon↔label, chip gaps, tight row padding |
| `space.sm` | 12 | table cell padding, list row vertical padding |
| `space.md` | 16 | **the default** — card padding (compact), field gaps |
| `space.lg` | 24 | card padding (desktop), section gaps, pane gutter |
| `space.xl` | 32 | between major form sections |
| `space.xxl` | 48 | page header ↔ content, empty-state insets |
| `space.xxxl` | 64 | hero/branding pane insets |

### 4.1 Per-tier layout spacing

Per M3 window size classes, aligned to the tiers already defined in
[breakpoints.dart](lib/core/layout/breakpoints.dart):

| Metric | Compact <600 | Medium 600–839 | Expanded 840–1199 | Large ≥1200 |
|---|---|---|---|---|
| Screen margin | 16 (`md`) | 24 (`lg`) | 24 (`lg`) | 24 (`lg`) |
| Pane gutter (list ↔ detail) | n/a (stacked) | 24 | 24 | 24 |
| Card padding | 16 | 16 | 24 | 24 |
| Field gap (vertical) | 16 | 16 | 16 | 16 |
| Field gap (horizontal, grid) | n/a | 16 | 24 | 24 |
| Section gap | 24 | 32 | 32 | 32 |
| Content max width | none | none | none | 1440 (then center) |

### 4.2 A note on the brand guide's own spacing

Measured from [XBE Look and Feel](artifacts/branding/XBE%20Look%20and%20Feel.dc.html):
the most common gaps are **14 px (26×)**, 12 (19×), 20 (16×), 16 (12×), 8 (11×).
The 14 px value is **off the 4 dp grid** — an artifact of the doc being authored
as a web canvas, not a Flutter intent. **Proposal**: snap 14 → 12 or 16 by
context rather than adding a 14 token; adding it would make every future
"which gap?" question ambiguous for the sake of matching a pixel value nobody
specified deliberately. Flag this to the brand owner rather than deciding
silently.

---

## 5. Shape / radius scale

### 5.1 Important implementation constraint

**Flutter has no `ShapeScheme` on `ThemeData`.** I checked the installed SDK:
M3 corner radii are baked into each component's own defaults (`Card` 12,
`Chip` 8, `Dialog` 28, buttons `StadiumBorder`). A shape *scale* therefore has
to be a `ThemeExtension` that the component sub-themes (§8) then consume. This
is the single biggest reason the shape layer never got built — there's no
built-in slot for it.

### 5.2 The scale (M3 shape tokens)

| Token | Radius | M3 name | Applies to |
|---|---|---|---|
| `shape.none` | 0 | none | table cells, dividers, full-bleed surfaces |
| `shape.xs` | 4 | extraSmall | text field (filled), snackbar |
| `shape.sm` | 8 | small | chips, badges, menu items |
| `shape.md` | 12 | medium | Flutter's `Card` default, inner containers |
| `shape.lg` | 16 | large | **cards and panels** (see below) |
| `shape.xl` | 28 | extraLarge | dialogs, side sheets, bottom sheets |
| `shape.full` | `StadiumBorder` | full | buttons, nav indicators, filter pills |

### 5.3 Two deviations worth adopting

- **Cards/panels at `lg` (16), not Flutter's `md` (12).** The brand guide's
  radii cluster overwhelmingly at 16 px (26 occurrences — the single most common
  value in the document), with a secondary 20–24 cluster. Matching the guide
  means overriding `CardThemeData.shape`.
- **`BorderRadius.circular(28)` in [app_navigation.dart:97](lib/core/widgets/app_navigation.dart#L97)
  is an ad-hoc stadium.** On a ~48 dp tall nav item, `circular(28)` and
  `StadiumBorder` render identically — but only the latter states the intent
  and survives a height change. **Proposal**: `shape.full`, applied through
  `NavigationRailThemeData.indicatorShape` / `NavigationDrawerThemeData`.

---

## 6. Elevation

M3 defines six levels (0/1/3/6/8/12 dp — *M3 spec values; confirm against the
SDK's component defaults at implementation time*), but M3 also prefers
conveying elevation with **surface color** over shadow. That preference is
already funded here: the palette pins `surfaceContainerLowest`, `Low`, and
`Container`.

| Level | Surface role | Shadow | Used for |
|---|---|---|---|
| 0 | `surface` | none | page background |
| 0 | `surfaceContainerLowest` | none | the "sunken" well behind a card list |
| 1 | `surfaceContainerLow` | none | **cards, panels at rest** |
| 2 | `surfaceContainer` | none | search bar, filter bar, selected row |
| 3 | `surfaceContainerHigh` | 6 dp | popup menu, autocomplete overlay, FAB |
| 4–5 | `surfaceContainerHighest` | 8–12 dp | modal dialog, side sheet, drag proxy |

**Rule**: persistent surfaces get elevation by color and **no shadow**;
transient overlays (menu, dialog, sheet, snackbar, dragged item) get both.
This keeps a dense desktop table screen visually flat, which is what makes
tabular data readable.

**Prerequisite (a real blocker):** `surfaceContainerLow` is pinned in the dark
scheme only — [app_theme.dart:77](lib/app/theme/app_theme.dart#L77) — while
four widgets already consume the role. Light mode silently falls back to a
seed-derived value. Level 1 above is not trustworthy until that pin is added.

---

## 7. Density and touch targets

The only layer here that *must* vary by input modality rather than width.

| | Compact / Medium (touch) | Expanded / Large (pointer) |
|---|---|---|
| `VisualDensity` | `standard` (0, 0) | `comfortable` (−1, −1) |
| Min interactive target | 48 × 48 | 40 × 40 |
| Table header row height | n/a | 48 |
| Table data row height | n/a (cards) | 44 |
| List row min height | 56 | 48 |
| Icon button size | 48 | 40 |
| Text field | `isDense: false` | `isDense: true` |

Note this is keyed on *input*, not width — a 1024 px touch tablet in landscape
should get touch metrics. Proposal: derive from
`MediaQuery.navigationModeOf` / pointer device kind where available, falling
back to the width tier. Detail for the implementing spec.

---

## 8. Component sub-themes

Currently **zero** exist. This is where the tokens above become real, and where
most of the audit's raw-`TextStyle` bypasses die.

| Sub-theme | Carries | Retires the hardcode in |
|---|---|---|
| `AppBarTheme` | `titleTextStyle` = `titleLarge`, `centerTitle: false`, `scrolledUnderElevation` | — |
| `CardThemeData` | `shape.lg`, `surfaceContainerLow`, `elevation: 0`, per-tier margin | home tiles, `facility_card`, welcome card |
| `InputDecorationTheme` | filled, `shape.xs`, label/helper/error styles, per-tier `isDense` | every form field in 18 detail screens |
| `ChipThemeData` | `labelStyle`, `shape.sm`, density, container colors | [entity_status_controls.dart:46](lib/core/widgets/entity_status_controls.dart#L46), [cash_session_status_chip.dart:48](lib/features/sales/presentation/widgets/cash_session_status_chip.dart#L48) |
| `DataTableThemeData` | `headingTextStyle` = `labelLarge`, `dataTextStyle` = `bodyMedium`, per-tier row heights, `dividerThickness` | `data_table_view`, and the `DataTable2` config |
| `DividerThemeData` | `outlineVariant`, thickness 1, space | 13 ad-hoc `outlineVariant` borders |
| `DialogThemeData` | `shape.xl`, `titleTextStyle` = `headlineSmall` | delete confirmations, `catalog_filter_sheet` |
| `NavigationRailThemeData` / `NavigationDrawerThemeData` | `indicatorShape` = `shape.full`, `indicatorColor` = `secondaryContainer`, label styles | [app_navigation.dart:96](lib/core/widgets/app_navigation.dart#L96) (`Colors.transparent`) and [:112](lib/core/widgets/app_navigation.dart#L112) (raw `TextStyle`) |
| `FilledButtonTheme` / `OutlinedButtonTheme` / `TextButtonTheme` | `shape.full`, per-tier padding, `labelLarge` | `record_form_actions` |
| `ListTileThemeData` | title/subtitle styles, `minVerticalPadding`, density | `facility_child_row`, list rows |
| `SegmentedButtonThemeData` | shape, density | status facet filters |
| `SnackBarThemeData`, `TooltipThemeData`, `PopupMenuThemeData`, `SwitchThemeData`, `ProgressIndicatorThemeData` | type + shape + color per §3/§5 | scattered defaults |
| `BottomSheetThemeData` | `shape.xl` (top corners only) | compact-tier filter sheet |

Defining `ChipThemeData` and the navigation themes alone removes three of the
raw-`TextStyle` bypasses found in the theme audit — the sub-themes aren't
just tidiness, they're the mechanism that makes call sites stop re-specifying
type.

---

## 9. Form-factor behavior

Constitution §VI targets Expanded first and defers Compact. This table
specifies all four tiers so that deferral doesn't become a redesign. Tiers are
[breakpoints.dart](lib/core/layout/breakpoints.dart)'s, unchanged.

| Concern | Compact <600 | Medium 600–839 | Expanded 840–1199 | Large ≥1200 |
|---|---|---|---|---|
| Navigation | `NavigationBar` (bottom) + modal drawer | `NavigationRail` collapsed (icons) | `NavigationRail` extended | extended |
| Brand in nav | mark only | mark only | mark + display name | mark + display name |
| List presentation | **card list** — no horizontal scroll | table, priority columns only | `DataTable2`, all columns | `DataTable2`, all columns |
| List → detail | push full screen | push full screen | two-pane list + detail | two-pane |
| Form columns | 1 | 2 | 2 | 2 (3 only where the data model allows) |
| Record actions | sticky bottom bar | in-form, right-aligned | in-form, right-aligned | in-form |
| Filters | **bottom sheet** | side sheet | side sheet (current) | side sheet |
| Dialogs | full-screen dialog | dialog | dialog | dialog |
| Pagination | infinite scroll or compact pager | full pager | full pager | full pager |
| Search | collapses to icon → full-width field | inline in filter bar | inline | inline |
| Status display | **dot** (color + tooltip) | chip | chip | chip |
| Density | standard | standard | comfortable | comfortable |

Two of these already exist in code and should be treated as the reference
implementations, not rewritten: [facility_child_row.dart](lib/features/catalog/presentation/widgets/facility_child_row.dart)
already switches chip → dot at Compact, and
[responsive_form_grid.dart](lib/core/widgets/responsive_form_grid.dart) already
does the 1↔2 column transition.

**The genuinely unbuilt piece** is the Compact table→card transformation. Every
list screen currently assumes `DataTable2`. That's the one row above that is a
new component, not a token application — and it's the reason Compact is
deferred rather than nearly-free.

---

## 10. Where this lives

Respecting constitution §I layering (verified: nothing in `lib/features/` or
`lib/core/` imports `lib/app/`) and spec 019 R6 (brand tokens live in
`core/branding/`, `app/theme/` is a consumer):

```
lib/core/design/                 ← NEW: product tokens (not brandable, per §V)
  spacing.dart                   ← Spacing  extends ThemeExtension
  shapes.dart                    ← Shapes   extends ThemeExtension
  elevations.dart                ← Elevations extends ThemeExtension
  density.dart                   ← per-tier density + target sizes
  type_roles.dart                ← the §3.3 slot→role mapping, tier-aware

lib/core/branding/               ← EXISTING: brand tokens (per-deployment)
  xbe_palette.dart               ← unchanged
  brand_ink.dart                 ← unchanged
  brand_config.dart              ← unchanged

lib/app/theme/
  app_theme.dart                 ← assembles ThemeData: colors + type +
                                   extensions + all §8 sub-themes
```

**Why `core/design/` and not `core/branding/`:** constitution §V says
customization is limited to "color scheme, typography, and branding assets,
**not layout/structure**." Spacing, shape, elevation, and density are fixed
product structure — putting them beside per-deployment brand tokens would
invite a future deployment to override them, which §V forbids. The directory
split encodes the rule.

**Access pattern** — identical to the `BrandInk` extension already shipped, so
there's one idiom to learn:

```dart
final theme = Theme.of(context);
Padding(
  padding: EdgeInsets.all(theme.spacing.lg),
  child: Card(
    // shape/color come from CardThemeData — not restated here
    child: Text(label, style: theme.typeRoles.sectionHeading(context)),
  ),
);
```

Every token reachable from `Theme.of(context)`; no widget imports a token
constant directly.

---

## 11. Component library documentation

The 20 widgets in [lib/core/widgets/](lib/core/widgets/) are the design
system's actual component layer, and they're undocumented as such. Proposal,
in priority order:

1. **An index** in this document or its own page: component → purpose → which
   constitution rule mandates it → reference screen.
2. **Widget previews** via Flutter's `previews.dart` system, giving a rendered
   reference in both themes at all four tiers. This is the closest thing to a
   Storybook that Flutter offers, and it's the piece that would make this
   system reviewable by a designer rather than only by a developer. (Not set
   up in the repo today — it would be new work in Phase 1 or 2.)
3. **Golden tests** at Compact + Expanded, light + dark, for each shared
   component — the regression net that makes the §8 sub-theme rollout safe.

Note: [cash_session_status_chip.dart](lib/features/sales/presentation/widgets/cash_session_status_chip.dart)
duplicates [entity_status_controls.dart](lib/core/widgets/entity_status_controls.dart)'s
chip pattern verbatim (same `labelStyle`, same `visualDensity`, different enum).
Constitution §VI wants shared status badges in `core/widgets/` — this is a
candidate for consolidation into one generic status chip during Phase 2.

---

## 12. Suggested implementation phases

Sized so each lands independently and none is a big-bang.

| Phase | Content | Risk | Verification |
|---|---|---|---|
| **0. Prereqs** | Fix the `TextTheme` ink bug (theme's own `onSurface` never reaches text); pin light `surfaceContainerLow` | Low, but visible | Existing theme tests + new contrast assertions |
| **1. Token layer** | `core/design/` extensions, registered on `ThemeData`. **Zero call-site changes** | Very low — purely additive | Unit tests on token values; nothing renders differently |
| **2. Component sub-themes** | All of §8 | **Highest** — changes how everything looks | Golden tests must land *before* this phase |
| **3. Semantic type roles** | §3.3 mapping; retire 5 `fontFamily` + 3 `fontSize` hardcodes | Low | Widget tests asserting role, not literal |
| **4. Call-site migration** | Raw `EdgeInsets`/`SizedBox` → spacing tokens, per feature module | Low each, large diff | Per-module; goldens catch drift |
| **5. Compact tier** | §9's compact column, incl. the table→card component | High — new scope | Out of current constitution §VI scope; needs its own spec |

Phase 0 is a bug fix and could ship immediately. Phase 2 is the one that
genuinely needs golden coverage first — without it, a `CardThemeData` change
silently restyles 18 screens with no test that notices.

---

## 13. Open questions — decide before the spec

1. **Archivo tracking**: what are the measured letter-spacing corrections for
   `display*`/`headlineLarge` at w700? Needs measurement against the brand
   guide's mockups, not a guess.
2. **Brand weights vs. M3**: keep w600/w700 across all brand roles, or revert
   `labelMedium`/`labelSmall` to w500 (§3.2)?
3. **The 14 px gap**: snap to the 4 dp grid, or is 14 an intentional brand
   value the guide should state explicitly (§4.2)?
4. **RobotoMono**: honor the "codes / SKUs" contract in table columns, or amend
   the contract to "timestamps and IDs only" (§3.3)?
5. **`data_table_2` theming**: how much of `DataTableThemeData` does the
   package actually honor, and what has to be passed to `DataTable2` directly?
6. **Compact tier scope**: does §9's compact column get scoped now, or stay
   deferred with this document as its design input?
7. **Density trigger**: input modality (correct) or width (simple)? §7.
8. **Golden test infrastructure**: not currently in the repo — does Phase 2
   depend on adding it, and with which package?

---

## 14. Non-goals

- **Not** changing the color scheme, logo rules, or fonts — spec 019 settled
  those and they're correct.
- **Not** moving off Material 3 or introducing a custom component kit.
- **Not** making spacing/shape/density per-deployment configurable —
  constitution §V forbids it (§10).
- **Not** building the Compact tier — that stays deferred; this only ensures
  the tokens won't need redesigning when it's scoped.
- **Not** replacing `data_table_2` or any current dependency.
