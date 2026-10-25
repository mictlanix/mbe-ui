import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_quote_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

/// Integration test against a *real* mbe-api instance (constitution §VII — no
/// mocked/offline mode): the quote PDF mbe-api spec 024 renders reaches the
/// client intact, and the server's refusals to email a quote map to the
/// causes the dialog shows (spec 053 SC-001, SC-003, FR-003, FR-013).
///
/// Creates nothing: every quote is discovered at runtime from what the
/// database already holds, and a fixture that cannot be found skips its check
/// rather than failing the run.
///
/// **Sending a real email is opt-in.** The only check that sends mail runs
/// when `MBE_QUOTE_EMAIL_TO` names an inbox you control, against a
/// deployment with mail configured. Every other check sends nothing: the
/// refusal check targets a quote that is not confirmed, which mbe-api refuses
/// before it sends.
///
/// Requires mbe-api at [apiBaseUrl] (default `http://127.0.0.1:8000`, at or
/// after mbe-api spec 024) and an account that may read sales quotes. The
/// `MBE_POS_*` account is the `admin` one. Configure via `--dart-define`, or
/// `--dart-define-from-file=.env`:
///   --dart-define=MBE_POS_USERNAME=...
///   --dart-define=MBE_POS_PASSWORD=...
///   --dart-define=MBE_QUOTE_EMAIL_TO=you@example.com   (optional, sends mail)
///
/// Skipped entirely when credentials aren't provided.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _emailTo = String.fromEnvironment('MBE_QUOTE_EMAIL_TO');

const _canRun = _username != '' && _password != '';
const _skipReason = 'MBE_POS_USERNAME / MBE_POS_PASSWORD were not provided';

void main() {
  late Dio dio;
  late DocumentSourceImpl source;
  late SalesQuoteRepositoryImpl quotes;

  int? anyQuoteId;
  int? confirmedQuoteId;
  int? unsendableQuoteId;

  setUpAll(() async {
    if (!_canRun) return;

    dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _username, password: _password);
    dio.options.headers['Authorization'] = 'Bearer $token';
    source = DocumentSourceImpl(dio);
    quotes = SalesQuoteRepositoryImpl(dio);

    Future<int?> firstWith(SaleStatus? status) async {
      final page = await quotes.listQuotes(status: status, limit: 1);
      return page.items.isEmpty ? null : page.items.first.id;
    }

    confirmedQuoteId = await firstWith(SaleStatus.completed);
    // A draft or a cancelled quote is not sendable; mbe-api refuses either
    // before it sends anything.
    unsendableQuoteId =
        await firstWith(SaleStatus.draft) ??
        await firstWith(SaleStatus.cancelled);
    anyQuoteId = confirmedQuoteId ?? unsendableQuoteId ?? await firstWith(null);
  });

  /// The same document fetched directly, with no client code in between.
  Future<Uint8List> direct(String path) async {
    final response = await dio.get<List<int>>(
      path,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }

  test('the quote document arrives as the exact bytes the server renders, '
      'with the server\'s file name (FR-003, SC-001)', () async {
    final id = anyQuoteId;
    if (id == null) {
      markTestSkipped('this database holds no quote to print');
      return;
    }

    final document = await source.fetch(
      DocumentRef(kind: DocumentKind.salesQuote, recordId: id, title: 'q'),
    );

    expect(String.fromCharCodes(document.bytes.take(5)), '%PDF-');
    expect(
      document.bytes,
      orderedEquals(await direct('/api/v1/sales-quotes/$id/document')),
      reason: 'the client must not alter a byte of the quote',
    );
    expect(document.filename, matches(RegExp(r'^cotizacion-\d{8}\.pdf$')));
  }, skip: _canRun ? null : _skipReason);

  test(
    'a quote that does not exist is refused with the server\'s own wording',
    () async {
      await expectLater(
        () => source.fetch(
          const DocumentRef(
            kind: DocumentKind.salesQuote,
            recordId: 2147483000,
            title: 'q',
          ),
        ),
        throwsA(isA<NotFoundError>()),
      );
    },
    skip: _canRun ? null : _skipReason,
  );

  test('emailing a quote that is not confirmed is refused and sends nothing '
      '(FR-013 notSendable)', () async {
    final id = unsendableQuoteId;
    if (id == null) {
      markTestSkipped('this database holds no draft or cancelled quote');
      return;
    }

    await expectLater(
      () => quotes.email(quoteId: id, recipients: const ['nobody@example.com']),
      throwsA(
        // 409 is the documented answer. A deployment without mail may
        // answer 503 first, which is also a refusal that sends nothing.
        isA<ServerError>().having(
          (e) => e.statusCode,
          'statusCode',
          anyOf(409, 503),
        ),
      ),
    );
  }, skip: _canRun ? null : _skipReason);

  test('a malformed recipient list is refused as a ValidationError, never as a '
      'credit hold (research R4)', () async {
    final id = anyQuoteId;
    if (id == null) {
      markTestSkipped('this database holds no quote');
      return;
    }

    await expectLater(
      () => quotes.email(quoteId: id, recipients: const ['not-an-address']),
      throwsA(isA<ValidationError>()),
    );
  }, skip: _canRun ? null : _skipReason);

  test(
    'a confirmed quote is emailed and the receipt names the recipient '
    '(US2, SC-002)',
    () async {
      final id = confirmedQuoteId;
      if (id == null) {
        markTestSkipped('this database holds no confirmed quote');
        return;
      }

      final receipt = await quotes.email(
        quoteId: id,
        recipients: const [_emailTo],
      );

      expect(
        receipt.recipients.map((r) => r.toLowerCase()),
        contains(_emailTo.toLowerCase()),
      );
    },
    skip: !_canRun
        ? _skipReason
        : _emailTo == ''
        ? 'MBE_QUOTE_EMAIL_TO was not provided; sending a real email is opt-in'
        : null,
  );
}
