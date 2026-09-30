import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/domain/document_source.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';

final documentSourceProvider = Provider<DocumentSource>((ref) {
  return DocumentSourceImpl(ref.watch(dioProvider));
});

/// `DocumentSource` backed by the three generated print methods mbe-api#231
/// added (spec 044 contracts/consumed-endpoints.md).
///
/// A PDF has no DTO, so there is no mapping: the bytes are returned exactly as
/// the server sent them (FR-020). The generated methods already ask dio for
/// `ResponseType.bytes`, which is why no raw-dio bypass is needed
/// (`generated_client_bytes_test.dart` guards that).
class DocumentSourceImpl implements DocumentSource {
  DocumentSourceImpl(Dio dio)
    : _salesOrders = api.SalesOrdersApi(dio, appSerializers),
      _cashSessions = api.CashSessionsApi(dio, appSerializers);

  final api.SalesOrdersApi _salesOrders;
  final api.CashSessionsApi _cashSessions;

  @override
  Future<RenderedDocument> fetch(DocumentRef ref) async {
    try {
      final response = await switch (ref.kind) {
        DocumentKind.saleTicket =>
          _salesOrders
              .printSalesOrderTicketApiV1SalesOrdersSalesOrderIdTicketGet(
                salesOrderId: ref.recordId,
              ),
        DocumentKind.salesOrder =>
          _salesOrders
              .printSalesOrderDocumentApiV1SalesOrdersSalesOrderIdDocumentGet(
                salesOrderId: ref.recordId,
              ),
        DocumentKind.cashCut =>
          _cashSessions
              .printCashSessionCutApiV1CashSessionsCashSessionIdTicketGet(
                cashSessionId: ref.recordId,
              ),
      };

      // A 200 that is not a PDF (an HTML login page from a proxy, an empty
      // body) must never reach a viewer or a printer (FR-020).
      final bytes = response.data;
      if (bytes == null || !_looksLikePdf(bytes)) {
        throw const AppError.server();
      }

      return RenderedDocument(
        bytes: bytes,
        filename:
            _filenameFrom(response.headers) ??
            ref.kind.fallbackFilename(ref.recordId),
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

/// `%PDF-` — the four-byte-plus-dash signature every PDF starts with.
bool _looksLikePdf(Uint8List bytes) =>
    bytes.length >= 5 &&
    bytes[0] == 0x25 &&
    bytes[1] == 0x50 &&
    bytes[2] == 0x44 &&
    bytes[3] == 0x46 &&
    bytes[4] == 0x2D;

final _quotedFilename = RegExp(r'filename="([^"]*)"', caseSensitive: false);
final _bareFilename = RegExp(r'filename=([^;\s]+)', caseSensitive: false);

/// The `filename` of a `Content-Disposition` header, reduced to its last path
/// segment so a server-supplied name can never carry a directory (research
/// R10). `null` when there is no usable name, so the caller falls back.
String? _filenameFrom(Headers headers) {
  final disposition = headers.value('content-disposition');
  if (disposition == null) return null;
  final match =
      _quotedFilename.firstMatch(disposition) ??
      _bareFilename.firstMatch(disposition);
  final raw = match?.group(1)?.trim();
  if (raw == null || raw.isEmpty) return null;
  final name = raw.split(RegExp(r'[\\/]')).last.trim();
  return name.isEmpty ? null : name;
}

/// The interceptor has already attached the mapped [AppError]; fall back to
/// mapping here for callers that run without it (integration tests).
AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
