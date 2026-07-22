import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/point_sale_repository.dart';

final pointSaleRepositoryProvider = Provider<PointSaleRepository>((ref) {
  return PointSaleRepositoryImpl(ref.watch(dioProvider));
});

class PointSaleRepositoryImpl implements PointSaleRepository {
  PointSaleRepositoryImpl(Dio dio)
    : _api = PointsOfSaleApi(dio, standardSerializers);

  final PointsOfSaleApi _api;

  @override
  Future<PointSaleListResult> list({
    String? search,
    int? facilityId,
    int? warehouseId,
    EntityStatus? status,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listPointsOfSaleApiV1PointsOfSaleGet(
        search: search,
        facility: facilityId,
        warehouse: warehouseId,
        status: status?.toApi(),
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return PointSaleListResult(
        items: result.items.map(PointSale.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PointSale> get({required int pointSaleId}) async {
    try {
      final response = await _api.getPointOfSaleApiV1PointsOfSalePointSaleIdGet(
        pointSaleId: pointSaleId,
      );
      final pointSale = response.data;
      if (pointSale == null) throw const AppError.server();
      return PointSale.fromResponse(pointSale);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PointSale> create({
    required int facilityId,
    required String code,
    required String name,
    required int warehouseId,
    String? comment,
    EntityStatus? status,
  }) async {
    try {
      final response = await _api.createPointOfSaleApiV1PointsOfSalePost(
        pointSaleCreate: PointSaleCreate((b) {
          b
            ..facility = facilityId
            ..code = code
            ..name = name
            ..warehouse = warehouseId
            ..comment = comment
            ..status = status?.toApi();
        }),
      );
      final pointSale = response.data;
      if (pointSale == null) throw const AppError.server();
      return PointSale.fromResponse(pointSale);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PointSale> update({
    required int pointSaleId,
    int? facilityId,
    String? code,
    String? name,
    int? warehouseId,
    String? comment,
    EntityStatus? status,
  }) async {
    try {
      final response = await _api
          .updatePointOfSaleApiV1PointsOfSalePointSaleIdPut(
            pointSaleId: pointSaleId,
            pointSaleUpdate: PointSaleUpdate((b) {
              if (facilityId != null) b.facility = facilityId;
              if (code != null) b.code = code;
              if (name != null) b.name = name;
              if (warehouseId != null) b.warehouse = warehouseId;
              if (comment != null) b.comment = comment;
              if (status != null) b.status = status.toApi();
            }),
          );
      final pointSale = response.data;
      if (pointSale == null) throw const AppError.server();
      return PointSale.fromResponse(pointSale);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required int pointSaleId}) async {
    try {
      await _api.deletePointOfSaleApiV1PointsOfSalePointSaleIdDelete(
        pointSaleId: pointSaleId,
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
