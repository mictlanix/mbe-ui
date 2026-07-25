import 'package:built_value/serializer.dart';
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
  TaxpayerCertificateRepositoryImpl(this._dio)
    : _api = TaxpayerCertificatesApi(_dio, standardSerializers);

  final Dio _dio;
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
      // The generated wrapper types certificate/key as plain string form
      // fields (a codegen gap: the OpenAPI contract's `format: binary` file
      // fields didn't produce real multipart file parts), but the server
      // requires actual `UploadFile` parts and rejects a base64 string with
      // "Expected UploadFile" (research §8 correction, confirmed against a
      // live upload). Bypass the generated method — same pattern as
      // `ProductRepositoryImpl.uploadPhoto` — and post real file parts.
      final response = await _dio.post<Object>(
        '/api/v1/taxpayer-certificates',
        data: FormData.fromMap({
          'taxpayer': taxpayer,
          'certificate': MultipartFile.fromBytes(
            certificateBytes,
            filename: 'certificate.cer',
          ),
          'key': MultipartFile.fromBytes(keyBytes, filename: 'key.key'),
          'key_password': keyPassword,
        }),
      );
      final raw = response.data;
      if (raw == null) throw const AppError.server();
      final certificate =
          standardSerializers.deserialize(
                raw,
                specifiedType: const FullType(TaxpayerCertificateResponse),
              )
              as TaxpayerCertificateResponse;
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
