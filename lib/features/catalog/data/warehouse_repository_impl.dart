import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';

final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  return WarehouseRepositoryImpl(ref.watch(dioProvider));
});

class WarehouseRepositoryImpl implements WarehouseRepository {
  WarehouseRepositoryImpl(Dio dio)
    : _api = WarehousesApi(dio, standardSerializers);

  final WarehousesApi _api;

  @override
  Future<WarehouseListResult> list({
    String? search,
    int? facilityId,
    EntityStatus? status,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listWarehousesApiV1WarehousesGet(
        search: search,
        facility: facilityId,
        status: status?.toApi(),
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return WarehouseListResult(
        items: result.items.map(Warehouse.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Warehouse> get({required int warehouseId}) async {
    try {
      final response = await _api.getWarehouseApiV1WarehousesWarehouseIdGet(
        warehouseId: warehouseId,
      );
      final warehouse = response.data;
      if (warehouse == null) throw const AppError.server();
      return Warehouse.fromResponse(warehouse);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Warehouse> create({
    required int facilityId,
    required String code,
    required String name,
    String? comment,
    EntityStatus? status,
  }) async {
    try {
      final response = await _api.createWarehouseApiV1WarehousesPost(
        warehouseCreate: WarehouseCreate((b) {
          b
            ..facility = facilityId
            ..code = code
            ..name = name
            ..comment = comment
            ..status = status?.toApi();
        }),
      );
      final warehouse = response.data;
      if (warehouse == null) throw const AppError.server();
      return Warehouse.fromResponse(warehouse);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Warehouse> update({
    required int warehouseId,
    int? facilityId,
    String? code,
    String? name,
    String? comment,
    EntityStatus? status,
  }) async {
    try {
      final response = await _api
          .updateWarehouseApiV1WarehousesWarehouseIdPut(
            warehouseId: warehouseId,
            warehouseUpdate: WarehouseUpdate((b) {
              if (facilityId != null) b.facility = facilityId;
              if (code != null) b.code = code;
              if (name != null) b.name = name;
              if (comment != null) b.comment = comment;
              if (status != null) b.status = status.toApi();
            }),
          );
      final warehouse = response.data;
      if (warehouse == null) throw const AppError.server();
      return Warehouse.fromResponse(warehouse);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required int warehouseId}) async {
    try {
      await _api.deleteWarehouseApiV1WarehousesWarehouseIdDelete(
        warehouseId: warehouseId,
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
