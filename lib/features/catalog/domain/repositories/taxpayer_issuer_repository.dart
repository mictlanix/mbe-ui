import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_issuer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_issuer_list_item.dart';

/// Taxpayer issuer lookup **and full CRUD catalog management** (data-model.md
/// §2, contracts/mbe-api-catalogs.md §2, spec 015 US2). Originally
/// list-only (spec 014's facility-form autocomplete); **extended
/// additively** for spec 015's Taxpayer Issuers catalog (research §13) —
/// [list] and the lightweight [get] are unchanged and keep serving that
/// autocomplete; [getDetail]/[create]/[update]/[delete] are new.
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

  /// The catalog's full-detail lookup, for the Taxpayer Issuers detail
  /// screen (FR-010, FR-015). Distinct from [get] (the lightweight picker
  /// lookup) so the two consumers stay decoupled.
  Future<TaxpayerIssuer> getDetail(String rfc);

  /// Registers a new issuer. [rfc] is the client-supplied identity, entered
  /// on create and immutable thereafter (FR-012).
  Future<TaxpayerIssuer> create({
    required String rfc,
    String? name,
    required String regime,
    FiscalCertificationProvider? provider,
    String? postalCode,
    String? comment,
  });

  /// Edits an existing issuer's mutable fields (FR-015). The RFC is never
  /// part of the request body — it is the path parameter, not a field to
  /// update (FR-012).
  Future<TaxpayerIssuer> update({
    required String rfc,
    String? name,
    String? regime,
    FiscalCertificationProvider? provider,
    String? postalCode,
    String? comment,
  });

  Future<void> delete(String rfc);
}

class TaxpayerIssuerListResult {
  const TaxpayerIssuerListResult({required this.items, required this.total});
  final List<TaxpayerIssuerListItem> items;
  final int total;
}
