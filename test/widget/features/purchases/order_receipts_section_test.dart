import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/purchases/purchase_order_fixtures.dart';
import 'purchases_harness.dart';

/// Spec 080 US2 (T021), FR-022 and research R11: the "Entradas" section on a
/// confirmed order's detail.
void main() {
  late PurchasesHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => h = PurchasesHarness());

  final confirmed = anOrder(
    status: InventoryDocumentStatus.completed,
    receipts: [
      aReceipt(id: 8812),
      aReceipt(id: 8813, warehouseId: 4, facilityId: 5),
    ],
  );

  testWidgets('a row per receipt: number, warehouse, facility and lines', (
    tester,
  ) async {
    await h.pumpOrder(
      tester,
      confirmed,
      who: PurchasesHarness.user(orderRights: 2, receiptsRead: true),
    );

    expect(find.text(l10n.purchaseOrderReceiptsTitle), findsOneWidget);
    final first = key('purchase_order_receipt_8812');
    final second = key('purchase_order_receipt_8813');
    expect(
      find.descendant(
        of: first,
        matching: find.text(l10n.purchaseOrderReceiptItem('8812')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: first, matching: find.text('Almacén 3')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: first, matching: find.text('Sucursal 2')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: second, matching: find.text('Almacén 4')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: second, matching: find.text('Sucursal 5')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: first,
        matching: find.text(l10n.toPurchaseLineCount(1)),
      ),
      findsOneWidget,
    );
  });

  testWidgets('"Abrir" opens the receipt with InventoryReceipts (15) read', (
    tester,
  ) async {
    final router = await h.pumpOrder(
      tester,
      confirmed,
      who: PurchasesHarness.user(orderRights: 2, receiptsRead: true),
    );

    await tester.tap(key('purchase_order_receipt_open_8813'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/inventory/receipts/8813');
    expect(key('receipt_stand_in'), findsOneWidget);
  });

  testWidgets('"Abrir" is absent without InventoryReceipts (15) read', (
    tester,
  ) async {
    await h.pumpOrder(
      tester,
      confirmed,
      who: PurchasesHarness.user(orderRights: 2),
    );

    expect(key('purchase_order_receipts'), findsOneWidget);
    expect(key('purchase_order_receipt_open_8812'), findsNothing);
    expect(find.text(l10n.purchaseOrderReceiptOpen), findsNothing);
  });

  testWidgets('nothing renders without receipts, as on a reload', (
    tester,
  ) async {
    await h.pumpOrder(
      tester,
      anOrder(status: InventoryDocumentStatus.completed),
      who: PurchasesHarness.user(orderRights: 2, receiptsRead: true),
    );

    expect(key('purchase_order_receipts'), findsNothing);
    expect(find.text(l10n.purchaseOrderReceiptsTitle), findsNothing);
  });
}
