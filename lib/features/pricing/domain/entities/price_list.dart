import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'price_list.freezed.dart';

/// A named selling tier (data-model.md §1), mapped from `PriceListResponse`.
/// Margins are kept as `String` end-to-end (research.md §3) — never parsed
/// to `double`.
@freezed
class PriceList with _$PriceList {
  const factory PriceList({
    required int priceListId,
    required String name,
    required String highProfitMargin,
    required String lowProfitMargin,
  }) = _PriceList;

  factory PriceList.fromResponse(PriceListResponse response) {
    return PriceList(
      priceListId: response.priceListId,
      name: response.name,
      highProfitMargin: response.highProfitMargin,
      lowProfitMargin: response.lowProfitMargin,
    );
  }
}
