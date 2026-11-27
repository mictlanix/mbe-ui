import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/presentation/approval/purchase_request_approval_screen.dart';

import '../../../unit/features/purchases/purchase_request_fixtures.dart';
import 'purchases_harness.dart';

/// Spec 079 T037 (constitution §V, quickstart step 14): at the largest text
/// level, the Solicitudes de compra list, a request's detail (lines table
/// and action area) and the approval queue must not overflow at a supported
/// desktop width. The platform scale stands in for the user's extra-large
/// level, as in `inventory_receipts_large_text_test.dart`.
void main() {
  const desktop = Size(1280, 800);
  const longName =
      'Tornillo hexagonal galvanizado de alta resistencia 1/4 x 2 pulgadas, '
      'caja con 100 piezas';
  const longComment =
      'Urgente para el fin de semana: reponer existencias de la sucursal '
      'antes del inventario físico de fin de mes';

  void useExtraLargeText(WidgetTester tester) {
    tester.platformDispatcher.textScaleFactorTestValue =
        TextSizeLevel.extraLarge.factor;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  /// Every right the screens check: 86 full, 96 read + update, 20 read +
  /// update, plus Facilities and Employees read.
  final everyRight = PurchasesHarness.user(
    approvalRights: 2 | 4,
    orderRights: 2 | 4,
    facilitiesRead: true,
    employeesRead: true,
  );

  testWidgets('the list with several rows at the largest text level does '
      'not overflow', (tester) async {
    useExtraLargeText(tester);
    final h = PurchasesHarness();
    h.serve([
      aRequestSummary(lineCount: 0, comment: longComment),
      aRequestSummary(
        id: 230,
        serial: 12571,
        status: PurchaseRequestStatus.submitted,
        lineCount: 128,
        comment: longComment,
      ),
      aRequestSummary(
        id: 231,
        serial: 12572,
        status: PurchaseRequestStatus.approved,
        lineCount: 7,
      ),
      aRequestSummary(
        id: 232,
        serial: 12573,
        status: PurchaseRequestStatus.cancelled,
        lineCount: 3,
      ),
      aRequestSummary(id: 228, serial: 569, lineCount: 3),
    ]);
    await h.pump(tester, who: everyRight, surface: desktop);

    expect(key('purchase_requests_table'), findsOneWidget);
    expect(key('purchase_request_folio_230'), findsOneWidget);
    expect(key('purchase_requests_new_button'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a submitted request with every action, a line on a purchase '
      'order and the minimum band at the largest text level does not '
      'overflow', (tester) async {
    useExtraLargeText(tester);
    final h = PurchasesHarness();
    await h.pumpRequest(
      tester,
      aRequest(
        serial: 12571,
        status: PurchaseRequestStatus.submitted,
        comment: longComment,
        lines: [
          aRequestLine(
            quantity: '12345.678',
            minOrderQty: 20000,
            toPurchase: true,
            purchaseOrderId: 110490,
            purchaseOrderStatus: InventoryDocumentStatus.completed,
          ).copyWith(productName: longName),
          aRequestLine(
            id: 901,
            productId: 8,
            code: 'B-220-XL-LARGO',
            quantity: '5',
            warehouseId: 4,
            minOrderQty: 12,
          ).copyWith(productName: longName),
        ],
      ),
      who: everyRight,
      surface: desktop,
    );

    expect(key('purchase_request_lines_table'), findsOneWidget);
    expect(key('purchase_request_line_order_900'), findsOneWidget);
    expect(key('request_minimum_band'), findsOneWidget);
    expect(key('purchase_request_cancel'), findsOneWidget);
    expect(key('purchase_request_reject'), findsOneWidget);
    expect(key('purchase_request_approve'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a draft with its row icons and draft actions at the largest '
      'text level does not overflow', (tester) async {
    useExtraLargeText(tester);
    final h = PurchasesHarness();
    await h.pumpRequest(
      tester,
      aRequest(
        comment: longComment,
        lines: [
          aRequestLine(
            quantity: '5',
            minOrderQty: 12,
          ).copyWith(productName: longName),
          aRequestLine(
            id: 901,
            productId: 8,
            code: 'B-220-XL-LARGO',
            quantity: '12345.678',
            warehouseId: 4,
            toPurchase: true,
          ).copyWith(productName: longName),
        ],
      ),
      who: everyRight,
      surface: desktop,
    );

    expect(key('purchase_request_line_edit_900'), findsOneWidget);
    expect(key('purchase_request_line_remove_901'), findsOneWidget);
    expect(key('purchase_request_cancel'), findsOneWidget);
    expect(key('purchase_request_edit_header'), findsOneWidget);
    expect(key('purchase_request_add_product'), findsOneWidget);
    expect(key('purchase_request_submit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the approval queue with checkboxes, ✓ and the bulk button at '
      'the largest text level does not overflow', (tester) async {
    useExtraLargeText(tester);
    final h = PurchasesHarness();
    h.serveQueue([
      for (final (id, serial) in [(1, 12571), (2, 92), (3, 318)])
        aRequestSummary(
          id: id,
          serial: serial,
          status: PurchaseRequestStatus.submitted,
          facilityId: id == 3 ? 5 : 2,
          lineCount: id * 42,
          comment: id == 2 ? null : longComment,
        ),
    ]);
    await h.pump(
      tester,
      who: everyRight,
      location: purchaseRequestApprovalPath,
      surface: desktop,
    );

    expect(key('purchase_request_approval_table'), findsOneWidget);
    expect(key('purchase_request_select_all'), findsOneWidget);
    expect(key('purchase_request_select_1'), findsOneWidget);
    expect(key('purchase_request_approve_1'), findsOneWidget);
    expect(key('purchase_request_approve_selected'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
