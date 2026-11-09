import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refund_confirm_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

/// Spec 057 US1 (T022), contracts C5: the confirm dialog has no default
/// choice, and each choice returns its payout.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  /// Opens the dialog from a button; [result] receives what it returned.
  Future<void> openDialog(
    WidgetTester tester,
    List<RefundPayout?> result,
  ) async {
    await pumpPos(
      tester,
      Builder(
        builder: (context) => TextButton(
          key: const Key('open'),
          onPressed: () async => result.add(
            await showRefundConfirmDialog(context, total: '20.00'),
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
  }

  bool submitEnabled(WidgetTester tester) => tester
      .widget<ButtonStyleButton>(find.byKey(const Key('refund_confirm_submit')))
      .enabled;

  testWidgets('nothing is selected and confirm is disabled until a choice', (
    tester,
  ) async {
    await openDialog(tester, []);

    expect(find.byKey(const Key('refund_confirm_dialog')), findsOneWidget);
    expect(find.textContaining('20.00'), findsOneWidget);
    expect(find.byKey(const Key('refund_payout_cash')), findsOneWidget);
    expect(find.byKey(const Key('refund_payout_credit_note')), findsOneWidget);
    expect(find.text(l10n.refundPayoutCash), findsOneWidget);
    expect(submitEnabled(tester), isFalse);

    await tester.tap(find.byKey(const Key('refund_payout_cash')));
    await tester.pumpAndSettle();

    expect(submitEnabled(tester), isTrue);
  });

  for (final (key, payout) in [
    ('refund_payout_cash', RefundPayout.cash),
    ('refund_payout_credit_note', RefundPayout.creditNote),
  ]) {
    testWidgets('choosing $key returns $payout', (tester) async {
      final result = <RefundPayout?>[];
      await openDialog(tester, result);

      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('refund_confirm_submit')));
      await tester.pumpAndSettle();

      expect(result, [payout]);
      expect(find.byKey(const Key('refund_confirm_dialog')), findsNothing);
    });
  }

  testWidgets('backing out returns null', (tester) async {
    final result = <RefundPayout?>[];
    await openDialog(tester, result);

    await tester.tap(find.text(l10n.refundConfirmBack));
    await tester.pumpAndSettle();

    expect(result, [null]);
  });
}
