import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/customers_list_controller.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

CustomerListItem _customer(int id) => CustomerListItem(
  customerId: id,
  code: 'CUST-$id',
  name: 'Customer $id',
  creditLimit: '0',
  creditDays: 0,
  priceList: const PriceListRef(id: 1, name: 'Retail'),
  disabled: false,
);

void main() {
  late MockCustomerRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockCustomerRepository();
    container = ProviderContainer(
      overrides: [customerRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group('CustomerFilterController', () {
    test('starts with no filters', () {
      final filter = container.read(customerFilterControllerProvider);
      expect(filter.search, '');
      expect(filter.disabled, isNull);
      expect(filter.priceListId, isNull);
      expect(filter.salespersonId, isNull);
      expect(filter.hasActiveFilters, isFalse);
    });

    test('priceListChanged/salespersonChanged/disabledChanged set independently', () {
      final notifier = container.read(
        customerFilterControllerProvider.notifier,
      );
      notifier
        ..disabledChanged(false)
        ..priceListChanged(1, 'Retail')
        ..salespersonChanged(2, 'Jane Doe');

      final filter = container.read(customerFilterControllerProvider);
      expect(filter.disabled, isFalse);
      expect(filter.priceListId, 1);
      expect(filter.salespersonId, 2);
      expect(filter.activeFilterCount, 3);
    });

    test('reset clears facets but preserves search', () {
      final notifier = container.read(
        customerFilterControllerProvider.notifier,
      );
      notifier
        ..searchChanged('Acme')
        ..priceListChanged(1, 'Retail');

      notifier.reset();

      final filter = container.read(customerFilterControllerProvider);
      expect(filter.search, 'Acme');
      expect(filter.priceListId, isNull);
    });
  });

  group('CustomersListController', () {
    test('build() maps the current filter to repository query params', () async {
      when(
        () => repository.list(
          search: null,
          disabled: null,
          priceList: null,
          salesperson: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => CustomerPage(items: [_customer(1)], total: 1),
      );

      final result = await container.read(
        customersListControllerProvider.future,
      );

      expect(result.items, hasLength(1));
      expect(result.total, 1);
    });

    test('changing the priceList filter re-fetches from skip=0', () async {
      when(
        () => repository.list(
          search: null,
          disabled: null,
          priceList: null,
          salesperson: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => CustomerPage(items: [_customer(1)], total: 1),
      );
      await container.read(customersListControllerProvider.future);

      when(
        () => repository.list(
          search: null,
          disabled: null,
          priceList: 1,
          salesperson: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => CustomerPage(items: [_customer(2)], total: 1),
      );
      container
          .read(customerFilterControllerProvider.notifier)
          .priceListChanged(1, 'Retail');

      final result = await container.read(
        customersListControllerProvider.future,
      );
      expect(result.items.single.customerId, 2);
    });

    test('goToPage replaces the current page with the requested one', () async {
      when(
        () => repository.list(
          search: null,
          disabled: null,
          priceList: null,
          salesperson: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => CustomerPage(items: [_customer(1)], total: 21),
      );
      await container.read(customersListControllerProvider.future);

      when(
        () => repository.list(
          search: null,
          disabled: null,
          priceList: null,
          salesperson: null,
          skip: 20,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => CustomerPage(items: [_customer(2)], total: 21),
      );

      await container
          .read(customersListControllerProvider.notifier)
          .goToPage(1);

      final page = container.read(customersListControllerProvider).value!;
      expect(page.items.map((c) => c.customerId), [2]);
      expect(page.pageIndex, 1);
    });
  });
}
