import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_receipt_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 067 US1 (T014): the Entradas de almacén list. The route gate is
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
      of: key('inventory_receipts_filter_button'),
      matching: find.byType(Badge),
    ),
  );

  Future<void> openFilters(WidgetTester tester) async {
    await tester.tap(key('inventory_receipts_filter_button'));
    await tester.pumpAndSettle();
  }

  final rows = [
    aReceiptSummary(),
    aReceiptSummary(
      id: 320,
      serial: 1043,
      purchaseOrderId: 5512,
      status: InventoryDocumentStatus.completed,
    ),
  ];

  testWidgets('a row per receipt: a draft reads "Borrador #id", a confirmed '
      'one its folio and purchase order, with names and a chip', (
    tester,
  ) async {
    h.serve(rows);
    await h.pump(tester);

    for (final header in [
      l10n.inventoryReceiptColFolio,
      l10n.inventoryReceiptColWarehouse,
      l10n.inventoryReceiptColFacility,
      l10n.inventoryReceiptColPurchaseOrder,
      l10n.inventoryReceiptColStatus,
      l10n.inventoryReceiptColCreator,
      l10n.inventoryReceiptColDate,
    ]) {
      expect(find.text(header), findsWidgets, reason: header);
    }
    expect(find.text(l10n.inventoryDocumentDraftFolio('318')), findsOneWidget);
    expect(find.text('1043'), findsOneWidget);
    expect(find.text('5512'), findsOneWidget);
    expect(find.text('Almacén 3'), findsNWidgets(2));
    expect(find.text('Sucursal 2'), findsNWidgets(2));
    expect(find.text('Empleado 5'), findsNWidgets(2));
    expect(find.text(l10n.inventoryDocumentStatusDraft), findsOneWidget);
    expect(find.text(l10n.inventoryDocumentStatusCompleted), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rows carry no icons (§VI document reading)', (tester) async {
    h.serve(rows);
    await h.pump(tester);

    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(find.byIcon(Icons.visibility_outlined), findsNothing);
  });

  testWidgets('a row tap opens the receipt', (tester) async {
    h.serve(rows);
    h.stubReceipt(aReceipt(id: 320, serial: 1043));
    final router = await h.pump(tester);

    await tester.tap(find.text('1043'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/inventory/receipts/320');
  });

  testWidgets('there is no search control', (tester) async {
    h.serve(rows);
    await h.pump(tester);

    expect(find.byType(CatalogSearchBar), findsNothing);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('a failed name lookup shows "#id"', (tester) async {
    h.serve(rows);
    await h.pump(tester, namesFail: true);

    expect(find.text('#3'), findsNWidgets(2));
    expect(find.text('#2'), findsNWidgets(2));
    expect(find.text('#5'), findsNWidgets(2));
  });

  group('facets', () {
    testWidgets('opens unfiltered, with the badge hidden', (tester) async {
      h.serve(rows);
      await h.pump(tester);

      expect(h.requests.single.status, isNull);
      expect(h.requests.single.warehouseId, isNull);
      expect(badge(tester).isLabelVisible, isFalse);
    });

    testWidgets('status and warehouse in the address reach the repository '
        'and count on the badge', (tester) async {
      h.serve(rows);
      await h.pump(
        tester,
        location: '/inventory/receipts?status=draft&warehouse=3',
      );

      expect(h.requests.last.status, InventoryDocumentStatus.draft);
      expect(h.requests.last.warehouseId, 3);
      expect(badge(tester).isLabelVisible, isTrue);
      expect(
        find.descendant(of: find.byType(Badge), matching: find.text('2')),
        findsOneWidget,
      );
    });

    testWidgets('a status chip writes the address, resets the page and '
        'reaches the repository', (tester) async {
      h.serve(rows);
      final router = await h.pump(
        tester,
        location: '/inventory/receipts?page=3',
      );
      await openFilters(tester);

      await tester.tap(key('inventory_receipts_status_completed'));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['status'], 'completed');
      expect(router.state.uri.queryParameters.containsKey('page'), isFalse);
      expect(h.requests.last.status, InventoryDocumentStatus.completed);
    });

    testWidgets('a picked warehouse reaches the repository, from every '
        'warehouse (no facility limit)', (tester) async {
      h.serve(rows);
      h.serveWarehouses([aWarehouse(4, facilityId: 9)]);
      final router = await h.pump(tester);
      await openFilters(tester);

      await tester.enterText(
        find.descendant(
          of: key('inventory_receipts_warehouse_filter'),
          matching: find.byType(TextField),
        ),
        'Alm',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Almacén 4').last);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['warehouse'], '4');
      expect(h.requests.last.warehouseId, 4);
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
      h.serve(rows);
      await h.pump(tester, who: InventoryHarness.user(warehousesRead: false));
      await openFilters(tester);

      expect(key('inventory_receipts_warehouse_filter'), findsNothing);
      expect(key('inventory_receipts_status_filter'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('empty', (tester) async {
      h.serve(const []);
      await h.pump(tester);

      expect(find.text(l10n.inventoryReceiptEmpty), findsOneWidget);
    });

    testWidgets('filtered-empty offers "Limpiar filtros"', (tester) async {
      h.serve(const []);
      final router = await h.pump(
        tester,
        location: '/inventory/receipts?status=cancelled',
      );

      expect(find.text(l10n.inventoryReceiptEmpty), findsNothing);
      await tester.tap(find.text(l10n.clearFiltersButton));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, isEmpty);
      expect(h.requests.last.status, isNull);
    });

    testWidgets('a read error shows the banner', (tester) async {
      h.stubList((_) async => throw const AppError.network());
      await h.pump(tester);

      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.text(l10n.retryButton), findsOneWidget);
    });
  });
}
