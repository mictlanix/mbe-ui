import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/capture/capture_step.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';
import 'package:mbe_ui/features/sales/presentation/capture/default_warehouse_controller.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_search_field.dart';

import 'pos_test_harness.dart';

/// spec 047 US3: Continue is blocked while a draft sale has a line short of
/// stock, and only on a host that opts in with `enforceStock`.
void main() {
  late MockWarehouseRepository warehouseRepository;
  late MockSalesOrderRepository salesOrders;
  final saleProvider = StateProvider<Sale>((ref) => testSale());

  const reasonKey = Key('capture_continue_blocked_reason');
  const continueKey = Key('pos_continue_to_payment');

  setUp(() {
    warehouseRepository = MockWarehouseRepository();
    when(
      () => warehouseRepository.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));
    salesOrders = MockSalesOrderRepository();
  });

  ProductStock stockOf(String available) => ProductStock(
    warehouses: [WarehouseStock(warehouse: 3, onHand: available, available: available)],
  );

  Future<ProviderContainer> pumpGate(
    WidgetTester tester,
    Sale sale, {
    Map<int, ProductStock> cache = const {},
    bool enforceStock = true,
    List<Override> overrides = const [],
  }) async {
    final container = await pumpPos(
      tester,
      Consumer(
        builder: (context, ref, _) => CaptureStep(
          sale: ref.watch(saleProvider),
          onContinue: () {},
          enforceStock: enforceStock,
        ),
      ),
      overrides: [
        warehouseOverride(warehouseRepository),
        salesOrderOverride(salesOrders),
        saleProvider.overrideWith((ref) => sale),
        productStockCacheProvider.overrideWith((ref) => cache),
        ...overrides,
      ],
      surface: const Size(1400, 900),
    );
    return container;
  }

  bool continueEnabled(WidgetTester tester) =>
      tester.widget<FloatingActionButton>(find.byKey(continueKey)).onPressed != null;

  testWidgets('blocked with a reason while a line is short; unblocked by '
      'lowering the quantity or switching warehouse', (tester) async {
    final container = await pumpGate(
      tester,
      testSale(lines: [testLine(quantity: '6')]),
      cache: {11: stockOf('5')},
    );

    expect(continueEnabled(tester), isFalse);
    expect(find.byKey(reasonKey), findsOneWidget);
    expect(find.text('1 partida sin existencia suficiente'), findsOneWidget);

    container.read(saleProvider.notifier).state = testSale(
      lines: [testLine(quantity: '5')],
    );
    await tester.pumpAndSettle();
    expect(continueEnabled(tester), isTrue);
    expect(find.byKey(reasonKey), findsNothing);

    container.read(saleProvider.notifier).state = testSale(
      lines: [testLine(quantity: '6', warehouse: 4)],
    );
    await tester.pumpAndSettle();
    expect(continueEnabled(tester), isTrue, reason: 'no row for warehouse 4 is unknown');
  });

  testWidgets('unknown stock does not block', (tester) async {
    when(
      () => salesOrders.productLookupByIds(
        products: any(named: 'products'),
        customer: any(named: 'customer'),
      ),
    ).thenThrow(Exception('offline'));
    await pumpGate(tester, testSale(lines: [testLine(quantity: '99')]));

    expect(continueEnabled(tester), isTrue);
    expect(find.byKey(reasonKey), findsNothing);
  });

  testWidgets('a resumed sale loads its stock, so the gate still blocks', (
    tester,
  ) async {
    when(
      () => salesOrders.productLookupByIds(products: [11], customer: 7),
    ).thenAnswer(
      (_) async => [
        ProductLookupResult(
          product: 11,
          code: 'P-11',
          name: 'Widget',
          price: '50.00',
          taxRate: '0.16',
          taxIncluded: false,
          minOrderQty: 1,
          stockRequired: true,
          stockable: true,
          stock: const [WarehouseStock(warehouse: 3, onHand: '1', available: '1')],
        ),
      ],
    );
    await pumpGate(tester, testSale(lines: [testLine(quantity: '2')]));

    expect(continueEnabled(tester), isFalse);
    expect(find.byKey(reasonKey), findsOneWidget);
    // One batch request by id (mbe-api#237), never a per-code search.
    verify(() => salesOrders.productLookupByIds(products: [11], customer: 7)).called(1);
    verifyNever(
      () => salesOrders.productLookup(
        pattern: any(named: 'pattern'),
        customer: any(named: 'customer'),
        warehouse: any(named: 'warehouse'),
      ),
    );
  });

  testWidgets('a host that does not enforce stock is never blocked', (tester) async {
    await pumpGate(
      tester,
      testSale(lines: [testLine(quantity: '6')]),
      cache: {11: stockOf('5')},
      enforceStock: false,
    );

    expect(continueEnabled(tester), isTrue);
    expect(find.byKey(reasonKey), findsNothing);
  });

  // Found in the spec 047 live walkthrough: a search filtered to the default
  // warehouse seeded the cache with that warehouse only, so every other one
  // read "unknown" — the pop-up hid their stock, and switching a short line
  // to one of them slipped past the gate.
  testWidgets('the product search is not filtered to one warehouse', (tester) async {
    await pumpGate(
      tester,
      testSale(lines: [testLine(quantity: '1')]),
      // The register's point of sale has a default warehouse, which is
      // exactly what the search used to be filtered to.
      overrides: [defaultWarehouseControllerProvider.overrideWith((ref, pointSale) async => 3)],
    );

    expect(tester.widget<ProductSearchField>(find.byType(ProductSearchField)).warehouse, isNull);
  });
}
