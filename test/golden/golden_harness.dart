import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The two logical-pixel widths captured for every golden (spec 022 FR-020):
/// "narrow" sits inside the compact tier, "wide" inside expanded. US3's own
/// scope is deliberately these two, not all four tiers — see spec.md.
const goldenNarrowWidth = 400.0;
const goldenWideWidth = 1024.0;
const _goldenHeight = 900.0;

const _defaultBrand = BrandConfig(displayName: 'Mictlanix Business Essentials');

/// Loads the bundled brand fonts, **and** the base Material body face, into
/// the test binary. **Required, not optional** (research R4) — without
/// this, every golden renders text as placeholder boxes, and the whole
/// safety net verifies nothing. Call once from a `setUpAll` in each golden
/// test file.
///
/// Archivo/RobotoMono are declared in `pubspec.yaml` and loadable via
/// `rootBundle`. Roboto is deliberately **not** bundled by the app (spec
/// 019 research R3 — "already Flutter's Material 3 default"), so it isn't
/// reachable through `rootBundle` either; `flutter test`'s sandbox has zero
/// real fonts pre-loaded, including Roboto, unlike a real device/browser
/// run. `fixtures/Roboto-Regular.ttf` is a vendored copy of the SDK's own
/// Material font (Apache 2.0 — `fixtures/Roboto_LICENSE.txt`), the same fix
/// third-party golden-testing packages apply for this exact gap, loaded
/// directly from disk since it's a test fixture, not an app asset.
Future<void> loadGoldenFonts() async {
  final archivo = FontLoader('Archivo')
    ..addFont(rootBundle.load('assets/fonts/Archivo-Variable.ttf'));
  final mono = FontLoader('RobotoMono')
    ..addFont(rootBundle.load('assets/fonts/RobotoMono-Variable.ttf'));
  final robotoBytes = File(
    'test/golden/fixtures/Roboto-Regular.ttf',
  ).readAsBytesSync();
  final roboto = FontLoader('Roboto')
    ..addFont(Future.value(ByteData.view(robotoBytes.buffer)));
  // Icon glyphs (Icons.*) are also a font, not vector art -- without this,
  // every Icon renders as a generic placeholder square instead of its real
  // glyph. Vendored the same way as Roboto, CC-BY 4.0 (fixtures/
  // MaterialIcons_LICENSE.txt).
  final iconBytes = File(
    'test/golden/fixtures/MaterialIcons-Regular.otf',
  ).readAsBytesSync();
  final materialIcons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.view(iconBytes.buffer)));
  await archivo.load();
  await mono.load();
  await roboto.load();
  await materialIcons.load();
}

/// Pumps [child] inside the real app theme (light or dark, tier-resolved
/// exactly as `lib/app/app.dart` wires it) at a fixed logical-pixel [width],
/// with [overrides] applied to a [ProviderScope] for any widget that reads
/// Riverpod state. Returns once the frame is settled.
///
/// Defaults [sharedPreferencesProvider] to an in-memory instance (spec 028):
/// `formattersProvider` reads through `resolvedLocaleProvider` ->
/// `userDisplayPreferencesControllerProvider`, so any widget formatting a
/// value now needs one. A caller-supplied override for the same provider,
/// appended after this default, still wins (Riverpod resolves duplicate
/// overrides last-one-wins).
Future<void> pumpGoldenScenario(
  WidgetTester tester,
  Widget child, {
  required Brightness brightness,
  required double width,
  List<Override> overrides = const [],
  double height = _goldenHeight,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  tester.view.platformDispatcher.textScaleFactorTestValue = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.platformDispatcher.clearTextScaleFactorTestValue);

  final appTheme = AppTheme.of(_defaultBrand);
  final base = brightness == Brightness.light ? appTheme.light : appTheme.dark;

  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ...overrides,
      ],
      child: MaterialApp(
        theme: base,
        debugShowCheckedModeBanner: false,
        locale: const Locale('es', 'MX'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, widget) {
          final tier = LayoutBreakpoints.tierOfContext(context);
          return Theme(
            data: DesignTheme.forTier(Theme.of(context), tier),
            child: widget!,
          );
        },
        home: Scaffold(body: Center(child: child)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Runs [scenario] at both brightnesses and both widths (4 combinations),
/// matching each against `goldens/<name>_<brightness>_<width>.png`. Fails
/// (does not silently skip) if a baseline is missing (`FR-023`) — run with
/// `flutter test test/golden --update-goldens` to generate them first.
Future<void> expectGoldenMatrix(
  WidgetTester tester,
  String name,
  Widget Function(Brightness brightness, double width) scenario, {
  List<Override> overrides = const [],
}) async {
  for (final brightness in Brightness.values) {
    for (final width in [goldenNarrowWidth, goldenWideWidth]) {
      await pumpGoldenScenario(
        tester,
        scenario(brightness, width),
        brightness: brightness,
        width: width,
        overrides: overrides,
      );
      final widthLabel = width == goldenNarrowWidth ? 'narrow' : 'wide';
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/${name}_${brightness.name}_$widthLabel.png'),
      );
    }
  }
}
