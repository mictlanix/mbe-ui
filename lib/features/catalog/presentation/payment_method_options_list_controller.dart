import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';

part 'payment_method_options_list_controller.freezed.dart';
part 'payment_method_options_list_controller.g.dart';

const _pageSize = 20;

/// The Payment Method Options list screen's addressable view state
/// (017-ui-consistency-filters FR-017, FR-031): a facility facet and a
/// status facet, independent of search. The generated list endpoint has no
/// `search` param yet — [search] is carried anyway so the box is wired
/// ahead of the upstream capability (research §15) and needs no call-site
/// change once it ships. Derived from the route's [ListQuery] — the URL,
/// not a mutable notifier, is the source of truth.
@freezed
class PaymentMethodOptionFilter with _$PaymentMethodOptionFilter {
  const factory PaymentMethodOptionFilter({
    @Default('') String search,
    int? facilityId,
    EntityStatus? status,
    @Default(0) int pageIndex,
  }) = _PaymentMethodOptionFilter;

  factory PaymentMethodOptionFilter.fromQuery(ListQuery query) {
    final facilityRaw = query.facet('facility');
    return PaymentMethodOptionFilter(
      search: query.search,
      facilityId: facilityRaw != null ? int.tryParse(facilityRaw) : null,
      status: decodeStatusFacet(query),
      pageIndex: query.pageIndex,
    );
  }
}

/// Derived facet-filter summary for the Payment Method Options list's
/// Filters button badge (mirrors `WarehouseFilterBadge`). [search] has its
/// own always-visible box and is excluded.
extension PaymentMethodOptionFilterBadge on PaymentMethodOptionFilter {
  int get activeFilterCount {
    var count = 0;
    if (facilityId != null) count++;
    if (status != null) count++;
    return count;
  }

  bool get hasActiveFilters => activeFilterCount > 0;
}

/// Fetches and holds the Payment Method Options list (FR-001, FR-002) for
/// the given [PaymentMethodOptionFilter]. A family keyed by the filter
/// value: a different URL is a different provider instance, and
/// `ref.invalidate` after a mutation re-fetches the *same* page rather than
/// resetting to page 0 (FR-025, research §3).
@riverpod
class PaymentMethodOptionsListController
    extends _$PaymentMethodOptionsListController {
  @override
  Future<CatalogPage<PaymentMethodOption>> build(
    PaymentMethodOptionFilter filter,
  ) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter.copyWith(pageIndex: pageIndex)),
    );
  }

  Future<CatalogPage<PaymentMethodOption>> _fetch(
    PaymentMethodOptionFilter filter,
  ) async {
    final result = await ref
        .read(paymentMethodOptionRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          facilityId: filter.facilityId,
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
