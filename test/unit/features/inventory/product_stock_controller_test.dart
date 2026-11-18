import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/inventory/data/stock_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/stock.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/stock_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/stock/product_stock_controller.dart';

import 'stock_fixtures.dart';

class MockStockRepository extends Mock implements StockRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

Product _product() => const Product(
  productId: 7,
  code: 'A-100',
  name: 'Tornillo 1/4 caja',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Pieza',
  taxRate: '0.16',
  taxIncluded: false,
  priceType: 0,
  currency: 0,
  minOrderQty: 1,
  stockable: true,
  perishable: false,
  seriable: false,
  purchasable: true,
  salable: true,
  invoiceable: true,
  stockRequired: false,
  status: EntityStatus.active,
);

Warehouse _warehouse(int id, int facilityId) => Warehouse(
  warehouseId: id,
  facilityId: facilityId,
  facilityName: 'Sucursal $facilityId',
  code: 'W$id',
  name: 'Almacén $id',
  status: EntityStatus.active,
);

/// Spec 071 US2, research R6 (T011).
void main() {
  late MockStockRepository stock;
  late MockProductRepository products;
  late MockWarehouseRepository warehouses;

  setUp(() {
    stock = MockStockRepository();
    products = MockProductRepository();
    warehouses = MockWarehouseRepository();
    when(() => products.get(productId: 7)).thenAnswer((_) async => _product());
    when(
      () => warehouses.get(warehouseId: any(named: 'warehouseId')),
    ).thenAnswer((i) async {
      final id = i.namedArguments[#warehouseId] as int;
      return _warehouse(id, id * 10);
    });
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        stockRepositoryProvider.overrideWithValue(stock),
        productRepositoryProvider.overrideWithValue(products),
        warehouseRepositoryProvider.overrideWithValue(warehouses),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<ProductStockView> load() =>
      container().read(productStockControllerProvider(7).future);

  test('loads the stock, the product and each warehouse facility', () async {
    final productStock = aProductStock(
      warehouses: [aStockRow(warehouseId: 3), aStockRow(warehouseId: 4)],
      inTransit: [anInTransitStock()],
    );
    when(() => stock.product(7)).thenAnswer((_) async => productStock);

    final view = await load();

    expect(view.stock, productStock);
    expect(view.code, 'A-100');
    expect(view.name, 'Tornillo 1/4 caja');
    expect(view.facilities, {
      3: (facilityId: 30, facilityName: 'Sucursal 30'),
      4: (facilityId: 40, facilityName: 'Sucursal 40'),
    });
  });

  test('totals sum the rows, negatives included', () async {
    when(() => stock.product(7)).thenAnswer(
      (_) async => aProductStock(
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
            onHand: '-12',
            reserved: '1',
            available: '-13',
            incoming: '0',
          ),
        ],
      ),
    );

    final totals = (await load()).stock.totals;

    expect(totals.onHand, Decimal.parse('-2'));
    expect(totals.reserved, Decimal.parse('3'));
    expect(totals.available, Decimal.parse('-5'));
    expect(totals.incoming, Decimal.parse('5'));
  });

  test('each warehouse is resolved once', () async {
    when(() => stock.product(7)).thenAnswer(
      (_) async => aProductStock(
        warehouses: [aStockRow(warehouseId: 3), aStockRow(warehouseId: 3)],
      ),
    );

    final view = await load();

    expect(view.facilities.keys, [3]);
    verify(() => warehouses.get(warehouseId: 3)).called(1);
  });

  test('a failed warehouse lookup leaves it unresolved without failing the '
      'view', () async {
    when(
      () => warehouses.get(warehouseId: 4),
    ).thenThrow(const AppError.server());
    when(() => stock.product(7)).thenAnswer(
      (_) async => aProductStock(
        warehouses: [aStockRow(warehouseId: 3), aStockRow(warehouseId: 4)],
      ),
    );

    final view = await load();

    expect(view.stock.warehouses, hasLength(2));
    expect(view.facilities.keys, [3]);
  });

  test('a failed product lookup falls back to the server row names', () async {
    when(() => products.get(productId: 7)).thenThrow(const AppError.server());
    when(() => stock.product(7)).thenAnswer(
      (_) async => aProductStock(
        warehouses: [
          aStockRow(productCode: 'X-1', productName: 'Desde la fila'),
        ],
      ),
    );

    final view = await load();

    expect(view.code, 'X-1');
    expect(view.name, 'Desde la fila');
  });

  test('a not-found product is kept as an AppError', () async {
    when(() => stock.product(7)).thenThrow(const AppError.notFound());

    await expectLater(load(), throwsA(isA<NotFoundError>()));
  });

  test('an empty product loads empty', () async {
    when(() => stock.product(7)).thenAnswer(
      (_) async =>
          const ProductStock(productId: 7, warehouses: [], inTransit: []),
    );

    final view = await load();

    expect(view.stock.isEmpty, isTrue);
    expect(view.facilities, isEmpty);
    expect(view.code, 'A-100');
    verifyNever(() => warehouses.get(warehouseId: any(named: 'warehouseId')));
  });
}
