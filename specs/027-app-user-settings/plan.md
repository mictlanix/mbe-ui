# Implementation Plan: App Settings, User Settings & Cross-Widget Consistency

**Branch**: `027-app-user-settings` | **Date**: 2026-08-16 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/027-app-user-settings/spec.md`

## Summary

Three consistency gaps — divergent value formatting, list screens that ignore
the catalog structure, and asymmetric padding — resolved by introducing the
two configuration levels the app never had, and by fixing the three screens
that motivated the complaint.

The technical spine is **one formatting surface** (`formattersProvider`,
derived from `AppSettings` + the resolved locale) replacing ~78 call sites
across `MoneyFormatters`, the `money.dart` display helpers and one inline
`DateFormat`; a **build-time `AppSettings`** consolidating the four scattered
`fromEnvironment` sites and adding formatting/locale keys, all defaulting to
today's exact rendering; and **device-local `UserDisplayPreferences`**
(appearance, four text-size levels, language) on a new settings screen, loaded
before `runApp` so the first frame is already correct. On top of that:
`pos_sales_list_screen` moves its facets into the shared filter drawer,
`cash_sessions_screen` moves its shift form into a sheet whose toolbar action
carries the shift state, and the POS sale line gets symmetric insets with its
control band on the line total's baseline.

No mbe-api change. Constitution amended to v1.11.0 in the same change.

## Technical Context

**Language/Version**: Dart 3 / Flutter (repo toolchain)

**Primary Dependencies**: `flutter_riverpod`, `intl`, `shared_preferences`,
`go_router`, `decimal`, `data_table_2` — **no new dependency**. `flutter_dotenv`
was considered and rejected (research R7).

**Storage**: `shared_preferences` for device-local display preferences.
Build-time `--dart-define-from-file=.env` for deployment configuration.
No mbe-api persistence.

**Testing**: `flutter_test` — unit, widget, golden and screenshot suites,
plus source-scanning tests following the existing `layering_test.dart` /
`l10n_parity_test.dart` precedent.

**Target Platform**: desktop/web first (Expanded tier), compact-ready.

**Project Type**: single Flutter application.

**Performance Goals**: no regression. The formatting change is a net
improvement — today a 50-row × 3-formatted-column table constructs ~150
`NumberFormat`/`DateFormat` instances per frame; pre-built formatters resolved
once per build eliminate that.

**Constraints**:
- Golden and screenshot baselines must not need re-baselining — the default
  text-size level is the identity composition (research R1).
- `PHOTOS_BASE_URL` defaults to `API_BASE_URL`, a const cross-reference: both
  must stay compile-time constants (research R7).
- Existing `theme_mode` preference key must be reused so stored choices
  survive (FR-017).
- Every new app-settings default must reproduce current rendering
  byte-for-byte.
- `.env` is gitignored and already owned by integration-test credentials;
  deployment configuration gets its own per-customer file using the same
  mechanism, with `.env.template` documenting both (research R11). Tests that
  assert formatted output override `appSettingsProvider` rather than inherit a
  developer's local `.env`.

**Scale/Scope**: ~78 formatting call sites across 22 files; 17 list screens
audited (2 non-compliant, 1 of them out of scope); 1 new screen; 3 screens
remediated; 1 shared sheet shell extracted; 1 constitution amendment.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Checked against constitution **v1.11.0** — which this feature itself
authored, so the check is also a self-consistency check on the amendment.

| Principle | Gate | Status |
|---|---|---|
| **I. Feature-first layered architecture** | Shared formatting/settings live in `core/`, not reached cross-feature through `presentation/` | ✅ `core/formatting/`, `core/config/`. This is the rule that forced `MoneyFormatters` out of `pricing/presentation` originally; the same logic applies to `money.dart`'s display helpers, which currently sit in `features/sales/domain/` |
| **II. Riverpod for state & DI** | New state exposed as providers, overridable in tests | ✅ `appSettingsProvider`, `formattersProvider`, `userDisplayPreferencesProvider`, `sharedPreferencesProvider`. No second DI mechanism — a `BuildContext` extension was rejected for this reason (research R3) |
| **III. Contract-driven API integration** | No hand-written DTOs; no mbe-api edit | ✅ N/A — zero backend surface (SC-011) |
| **IV. Deny-by-default RBAC** | Every mutable action gated | ✅ Settings screen is deliberately ungated (personal preferences, constitution §V). The cash-sessions toolbar action stays gated on `pos:create` and is **absent**, not disabled, without it |
| **V. Material 3, white-labeled** | Brand tokens build-time; one formatting surface; two config levels; four text sizes | ✅ This feature implements the v1.11.0 rules. `BrandConfig` is composed unchanged, preserving spec 019's `usesDefaultPalette` semantics |
| **VI. Desktop/web-first layout** | Filters behind the drawer; no form above a list; symmetry/baselines from tokens, asserted by measuring tests | ✅ US4/US5/US6 |
| **VII. Online-only** | No offline storage or caching | ⚠️ **Justified, see Complexity Tracking** — `shared_preferences` stores display preferences locally |

**Post-Phase-1 re-check**: no gate changed. The Phase 1 design added the
shared sheet shell (§VI-consistent: one shared component rather than a second
sheet implementation) and the `sharedPreferencesProvider` override (§II).

## Project Structure

### Documentation (this feature)

```text
specs/027-app-user-settings/
├── plan.md              # This file
├── spec.md
├── research.md          # Phase 0 — R1..R10, all unknowns resolved
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/           # Phase 1
│   ├── formatting-surface.md
│   ├── app-and-user-settings.md
│   └── screen-structure.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 — NOT created by /speckit-plan
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── config/                          # NEW — deployment configuration
│   │   ├── app_settings.dart            #   AppSettings.fromEnvironment(), FormattingSettings
│   │   └── app_settings_provider.dart
│   ├── formatting/                      # NEW — the single formatting surface
│   │   ├── app_formatters.dart          #   display.* / field.* + inverses
│   │   └── formatters_provider.dart
│   ├── design/
│   │   ├── text_scale.dart              # NEW — TextSizeLevel + composing TextScaler
│   │   └── spacing.dart                 # (unchanged; source for FR-034)
│   ├── settings/                        # NEW — device-local preferences
│   │   ├── user_display_preferences.dart
│   │   └── user_display_preferences_controller.dart
│   ├── storage/
│   │   └── shared_preferences_provider.dart  # NEW — seeded from main()
│   ├── branding/brand_config.dart       # composed into AppSettings; unchanged
│   ├── network/{dio_client,photo_url}.dart   # read AppSettings
│   └── widgets/
│       ├── app_side_sheet.dart          # NEW — shell extracted from the filter sheet
│       ├── catalog_filter_sheet.dart    # delegates to the shell
│       ├── catalog_filter_bar.dart      # `search` becomes optional
│       └── money_formatters.dart        # DELETED at the end of the migration
├── app/
│   ├── app.dart                         # locale + textScaler from preferences
│   └── theme/app_theme.dart             # ThemeModeController folded into preferences
├── features/
│   ├── settings/presentation/           # NEW — the user settings screen
│   │   └── user_settings_screen.dart
│   ├── sales/
│   │   ├── pos_defaults.dart            # reads AppSettings
│   │   ├── domain/money.dart            # display helpers removed; parsing stays
│   │   └── presentation/
│   │       ├── pos_sales_list_screen.dart      # US4
│   │       ├── cash_sessions_screen.dart       # US5
│   │       ├── widgets/shift_sheet.dart        # NEW — US5
│   │       └── capture/sale_line_{layout,row,card}.dart  # US6 + FR-024
│   └── catalog/presentation/taxpayer_certificates_section.dart  # inline DateFormat removed
├── l10n/{app_en,app_es}.arb             # settings screen strings, both locales
└── main.dart                            # loads prefs before runApp

