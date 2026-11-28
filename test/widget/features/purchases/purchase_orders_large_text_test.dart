import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_detail_screen.dart';
import 'package:mbe_ui/features/purchases/presentation/to_purchase/to_purchase_screen.dart';

import '../../../unit/features/purchases/purchase_order_fixtures.dart';
import '../../../unit/features/purchases/purchase_request_fixtures.dart';
import 'purchases_harness.dart';

/// Spec 080 T035 (constitution §V, quickstart step 15): at the largest text
/// level, the Órdenes de compra list, Por comprar, a draft order's detail
/// and a confirmed order's detail must not overflow at a supported desktop
/// width, as `purchases_large_text_test.dart` checks for requests.
void main() {
  const desktop = Size(1280, 800);
  const longName =
      'Tornillo hexagonal galvanizado de alta resistencia 1/4 x 2 pulgadas, '
      'caja con 100 piezas';
  const longSupplier =
      'Distribuidora Ferretera e Industrial del Norte de México, S.A. de C.V.';
  const longComment =
      'Urgente para el fin de semana: entregar en el andén 2 antes del '
      'inventario físico de fin de mes';

  void useExtraLargeText(WidgetTester tester) {
    tester.platformDispatcher.textScaleFactorTestValue =
        TextSizeLevel.extraLarge.factor;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  /// Every right the screens check: 20 full, 86 read, plus Facilities,
  /// Employees, Suppliers and InventoryReceipts read.
  final everyRight = PurchasesHarness.user(
    requestRights: 2,
    orderRights: 15,
    facilitiesRead: true,
    employeesRead: true,
    suppliersRead: true,
    receiptsRead: true,
  );

  testWidgets('the orders list with several rows at the largest text level '
      'does not overflow', (tester) async {
    useExtraLargeText(tester);
    final h = PurchasesHarness();
    h.serveOrders([
      anOrderSummary(
        supplierName: longSupplier,
        estimatedReceiptDate: DateTime(2026, 12, 5),
        lineCount: 128,
        total: '1234567.89',
      ),
      anOrderSummary(
        id: 110490,
        status: InventoryDocumentStatus.completed,
        supplierName: longSupplier,
        lineCount: 7,
      ),
      anOrderSummary(id: 311, status: InventoryDocumentStatus.cancelled),
      anOrderSummary(id: 312, supplierId: null, supplierName: null),
    ]);
    await h.pump(
      tester,
      who: everyRight,
      location: purchaseOrdersPath,
      surface: desktop,
    );

    expect(key('purchase_orders_table'), findsOneWidget);
    expect(key('purchase_order_number_110490'), findsOneWidget);
    expect(key('purchase_orders_new_button'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Por comprar with several groups, one expanded, at the largest '
      'text level does not overflow', (tester) async {
    useExtraLargeText(tester);
    final h = PurchasesHarness();
    final groups = [
      aToPurchaseGroup(
        supplierName: longSupplier,
        lines: [
          aToPurchaseLine(serial: 12571).copyWith(productName: longName),
          aToPurchaseLine(
            requestLineId: 901,
            serial: 566,
            cost: '0',
          ).copyWith(productName: longName),
        ],
      ).copyWith(estimatedTotal: Decimal.parse('1234567.89')),
      aToPurchaseGroup(
        supplierId: 13,
        supplierName: longSupplier,
        facilityId: 5,
        lines: [aToPurchaseLine(requestLineId: 902)],
      ),
      aToPurchaseGroup(
        supplierId: null,
        supplierName: null,
        lines: [aToPurchaseLine(requestLineId: 903)],
      ),
    ];
    when(
      () => h.orders.toPurchase(facilityId: any(named: 'facilityId')),
    ).thenAnswer((_) async => groups);
    await h.pump(
      tester,
      who: everyRight,
      location: toPurchasePath,
      surface: desktop,
    );

    await tester.tap(key('to_purchase_group_toggle_12_2'));
    await tester.pumpAndSettle();

    expect(key('to_purchase_group_lines_12_2'), findsOneWidget);
    expect(key('to_purchase_group_total_12_2'), findsOneWidget);
    expect(key('to_purchase_group_radio_13_5'), findsOneWidget);
    expect(key('to_purchase_create_order'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a draft with a request line, the price-0 band and every draft '
      'action at the largest text level does not overflow', (tester) async {
    useExtraLargeText(tester);
    final h = PurchasesHarness();
    when(
      () => h.requests.get(212),
    ).thenAnswer((_) async => aRequest(serial: 12571));
    await h.pumpOrder(
      tester,
      anOrder(
        supplierName: longSupplier,
        estimatedReceiptDate: DateTime(2026, 12, 5),
        lines: [
          anOrderLine(
            name: longName,
            quantity: '12345.678',
            price: '98765.43',
            requestId: 212,
          ),
          anOrderLine(
            id: 901,
            code: 'B-220-XL-LARGO',
            name: longName,
            price: '0',
            warehouseId: 4,
          ),
        ],
      ).copyWith(comment: longComment),
      who: everyRight,
      surface: desktop,
    );

    expect(key('purchase_order_lines_table'), findsOneWidget);
    expect(key('purchase_order_line_request_900'), findsOneWidget);
    expect(key('order_warnings_band'), findsOneWidget);
    expect(key('purchase_order_line_edit_900'), findsOneWidget);
    expect(key('purchase_order_line_remove_901'), findsOneWidget);
    expect(key('purchase_order_cancel'), findsOneWidget);
    expect(key('purchase_order_edit_header'), findsOneWidget);
    expect(key('purchase_order_add_request'), findsOneWidget);
    expect(key('purchase_order_add_product'), findsOneWidget);
    expect(key('purchase_order_confirm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a confirmed order with receipts and the received and pending '
      'columns at the largest text level does not overflow', (tester) async {
    useExtraLargeText(tester);
    final h = PurchasesHarness();
    when(
      () => h.requests.get(212),
    ).thenAnswer((_) async => aRequest(serial: 12571));
    await h.pumpOrder(
      tester,
      anOrder(
        status: InventoryDocumentStatus.completed,
        supplierName: longSupplier,
        receipts: [
          aReceipt(id: 8812),
          aReceipt(id: 8813, warehouseId: 4, facilityId: 5),
        ],
        lines: [
          anOrderLine(
            name: longName,
            quantity: '12345.678',
            received: '5',
            pending: '12340.678',
            requestId: 212,
          ),
          anOrderLine(
            id: 901,
            code: 'B-220-XL-LARGO',
            name: longName,
            quantity: '24',
            warehouseId: 4,
            received: '24',
            pending: '0',
          ),
        ],
      ).copyWith(comment: longComment),
      who: everyRight,
      surface: desktop,
    );

    expect(key('purchase_order_receipts'), findsOneWidget);
    expect(key('purchase_order_receipt_open_8813'), findsOneWidget);
    expect(key('purchase_order_line_received_900'), findsOneWidget);
    expect(key('purchase_order_line_pending_901'), findsOneWidget);
    expect(key('purchase_order_line_request_900'), findsOneWidget);
    expect(key('purchase_order_print'), findsOneWidget);
    expect(key('purchase_order_email'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
