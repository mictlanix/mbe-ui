import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart';
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/pricing/domain/entities/exchange_rate.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/exchange_rate_repository.dart';

final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>((ref) {
  return ExchangeRateRepositoryImpl(ref.watch(dioProvider));
});

/// `ExchangeRateRepository` backed by the generated `mbe_api_client`
/// `ExchangeRatesApi` (contracts/mbe-api-pricing.md §3).
class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  ExchangeRateRepositoryImpl(Dio dio)
    : _api = ExchangeRatesApi(dio, standardSerializers);

  final ExchangeRatesApi _api;

  @override
  Future<ExchangeRateResult> list({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? base,
    int? target,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listExchangeRatesApiV1ExchangeRatesGet(
        dateFrom: dateFrom?.toDate(),
        dateTo: dateTo?.toDate(),
        base_: base,
        target: target,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return ExchangeRateResult(
        items: result.items.map(ExchangeRate.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<ExchangeRate> get({required int exchangeRateId}) async {
    try {
      final response = await _api
          .getExchangeRateApiV1ExchangeRatesExchangeRateIdGet(
            exchangeRateId: exchangeRateId,
          );
      final rate = response.data;
      if (rate == null) throw const AppError.server();
      return ExchangeRate.fromResponse(rate);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<ExchangeRate> create({
    required DateTime date,
    required String rate,
    required int base,
    required int target,
  }) async {
    try {
      final response = await _api.createExchangeRateApiV1ExchangeRatesPost(
        exchangeRateCreate: ExchangeRateCreate((b) {
          b
            ..date = date.toDate()
            ..base_ = base
            ..target = target;
          _setRate(b.rate, rate);
        }),
      );
      final created = response.data;
      if (created == null) throw const AppError.server();
      return ExchangeRate.fromResponse(created);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<ExchangeRate> update({
    required int exchangeRateId,
    DateTime? date,
    String? rate,
    int? base,
    int? target,
  }) async {
    try {
      final response = await _api
          .updateExchangeRateApiV1ExchangeRatesExchangeRateIdPut(
            exchangeRateId: exchangeRateId,
            exchangeRateUpdate: ExchangeRateUpdate((b) {
              if (date != null) b.date = date.toDate();
              if (base != null) b.base_ = base;
              if (target != null) b.target = target;
              // Update-side wrapper is distinct from the create-side one for
              // the same field (research.md §4) — Rate1, not Rate.
              if (rate != null) _setRate1(b.rate, rate);
            }),
          );
      final updated = response.data;
      if (updated == null) throw const AppError.server();
      return ExchangeRate.fromResponse(updated);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required int exchangeRateId}) async {
    try {
      await _api.deleteExchangeRateApiV1ExchangeRatesExchangeRateIdDelete(
        exchangeRateId: exchangeRateId,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}

/// `rate` is `anyOf: [number, string]` in mbe-api's schema; this project
/// always sends the String arm via `AnyOf2<String, num>(values: {0: value})`
/// — String as the *first* type parameter, key `0` (research.md §4 —
/// verified against a live serialization round-trip, not the naive
/// `AnyOf2<num, String>`/key-`1` reading of the wrapper's generated
/// `targetType` order, which throws a `RangeError`).
void _setRate(RateBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setRate1(Rate1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}
