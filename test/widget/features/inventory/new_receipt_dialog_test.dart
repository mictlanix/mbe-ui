import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_receipt_fixtures.dart';
import 'inventory_harness.dart';

const _pointSale = PointSale(
  pointSaleId: 11,
  facilityId: 2,
  facilityName: 'Sucursal 2',
  code: 'POS1',
  name: 'Caja 1',
  warehouseId: 3,
  warehouseName: 'Almacén 3',
  status: EntityStatus.active,
);

/// Spec 067 US2 (T020), FR-005 and FR-017: "Nueva entrada", opened from the
/// list's button.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(EntityStatus.active);
  });

  setUp(() {
    h = InventoryHarness();
    h.serve(const []);
    h.serveWarehouses([aWarehouse(3), aWarehouse(4)]);
    when(
      () => h.pointSales.get(pointSaleId: 11),
    ).thenAnswer((_) async => _pointSale);
    when(
      () => h.warehouses.get(warehouseId: 3),
    ).thenAnswer((_) async => aWarehouse(3));
  });

  Future<void> open(WidgetTester tester, {bool administrator = false}) async {
    await h.pump(
      tester,
      who: InventoryHarness.user(administrator: administrator, pointSaleId: 11),
    );
    await tester.tap(key('inventory_receipts_new_button'));
    await tester.pumpAndSettle();
  }

  Finder warehouseField() => find.descendant(
    of: key('new_inventory_receipt_warehouse'),
    matching: find.byType(TextField),
  );

  String warehouseText(WidgetTester tester) =>
      tester.widget<TextField>(warehouseField()).controller!.text;

  FilledButton submit(WidgetTester tester) =>
      tester.widget<FilledButton>(key('new_inventory_receipt_submit'));

  testWidgets('starts on the point-of-sale warehouse', (tester) async {
    await open(tester);

    expect(key('new_inventory_receipt_dialog'), findsOneWidget);
    expect(warehouseText(tester), 'Almacén 3');
    expect(submit(tester).onPressed, isNotNull);
  });

  testWidgets('starts empty for a non-administrator whose point-of-sale '
      'warehouse is in another facility', (tester) async {
    when(
      () => h.warehouses.get(warehouseId: 3),
    ).thenAnswer((_) async => aWarehouse(3, facilityId: 9));
    await open(tester);

    expect(warehouseText(tester), isEmpty);
    expect(submit(tester).onPressed, isNull);
  });

  testWidgets('a non-administrator is offered their own facility\'s '
      'warehouses', (tester) async {
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

  testWidgets('an administrator is offered every warehouse', (tester) async {
    await open(tester, administrator: true);

    await tester.enterText(warehouseField(), 'Alm');
    await tester.pumpAndSettle();

    verify(
      () => h.warehouses.list(
        search: 'Alm',
        facilityId: null,
        status: EntityStatus.active,
        limit: 10,
      ),
    ).called(greaterThan(0));
  });

  testWidgets('a non-administrator with no facility is told so and offered '
      'nothing', (tester) async {
    await h.pump(tester, who: InventoryHarness.user(facilityId: null));
    await tester.tap(key('inventory_receipts_new_button'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.inventoryReceiptNoFacility), findsOneWidget);
    await tester.enterText(warehouseField(), 'Alm');
    await tester.pumpAndSettle();
    verifyNever(
      () => h.warehouses.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        limit: any(named: 'limit'),
      ),
    );
  });

  testWidgets('notes over 500 characters can\'t be submitted', (tester) async {
    await open(tester);

    await tester.enterText(key('new_inventory_receipt_comment'), 'x' * 501);
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNull);

    await tester.enterText(key('new_inventory_receipt_comment'), 'x' * 500);
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNotNull);
  });

  testWidgets('a refusal stays in the dialog, localized', (tester) async {
    when(
      () => h.receipts.create(
        warehouseId: any(named: 'warehouseId'),
        comment: any(named: 'comment'),
      ),
    ).thenAnswer(
      (_) async => throw aRefusal(
        api.ErrorCode.warehousePeriodInTransitLocation,
        'warehouse.in_transit_location',
        {'warehouse_id': 3},
      ),
    );
    await open(tester);

    await tester.tap(key('new_inventory_receipt_submit'));
    await tester.pumpAndSettle();

    expect(key('new_inventory_receipt_dialog'), findsOneWidget);
    expect(key('new_inventory_receipt_refusal'), findsOneWidget);
    expect(find.text('SERVER TEXT'), findsNothing);
  });

  testWidgets('success sends the warehouse and notes, then opens the new '
      'receipt', (tester) async {
    when(
      () => h.receipts.create(
        warehouseId: any(named: 'warehouseId'),
        comment: any(named: 'comment'),
      ),
    ).thenAnswer((_) async => aReceipt(id: 400, lines: const []));
    h.stubReceipt(aReceipt(id: 400, lines: const []));
    await open(tester);

    await tester.enterText(key('new_inventory_receipt_comment'), 'Sin factura');
    await tester.pumpAndSettle();
    await tester.tap(key('new_inventory_receipt_submit'));
    await tester.pumpAndSettle();

    verify(
      () => h.receipts.create(warehouseId: 3, comment: 'Sin factura'),
    ).called(1);
    expect(key('new_inventory_receipt_dialog'), findsNothing);
    expect(find.text(l10n.inventoryReceiptTitleDraft('400')), findsOneWidget);
  });

  testWidgets('the button is absent without create on 15', (tester) async {
    await h.pump(tester, who: InventoryHarness.user(receipts: 2 | 4));
    expect(key('inventory_receipts_new_button'), findsNothing);
  });

  testWidgets('the button is absent without Warehouses (4) read', (
    tester,
  ) async {
    await h.pump(tester, who: InventoryHarness.user(warehousesRead: false));
    expect(key('inventory_receipts_new_button'), findsNothing);
  });
}
