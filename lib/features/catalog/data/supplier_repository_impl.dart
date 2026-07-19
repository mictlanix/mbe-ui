import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart';
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepositoryImpl(ref.watch(dioProvider));
});

class SupplierRepositoryImpl implements SupplierRepository {
  SupplierRepositoryImpl(Dio dio)
    : _api = SuppliersApi(dio, standardSerializers);

  final SuppliersApi _api;

  @override
  Future<SupplierListResult> list({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listSuppliersApiV1SuppliersGet(
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return SupplierListResult(
        items: result.items.map(SupplierListItem.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<SupplierPage> listDetailed({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listSuppliersApiV1SuppliersGet(
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return SupplierPage(
        items: result.items.map(Supplier.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Supplier> get({required int supplierId}) async {
    try {
      final response = await _api.getSupplierApiV1SuppliersSupplierIdGet(
        supplierId: supplierId,
      );
      final supplier = response.data;
      if (supplier == null) throw const AppError.server();
      return Supplier.fromResponse(supplier);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Supplier> create({
    required String code,
    required String name,
    String? zone,
    String? creditLimit,
    int? creditDays,
    String? comment,
  }) async {
    try {
      final response = await _api.createSupplierApiV1SuppliersPost(
        supplierCreate: SupplierCreate((b) {
          b
            ..code = code
            ..name = name
            ..zone = zone
            ..creditDays = creditDays
            ..comment = comment;
          if (creditLimit != null) _setCreditLimit(b.creditLimit, creditLimit);
        }),
      );
      final supplier = response.data;
      if (supplier == null) throw const AppError.server();
      return Supplier.fromResponse(supplier);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Supplier> update({
    required int supplierId,
    String? code,
    String? name,
    String? zone,
    String? creditLimit,
    int? creditDays,
    String? comment,
  }) async {
    try {
      final response = await _api.updateSupplierApiV1SuppliersSupplierIdPut(
        supplierId: supplierId,
        supplierUpdate: SupplierUpdate((b) {
          if (code != null) b.code = code;
          if (name != null) b.name = name;
          if (zone != null) b.zone = zone;
          if (creditDays != null) b.creditDays = creditDays;
          if (comment != null) b.comment = comment;
          if (creditLimit != null) {
            _setCreditLimit1(b.creditLimit, creditLimit);
          }
        }),
      );
      final supplier = response.data;
      if (supplier == null) throw const AppError.server();
      return Supplier.fromResponse(supplier);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required int supplierId}) async {
    try {
      await _api.deleteSupplierApiV1SuppliersSupplierIdDelete(
        supplierId: supplierId,
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

/// `creditLimit` is `anyOf: [number, string]` in mbe-api's schema; always
/// send the String arm — `AnyOf2<String, num>(values: {0: value})` (String
/// first, key 0), mirroring the proven construction in
/// `product_repository_impl.dart`'s `_setTaxRate` and the pricing feature's
/// margin/price wrappers (research.md §4). Create and update use distinct
/// generated wrapper classes for the same field.
void _setCreditLimit(CreditLimitBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void _setCreditLimit1(CreditLimit1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}
