import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/features/catalog/domain/entities/sat_catalog_item.dart';

part 'taxpayer_issuer.freezed.dart';

/// A legal entity authorized to issue the organization's invoices — full
/// detail entity for the Taxpayer Issuers catalog's list and detail screens
/// (data-model.md §2), mapped from `TaxpayerIssuerResponse`. [rfc]
/// (`taxpayerIssuerId` on the wire) is the issuer's identity: client-supplied
/// on create, **immutable** thereafter (spec 015 Clarifications).
///
/// Distinct from the lightweight `TaxpayerIssuerListItem`, which remains the
/// picker projection spec 014's facility-form autocomplete consumes
/// (research §13) — this is the catalog's own row/detail shape.
@freezed
class TaxpayerIssuer with _$TaxpayerIssuer {
  const factory TaxpayerIssuer({
    required String rfc,
    required String name,
    SatCatalogItem? regime,
    required FiscalCertificationProvider provider,
    SatCatalogItem? postalCode,
    String? comment,
  }) = _TaxpayerIssuer;

  factory TaxpayerIssuer.fromResponse(TaxpayerIssuerResponse r) =>
      TaxpayerIssuer(
        rfc: r.taxpayerIssuerId,
        // `name` is nullable on the wire; this feature's form always
        // requires it before allowing a save, so a record saved another way
        // with no name falls back to empty rather than surfacing null
        // (Taxpayer Recipient precedent, research §4).
        name: r.name ?? '',
        regime: r.regime == null ? null : SatCatalogItem.fromResponse(r.regime!),
        provider: r.provider,
        postalCode: r.postalCode == null
            ? null
            : SatCatalogItem.fromResponse(r.postalCode!),
        comment: r.comment,
      );
}
