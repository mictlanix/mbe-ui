# Implementation Plan: XBE Default Branding

**Branch**: `019-xbe-default-branding` | **Date**: 2026-07-28 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/019-xbe-default-branding/spec.md`

## Summary

Replace the app's unbranded defaults with the approved XBE Business
Essentials identity, for builds that set no per-deployment brand override.
Three deliverables: (1) a brand color scheme + Archivo/Roboto/Roboto Mono
typography, (2) native app icons, splash, and web favicon/PWA metadata, and
(3) correct logo placement on login and navigation.

The technical approach keeps the constitution's white-labeling seam intact
by moving brand tokens **out of** `app/theme/` and into `core/branding/`,
where the existing `BrandConfig` already resolves `--dart-define` values.
`ColorScheme.fromSeed` remains the derivation mechanism for both
brightnesses from one gold seed; the brand's Pantone-exact roles are applied
through `fromSeed`'s own per-role override parameters (verified present in
Flutter 3.44.2), so brand fidelity costs nothing in §V compliance. No screen
layout or information architecture changes.

## Technical Context

**Language/Version**: Dart (SDK `^3.10.3`) / Flutter 3.44.2 stable

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation`
(state/DI), `shared_preferences` (theme mode). **New dev-only**:
`flutter_launcher_icons`, `flutter_native_splash`. **No new runtime
dependencies** — fonts are bundled and logos render from raster assets
(research R3, R4).

**Storage**: N/A — no persisted data. Existing `shared_preferences` theme-mode
key is untouched.

**Testing**: `flutter_test` (153 existing tests: `test/unit/`, `test/widget/`,
`test/integration/`), `mocktail`. New coverage is widget-level.

**Target Platform**: Web (primary), Android, iOS, macOS, Windows, Linux —
all six present in the repo.

**Project Type**: Single Flutter application, feature-first layering.

**Performance Goals**: No runtime cost. Theme is resolved once at startup;
fonts are bundled so there is no first-run network fetch or fallback flash.

**Constraints**: Brand red is reserved for error/critical states only
(FR-009). Logo hard minimums (51 px lockup / 37 px mark) must hold in every
placement. Existing per-deployment overrides must remain fully isolated
from the new defaults (FR-007).

**Scale/Scope**: ~20 screens inherit the theme automatically; 3 files gain
explicit logo placements (login, nav shell, home welcome); 5 native manifest
touchpoints; ~10 new asset files.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| **I. Feature-First Layered Architecture** | ✅ PASS | Brand tokens in `core/branding/` (shared kernel), theme assembly in `app/theme/`. No feature module gains brand knowledge; all read one provider. |
| **II. Riverpod for State/DI** | ✅ PASS | New `appThemeProvider` derives from the existing `brandConfigProvider`. No new DI mechanism. Overridable in tests, which is how FR-007 is verified. |
| **III. Contract-Driven API** | ✅ N/A | No API surface, no codegen, no mbe-api dependency. |
| **IV. Deny-by-Default RBAC** | ✅ N/A | No new routes or mutable actions. |
| **V. Material 3, White-Labeled Design System** | ✅ PASS *(fixes an existing violation)* | Both schemes derive from **one** seed via `ColorScheme.fromSeed` ✓. Light/Dark/System persisted ✓. Material 3 only, no Cupertino ✓. i18n untouched ✓. **Removes** the standing violation at `app_theme.dart:9` (`const _seedColor = Colors.indigo` hardcoded in `app/theme/`) by relocating tokens to `core/branding/` behind dart-defines. See Complexity Tracking for the role-pinning nuance. |
| **VI. Desktop/Web-First Layout** | ✅ PASS | No layout, table, row-action, form-grid, or `AppBar.actions` changes. FR-011 forbids structural change explicitly. The nav header gains a logo + name block above the existing destination tree — an additive branding placement, not a change to navigation structure or behavior. |
| **VII. Online-Only, Server-Rendered Documents** | ✅ PASS | Reinforced: bundling fonts avoids a runtime fetch from a third-party host (research R3). PDF/print branding is explicitly out of scope (spec Assumptions) since mbe-api owns document rendering. |

**Tech stack defaults**: unchanged. The two new packages are `dev_dependencies`
(build-time codegen) and ship no runtime code.

**Gate result**: PASS — no unjustified violations. One transparency entry
recorded below.

## Project Structure

### Documentation (this feature)

