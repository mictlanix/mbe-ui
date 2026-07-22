import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_issuer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_issuer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_issuer_repository.dart';

final taxpayerIssuerRepositoryProvider = Provider<TaxpayerIssuerRepository>((
  ref,
) {
  return TaxpayerIssuerRepositoryImpl(ref.watch(dioProvider));
});

class TaxpayerIssuerRepositoryImpl implements TaxpayerIssuerRepository {
  TaxpayerIssuerRepositoryImpl(Dio dio)
    : _api = TaxpayerIssuersApi(dio, standardSerializers);

  final TaxpayerIssuersApi _api;

  @override
  Future<TaxpayerIssuerListResult> list({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listTaxpayerIssuersApiV1TaxpayerIssuersGet(
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return TaxpayerIssuerListResult(
        items: result.items.map(TaxpayerIssuerListItem.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<TaxpayerIssuerListItem?> get(String rfc) async {
    try {
      final response = await _api.getTaxpayerIssuerApiV1TaxpayerIssuersRfcGet(
        rfc: rfc,
      );
      final issuer = response.data;
      if (issuer == null) return null;
      return TaxpayerIssuerListItem.fromResponse(issuer);
    } on DioException catch (e) {
      // A not-found RFC is a legitimate "unresolvable" outcome (FR-034b),
      // not a screen-failing error — degrade to null, same as a null body.
      if (e.response?.statusCode == 404) return null;
      throw _toAppError(e);
    }
  }

  @override
  Future<TaxpayerIssuer> getDetail(String rfc) async {
    try {
      final response = await _api.getTaxpayerIssuerApiV1TaxpayerIssuersRfcGet(
        rfc: rfc,
      );
      final issuer = response.data;
      if (issuer == null) throw const AppError.server();
      return TaxpayerIssuer.fromResponse(issuer);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<TaxpayerIssuer> create({
    required String rfc,
    String? name,
    required String regime,
    FiscalCertificationProvider? provider,
    String? postalCode,
    String? comment,
  }) async {
    try {
      final response = await _api.createTaxpayerIssuerApiV1TaxpayerIssuersPost(
        taxpayerIssuerCreate: TaxpayerIssuerCreate((b) {
          b
            ..taxpayerIssuerId = rfc
            ..name = name
            ..regime = regime
            ..provider = provider
            ..postalCode = postalCode
            ..comment = comment;
        }),
      );
      final issuer = response.data;
      if (issuer == null) throw const AppError.server();
      return TaxpayerIssuer.fromResponse(issuer);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<TaxpayerIssuer> update({
    required String rfc,
    String? name,
    String? regime,
    FiscalCertificationProvider? provider,
    String? postalCode,
    String? comment,
  }) async {
    try {
      final response = await _api
          .updateTaxpayerIssuerApiV1TaxpayerIssuersRfcPut(
            rfc: rfc,
            taxpayerIssuerUpdate: TaxpayerIssuerUpdate((b) {
              if (name != null) b.name = name;
              if (regime != null) b.regime = regime;
              if (provider != null) b.provider = provider;
              if (postalCode != null) b.postalCode = postalCode;
              if (comment != null) b.comment = comment;
            }),
          );
      final issuer = response.data;
      if (issuer == null) throw const AppError.server();
      return TaxpayerIssuer.fromResponse(issuer);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete(String rfc) async {
    try {
      await _api.deleteTaxpayerIssuerApiV1TaxpayerIssuersRfcDelete(rfc: rfc);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
