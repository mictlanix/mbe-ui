import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart';
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';

final priceListRepositoryProvider = Provider<PriceListRepository>((ref) {
  return PriceListRepositoryImpl(ref.watch(dioProvider));
});

/// `PriceListRepository` backed by the generated `mbe_api_client`
/// `PriceListsApi` (contracts/mbe-api-pricing.md §1).
class PriceListRepositoryImpl implements PriceListRepository {
  PriceListRepositoryImpl(Dio dio)
    : _api = PriceListsApi(dio, standardSerializers);

  final PriceListsApi _api;

  @override
  Future<PriceListResult> list({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listPriceListsApiV1PriceListsGet(
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return PriceListResult(
        items: result.items.map(PriceList.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PriceList> get({required int priceListId}) async {
    try {
      final response = await _api.getPriceListApiV1PriceListsPriceListIdGet(
        priceListId: priceListId,
      );
      final priceList = response.data;
      if (priceList == null) throw const AppError.server();
      return PriceList.fromResponse(priceList);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PriceList> create({
    required String name,
    String? highProfitMargin,
    String? lowProfitMargin,
  }) async {
    try {
      final response = await _api.createPriceListApiV1PriceListsPost(
        priceListCreate: PriceListCreate((b) {
          b.name = name;
          if (highProfitMargin != null) {
            _setHighProfitMargin(b.highProfitMargin, highProfitMargin);
          }
          if (lowProfitMargin != null) {
            _setLowProfitMargin(b.lowProfitMargin, lowProfitMargin);
          }
        }),
      );
      final priceList = response.data;
      if (priceList == null) throw const AppError.server();
      return PriceList.fromResponse(priceList);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PriceList> update({
    required int priceListId,
    String? name,
    String? highProfitMargin,
    String? lowProfitMargin,
  }) async {
    try {
      final response = await _api.updatePriceListApiV1PriceListsPriceListIdPut(
        priceListId: priceListId,
        priceListUpdate: PriceListUpdate((b) {
          if (name != null) b.name = name;
          // Update-side wrapper classes are distinct from create-side ones
          // for the same field (research.md §4) — HighProfitMargin1/
          // LowProfitMargin1, not HighProfitMargin/LowProfitMargin.
          if (highProfitMargin != null) {
            _setHighProfitMargin1(b.highProfitMargin, highProfitMargin);
          }
          if (lowProfitMargin != null) {
            _setLowProfitMargin1(b.lowProfitMargin, lowProfitMargin);
          }
        }),
      );
      final priceList = response.data;
      if (priceList == null) throw const AppError.server();
      return PriceList.fromResponse(priceList);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required int priceListId}) async {
    try {
      await _api.deletePriceListApiV1PriceListsPriceListIdDelete(
        priceListId: priceListId,
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

/// `high_profit_margin`/`low_profit_margin` are each `anyOf: [number,
/// string]` in mbe-api's schema; this project always sends the String arm.
/// **`AnyOf2<String, num>(values: {0: value})`** — String as the *first*
/// type parameter, key `0` — mirroring the existing `_setTaxRate` precedent
/// in `product_repository_impl.dart` exactly. This is NOT the naive reading
/// of the wrapper's generated `targetType` order (`[num, String]`, which
/// governs *deserialization* only): `AnyOfSerializer.serialize` re-indexes
/// into `object.values` using the *set* of populated value keys, not the
/// full declared type list, so `{1: value}` throws a `RangeError` and
/// `AnyOf2<num, String>(values: {0: value})` throws a type-mismatch in
/// `NumSerializer`. Verified against a live serialization round-trip before
/// landing (research.md §4 — corrected after the codebase's first
/// `AnyOf` construction attempt failed both plausible-looking forms).
/// Create and Update DTOs use separately-generated wrapper classes for the
/// same field, hence the four near-identical helpers below rather than one
/// shared one.
void _setHighProfitMargin(HighProfitMarginBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setLowProfitMargin(LowProfitMarginBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setHighProfitMargin1(HighProfitMargin1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setLowProfitMargin1(LowProfitMargin1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}
