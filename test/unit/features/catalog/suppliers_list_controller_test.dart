import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

  group('SupplierSearchController', () {
    test('starts empty', () {
      expect(container.read(supplierSearchControllerProvider), '');
    });

    test('updates on searchChanged', () {
      container
          .read(supplierSearchControllerProvider.notifier)
          .searchChanged('Acme');
      expect(container.read(supplierSearchControllerProvider), 'Acme');
    });
  });

  group('SuppliersListController', () {
    test(
      'build() maps the current search to repository query params',
      () async {
        when(
          () => repository.listDetailed(search: null, skip: 0, limit: 20),
        ).thenAnswer(
          (_) async => SupplierPage(items: [_supplier(1)], total: 1),
        );

        final result = await container.read(
          suppliersListControllerProvider.future,
        );

        expect(result.items, hasLength(1));
        expect(result.total, 1);
      },
    );

    test('changing the search text re-fetches from skip=0', () async {
      when(
        () => repository.listDetailed(search: null, skip: 0, limit: 20),
      ).thenAnswer((_) async => SupplierPage(items: [_supplier(1)], total: 1));
      await container.read(suppliersListControllerProvider.future);

      when(
        () => repository.listDetailed(search: 'Acme', skip: 0, limit: 20),
      ).thenAnswer((_) async => SupplierPage(items: [_supplier(2)], total: 1));
      container
          .read(supplierSearchControllerProvider.notifier)
          .searchChanged('Acme');

      final result = await container.read(
        suppliersListControllerProvider.future,
      );
      expect(result.items.single.supplierId, 2);
    });

    test('goToPage replaces the current page with the requested one', () async {
      when(
        () => repository.listDetailed(search: null, skip: 0, limit: 20),
      ).thenAnswer(
        (_) async => SupplierPage(items: [_supplier(1)], total: 21),
      );
      await container.read(suppliersListControllerProvider.future);

      when(
        () => repository.listDetailed(search: null, skip: 20, limit: 20),
      ).thenAnswer(
        (_) async => SupplierPage(items: [_supplier(2)], total: 21),
      );

      await container
          .read(suppliersListControllerProvider.notifier)
          .goToPage(1);

      final page = container.read(suppliersListControllerProvider).value!;
      expect(page.items.map((s) => s.supplierId), [2]);
      expect(page.pageIndex, 1);
      expect(page.total, 21);
    });
  });
}
