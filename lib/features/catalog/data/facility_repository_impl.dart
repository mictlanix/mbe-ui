import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart'
    hide EntityStatus, FacilityType;

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/facility_type.dart' as domain;
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';

final facilityRepositoryProvider = Provider<FacilityRepository>((ref) {
  return FacilityRepositoryImpl(ref.watch(dioProvider));
});

class FacilityRepositoryImpl implements FacilityRepository {
  FacilityRepositoryImpl(Dio dio) : _api = FacilitiesApi(dio, standardSerializers);

  final FacilitiesApi _api;

  @override
  Future<FacilityListResult> list({
    String? search,
    EntityStatus? status,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listFacilitiesApiV1FacilitiesGet(
        search: search,
        status: status?.toApi(),
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return FacilityListResult(
        items: result.items.map(FacilityListItem.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Facility> get({required int facilityId}) async {
    try {
      final response = await _api.getFacilityApiV1FacilitiesFacilityIdGet(
        facilityId: facilityId,
      );
      final facility = response.data;
      if (facility == null) throw const AppError.server();
      return Facility.fromResponse(facility);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Facility> create({
    required String code,
    required String name,
    domain.FacilityType? type,
    required String location,
    required int address,
    required String taxpayer,
    String? logo,
    String? receiptMessage,
    String? defaultBatch,
    EntityStatus? status,
  }) async {
    try {
      final response = await _api.createFacilityApiV1FacilitiesPost(
        facilityCreate: FacilityCreate((b) {
          b
            ..code = code
            ..name = name
            ..type = type?.toApi()
            ..location = location
            ..address = address
            ..taxpayer = taxpayer
            ..logo = logo
            ..receiptMessage = receiptMessage
            ..defaultBatch = defaultBatch
            ..status = status?.toApi();
        }),
      );
      final facility = response.data;
      if (facility == null) throw const AppError.server();
      return Facility.fromResponse(facility);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Facility> update({
    required int facilityId,
    String? code,
    String? name,
    domain.FacilityType? type,
    String? location,
    int? address,
    String? taxpayer,
    String? logo,
    String? receiptMessage,
    String? defaultBatch,
    EntityStatus? status,
  }) async {
    try {
      final response = await _api.updateFacilityApiV1FacilitiesFacilityIdPut(
        facilityId: facilityId,
        facilityUpdate: FacilityUpdate((b) {
          if (code != null) b.code = code;
          if (name != null) b.name = name;
          if (type != null) b.type = type.toApi();
          if (location != null) b.location = location;
          if (address != null) b.address = address;
          if (taxpayer != null) b.taxpayer = taxpayer;
          if (logo != null) b.logo = logo;
          if (receiptMessage != null) b.receiptMessage = receiptMessage;
          if (defaultBatch != null) b.defaultBatch = defaultBatch;
          if (status != null) b.status = status.toApi();
        }),
      );
      final facility = response.data;
      if (facility == null) throw const AppError.server();
      return Facility.fromResponse(facility);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required int facilityId}) async {
    try {
      await _api.deleteFacilityApiV1FacilitiesFacilityIdDelete(
        facilityId: facilityId,
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
