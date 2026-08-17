# Implementation Plan: App Settings, User Settings & Cross-Widget Consistency

**Branch**: `027-app-user-settings` | **Date**: 2026-08-16 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/027-app-user-settings/spec.md`

## Summary

Introduces the two configuration levels the app never had, and fixes the
screens that motivated the complaint.

**Formatting was descoped after planning** (spec.md Clarifications,
2026-08-16): the audit sized it at ≈78 call sites across 22 files in three
divergent paths, larger than everything else here combined and indivisible,
since the guard test only becomes satisfiable once the last call site moves.
Its finished design is carried forward in `contracts/formatting-surface.md`,
`research.md` R3/R4/R8 and `data-model.md` §2 for its own spec. **This feature
changes how nothing is rendered.**

What remains: a **build-time `AppSettings`** consolidating the four scattered
`fromEnvironment` sites and adding the deployment's default locale;
**device-local `UserDisplayPreferences`** (appearance, four text-size levels,
language) on a new settings screen, loaded before `runApp` so the first frame
is already correct; `pos_sales_list_screen` moving its facets into the shared
filter drawer; `cash_sessions_screen` moving its shift form into a sheet whose
toolbar action carries the shift state; and the POS sale line getting
symmetric insets with its control band on the line total's baseline.

No mbe-api change. Constitution amended to v1.11.0 in the same change — minus
the formatting rule, which is withheld until the surface exists.

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

**Performance Goals**: no regression. (The per-frame formatter churn found in
the audit — a 50-row × 3-formatted-column table constructs ~150
`NumberFormat`/`DateFormat` instances per frame — is left for the formatting
spec to fix, since it is a property of the call sites, not of this change.)

**Constraints**:
- **Nothing rendered may change.** Formatting is out of scope; the only
  visual changes are the two remediated screens and the sale-line insets.
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

**Scale/Scope**: 17 list screens audited (3 non-compliant, 1 out of scope);
1 new screen; 3 screens remediated; 1 shared sheet shell extracted; 1
constitution amendment. The ≈78 formatting call sites across 22 files are
**deferred** — audited and sized in research.md R8, not touched here.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Checked against constitution **v1.11.0** — which this feature itself
authored, so the check is also a self-consistency check on the amendment.

| Principle | Gate | Status |
|---|---|---|
| **I. Feature-first layered architecture** | Shared settings live in `core/`, not reached cross-feature through `presentation/` | ✅ `core/config/`, `core/settings/` |
| **II. Riverpod for state & DI** | New state exposed as providers, overridable in tests | ✅ `appSettingsProvider`, `userDisplayPreferencesProvider`, `sharedPreferencesProvider` |
| **III. Contract-driven API integration** | No hand-written DTOs; no mbe-api edit | ✅ N/A — zero backend surface (SC-011) |
| **IV. Deny-by-default RBAC** | Every mutable action gated | ✅ Settings screen is deliberately ungated (personal preferences, constitution §V). The cash-sessions toolbar action stays gated on `pos:create` and is **absent**, not disabled, without it |
| **V. Material 3, white-labeled** | Brand tokens build-time; two config levels; four text sizes | ✅ This feature implements the v1.11.0 rules. `BrandConfig` is composed unchanged, preserving spec 019's `usesDefaultPalette` semantics. The formatting-surface rule is **withheld** from v1.11.0 rather than shipped unenforceable |
| **VI. Desktop/web-first layout** | Filters behind the drawer; no form above a list; symmetry/baselines from tokens, asserted by measuring tests | ✅ US4/US5/US6 |
| **VII. Online-only** | No offline storage or caching | ⚠️ **Justified, see Complexity Tracking** — `shared_preferences` stores display preferences locally |

**Post-Phase-1 re-check**: no gate changed. The Phase 1 design added the
shared sheet shell (§VI-consistent: one shared component rather than a second
sheet implementation) and the `sharedPreferencesProvider` override (§II).

**Post-descope re-check (2026-08-16)**: removing formatting removes no gate
and creates no violation. The pre-existing formatting drift is not a new
deviation — it is the status quo this feature no longer addresses, inventoried
in research.md R8, and §V carries no rule against it until the surface
exists.

## Project Structure

### Documentation (this feature)

```text
specs/027-app-user-settings/
├── plan.md              # This file
├── spec.md
├── research.md          # Phase 0 — R1..R11, all unknowns resolved
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
│   │   ├── app_settings.dart            #   AppSettings.fromEnvironment()
│   │   └── app_settings_provider.dart
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
│       └── money_formatters.dart        # UNTOUCHED — formatting is out of scope
├── app/
│   ├── app.dart                         # locale + textScaler from preferences
│   └── theme/app_theme.dart             # ThemeModeController folded into preferences
├── features/
│   ├── settings/presentation/           # NEW — the user settings screen
│   │   └── user_settings_screen.dart
│   ├── sales/
│   │   ├── pos_defaults.dart            # reads AppSettings
│   │   └── presentation/
│   │       ├── pos_sales_list_screen.dart      # US4
│   │       ├── cash_sessions_screen.dart       # US5
│   │       ├── widgets/shift_sheet.dart        # NEW — US5
│   │       └── capture/sale_line_{layout,row,card}.dart  # US6 + FR-024
├── l10n/{app_en,app_es}.arb             # settings screen strings, both locales
└── main.dart                            # loads prefs before runApp

