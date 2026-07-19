import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/employee_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/employees_list_controller.dart';

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

EmployeeListItem _employee(int id) => EmployeeListItem(
  employeeId: id,
  fullName: 'Employee $id',
  nickname: 'E$id',
  active: true,
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

  group('EmployeeFilterController', () {
    test('starts with no filters', () {
      final filter = container.read(employeeFilterControllerProvider);
      expect(filter.search, '');
      expect(filter.active, isNull);
      expect(filter.salesPerson, isNull);
      expect(filter.hasActiveFilters, isFalse);
    });

    test('activeChanged/salesPersonChanged set independently', () {
      final notifier = container.read(
        employeeFilterControllerProvider.notifier,
      );
      notifier.activeChanged(true);
      notifier.salesPersonChanged(false);

      final filter = container.read(employeeFilterControllerProvider);
      expect(filter.active, isTrue);
      expect(filter.salesPerson, isFalse);
      expect(filter.activeFilterCount, 2);
    });

    test('reset clears facets but preserves search', () {
      final notifier = container.read(
        employeeFilterControllerProvider.notifier,
      );
      notifier
        ..searchChanged('Jane')
        ..activeChanged(true);

      notifier.reset();

      final filter = container.read(employeeFilterControllerProvider);
      expect(filter.search, 'Jane');
      expect(filter.active, isNull);
    });
  });

  group('EmployeesListController', () {
    test('build() maps the current filter to repository query params', () async {
      when(
        () => repository.list(
          search: null,
          active: null,
          salesPerson: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => EmployeeListResult(items: [_employee(1)], total: 1),
      );

      final result = await container.read(
        employeesListControllerProvider.future,
      );

      expect(result.items, hasLength(1));
      expect(result.total, 1);
    });

    test('changing the active filter re-fetches from skip=0', () async {
      when(
        () => repository.list(
          search: null,
          active: null,
          salesPerson: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => EmployeeListResult(items: [_employee(1)], total: 1),
      );
      await container.read(employeesListControllerProvider.future);

      when(
        () => repository.list(
          search: null,
          active: true,
          salesPerson: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => EmployeeListResult(items: [_employee(2)], total: 1),
      );
      container
          .read(employeeFilterControllerProvider.notifier)
          .activeChanged(true);

      final result = await container.read(
        employeesListControllerProvider.future,
      );
      expect(result.items.single.employeeId, 2);
    });

    test('goToPage replaces the current page with the requested one', () async {
      when(
        () => repository.list(
          search: null,
          active: null,
          salesPerson: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => EmployeeListResult(items: [_employee(1)], total: 21),
      );
      await container.read(employeesListControllerProvider.future);

      when(
        () => repository.list(
          search: null,
          active: null,
          salesPerson: null,
          skip: 20,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => EmployeeListResult(items: [_employee(2)], total: 21),
      );

      await container
          .read(employeesListControllerProvider.notifier)
          .goToPage(1);

      final page = container.read(employeesListControllerProvider).value!;
      expect(page.items.map((e) => e.employeeId), [2]);
      expect(page.pageIndex, 1);
    });
  });
}
