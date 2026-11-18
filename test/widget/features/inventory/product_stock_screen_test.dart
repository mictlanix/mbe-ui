import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/inventory/domain/entities/stock.dart';

import '../../../unit/features/inventory/stock_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 071 US2 (T016): the product view. The route gate is covered in
/// `app_router_test.dart`.
void main() {
  late InventoryHarness h;

  setUp(() => h = InventoryHarness());

  String qty(String value) =>
      h.container.read(formattersProvider).display.quantity(value);

  final twoWarehouses = aProductStock(
    warehouses: [
      aStockRow(
        warehouseId: 3,
        onHand: '10',
        reserved: '2',
        available: '8',
        incoming: '5',
      ),
      aStockRow(
        warehouseId: 4,
        onHand: '-15',
        reserved: '1',
        available: '-16',
        incoming: '0',
      ),
    ],
  );

  testWidgets('the title names the product, with no AppBar actions', (
    tester,
  ) async {
    await h.pumpProductStock(tester, twoWarehouses);

    expect(find.text('Existencias · A-100 Tornillo 1/4 caja'), findsOneWidget);
    expect(tester.widget<AppBar>(find.byType(AppBar)).actions, isNull);
  });

  testWidgets('each row shows its warehouse and facility', (tester) async {
    await h.pumpProductStock(tester, twoWarehouses);

    final table = key('product_stock_table');
    expect(
      find.descendant(of: table, matching: find.text('Almacén 3')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: table, matching: find.text('Sucursal 30')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: table, matching: find.text('Almacén 4')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: table, matching: find.text('Sucursal 40')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: table, matching: find.text(qty('-15'))),
      findsOneWidget,
    );
  });

  testWidgets('the totals strip sums the rows, a negative total kept', (
    tester,
  ) async {
    await h.pumpProductStock(tester, twoWarehouses);

    final totals = key('product_stock_totals');
    for (final text in [
      'Existencia',
      'Apartado',
      'Disponible',
      'Por recibir',
      qty('-5'),
      qty('3'),
      qty('-8'),
      qty('5'),
    ]) {
      expect(
        find.descendant(of: totals, matching: find.text(text)),
        findsOneWidget,
        reason: text,
      );
    }
  });

  group('Ver kardex', () {
    testWidgets('present with Kardex (32) read, pushing the kardex of the '
        'row', (tester) async {
      final router = await h.pumpProductStock(
        tester,
        twoWarehouses,
        who: InventoryHarness.stockUser(kardex: 2),
      );

      expect(key('product_stock_kardex_3'), findsOneWidget);
      expect(key('product_stock_kardex_4'), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsNWidgets(2));
      expect(find.byIcon(Icons.edit_outlined), findsNothing);

      await tester.tap(key('product_stock_kardex_4'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/inventory/kardex/view');
      expect(router.state.uri.queryParameters, {
        'product': '7',
        'warehouse': '4',
      });
      // Pushed over the product view, which stays underneath.
      expect(router.canPop(), isTrue);
    });

    testWidgets('absent without Kardex (32) read', (tester) async {
      await h.pumpProductStock(tester, twoWarehouses);

      expect(key('product_stock_kardex_3'), findsNothing);
      expect(find.byIcon(Icons.receipt_long_outlined), findsNothing);
    });
  });

  group('En tránsito', () {
    testWidgets('shown with the facility and quantity when non-empty', (
      tester,
    ) async {
      await h.pumpProductStock(
        tester,
        aProductStock(
          inTransit: [anInTransitStock(facilityId: 2, onHand: '4')],
        ),
      );

      final section = key('product_stock_in_transit');
      expect(section, findsOneWidget);
      expect(
        find.descendant(of: section, matching: find.text('En tránsito')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: section, matching: find.text('Sucursal 2')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: section, matching: find.text(qty('4'))),
        findsOneWidget,
      );
    });

    testWidgets('absent when empty', (tester) async {
      await h.pumpProductStock(tester, twoWarehouses);

      expect(key('product_stock_in_transit'), findsNothing);
    });
  });

  testWidgets('a product with no stock anywhere shows the empty text', (
    tester,
  ) async {
    await h.pumpProductStock(
      tester,
      const ProductStock(productId: 7, warehouses: [], inTransit: []),
    );

    expect(
      find.text('Este producto no tiene existencias en ningún almacén.'),
      findsOneWidget,
    );
    expect(key('product_stock_table'), findsNothing);
    expect(key('product_stock_totals'), findsNothing);
  });

  testWidgets('a missing product shows the not-found state', (tester) async {
    when(
      () => h.stock.product(99),
    ).thenAnswer((_) async => throw const AppError.notFound());

    await h.pumpStock(tester, location: '/inventory/stock/products/99');

    expect(key('product_stock_not_found'), findsOneWidget);
    expect(key('product_stock_table'), findsNothing);
  });

  testWidgets('a non-numeric id shows the not-found state', (tester) async {
    await h.pumpStock(tester, location: '/inventory/stock/products/abc');

    expect(key('product_stock_not_found'), findsOneWidget);
  });
}
