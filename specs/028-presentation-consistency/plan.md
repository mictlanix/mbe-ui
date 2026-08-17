# Implementation Plan: Presentation Consistency — One Formatting Surface & Flex Spacing

**Branch**: `028-presentation-consistency` | **Date**: 2026-08-17 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/028-presentation-consistency/spec.md`

## Summary

Replace three divergent display-formatting implementations with one
`formattersProvider`-backed surface in `lib/core/formatting/`, migrate ≈79 call
sites to it, make its output configurable per deployment through build-time
keys on the existing `AppSettings`, and lock the result with a source-scanning
guard test. Separately and independently, convert `SizedBox` spacers to the
`Flex.spacing` property wherever every gap in a given `Row`/`Column` is the
same size.

The design was authored during spec 027 and descoped intact; Phase 0 carried it
forward and **re-verified it against the code**, which produced three
corrections that change implementation: the guard's allowlist misses the
generated localizations, the migration is one call site larger than audited,
and the ISO default is not the only rendering that changes — merging the two
percent paths changes output too, because they never agreed. See
[research.md](research.md) R2, R3 and R4.

## Technical Context

**Language/Version**: Dart SDK `^3.10.3`, Flutter 3.44.2 stable

**Primary Dependencies**: `flutter_riverpod` + `riverpod_generator`, `intl`,
`decimal`, `flutter_localizations`. **No new dependency** — the guard is a
plain `dart:io` test rather than a `custom_lint` rule (research R2).

**Storage**: None. Formatting configuration is build-time
(`--dart-define-from-file`), not persisted. No `shared_preferences` change —
user display preferences ship as 027 delivered them.

**Testing**: `flutter_test` for unit and widget tests; the existing golden
(`test/golden/`, 92 baselines) and screenshot (`test/screenshots/`, 8
baselines) suites; a source-scanning guard test following
`test/unit/core/layering_test.dart`.

**Target Platform**: Web/desktop-first, compact-ready (constitution §VI).

**Project Type**: Flutter application, feature-first layered (constitution §I).

**Performance Goals**: Eliminate per-cell formatter construction. A 50-row
table with 3 formatted columns currently builds ~150 formatters per frame; the
surface resolves once per build (research R1).

**Constraints**:
- The migration is **indivisible** — the guard is unsatisfiable until the last
  call site moves.
- Goldens are authoritative **in CI only**; a local `--update-goldens` is
  advisory (`test/golden/README.md`).
- **Zero backend dependency** — nothing here touches mbe-api.
- US2 must change no rendered pixel.

**Scale/Scope**: US1 — ≈79 call sites across ~26 files, 7 new deployment keys,
92+8 baselines re-recorded once. US2 — 85 candidate Flexes, ≥40 convertible
across 23 files.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Verdict |
|---|---|---|
| **I. Feature-First Layered Architecture** | Shared formatting must not be reached by a cross-feature `presentation` import | **PASS** — the surface lives in `lib/core/formatting/`, consumed by every module through DI. It removes an existing smell: `money.dart`'s display helpers sit in `features/sales/domain/` yet are read as general-purpose formatters. |
| **II. Riverpod for State & DI** | No second DI mechanism; providers overridable in tests | **PASS** — `formattersProvider` composes `appSettingsProvider` and the shipped `resolvedLocaleProvider`. A `BuildContext`-extension alternative was rejected for exactly this reason (research R1). |
| **III. Contract-Driven API Integration** | Codegen / entity mapping / `SystemObject` updates when mbe-api changes | **N/A** — no mbe-api change. No endpoint, DTO or RBAC object is touched. |
| **IV. Deny-by-Default RBAC** | New routes gated | **N/A** — no new route or screen. |
| **V. Material 3, White-Labeled Design System** | `intl` not manual string formatting; app settings build-time, documented in `.env.template`, fall back on malformed input, unreachable from UI; deployment config and personal preference kept distinct | **PASS on every clause** — and the feature exists to *restore* the first one, which `money.dart`'s hand-built `"16.00 %"` currently violates. Formatting is deployment-only, so the two configuration levels stay unblurred. |
| **V (pending amendment)** | The single-formatting-surface rule was drafted for v1.11.0 and **withheld** pending "the spec that builds the surface" | **THIS FEATURE** — FR-029 lands the amendment together with the code that satisfies it, per §Governance practice. |
| **VI. Desktop/Web-First, Compact-Ready Layout** | Layout changes must not clip or overflow at supported widths | **PASS** — US2's acceptance criterion is that no baseline moves at all. |
| **VII. Online-Only, Server-Rendered Documents** | — | **N/A** |
| **Tech Stack** | `intl` + `.arb`, `es-MX` default | **PASS** — `intl` remains the formatting engine; the ISO date default is an explicit `intl` pattern, and `es-MX` remains the default locale. |
| **Quality Gates** | Unit / widget / integration coverage | **PASS** — see research R8. Unit for the surface and the guard, widget for provider-driven rendering, goldens for appearance. |

**Post-Phase-1 re-check**: no gate changed. The design adds one `core/`
directory, one provider and seven documented settings keys; it introduces no
new dependency, no new DI mechanism, no new route, and no backend coupling.

**Violations**: none. Complexity Tracking is therefore empty.

## Project Structure

### Documentation (this feature)

```text
specs/028-presentation-consistency/
├── plan.md                              # This file
├── spec.md                              # Feature specification
├── research.md                          # Phase 0 — R1-R3 carried forward + corrected, R4-R8 new
├── data-model.md                        # Phase 1 — FormattingSettings, AppFormatters, allowlist, inventory
├── quickstart.md                        # Phase 1 — validation scenarios
├── contracts/
│   ├── formatting-surface.md            # Phase 1 — the display/field API + pattern reference
│   └── spacing-conversion.md            # Phase 1 — the US2 rubric
├── checklists/
│   └── requirements.md                  # Spec quality checklist (passed)
└── tasks.md                             # Phase 2 — NOT created by /speckit-plan
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── formatting/                      # NEW — the surface
│   │   ├── app_formatters.dart          #   display.* / field.* value object
│   │   └── formatters_provider.dart     #   formattersProvider
│   ├── config/
│   │   ├── app_settings.dart            # + FormattingSettings field
│   │   └── app_settings_provider.dart   # unchanged
│   ├── settings/                        # unchanged — 027's user prefs stay as shipped
│   │   └── user_display_preferences_controller.dart   # resolvedLocaleProvider (consumed)
│   ├── design/spacing.dart              # unchanged — tokens deliberately not adopted (US2)
│   └── widgets/
│       └── money_formatters.dart        # DELETED at the end of US1
├── features/
│   ├── sales/
│   │   ├── domain/money.dart            # display helpers REMOVED; decimal arithmetic STAYS (research R6)
│   │   └── presentation/
│   │       ├── pos_sales_list_controller.dart      # _dateFacetFormat — exempt, unchanged
│   │       └── capture/sale_line_card.dart         # US2 worked example
│   ├── catalog/presentation/
│   │   └── taxpayer_certificates_section.dart      # inline DateFormat.yMd() → display.date
│   └── pricing/presentation/                        # MoneyFormatters call sites
└── l10n/app_localizations*.dart          # generated; ALLOWLISTED (research R2 correction)

