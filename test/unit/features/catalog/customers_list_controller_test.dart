import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
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
  status: EntityStatus.active,
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

  group('CustomerFilter.fromQuery (017-ui-consistency-filters FR-017)', () {
    test('derives every field from a ListQuery', () {
      final filter = CustomerFilter.fromQuery(
        const ListQuery(
          search: 'Acme',
          pageIndex: 2,
          facets: {
            'status': ['active'],
            'priceList': ['1'],
            'salesperson': ['2'],
          },
        ),
      );

      expect(filter.search, 'Acme');
      expect(filter.pageIndex, 2);
      expect(filter.status, EntityStatus.active);
      expect(filter.priceListId, 1);
      expect(filter.salespersonId, 2);
      expect(filter.activeFilterCount, 3);
    });

    test('defaults from an empty ListQuery', () {
      final filter = CustomerFilter.fromQuery(const ListQuery());

      expect(filter.search, '');
      expect(filter.pageIndex, 0);
      expect(filter.status, isNull);
      expect(filter.priceListId, isNull);
      expect(filter.salespersonId, isNull);
      expect(filter.hasActiveFilters, isFalse);
    });
  });

  group('CustomersListController (a family keyed by CustomerFilter)', () {
    test('build(filter) maps the filter to repository query params', () async {
      when(
        () => repository.list(
          search: null,
          status: null,
          priceList: null,
          salesperson: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => CustomerPage(items: [_customer(1)], total: 1),
      );

      const filter = CustomerFilter();
      final result = await container.read(
        customersListControllerProvider(filter).future,
      );

      expect(result.items, hasLength(1));
      expect(result.total, 1);
    });

    test(
      'a different priceList filter maps to a different provider instance and query',
      () async {
        when(
          () => repository.list(
            search: null,
            status: null,
            priceList: null,
            salesperson: null,
            skip: 0,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => CustomerPage(items: [_customer(1)], total: 1),
        );
        when(
          () => repository.list(
            search: null,
            status: null,
            priceList: 1,
            salesperson: null,
            skip: 0,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => CustomerPage(items: [_customer(2)], total: 1),
        );

        final first = await container.read(
          customersListControllerProvider(const CustomerFilter()).future,
        );
        final second = await container.read(
          customersListControllerProvider(
            const CustomerFilter(priceListId: 1),
          ).future,
        );

        expect(first.items.single.customerId, 1);
        expect(second.items.single.customerId, 2);
      },
    );

    test('a different pageIndex maps to skip = pageIndex * pageSize', () async {
      when(
        () => repository.list(
          search: null,
          status: null,
          priceList: null,
          salesperson: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => CustomerPage(items: [_customer(1)], total: 21),
      );
      when(
        () => repository.list(
          search: null,
          status: null,
          priceList: null,
          salesperson: null,
          skip: 20,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => CustomerPage(items: [_customer(2)], total: 21),
      );

      final page0 = await container.read(
        customersListControllerProvider(const CustomerFilter()).future,
      );
      final page1 = await container.read(
        customersListControllerProvider(
          const CustomerFilter(pageIndex: 1),
        ).future,
      );

      expect(page0.items.map((c) => c.customerId), [1]);
      expect(page0.pageIndex, 0);
      expect(page1.items.map((c) => c.customerId), [2]);
      expect(page1.pageIndex, 1);
      expect(page1.total, 21);
    });

    test(
      'invalidating the provider re-fetches the SAME page rather than '
      'resetting to page 0 (017-ui-consistency-filters FR-025, research §3)',
      () async {
        const filter = CustomerFilter(pageIndex: 1);
        when(
          () => repository.list(
            search: null,
            status: null,
            priceList: null,
            salesperson: null,
            skip: 20,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => CustomerPage(items: [_customer(2)], total: 21),
        );

        await container.read(customersListControllerProvider(filter).future);

        when(
          () => repository.list(
            search: null,
            status: null,
            priceList: null,
            salesperson: null,
            skip: 20,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => CustomerPage(items: [_customer(99)], total: 21),
        );
        container.invalidate(customersListControllerProvider(filter));

        final refreshed = await container.read(
          customersListControllerProvider(filter).future,
        );
        expect(refreshed.pageIndex, 1);
        expect(refreshed.items.single.customerId, 99);
      },
    );
  });
}
