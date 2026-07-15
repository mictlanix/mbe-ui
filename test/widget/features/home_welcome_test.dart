import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/branding/brand_config_provider.dart';
import 'package:mbe_ui/features/home/presentation/home_welcome.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

void main() {
  Future<void> pumpWelcome(
    WidgetTester tester, {
    required BrandConfig brand,
    Size size = const Size(1000, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [brandConfigProvider.overrideWithValue(brand)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: HomeWelcome()),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('branded deployment shows the configured display name',
      (tester) async {
    await pumpWelcome(
      tester,
      brand: const BrandConfig(
        displayName: 'CASA MAESTRA',
        welcomeAsset: 'assets/branding/default_welcome.png',
      ),
    );

    expect(find.text('CASA MAESTRA'), findsOneWidget);
    // A configured asset is used directly, not the default-placeholder branch.
    expect(find.byKey(const Key('home_welcome_default')), findsNothing);
  });

  testWidgets('unbranded deployment shows the default placeholder + message',
      (tester) async {
    await pumpWelcome(
      tester,
      brand: const BrandConfig(displayName: 'Mictlanix Business Essentials'),
    );

    expect(find.byKey(const Key('home_welcome_default')), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('renders no navigation list (regression: old Home nav)',
      (tester) async {
    await pumpWelcome(
      tester,
      brand: const BrandConfig(displayName: 'Mictlanix Business Essentials'),
    );

    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('renders without overflow at narrow and wide widths',
      (tester) async {
    await pumpWelcome(
      tester,
      brand: const BrandConfig(displayName: 'Mictlanix Business Essentials'),
      size: const Size(400, 800),
    );
    expect(tester.takeException(), isNull);

    await pumpWelcome(
      tester,
      brand: const BrandConfig(displayName: 'Mictlanix Business Essentials'),
      size: const Size(1400, 900),
    );
    expect(tester.takeException(), isNull);
  });
}
