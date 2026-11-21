import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/branding/brand_config_provider.dart';
import 'package:mbe_ui/core/branding/brands/casa_maestra_brand.dart';
import 'package:mbe_ui/core/branding/semantic_colors.dart';
import 'package:mbe_ui/core/branding/xbe_palette.dart';
import 'package:mbe_ui/features/auth/presentation/login/login_branding_pane.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The pane is painted from the brand's `LoginPaneStyle` (spec 077 FR-009):
/// XBE stays always-dark with three fixed bars, Casa Maestra follows the
/// theme with one accent bar and the reversed lockup on dark.
void main() {
  const xbe = BrandConfig(displayName: 'XBE');
  const casaMaestra = BrandConfig(
    displayName: 'Casa Maestra',
    seedColor: casaMaestraNavy,
    lockupAsset: 'assets/brand/xbe.cm/casa-maestra-logo.png',
    lockupReversedAsset: 'assets/brand/xbe.cm/casa-maestra-logo-reversed.png',
    markAsset: 'assets/brand/xbe.cm/casa-maestra-mark.png',
    definition: casaMaestraBrand,
  );

  Future<void> pump(
    WidgetTester tester,
    BrandConfig brand,
    Brightness brightness,
  ) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final appTheme = AppTheme.of(brand);
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [brandConfigProvider.overrideWithValue(brand)],
        child: MaterialApp(
          theme: brightness == Brightness.light
              ? appTheme.light
              : appTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: LoginBrandingPane()),
        ),
      ),
    );
    await tester.pump();
  }

  Color paneColor(WidgetTester tester) => tester
      .widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(LoginBrandingPane),
              matching: find.byType(ColoredBox),
            )
            .first,
      )
      .color;

  List<Color> barColors(WidgetTester tester) => tester
      .widgetList<Container>(find.byType(Container))
      .where((c) => c.constraints?.maxWidth == 56)
      .map((c) => (c.decoration! as BoxDecoration).color!)
      .toList();

  String lockupAsset(WidgetTester tester) =>
      (tester.widget<Image>(find.byType(Image)).image as AssetImage).assetName;

  for (final brightness in Brightness.values) {
    testWidgets('XBE: always-dark pane with three bars (${brightness.name})', (
      tester,
    ) async {
      await pump(tester, xbe, brightness);
      expect(paneColor(tester), XbePalette.darkSurface);
      expect(barColors(tester), [
        XbePalette.red,
        XbePalette.orange,
        XbePalette.gold,
      ]);
      expect(lockupAsset(tester), 'assets/brand/login_lockup.png');
    });
  }

  testWidgets('Casa Maestra light: theme surface, accent bar, primary lockup', (
    tester,
  ) async {
    await pump(tester, casaMaestra, Brightness.light);
    final theme = AppTheme.of(casaMaestra).light;
    expect(paneColor(tester), theme.colorScheme.surface);
    expect(barColors(tester), [theme.extension<SemanticColors>()!.accent]);
    expect(lockupAsset(tester), 'assets/brand/xbe.cm/casa-maestra-logo.png');
  });

  testWidgets('Casa Maestra dark: dark surface, accent bar, reversed lockup', (
    tester,
  ) async {
    await pump(tester, casaMaestra, Brightness.dark);
    final theme = AppTheme.of(casaMaestra).dark;
    expect(paneColor(tester), theme.colorScheme.surface);
    expect(barColors(tester), [theme.extension<SemanticColors>()!.accent]);
    expect(
      lockupAsset(tester),
      'assets/brand/xbe.cm/casa-maestra-logo-reversed.png',
    );
  });
}
