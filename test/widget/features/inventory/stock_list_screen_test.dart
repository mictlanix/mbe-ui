import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/stock_fixtures.dart';
import 'inventory_harness.dart';

const _pointSale = PointSale(
  pointSaleId: 11,
  facilityId: 2,
  facilityName: 'Matriz',
  code: 'POS1',
  name: 'Caja 1',
  warehouseId: 3,
  warehouseName: 'Almacén 3',
  status: EntityStatus.active,
);

/// Spec 071 US1 (T010): Existencias. The route gate is covered in
/// `app_router_test.dart`.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    h = InventoryHarness();
    when(
      () => h.pointSales.get(pointSaleId: 11),
    ).thenAnswer((_) async => _pointSale);
  });

  const atWarehouse = '/inventory/stock?warehouse=3';

  final rows = [
    aStockRow(),
    aStockRow(
      productId: 8,
      productCode: 'C-310',
      productName: 'Ancla plástica',
      onHand: '-2',
      reserved: '0',
      available: '-2.5',
      incoming: '40',
    ),
  ];

  /// A full page (50 rows) of a 400-row warehouse, so the table has no
  /// placeholder rows on any page.
  final fullPage = [
    for (var i = 1; i <= 50; i++)
      aStockRow(productId: i, productCode: 'P-$i', productName: 'Producto $i'),
  ];

  Badge badge(WidgetTester tester) => tester.widget<Badge>(
    find.ancestor(of: key('stock_filter_button'), matching: find.byType(Badge)),
  );

  Future<void> openFilters(WidgetTester tester) async {
    await tester.tap(key('stock_filter_button'));
    await tester.pumpAndSettle();
  }

  testWidgets('a row per product with the four figures, negatives shown as '
      'negative', (tester) async {
    h.serveStock(rows);
    await h.pumpStock(tester, location: atWarehouse);

    for (final header in [
      l10n.inventoryStockColumnCode,
      l10n.inventoryStockColumnProduct,
      l10n.inventoryStockColumnOnHand,
      l10n.inventoryStockColumnReserved,
      l10n.inventoryStockColumnAvailable,
      l10n.inventoryStockColumnIncoming,
    ]) {
      expect(find.text(header), findsWidgets, reason: header);
    }
    expect(find.text('A-100'), findsOneWidget);
    expect(find.text('Tornillo 1/4 caja'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('C-310'), findsOneWidget);
    expect(find.text('-2'), findsOneWidget);
    expect(find.text('-2.5'), findsOneWidget);
    expect(find.text('40'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the facts strip names the chosen warehouse', (tester) async {
    h.serveStock(rows);
    await h.pumpStock(tester, location: atWarehouse);

    expect(
      find.descendant(
        of: key('stock_selection'),
        matching: find.text(l10n.inventoryStockSelectionWarehouse),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: key('stock_selection'),
        matching: find.text('Almacén 3'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('rows carry no icons, and the bar has no actions', (
    tester,
  ) async {
    h.serveStock(rows);
    await h.pumpStock(tester, location: atWarehouse);

    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    final bar = tester.widget<CatalogFilterBar>(find.byType(CatalogFilterBar));
    expect(bar.actions, isEmpty);
    expect(bar.filters, hasLength(1));
  });

  testWidgets('a row tap pushes the product view', (tester) async {
    h.serveStock(rows);
    h.stubProductStock(aProductStock(productId: 8));
    final router = await h.pumpStock(tester, location: atWarehouse);

    await tester.tap(find.text('Ancla plástica'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/inventory/stock/products/8');
    expect(key('product_stock_table'), findsOneWidget);
  });

  group('starting warehouse', () {
    testWidgets('the point-of-sale warehouse is the start, written to the '
        'URL, even outside the user\'s facility', (tester) async {
      when(() => h.pointSales.get(pointSaleId: 11)).thenAnswer(
        (_) async => _pointSale.copyWith(warehouseId: 30, facilityId: 9),
      );
      h.serveStock(rows);
      final router = await h.pumpStock(
        tester,
        who: InventoryHarness.stockUser(pointSaleId: 11),
      );

      expect(router.state.uri.queryParameters['warehouse'], '30');
      expect(h.stockRequests.single.warehouseId, 30);
      expect(find.text('A-100'), findsOneWidget);
    });

    testWidgets('a warehouse in the URL wins over the point of sale', (
      tester,
    ) async {
      h.serveStock(rows);
      final router = await h.pumpStock(
        tester,
        who: InventoryHarness.stockUser(pointSaleId: 11),
        location: '/inventory/stock?warehouse=5',
      );

      expect(router.state.uri.queryParameters['warehouse'], '5');
      expect(h.stockRequests.single.warehouseId, 5);
    });

    testWidgets('without a point of sale: the prompt and its button, no '
        'request', (tester) async {
      h.serveStock(rows);
      h.serveWarehouses([aWarehouse(4)]);
      await h.pumpStock(tester);

      expect(find.text(l10n.inventoryStockPickWarehousePrompt), findsOneWidget);
      expect(key('stock_selection'), findsNothing);
      expect(h.stockRequests, isEmpty);

      await tester.tap(find.text(l10n.inventoryStockPickWarehouseButton));
      await tester.pumpAndSettle();
      expect(key('stock_warehouse_filter'), findsOneWidget);
    });

    testWidgets('without Warehouses (4) read the prompt has no button', (
      tester,
    ) async {
      await h.pumpStock(
        tester,
        who: InventoryHarness.stockUser(warehousesRead: false),
      );

      expect(find.text(l10n.inventoryStockPickWarehousePrompt), findsOneWidget);
      expect(find.text(l10n.inventoryStockPickWarehouseButton), findsNothing);
    });

    testWidgets('a failed point-of-sale lookup falls back to the prompt', (
      tester,
    ) async {
      when(
        () => h.pointSales.get(pointSaleId: 11),
      ).thenAnswer((_) async => throw const AppError.network());
      await h.pumpStock(
        tester,
        who: InventoryHarness.stockUser(pointSaleId: 11),
      );

      expect(find.text(l10n.inventoryStockPickWarehousePrompt), findsOneWidget);
      expect(h.stockRequests, isEmpty);
    });
  });

  group('search and switch', () {
    testWidgets('a search writes q, returns to page 1 and reaches the '
        'repository', (tester) async {
      h.serveStock(fullPage, total: 400);
      final router = await h.pumpStock(
        tester,
        location: '/inventory/stock?page=3&warehouse=3',
      );
      expect(h.stockRequests.last.skip, 100);

      await tester.enterText(
        find.descendant(
          of: key('stock_search'),
          matching: find.byType(TextField),
        ),
        'torn',
      );
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['q'], 'torn');
      expect(router.state.uri.queryParameters.containsKey('page'), isFalse);
      expect(router.state.uri.queryParameters['warehouse'], '3');
      final last = h.stockRequests.last;
      expect(last.q, 'torn');
      expect(last.skip, 0);
      expect(last.limit, 50);
    });

    testWidgets('the switch writes include_zero, returns to page 1 and '
        'reaches the repository', (tester) async {
      h.serveStock(fullPage, total: 400);
      final router = await h.pumpStock(
        tester,
        location: '/inventory/stock?page=2&warehouse=3',
      );
      expect(h.stockRequests.last.includeZero, isFalse);
      await openFilters(tester);

      await tester.tap(key('stock_include_zero'));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['include_zero'], 'true');
      expect(router.state.uri.queryParameters.containsKey('page'), isFalse);
      expect(h.stockRequests.last.includeZero, isTrue);
      expect(h.stockRequests.last.skip, 0);
    });

    testWidgets('a picked warehouse reaches the repository, offering every '
        'warehouse', (tester) async {
      h.serveStock(rows);
      h.serveWarehouses([aWarehouse(4, facilityId: 9)]);
      final router = await h.pumpStock(tester, location: atWarehouse);
      await openFilters(tester);

      await tester.enterText(
        find.descendant(
          of: key('stock_warehouse_filter'),
          matching: find.byType(TextField),
        ),
        'Alm',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Almacén 4').last);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['warehouse'], '4');
      expect(h.stockRequests.last.warehouseId, 4);
      verify(
        () => h.warehouses.list(
          search: 'Alm',
          facilityId: null,
          status: any(named: 'status'),
          limit: 10,
        ),
      ).called(greaterThan(0));
    });

    testWidgets('the Almacén facet needs Warehouses (4) read', (tester) async {
      h.serveStock(rows);
      await h.pumpStock(
        tester,
        who: InventoryHarness.stockUser(warehousesRead: false),
        location: atWarehouse,
      );
      await openFilters(tester);

      expect(key('stock_warehouse_filter'), findsNothing);
      expect(key('stock_include_zero'), findsOneWidget);
    });

    testWidgets('the badge counts the chosen warehouse', (tester) async {
      h.serveStock(rows);
      await h.pumpStock(tester, location: atWarehouse);

      expect(badge(tester).isLabelVisible, isTrue);
      expect(
        find.descendant(of: find.byType(Badge), matching: find.text('1')),
        findsOneWidget,
      );
    });

    testWidgets('the badge counts the warehouse and the switch, not the '
        'search', (tester) async {
      h.serveStock(rows);
      await h.pumpStock(
        tester,
        location: '/inventory/stock?warehouse=3&q=torn&include_zero=true',
      );

      expect(
        find.descendant(of: find.byType(Badge), matching: find.text('2')),
        findsOneWidget,
      );
    });
  });

  group('states', () {
    testWidgets('empty', (tester) async {
      h.serveStock(const []);
      await h.pumpStock(tester, location: atWarehouse);

      expect(find.text(l10n.inventoryStockEmpty), findsOneWidget);
    });

    testWidgets('filtered-empty', (tester) async {
      h.serveStock(const []);
      await h.pumpStock(tester, location: '$atWarehouse&q=zzz');

      expect(find.text(l10n.inventoryStockFilteredEmpty), findsOneWidget);
      expect(find.text(l10n.inventoryStockEmpty), findsNothing);
    });

    testWidgets('a read error shows the banner', (tester) async {
      h.stubStockList((_) async => throw const AppError.network());
      await h.pumpStock(tester, location: atWarehouse);

      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.text(l10n.retryButton), findsOneWidget);
    });

    testWidgets('an in-transit warehouse shows the Spanish refusal and no '
        'rows', (tester) async {
      h.stubStockList(
        (_) async => throw aRefusal(
          api.ErrorCode.warehousePeriodInTransitLocation,
          'warehouse.in_transit_location',
        ),
      );
      await h.pumpStock(tester, location: atWarehouse);

      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(
        find.textContaining(l10n.apiErrorWarehouseInTransitLocation),
        findsOneWidget,
      );
      expect(find.textContaining('SERVER TEXT'), findsNothing);
      expect(key('stock_table'), findsNothing);
    });
  });
}
