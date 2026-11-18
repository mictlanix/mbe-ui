import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/inventory/data/stock_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/stock.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/stock_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/stock/stock_list_controller.dart';

import 'stock_fixtures.dart';

class MockStockRepository extends Mock implements StockRepository {}

/// Spec 071 FR-002–FR-005, research R7 (T007).
void main() {
  late MockStockRepository repository;

  setUp(() => repository = MockStockRepository());

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [stockRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(c.dispose);
    return c;
  }

  When<Future<StockPage>> whenList() => when(
    () => repository.list(
      warehouseId: any(named: 'warehouseId'),
      q: any(named: 'q'),
      includeZero: any(named: 'includeZero'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  );

  /// A fake server holding [rows], paged by `skip` and `limit`.
  void serve(List<StockRow> rows) {
    whenList().thenAnswer((invocation) async {
      final skip = invocation.namedArguments[#skip] as int;
      final limit = invocation.namedArguments[#limit] as int;
      final end = (skip + limit).clamp(0, rows.length);
      return StockPage(
        items: skip >= rows.length ? const [] : rows.sublist(skip, end),
        total: rows.length,
      );
    });
  }

  List<StockRow> rows(int n) => [
    for (var i = 1; i <= n; i++) aStockRow(productId: i),
  ];

  test('the query reaches the repository, 50 per page', () async {
    serve(rows(120));
    const query = StockQuery(
      warehouseId: 3,
      q: 'torn',
      includeZero: true,
      pageIndex: 1,
    );

    final page = await container().read(
      stockListControllerProvider(query).future,
    );

    expect(page.items, hasLength(50));
    expect(page.items.first.productId, 51);
    expect(page.total, 120);
    expect(page.pageIndex, 1);
    expect(page.pageSize, 50);
    verify(
      () => repository.list(
        warehouseId: 3,
        q: 'torn',
        includeZero: true,
        skip: 50,
        limit: 50,
      ),
    ).called(1);
  });

  test('without a warehouse it makes no request and holds an empty '
      'page', () async {
    final page = await container().read(
      stockListControllerProvider(const StockQuery(q: 'torn')).future,
    );

    expect(page.items, isEmpty);
    expect(page.total, 0);
    verifyNever(
      () => repository.list(
        warehouseId: any(named: 'warehouseId'),
        q: any(named: 'q'),
        includeZero: any(named: 'includeZero'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    );
  });

  test('a page past the end is clamped to the last page', () async {
    serve(rows(70));

    final page = await container().read(
      stockListControllerProvider(
        const StockQuery(warehouseId: 3, pageIndex: 9),
      ).future,
    );

    expect(page.pageIndex, 1);
    expect(page.items, hasLength(20));
    verify(
      () => repository.list(
        warehouseId: 3,
        q: '',
        includeZero: false,
        skip: 50,
        limit: 50,
      ),
    ).called(1);
  });

  test('a failure becomes an AsyncError carrying the AppError', () async {
    whenList().thenAnswer((_) async => throw const AppError.network());
    final c = container();
    final provider = stockListControllerProvider(
      const StockQuery(warehouseId: 3),
    );
    c.listen(provider, (_, _) {});

    await expectLater(c.read(provider.future), throwsA(isA<NetworkError>()));
    expect(c.read(provider), isA<AsyncError<CatalogPage<StockRow>>>());
  });

  group('StockQuery', () {
    test('reads the warehouse, q, include_zero and page from the URL', () {
      final query = StockQuery.fromQuery(
        ListQuery.fromUri(
          Uri.parse(
            '/inventory/stock?page=3&warehouse=4&q=a-1&include_zero=true',
          ),
        ),
      );
      expect(
        query,
        const StockQuery(
          warehouseId: 4,
          q: 'a-1',
          includeZero: true,
          pageIndex: 2,
        ),
      );
    });

    test('a non-numeric warehouse and any other include_zero are '
        'ignored', () {
      final query = StockQuery.fromQuery(
        ListQuery.fromUri(
          Uri.parse('/inventory/stock?warehouse=abc&include_zero=1'),
        ),
      );
      expect(query, const StockQuery());
    });

    test('round-trips through the URL, defaults omitted', () {
      const query = StockQuery(
        warehouseId: 4,
        q: 'torn',
        includeZero: true,
        pageIndex: 2,
      );
      final uri = query.toQuery().toUri('/inventory/stock');
      expect(
        uri.toString(),
        '/inventory/stock?page=3&warehouse=4&q=torn&include_zero=true',
      );
      expect(StockQuery.fromQuery(ListQuery.fromUri(uri)), query);
      expect(
        const StockQuery().toQuery().toUri('/inventory/stock').toString(),
        '/inventory/stock',
      );
    });

    test('a search, switch or warehouse change returns to page 1', () {
      const query = StockQuery(warehouseId: 4, pageIndex: 5);
      expect(query.withSearch('torn'), query.copyWith(q: 'torn', pageIndex: 0));
      expect(
        query.withIncludeZero(true),
        query.copyWith(includeZero: true, pageIndex: 0),
      );
      expect(query.withWarehouse(9), const StockQuery(warehouseId: 9));
    });

    test('the badge counts the warehouse and the switch, not the search', () {
      expect(const StockQuery(q: 'torn').activeFilterCount, 0);
      expect(const StockQuery(warehouseId: 4).activeFilterCount, 1);
      expect(
        const StockQuery(warehouseId: 4, includeZero: true).activeFilterCount,
        2,
      );
    });
  });
}
