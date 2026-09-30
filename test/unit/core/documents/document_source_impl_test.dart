import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';

/// Drives the real generated print methods through a stubbed dio adapter, with
/// the real [AuthInterceptor] attached, so the byte-body error path is the one
/// production runs (spec 044 research R9, R15).
void main() {
  group('DocumentSourceImpl.fetch — success', () {
    test('returns the bytes exactly as the server sent them (FR-020)', () async {
      final bytes = _pdf([1, 2, 3, 250, 251, 252, 0, 255]);
      final source = _sourceWith(
        (options) async => _pdfResponse(bytes, filename: 'ticket-00000042.pdf'),
      );

      final document = await source.fetch(_ref(DocumentKind.saleTicket, 42));

      // Bytes above 0x7F are exactly what a UTF-8 decode would have corrupted.
      expect(document.bytes, orderedEquals(bytes));
    });

    test('requests the route for each kind', () async {
      final paths = <String>[];
      final source = _sourceWith((options) async {
        paths.add(options.path);
        return _pdfResponse(_pdf([1]), filename: 'x.pdf');
      });

      await source.fetch(_ref(DocumentKind.saleTicket, 42));
      await source.fetch(_ref(DocumentKind.salesOrder, 42));
      await source.fetch(_ref(DocumentKind.cashCut, 7));

      expect(paths, [
        '/api/v1/sales-orders/42/ticket',
        '/api/v1/sales-orders/42/document',
        '/api/v1/cash-sessions/7/ticket',
      ]);
    });

    test('takes the file name from Content-Disposition', () async {
      final source = _sourceWith(
        (options) async =>
            _pdfResponse(_pdf([1]), filename: 'pedido-00001234.pdf'),
      );

      final document = await source.fetch(_ref(DocumentKind.salesOrder, 1234));

      expect(document.filename, 'pedido-00001234.pdf');
    });

    test(
      'falls back to the kind\'s padded name when the header is missing',
      () async {
        final source = _sourceWith((options) async => _pdfResponse(_pdf([1])));

        expect(
          (await source.fetch(_ref(DocumentKind.saleTicket, 42))).filename,
          'ticket-00000042.pdf',
        );
        expect(
          (await source.fetch(_ref(DocumentKind.salesOrder, 42))).filename,
          'pedido-00000042.pdf',
        );
        expect(
          (await source.fetch(_ref(DocumentKind.cashCut, 7))).filename,
          'corte-000007.pdf',
        );
      },
    );

    test('falls back when the header carries no file name', () async {
      final source = _sourceWith(
        (options) async => _pdfResponse(_pdf([1]), disposition: 'inline'),
      );

      final document = await source.fetch(_ref(DocumentKind.cashCut, 7));

      expect(document.filename, 'corte-000007.pdf');
    });

    test('never lets a server-supplied name carry a path', () async {
      final source = _sourceWith(
        (options) async => _pdfResponse(
          _pdf([1]),
          disposition: 'inline; filename="../../etc/passwd"',
        ),
      );

      final document = await source.fetch(_ref(DocumentKind.saleTicket, 42));

      expect(document.filename, 'passwd');
    });
  });

  group('DocumentSourceImpl.fetch — a 200 that is not a PDF (FR-020)', () {
    test('a body that does not start with %PDF- is a ServerError', () async {
      final source = _sourceWith(
        (options) async => ResponseBody.fromBytes(
          Uint8List.fromList(utf8.encode('<html>login</html>')),
          200,
          headers: _pdfHeaders(),
        ),
      );

      await expectLater(
        () => source.fetch(_ref(DocumentKind.saleTicket, 42)),
        throwsA(isA<ServerError>()),
      );
    });

    test('an empty body is a ServerError', () async {
      final source = _sourceWith(
        (options) async =>
            ResponseBody.fromBytes(Uint8List(0), 200, headers: _pdfHeaders()),
      );

      await expectLater(
        () => source.fetch(_ref(DocumentKind.saleTicket, 42)),
        throwsA(isA<ServerError>()),
      );
    });
  });

  group('DocumentSourceImpl.fetch — refusals keep the server\'s reason '
      '(FR-030, SC-005)', () {
    test('404 for a missing sales order', () async {
      final source = _sourceWith(
        (options) async => _jsonError(404, 'Sales order not found'),
      );

      await expectLater(
        () => source.fetch(_ref(DocumentKind.salesOrder, 9)),
        throwsA(
          isA<NotFoundError>().having(
            (e) => e.message,
            'message',
            'Sales order not found',
          ),
        ),
      );
    });

    test('404 for a missing cash session', () async {
      final source = _sourceWith(
        (options) async => _jsonError(404, 'Cash session not found'),
      );

      await expectLater(
        () => source.fetch(_ref(DocumentKind.cashCut, 9)),
        throwsA(
          isA<NotFoundError>().having(
            (e) => e.message,
            'message',
            'Cash session not found',
          ),
        ),
      );
    });

    test('409 for the cut of a session that is still open', () async {
      final source = _sourceWith(
        (options) async => _jsonError(409, 'Cash session is not closed'),
      );

      await expectLater(
        () => source.fetch(_ref(DocumentKind.cashCut, 7)),
        throwsA(
          isA<ServerError>()
              .having((e) => e.statusCode, 'statusCode', 409)
              .having(
                (e) => e.message,
                'message',
                'Cash session is not closed',
              ),
        ),
      );
    });

    test('403 for a user without the privilege', () async {
      final source = _sourceWith(
        (options) async => _jsonError(403, 'Insufficient privileges'),
      );

      await expectLater(
        () => source.fetch(_ref(DocumentKind.saleTicket, 42)),
        throwsA(
          isA<ServerError>()
              .having((e) => e.statusCode, 'statusCode', 403)
              .having((e) => e.message, 'message', 'Insufficient privileges'),
        ),
      );
    });

    test('a connection failure is a NetworkError', () async {
      final source = _sourceWith((options) async {
        throw DioException.connectionError(
          requestOptions: options,
          reason: 'no route to host',
        );
      });

      await expectLater(
        () => source.fetch(_ref(DocumentKind.saleTicket, 42)),
        throwsA(isA<NetworkError>()),
      );
    });
  });
}

DocumentRef _ref(DocumentKind kind, int id) =>
    DocumentRef(kind: kind, recordId: id, title: 'title');

/// A minimal body that starts as a PDF does, with [tail] after the header.
Uint8List _pdf(List<int> tail) =>
    Uint8List.fromList([...utf8.encode('%PDF-1.7\n'), ...tail]);

Map<String, List<String>> _pdfHeaders({String? disposition}) => {
  Headers.contentTypeHeader: ['application/pdf'],
  if (disposition != null) 'content-disposition': [disposition],
};

ResponseBody _pdfResponse(
  Uint8List bytes, {
  String? filename,
  String? disposition,
}) => ResponseBody.fromBytes(
  bytes,
  200,
  headers: _pdfHeaders(
    disposition:
        disposition ??
        (filename == null ? null : 'inline; filename="$filename"'),
  ),
);

ResponseBody _jsonError(int status, String detail) => ResponseBody.fromBytes(
  Uint8List.fromList(utf8.encode(jsonEncode({'detail': detail}))),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

DocumentSourceImpl _sourceWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler)
    ..interceptors.add(AuthInterceptor(_NoTokenStorage()));
  return DocumentSourceImpl(dio);
}

class _NoTokenStorage extends TokenStorage {
  @override
  Future<String?> read() async => null;
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _handler(options);

  @override
  void close({bool force = false}) {}
}
