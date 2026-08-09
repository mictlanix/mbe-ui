# Phase 0 Research: Design System Tokens & Component Theming

**Feature**: 022-design-system-tokens | **Date**: 2026-08-08

Resolves the technical unknowns in [plan.md](./plan.md)'s Technical Context and the
items [spec.md](./spec.md) deferred to planning. Every SDK claim below was verified
against the installed Flutter 3.44.2 checkout, not recalled.

---

## R1. Where per-tier theming is applied (the crux)

**Question**: `FR-012`/`FR-013` require spacing, density and component appearance to
differ by width tier. But `ThemeData` is built once by `appThemeProvider` and handed
to `MaterialApp.theme`/`.darkTheme`, while the width tier is only knowable from a
`BuildContext` below `MediaQuery`. Component sub-themes (`VisualDensity`,
`InputDecorationTheme.isDense`, `DataTableThemeData` row heights, per-tier button
padding) live *inside* `ThemeData`, so they cannot vary per-context by default.

**Decision**: Resolve the tier in `MaterialApp.builder` and re-apply a tier-resolved
`ThemeData` there:

```
MaterialApp(
  theme: appTheme.light,          // tier-agnostic base
  darkTheme: appTheme.dark,
  builder: (context, child) {
    final tier = LayoutBreakpoints.tierOfContext(context);
    return Theme(
      data: DesignTheme.forTier(Theme.of(context), tier),
      child: child!,
    );
  },
)
```

`MaterialApp` inserts its own `MediaQuery` above `builder`, so the builder's context
has the window size; and because `builder` wraps the `Navigator`, every route, dialog,
overlay and sheet pushed below it inherits the tier-resolved theme.

**Consequences, all of which are wins**:

- Token accessors return **plain resolved values** — `Theme.of(context).spacing.screenMargin`
  is a `double`, not a function of context. This is what makes `FR-009` ergonomic enough
  that developers actually use it instead of typing a literal.
- Component sub-themes become tier-aware for free, satisfying `FR-013` without any
  widget re-plumbing.
- Golden tests get the right tier simply by pumping at a given surface size — no test-only
  branch.

**Cost and mitigation**: a resize rebuilds `ThemeData`. The tier is one of four enum
values, so memoize per `(brightness, tier)` — at most eight instances for the lifetime of
a brand config. Without the cache this rebuilds a large object on every resize frame.

**Alternatives considered**:

- *Tokens hold all four tiers; every accessor takes a `BuildContext`* — rejected: it
  cannot carry component sub-themes at all (they are `ThemeData` fields), so `FR-013`
  would go unmet, and `theme.spacing.screenMargin(context)` at every call site is exactly
  the friction that causes people to type `16` instead.
- *A separate `InheritedWidget` for layout metrics beside the theme* — rejected:
  two parallel lookup mechanisms for one design system, and it still cannot reach
  sub-themes. Violates the single-source intent of `FR-009`.

---

## R2. Input-modality signal for density — spec assumption corrected

**Question**: `FR-007` and the spec's Assumptions say density is chosen by input
modality, "derived from `MediaQuery.navigationModeOf` / pointer device kind".

**Finding — the assumed API is the wrong one.** `MediaQuery.navigationModeOf` returns
`NavigationMode.traditional` / `.directional`
(`packages/flutter/lib/src/widgets/media_query.dart:2252`). Its documented meaning is
whether arrow keys are reserved for navigation and whether disabled controls stay
focusable — a **keyboard traversal** concern. It reports nothing about touch versus
pointer, and it would not distinguish a touch tablet from a desktop.

**Decision**: use `VisualDensity.adaptivePlatformDensity`, Flutter's own idiom for this
(`material/theme_data.dart:3240`). It delegates to `defaultDensityForPlatform`, which
returns `standard` for Android/iOS/Fuchsia and `compact` for Linux/macOS/Windows. On web,
`defaultTargetPlatform` reports the *host* platform, so a desktop browser correctly gets
`compact` and a mobile browser `standard`.

Minimum interactive-target sizes ride the same platform signal: 48 on the touch
platforms, 40 on the pointer platforms.

