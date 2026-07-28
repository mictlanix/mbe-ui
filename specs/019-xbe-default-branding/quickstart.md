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

On the login screen and in the nav (expanded, then narrowed until the rail
collapses):

**Expected**:

- Login lockup ~236 px wide with clear space (~8% of its width) free of
  other content on all sides.
- Expanded nav: mark at ~34 px tall beside the display name.
- Collapsed nav: mark only at ≥ 37 px, no wordmark.
- Nothing renders a logo below its minimum (51 px lockup / 37 px mark).

Narrow the browser window progressively to force the compact tier and
confirm the mark never squashes, stretches, or clips.

## 6. SC-005 — Contrast

Run Chrome DevTools Lighthouse (Accessibility) against the running web build
in **both** light and dark mode, or spot-check body text and button labels
with a contrast checker.

**Expected**: no contrast failures on text against its background. The light
scheme derives its tones from the seed, so accessible pairings are produced
by construction (research R2); the dark scheme's pinned pairs come from the
approved guide.

## Rollback

Every change is additive or a value swap. To revert, restore
`lib/app/theme/app_theme.dart`, `lib/core/branding/`, `pubspec.yaml`, and the
generated native icon/splash outputs — no data migration or persisted state
is involved.
