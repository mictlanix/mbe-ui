import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide ProductListItem;
import 'package:one_of/any_of.dart';

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
  ProductRepositoryImpl(Dio dio)
      : _dio = dio,
        _api = ProductsApi(dio, standardSerializers);

  final Dio _dio;
  final ProductsApi _api;

  @override
  Future<ProductListResult> list({
    String? search,
    bool? deactivated,
    bool? stockable,
    bool? salable,
    bool? purchasable,
    List<int> labels = const [],
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
        label: labels.isEmpty ? null : BuiltList<int>(labels),
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

  @override
  Future<void> delete({required int productId}) async {
    try {
      await _api.deleteProductApiV1ProductsProductIdDelete(
        productId: productId,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Product> create({
    required String code,
    required String name,
    required String unitOfMeasurement,
    String? sku,
    String? brand,
    String? model,
    String? barCode,
    String? location,
    String? taxRate,
    String? comment,
    bool stockable = false,
    bool perishable = false,
    bool seriable = false,
    bool purchasable = false,
    bool salable = false,
    bool invoiceable = false,
    int? supplier,
    String? key,
    List<int> labels = const [],
  }) async {
    try {
      final response = await _api.createProductApiV1ProductsPost(
        productCreate: ProductCreate((b) {
          b
            ..code = code
            ..name = name
            ..unitOfMeasurement = unitOfMeasurement
            ..sku = sku
            ..brand = brand
            ..model = model
            ..barCode = barCode
            ..location = location
            ..comment = comment
            ..stockable = stockable
            ..perishable = perishable
            ..seriable = seriable
            ..purchasable = purchasable
            ..salable = salable
            ..invoiceable = invoiceable
            ..supplier = supplier
            ..key = key;
          if (taxRate != null) _setTaxRate(b.taxRate, taxRate);
          b.labels.replace(labels);
        }),
      );
      final product = response.data;
      if (product == null) throw const AppError.server();
      return Product.fromResponse(product);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Product> update({
    required int productId,
    String? code,
    String? name,
    String? unitOfMeasurement,
    String? sku,
    String? brand,
    String? model,
    String? barCode,
    String? location,
    String? taxRate,
    String? comment,
    bool? stockable,
    bool? perishable,
    bool? seriable,
    bool? purchasable,
    bool? salable,
    bool? invoiceable,
    bool? deactivated,
    int? supplier,
    String? key,
    List<int>? labels,
  }) async {
    try {
      final response = await _api.updateProductApiV1ProductsProductIdPut(
        productId: productId,
        productUpdate: ProductUpdate((b) {
          if (code != null) b.code = code;
          if (name != null) b.name = name;
          if (unitOfMeasurement != null) b.unitOfMeasurement = unitOfMeasurement;
          if (sku != null) b.sku = sku;
          if (brand != null) b.brand = brand;
          if (model != null) b.model = model;
          if (barCode != null) b.barCode = barCode;
          if (location != null) b.location = location;
          if (comment != null) b.comment = comment;
          if (stockable != null) b.stockable = stockable;
          if (perishable != null) b.perishable = perishable;
          if (seriable != null) b.seriable = seriable;
          if (purchasable != null) b.purchasable = purchasable;
          if (salable != null) b.salable = salable;
          if (invoiceable != null) b.invoiceable = invoiceable;
          if (deactivated != null) b.deactivated = deactivated;
          if (supplier != null) b.supplier = supplier;
          if (key != null) b.key = key;
          if (taxRate != null) _setTaxRate(b.taxRate, taxRate);
          if (labels != null) b.labels.replace(labels);
        }),
      );
      final product = response.data;
      if (product == null) throw const AppError.server();
      return Product.fromResponse(product);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Product> uploadPhoto({
    required int productId,
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      final response = await _dio.post<Object>(
        '/api/v1/products/$productId/image',
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(bytes, filename: filename),
        }),
      );
      return Product.fromResponse(_deserializeProductResponse(response));
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Product> removePhoto({required int productId}) async {
    try {
      final response = await _dio.put<Object>(
        '/api/v1/products/$productId',
        data: {'photo': null},
      );
      return Product.fromResponse(_deserializeProductResponse(response));
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> mergeProducts({
    required int productId,
    required int duplicateId,
  }) async {
    try {
      await _api.mergeProductsApiV1ProductsMergePost(
        productMergeRequest: ProductMergeRequest((b) => b
          ..productId = productId
          ..duplicateId = duplicateId),
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

/// Mirrors the generated client's own response-deserialization pattern
/// (`products_api.dart`'s `getProductApiV1ProductsProductIdGet`, etc.) for
/// the two raw `dio` calls above, since they bypass the generated wrapper
/// methods (research.md §3) but still want a `ProductResponse` back.
ProductResponse _deserializeProductResponse(Response<Object?> response) {
  final raw = response.data;
  if (raw == null) throw const AppError.server();
  return standardSerializers.deserialize(
    raw,
    specifiedType: const FullType(ProductResponse),
  ) as ProductResponse;
}

/// `tax_rate` is `anyOf: [string, number]` in mbe-api's OpenAPI schema
/// (Pydantic `Decimal | None`); this project always sends it as a string.
void _setTaxRate(TaxRateBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
