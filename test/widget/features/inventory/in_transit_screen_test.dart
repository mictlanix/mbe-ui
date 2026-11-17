import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_transfer_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 069 US7 (T034): the En tránsito screen.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => h = InventoryHarness());

  const path = '/inventory/transfers/in-transit';

  void serve(int facilityId, InTransitView view) => when(
    () => h.transfers.inTransit(facilityId: facilityId),
  ).thenAnswer((_) async => view);

  InTransitView twoLines() => InTransitView(
    facilityId: 2,
    products: [
      InTransitProductTotal(
        productId: 7,
        productCode: 'A-100',
        productName: 'Tornillo',
        quantity: Decimal.parse('8.5'),
      ),
    ],
    lines: [
      for (final (i, q) in [('5.5'), ('3')].indexed)
        InTransitLineItem(
          transferId: 412 + i,
          serial: i == 0 ? 77 : null,
          warehouseId: 3,
          warehouseToId: 4,
          lineId: 900 + i,
          productId: 7,
          productCode: 'A-100',
          productName: 'Tornillo',
          quantityOutstanding: Decimal.parse(q),
        ),
    ],
  );

  testWidgets('both tables render with quantities, totals and folios', (
    tester,
  ) async {
    serve(2, twoLines());
    await h.pumpTransfers(tester, location: path);

    expect(find.text(l10n.inventoryTransferInTransitByProduct), findsOneWidget);
    expect(
      find.text(l10n.inventoryTransferInTransitByTransfer),
      findsOneWidget,
    );
    expect(key('in_transit_products_table'), findsOneWidget);
    expect(key('in_transit_lines_table'), findsOneWidget);
    final fmt = h.container.read(formattersProvider);
    expect(find.text(fmt.display.quantity('8.5')), findsOneWidget);
    expect(find.text(fmt.display.quantity('5.5')), findsOneWidget);
    expect(find.text('77'), findsOneWidget);
    // A null serial shows the id.
    expect(find.text('#413'), findsOneWidget);
    expect(find.text('Almacén 3'), findsNWidgets(2));
  });

  testWidgets('a line row opens its transfer', (tester) async {
    serve(2, twoLines());
    final router = await h.pumpTransfers(tester, location: path);

    await tester.tap(find.text('77'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/inventory/transfers/412');
  });

  testWidgets('a non-administrator has no picker and the title names their '
      'facility', (tester) async {
    serve(2, twoLines());
    await h.pumpTransfers(tester, location: path);

    expect(key('in_transit_facility_mine'), findsNothing);
    expect(find.byType(Autocomplete<FacilityListItem>), findsNothing);
    expect(
      find.text(l10n.inventoryTransferInTransitTitleFacility('Sucursal 2')),
      findsOneWidget,
    );
  });

  testWidgets('an administrator sees the picker, and switching reloads', (
    tester,
  ) async {
    serve(2, twoLines());
    serve(5, anInTransitView(facilityId: 5));
    when(
      () => h.facilities.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const FacilityListResult(
        items: [
          FacilityListItem(
            facilityId: 5,
            code: 'S5',
            name: 'Sucursal Cinco',
            type: FacilityType.store,
            status: EntityStatus.active,
          ),
        ],
        total: 1,
      ),
    );
    await h.pumpTransfers(
      tester,
      location: path,
      who: InventoryHarness.transferUser(administrator: true),
    );

    expect(find.text(l10n.inventoryTransferInTransitTitle), findsOneWidget);
    expect(key('in_transit_facility_mine'), findsOneWidget);
    verify(() => h.transfers.inTransit(facilityId: 2)).called(1);

    final field = find.descendant(
      of: find.byType(Autocomplete<FacilityListItem>),
      matching: find.byType(TextField),
    );
    await tester.tap(field);
    await tester.enterText(field, 'Cinco');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sucursal Cinco').last);
    await tester.pumpAndSettle();

    verify(() => h.transfers.inTransit(facilityId: 5)).called(1);
    expect(find.text('A-100'), findsWidgets);

    await tester.tap(key('in_transit_facility_mine'));
    await tester.pumpAndSettle();
    verify(() => h.transfers.inTransit(facilityId: 2)).called(greaterThan(0));
  });

  testWidgets('no facility: a non-administrator sees the no-sucursal text and '
      'no request is sent', (tester) async {
    await h.pumpTransfers(
      tester,
      location: path,
      who: InventoryHarness.transferUser(facilityId: null),
    );

    expect(find.text(l10n.inventoryDocumentNoFacility), findsOneWidget);
    verifyNever(
      () => h.transfers.inTransit(facilityId: any(named: 'facilityId')),
    );
  });

  testWidgets('no facility: an administrator is asked to select one and no '
      'request is sent', (tester) async {
    await h.pumpTransfers(
      tester,
      location: path,
      who: InventoryHarness.transferUser(administrator: true, facilityId: null),
    );

    expect(
      find.text(l10n.inventoryTransferInTransitSelectFacility),
      findsOneWidget,
    );
    verifyNever(
      () => h.transfers.inTransit(facilityId: any(named: 'facilityId')),
    );
  });

  testWidgets('an empty view shows the empty state', (tester) async {
    serve(2, const InTransitView(facilityId: 2, products: [], lines: []));
    await h.pumpTransfers(tester, location: path);

    expect(find.text(l10n.inventoryTransferInTransitEmpty), findsOneWidget);
  });

  testWidgets('a read error shows the banner and retry reloads', (
    tester,
  ) async {
    when(
      () => h.transfers.inTransit(facilityId: 2),
    ).thenAnswer((_) async => throw const AppError.network());
    await h.pumpTransfers(tester, location: path);

    expect(key('list_state_failed'), findsOneWidget);

    serve(2, twoLines());
    await tester.tap(key('list_state_retry_button'));
    await tester.pumpAndSettle();

    expect(key('in_transit_lines_table'), findsOneWidget);
  });
}
