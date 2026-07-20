import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/expense_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/expense.dart';

part 'expenses_list_controller.g.dart';

const _pageSize = 20;

/// Holds the current search text for the Expenses catalog screen (FR-001,
/// FR-002).
@riverpod
class ExpenseSearchController extends _$ExpenseSearchController {
  @override
  String build() => '';

  void searchChanged(String value) => state = value;
}

/// Fetches and holds the Expenses list (FR-001), re-fetching page 0 whenever
/// the search text changes.
@riverpod
class ExpensesListController extends _$ExpensesListController {
  @override
  Future<CatalogPage<Expense>> build() {
    final search = ref.watch(expenseSearchControllerProvider);
    return _fetch(search, pageIndex: 0);
  }

  Future<CatalogPage<Expense>> _fetch(
    String search, {
    required int pageIndex,
  }) async {
    final result = await ref
        .read(expenseRepositoryProvider)
        .list(
          search: search.isEmpty ? null : search,
          skip: pageIndex * _pageSize,
          limit: _pageSize,
        );
    return CatalogPage(
      items: result.items,
      total: result.total,
      pageIndex: pageIndex,
      pageSize: _pageSize,
    );
  }

  /// Fetches [pageIndex] and replaces the current page with it.
  Future<void> goToPage(int pageIndex) async {
    final search = ref.read(expenseSearchControllerProvider);
    state = const AsyncLoading<CatalogPage<Expense>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(search, pageIndex: pageIndex));
  }
}
