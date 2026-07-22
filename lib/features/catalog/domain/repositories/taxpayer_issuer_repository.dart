import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_issuer_list_item.dart';

/// Taxpayer issuer lookup — deliberately **not** full CRUD (data-model.md
/// "TaxpayerIssuerListItem", contracts/mbe-api-catalogs.md §Taxpayer
/// Issuers). [list] backs the facility form's taxpayer autocomplete
/// (FR-034); [get] resolves a loaded facility's stored RFC to a display
/// name (FR-034b). Issuer creation is intentionally not exposed here
/// (FR-034a) — a dedicated Taxpayer Issuers catalog is a follow-up feature.
abstract class TaxpayerIssuerRepository {
  Future<TaxpayerIssuerListResult> list({
    String? search,
    int skip = 0,
    int limit = 20,
  });

  /// Returns `null` if the RFC cannot be resolved (e.g. deleted since the
  /// facility was saved) — callers fall back to displaying the bare RFC
  /// rather than failing the screen (FR-034b).
  Future<TaxpayerIssuerListItem?> get(String rfc);
}

class TaxpayerIssuerListResult {
  const TaxpayerIssuerListResult({required this.items, required this.total});
  final List<TaxpayerIssuerListItem> items;
  final int total;
}
