import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/sat_catalog_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/sat_catalog_repository.dart';

final satCatalogRepositoryProvider = Provider<SatCatalogRepository>((ref) {
  return SatCatalogRepositoryImpl(ref.watch(dioProvider));
});

class SatCatalogRepositoryImpl implements SatCatalogRepository {
  SatCatalogRepositoryImpl(Dio dio)
    : _api = SatCatalogsApi(dio, standardSerializers);

  final SatCatalogsApi _api;

  @override
  Future<SatCatalogListResult> listUnitsOfMeasurement({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api
          .listUnitsOfMeasurementApiV1SatUnitsOfMeasurementGet(
            search: search,
            skip: skip,
            limit: limit,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return SatCatalogListResult(
        items: result.items.map(SatCatalogItem.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<SatCatalogListResult> listProductServices({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listProductServicesApiV1SatProductServicesGet(
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return SatCatalogListResult(
        items: result.items.map(SatCatalogItem.fromResponse).toList(),
        total: result.total,
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
