import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';

part 'commission_periods_controller.g.dart';

const commissionPeriodsPageSize = 25;

/// The months list's data and its client-side view (spec 078 research R9):
/// every period the server lists, newest first, narrowed by the Estado facet
/// and cut into pages of [commissionPeriodsPageSize]. The endpoint is
/// unpaged and a company has at most a dozen months a year, so filtering and
/// paging here is cheaper than a request per click.
class CommissionPeriodsState {
  const CommissionPeriodsState({
    required this.all,
    this.status,
    this.pageIndex = 0,
  });

  /// Every period, newest first.
  final List<CommissionPeriodSummary> all;

  /// The Estado facet; `null` shows every status.
  final CommissionPeriodStatus? status;

  /// 0-based.
  final int pageIndex;

  List<CommissionPeriodSummary> get filtered => status == null
      ? all
      : [
          for (final period in all)
            if (period.status == status) period,
        ];

  /// The current page of [filtered].
  CatalogPage<CommissionPeriodSummary> get page {
    final rows = filtered;
    final start = pageIndex * commissionPeriodsPageSize;
    return CatalogPage(
      items: start >= rows.length
          ? const []
          : rows.sublist(
              start,
              (start + commissionPeriodsPageSize).clamp(0, rows.length),
            ),
      total: rows.length,
      pageIndex: pageIndex,
      pageSize: commissionPeriodsPageSize,
    );
  }

  CommissionPeriodsState copyWith({
    CommissionPeriodStatus? status,
    bool clearStatus = false,
    int? pageIndex,
  }) => CommissionPeriodsState(
    all: all,
    status: clearStatus ? null : (status ?? this.status),
    pageIndex: pageIndex ?? this.pageIndex,
  );
}

@riverpod
class CommissionPeriodsController extends _$CommissionPeriodsController {
  @override
  Future<CommissionPeriodsState> build() async {
    final periods = await ref.watch(commissionRepositoryProvider).listPeriods();
    return CommissionPeriodsState(
      all: [...periods]..sort((a, b) => b.month.compareTo(a.month)),
    );
  }

  /// Sets the Estado facet (`null` clears it) and returns to the first page.
  void setStatus(CommissionPeriodStatus? status) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        status: status,
        clearStatus: status == null,
        pageIndex: 0,
      ),
    );
  }

  void setPage(int pageIndex) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(pageIndex: pageIndex));
  }
}
