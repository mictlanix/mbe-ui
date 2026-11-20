# Quickstart: validating Casa Maestra branding (077)

Prerequisites: Flutter 3.44.2, macOS with Xcode, and the Android SDK for the release checks. The local `.env` points at the test API.

## V1. The default brand is untouched (FR-004, SC-002)

```bash
flutter test test/widget/app/app_theme_test.dart test/unit/core/design/brand_independence_test.dart
flutter test test/golden                       # XBE login/home goldens must not change
git diff --stat test/golden/goldens            # only app bar, chips, banners, nav, nav header PNGs
```

Expected:
- The theme-pin tests pass unchanged.
- No XBE login or home golden changes.

## V2. Casa Maestra theme values and contrast (FR-006–FR-008, FR-020, SC-001, SC-004)

```bash
flutter test test/unit/core/branding test/contract/brand_contrast_test.dart
```

Expected:
- Every role in spec.md › Verbatim Constraints matches in light and dark.
- Every brand passes the contrast gate.

## V3. Run the Casa Maestra build

```bash
flutter run -d macos --dart-define-from-file=.env --dart-define=BRAND_ID=xbe.cm
```

Check by eye, in light then dark (Settings → Apariencia):
- **Login**: the lockup sits on a light pane in light and the reversed lockup on a dark pane in dark. The pane has one red accent bar.
- **Shell at 1200px**: mark plus "Casa Maestra" in the header. Rail sections read Operación, Inventario, Finanzas, Sistema. A red 3px rule sits under the app bar.
- **Shell at 700px**: mark only in the header.
- **Pedidos list**: folio and date columns in Roboto Mono. Status chips show an icon and a word. Titles are in Bitter.
- **Text size at the largest level**: no new overflow on login, home, Pedidos or POS (SC-007).

## V4. Unknown brand falls back (FR-003)

```bash
flutter run -d macos --dart-define-from-file=.env --dart-define=BRAND_ID=nope
```

Expected: the XBE look, with a `[BrandConfig]` debug line naming the fallback.

## V5. Status chips, navigation and errors (FR-014–FR-018)

```bash
flutter test test/widget/core/widgets test/unit/core/navigation test/unit/app/router
```

Expected:
- Every chip test finds an icon and a label.
- The nav invariants in contracts/nav-sections.md hold.

## V6. Release packaging (FR-021–FR-024, SC-006)

```bash
tool/release.sh web cm                     # refused: API_BASE_URL is a .invalid placeholder
# temporarily point deploy/cm.env at the test API, then:
tool/release.sh web cm --build-only
tool/release.sh android cm --build-only
tool/release.sh ios cm --build-only
tool/release.sh web demo --build-only      # mbe brand: same output as before
shellcheck tool/release.sh tool/release/*.sh
git status                                 # clean after each run
```

Expected:
- **Android**: the APK badging shows `com.mictlanix.xbe.cm` and "Casa Maestra", and the adaptive icon is the mark on white.
- **iOS**: the archive's Info.plist shows the bundle ID.
- **Web**: `build/web/manifest.json` has the "Casa Maestra" name and `#FFFFFF` theme and background colors.
- **Every platform**: the app opens in the Casa Maestra look.

Restore `deploy/cm.env` afterwards.
