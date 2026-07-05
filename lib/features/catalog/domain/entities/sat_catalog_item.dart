import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'sat_catalog_item.freezed.dart';

/// A SAT catalog entry returned by the list endpoints for both
/// units-of-measurement and product/service keys (data-model.md
/// "SatCatalogItem"). Both list endpoints return `SatCatalogResponse`
/// (id + description); the richer `SatUnitOfMeasurementResponse` (with name
/// and symbol) is only available embedded in a `ProductResponse`.
@freezed
class SatCatalogItem with _$SatCatalogItem {
  const factory SatCatalogItem({
    required String code,
    String? description,
  }) = _SatCatalogItem;

  factory SatCatalogItem.fromResponse(SatCatalogResponse r) => SatCatalogItem(
        code: r.id,
        description: r.description,
      );
}
