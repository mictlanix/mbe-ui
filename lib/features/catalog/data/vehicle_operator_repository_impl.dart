import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle_operator.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/vehicle_operator_repository.dart';

final vehicleOperatorRepositoryProvider = Provider<VehicleOperatorRepository>((
  ref,
) {
  return VehicleOperatorRepositoryImpl(ref.watch(dioProvider));
});

class VehicleOperatorRepositoryImpl implements VehicleOperatorRepository {
  VehicleOperatorRepositoryImpl(Dio dio)
    : _dio = dio,
      _api = VehicleOperatorsApi(dio, appSerializers);

  final Dio _dio;
  final VehicleOperatorsApi _api;

  @override
  Future<VehicleOperatorListResult> list({
    String? search,
    int? driverId,
    EntityStatus? status,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listVehicleOperatorsApiV1VehicleOperatorsGet(
        search: search,
        employee: driverId,
        status: status?.toApi(),
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return VehicleOperatorListResult(
        items: result.items.map(VehicleOperator.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<VehicleOperator> get({required int vehicleOperatorId}) async {
    try {
      final response = await _api
          .getVehicleOperatorApiV1VehicleOperatorsVehicleOperatorIdGet(
            vehicleOperatorId: vehicleOperatorId,
          );
      final operator = response.data;
      if (operator == null) throw const AppError.server();
      return VehicleOperator.fromResponse(operator);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<VehicleOperator> create({
    required int driverId,
    required String licenseType,
    required String driverLicenseNumber,
    required DateTime issueDate,
    required DateTime expirationDate,
    required String issuingLocation,
    EntityStatus? status,
  }) async {
    try {
      final response = await _api
          .createVehicleOperatorApiV1VehicleOperatorsPost(
            vehicleOperatorCreate: VehicleOperatorCreate((b) {
              b
                ..driver = driverId
                ..licenseType = licenseType
                ..driverLicenseNumber = driverLicenseNumber
                ..issueDate = issueDate.toDate()
                ..expirationDate = expirationDate.toDate()
                ..issuingLocation = issuingLocation
                ..status = status?.toApi();
            }),
          );
      final operator = response.data;
      if (operator == null) throw const AppError.server();
      return VehicleOperator.fromResponse(operator);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<VehicleOperator> update({
    required int vehicleOperatorId,
    int? driverId,
    String? licenseType,
    String? driverLicenseNumber,
    DateTime? issueDate,
    DateTime? expirationDate,
    String? issuingLocation,
    EntityStatus? status,
  }) async {
    try {
      final response = await _api
          .updateVehicleOperatorApiV1VehicleOperatorsVehicleOperatorIdPut(
            vehicleOperatorId: vehicleOperatorId,
            vehicleOperatorUpdate: VehicleOperatorUpdate((b) {
              if (driverId != null) b.driver = driverId;
              if (licenseType != null) b.licenseType = licenseType;
              if (driverLicenseNumber != null) {
                b.driverLicenseNumber = driverLicenseNumber;
              }
              if (issueDate != null) b.issueDate = issueDate.toDate();
              if (expirationDate != null) {
                b.expirationDate = expirationDate.toDate();
              }
              if (issuingLocation != null) {
                b.issuingLocation = issuingLocation;
              }
              if (status != null) b.status = status.toApi();
            }),
          );
      final operator = response.data;
      if (operator == null) throw const AppError.server();
      return VehicleOperator.fromResponse(operator);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required int vehicleOperatorId}) async {
    try {
      await _api
          .deleteVehicleOperatorApiV1VehicleOperatorsVehicleOperatorIdDelete(
            vehicleOperatorId: vehicleOperatorId,
          );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  /// Reads the photo as raw bytes through the shared client rather than the
  /// generated `getLicensePhoto…Get`: mbe-api documents that route as
  /// `application/json`, so the generated method would hand the PNG to a JSON
  /// parser and lose it (051 research R1). Remove this once the route declares
  /// `image/png` and the client is regenerated.
  @override
  Future<Uint8List> getLicensePhoto({required int vehicleOperatorId}) async {
    try {
      final response = await _dio.get<List<int>>(
        '/api/v1/vehicle-operators/$vehicleOperatorId/license-photo',
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      if (data == null) throw const AppError.server();
      final bytes = Uint8List.fromList(data);
      // A 200 that is not a PNG (an HTML login page from a proxy, an empty
      // body) must never reach an image decoder.
      if (!_looksLikePng(bytes)) throw const AppError.server();
      return bytes;
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<VehicleOperator> uploadLicensePhoto({
    required int vehicleOperatorId,
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      final response = await _api
          .uploadLicensePhotoApiV1VehicleOperatorsVehicleOperatorIdLicensePhotoPost(
            vehicleOperatorId: vehicleOperatorId,
            file: MultipartFile.fromBytes(bytes, filename: filename),
          );
      final operator = response.data;
      if (operator == null) throw const AppError.server();
      return VehicleOperator.fromResponse(operator);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> removeLicensePhoto({required int vehicleOperatorId}) async {
    try {
      await _api
          .deleteLicensePhotoApiV1VehicleOperatorsVehicleOperatorIdLicensePhotoDelete(
            vehicleOperatorId: vehicleOperatorId,
          );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

/// The eight-byte signature every PNG starts with.
bool _looksLikePng(Uint8List bytes) {
  const signature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  if (bytes.length < signature.length) return false;
  for (var i = 0; i < signature.length; i++) {
    if (bytes[i] != signature[i]) return false;
  }
  return true;
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