test/
├── unit/core/
│   └── config/app_settings_test.dart    # NEW — malformed-value fallbacks
├── widget/features/
│   ├── settings/                        # NEW
│   └── sales/sale_line_row_test.dart    # extended: 4 text-size levels, symmetry, baselines
├── golden/ + screenshots/               # must pass unchanged
.env.template                            # app-settings section added
```

**Structure Decision**: the existing feature-first layout is unchanged. Two
new `core/` subdirectories (`config/`, `settings/`, plus one file each in
`design/` and `storage/`) because constitution §I forbids reaching shared
concerns through another feature's `presentation/`. The settings **screen** is
a feature (`features/settings/`), while the preference **state** is `core/`,
since `app.dart` consumes it. `core/formatting/` is **not** created here — it
belongs to the deferred formatting spec.

## Phasing

With formatting deferred, the long dependency chain is gone and the remaining
work splits into two independent tracks.

1. **Foundation** — `AppSettings` + provider; `sharedPreferencesProvider`
   seeded in `main()` before `runApp`; the four existing `fromEnvironment`
   sites re-pointed; `.env.template` gains its app-settings section. No
   visible change.
2. **Preferences & settings screen** — `UserDisplayPreferences`, the composing
   text scaler, locale wiring into `MaterialApp`, the screen itself, `.arb`
   strings in both locales. Depends on 1 for the default locale.
3. **Sale line: text scale + alignment** — scale `sale_line_layout.dart`'s
   vertical constants and width threshold (FR-024), fix the insets and
   baselines (US6), and extend `sale_line_row_test.dart` to measure both at
   all four levels. Depends on 2 for the scaler.
4. **Screen remediation** — extract the sheet shell; convert
   `pos_sales_list_screen` to the drawer (US4); move the shift panel into a
   sheet with a state-carrying toolbar action (US5). **Independent of 1–3**;
   can run in parallel from the start.

Phases 1 → 2 → 3 are one chain; phase 4 is the other track. Phase 3
deliberately makes both of its changes in one pass over
`sale_line_layout.dart` — the most delicate file in the change, and the same
arithmetic serves both requirements.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| **§VII (online-only, no local storage)** — display preferences persist on device via `shared_preferences` | Constitution §V has required device-persisted theme since v1.0.0, and the Technology Stack section names `shared_preferences` for exactly this. §VII's prohibition targets **business data** caching and offline sync, not UI preferences | Server-side persistence would need an mbe-api change (`UserSettingsResponse` has no display fields), making a personal-taste setting wait on a backend release — and the spec requires zero backend dependency (SC-011). Not persisting at all fails FR-021 |
| **`sale_line_layout.dart` touched for two reasons at once** (FR-024 scaling and FR-033 symmetry) | Both are the same arithmetic on the same derived constants — the file's own invariant (fields and dropdowns pay their height difference in padding, so heights *and* baselines agree) is what both requirements need | Two separate passes over the file the spec itself calls "specially difficult" doubles the risk of regressing a budget that took many iterations to land |
