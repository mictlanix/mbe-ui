import 'package:built_collection/built_collection.dart';
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
        // `product` repeats since mbe-api#182; one id is a one-element list.
        product: BuiltList<int>([productId]),
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
  Future<List<ProductPrice>> listForProducts({
    required List<int> productIds,
    required List<int> priceListIds,
  }) async {
    if (productIds.isEmpty) return const [];
    try {
      // One request since mbe-api#182 landed — this method shipped as a
      // `Future.wait` fan-out over `listByProduct` precisely so the change
      // would land here and nowhere else (spec 033 research.md §R5).
      final response = await _api.listProductPricesApiV1ProductPricesGet(
        product: BuiltList<int>(productIds),
        limit: kProductPriceBulkLimit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      final priceListIdSet = priceListIds.toSet();
      return result.items
          .map(ProductPrice.fromResponse)
          .where((p) => priceListIdSet.contains(p.priceList.priceListId))
          .toList();
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<ProductPrice> create({
    required int productId,
    required int priceListId,
    required String price,
  }) async {
    try {
      final response = await _api.createProductPriceApiV1ProductPricesPost(
        productPriceCreate: ProductPriceCreate((b) {
          b
            ..product = productId
            ..priceList = priceListId;
          // Price only: since mbe-api#185 the server fills a created row's
          // band from the price list's own margins, and nothing reads it.
          _setPrice(b.price, price);
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
  }) async {
    try {
      final response = await _api
          .updateProductPriceApiV1ProductPricesProductPriceIdPut(
            productPriceId: productPriceId,
            productPriceUpdate: ProductPriceUpdate((b) {
              // `price` keeps its own update-side wrapper (`Price1`); an
              // omitted profit band leaves the stored one alone (mbe-api#185).
              _setPrice1(b.price, price);
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
  Future<List<ProductPrice>> applyPriceChanges(
    List<PriceCellWrite> writes,
  ) async {
    if (writes.isEmpty) return const [];
    try {
      final response = await _api
          .bulkUpsertProductPricesApiV1ProductPricesPut(
            productPriceBulkItem: BuiltList<ProductPriceBulkItem>(
              writes.map(
                (w) => ProductPriceBulkItem((b) {
                  b
                    ..product = w.productId
                    ..priceList = w.priceListId;
                  _setPrice(b.price, w.price);
                  // No profit band: defaulted from the price list on a created
                  // row, left alone on an updated one (mbe-api#185).
                }),
              ),
            ),
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return result.map(ProductPrice.fromResponse).toList();
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}

/// `price` is `anyOf: [number, string]` in mbe-api's schema; this project
/// always sends the String arm via
/// `AnyOf2<String, num>(values: {0: value})` — String as the *first* type
/// parameter, key `0` (research.md §4 — corrected after the codebase's
/// first `AnyOf` construction attempt, in US1's price-list margins, threw a
/// `RangeError` with the naive `AnyOf2<num, String>`/key-`1` reading of the
/// wrapper's generated `targetType` order). Create and Update DTOs use
/// separately-generated wrapper classes for `price` (`Price` against
/// `Price1`), hence the two near-identical helpers below rather than one
/// shared one. The deprecated profit pair's helpers went with spec 033 US7 —
/// nothing sends those fields any more.
void _setPrice(PriceBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}


void _setPrice1(Price1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}
