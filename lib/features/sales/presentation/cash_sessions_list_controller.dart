import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/cash_session_status.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';

part 'cash_sessions_list_controller.freezed.dart';
part 'cash_sessions_list_controller.g.dart';

const _pageSize = 20;

/// The history list's addressable view state (data-model.md §9,
/// research.md §17) — cash drawer, cashier and status facets, all opt-in.
/// **No `search` field**: the endpoint has none, and a session has no
/// free-text field one would match against (spec D-003).
@freezed
class CashSessionFilter with _$CashSessionFilter {
  const factory CashSessionFilter({
    int? cashDrawerId,
    int? cashierId,
    CashSessionStatus? status,
    @Default(0) int pageIndex,
  }) = _CashSessionFilter;

  factory CashSessionFilter.fromQuery(ListQuery query) {
    final drawerRaw = query.facet('cash-drawer');
    final cashierRaw = query.facet('cashier');
    final statusRaw = query.facet('status');
    return CashSessionFilter(
      cashDrawerId: drawerRaw != null ? int.tryParse(drawerRaw) : null,
      cashierId: cashierRaw != null ? int.tryParse(cashierRaw) : null,
      status: statusRaw != null ? _statusByName(statusRaw) : null,
      pageIndex: query.pageIndex,
    );
  }
}

CashSessionStatus? _statusByName(String name) {
  for (final status in CashSessionStatus.values) {
    if (status.name == name) return status;
  }
  return null;
}

extension CashSessionFilterBadge on CashSessionFilter {
  int get activeFilterCount =>
      (cashDrawerId != null ? 1 : 0) +
      (cashierId != null ? 1 : 0) +
      (status != null ? 1 : 0);

  bool get hasActiveFilters => activeFilterCount > 0;
}

/// Fetches and holds the history list (FR-027 to FR-029, FR-034) for the
/// given [CashSessionFilter].
@riverpod
class CashSessionsListController extends _$CashSessionsListController {
  @override
  Future<CatalogPage<CashSession>> build(CashSessionFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<CashSession>> _fetch(CashSessionFilter filter) async {
    final result = await ref
        .read(cashSessionRepositoryProvider)
        .list(
          cashDrawerId: filter.cashDrawerId,
          cashierId: filter.cashierId,
          status: filter.status,
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
