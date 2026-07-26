import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/catalog/data/expense_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/expense.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/expense_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/expenses_list_controller.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

Expense _expense(int id) => Expense(expenseId: id, name: 'Expense $id');

void main() {
  late MockExpenseRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockExpenseRepository();
    container = ProviderContainer(
      overrides: [expenseRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group('ExpenseFilter.fromQuery (017-ui-consistency-filters FR-017)', () {
    test('derives every field from a ListQuery', () {
      final filter = ExpenseFilter.fromQuery(
        const ListQuery(search: 'Rent', pageIndex: 2),
      );

      expect(filter.search, 'Rent');
      expect(filter.pageIndex, 2);
    });

    test('defaults from an empty ListQuery', () {
      final filter = ExpenseFilter.fromQuery(const ListQuery());

      expect(filter.search, '');
      expect(filter.pageIndex, 0);
    });
  });

  group('ExpensesListController (a family keyed by ExpenseFilter)', () {
    test('build(filter) maps the filter to repository query params', () async {
      when(() => repository.list(search: null, skip: 0, limit: 20)).thenAnswer(
        (_) async => ExpenseListResult(items: [_expense(1)], total: 1),
      );

      const filter = ExpenseFilter();
      final result = await container.read(
        expensesListControllerProvider(filter).future,
      );

      expect(result.items, hasLength(1));
      expect(result.total, 1);
    });

    test(
      'a different search maps to a different provider instance and query',
      () async {
        when(
          () => repository.list(search: null, skip: 0, limit: 20),
        ).thenAnswer(
          (_) async => ExpenseListResult(items: [_expense(1)], total: 1),
        );
        when(
          () => repository.list(search: 'Rent', skip: 0, limit: 20),
        ).thenAnswer(
          (_) async => ExpenseListResult(items: [_expense(2)], total: 1),
        );

        final first = await container.read(
          expensesListControllerProvider(const ExpenseFilter()).future,
        );
        final second = await container.read(
          expensesListControllerProvider(
            const ExpenseFilter(search: 'Rent'),
          ).future,
        );

        expect(first.items.single.expenseId, 1);
        expect(second.items.single.expenseId, 2);
      },
    );

    test('a different pageIndex maps to skip = pageIndex * pageSize', () async {
      when(() => repository.list(search: null, skip: 0, limit: 20)).thenAnswer(
        (_) async => ExpenseListResult(items: [_expense(1)], total: 21),
      );
      when(() => repository.list(search: null, skip: 20, limit: 20)).thenAnswer(
        (_) async => ExpenseListResult(items: [_expense(2)], total: 21),
      );

      final page0 = await container.read(
        expensesListControllerProvider(const ExpenseFilter()).future,
      );
      final page1 = await container.read(
        expensesListControllerProvider(
          const ExpenseFilter(pageIndex: 1),
        ).future,
      );

      expect(page0.items.map((e) => e.expenseId), [1]);
      expect(page0.pageIndex, 0);
      expect(page1.items.map((e) => e.expenseId), [2]);
      expect(page1.pageIndex, 1);
      expect(page1.total, 21);
    });

    test(
      'invalidating the provider re-fetches the SAME page rather than '
      'resetting to page 0 (017-ui-consistency-filters FR-025, research §3)',
      () async {
        const filter = ExpenseFilter(pageIndex: 1);
        when(
          () => repository.list(search: null, skip: 20, limit: 20),
        ).thenAnswer(
          (_) async => ExpenseListResult(items: [_expense(2)], total: 21),
        );

        await container.read(expensesListControllerProvider(filter).future);

        when(
          () => repository.list(search: null, skip: 20, limit: 20),
        ).thenAnswer(
          (_) async => ExpenseListResult(items: [_expense(99)], total: 21),
        );
        container.invalidate(expensesListControllerProvider(filter));

        final refreshed = await container.read(
          expensesListControllerProvider(filter).future,
        );
        expect(refreshed.pageIndex, 1);
        expect(refreshed.items.single.expenseId, 99);
      },
    );
  });
}
