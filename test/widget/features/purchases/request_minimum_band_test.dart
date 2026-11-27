import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/purchases/domain/below_minimum.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/request_minimum_band.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Spec 079 US1 (T016), FR-013: the minimum-quantity band.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  Future<void> pump(WidgetTester tester, List<BelowMinimum> entries) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RequestMinimumBand(belowMinimum: entries)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('one line per entry, with a warning icon', (tester) async {
    await pump(tester, [
      BelowMinimum(
        productCode: 'A-100',
        quantity: Decimal.fromInt(5),
        minimum: 12,
      ),
      BelowMinimum(
        productCode: 'C-007',
        quantity: Decimal.fromInt(2),
        minimum: 6,
      ),
    ]);

    expect(find.byKey(const Key('request_minimum_band')), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    expect(
      find.text(l10n.purchaseRequestBelowMinimum('A-100', '5', '12')),
      findsOneWidget,
    );
    expect(
      find.text(l10n.purchaseRequestBelowMinimum('C-007', '2', '6')),
      findsOneWidget,
    );
  });

  testWidgets('nothing for an empty list', (tester) async {
    await pump(tester, const []);

    expect(find.byKey(const Key('request_minimum_band')), findsNothing);
    expect(find.byIcon(Icons.warning_amber_outlined), findsNothing);
  });
}