**Consequence for the spec's edge case** "a large touch tablet whose width falls in the
desktop range": it resolves **correctly and for a better reason than the spec assumed** —
an Android/iOS tablet reports a mobile platform, so it gets touch density regardless of how
wide it is. Density is therefore keyed on **platform**, not width and not navigation mode.
Width still drives spacing and layout (R1); the two signals are deliberately independent.

**Alternative considered**: `RendererBinding.instance.mouseTracker.mouseIsConnected` —
rejected as the primary signal: it changes at runtime when a mouse is plugged in or a
Bluetooth mouse sleeps, which would make controls resize under the user's hands. It is a
reasonable future refinement, not a foundation.

---

## R3. Shape scale delivery

**Question**: how is a corner-radius scale (`FR-005`) expressed?

**Finding**: Flutter has **no `ShapeScheme` on `ThemeData`** — verified by searching the
material library. M3 corner radii are baked into each component's own defaults: `Card`
12.0 (`card.dart:322`), `Chip` 8.0 (`chip.dart:2499`), `Dialog` 28.0 (`dialog.dart:1967`),
buttons `StadiumBorder`.

**Decision**: a `Shapes` `ThemeExtension` holding the seven named radii, consumed by the
component sub-themes in `FR-016`. There is no built-in slot to fill, so the sub-themes are
the only mechanism by which a shape token reaches a rendered widget.

**Note on the brand deviation**: cards move from Flutter's `medium` (12) to `large` (16)
per the Verbatim Constraint. That is a `CardThemeData.shape` override, applied product-wide
and identically for every deployment — see the Constitution Check in plan.md for why this
is not a §V "layout/structure customization" violation.

---

## R4. Golden-image tooling

**Question**: the spec explicitly defers the choice (`FR-020`, `FR-023`). The repo has no
golden infrastructure today; `dev_dependencies` are `flutter_test`, `flutter_driver`,
`flutter_lints`, `build_runner`, `freezed`, `json_serializable`, `riverpod_generator`,
`mocktail`, plus the icon/splash generators.

**Decision**: use **`flutter_test`'s built-in `matchesGoldenFile`** with a small local
harness in `test/golden/`, rather than adding a third-party golden package.

**Rationale**:

- Zero new dependencies. The matrix this feature needs — light/dark × narrow/wide — is a
  four-iteration loop over `pumpWidget`, not a feature that justifies a dependency.
- The harness must set the surface size anyway to exercise R1's tier resolution, which is
  the same code a third-party wrapper would call.
- No exposure to a golden package being abandoned mid-feature, which has happened
  repeatedly in this corner of the ecosystem.

**Known risk — fonts.** Golden tests render text as placeholder boxes when the custom font
is not loaded into the test binary, which would make every Archivo heading meaningless in a
golden. **Mitigation**: the harness explicitly loads `Archivo-Variable.ttf` and
`RobotoMono-Variable.ttf` via `FontLoader` in `setUpAll`, rather than assuming the test
runner picks them up from the pubspec font manifest. This is a required task, not a
nice-to-have — a golden suite that silently renders boxes would pass `FR-020` while
verifying nothing.

**Second risk — host dependence.** Goldens differ subtly across platforms and Flutter
versions. **Mitigation**: goldens are generated and verified on one designated
platform/version in CI; local `--update-goldens` runs are advisory. Record the generating
Flutter version alongside the goldens.

**Alternative considered**: `alchemist` and `golden_toolkit` — not adopted. Their main
value is CI/host-independent rendering, which the single-designated-CI-platform rule
already buys us without a dependency. This can be revisited if goldens prove flaky across
contributors' machines.

---

## R5. `data_table_2` theming coverage

**Question**: how much of `DataTableThemeData` does the table package honor
(`FR-016`)? Version in use: `data_table_2 2.7.2`.

**Finding**: it reads `DataTableTheme.of(context)` directly
(`lib/src/data_table_2.dart:386`) and falls back to it for `dataTextStyle`,
`headingTextStyle`, `headingRowColor`, `headingCheckboxTheme`, and
`dataRowMinHeight` (`data_table_2.dart:295, 362-364`). However `DataTable2` also carries
its **own** `dataRowHeight`, `headingRowHeight` and `dividerThickness` constructor
parameters with hardcoded defaults (`_headingRowHeight = 56.0`,
`_dividerThickness = 1.0`).

