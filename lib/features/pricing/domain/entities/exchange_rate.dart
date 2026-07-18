import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/domain/currency.dart';

part 'exchange_rate.freezed.dart';

/// A dated currency conversion (data-model.md §4), mapped from
/// `ExchangeRateResponse`. [rate] is kept as `String` end-to-end
/// (research.md §3). [base]/[target] fall back to `null` for a code the
/// mapper doesn't recognize (data-model.md §4) — `rawBase`/`rawTarget`
/// preserve the original `int` for display in that case.
@freezed
class ExchangeRate with _$ExchangeRate {
  const factory ExchangeRate({
    required int exchangeRateId,
    required DateTime date,
    required String rate,
    required int rawBase,
    required int rawTarget,
    Currency? base,
    Currency? target,
  }) = _ExchangeRate;

  factory ExchangeRate.fromResponse(ExchangeRateResponse response) {
    return ExchangeRate(
      exchangeRateId: response.exchangeRateId,
      date: response.date.toDateTime(),
      rate: response.rate,
      rawBase: response.base_,
      rawTarget: response.target,
      base: Currency.fromValue(response.base_),
      target: Currency.fromValue(response.target),
    );
  }
}
