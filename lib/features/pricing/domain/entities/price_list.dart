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
      // Deprecated on the wire since mbe-api#185 — still mapped because the
      // price-list form still edits them, until spec 033 US7 removes that.
      // Reading a field that is deprecated *for callers* is exactly what
      // this mapping is for, so the lint is silenced rather than obeyed.
      // ignore: deprecated_member_use
      highProfitMargin: response.highProfitMargin,
      // ignore: deprecated_member_use
      lowProfitMargin: response.lowProfitMargin,
    );
  }
}