test/
├── unit/core/
│   ├── formatting/                      # NEW — surface unit + round-trip property tests
│   ├── formatting_guard_test.dart       # NEW — lands LAST (research R8)
│   └── layering_test.dart               # precedent the guard follows
├── golden/                              # 92 baselines — re-recorded once in US1
└── screenshots/                         # 8 baselines — re-recorded once in US1

.env.template                            # + 7 formatting keys with worked examples (FR-014)
.specify/memory/constitution.md          # + §V single-formatting-surface rule (FR-029)
```

**Structure Decision**: The formatting surface is new shared infrastructure, so
it takes a new `lib/core/formatting/` directory rather than extending
`lib/core/widgets/`. This is not a §VI conflict: §VI requires shared *formatted
fields* — widgets — to live in `core/widgets/`, and `AppFormatters` is a value
object, not a widget. `MoneyFormatters` sits under `widgets/` today because
spec 021 promoted it there when a second feature needed it (its own docstring
records the reasoning), which was the closest available home at the time rather
than a considered placement. Everything else in the tree is
existing code being migrated, deleted, or left deliberately alone. The two user
stories touch disjoint files apart from `sale_line_card.dart`, which US1 touches
for formatting and US2 for layout — sequence them in that order within that one
file to avoid a conflict.

## Complexity Tracking

> No Constitution Check violations. Nothing to justify.

## Phase Status

| Phase | Output | State |
|---|---|---|
| Phase 0 — Research | [research.md](research.md) | ✅ Complete — 3 corrections found while re-verifying |
| Phase 1 — Design | [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md) | ✅ Complete |
| Phase 2 — Tasks | `tasks.md` | ⏳ Not started — run `/speckit-tasks` |

**No unresolved NEEDS CLARIFICATION.** The two decisions that would have
produced them were settled with the user before the spec was written and are
recorded in its Clarifications section.
