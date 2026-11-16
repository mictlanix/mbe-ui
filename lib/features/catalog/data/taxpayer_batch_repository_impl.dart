import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_batch.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_batch_repository.dart';

final taxpayerBatchRepositoryProvider = Provider<TaxpayerBatchRepository>((
  ref,
) {
  return TaxpayerBatchRepositoryImpl(ref.watch(dioProvider));
});

/// `TaxpayerBatchRepository` backed by the generated `mbe_api_client`
/// `TaxpayerIssuersApi` batch methods (spec 065, contracts/
/// consumed-endpoints.md). Consumed only by the Taxpayer Issuer detail's
/// Series section — every call is scoped to one RFC.
class TaxpayerBatchRepositoryImpl implements TaxpayerBatchRepository {
  TaxpayerBatchRepositoryImpl(Dio dio)
    : _api = TaxpayerIssuersApi(dio, appSerializers);

  final TaxpayerIssuersApi _api;

  @override
  Future<List<TaxpayerBatch>> listForIssuer(String rfc) async {
    try {
      final response = await _api
          .listTaxpayerBatchesApiV1TaxpayerIssuersRfcBatchesGet(rfc: rfc);
      final result = response.data;
      if (result == null) throw const AppError.server();
      return result.map(TaxpayerBatch.fromResponse).toList();
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<TaxpayerBatch> create(String rfc, TaxpayerBatchDraft draft) async {
    try {
      final response = await _api
          .createTaxpayerBatchApiV1TaxpayerIssuersRfcBatchesPost(
            rfc: rfc,
            taxpayerBatchCreate: TaxpayerBatchCreate(
              (b) => b
                ..batch = draft.series
                ..type = _wireType(draft.kind)
                ..template.replace(_wireTemplate(draft.template)),
            ),
          );
      final created = response.data;
      if (created == null) throw const AppError.server();
      return TaxpayerBatch.fromResponse(created);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<TaxpayerBatch> update(
    String rfc,
    int taxpayerBatchId,
    TaxpayerBatchDraft draft,
  ) async {
    try {
      final response = await _api
          .updateTaxpayerBatchApiV1TaxpayerIssuersRfcBatchesTaxpayerBatchIdPut(
            rfc: rfc,
            taxpayerBatchId: taxpayerBatchId,
            taxpayerBatchUpdate: TaxpayerBatchUpdate(
              (b) => b
                ..batch = draft.series
                ..type = _wireType(draft.kind)
                ..template.replace(_wireTemplate(draft.template)),
            ),
          );
      final updated = response.data;
      if (updated == null) throw const AppError.server();
      return TaxpayerBatch.fromResponse(updated);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> delete(String rfc, int taxpayerBatchId) async {
    try {
      await _api
          .deleteTaxpayerBatchApiV1TaxpayerIssuersRfcBatchesTaxpayerBatchIdDelete(
            rfc: rfc,
            taxpayerBatchId: taxpayerBatchId,
          );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

/// The wire enum for a kind. The only place the generated
/// `FiscalDocumentType` (whose constants are named after their codes) is
/// touched, so presentation never sees it.
FiscalDocumentType _wireType(FiscalDocumentKind kind) => switch (kind) {
  FiscalDocumentKind.invoice => FiscalDocumentType.number0,
  FiscalDocumentKind.feeReceipt => FiscalDocumentType.number1,
  FiscalDocumentKind.rentReceipt => FiscalDocumentType.number2,
  FiscalDocumentKind.debitNote => FiscalDocumentType.number3,
  FiscalDocumentKind.creditNote => FiscalDocumentType.number100,
  FiscalDocumentKind.advancePaymentsApplied => FiscalDocumentType.number101,
  FiscalDocumentKind.paymentReceipt => FiscalDocumentType.number200,
};

/// The wire template: a blank logo is sent as `null`, accounts keep their
/// order, and the controller has already dropped all-blank rows.
BatchTemplate _wireTemplate(TaxpayerBatchTemplate t) {
  final logo = t.logo?.trim();
  return BatchTemplate(
    (b) => b
      ..name = t.name
      ..logo = (logo == null || logo.isEmpty) ? null : logo
      ..headerHeight = t.headerHeight
      ..footerHeight = t.footerHeight
      ..extraInfo.replace([
        for (final a in t.accounts)
          BatchAccount(
            (x) => x
              ..bank = a.bank
              ..account = a.account
              ..clabe = a.clabe
              ..currency = a.currency,
          ),
      ]),
  );
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
