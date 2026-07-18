import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart';
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/product_price_repository.dart';

final productPriceRepositoryProvider = Provider<ProductPriceRepository>((ref) {
  return ProductPriceRepositoryImpl(ref.watch(dioProvider));
});

/// `ProductPriceRepository` backed by the generated `mbe_api_client`
/// `ProductPricesApi` (contracts/mbe-api-pricing.md §2).
class ProductPriceRepositoryImpl implements ProductPriceRepository {
  ProductPriceRepositoryImpl(Dio dio)
    : _api = ProductPricesApi(dio, standardSerializers);

  final ProductPricesApi _api;

  @override
  Future<List<ProductPrice>> listByProduct({
    required int productId,
    required int limit,
  }) async {
    try {
      final response = await _api.listProductPricesApiV1ProductPricesGet(
        product: productId,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return result.items.map(ProductPrice.fromResponse).toList();
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<ProductPrice> create({
    required int productId,
    required int priceListId,
    required String price,
    required String lowProfit,
    required String highProfit,
  }) async {
    try {
      final response = await _api.createProductPriceApiV1ProductPricesPost(
        productPriceCreate: ProductPriceCreate((b) {
          b
            ..product = productId
            ..priceList = priceListId;
          _setPrice(b.price, price);
          _setLowProfit(b.lowProfit, lowProfit);
          _setHighProfit(b.highProfit, highProfit);
        }),
      );
      final productPrice = response.data;
      if (productPrice == null) throw const AppError.server();
      return ProductPrice.fromResponse(productPrice);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<ProductPrice> update({
    required int productPriceId,
    required String price,
    required String lowProfit,
    required String highProfit,
  }) async {
    try {
      final response = await _api
          .updateProductPriceApiV1ProductPricesProductPriceIdPut(
            productPriceId: productPriceId,
            productPriceUpdate: ProductPriceUpdate((b) {
              // Update-side wrapper classes are distinct from create-side ones
              // for the same field (research.md §4) — Price1/LowProfit1/
              // HighProfit1, not Price/LowProfit/HighProfit.
              _setPrice1(b.price, price);
              _setLowProfit1(b.lowProfit, lowProfit);
              _setHighProfit1(b.highProfit, highProfit);
            }),
          );
      final productPrice = response.data;
      if (productPrice == null) throw const AppError.server();
      return ProductPrice.fromResponse(productPrice);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}

/// `price`/`low_profit`/`high_profit` are each `anyOf: [number, string]` in
/// mbe-api's schema; this project always sends the String arm via
/// `AnyOf2<String, num>(values: {0: value})` — String as the *first* type
/// parameter, key `0` (research.md §4 — corrected after the codebase's
/// first `AnyOf` construction attempt, in US1's price-list margins, threw a
/// `RangeError` with the naive `AnyOf2<num, String>`/key-`1` reading of the
/// wrapper's generated `targetType` order). Create and Update DTOs use
/// separately-generated wrapper classes for the same field, hence the six
/// near-identical helpers below rather than one shared one.
void _setPrice(PriceBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setLowProfit(LowProfitBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setHighProfit(HighProfitBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setPrice1(Price1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setLowProfit1(LowProfit1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setHighProfit1(HighProfit1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}