test/
├── unit/core/
│   ├── formatting_guard_test.dart       # NEW — FR-015, lands LAST
│   ├── formatting/app_formatters_test.dart   # NEW — incl. round-trip property
│   └── config/app_settings_test.dart    # NEW — malformed-value fallbacks
├── widget/features/
│   ├── settings/                        # NEW
│   └── sales/sale_line_row_test.dart    # extended: 4 text-size levels, symmetry, baselines
├── golden/ + screenshots/               # must pass unchanged
.env.template                            # every key documented
```

**Structure Decision**: the existing feature-first layout is unchanged. Four
new `core/` subdirectories (`config/`, `formatting/`, `settings/`, plus one
file each in `design/` and `storage/`) because constitution §I forbids
reaching shared concerns through another feature's `presentation/` — the same
rule that promoted `PricingFormatters` to `MoneyFormatters` in spec 021, now
applied to the sales feature's display helpers too. The settings **screen**
is a feature (`features/settings/`), while the preference **state** is `core/`,
since `app.dart` and every formatter consume it.

## Phasing

Ordering is driven by one hard constraint: **the guard test (FR-015) must land
after the last call site migrates**, or it fails the suite for the entire
migration.

1. **Foundation** — `AppSettings` + providers; `sharedPreferencesProvider`
   seeded in `main()`; existing `fromEnvironment` sites re-pointed. No visible
   change.
2. **Formatting surface** — `AppFormatters` + provider + unit tests
   (round-trip property first). Still no call sites moved.
3. **Migration** — ~78 call sites across 22 files, in file batches. Delete
   `money_formatters.dart` and `money.dart`'s display helpers. **Then** the
   guard test.
4. **Preferences & settings screen** — `UserDisplayPreferences`, text scaling,
   locale wiring, the screen, `.arb` strings in both locales.
5. **FR-024 verification** — scale `sale_line_layout.dart`'s vertical
   constants and width threshold; extend `sale_line_row_test.dart` to four
   levels.
6. **Screen remediation** — sheet shell extraction; `pos_sales_list_screen`
   (US4); `cash_sessions_screen` + shift sheet (US5).
7. **Alignment** — POS sale-line symmetry and baselines, with measuring tests
   (US6).

Phases 1–3 are one dependency chain. Phase 6 is independent of 1–5 and can run
in parallel. Phase 5 depends on 4 (needs the scaler) and shares its file with
phase 7 — do 5 and 7 together to avoid two passes over
`sale_line_layout.dart`, the most delicate file in the change.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| **§VII (online-only, no local storage)** — display preferences persist on device via `shared_preferences` | Constitution §V has required device-persisted theme since v1.0.0, and the Technology Stack section names `shared_preferences` for exactly this. §VII's prohibition targets **business data** caching and offline sync, not UI preferences | Server-side persistence would need an mbe-api change (`UserSettingsResponse` has no display fields), making a personal-taste setting wait on a backend release — and the spec requires zero backend dependency (SC-011). Not persisting at all fails FR-021 |
| **Migrating ~78 call sites in one feature** | The guard (FR-015) cannot land until the last one moves; a partial migration leaves exactly the drift the feature exists to remove, and SC-001/SC-002 are stated as 100% | Migrating incrementally across features was rejected: it would keep two formatting paths alive indefinitely, which is the status quo |
| **`sale_line_layout.dart` touched for two reasons at once** (FR-024 scaling and FR-033 symmetry) | Both are the same arithmetic on the same derived constants — the file's own invariant (fields and dropdowns pay their height difference in padding, so heights *and* baselines agree) is what both requirements need | Two separate passes over the file the spec itself calls "specially difficult" doubles the risk of regressing a budget that took many iterations to land |
