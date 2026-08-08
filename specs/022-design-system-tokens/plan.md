# Implementation Plan: Design System Tokens & Component Theming

**Branch**: `022-design-system-tokens` | **Date**: 2026-08-08 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/022-design-system-tokens/spec.md`

## Summary

Close the five missing layers of the design system — semantic type roles, spacing, shape,
elevation and density — and move component appearance out of individual screens into 17
Material 3 sub-themes. Token values are decided for all four width tiers so phone and
tablet need no renegotiation later, while phone-specific *layouts* stay out of scope.

The technical approach turns on one decision (research R1): the width tier is resolved in
`MaterialApp.builder` and a tier-resolved `ThemeData` is re-applied there. This is what
lets component sub-themes vary by tier at all — they are `ThemeData` fields and cannot vary
per-context otherwise — and it lets every token accessor return a plain resolved value
rather than a function of `BuildContext`. Product tokens live in a new `lib/core/design/`
whose classes take no `BrandConfig` parameter, making "structure is not brandable"
(constitution §V) true by construction rather than by review.

Two of the spec's stated assumptions were wrong and are corrected here: `navigationModeOf`
does not carry touch-vs-pointer (R2), and the deployment contrast gate cannot be a build
hook (R6).

## Technical Context

**Language/Version**: Dart 3.10.3 / Flutter 3.44.2 (stable, verified)

**Primary Dependencies**: Flutter Material 3 (`useMaterial3: true`), `flutter_riverpod` 2.6
(theme provider), `data_table_2` 2.7.2 (honors `DataTableThemeData` partially — research R5),
`shared_preferences` (theme mode). **No new runtime dependencies.**

**Storage**: N/A — tokens are compile-time constants. Theme mode persistence is unchanged.

**Testing**: `flutter_test`, `mocktail`. Golden images via built-in `matchesGoldenFile`
plus a local harness in `test/golden/` — **no new dev dependency** (research R4).

**Target Platform**: Web, macOS, Windows, Linux, Android, iOS. Density derives from
`defaultTargetPlatform`; layout tier derives from width.

**Project Type**: Flutter application, feature-first layered (constitution §I)

**Performance Goals**: Tier change must not drop frames. `ThemeData` is memoized per
`(brightness, tier)` — at most 8 instances — so only a tier-boundary crossing rebuilds.

**Constraints**: Spec 019 FR-007 white-label isolation must survive intact. Nothing in
`lib/features/` or `lib/core/` may import `lib/app/` (verified true today). No structural
value may be per-deployment configurable.

**Scale/Scope**: ~20 shared widgets in `lib/core/widgets/`, 18 record detail screens,
5 new token files, 17 component sub-themes, ~80 golden images (20 controls × 4 combinations).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Assessment | Verdict |
|---|---|---|
| **I. Feature-First Layered Architecture** | `lib/core/design/` sits under `core/`, importable by features. Imports nothing from `lib/app/`. No feature-to-feature coupling introduced. | **PASS** |
| **II. Riverpod for State & DI** | `appThemeProvider` unchanged. Tier resolution is a widget-tree concern (`MaterialApp.builder`), not app state — correctly not a provider. | **PASS** |
| **III. Contract-Driven API Integration** | No API surface touched. | **N/A** |
| **IV. Deny-by-Default RBAC** | No authorization surface touched. | **N/A** |
| **V. Material 3, White-Labeled Design System** | M3 exclusively; no Cupertino branch. Both `ColorScheme`s still derive from one seed via `fromSeed` — untouched. Brand tokens stay per-deployment; product tokens explicitly are not. See the note below on shape overrides. | **PASS** |
| **VI. Desktop/Web-First, Compact-Ready** | Expanded remains the primary target. Breakpoints stay centralized in `core/layout/`. Compact **layouts** explicitly deferred (`FR-025`), so §VI's deferral is preserved, not amended. Shared table/badge/form ownership in `core/widgets/` is strengthened by `FR-018`. | **PASS** |
| **VII. Online-Only, Server-Rendered Documents** | Not touched. | **N/A** |

**Note on §V and the card shape override.** §V says all UI stays "within Material 3
component shapes/structure regardless of theme — customization is limited to color scheme,
typography, and branding assets, not layout/structure." This feature overrides
`CardThemeData.shape` from Flutter's 12 to the brand guide's 16. That is **not** a §V
violation: §V constrains *per-deployment* customization, and this override is applied
product-wide, identically for every deployment, as part of the product's own M3 theming.
The clause it must satisfy — that a customer cannot alter structure — is satisfied more
strictly than before, because `lib/core/design/` accepts no brand input at all.

**Post-Phase 1 re-check**: no gate changed. The design adds no new project, no new runtime
dependency, and no new state management mechanism. Complexity Tracking is therefore empty.

## Project Structure

### Documentation (this feature)

```text
specs/022-design-system-tokens/
├── plan.md              # This file
├── spec.md              # Feature specification (28 FRs, 11 SCs)
├── research.md          # Phase 0 — R1..R8
├── data-model.md        # Phase 1 — token entities with concrete values
├── quickstart.md        # Phase 1 — 7 runnable validation scenarios
├── contracts/
│   └── design-tokens.md # Phase 1 — token API + sub-theme ownership
├── checklists/
│   └── requirements.md  # Spec quality checklist (16/16)
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── design/                      # NEW — product tokens, no brand input
│   │   ├── spacing.dart             #   Spacing      (ThemeExtension)
│   │   ├── shapes.dart              #   Shapes       (ThemeExtension)
│   │   ├── elevations.dart          #   Elevations   (ThemeExtension)
│   │   ├── density.dart             #   Density      (platform-derived)
│   │   ├── type_roles.dart          #   TypeRoles    (slot → M3 role, per tier)
│   │   └── design_theme.dart        #   DesignTheme.forTier(base, tier) + memoization
│   ├── branding/                    # EXISTING — brand tokens, unchanged
│   │   ├── xbe_palette.dart
│   │   ├── brand_ink.dart
│   │   └── brand_config.dart
│   ├── layout/breakpoints.dart      # EXISTING — reused unchanged
│   └── widgets/                     # ~20 shared components; status chip consolidated
│       └── status_chip.dart         # NEW — replaces the two near-duplicates (FR-018)
├── app/theme/
│   └── app_theme.dart               # Assembles ColorScheme + TextTheme + 17 sub-themes
└── app/app.dart                     # MaterialApp.builder applies the tier-resolved theme

