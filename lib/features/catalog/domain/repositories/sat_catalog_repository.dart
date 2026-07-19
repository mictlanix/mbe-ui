import 'package:mbe_ui/features/catalog/domain/entities/sat_catalog_item.dart';

/// Read-only SAT catalog lookup for units-of-measurement and product/service
/// key pickers on the product form (data-model.md "SatCatalogRepository",
/// contracts/mbe-api-master-data-pickers.md). Both endpoints return
/// `SatCatalogResponse` (code + description), represented as [SatCatalogItem].
abstract class SatCatalogRepository {
  Future<SatCatalogListResult> listUnitsOfMeasurement({
    String? search,
    int skip = 0,
    int limit = 20,
  });

  Future<SatCatalogListResult> listProductServices({
    String? search,
    int skip = 0,
    int limit = 20,
  });

  /// Backs the Taxpayer Recipient form's postal-code picker (spec 012 FR-025,
  /// research.md §5). Mirrors [listUnitsOfMeasurement]/[listProductServices]
  /// exactly — same `SatCatalogResponse` shape, no upstream gap.
  Future<SatCatalogListResult> listPostalCodes({
    String? search,
    int skip = 0,
    int limit = 20,
  });

  /// Backs the Taxpayer Recipient form's tax-regime picker (spec 012 FR-025).
  Future<SatCatalogListResult> listTaxRegimes({
    String? search,
    int skip = 0,
    int limit = 20,
  });
}

class SatCatalogListResult {
  const SatCatalogListResult({required this.items, required this.total});
  final List<SatCatalogItem> items;
  final int total;
}
