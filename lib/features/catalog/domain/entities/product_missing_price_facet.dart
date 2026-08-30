import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

part 'product_missing_price_facet.freezed.dart';

/// One row of the pricing grid's worklist lookup (spec 033 US2, mbe-api#184):
/// a price list, and how many products in the current filter set still have
/// **no** price on it. Drives the grid's "Missing «list» (count)" chips.
///
/// The counterpart of [ProductLabelFacet] — same product set, different
/// question, read into a different chip row. Mapped from the generated
/// `api.ProductMissingPriceFacet` (aliased for the same reason
/// `ProductLabelFacet` aliases its DTO).
///
/// ⚠️ [priceListId] of `0` is real — `Costo` in the deployment — so every
/// check on it must test for absence, never for falsiness (spec FR-019a).
@freezed
class ProductMissingPriceFacet with _$ProductMissingPriceFacet {
  const factory ProductMissingPriceFacet({
    required int priceListId,
    required int missingCount,
  }) = _ProductMissingPriceFacet;

  factory ProductMissingPriceFacet.fromResponse(
    api.ProductMissingPriceFacet r,
  ) => ProductMissingPriceFacet(
    priceListId: r.priceList,
    missingCount: r.missingCount,
  );
}
