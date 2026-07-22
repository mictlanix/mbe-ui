import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'taxpayer_issuer_list_item.freezed.dart';

/// A lightweight taxpayer-issuer projection used by the facility form's
/// taxpayer `CatalogEntityPicker` (data-model.md "TaxpayerIssuerListItem",
/// FR-034). [rfc] (`TaxpayerIssuerResponse.taxpayerIssuerId`) is what the
/// facility stores; [name] is nullable since not every registered issuer
/// has one on record — the picker/detail display falls back to [rfc]
/// (FR-034b).
@freezed
class TaxpayerIssuerListItem with _$TaxpayerIssuerListItem {
  const factory TaxpayerIssuerListItem({
    required String rfc,
    String? name,
  }) = _TaxpayerIssuerListItem;

  factory TaxpayerIssuerListItem.fromResponse(TaxpayerIssuerResponse r) =>
      TaxpayerIssuerListItem(rfc: r.taxpayerIssuerId, name: r.name);
}

/// The display text for a [TaxpayerIssuerListItem] — the issuer's name where
/// it has one, falling back to its RFC (FR-034b).
extension TaxpayerIssuerDisplay on TaxpayerIssuerListItem {
  String get displayText => (name == null || name!.isEmpty) ? rfc : name!;
}
