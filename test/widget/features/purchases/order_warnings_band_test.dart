import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/order_warnings_band.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/purchases/purchase_order_fixtures.dart';

/// Spec 080 US1 (T012), FR-019: the price-0 band.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  Future<void> pump(WidgetTester tester, List<PurchaseOrderLine> lines) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es', 'MX'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: OrderWarningsBand(zeroPriceLines: lines)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('one line per product, with a warning icon', (tester) async {
    await pump(tester, [
      anOrderLine(code: 'C-007', name: 'Rondana', price: '0'),
      anOrderLine(id: 901, code: 'B-220', name: 'Taquete 5/16', price: '0'),
    ]);

    expect(find.byKey(const Key('order_warnings_band')), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    expect(
      find.text(l10n.purchaseOrderZeroPriceWarning('C-007', 'Rondana')),
      findsOneWidget,
    );
    expect(
      find.text(l10n.purchaseOrderZeroPriceWarning('B-220', 'Taquete 5/16')),
      findsOneWidget,
    );
  });

  testWidgets('nothing for an empty list', (tester) async {
    await pump(tester, const []);

    expect(find.byKey(const Key('order_warnings_band')), findsNothing);
    expect(find.byIcon(Icons.warning_amber_outlined), findsNothing);
  });
}
