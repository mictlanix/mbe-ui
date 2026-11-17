import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_transfer_fixtures.dart';
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

/// Spec 069 US2 (T018), FR-005 and FR-021: "Nuevo traspaso", opened from the
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
    h.serveTransfers(const []);
    h.serveWarehouses([aWarehouse(3), aWarehouse(4)]);
    when(
      () => h.pointSales.get(pointSaleId: 11),
    ).thenAnswer((_) async => _pointSale);
    when(
      () => h.warehouses.get(warehouseId: 3),
    ).thenAnswer((_) async => aWarehouse(3));
  });

  Future<void> open(WidgetTester tester, {bool administrator = false}) async {
    await h.pumpTransfers(
      tester,
      who: InventoryHarness.transferUser(
        administrator: administrator,
        pointSaleId: 11,
      ),
    );
    await tester.tap(key('inventory_transfers_new_button'));
    await tester.pumpAndSettle();
  }

  Finder field(String k) =>
      find.descendant(of: key(k), matching: find.byType(TextField));

  String text(WidgetTester tester, String k) =>
      tester.widget<TextField>(field(k)).controller!.text;

  FilledButton submit(WidgetTester tester) =>
      tester.widget<FilledButton>(key('new_inventory_transfer_submit'));

  Future<void> pickDestination(WidgetTester tester) async {
    await tester.enterText(field('new_inventory_transfer_destination'), 'Alm');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Almacén 4').last);
    await tester.pumpAndSettle();
  }

  testWidgets('the origin starts on the point-of-sale warehouse and the '
      'destination empty', (tester) async {
    await open(tester);

    expect(key('new_inventory_transfer_dialog'), findsOneWidget);
    expect(text(tester, 'new_inventory_transfer_warehouse'), 'Almacén 3');
    expect(text(tester, 'new_inventory_transfer_destination'), isEmpty);
    // Both warehouses are required.
    expect(submit(tester).onPressed, isNull);
  });

  testWidgets('a non-administrator is offered their own facility\'s origins '
      'but every warehouse as destination', (tester) async {
    await open(tester);

    await tester.enterText(field('new_inventory_transfer_warehouse'), 'Alm');
    await tester.pumpAndSettle();
    verify(
      () => h.warehouses.list(
        search: 'Alm',
        facilityId: 2,
        status: EntityStatus.active,
        limit: 10,
      ),
    ).called(greaterThan(0));

    await tester.enterText(field('new_inventory_transfer_destination'), 'Des');
    await tester.pumpAndSettle();
    verify(
      () => h.warehouses.list(
        search: 'Des',
        facilityId: null,
        status: EntityStatus.active,
        limit: 10,
      ),
    ).called(greaterThan(0));
  });

  testWidgets('a non-administrator with no facility is told so', (
    tester,
  ) async {
    await h.pumpTransfers(
      tester,
      who: InventoryHarness.transferUser(facilityId: null),
    );
    await tester.tap(key('inventory_transfers_new_button'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.inventoryDocumentNoFacility), findsOneWidget);
  });

  testWidgets('notes over 500 characters can\'t be submitted', (tester) async {
    await open(tester);
    await pickDestination(tester);
    expect(submit(tester).onPressed, isNotNull);

    await tester.enterText(key('new_inventory_transfer_comment'), 'x' * 501);
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNull);

    await tester.enterText(key('new_inventory_transfer_comment'), 'x' * 500);
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNotNull);
  });

  for (final (code, name, params) in [
    (
      api.ErrorCode.inventoryTransferPeriodSameWarehouse,
      'inventory_transfer.same_warehouse',
      <String, Object?>{},
    ),
    (
      api.ErrorCode.warehousePeriodInTransitLocation,
      'warehouse.in_transit_location',
      <String, Object?>{'warehouse_id': 4},
    ),
  ]) {
    testWidgets('$name stays in the dialog, in Spanish', (tester) async {
      when(
        () => h.transfers.create(
          warehouseId: any(named: 'warehouseId'),
          warehouseToId: any(named: 'warehouseToId'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => throw aRefusal(code, name, params));
      await open(tester);
      await pickDestination(tester);

      await tester.tap(key('new_inventory_transfer_submit'));
      await tester.pumpAndSettle();

      expect(key('new_inventory_transfer_dialog'), findsOneWidget);
      expect(key('new_inventory_transfer_refusal'), findsOneWidget);
      expect(find.text('SERVER TEXT'), findsNothing);
    });
  }

  testWidgets('the same-warehouse refusal is the server\'s: it reads '
      '"distintos"', (tester) async {
    when(
      () => h.transfers.create(
        warehouseId: any(named: 'warehouseId'),
        warehouseToId: any(named: 'warehouseToId'),
        comment: any(named: 'comment'),
      ),
    ).thenAnswer(
      (_) async => throw aRefusal(
        api.ErrorCode.inventoryTransferPeriodSameWarehouse,
        'inventory_transfer.same_warehouse',
      ),
    );
    await open(tester);
    await pickDestination(tester);
    await tester.tap(key('new_inventory_transfer_submit'));
    await tester.pumpAndSettle();

    expect(find.textContaining('distintos'), findsOneWidget);
  });

  testWidgets('success sends both warehouses and the notes, then opens the '
      'new transfer', (tester) async {
    when(
      () => h.transfers.create(
        warehouseId: any(named: 'warehouseId'),
        warehouseToId: any(named: 'warehouseToId'),
        comment: any(named: 'comment'),
      ),
    ).thenAnswer((_) async => aTransfer(id: 400, lines: const []));
    h.stubTransfer(aTransfer(id: 400, lines: const []));
    await open(tester);
    await pickDestination(tester);

    await tester.enterText(key('new_inventory_transfer_comment'), 'Reposición');
    await tester.pumpAndSettle();
    await tester.tap(key('new_inventory_transfer_submit'));
    await tester.pumpAndSettle();

    verify(
      () => h.transfers.create(
        warehouseId: 3,
        warehouseToId: 4,
        comment: 'Reposición',
      ),
    ).called(1);
    expect(key('new_inventory_transfer_dialog'), findsNothing);
    expect(find.text(l10n.inventoryTransferTitleDraft('400')), findsOneWidget);
  });
}
