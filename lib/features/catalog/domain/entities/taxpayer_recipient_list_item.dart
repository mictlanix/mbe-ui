import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as mbe_api;

part 'taxpayer_recipient_list_item.freezed.dart';

/// A taxpayer recipient search-result row for the Taxpayer Recipients
/// catalog list (data-model.md §5).
@freezed
class TaxpayerRecipientListItem with _$TaxpayerRecipientListItem {
  const factory TaxpayerRecipientListItem({
    required String taxpayerRecipientId,
    required String name,
    required String email,
  }) = _TaxpayerRecipientListItem;

  factory TaxpayerRecipientListItem.fromResponse(
    mbe_api.TaxpayerRecipientResponse r,
  ) => TaxpayerRecipientListItem(
    taxpayerRecipientId: r.taxpayerRecipientId,
    name: r.name ?? '',
    email: r.email,
  );
}
