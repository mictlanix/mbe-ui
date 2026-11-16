import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_receipt_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 067 US3 (T023), FR-006, FR-016, FR-017 and research R8: "Editar
/// encabezado", opened from a draft's detail screen.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(EntityStatus.active);
  });

  setUp(() {
    h = InventoryHarness();
    h.serveWarehouses([aWarehouse(3), aWarehouse(4)]);
  });

  void answerUpdate([InventoryReceipt? result]) => when(
    () => h.receipts.updateHeader(
      318,
      warehouseId: any(named: 'warehouseId'),
      comment: any(named: 'comment'),
      clearComment: any(named: 'clearComment'),
    ),
  ).thenAnswer((_) async => result ?? aReceipt());

  Future<void> open(
    WidgetTester tester, {
    InventoryReceipt? receipt,
    User? who,
  }) async {
    await h.pumpReceipt(
      tester,
      receipt ?? aReceipt(comment: 'Sin factura'),
      who: who,
    );
    await tester.tap(key('inventory_receipt_edit_header'));
    await tester.pumpAndSettle();
  }

  Finder warehouseField() => find.descendant(
    of: key('receipt_header_warehouse'),
    matching: find.byType(TextField),
  );

  FilledButton submit(WidgetTester tester) =>
      tester.widget<FilledButton>(key('receipt_header_submit'));

  Future<void> save(WidgetTester tester) async {
    await tester.tap(key('receipt_header_submit'));
    await tester.pumpAndSettle();
  }

  testWidgets('starts on the receipt\'s warehouse and notes, and unchanged '
      'can\'t be saved', (tester) async {
    await open(tester);

    expect(key('receipt_header_dialog'), findsOneWidget);
    expect(
      tester.widget<TextField>(warehouseField()).controller!.text,
      'Almacén 3',
    );
    expect(
      tester.widget<TextField>(key('receipt_header_comment')).controller!.text,
      'Sin factura',
    );
    expect(submit(tester).onPressed, isNull);
  });

  testWidgets('only the changed notes are sent', (tester) async {
    answerUpdate(aReceipt(comment: 'Con factura'));
    await open(tester);

    await tester.enterText(key('receipt_header_comment'), 'Con factura');
    await tester.pumpAndSettle();
    await save(tester);

    verify(
      () => h.receipts.updateHeader(
        318,
        warehouseId: null,
        comment: 'Con factura',
        clearComment: false,
      ),
    ).called(1);
    expect(key('receipt_header_dialog'), findsNothing);
    expect(find.text('Con factura'), findsOneWidget);
  });

  testWidgets('only the changed warehouse is sent', (tester) async {
    answerUpdate(aReceipt(warehouseId: 4, comment: 'Sin factura'));
    await open(tester);

    await tester.enterText(warehouseField(), 'Alm');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Almacén 4').last);
    await tester.pumpAndSettle();
    await save(tester);

    verify(
      () => h.receipts.updateHeader(
        318,
        warehouseId: 4,
        comment: null,
        clearComment: false,
      ),
    ).called(1);
    expect(find.text('Almacén 4'), findsOneWidget);
  });

  testWidgets('clearing the notes is sent as clearComment', (tester) async {
    answerUpdate();
    await open(tester);

    await tester.enterText(key('receipt_header_comment'), '');
    await tester.pumpAndSettle();
    await save(tester);

    verify(
      () => h.receipts.updateHeader(
        318,
        warehouseId: null,
        comment: null,
        clearComment: true,
      ),
    ).called(1);
  });

  testWidgets('notes over 500 characters can\'t be saved', (tester) async {
    await open(tester);

    await tester.enterText(key('receipt_header_comment'), 'x' * 501);
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNull);

    await tester.enterText(key('receipt_header_comment'), 'x' * 500);
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNotNull);
  });

  testWidgets('a linked receipt shows its warehouse as fixed text', (
    tester,
  ) async {
    await open(tester, receipt: aReceipt(purchaseOrderId: 5512));

    expect(key('receipt_header_warehouse'), findsNothing);
    expect(key('receipt_header_warehouse_text'), findsOneWidget);
    expect(
      find.text('(${l10n.inventoryReceiptWarehouseFixed})'),
      findsOneWidget,
    );
  });

  testWidgets('without Warehouses (4) read the warehouse is text and the '
      'notes can still be saved', (tester) async {
    answerUpdate();
    await open(tester, who: InventoryHarness.user(warehousesRead: false));

    expect(key('receipt_header_warehouse'), findsNothing);
    expect(key('receipt_header_warehouse_text'), findsOneWidget);
    expect(find.text('(${l10n.inventoryReceiptWarehouseFixed})'), findsNothing);

    await tester.enterText(key('receipt_header_comment'), 'Nota');
    await tester.pumpAndSettle();
    await save(tester);

    verify(
      () => h.receipts.updateHeader(
        318,
        warehouseId: null,
        comment: 'Nota',
        clearComment: false,
      ),
    ).called(1);
  });

  testWidgets('a non-administrator\'s picker is limited to their facility', (
    tester,
  ) async {
    await open(tester);

    await tester.enterText(warehouseField(), 'Alm');
    await tester.pumpAndSettle();

    verify(
      () => h.warehouses.list(
        search: 'Alm',
        facilityId: 2,
        status: EntityStatus.active,
        limit: 10,
      ),
    ).called(greaterThan(0));
  });

  testWidgets('a refusal stays in the dialog, localized', (tester) async {
    when(
      () => h.receipts.updateHeader(
        318,
        warehouseId: any(named: 'warehouseId'),
        comment: any(named: 'comment'),
        clearComment: any(named: 'clearComment'),
      ),
    ).thenAnswer(
      (_) async => throw aRefusal(
        api.ErrorCode.warehousePeriodInTransitLocation,
        'warehouse.in_transit_location',
        {'warehouse_id': 4},
      ),
    );
    await open(tester);

    await tester.enterText(warehouseField(), 'Alm');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Almacén 4').last);
    await tester.pumpAndSettle();
    await save(tester);

    expect(key('receipt_header_dialog'), findsOneWidget);
    expect(key('receipt_header_refusal'), findsOneWidget);
    expect(find.text('SERVER TEXT'), findsNothing);
  });
}
