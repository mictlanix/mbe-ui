import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/credit_note_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

Map<String, dynamic> _noteJson({
  required int id,
  int customer = 10653,
  int payment = 0,
  String amount = '27.0000',
  String remaining = '3',
  String? date,
}) => {
  'credit_note_id': id,
  'customer': customer,
  'sales_order': 343533,
  'customer_refund': 9605,
  'customer_payment': payment == 0 ? 300000 + id : payment,
  'facility': 51,
  'amount': amount,
  'refunded': '0.000000',
  'refunded_to_customer': false,
  'remaining': remaining,
  'cash_session': null,
  'date': date ?? '2026-09-29T12:55:20',
};

ResponseBody _page(List<Map<String, dynamic>> items, {int? total}) =>
    ResponseBody.fromString(
      jsonEncode({'items': items, 'total': total ?? items.length}),
      200,
      headers: _jsonHeaders,
    );

void main() {
  group('list', () {
    test(
      'forwards customer, skip and limit, with open_only off by default',
      () async {
        late RequestOptions seen;
        final repository = _repositoryWith((options) async {
          seen = options;
          return _page([_noteJson(id: 990)], total: 103);
        });

        final page = await repository.list(
          customerId: 10653,
          skip: 40,
          limit: 20,
        );

        expect(seen.path, endsWith('/api/v1/credit-notes'));
        expect(seen.queryParameters['customer'], 10653);
        expect(seen.queryParameters['skip'], 40);
        expect(seen.queryParameters['limit'], 20);
        expect(seen.queryParameters['open_only'], isNot(true));
        // The facility is the server's default, the caller's own (mbe-api
        // spec 034 FR-013): never named here.
        expect(seen.queryParameters.containsKey('facility'), isFalse);
        expect(page.total, 103);
        expect(page.items.single.id, 990);
      },
    );

    test('openOnly asks the server for the spendable notes', () async {
      late RequestOptions seen;
      final repository = _repositoryWith((options) async {
        seen = options;
        return _page(const []);
      });

      await repository.list(openOnly: true);

      expect(seen.queryParameters['open_only'], true);
    });

    test('keeps the server\'s figures exactly as sent: issued is the '
        'amount (FR-015)', () async {
      final repository = _repositoryWith(
        (options) async => _page([
          _noteJson(id: 1, amount: '9505.0000', remaining: '15.0000'),
        ]),
      );

      final note = (await repository.list()).items.single;

      expect(note.issued, '9505.0000');
      expect(note.remaining, '15.0000');
      expect(note.isOpen, isTrue);
    });

    test('a null body becomes AppError.server', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 200),
      );

      await expectLater(() => repository.list(), throwsA(isA<AppError>()));
    });

    test('a 404 becomes AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Credit note not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.list(),
        throwsA(const AppError.notFound('Credit note not found')),
      );
    });
  });

  group('listSpendable', () {
    test('asks for open notes only, reads every page, oldest first', () async {
      final seen = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        seen.add(options);
        return options.queryParameters['skip'] == 0
            ? _page([
                _noteJson(id: 3, date: '2026-09-03T10:00:00'),
                _noteJson(id: 2, date: '2026-09-02T10:00:00'),
              ], total: 3)
            : _page([_noteJson(id: 1, date: '2026-09-01T10:00:00')], total: 3);
      });

      final notes = await repository.listSpendable(10653);

      expect(seen.map((o) => o.queryParameters['skip']), [0, 2]);
      expect(seen.every((o) => o.queryParameters['open_only'] == true), isTrue);
      expect(seen.every((o) => o.queryParameters['customer'] == 10653), isTrue);
      expect(notes.map((n) => n.id), [1, 2, 3]);
    });

    test('stops on an empty page even when total says there is more', () async {
      var calls = 0;
      final repository = _repositoryWith((options) async {
        calls++;
        return _page(const [], total: 50);
      });

      expect(await repository.listSpendable(10653), isEmpty);
      expect(calls, 1);
    });
  });

  group('findByPayment', () {
    test('asks the server for that backing payment, in one request', () async {
      final seen = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        seen.add(options);
        return _page([_noteJson(id: 5, payment: 300743)]);
      });

      final note = await repository.findByPayment(300743);

      expect(note?.id, 5);
      expect(seen, hasLength(1));
      expect(seen.single.queryParameters['customer_payment'], 300743);
      expect(seen.single.queryParameters.containsKey('customer'), isFalse);
    });

    test('is null when that payment backs no note', () async {
      final repository = _repositoryWith((options) async => _page(const []));

      expect(await repository.findByPayment(9), isNull);
    });
  });
}

CreditNoteRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return CreditNoteRepositoryImpl(dio);
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
