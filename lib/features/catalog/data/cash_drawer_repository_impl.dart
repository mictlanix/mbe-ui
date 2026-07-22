import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/cash_drawer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/cash_drawer_repository.dart';

final cashDrawerRepositoryProvider = Provider<CashDrawerRepository>((ref) {
  return CashDrawerRepositoryImpl(ref.watch(dioProvider));
});

class CashDrawerRepositoryImpl implements CashDrawerRepository {
  CashDrawerRepositoryImpl(Dio dio)
    : _api = CashDrawersApi(dio, standardSerializers);

  final CashDrawersApi _api;

  @override
  Future<CashDrawerListResult> list({
    String? search,
    int? facilityId,
    EntityStatus? status,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listCashDrawersApiV1CashDrawersGet(
        search: search,
        facility: facilityId,
        status: status?.toApi(),
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return CashDrawerListResult(
        items: result.items.map(CashDrawer.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<CashDrawer> get({required int cashDrawerId}) async {
    try {
      final response = await _api.getCashDrawerApiV1CashDrawersCashDrawerIdGet(
        cashDrawerId: cashDrawerId,
      );
      final cashDrawer = response.data;
      if (cashDrawer == null) throw const AppError.server();
      return CashDrawer.fromResponse(cashDrawer);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<CashDrawer> create({
    required int facilityId,
    required String code,
    required String name,
    String? comment,
    EntityStatus? status,
  }) async {
    try {
      final response = await _api.createCashDrawerApiV1CashDrawersPost(
        cashDrawerCreate: CashDrawerCreate((b) {
          b
            ..facility = facilityId
            ..code = code
            ..name = name
            ..comment = comment
            ..status = status?.toApi();
        }),
      );
      final cashDrawer = response.data;
      if (cashDrawer == null) throw const AppError.server();
      return CashDrawer.fromResponse(cashDrawer);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<CashDrawer> update({
    required int cashDrawerId,
    int? facilityId,
    String? code,
    String? name,
    String? comment,
    EntityStatus? status,
  }) async {
    try {
      final response = await _api
          .updateCashDrawerApiV1CashDrawersCashDrawerIdPut(
            cashDrawerId: cashDrawerId,
            cashDrawerUpdate: CashDrawerUpdate((b) {
              if (facilityId != null) b.facility = facilityId;
              if (code != null) b.code = code;
              if (name != null) b.name = name;
              if (comment != null) b.comment = comment;
              if (status != null) b.status = status.toApi();
            }),
          );
      final cashDrawer = response.data;
      if (cashDrawer == null) throw const AppError.server();
      return CashDrawer.fromResponse(cashDrawer);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required int cashDrawerId}) async {
    try {
      await _api.deleteCashDrawerApiV1CashDrawersCashDrawerIdDelete(
        cashDrawerId: cashDrawerId,
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