test/
├── unit/core/design/                # token invariants, brand-independence (SC-008)
├── widget/app/app_theme_test.dart   # EXISTING — extended for FR-001/002
├── widget/core/design/              # tier resolution
├── golden/                          # NEW — harness + ~80 images, FontLoader setup
└── contract/
    └── brand_contrast_test.dart     # NEW — the deployment gate (FR-027)
```

**Structure Decision**: The repository's existing feature-first layout is unchanged. The
one addition is `lib/core/design/`, deliberately a sibling of `lib/core/branding/` rather
than a subdirectory of it — the split *is* the enforcement of `FR-010`/`FR-011`, since
product tokens take no `BrandConfig` and brand tokens do. `lib/app/theme/` remains the sole
assembly point, and `lib/app/app.dart` gains the tier-resolving `builder`.

## Implementation Sequencing

Derived from the story priorities, with two hard orderings that are not negotiable:

1. **`FR-002` before any elevation work** — `Elevations.raised` maps to
   `surfaceContainerLow`, which today resolves to an unapproved seed-derived value in light
   mode. Building elevation on it first would bake in the wrong colour.
2. **`FR-021`: goldens exist and pass before the first sub-theme lands** — a
   `CardThemeData` change restyles 18 screens at once. Without the net, the blast radius is
   invisible.

| Phase | Stories | Content | Risk |
|---|---|---|---|
| A | US1 | Text ink fix, light `surfaceContainerLow` pin | Low, visible |
| B | US2 | `core/design/` tokens + `DesignTheme.forTier` + `MaterialApp.builder`; no call-site change | Very low — additive |
| C | US3 | Golden harness, `FontLoader` setup, ~80 baseline images | Low; **gates phase D** |
| D | US4 | 17 sub-themes; status chip consolidation | **Highest** — product-wide visual change |
| E | US5 | Type roles applied; retire 5 typeface + 3 size literals; correct spec 019's typography contract | Low |
| F | US6 | Tier-response verification across all four tiers | Low |

Phase A can ship on its own. Phase D must not start before Phase C is green.

## Complexity Tracking

No constitutional violations require justification. This section is intentionally empty.
