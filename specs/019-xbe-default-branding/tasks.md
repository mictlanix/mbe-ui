# Tasks: XBE Default Branding

**Input**: Design documents from `/specs/019-xbe-default-branding/`
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/brand-tokens.md](./contracts/brand-tokens.md), [contracts/brand-assets.md](./contracts/brand-assets.md), [quickstart.md](./quickstart.md)

**Tests**: Included — this repo has an established `flutter_test` suite (153 tests) and the constitution's Development Workflow section requires widget tests for `core/widgets/` components and critical screens.

**Organization**: Tasks are grouped by user story (spec.md) so each is independently implementable and testable.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: Maps to spec.md's user stories (US1–US5)
- Every task names its exact file path

## Path Conventions

Single Flutter application, feature-first layering (plan.md's Structure Decision). All paths are repo-root-relative.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Get every brand asset and font into the repo and declared, before any code references them.

- [X] T001 [P] Fetch the 5 brand SVGs (`xbe-lockup.svg`, `xbe-lockup-white.svg`, `xbe-lockup-gray.svg`, `xbe-mark.svg`, `xbe-mark-white.svg`) from the Claude Design project `7a94cd32-a9e1-456c-b870-5730d4498e59` ("XBE Look and Feel proposal") into `assets/brand/` — content already retrieved in this session's design import, write verbatim.
- [X] T002 [P] Fetch the PNG raster set from the same design project into `assets/brand/` with resolution-aware subfolders per `contracts/brand-assets.md`'s repository layout: `login_lockup.png` (1x) + `2.0x/login_lockup.png` + `3.0x/login_lockup.png` (from `assets/login_lockup_1x/2x/3x.png`), and `nav_lockup.png` + `2.0x/nav_lockup.png` + `3.0x/nav_lockup.png` (from `assets/nav_lockup_1x/2x/3x.png`).
- [X] T003 [P] Fetch the native-icon/splash generator source PNGs from the design project into `assets/icons_src/` (not declared in `pubspec.yaml`'s `assets:`, per `contracts/brand-assets.md`): `app_icon_dark_1024.png`, `app_icon_light_1024.png`, `android_adaptive_foreground_1024.png`, `splash_lockup_1024.png`.
- [X] T004 [P] Fetch `favicon_32.png`, `favicon_192.png`, `favicon_512.png` from the design project directly into `web/` and `web/icons/` per `contracts/brand-assets.md`'s Web assets table (replacing `web/favicon.png`, `web/icons/Icon-192.png`, `web/icons/Icon-512.png`, `web/icons/Icon-maskable-192.png`, `web/icons/Icon-maskable-512.png`).
- [X] T005 [P] Add `assets/fonts/Archivo-Variable.ttf` + `assets/fonts/OFL-Archivo.txt` and `assets/fonts/RobotoMono-Variable.ttf` + `assets/fonts/OFL-RobotoMono.txt` (Google Fonts OFL releases, per research R3 — bundled, not fetched via `google_fonts` at runtime).
- [X] T006 Declare the new assets in `pubspec.yaml`: add `assets/brand/` under `flutter: assets:` (alongside the existing `assets/branding/`), and add a `fonts:` section with the `Archivo` family (weights 400/500/600/700 from the single variable `.ttf`) and `RobotoMono` family (weights 400/500).
- [X] T007 Add `flutter_launcher_icons` and `flutter_native_splash` to `pubspec.yaml`'s `dev_dependencies:`, then run `flutter pub get`.
- [X] T008 Configure `flutter_launcher_icons` and `flutter_native_splash` in `pubspec.yaml` per `contracts/brand-assets.md`'s Generator configuration section (icon/adaptive-icon/splash image paths, `#14120F` backgrounds, Android/iOS/macOS/Windows/web targets; Linux excluded — tool limitation, accepted).

**Checkpoint**: All brand assets exist on disk and are declared; `flutter pub get` succeeds.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The brand-token pipeline (config → palette → theme → provider) that User Stories 1, 3, 4, and 5 all build on. **No user story can be verified until this phase is done.**

- [X] T009 [P] Create `lib/core/branding/xbe_palette.dart`: brand hue constants (`xbeGold` #ECAB03, `xbeOrange` #EC672A, `xbeRed` #D8262E, `xbeWordmarkGray` #C7C7C8), the dark-scheme role-pin map, the light-scheme role-pin map, the standalone `xbeGoldInk` (#7A5600) constant, and the placement constants (`lockupLoginWidth` 236.0, `lockupMinWidth` 51.0, `markMinWidth` 37.0, `markNavHeight` 34.0, `clearSpaceRatio` 0.08, `watermarkOpacityDark` 0.07, `watermarkOpacityLight` 0.06) — exact values from `data-model.md`'s `XbeBrandPalette` section.
- [X] T010 Extend `lib/core/branding/brand_config.dart`: add `seedColor` (`Color`, from `BRAND_SEED_COLOR` dart-define, hex `RRGGBB`/`#RRGGBB`, falls back to `xbeGold` on unset or unparseable input — never throws), `usesDefaultPalette` (`bool`, `true` iff `BRAND_SEED_COLOR` is absent), `lockupAsset` (`String`, from `BRAND_LOCKUP_ASSET`, default `assets/brand/login_lockup.png`), `markAsset` (`String`, from `BRAND_MARK_ASSET`, default `assets/brand/nav_lockup.png`); extend `==`/`hashCode` to cover all four new fields (existing pattern in the file).
- [X] T011 [P] [US1] `test/unit/core/branding/brand_config_test.dart` — new file: test `BRAND_SEED_COLOR` hex parsing (with/without `#` prefix), fallback to `xbeGold` on malformed input, `usesDefaultPalette` true/false in both directions (including the "explicit seed equal to XBE gold still counts as override" rule from data-model.md), and updated equality/hashCode.
- [X] T012 Convert `lib/app/theme/app_theme.dart`: replace the hardcoded `const _seedColor = Colors.indigo` and static `AppTheme.light`/`AppTheme.dark` with an `AppTheme.of(BrandConfig brand)` builder (or equivalent instance constructor) producing `light`/`dark` `ThemeData`, each via `ColorScheme.fromSeed(seedColor: brand.seedColor, brightness: ..., dynamicSchemeVariant: DynamicSchemeVariant.fidelity, ...)` — applying the dark/light role-pin maps from `xbe_palette.dart` **only when** `brand.usesDefaultPalette` is `true` — plus a `TextTheme` override mapping `displaySmall`/`titleLarge`/`labelLarge` (and other display/headline/title/label roles) to the bundled Archivo font family. Leave `ThemeModeController` untouched.
- [X] T013 Add `final appThemeProvider = Provider<AppTheme>((ref) => AppTheme.of(ref.watch(brandConfigProvider)));` to `lib/app/theme/app_theme.dart` (plain `Provider`, no codegen needed, colocated with the class per existing file conventions).
- [X] T014 Update `lib/app/app.dart`: watch `appThemeProvider` and pass `.light`/`.dark` to `MaterialApp.router`'s `theme`/`darkTheme` (replacing the `AppTheme.light`/`AppTheme.dark` static references); change `title:` from the literal `'Mictlanix Business Essentials'` to `ref.watch(brandConfigProvider).displayName`.

**Checkpoint**: `flutter analyze` is clean; the app builds and runs with the new brand-driven theme pipeline in place (visual verification comes in US1).

---

## Phase 3: User Story 1 - Cohesive in-app brand experience (Priority: P1) 🎯 MVP

**Goal**: Every screen in the default build shows the XBE color palette and Archivo/Roboto/Roboto Mono typography, in both light and dark mode, with the brand red reserved for error states only.

**Independent Test**: `flutter run -d chrome` with no dart-defines; walk login → home → a catalog list; toggle Light/Dark/System — see quickstart.md §2.

### Tests for User Story 1

- [X] T015 [P] [US1] `test/widget/app/app_theme_test.dart` — new file: assert `AppTheme.of(BrandConfig.fromEnvironment())` (default, no `BRAND_SEED_COLOR`) produces a dark `ColorScheme` with `primary == xbeGold`, `tertiary == xbeOrange`, `error == xbeRed`, `surface == Color(0xFF14120F)`, and a light `ColorScheme` with `error == Color(0xFFC4262E)` and `surface == Color(0xFFFBF8F3)` — i.e. the pinned roles from `xbe_palette.dart` actually apply for the default palette.
- [X] T016 [P] [US1] Grep the existing test suite for any assertion on a literal indigo-derived color (`Colors.indigo`, or a `ColorScheme.fromSeed(seedColor: Colors.indigo)`-derived hex) and update it to assert against the new brand role/color instead — this is a "fix forward" task, not a new file; report which files (if any) needed changes.

### Implementation for User Story 1

- [X] T017 [US1] Verify (via `flutter run` and the widget tree, not just code review) that every screen inheriting `Theme.of(context)` — catalog lists, detail forms, dialogs, snackbars, `ErrorBanner` — resolves colors from the new `ColorScheme` with no hardcoded `Colors.indigo`/`Colors.blue` left in `core/widgets/` or feature screens; fix any found (expected: none, since the seam was always `Theme.of(context)`-based, but this is the FR-001/FR-009 acceptance check).
- [X] T018 [US1] Confirm `core/widgets/error_banner.dart` and any other error-state widget uses `Theme.of(context).colorScheme.error`/`errorContainer` (not a hardcoded red), so the brand red flows through automatically — fix if it doesn't.

**Checkpoint**: User Story 1 is fully functional and testable independently — this is the MVP.

---

## Phase 4: User Story 2 - Branded first impression (Priority: P1)

**Goal**: App icon, native splash, and web favicon/tab title are on-brand from first launch, with no in-app navigation required to see it.

**Independent Test**: fresh install on one native target + web build — see quickstart.md §3.

### Implementation for User Story 2

- [X] T019 [US2] Run `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create` (configured in T008) and commit the generated native outputs (Android `mipmap-*`/adaptive-icon XML, iOS `Assets.xcassets/AppIcon.appiconset`, macOS/Windows icon files, native splash resources) so CI builds need no generation step.
- [X] T020 [P] [US2] Update `web/manifest.json`: `icons[]` paths already point at `web/icons/Icon-192.png`/`Icon-512.png`/maskable variants (now branded via T004's in-place replacement — no path change needed); change `background_color` and `theme_color` from `#0175C2` to `#14120F`.
- [X] T021 [P] [US2] Update `web/index.html`: no `<title>`/`apple-mobile-web-app-title` change needed (FR-017 keeps "Mictlanix Business Essentials"/"MBE") — confirm the `<link rel="icon">` still points at `favicon.png` (now branded via T004's in-place replacement).
- [X] T022 [P] [US2] Fix `android/app/src/main/AndroidManifest.xml`: change `android:label="mbe_ui"` (raw package identifier) to `android:label="Mictlanix Business Essentials"` (FR-017/018 — this was already wrong before this feature, per contracts/brand-tokens.md's native touchpoints table).
- [X] T023 [P] [US2] Fix `ios/Runner/Info.plist`: change `CFBundleDisplayName` from `Mbe Ui` to `Mictlanix Business Essentials` (same rationale as T022).

**Checkpoint**: User Stories 1 AND 2 both work independently.

---

## Phase 5: User Story 3 - Correctly placed and sized logo across the app (Priority: P2)

**Goal**: The lockup/mark render at the right size, variant, and clear space at every documented placement — login, nav (rail + drawer), decorative watermark. No collapsed/icon-only nav state is introduced (confirmed with the user — see spec.md Assumptions); the nav rail and drawer stay exactly as they are structurally today, gaining only the brand header block.

**Independent Test**: walk login + nav (rail, then drawer at the Compact tier) — see quickstart.md §5.

### Tests for User Story 3

- [X] T024 [P] [US3] `test/widget/core/widgets/brand_logo_test.dart` — new file: assert the widget renders nothing (not a squashed/stretched image) when requested below its variant's minimum width, renders the full lockup at/above 51px and the mark at/above 37px, and selects the correct asset variant per background (full-color on dark, grayscale on light, white single-ink on a brand-color fill) per `contracts/brand-assets.md`'s Variant selection rule.

### Implementation for User Story 3

- [X] T025 [US3] Create `lib/core/widgets/brand_logo.dart`: a `BrandLogo` widget taking a placement/background parameter, encapsulating variant selection (full-color / grayscale / white single-ink), minimum-size enforcement (51px lockup, 37px mark — render `SizedBox.shrink()` below minimum rather than an illegibly small image), and the 8%-of-width clear-space padding, reading asset paths from `BrandConfig.lockupAsset`/`markAsset` (via `brandConfigProvider`) so a deployment's own logo overrides flow through automatically.
- [X] T026 [US3] Update `lib/core/widgets/app_navigation.dart`: add a header block above the existing destination tree in both `_buildRail` and `_buildDrawer`, showing `BrandLogo` (mark, `markNavHeight` 34px) + `brand.displayName` in Archivo 14/600. Do not change `AppShell`/`AppNavigation`'s structure otherwise — the app keeps its current two presentations (the 240px rail and the `NavigationDrawer`) exactly as they are; no rail-collapse toggle or third navigation state is added.
- [X] T027 [US3] Add the decorative watermark placement support to `BrandLogo` (or a small `BrandWatermark` sibling widget in the same file): white mark at 7% opacity on dark surfaces, full-color mark at 6% opacity on light surfaces, positioned so callers can place it behind non-text content only (used by the Home dashboard hero card in US4 — T034).

**Checkpoint**: All user stories through US3 are independently functional.

---

## Phase 6: User Story 4 - Login and Home rebuilt to match the brand proposal (Priority: P1)

**Goal**: Login becomes a two-pane split (branding pane + form); Home becomes a dashboard (greeting + indicator tiles + activity panel) with hardcoded placeholder content; every other screen's layout is untouched.

**Independent Test**: compare login/home against the brand guide's mockups; confirm tile/activity content is static, not loading/blank — see quickstart.md §7.

**Depends on**: `BrandLogo`/`BrandWatermark` from US3 (T025, T027) — the login branding pane and home hero card reuse them rather than duplicating variant-selection logic.

### Tests for User Story 4

- [X] T028 [P] [US4] Add new `.arb` keys to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` for the login tagline/subhead ("Toda la operación, en un solo lugar." / "All your operations, in one place." and the "Catálogos, precios..." subhead) and the dashboard greeting/summary/button copy ("Buen día, {name}" greeting template, the static summary line, "Revisar pendientes", "Nueva venta") — regenerate localizations (`flutter gen-l10n` or via `flutter: generate: true` on next build) so `AppLocalizations` exposes the new getters. (Tile labels and activity entries themselves stay as literal Spanish strings in the static content files, T031/T032 — they're placeholder *data*, not permanent UI chrome, per data-model.md.)
- [X] T029 [US4] Update `test/widget/features/auth/login_screen_test.dart`: existing tests key off `Key('login_username_field')`/`Key('login_password_field')`/`FilledButton` text and must keep passing unchanged after the layout restructure (T033 preserves these keys/widgets) — add one new test asserting the branding pane (lockup + tagline) is present alongside the form. Run and confirm the three pre-existing tests still pass without modification.
- [X] T030 [US4] Rewrite `test/widget/features/home_welcome_test.dart` for the new dashboard structure per data-model.md's `welcomeAsset` reconciliation: (a) "branded deployment with a configured `welcomeAsset`" still shows the original image + `displayName` layout (unchanged behavior — update the test only if the widget/key names moved); (b) "unbranded deployment / no `welcomeAsset`" now asserts the dashboard renders — a greeting containing `displayName` or the signed-in user context, all 4 indicator tile labels from data-model.md's table, and all 4 activity entries — instead of asserting `Key('home_welcome_default')`; (c) keep the existing "no `ListTile`/no overflow at narrow and wide widths" regression tests, adapted to the new widget tree.

### Implementation for User Story 4

- [X] T031 [P] [US4] Create `lib/features/home/presentation/home_dashboard_tiles.dart`: a `HomeDashboardTiles` widget rendering the 4 static `DashboardIndicatorTile` entries from `data-model.md`'s table (icon/value/label) in a row of Material 3 cards, using `Theme.of(context).colorScheme`/Archivo per FR-002.
- [X] T032 [P] [US4] Create `lib/features/home/presentation/home_activity_feed.dart`: a `HomeActivityFeed` widget rendering the 4 static `ActivityFeedEntry` entries from `data-model.md`'s table (icon/text/time) as a list panel.
- [X] T033 [US4] Restructure `lib/features/auth/presentation/login/login_screen.dart` into a two-pane layout: a new `lib/features/auth/presentation/login/login_branding_pane.dart` (dark pane with `BrandLogo` full lockup at `lockupLoginWidth` 236px, the new tagline/subhead from T028, three accent-color bars using `xbeGold`/`xbeOrange`/`xbeRed`, and a version string) beside the **existing, unmodified** `Form`/`TextFormField`/`FilledButton`/`_submit` logic — same `Key`s, same validator behavior, same `ErrorBanner` usage. Update the class docstring (currently references a now-stale "centered single-column form" contract) to describe the new layout. On narrow/compact widths, the branding pane MAY collapse (e.g. hidden or stacked above the form) rather than force horizontal scrolling — follow the existing `LayoutBuilder`/`core/layout/breakpoints.dart` pattern used elsewhere in the app.
- [X] T034 [US4] Restructure `lib/features/home/presentation/home_welcome.dart`: branch on `brand.hasWelcomeAsset` per data-model.md's resolution — `true` keeps today's existing image+displayName+message layout unchanged; `false` renders the new dashboard (a greeting card with a `BrandWatermark` (T027) at low opacity, the static summary line + two action buttons from T028, followed by `HomeDashboardTiles` (T031) and `HomeActivityFeed` (T032)). The two action buttons route to whatever the equivalent existing destinations already resolve to today (no new routes).

**Checkpoint**: All user stories through US4 are independently functional; login/home visually match the brand guide's mockups.

---

## Phase 7: User Story 5 - Other deployments stay unaffected (Priority: P2)

**Goal**: Prove complete isolation — a deployment with its own brand override never sees any XBE-specific color, logo, icon, or splash.

**Independent Test**: build with `BRAND_SEED_COLOR`/`BRAND_DISPLAY_NAME` overrides set — see quickstart.md §4.

### Tests for User Story 5

- [X] T035 [US5] Append to `test/widget/app/app_theme_test.dart` (T015): assert `AppTheme.of(BrandConfig(displayName: '...', seedColor: Color(0xFF1B5E20)))` (i.e. `usesDefaultPalette == false`) produces a `ColorScheme` with **no** XBE pins present — `primary`/`tertiary`/`error`/surfaces all trace to Material's algorithmic derivation from the green seed, not any `xbe_palette.dart` constant — for both light and dark.
- [X] T036 [P] [US5] `test/widget/features/home_welcome_test.dart` (T030) already covers the `welcomeAsset`-configured path showing the non-XBE layout — add an explicit assertion there that none of the 4 dashboard tile labels or 4 activity entries from data-model.md appear when `welcomeAsset` is configured, closing the isolation gap for Home specifically.
- [X] T037 [P] [US5] `test/widget/core/widgets/app_navigation_test.dart` — add a case overriding `brandConfigProvider` with a custom `displayName`/`markAsset` and asserting the nav header (T026) shows that overridden name/asset, not "Mictlanix Business Essentials"/the XBE mark.

**Checkpoint**: All 5 user stories are independently functional and verified isolated from each other.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final verification across every story.

- [X] T038 Run `flutter analyze` and fix any warnings introduced by this feature.
- [X] T039 Run `flutter test` (full suite) and confirm all pre-existing + new tests pass.
- [X] T040 Walk every step of `quickstart.md` (§1–§7) manually against a running build and record results; fix any discrepancy found.
- [X] T041 [P] Update the stale docstring in `lib/features/home/presentation/home_welcome.dart` referencing "never renders blank" behavior to describe the new dashboard branch (T034 should have already touched this file — this is a final pass to ensure the comment matches the shipped structure, not a redundant edit if T034 already did it).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies — all `[P]` tasks can run together.
- **Foundational (Phase 2)**: depends on Setup (needs fonts declared for T012's TextTheme, brand assets on disk for later provider defaults) — **blocks every user story**.
- **User Stories (Phase 3–7)**: all depend on Foundational. US1 and US2 are mutually independent and can run in parallel. US3 depends only on Foundational. **US4 depends on US3** (reuses `BrandLogo`/`BrandWatermark`). US5's tests depend on US1's `app_theme_test.dart` file existing (T015) and US4's `home_welcome_test.dart`/`app_navigation_test.dart` files existing (T030, T026) — it appends to/extends them rather than starting fresh.
- **Polish (Phase 8)**: depends on all 5 stories being complete.

### Recommended Order

Setup → Foundational → US1 (MVP) → US2 → US3 → US4 → US5 → Polish. US1 and US2 may run in parallel once Foundational is done if staffed; US3 should land before US4 to avoid duplicating logo-variant logic; US5 is last because its tests extend files US1/US4 create.

### Parallel Opportunities

- All Setup tasks (T001–T005) are `[P]` — different files, no dependency on each other.
- T009 (`xbe_palette.dart`) is `[P]` relative to T010 (`brand_config.dart`) — different files — but both must land before T012.
- T020/T021/T022/T023 (US2's web/native manifest fixes) are all `[P]` — four independent files.
- T031/T032 (US4's new dashboard widgets) are `[P]` — independent new files — before T034 wires them in.
- T036/T037 (US5's isolation assertions) are `[P]` — different test files.

---

## Parallel Example: Setup Phase

```bash
Task: "Fetch the 5 brand SVGs into assets/brand/ (T001)"
Task: "Fetch the PNG raster set into assets/brand/ (T002)"
Task: "Fetch native-icon/splash generator source PNGs into assets/icons_src/ (T003)"
Task: "Fetch web favicon/PWA icons into web/ and web/icons/ (T004)"
Task: "Add bundled Archivo + Roboto Mono font files into assets/fonts/ (T005)"
```

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup) + Phase 2 (Foundational).
2. Complete Phase 3 (US1) — the app is now fully re-themed, every screen on-brand.
3. **STOP and VALIDATE**: run quickstart.md §1–§2 independently.
4. This is a demoable MVP even before icons/splash/logo-placement/login-home-rebuild land.

### Incremental Delivery

1. Setup + Foundational → theme pipeline ready.
2. US1 → in-app palette/typography live → demo (MVP).
3. US2 → branded icon/splash/favicon → demo.
4. US3 → correct logo placement in nav → demo.
5. US4 → login/home match the proposal → demo.
6. US5 → isolation proven → ship-ready.

## Notes

- `[P]` tasks touch different files with no dependency on an incomplete task.
- Every task names its exact file path so it's actionable without re-reading this whole document.
- Commit after each task or logical group (per repo convention — do not batch unrelated changes into one commit).
- No collapsed/icon-only navigation state is in scope for this feature — the nav rail and drawer keep their current structure, gaining only the brand header block (T026).
