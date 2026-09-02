import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/employee_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/employees_list_controller.dart';

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

EmployeeListItem _employee(int id) => EmployeeListItem(
  employeeId: id,
  fullName: 'Employee $id',
  nickname: 'E$id',
  status: EntityStatus.active,
  salesPerson: false,
);

void main() {
  late MockEmployeeRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockEmployeeRepository();
    container = ProviderContainer(
      overrides: [employeeRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group('EmployeeFilter.fromQuery (017-ui-consistency-filters FR-017)', () {
    test('derives every field from a ListQuery', () {
      final filter = EmployeeFilter.fromQuery(
        const ListQuery(
          search: 'Jane',
          pageIndex: 2,
          facets: {
            'status': ['active'],
            'salesPerson': ['false'],
          },
        ),
      );

      expect(filter.search, 'Jane');
      expect(filter.pageIndex, 2);
      expect(filter.status, EntityStatus.active);
      expect(filter.salesPerson, isFalse);
      expect(filter.activeFilterCount, 2);
    });

    test('defaults from an empty ListQuery', () {
      final filter = EmployeeFilter.fromQuery(const ListQuery());

      expect(filter.search, '');
      expect(filter.pageIndex, 0);
      // spec 035 FR-001/FR-002/FR-006: an absent status facet now defaults
      // to Active, not "no filter" — and that default counts toward the
      // filters badge, same as an explicit choice would.
      expect(filter.status, EntityStatus.active);
      expect(filter.salesPerson, isNull);
      expect(filter.hasActiveFilters, isTrue);
    });

    test('an explicit "all" status clears the default (FR-004)', () {
      final filter = EmployeeFilter.fromQuery(
        const ListQuery(
          facets: {
            'status': ['all'],
          },
        ),
      );

      expect(filter.status, isNull);
      expect(filter.hasActiveFilters, isFalse);
    });
  });

  group('EmployeesListController (a family keyed by EmployeeFilter)', () {
    test('build(filter) maps the filter to repository query params', () async {
      when(
        () => repository.list(
          search: null,
          status: null,
          salesPerson: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => EmployeeListResult(items: [_employee(1)], total: 1),
      );

      const filter = EmployeeFilter();
      final result = await container.read(
        employeesListControllerProvider(filter).future,
      );

      expect(result.items, hasLength(1));
      expect(result.total, 1);
    });

    test(
      'a different status filter maps to a different provider instance and query',
      () async {
        when(
          () => repository.list(
            search: null,
            status: null,
            salesPerson: null,
            skip: 0,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => EmployeeListResult(items: [_employee(1)], total: 1),
        );
        when(
          () => repository.list(
            search: null,
            status: EntityStatus.active,
            salesPerson: null,
            skip: 0,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => EmployeeListResult(items: [_employee(2)], total: 1),
        );

        final first = await container.read(
          employeesListControllerProvider(const EmployeeFilter()).future,
        );
        final second = await container.read(
          employeesListControllerProvider(
            const EmployeeFilter(status: EntityStatus.active),
          ).future,
        );

        expect(first.items.single.employeeId, 1);
        expect(second.items.single.employeeId, 2);
      },
    );

    test('a different pageIndex maps to skip = pageIndex * pageSize', () async {
      when(
        () => repository.list(
          search: null,
          status: null,
          salesPerson: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => EmployeeListResult(items: [_employee(1)], total: 21),
      );
      when(
        () => repository.list(
          search: null,
          status: null,
          salesPerson: null,
          skip: 20,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => EmployeeListResult(items: [_employee(2)], total: 21),
      );

      final page0 = await container.read(
        employeesListControllerProvider(const EmployeeFilter()).future,
      );
      final page1 = await container.read(
        employeesListControllerProvider(
          const EmployeeFilter(pageIndex: 1),
        ).future,
      );

      expect(page0.items.map((e) => e.employeeId), [1]);
      expect(page0.pageIndex, 0);
      expect(page1.items.map((e) => e.employeeId), [2]);
      expect(page1.pageIndex, 1);
      expect(page1.total, 21);
    });

    test(
      'invalidating the provider re-fetches the SAME page rather than '
      'resetting to page 0 (017-ui-consistency-filters FR-025, research §3)',
      () async {
        const filter = EmployeeFilter(pageIndex: 1);
        when(
          () => repository.list(
            search: null,
            status: null,
            salesPerson: null,
            skip: 20,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => EmployeeListResult(items: [_employee(2)], total: 21),
        );

        await container.read(employeesListControllerProvider(filter).future);

        when(
          () => repository.list(
            search: null,
            status: null,
            salesPerson: null,
            skip: 20,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => EmployeeListResult(items: [_employee(99)], total: 21),
        );
        container.invalidate(employeesListControllerProvider(filter));

        final refreshed = await container.read(
          employeesListControllerProvider(filter).future,
        );
        expect(refreshed.pageIndex, 1);
        expect(refreshed.items.single.employeeId, 99);
      },
    );
  });
}
