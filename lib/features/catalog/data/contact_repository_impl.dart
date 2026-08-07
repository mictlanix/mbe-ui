import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/contact_repository.dart';

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  return ContactRepositoryImpl(ref.watch(dioProvider));
});

/// `ContactRepository` backed by the generated `ContactsApi`
/// (mbe-api#133, contracts/mbe-api-pos.md §4).
class ContactRepositoryImpl implements ContactRepository {
  ContactRepositoryImpl(Dio dio)
    : _api = api.ContactsApi(dio, api.standardSerializers);

  final api.ContactsApi _api;

  @override
  Future<List<Contact>> list({String? search, int skip = 0, int limit = 20}) async {
    try {
      final response = await _api.listContactsApiV1ContactsGet(
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return result.items.map(Contact.fromResponse).toList();
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Contact> create({
    required String name,
    String? jobTitle,
    String? phone,
    String? mobile,
    String? email,
  }) async {
    try {
      final response = await _api.createContactApiV1ContactsPost(
        contactCreate: api.ContactCreate((b) {
          b
            ..name = name
            ..jobTitle = jobTitle
            ..phone = phone
            ..mobile = mobile
            ..email = email;
        }),
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Contact.fromResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