```text
specs/019-xbe-default-branding/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output — 8 resolved decisions
├── data-model.md        # Phase 1 output — config/theme entities
├── quickstart.md        # Phase 1 output — validation guide
├── contracts/
│   ├── brand-tokens.md  # Dart-define surface, color/type/logo contracts
│   └── brand-assets.md  # Asset inventory & variant selection rules
├── checklists/
│   └── requirements.md  # Spec quality checklist (passing)
└── tasks.md             # Phase 2 — created by /speckit-tasks, NOT here
```

### Source Code (repository root)

```text
lib/
├── core/branding/
│   ├── brand_config.dart           # MODIFIED — + seedColor, lockup/mark assets
│   ├── brand_config_provider.dart  # unchanged
│   └── xbe_palette.dart            # NEW — brand tokens + placement constants
├── core/widgets/
│   ├── app_shell.dart              # unchanged
│   ├── app_navigation.dart         # MODIFIED — brand header (mark + name)
│   └── brand_logo.dart             # NEW — variant/min-size/clear-space rules
├── app/
│   ├── app.dart                    # MODIFIED — watch appThemeProvider, brand title
│   └── theme/app_theme.dart        # MODIFIED — brand-driven builder, no constants
└── features/
    ├── auth/presentation/login/login_screen.dart   # MODIFIED — lockup above title
    └── home/presentation/home_welcome.dart         # unchanged (already brand-aware)

assets/
├── brand/      # NEW — SVG sources + 1x/2x/3x rasters
├── fonts/      # NEW — Archivo, Roboto Mono (bundled, OFL)
├── icons_src/  # NEW — generator inputs (not shipped in bundle)
└── branding/   # EXISTING — default_welcome.png

web/            # MODIFIED — favicon, icons/, manifest.json, index.html
android/ ios/ macos/ windows/   # MODIFIED — generated icons/splash + labels

test/widget/
├── core/widgets/brand_logo_test.dart    # NEW — min sizes, variant selection
└── app/app_theme_test.dart              # NEW — default vs. overridden palette
```

**Structure Decision**: Single Flutter application, feature-first layering
(matching every prior spec in this repo). Brand tokens live in the shared
kernel `lib/core/branding/` per constitution §I and §V; the reusable
`BrandLogo` widget lives in `lib/core/widgets/` per §VI's rule that shared
presentation components are implemented once, not per module.

## Implementation Phases

Each phase maps to spec user stories and is independently shippable.

**Phase A — Brand palette & typography** (US1, FR-001/002/008/009)
Extend `BrandConfig`; add `xbe_palette.dart`; convert `AppTheme` to a
brand-driven builder behind `appThemeProvider`; bundle Archivo + Roboto Mono
and map the Archivo text roles. Verify: full test suite green, both themes
render, Light/Dark/System still switches.

**Phase B — Icons, splash & web metadata** (US2, FR-005/006)
Import raster sources; add the two dev dependencies and their config; run
both generators; commit native outputs; replace web icons and update
`manifest.json`/`index.html`; correct the Android/iOS labels. Verify: fresh
install shows branded icon + splash; web tab shows branded favicon/title.

**Phase C — Logo placement** (US3, FR-003/004/010)
Add `BrandLogo` encapsulating variant selection, minimum sizes, and clear
space; place the lockup on login and the mark + name in the nav header.
Verify: widget tests assert minimums and variant-per-background.

**Phase D — Isolation & regression** (US4, FR-007/011/013)
Widget tests overriding `brandConfigProvider` prove an overridden seed yields
a purely seed-derived scheme with zero XBE pins; confirm no layout diffs.

## Complexity Tracking

> Recorded for transparency. The gate passes; this entry documents a nuance
> a reviewer should see rather than an unjustified deviation.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Dark scheme pins ~16 color roles to literal brand values rather than accepting every algorithmically-derived tone | The corporate palette is Pantone-specified (124 C / 165 C / 1795 C). Material's tonal algorithm shifts these measurably off their approved equivalents, so a purely derived scheme would not be the approved brand. Pins are applied **through** `ColorScheme.fromSeed`'s own role-override parameters, so §V's "derived from the same seed via `fromSeed`" holds mechanically and one seed remains the per-deployment knob. | Pure `fromSeed` with no overrides produces colors that are visibly not the approved corporate palette — failing the feature's entire purpose. Hand-authored `const ColorScheme.dark(...)` (what the design doc's own snippet does) would abandon the seed and genuinely break §V. Pins apply **only** to the XBE default palette: any deployment setting `BRAND_SEED_COLOR` gets a wholly derived scheme, so white-labeling is strictly unaffected. |
