# Quickstart: Validating XBE Default Branding

**Feature**: 019-xbe-default-branding

How to prove the feature works end to end. Each scenario maps to a spec
success criterion. See [contracts/brand-tokens.md](./contracts/brand-tokens.md)
for the token values being asserted.

## Prerequisites

```bash
flutter --version          # expect 3.44.2 stable
flutter pub get
```

## 1. Automated checks (fastest signal)

```bash
flutter analyze
flutter test
```

**Expected**: analyzer clean; all existing tests plus the new brand tests
pass. A pre-existing test asserting a specific indigo-derived color would
surface here — update it to assert the brand role, not a literal hex.

## 2. SC-001 — Brand palette on every screen, both modes

```bash
flutter run -d chrome        # no --dart-define: the default XBE build
```

Walk login → home → a catalog list → a record detail. In the user menu,
switch **Light → Dark → System**.

**Expected**:

- Primary buttons and active nav selection render brand gold, never indigo.
- Dark surfaces are warm-toned near-black (`#14120F` family), not blue-gray.
- Headings/labels render in Archivo; table body text stays Roboto.
- Red appears **only** on error banners and destructive confirmations — never
  on a button, chip, or nav highlight (FR-009).
- No screen's layout differs from `main` — only color and type (FR-011).

## 3. SC-002 — Branded first impression

```bash
flutter build web && (cd build/web && python3 -m http.server 8080)
```

Open `http://localhost:8080`.

**Expected**: browser tab shows the XBE favicon and
"Mictlanix Business Essentials"; the loading splash is the lockup on
`#14120F`, not white or Flutter blue.

Then on a native target:

```bash
flutter run -d macos    # or android/ios/windows
```

**Expected**: dock/launcher icon is the XBE mark; the launch splash shows
the lockup on the dark brand background.

## 4. SC-003 — White-label isolation (the critical regression check)

```bash
flutter run -d chrome \
  --dart-define=BRAND_DISPLAY_NAME="CASA MAESTRA" \
  --dart-define=BRAND_SEED_COLOR=1B5E20
```

**Expected**: a green-derived scheme throughout, "CASA MAESTRA" in the nav
header and window title, and **zero** XBE gold/orange/red anywhere. If any
XBE color survives, the `usesDefaultPalette` gate is wrong — this is the
single most important check in this feature.

Also confirm the partial-override case:

```bash
flutter run -d chrome --dart-define=BRAND_DISPLAY_NAME="ACME"
```

**Expected**: name is "ACME", palette and logo stay XBE (an unset flag means
"use the product default").

## 5. SC-004 — Logo placement rules

On the login screen and in the nav (rail, then the drawer at the Compact
tier — this app has no separate collapsed/icon-only rail state, see
spec.md Assumptions):

**Expected**:

- Login lockup ~236 px wide with clear space (~8% of its width) free of
  other content on all sides.
- Nav header (rail and drawer): mark at ~34 px tall beside the display
  name.
- Nothing renders a logo below its minimum (51 px lockup / 37 px mark).

Narrow the browser window until the drawer presentation kicks in and
confirm the mark never squashes, stretches, or clips there either.

## 6. SC-005 — Contrast

Run Chrome DevTools Lighthouse (Accessibility) against the running web build
in **both** light and dark mode, or spot-check body text and button labels
with a contrast checker.

**Expected**: no contrast failures on text against its background. The light
scheme derives its tones from the seed, so accessible pairings are produced
by construction (research R2); the dark scheme's pinned pairs come from the
approved guide.

## 7. SC-006 — Login & Home match the brand proposal

```bash
flutter run -d chrome        # default build, no dart-defines
```

**Login** (`/auth/login`): confirm a two-pane layout — a dark branding pane
(lockup, "Toda la operación, en un solo lugar." tagline, three accent-color
bars, version string) beside the sign-in form. Submit valid/invalid
credentials and confirm sign-in behavior (validation, error banner,
redirect on success) is unchanged from `main`.

**Home** (`/`): confirm a greeting card ("Buen día, {user}" + the guide's
summary line and two action buttons), a row of 4 indicator tiles
("Ventas de hoy" $184,320 / "Listas por autorizar" 3 / "Productos activos"
21,542 / "Instalaciones activas" 9 / 14), and a 4-entry recent-activity
panel — all matching `data-model.md`'s Static Home content table verbatim.

**Expected**: nothing on Home appears blank, stuck loading, or backed by a
network call (check DevTools Network tab — no request should fire for tile
or activity data). Every other screen (nav, catalog lists, detail screens)
is visually unchanged in layout from `main` — only color/type/assets.

## Rollback

Every change is additive or a value swap. To revert, restore
`lib/app/theme/app_theme.dart`, `lib/core/branding/`, `pubspec.yaml`, and the
generated native icon/splash outputs — no data migration or persisted state
is involved.
