import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/domain/entities/pending_delivery.dart';

part 'pending_deliveries_filter.freezed.dart';

/// The "Por entregar" route (spec 063 C1). Sits under `/sales/` like its
/// siblings `/sales/delivery-orders` and `/sales/delivery-order-approval`.
const forDeliveryPath = '/sales/for-delivery';

/// The "Por entregar" screen's addressable view state (spec 063 data-model
/// §4, research R3): the period and the page, both in the URL so Back from an
/// order returns to the same view.
///
/// The period is the one facet that always has a value. Hoy is the default
/// and is left out of the URL, so the bare route is the default view.
@freezed
abstract class PendingDeliveriesFilter with _$PendingDeliveriesFilter {
  const PendingDeliveriesFilter._();

  const factory PendingDeliveriesFilter({
    @Default(PendingDeliveryPeriod.today) PendingDeliveryPeriod period,
    @Default(0) int pageIndex,
  }) = _PendingDeliveriesFilter;

  /// A missing or unknown `period` is Hoy.
  factory PendingDeliveriesFilter.fromQuery(ListQuery query) =>
      PendingDeliveriesFilter(
        period: PendingDeliveryPeriod.fromKey(query.facet('period')),
        pageIndex: query.pageIndex,
      );

  /// This filter as a URL query.
  ListQuery toQuery() => ListQuery(pageIndex: pageIndex).withFacet(
    'period',
    period == PendingDeliveryPeriod.today ? null : period.key,
  );

  /// What the drawer badge counts: 1 when the period isn't the default.
  int get activeFilterCount => period == PendingDeliveryPeriod.today ? 0 : 1;

  bool get isNarrowed => activeFilterCount > 0;

  /// "Borrar todo": back to Hoy, first page.
  PendingDeliveriesFilter cleared() => const PendingDeliveriesFilter();
}
