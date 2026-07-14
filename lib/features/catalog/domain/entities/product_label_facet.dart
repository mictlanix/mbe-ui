import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

part 'product_label_facet.freezed.dart';

/// One row of the products-list label facet lookup (spec 009 data-model.md
/// "ProductLabelFacet"): a label present on at least one product matching the
/// current filter, with the count of matching products that carry it. Drives
/// the filter drawer's enable/disable of label chips — a label absent from the
/// facet response is unavailable and its chip is disabled.
///
/// Mapped from the generated `api.ProductLabelFacet` DTO (aliased to avoid the
/// name collision with this domain entity, mirroring how `ProductListItem`
/// hides the generated type in the data layer).
@freezed
class ProductLabelFacet with _$ProductLabelFacet {
  const factory ProductLabelFacet({
    required int labelId,
    required int count,
  }) = _ProductLabelFacet;

  factory ProductLabelFacet.fromResponse(api.ProductLabelFacet r) =>
      ProductLabelFacet(labelId: r.labelId, count: r.count);
}
