import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';

part 'payment_method_options_list_controller.freezed.dart';
part 'payment_method_options_list_controller.g.dart';

const _pageSize = 20;

/// The Payment Method Options list screen's search/filter selection
/// (FR-002, FR-031): a facility facet and a status facet, independent of
/// search. The generated list endpoint has no `search` param yet — [search]
/// is carried anyway so the box is wired ahead of the upstream capability
/// (research §15) and needs no call-site change once it ships.
@freezed
class PaymentMethodOptionFilter with _$PaymentMethodOptionFilter {
  const factory PaymentMethodOptionFilter({
    @Default('') String search,
    int? facilityId,
    @Default('') String facilityDisplayText,
    EntityStatus? status,
  }) = _PaymentMethodOptionFilter;
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

/// Holds the current search/filter selection for the Payment Method Options
/// list (FR-002, FR-031).
@riverpod
class PaymentMethodOptionFilterController
    extends _$PaymentMethodOptionFilterController {
  @override
  PaymentMethodOptionFilter build() => const PaymentMethodOptionFilter();

  void searchChanged(String value) => state = state.copyWith(search: value);

  void facilitySelected(int facilityId, String facilityName) => state = state
      .copyWith(facilityId: facilityId, facilityDisplayText: facilityName);

  void statusChanged(EntityStatus? value) =>
      state = state.copyWith(status: value);

  /// Resets every facet filter to its default while preserving the current
  /// search text (the search box stays outside the filter sheet).
  void reset() => state = PaymentMethodOptionFilter(search: state.search);
}

/// Fetches and holds the Payment Method Options list (FR-001, FR-002),
/// re-fetching page 0 whenever [PaymentMethodOptionFilterController]'s state
/// changes.
@riverpod
class PaymentMethodOptionsListController
    extends _$PaymentMethodOptionsListController {
  @override
  Future<CatalogPage<PaymentMethodOption>> build() {
    final filter = ref.watch(paymentMethodOptionFilterControllerProvider);
    return _fetch(filter, pageIndex: 0);
  }

  Future<CatalogPage<PaymentMethodOption>> _fetch(
    PaymentMethodOptionFilter filter, {
    required int pageIndex,
  }) async {
    final result = await ref
        .read(paymentMethodOptionRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          facilityId: filter.facilityId,
          status: filter.status,
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
    final filter = ref.read(paymentMethodOptionFilterControllerProvider);
    state =
        const AsyncLoading<CatalogPage<PaymentMethodOption>>()
            .copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(filter, pageIndex: pageIndex));
  }
}
