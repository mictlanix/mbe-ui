import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/vehicle_repository.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepositoryImpl(ref.watch(dioProvider));
});

class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl(Dio dio) : _api = VehiclesApi(dio, standardSerializers);

  final VehiclesApi _api;

  @override
  Future<VehicleListResult> list({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listVehiclesApiV1VehiclesGet(
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return VehicleListResult(
        items: result.items.map(Vehicle.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Vehicle> get({required int vehicleId}) async {
    try {
      final response = await _api.getVehicleApiV1VehiclesVehicleIdGet(
        vehicleId: vehicleId,
      );
      final vehicle = response.data;
      if (vehicle == null) throw const AppError.server();
      return Vehicle.fromResponse(vehicle);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Vehicle> create({
    required String licensePlate,
    required String name,
    required String nickname,
    required int tonsCapacity,
    bool? active,
  }) async {
    try {
      final response = await _api.createVehicleApiV1VehiclesPost(
        vehicleCreate: VehicleCreate((b) {
          b
            ..licensePlate = licensePlate
            ..name = name
            ..nickname = nickname
            ..tonsCapacity = tonsCapacity
            ..active = active;
        }),
      );
      final vehicle = response.data;
      if (vehicle == null) throw const AppError.server();
      return Vehicle.fromResponse(vehicle);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Vehicle> update({
    required int vehicleId,
    String? licensePlate,
    String? name,
    String? nickname,
    int? tonsCapacity,
    bool? active,
  }) async {
    try {
      final response = await _api.updateVehicleApiV1VehiclesVehicleIdPut(
        vehicleId: vehicleId,
        vehicleUpdate: VehicleUpdate((b) {
          if (licensePlate != null) b.licensePlate = licensePlate;
          if (name != null) b.name = name;
          if (nickname != null) b.nickname = nickname;
          if (tonsCapacity != null) b.tonsCapacity = tonsCapacity;
          if (active != null) b.active = active;
        }),
      );
      final vehicle = response.data;
      if (vehicle == null) throw const AppError.server();
      return Vehicle.fromResponse(vehicle);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required int vehicleId}) async {
    try {
      await _api.deleteVehicleApiV1VehiclesVehicleIdDelete(
        vehicleId: vehicleId,
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
