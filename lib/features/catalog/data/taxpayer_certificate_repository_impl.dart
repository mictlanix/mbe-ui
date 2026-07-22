import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_certificate.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_certificate_repository.dart';

final taxpayerCertificateRepositoryProvider =
    Provider<TaxpayerCertificateRepository>((ref) {
      return TaxpayerCertificateRepositoryImpl(ref.watch(dioProvider));
    });

/// `TaxpayerCertificateRepository` backed by the generated `mbe_api_client`
/// `TaxpayerCertificatesApi` (contracts/mbe-api-catalogs.md §3). Consumed
/// only by the Taxpayer Issuer detail's Certificates section — [listForIssuer]
/// always scopes to a single RFC; there is no standalone list/detail screen
/// (research §9).
class TaxpayerCertificateRepositoryImpl
    implements TaxpayerCertificateRepository {
  TaxpayerCertificateRepositoryImpl(Dio dio)
    : _api = TaxpayerCertificatesApi(dio, standardSerializers);

  final TaxpayerCertificatesApi _api;

  @override
  Future<List<TaxpayerCertificate>> listForIssuer(String rfc) async {
    try {
      final response = await _api
          .listTaxpayerCertificatesApiV1TaxpayerCertificatesGet(
            taxpayer: rfc,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return result.items.map(TaxpayerCertificate.fromResponse).toList();
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<TaxpayerCertificate> upload({
    required String taxpayer,
    required List<int> certificateBytes,
    required List<int> keyBytes,
    required String keyPassword,
  }) async {
    try {
      final response = await _api
          .uploadTaxpayerCertificateApiV1TaxpayerCertificatesPost(
            taxpayer: taxpayer,
            // The generated multipart body sends these as plain string form
            // fields (`FormData.fromMap`), not binary file parts, so the raw
            // DER bytes are base64-encoded into the string mbe-api expects
            // (research §8; confirmed against a live upload in quickstart).
            certificate: base64Encode(certificateBytes),
            key: base64Encode(keyBytes),
            keyPassword: keyPassword,
          );
      final certificate = response.data;
      if (certificate == null) throw const AppError.server();
      return TaxpayerCertificate.fromResponse(certificate);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
