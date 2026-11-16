import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/inventory/domain/over_receipt.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/receipt_warnings.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Spec 067 US5 (T029), FR-015 and FR-015a: the over-receipt band, the cost
/// notice band and its per-receipt state.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  OverReceipt over(String code, int received, int ordered) => OverReceipt(
    productCode: code,
    received: Decimal.fromInt(received),
    ordered: Decimal.fromInt(ordered),
    excess: Decimal.fromInt(received - ordered),
  );

  Future<void> pump(WidgetTester tester, Widget child) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ReceiptOverReceiptBand', () {
    testWidgets('lists each excess', (tester) async {
      await pump(
        tester,
        ReceiptOverReceiptBand(
          overReceipts: [over('A-100', 13, 10), over('B-200', 7, 5)],
        ),
      );

      expect(
        find.text(l10n.inventoryReceiptOverReceipt('A-100', '3', '13', '10')),
        findsOneWidget,
      );
      expect(
        find.text(l10n.inventoryReceiptOverReceipt('B-200', '2', '7', '5')),
        findsOneWidget,
      );
    });

    testWidgets('is absent when there is none', (tester) async {
      await pump(tester, const ReceiptOverReceiptBand(overReceipts: []));

      expect(key('receipt_over_receipt_band'), findsNothing);
    });
  });

  group('cost notice', () {
    /// The band for receipt [id], driven by its notice state, plus a button
    /// that shows it.
    Widget notice(int id) => Consumer(
      key: ValueKey(id),
      builder: (context, ref, _) => Column(
        children: [
          TextButton(
            key: const Key('show'),
            onPressed: () =>
                ref.read(receiptCostNoticeProvider(id).notifier).show(),
            child: const Text('show'),
          ),
          if (ref.watch(receiptCostNoticeProvider(id)))
            ReceiptCostNoticeBand(
              onClose: () =>
                  ref.read(receiptCostNoticeProvider(id).notifier).dismiss(),
            ),
        ],
      ),
    );

    testWidgets('shows, and the close button dismisses it', (tester) async {
      await pump(tester, notice(318));
      expect(key('receipt_cost_notice_band'), findsNothing);

      await tester.tap(key('show'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.inventoryReceiptCostNotice), findsOneWidget);

      await tester.tap(key('receipt_cost_notice_close'));
      await tester.pumpAndSettle();
      expect(key('receipt_cost_notice_band'), findsNothing);
    });

    testWidgets('clears when the screen is rebuilt for another receipt', (
      tester,
    ) async {
      await pump(tester, notice(318));
      await tester.tap(key('show'));
      await tester.pumpAndSettle();
      expect(key('receipt_cost_notice_band'), findsOneWidget);

      await pump(tester, notice(319));
      expect(key('receipt_cost_notice_band'), findsNothing);

      // Back on the first receipt: its state was disposed with the screen.
      await pump(tester, notice(318));
      expect(key('receipt_cost_notice_band'), findsNothing);
    });
  });
}

Finder key(String k) => find.byKey(Key(k));
