import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_count_fixtures.dart';
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

/// Spec 070 US2 (T019), FR-005: "Nuevo conteo", opened from the list's
/// button.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(EntityStatus.active);
  });

  setUp(() {
    h = InventoryHarness();
    h.serveCounts(const []);
    h.serveWarehouses([aWarehouse(3), aWarehouse(4)]);
    when(
      () => h.pointSales.get(pointSaleId: 11),
    ).thenAnswer((_) async => _pointSale);
    when(
      () => h.warehouses.get(warehouseId: 3),
    ).thenAnswer((_) async => aWarehouse(3));
  });

  Future<void> open(WidgetTester tester, {bool administrator = false}) async {
    await h.pumpCounts(
      tester,
      who: InventoryHarness.countUser(
        administrator: administrator,
        pointSaleId: 11,
      ),
    );
    await tester.tap(key('inventory_counts_new_button'));
    await tester.pumpAndSettle();
  }

  Finder warehouseField() => find.descendant(
    of: key('new_inventory_count_warehouse'),
    matching: find.byType(TextField),
  );

  String warehouseText(WidgetTester tester) =>
      tester.widget<TextField>(warehouseField()).controller!.text;

  FilledButton submit(WidgetTester tester) =>
      tester.widget<FilledButton>(key('new_inventory_count_submit'));

  testWidgets('starts on the point-of-sale warehouse', (tester) async {
    await open(tester);

    expect(key('new_inventory_count_dialog'), findsOneWidget);
    expect(find.text(l10n.inventoryCountFieldComment), findsOneWidget);
    expect(warehouseText(tester), 'Almacén 3');
    expect(submit(tester).onPressed, isNotNull);
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

  testWidgets('a non-administrator with no facility is told so and offered '
      'nothing', (tester) async {
    await h.pumpCounts(
      tester,
      who: InventoryHarness.countUser(facilityId: null),
    );
    await tester.tap(key('inventory_counts_new_button'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.inventoryDocumentNoFacility), findsOneWidget);
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

  testWidgets('a comment over 500 characters can\'t be submitted', (
    tester,
  ) async {
    await open(tester);

    await tester.enterText(key('new_inventory_count_comment'), 'x' * 501);
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNull);

    await tester.enterText(key('new_inventory_count_comment'), 'x' * 500);
    await tester.pumpAndSettle();
    expect(submit(tester).onPressed, isNotNull);
  });

  testWidgets('a refusal stays in the dialog, localized', (tester) async {
    when(
      () => h.counts.create(
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

    await tester.tap(key('new_inventory_count_submit'));
    await tester.pumpAndSettle();

    expect(key('new_inventory_count_dialog'), findsOneWidget);
    expect(key('new_inventory_count_refusal'), findsOneWidget);
    expect(find.text('SERVER TEXT'), findsNothing);
  });

  testWidgets('success sends the warehouse and comment, then opens the new '
      'count', (tester) async {
    when(
      () => h.counts.create(
        warehouseId: any(named: 'warehouseId'),
        comment: any(named: 'comment'),
      ),
    ).thenAnswer((_) async => aCount(id: 400, lines: const []));
    h.stubCount(aCount(id: 400, lines: const []));
    await open(tester);

    await tester.enterText(key('new_inventory_count_comment'), 'Pasillo 3');
    await tester.pumpAndSettle();
    await tester.tap(key('new_inventory_count_submit'));
    await tester.pumpAndSettle();

    verify(
      () => h.counts.create(warehouseId: 3, comment: 'Pasillo 3'),
    ).called(1);
    expect(key('new_inventory_count_dialog'), findsNothing);
    expect(find.text(l10n.inventoryCountTitleDraft('400')), findsOneWidget);
  });

  testWidgets('the button is absent without create on 74', (tester) async {
    await h.pumpCounts(tester, who: InventoryHarness.countUser(counts: 2 | 4));
    expect(key('inventory_counts_new_button'), findsNothing);
  });

  testWidgets('the button is absent without Warehouses (4) read', (
    tester,
  ) async {
    await h.pumpCounts(
      tester,
      who: InventoryHarness.countUser(warehousesRead: false),
    );
    expect(key('inventory_counts_new_button'), findsNothing);
  });
}
