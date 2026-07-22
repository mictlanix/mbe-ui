import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide AddressType;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/address_repository.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepositoryImpl(ref.watch(dioProvider));
});

class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl(Dio dio) : _api = AddressesApi(dio, standardSerializers);

  final AddressesApi _api;

  @override
  Future<AddressListResult> list({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listAddressesApiV1AddressesGet(
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return AddressListResult(
        items: result.items.map(AddressListItem.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<AddressListItem> create(AddressCreatePayload payload) async {
    try {
      final response = await _api.createAddressApiV1AddressesPost(
        addressCreate: AddressCreate((b) {
          b
            ..street = payload.street
            ..exteriorNumber = payload.exteriorNumber
            ..interiorNumber = payload.interiorNumber
            ..postalCode = payload.postalCode
            ..neighborhood = payload.neighborhood
            ..locality = payload.locality
            ..borough = payload.borough
            ..state = payload.addressState
            ..city = payload.city
            ..country = payload.country
            ..nickname = payload.nickname
            ..type = payload.type?.toApi()
            ..comment = payload.comment;
        }),
      );
      final address = response.data;
      if (address == null) throw const AppError.server();
      return AddressListItem.fromResponse(address);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
