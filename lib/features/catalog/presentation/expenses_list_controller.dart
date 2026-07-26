import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/expense_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/expense.dart';

part 'expenses_list_controller.freezed.dart';
part 'expenses_list_controller.g.dart';

const _pageSize = 20;

/// The Expenses list screen's addressable view state
/// (017-ui-consistency-filters FR-017): search only. Derived from the
/// route's [ListQuery] — the URL, not a mutable notifier, is the source of
/// truth.
@freezed
class ExpenseFilter with _$ExpenseFilter {
  const factory ExpenseFilter({
    @Default('') String search,
    @Default(0) int pageIndex,
  }) = _ExpenseFilter;

  factory ExpenseFilter.fromQuery(ListQuery query) {
    return ExpenseFilter(search: query.search, pageIndex: query.pageIndex);
  }
}

/// Fetches and holds the Expenses list (FR-001) for the given
/// [ExpenseFilter]. A family keyed by the filter value: a different URL is
/// a different provider instance, and `ref.invalidate` after a mutation
/// re-fetches the *same* page rather than resetting to page 0 (FR-025,
/// research §3).
@riverpod
class ExpensesListController extends _$ExpensesListController {
  @override
  Future<CatalogPage<Expense>> build(ExpenseFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<Expense>> _fetch(ExpenseFilter filter) async {
    final result = await ref
        .read(expenseRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          skip: filter.pageIndex * _pageSize,
          limit: _pageSize,
        );
    return CatalogPage(
      items: result.items,
      total: result.total,
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
    );
  }
}