**Decision**: split responsibility.

- Text styles and colors go in `DataTableThemeData` and are inherited automatically.
- Row heights and divider thickness are passed explicitly by the shared
  `core/widgets/data_table_view.dart` wrapper, reading them from the tier-resolved
  `Density` token.

Because every table in the product already goes through that one wrapper (constitution
§VI), this stays a single edit rather than a per-screen concern — no screen passes heights
itself.

---

## R6. Enforcing the contrast gate (`FR-027`)

**Question**: `FR-027` requires a deployment build to **fail** when its brand color cannot
meet foreground contrast. Flutter has no build-time hook that can evaluate this: brand
values arrive as `--dart-define` compile-time constants read through
`String.fromEnvironment`, which nothing outside the compiled app can inspect.

**Decision**: the gate is a **test executed with the same `--dart-define` values, run by
the deployment pipeline immediately before `flutter build`**. A non-zero exit fails the
deployment.

```
flutter test test/contract/brand_contrast_test.dart \
  --dart-define=BRAND_SEED_COLOR=$SEED
flutter build web --dart-define=BRAND_SEED_COLOR=$SEED
```

The test builds the real `AppTheme` from `BrandConfig.fromEnvironment()` and asserts every
foreground role clears 4.5:1 against the surface it renders on, in both brightnesses.

**Rationale**: it reuses the exact resolution path the app uses, so it cannot drift from
what actually renders. Its correctness depends on the pipeline passing identical defines
to both commands — a real coupling, documented in `quickstart.md` and enforced by keeping
both commands in one pipeline script rather than two.

**Alternatives considered**:

- *An `assert` in `BrandConfig`* — rejected: asserts are stripped from release builds, so
  the one build that matters would not check.
- *A standalone script parsing the hex before the build* — rejected: it would reimplement
  `ColorScheme.fromSeed`'s derivation to guess the resulting roles, and would drift from
  the framework's actual output on any Flutter upgrade.

---

## R7. Archivo tracking measurement

**Question**: the spec defers the letter-spacing corrections for `display*` /
`headlineLarge` at w700 to planning, requiring measurement rather than invention.

**Decision**: a bounded measurement task, not a research unknown. Render the brand guide's
own headline strings — the login tagline and the section headings from
`artifacts/branding/XBE Look and Feel.dc.html` — at the M3 sizes in Archivo w700, and
compare against the guide's rendering at the same nominal size. Record the delta per role
in `contracts/type-roles.md`. Until measured, roles keep M3 tracking unchanged; shipping M3
tracking is a correct, conservative default, so this never blocks the token work.

**Note**: the guide's own headings carry `letter-spacing: -0.02em` on the 56 px display
and none on the 32 px section headings, which suggests the correction is confined to the
largest one or two roles rather than the whole ramp.

---

## R8. Token organization and the out-of-theme fallback

**Question**: how do `FR-010`/`FR-011` (product tokens not customizable, and structurally
evident) and `FR-024` (sensible fallback outside the product theme) get satisfied together?

**Decision**:

- `lib/core/design/` holds `Spacing`, `Shapes`, `Elevations`, `Density`, `TypeRoles` — all
  `ThemeExtension`s built from **const** defaults with no `BrandConfig` input at all. The
  absence of a brand parameter in their constructors is what makes `FR-010` structurally
  true rather than a documented promise: there is no seam through which a deployment could
  override them.
- `lib/core/branding/` keeps `XbePalette`, `BrandInk`, `BrandConfig` — everything that
  *does* take a brand.
- Each extension gets a `ThemeData` getter mirroring the shipped `BrandInk` pattern, falling
  back to the const default when the extension is absent:
  `Spacing get spacing => extension<Spacing>() ?? const Spacing.standard();` This satisfies
  `FR-024` and keeps a bare `ThemeData` in a widget test from crashing.

This also preserves constitution §I: `lib/core/design/` is under `core/`, so features may
import it, and it imports nothing from `lib/app/` — verified true of the current tree.
