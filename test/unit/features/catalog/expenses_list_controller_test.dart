import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

  group('ExpenseSearchController', () {
    test('starts empty', () {
      expect(container.read(expenseSearchControllerProvider), '');
    });

    test('updates on searchChanged', () {
      container
          .read(expenseSearchControllerProvider.notifier)
          .searchChanged('Rent');
      expect(container.read(expenseSearchControllerProvider), 'Rent');
    });
  });

  group('ExpensesListController', () {
    test(
      'build() maps the current search to repository query params',
      () async {
        when(
          () => repository.list(search: null, skip: 0, limit: 20),
        ).thenAnswer(
          (_) async => ExpenseListResult(items: [_expense(1)], total: 1),
        );

        final result = await container.read(
          expensesListControllerProvider.future,
        );

        expect(result.items, hasLength(1));
        expect(result.total, 1);
      },
    );

    test('changing the search text re-fetches from skip=0', () async {
      when(() => repository.list(search: null, skip: 0, limit: 20)).thenAnswer(
        (_) async => ExpenseListResult(items: [_expense(1)], total: 1),
      );
      await container.read(expensesListControllerProvider.future);

      when(
        () => repository.list(search: 'Rent', skip: 0, limit: 20),
      ).thenAnswer(
        (_) async => ExpenseListResult(items: [_expense(2)], total: 1),
      );
      container
          .read(expenseSearchControllerProvider.notifier)
          .searchChanged('Rent');

      final result = await container.read(
        expensesListControllerProvider.future,
      );
      expect(result.items.single.expenseId, 2);
    });

    test('goToPage replaces the current page with the requested one', () async {
      when(() => repository.list(search: null, skip: 0, limit: 20)).thenAnswer(
        (_) async => ExpenseListResult(items: [_expense(1)], total: 21),
      );
      await container.read(expensesListControllerProvider.future);

      when(() => repository.list(search: null, skip: 20, limit: 20)).thenAnswer(
        (_) async => ExpenseListResult(items: [_expense(2)], total: 21),
      );

      await container.read(expensesListControllerProvider.notifier).goToPage(1);

      final page = container.read(expensesListControllerProvider).value!;
      expect(page.items.map((e) => e.expenseId), [2]);
      expect(page.pageIndex, 1);
      expect(page.total, 21);
    });
  });
}
