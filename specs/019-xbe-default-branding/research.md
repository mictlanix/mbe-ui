# Phase 0 Research: XBE Default Branding

**Feature**: 019-xbe-default-branding | **Date**: 2026-07-28

Resolves the open technical questions from the spec's Assumptions and the
Technical Context unknowns in [plan.md](./plan.md).

---

## R1. How to express the brand palette without violating constitution §V

**Question**: Constitution §V requires both `ColorScheme`s be "derived from
the same per-customer seed color via `ColorScheme.fromSeed`", but the brand
guide specifies exact Pantone-matched hex values for `tertiary` (#EC672A,
Pantone 165 C), `error` (#D8262E, Pantone 1795 C), `secondary` (#C7C7C8) and
a full warm-neutral surface ramp that Material's algorithm would not produce
from a gold seed alone.

**Decision**: Use `ColorScheme.fromSeed(seedColor: xbeGold, brightness: …,
dynamicSchemeVariant: DynamicSchemeVariant.fidelity, <role overrides>)`.

Verified against the installed SDK (Flutter 3.44.2,
`packages/flutter/lib/src/material/color_scheme.dart:309`): `fromSeed` takes
`dynamicSchemeVariant`, `contrastLevel`, and an optional override parameter
for **every one of the 45 color roles**. Pinning brand-exact roles is
therefore done *through* `fromSeed`, not as a replacement for it — every
unpinned role stays algorithmically derived from the single gold seed, and
both brightnesses share that seed.

`DynamicSchemeVariant.fidelity` is chosen over the default `tonalSpot`
because fidelity "match[es] seed color, even if the seed color is very
bright (high chroma)" and carries the seed's hue into the neutral palettes —
which is exactly the brand guide's stated intent for warm-tinted (not pure
gray) neutrals.

**Rationale**: satisfies §V literally and mechanically, keeps one seed as
the per-deployment knob, and still lands the corporate Pantone values
exactly where the brand guide requires them.

**Alternatives considered**:

- *Pure `fromSeed`, no overrides* — rejected: Material's tonal algorithm
  shifts #EC672A and #D8262E measurably off their Pantone equivalents, so
  the app would not actually match the approved corporate palette.
