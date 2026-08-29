import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_cell_key.freezed.dart';

/// One coordinate in the pricing grid — a product's price on one price list
/// (data-model.md §3). Freezed value equality makes it a legal `Map` key,
/// which is how every per-cell tracking structure in
/// `PricingGridState` (in-flight writes, rejected edits, baseline values) is
/// keyed.
@freezed
class PriceCellKey with _$PriceCellKey {
  const factory PriceCellKey({
    required int productId,
    required int priceListId,
  }) = _PriceCellKey;
}
