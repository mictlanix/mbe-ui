import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/features/catalog/domain/entities/sat_catalog_item.dart';

part 'taxpayer_recipient.freezed.dart';

/// A fiscal/invoicing recipient record — full detail entity for the
/// Taxpayer Recipients catalog (data-model.md §5), mapped from
/// `TaxpayerRecipientResponse`. `taxpayerRecipientId` is a client-supplied,
/// immutable String primary key (research.md §9) — never editable after
/// create. `postalCode`/`regime` are expanded on read as `SatCatalogResponse`
/// (code + description); reused directly as `SatCatalogItem` rather than a
/// separate value type, since the shape is identical (data-model.md §5).
@freezed
class TaxpayerRecipient with _$TaxpayerRecipient {
  const factory TaxpayerRecipient({
    required String taxpayerRecipientId,
    required String name,
    required String email,
    SatCatalogItem? postalCode,
    SatCatalogItem? regime,
  }) = _TaxpayerRecipient;

  factory TaxpayerRecipient.fromResponse(TaxpayerRecipientResponse response) {
    return TaxpayerRecipient(
      taxpayerRecipientId: response.taxpayerRecipientId,
      // `name` is nullable on the wire; this feature's form always requires
      // it before allowing a save, so a record saved another way with no
      // name falls back to empty rather than surfacing null (research.md §9
      // follow-on note).
      name: response.name ?? '',
      email: response.email,
      postalCode: response.postalCode == null
          ? null
          : SatCatalogItem.fromResponse(response.postalCode!),
      regime: response.regime == null
          ? null
          : SatCatalogItem.fromResponse(response.regime!),
    );
  }
}
