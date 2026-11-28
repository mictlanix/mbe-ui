import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';

part 'to_purchase_filter.freezed.dart';

/// Por comprar's addressable view state (spec 080 research R5). URL keys:
/// `facility`, `page`. The endpoint has no search, so there is no search box.
@freezed
abstract class ToPurchaseFilter with _$ToPurchaseFilter {
  const ToPurchaseFilter._();

  const factory ToPurchaseFilter({int? facilityId, @Default(0) int pageIndex}) =
      _ToPurchaseFilter;

  /// A non-numeric `facility` is ignored.
  factory ToPurchaseFilter.fromQuery(ListQuery query) => ToPurchaseFilter(
    facilityId: int.tryParse(query.facet('facility') ?? ''),
    pageIndex: query.pageIndex,
  );

  /// What the drawer badge counts: the facility, when chosen.
  int get activeFilterCount => facilityId != null ? 1 : 0;
}
