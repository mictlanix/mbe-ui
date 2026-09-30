import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/cash_session_status.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

/// Read-only integration test against a *real* mbe-api instance (constitution
/// §VII — no mocked/offline mode): the three PDFs mbe-api#231 renders reach
/// the client intact, and the server's own reasons reach the user when it
/// refuses one (spec 044 SC-003, SC-005, FR-020, FR-030).
///
/// Unlike its siblings this **creates nothing**: every fixture is discovered
/// at runtime from what the database already holds — a sales order, a closed
/// cash session and, if there is one, an open session — so it leaves no
/// orders behind and survives a reseeded database. A fixture that cannot be
/// found skips its check rather than failing the run.
///
/// Requires mbe-api at [apiBaseUrl] (default `http://127.0.0.1:8000`, at or
/// after mbe-api#231) and an account that may read sales orders and the point
/// of sale. The `MBE_POS_*` account is the `admin` one. Configure via
/// `--dart-define`, or `--dart-define-from-file=.env`:
///   --dart-define=MBE_POS_USERNAME=...
///   --dart-define=MBE_POS_PASSWORD=...
///
/// Skipped entirely when credentials aren't provided.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');

const _canRun = _username != '' && _password != '';
const _skipReason = 'MBE_POS_USERNAME / MBE_POS_PASSWORD were not provided';

void main() {
  late Dio dio;
  late DocumentSourceImpl source;

  int? saleId;
  int? closedSessionId;
  int? openSessionId;

  setUpAll(() async {
    if (!_canRun) return;

    dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _username, password: _password);
    dio.options.headers['Authorization'] = 'Bearer $token';
    source = DocumentSourceImpl(dio);

    // A sales order in any state can be printed; prefer a finished one so the
    // ticket is the final receipt.
    final orders = SalesOrderRepositoryImpl(dio);
    for (final status in [SaleStatus.paid, SaleStatus.completed, null]) {
      final page = await orders.listOrders(status: status, limit: 1);
      if (page.items.isNotEmpty) {
        saleId = page.items.first.id;
        break;
      }
    }

    final sessions = CashSessionRepositoryImpl(dio);
    final closed = await sessions.list(
      status: CashSessionStatus.closed,
      limit: 1,
    );
    if (closed.items.isNotEmpty) {
      closedSessionId = closed.items.first.cashSessionId;
    }
    final open = await sessions.list(status: CashSessionStatus.open, limit: 1);
    if (open.items.isNotEmpty) {
      openSessionId = open.items.first.cashSessionId;
    }
  });

  DocumentRef ref(DocumentKind kind, int id) =>
      DocumentRef(kind: kind, recordId: id, title: 'title');

  /// The same document fetched directly, with no client code in between.
  Future<Uint8List> direct(String path) async {
    final response = await dio.get<List<int>>(
      path,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }

  test(
    'the sale ticket and the pedido arrive as the exact bytes the server '
    'renders, with the server\'s file names (SC-003, FR-020)',
    () async {
      final id = saleId;
      if (id == null) {
        markTestSkipped('this database holds no sales order to print');
        return;
      }

      final ticket = await source.fetch(ref(DocumentKind.saleTicket, id));
      final pedido = await source.fetch(ref(DocumentKind.salesOrder, id));

      expect(String.fromCharCodes(ticket.bytes.take(5)), '%PDF-');
      expect(String.fromCharCodes(pedido.bytes.take(5)), '%PDF-');
      expect(
        ticket.bytes,
        orderedEquals(await direct('/api/v1/sales-orders/$id/ticket')),
        reason: 'the client must not alter a byte of the ticket',
      );
      expect(
        pedido.bytes,
        orderedEquals(await direct('/api/v1/sales-orders/$id/document')),
        reason: 'the client must not alter a byte of the pedido',
      );
      expect(ticket.filename, matches(RegExp(r'^ticket-\d{8}\.pdf$')));
      expect(pedido.filename, matches(RegExp(r'^pedido-\d{8}\.pdf$')));
    },
    skip: _canRun ? null : _skipReason,
  );

  test(
    'the cut of a closed session arrives intact, and can be fetched again '
    '(SC-003, US3 reprint)',
    () async {
      final id = closedSessionId;
      if (id == null) {
        markTestSkipped('this database holds no closed cash session');
        return;
      }

      final first = await source.fetch(ref(DocumentKind.cashCut, id));
      final again = await source.fetch(ref(DocumentKind.cashCut, id));

      expect(String.fromCharCodes(first.bytes.take(5)), '%PDF-');
      expect(
        first.bytes,
        orderedEquals(await direct('/api/v1/cash-sessions/$id/ticket')),
      );
      expect(
        again.bytes,
        orderedEquals(first.bytes),
        reason: 'the same data renders to the same bytes, so a reprint matches',
      );
      expect(first.filename, matches(RegExp(r'^corte-\d{6}\.pdf$')));
    },
    skip: _canRun ? null : _skipReason,
  );

  test(
    'the cut of a session that is still open is refused, and the user gets '
    'the server\'s reason (SC-005, FR-030)',
    () async {
      final id = openSessionId;
      if (id == null) {
        markTestSkipped('this database holds no open cash session');
        return;
      }

      await expectLater(
        () => source.fetch(ref(DocumentKind.cashCut, id)),
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
    },
    skip: _canRun ? null : _skipReason,
  );

  test(
    'a document that does not exist is refused with the server\'s own '
    'wording, which arrives as bytes and is still read (SC-005, FR-030)',
    () async {
      const missing = 2147483000;

      await expectLater(
        () => source.fetch(ref(DocumentKind.saleTicket, missing)),
        throwsA(
          isA<NotFoundError>().having(
            (e) => e.message,
            'message',
            'Sales order not found',
          ),
        ),
      );
      await expectLater(
        () => source.fetch(ref(DocumentKind.cashCut, missing)),
        throwsA(
          isA<NotFoundError>().having(
            (e) => e.message,
            'message',
            'Cash session not found',
          ),
        ),
      );
    },
    skip: _canRun ? null : _skipReason,
  );
}
