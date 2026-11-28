import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/purchases/purchase_order_fixtures.dart';
import 'purchases_harness.dart';

/// Spec 080 US2 (T021), FR-021 and research R11: the confirm prompt, opened
/// from a draft order's Confirmar; US5 (T032): the remove-line and cancel
/// prompts.
void main() {
  late PurchasesHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => h = PurchasesHarness());

  final buyer = PurchasesHarness.user(requestRights: 0, orderRights: 15);

  Future<void> open(WidgetTester tester, PurchaseOrder order) async {
    await h.pumpOrder(tester, order, who: buyer);
    await tester.tap(key('purchase_order_confirm'));
    await tester.pumpAndSettle();
  }

  Finder inDialog(Finder f) =>
      find.descendant(of: key('purchase_order_confirm_dialog'), matching: f);

  testWidgets('summarises the order, names each warehouse once and says it '
      "can't be undone", (tester) async {
    await open(
      tester,
      anOrder(
        lines: [
          anOrderLine(),
          anOrderLine(id: 901, warehouseId: 4),
          anOrderLine(id: 902),
        ],
      ),
    );

    expect(find.text(l10n.purchaseOrderConfirmTitle('310')), findsOneWidget);
    expect(
      tester.widget<Text>(key('purchase_order_confirm_summary')).data,
      l10n.purchaseOrderConfirmSummary(
        'Ferretera del Norte',
        l10n.toPurchaseLineCount(3),
        r'$1,160.00',
      ),
    );
    expect(
      tester.widget<Text>(key('purchase_order_confirm_warehouses')).data,
      l10n.purchaseOrderConfirmReceipts('Almacén 3, Almacén 4'),
    );
    expect(key('purchase_order_confirm_zero_price'), findsNothing);
    expect(
      inDialog(find.text(l10n.purchaseOrderConfirmIrreversible)),
      findsOneWidget,
    );
  });

  testWidgets('names the zero-priced lines', (tester) async {
    await open(
      tester,
      anOrder(
        lines: [
          anOrderLine(),
          anOrderLine(id: 901, code: 'C-007', name: 'Rondana', price: '0'),
        ],
      ),
    );

    expect(key('purchase_order_confirm_zero_price'), findsOneWidget);
    expect(
      inDialog(
        find.text(l10n.purchaseOrderConfirmZeroPrice(1, 'C-007 Rondana')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('"Volver" closes it without confirming', (tester) async {
    await open(tester, anOrder());

    await tester.tap(inDialog(find.text(l10n.purchaseOrderBack)));
    await tester.pumpAndSettle();

    expect(key('purchase_order_confirm_dialog'), findsNothing);
    verifyNever(() => h.orders.confirm(any()));
  });

  group('remove-line prompt (T032)', () {
    testWidgets('names the product, and "Volver" keeps the line', (
      tester,
    ) async {
      await h.pumpOrder(tester, anOrder(), who: buyer);
      await tester.tap(key('purchase_order_line_remove_900'));
      await tester.pumpAndSettle();

      expect(key('purchase_order_line_remove_dialog'), findsOneWidget);
      expect(find.text(l10n.purchaseOrderRemoveTitle), findsOneWidget);
      expect(
        tester.widget<Text>(key('purchase_order_line_remove_body')).data,
        l10n.purchaseOrderRemoveBody('A-100 Tornillo 1/4 caja'),
      );

      await tester.tap(find.text(l10n.purchaseOrderBack));
      await tester.pumpAndSettle();

      expect(key('purchase_order_line_remove_dialog'), findsNothing);
      verifyNever(() => h.orders.removeLine(any(), any()));
    });
  });

  group('cancel prompt (T032)', () {
    testWidgets('explains what cancelling does, and "Volver" keeps the '
        'order', (tester) async {
      await h.pumpOrder(tester, anOrder(), who: buyer);
      await tester.tap(key('purchase_order_cancel'));
      await tester.pumpAndSettle();

      expect(key('purchase_order_cancel_dialog'), findsOneWidget);
      expect(find.text(l10n.purchaseOrderCancelTitle('310')), findsOneWidget);
      expect(
        tester.widget<Text>(key('purchase_order_cancel_body')).data,
        l10n.purchaseOrderCancelBody,
      );

      await tester.tap(find.text(l10n.purchaseOrderBack));
      await tester.pumpAndSettle();

      expect(key('purchase_order_cancel_dialog'), findsNothing);
      verifyNever(() => h.orders.cancel(any()));
    });
  });
}
