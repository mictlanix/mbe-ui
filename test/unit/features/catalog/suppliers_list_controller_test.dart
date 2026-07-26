import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/suppliers_list_controller.dart';

class MockSupplierRepository extends Mock implements SupplierRepository {}

Supplier _supplier(int id) => Supplier(
  supplierId: id,
  code: 'SUP-$id',
  name: 'Supplier $id',
  creditLimit: '0',
  creditDays: 0,
);

void main() {
  late MockSupplierRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockSupplierRepository();
    container = ProviderContainer(
      overrides: [supplierRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group('SupplierFilter.fromQuery (017-ui-consistency-filters FR-017)', () {
    test('derives every field from a ListQuery', () {
      final filter = SupplierFilter.fromQuery(
        const ListQuery(search: 'Acme', pageIndex: 2),
      );

      expect(filter.search, 'Acme');
      expect(filter.pageIndex, 2);
    });

    test('defaults from an empty ListQuery', () {
      final filter = SupplierFilter.fromQuery(const ListQuery());

      expect(filter.search, '');
      expect(filter.pageIndex, 0);
    });
  });

  group('SuppliersListController (a family keyed by SupplierFilter)', () {
    test('build(filter) maps the filter to repository query params', () async {
      when(
        () => repository.listDetailed(search: null, skip: 0, limit: 20),
      ).thenAnswer((_) async => SupplierPage(items: [_supplier(1)], total: 1));

      const filter = SupplierFilter();
      final result = await container.read(
        suppliersListControllerProvider(filter).future,
      );

      expect(result.items, hasLength(1));
      expect(result.total, 1);
    });

    test(
      'a different search maps to a different provider instance and query',
      () async {
        when(
          () => repository.listDetailed(search: null, skip: 0, limit: 20),
        ).thenAnswer(
          (_) async => SupplierPage(items: [_supplier(1)], total: 1),
        );
        when(
          () => repository.listDetailed(search: 'Acme', skip: 0, limit: 20),
        ).thenAnswer(
          (_) async => SupplierPage(items: [_supplier(2)], total: 1),
        );

        final first = await container.read(
          suppliersListControllerProvider(const SupplierFilter()).future,
        );
        final second = await container.read(
          suppliersListControllerProvider(
            const SupplierFilter(search: 'Acme'),
          ).future,
        );

        expect(first.items.single.supplierId, 1);
        expect(second.items.single.supplierId, 2);
      },
    );

    test('a different pageIndex maps to skip = pageIndex * pageSize', () async {
      when(
        () => repository.listDetailed(search: null, skip: 0, limit: 20),
      ).thenAnswer((_) async => SupplierPage(items: [_supplier(1)], total: 21));
      when(
        () => repository.listDetailed(search: null, skip: 20, limit: 20),
      ).thenAnswer((_) async => SupplierPage(items: [_supplier(2)], total: 21));

      final page0 = await container.read(
        suppliersListControllerProvider(const SupplierFilter()).future,
      );
      final page1 = await container.read(
        suppliersListControllerProvider(
          const SupplierFilter(pageIndex: 1),
        ).future,
      );

      expect(page0.items.map((s) => s.supplierId), [1]);
      expect(page0.pageIndex, 0);
      expect(page1.items.map((s) => s.supplierId), [2]);
      expect(page1.pageIndex, 1);
      expect(page1.total, 21);
    });

    test(
      'invalidating the provider re-fetches the SAME page rather than '
      'resetting to page 0 (017-ui-consistency-filters FR-025, research §3)',
      () async {
        const filter = SupplierFilter(pageIndex: 1);
        when(
          () => repository.listDetailed(search: null, skip: 20, limit: 20),
        ).thenAnswer(
          (_) async => SupplierPage(items: [_supplier(2)], total: 21),
        );

        await container.read(suppliersListControllerProvider(filter).future);

        when(
          () => repository.listDetailed(search: null, skip: 20, limit: 20),
        ).thenAnswer(
          (_) async => SupplierPage(items: [_supplier(99)], total: 21),
        );
        container.invalidate(suppliersListControllerProvider(filter));

        final refreshed = await container.read(
          suppliersListControllerProvider(filter).future,
        );
        expect(refreshed.pageIndex, 1);
        expect(refreshed.items.single.supplierId, 99);
      },
    );
  });
}
