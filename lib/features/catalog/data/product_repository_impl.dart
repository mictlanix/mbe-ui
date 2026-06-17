import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide ProductListItem;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(dioProvider));
});

/// `ProductRepository` backed by the generated `mbe_api_client` `ProductsApi`
/// (contracts/mbe-api-products.md).
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(Dio dio) : _api = ProductsApi(dio, standardSerializers);

  final ProductsApi _api;

  @override
  Future<ProductListResult> list({
    String? search,
    bool? deactivated,
    bool? stockable,
    bool? salable,
    bool? purchasable,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listProductsApiV1ProductsGet(
        search: search,
        deactivated: deactivated,
        stockable: stockable,
        salable: salable,
        purchasable: purchasable,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return ProductListResult(
        items: result.items.map(ProductListItem.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Product> get({required int productId}) async {
    try {
      final response = await _api.getProductApiV1ProductsProductIdGet(
        productId: productId,
      );
      final product = response.data;
      if (product == null) throw const AppError.server();
      return Product.fromResponse(product);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