- *Hand-authored `const ColorScheme.dark(...)` / `.light(...)`* (what the
  design doc's own reference snippet does) — rejected: abandons the seed
  entirely, breaking §V and removing the single per-deployment knob that
  makes white-labeling work.

---

## R2. Light scheme (resolved — sourced from the design project, not derived)

**Update (2026-07-28)**: the design project's "XBE Look and Feel" doc was
updated to add a fully-specified §06 "Modo claro" (light mode) section after
this feature's initial planning. The light scheme is now **transcribed
directly from the brand guide**, the same way the dark scheme was — this
supersedes the original plan (below, kept for the record) to derive it
algorithmically.

**Decision**: pin the light `ColorScheme` to the brand guide's exact light
tokens through `fromSeed`'s role overrides, mirroring the dark scheme's
approach (see R1):

| Role | Value | Note |
|---|---|---|
| `primary` | `#ECAB03` | same gold, used as a **fill** with dark ink |
| `onPrimary` | `#241900` | |
| `primaryContainer` | `#FFE7A8` | |
| `onPrimaryContainer` | `#5C4000` | |
| `secondary` | `#5A5349` | |
| `onSecondary` | `#FFFFFF` | |
| `tertiary` | `#EC672A` | |
| `onTertiary` | `#FFFFFF` | |
| `error` | `#C4262E` | Pantone 1795 C, adjusted for 4.6:1 contrast on white |
| `onError` | `#FFFFFF` | |
| `errorContainer` | `#FBDEDF` | |
| `onErrorContainer` | `#A31219` | |
| `surface` | `#FBF8F3` | |
| `onSurface` | `#1C1A16` | |
| `surfaceContainerLowest` | `#FFFFFF` | |
| `surfaceContainer` | `#F3EDE3` | |
| `onSurfaceVariant` | `#5A5349` | |
| `outline` | `#C4BBAC` | |
| `outlineVariant` | `#E3DACC` | |

**Brand-color text on light surfaces**: the brand guide is explicit that raw
gold fails as *text*: "El oro puro (#ECAB03) no alcanza contraste como texto
sobre blanco … para texto y iconos activos se baja a un oro tostado
(#7A5600, 5.4:1)." A new constant `xbeGoldInk = #7A5600` is used wherever
gold would otherwise be used as *text or icon color* on a light surface
(e.g. an active nav-item label) — never for fills, where raw `primary` gold
is correct and already passes contrast against its `onPrimary` ink.

**Logo variant on light**: the brand guide's light mockups use the
grayscale lockup (`xbe-lockup-gray.svg`, approved Cool Gray 3 C), matching
what R4/contracts already specify for light backgrounds — no change needed
there.

**Watermark opacity on light**: the light home mockup uses the **full-color**
mark at **6%** opacity (vs. the dark mode's white mark at 7%) — see
`data-model.md`'s placement constants for both.

**Rationale**: identical to R1 — matching the approved corporate palette
exactly takes priority, applied through `fromSeed`'s overrides so §V's "one
seed, both schemes" still holds mechanically; only the roles the guide
doesn't specify (fixed/dim variants, inverse colors, scrim, shadow,
surfaceTint, surfaceBright, surfaceContainerHigh/Highest) are left to
algorithmic derivation.

<details>
<summary>Original plan (superseded) — algorithmic light derivation</summary>

Before the light scheme was added to the design project, the plan was to
pin only `error` and derive everything else (including `primary`) from the
gold seed via `fromSeed`'s `fidelity` variant, reasoning that raw gold fails
contrast as a light-mode fill. The brand guide's actual answer differs
subtly and is more correct: keep gold as the **fill** (contrast is against
its dark `onPrimary` ink, which passes), but demote gold to a darker
"toasted" ink (`#7A5600`) specifically when gold is used as *text*. This is
adopted as the resolved decision above.

</details>

**Alternatives considered**:

- *Keep the original algorithmic derivation now that real tokens exist* —
  rejected: would ship a scheme that's recognizably not the approved
  palette once compared side-by-side, for no remaining benefit (the
  blocker — "no light tokens exist" — no longer applies).

---

## R3. Typography delivery — bundled fonts vs. `google_fonts`

**Decision**: Bundle **Archivo** (400/500/600/700) and **Roboto Mono**
(400/500) as local font assets under `assets/fonts/`, declared in
`pubspec.yaml`'s `fonts:` section. **Roboto is not bundled** — it already
ships as Flutter's Material 3 default body face, so body/table text needs no
change (satisfying the spec's "body text keeps the existing readable
typeface").

**Rationale**: the `google_fonts` package fetches font binaries from
`fonts.gstatic.com` at first runtime and caches them, which means a
first-run network dependency on a third-party host, a flash of fallback
type, and a failure mode in restricted/enterprise network environments.
Bundling is deterministic, offline-safe, adds no runtime dependency, and
keeps builds reproducible. Both families are OFL-licensed and
redistributable; ship each family's `OFL.txt` alongside.

**Alternatives considered**:

- *`google_fonts` package* — rejected for the runtime-fetch behavior above.
- *Bundle Roboto too* — unnecessary duplication of what Flutter already
  provides, and adds ~500 KB for no visual change.

**Note**: Archivo and Roboto Mono are distributed as variable fonts; a
single variable `.ttf` per family covers all required weights, which is
smaller than four static files.

---

## R4. Logo rendering — SVG vs. bundled rasters

**Decision**: Render in-app logo placements from the **PNG raster variants**
the design project already provides (`login_lockup_1x/2x/3x.png`,
`nav_lockup_1x/2x/3x.png`) using Flutter's built-in resolution-aware asset
variants. Keep the source SVGs in the repo under `assets/brand/` as the
regeneration source of truth. **No `flutter_svg` dependency is added.**

**Rationale**: zero new runtime dependencies, correct rendering on all six
target platforms including web with no SVG rasterization cost, and the
design project already exported the rasters explicitly for this purpose.
Every in-app placement in the spec is at a fixed, known size (login lockup
~236 px, nav mark ~34 px), so arbitrary vector scaling buys nothing. The decorative watermark renders at ~7% opacity where
raster softness is imperceptible.

**Alternatives considered**:

- *`flutter_svg`* — crisper at arbitrary sizes and a smaller asset payload,
  but adds a dependency not in the constitution's stack for a benefit no
  current placement needs. Revisit if a future placement needs free scaling.

---

## R5. Native icon & splash generation

**Decision**: Add `flutter_launcher_icons` and `flutter_native_splash` as
**dev dependencies**, configure them in `pubspec.yaml`, run them once, and
**commit the generated native outputs**.

Source assets map as follows:

| Generator input | Source asset | Targets |
|---|---|---|
| `image_path` | `app_icon_dark_1024.png` | iOS, macOS, Windows, web |
| `adaptive_icon_foreground` | `android_adaptive_foreground_1024.png` | Android adaptive |
| `adaptive_icon_background` | `#14120F` (solid) | Android adaptive |
| splash `image` | `splash_lockup_1024.png` | Android, iOS, web |
| splash `color` | `#14120F` | all splash targets |

**Rationale**: these are the standard, widely-used Flutter tools for this
exact job; they are build-time codegen only (no runtime dependency, no
shipped code), and committing their output keeps CI builds from needing a
generation step.

**Known limitation**: `flutter_launcher_icons` has no Linux target. The
Linux desktop build keeps its current icon; recorded as accepted scope, not
a defect.

**Web favicon**: `favicon_32/192/512.png` replace `web/favicon.png` and
`web/icons/Icon-*.png`; `web/manifest.json`'s `background_color` and
`theme_color` move off Flutter's default `#0175C2` to `#14120F`.

---

## R6. Where brand tokens live (constitution §V compliance)

**Decision**: All brand tokens move into `lib/core/branding/`, extending the
existing `BrandConfig`. `lib/app/theme/app_theme.dart` becomes a **consumer**
that builds `ThemeData` from a `BrandConfig`, exposed as a Riverpod provider
(`appThemeProvider`) watching `brandConfigProvider`. `App` watches that
provider instead of referencing `AppTheme.light`/`.dark` statics, and
`MaterialApp.title` reads `brand.displayName` instead of a literal.

**Rationale**: constitution §V says brand tokens "MUST be configurable per
deployment … never hardcoded in `app/theme/`". Today's
`const _seedColor = Colors.indigo` in `app_theme.dart:9` is a standing
violation of that rule (self-acknowledged in its own comment). This feature
necessarily touches that line, so fixing the seam properly — rather than
swapping one hardcoded constant for another — is the minimal
constitution-compliant change, not scope creep.

`BrandConfig` gains a `BRAND_SEED_COLOR` dart-define (hex string) alongside
the existing `BRAND_DISPLAY_NAME` / `BRAND_WELCOME_ASSET`, so a deployment
overriding the seed gets a wholly seed-derived scheme with **no XBE-specific
role pinning** — that pinning belongs to the XBE default palette only. This
is what makes FR-007's isolation guarantee true rather than aspirational.

---

## R7. Single source for the display name (FR-018)

**Decision**: `BrandConfig.defaultDisplayName` is the single Dart-side
constant; everything Dart-rendered (nav header, home welcome,
`MaterialApp.title`) reads it transitively. The five **native** touchpoints
cannot read Dart and are enumerated in one place —
[contracts/brand-tokens.md](./contracts/brand-tokens.md) — with their
current values, so a future rename is a documented five-line edit rather
than a repo-wide search.

**Rationale**: honest limitation. Android's `android:label`, iOS's
`CFBundleDisplayName`, `web/index.html`'s `<title>`, `web/manifest.json`'s
`name`/`short_name`, and the Apple web-app title are platform manifest
values resolved at build time by their own toolchains. A generator script to
sync them from Dart was considered and rejected as disproportionate for a
value that changes approximately never; a documented checklist achieves
FR-018's intent ("without touching every touchpoint individually" —
i.e. without hunting for them) at a fraction of the machinery.

**Per the resolved clarification**, all of these keep the value
**"Mictlanix Business Essentials"** — this feature changes the visual brand
only, not the product name.

---

## R8. Asset transfer from the design project

The brand assets live in the Claude Design project
`7a94cd32-a9e1-456c-b870-5730d4498e59` ("XBE Look and Feel proposal"). The
five SVGs are already retrieved verbatim; the PNG rasters are fetched from
the same project during implementation and written under `assets/brand/`
(SVG sources + in-app rasters) and the generator input paths above.

No asset is authored by hand — every file traces to the approved design
project, keeping the brand guide as the single upstream.
