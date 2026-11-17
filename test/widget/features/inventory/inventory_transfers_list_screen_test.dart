import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfer_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_transfer_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 069 US1 (T015): the Traspasos list. The route gate is
/// covered in `app_router_test.dart`.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => h = InventoryHarness());

  Badge badge(WidgetTester tester) => tester.widget<Badge>(
    find.ancestor(
      of: key('inventory_transfers_filter_button'),
      matching: find.byType(Badge),
    ),
  );

  Future<void> openFilters(WidgetTester tester) async {
    await tester.tap(key('inventory_transfers_filter_button'));
    await tester.pumpAndSettle();
  }

  final rows = [
    aTransferSummary(),
    aTransferSummary(
      id: 320,
      serial: 1043,
      status: InventoryTransferStatus.inTransit,
    ),
    aTransferSummary(
      id: 321,
      serial: 1044,
      status: InventoryTransferStatus.received,
    ),
    aTransferSummary(id: 322, status: InventoryTransferStatus.cancelled),
  ];

  testWidgets('a row per transfer: a draft reads "Borrador #id", a dispatched '
      'one its folio, with both warehouses and a chip', (tester) async {
    h.serveTransfers(rows);
    await h.pumpTransfers(tester);

    for (final header in [
      l10n.inventoryTransferColFolio,
      l10n.inventoryTransferColSource,
      l10n.inventoryTransferColDestination,
      l10n.inventoryTransferColFacility,
      l10n.inventoryTransferColStatus,
      l10n.inventoryTransferColCreator,
      l10n.inventoryTransferColDate,
    ]) {
      expect(find.text(header), findsWidgets, reason: header);
    }
    expect(find.text(l10n.inventoryDocumentDraftFolio('412')), findsOneWidget);
    expect(find.text(l10n.inventoryDocumentDraftFolio('322')), findsOneWidget);
    expect(find.text('1043'), findsOneWidget);
    expect(find.text('1044'), findsOneWidget);
    // The draft shows no folio: its id appears only as "Borrador #id".
    expect(find.text('412'), findsNothing);
    expect(find.text('Almacén 3'), findsNWidgets(4));
    expect(find.text('Almacén 4'), findsNWidgets(4));
    expect(find.text('Sucursal 2'), findsNWidgets(4));
    expect(find.text('Empleado 5'), findsNWidgets(4));
    expect(find.text(l10n.inventoryTransferStatusDraft), findsOneWidget);
    // The En tránsito button shares the status's label.
    expect(
      find.descendant(
        of: find.byType(InventoryTransferStatusChip),
        matching: find.text(l10n.inventoryTransferStatusInTransit),
      ),
      findsOneWidget,
    );
    expect(find.text(l10n.inventoryTransferStatusReceived), findsOneWidget);
    expect(find.text(l10n.inventoryTransferStatusCancelled), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rows carry no icons (§VI document reading)', (tester) async {
    h.serveTransfers(rows);
    await h.pumpTransfers(tester);

    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(find.byIcon(Icons.visibility_outlined), findsNothing);
  });

  testWidgets('a row tap opens the transfer', (tester) async {
    h.serveTransfers(rows);
    h.stubTransfer(aTransfer(id: 320, serial: 1043));
    final router = await h.pumpTransfers(tester);

    await tester.tap(find.text('1043'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/inventory/transfers/320');
  });

  testWidgets('there is no search control', (tester) async {
    h.serveTransfers(rows);
    await h.pumpTransfers(tester);

    expect(find.byType(CatalogSearchBar), findsNothing);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('a failed name lookup shows "#id"', (tester) async {
    h.serveTransfers(rows);
    await h.pumpTransfers(tester, namesFail: true);

    expect(find.text('#3'), findsNWidgets(4));
    expect(find.text('#4'), findsNWidgets(4));
    expect(find.text('#2'), findsNWidgets(4));
    expect(find.text('#5'), findsNWidgets(4));
  });

  group('facets', () {
    testWidgets('opens unfiltered, with the badge hidden', (tester) async {
      h.serveTransfers(rows);
      await h.pumpTransfers(tester);

      expect(h.transferRequests.single.status, isNull);
      expect(h.transferRequests.single.warehouseId, isNull);
      expect(badge(tester).isLabelVisible, isFalse);
    });

    testWidgets('status and warehouse in the address reach the repository '
        'and count on the badge', (tester) async {
      h.serveTransfers(rows);
      await h.pumpTransfers(
        tester,
        location: '/inventory/transfers?status=draft&warehouse=3',
      );

      expect(h.transferRequests.last.status, InventoryTransferStatus.draft);
      expect(h.transferRequests.last.warehouseId, 3);
      expect(badge(tester).isLabelVisible, isTrue);
      expect(
        find.descendant(of: find.byType(Badge), matching: find.text('2')),
        findsOneWidget,
      );
    });

    testWidgets('a status chip writes the address, resets the page and '
        'reaches the repository', (tester) async {
      h.serveTransfers(rows);
      final router = await h.pumpTransfers(
        tester,
        location: '/inventory/transfers?page=3',
      );
      await openFilters(tester);

      await tester.tap(key('inventory_transfers_status_inTransit'));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['status'], 'in_transit');
      expect(router.state.uri.queryParameters.containsKey('page'), isFalse);
      expect(h.transferRequests.last.status, InventoryTransferStatus.inTransit);
    });

    testWidgets('the drawer labels the warehouse facet as origin or '
        'destination', (tester) async {
      h.serveTransfers(rows);
      await h.pumpTransfers(tester);
      await openFilters(tester);

      expect(find.text('Almacén (origen o destino)'), findsOneWidget);
      expect(find.text(l10n.inventoryTransferFacetWarehouse), findsOneWidget);
    });

    testWidgets('a picked warehouse reaches the repository, from every '
        'warehouse (no facility limit)', (tester) async {
      h.serveTransfers(rows);
      h.serveWarehouses([aWarehouse(4, facilityId: 9)]);
      final router = await h.pumpTransfers(tester);
      await openFilters(tester);

      await tester.enterText(
        find.descendant(
          of: key('inventory_transfers_warehouse_filter'),
          matching: find.byType(TextField),
        ),
        'Alm',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Almacén 4').last);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['warehouse'], '4');
      expect(h.transferRequests.last.warehouseId, 4);
      // A non-administrator of facility 2, yet no facility is sent.
      verify(
        () => h.warehouses.list(
          search: 'Alm',
          facilityId: null,
          status: any(named: 'status'),
          limit: 10,
        ),
      ).called(greaterThan(0));
    });

    testWidgets('the warehouse facet needs Warehouses (4) read', (
      tester,
    ) async {
      h.serveTransfers(rows);
      await h.pumpTransfers(
        tester,
        who: InventoryHarness.transferUser(warehousesRead: false),
      );
      await openFilters(tester);

      expect(key('inventory_transfers_warehouse_filter'), findsNothing);
      expect(key('inventory_transfers_status_filter'), findsOneWidget);
    });
  });

  group('Nuevo traspaso', () {
    testWidgets('shown with create on 17 and read on Warehouses', (
      tester,
    ) async {
      h.serveTransfers(rows);
      await h.pumpTransfers(tester);

      expect(key('inventory_transfers_new_button'), findsOneWidget);
    });

    testWidgets('absent without create on 17', (tester) async {
      h.serveTransfers(rows);
      await h.pumpTransfers(
        tester,
        who: InventoryHarness.transferUser(transfers: 2),
      );

      expect(key('inventory_transfers_new_button'), findsNothing);
    });

    testWidgets('absent without read on Warehouses', (tester) async {
      h.serveTransfers(rows);
      await h.pumpTransfers(
        tester,
        who: InventoryHarness.transferUser(warehousesRead: false),
      );

      expect(key('inventory_transfers_new_button'), findsNothing);
    });
  });

  group('states', () {
    testWidgets('empty', (tester) async {
      h.serveTransfers(const []);
      await h.pumpTransfers(tester);

      expect(find.text(l10n.inventoryTransferEmpty), findsOneWidget);
    });

    testWidgets('filtered-empty offers "Limpiar filtros"', (tester) async {
      h.serveTransfers(const []);
      final router = await h.pumpTransfers(
        tester,
        location: '/inventory/transfers?status=cancelled',
      );

      expect(find.text(l10n.inventoryTransferEmpty), findsNothing);
      await tester.tap(find.text(l10n.clearFiltersButton));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, isEmpty);
      expect(h.transferRequests.last.status, isNull);
    });

    testWidgets('a read error shows the banner', (tester) async {
      h.stubTransferList((_) async => throw const AppError.network());
      await h.pumpTransfers(tester);

      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.text(l10n.retryButton), findsOneWidget);
    });
  });

  testWidgets('En tránsito is present for a reader and opens its route', (
    tester,
  ) async {
    h.serveTransfers(const []);
    when(
      () => h.transfers.inTransit(facilityId: any(named: 'facilityId')),
    ).thenAnswer((_) async => anInTransitView());
    final router = await h.pumpTransfers(
      tester,
      who: InventoryHarness.transferUser(transfers: 2),
    );

    expect(find.text(l10n.inventoryTransferInTransitAction), findsOneWidget);
    await tester.tap(key('inventory_transfers_in_transit_button'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/inventory/transfers/in-transit');
    expect(key('in_transit_lines_table'), findsOneWidget);
  });
}
