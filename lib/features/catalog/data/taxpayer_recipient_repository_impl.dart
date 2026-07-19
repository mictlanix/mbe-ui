import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_recipient_repository.dart';

final taxpayerRecipientRepositoryProvider =
    Provider<TaxpayerRecipientRepository>((ref) {
      return TaxpayerRecipientRepositoryImpl(ref.watch(dioProvider));
    });

class TaxpayerRecipientRepositoryImpl implements TaxpayerRecipientRepository {
  TaxpayerRecipientRepositoryImpl(Dio dio)
    : _api = TaxpayerRecipientsApi(dio, standardSerializers);

  final TaxpayerRecipientsApi _api;

  @override
  Future<TaxpayerRecipientPage> list({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api
          .listTaxpayerRecipientsApiV1TaxpayerRecipientsGet(
            search: search,
            skip: skip,
            limit: limit,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return TaxpayerRecipientPage(
        items: result.items
            .map(TaxpayerRecipientListItem.fromResponse)
            .toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<TaxpayerRecipient> get({required String taxpayerRecipientId}) async {
    try {
      final response = await _api
          .getTaxpayerRecipientApiV1TaxpayerRecipientsRfcGet(
            rfc: taxpayerRecipientId,
          );
      final taxpayerRecipient = response.data;
      if (taxpayerRecipient == null) throw const AppError.server();
      return TaxpayerRecipient.fromResponse(taxpayerRecipient);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<TaxpayerRecipient> create({
    required String taxpayerRecipientId,
    required String email,
    String? name,
    String? postalCode,
    String? regime,
  }) async {
    try {
      final response = await _api
          .createTaxpayerRecipientApiV1TaxpayerRecipientsPost(
            taxpayerRecipientCreate: TaxpayerRecipientCreate((b) {
              b
                ..taxpayerRecipientId = taxpayerRecipientId
                ..email = email
                ..name = name
                ..postalCode = postalCode
                ..regime = regime;
            }),
          );
      final taxpayerRecipient = response.data;
      if (taxpayerRecipient == null) throw const AppError.server();
      return TaxpayerRecipient.fromResponse(taxpayerRecipient);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<TaxpayerRecipient> update({
    required String taxpayerRecipientId,
    String? name,
    String? email,
    String? postalCode,
    String? regime,
  }) async {
    try {
      final response = await _api
          .updateTaxpayerRecipientApiV1TaxpayerRecipientsRfcPut(
            rfc: taxpayerRecipientId,
            taxpayerRecipientUpdate: TaxpayerRecipientUpdate((b) {
              if (name != null) b.name = name;
              if (email != null) b.email = email;
              if (postalCode != null) b.postalCode = postalCode;
              if (regime != null) b.regime = regime;
            }),
          );
      final taxpayerRecipient = response.data;
      if (taxpayerRecipient == null) throw const AppError.server();
      return TaxpayerRecipient.fromResponse(taxpayerRecipient);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete({required String taxpayerRecipientId}) async {
    try {
      await _api.deleteTaxpayerRecipientApiV1TaxpayerRecipientsRfcDelete(
        rfc: taxpayerRecipientId,
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
