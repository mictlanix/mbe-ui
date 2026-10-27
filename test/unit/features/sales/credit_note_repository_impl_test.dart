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
  String refunded = '27.000000',
  String remaining = '3',
  String? date,
}) => {
  'credit_note_id': id,
  'customer': customer,
  'sales_order': 343533,
  'customer_refund': 9605,
  'customer_payment': payment == 0 ? 300000 + id : payment,
  'refunded': refunded,
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
      'forwards customer, skip and limit, and never turns open_only on',
      () async {
        late RequestOptions seen;
        final repository = _repositoryWith((options) async {
          seen = options;
          return _page([_noteJson(id: 990)], total: 984);
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
        // mbe-api#278: open_only pages before it filters, so it is never
        // turned on. The generated client sends its default, false.
        expect(seen.queryParameters['open_only'], isNot(true));
        expect(page.total, 984);
        expect(page.items.single.id, 990);
      },
    );

    test('keeps the server\'s figures exactly as sent (FR-015)', () async {
      final repository = _repositoryWith(
        (options) async =>
            _page([_noteJson(id: 1, refunded: '0.000000', remaining: '0')]),
      );

      final note = (await repository.list()).items.single;

      expect(note.issued, '0.000000');
      expect(note.remaining, '0');
      expect(note.isOpen, isFalse);
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

  group('listForCustomer', () {
    test('reads a second page when total exceeds one, oldest first', () async {
      final skips = <Object?>[];
      final repository = _repositoryWith((options) async {
        skips.add(options.queryParameters['skip']);
        return options.queryParameters['skip'] == 0
            ? _page([
                _noteJson(id: 3, date: '2026-09-03T10:00:00'),
                _noteJson(id: 2, date: '2026-09-02T10:00:00'),
              ], total: 3)
            : _page([_noteJson(id: 1, date: '2026-09-01T10:00:00')], total: 3);
      });

      final notes = await repository.listForCustomer(10653);

      expect(skips, [0, 2]);
      expect(notes.map((n) => n.id), [1, 2, 3]);
    });

    test('stops on an empty page even when total says there is more', () async {
      var calls = 0;
      final repository = _repositoryWith((options) async {
        calls++;
        return _page(const [], total: 50);
      });

      expect(await repository.listForCustomer(10653), isEmpty);
      expect(calls, 1);
    });
  });

  group('findByPayment', () {
    test('returns the match from page 1 without reading page 2', () async {
      var calls = 0;
      final repository = _repositoryWith((options) async {
        calls++;
        return _page([
          _noteJson(id: 5, payment: 300743),
          _noteJson(id: 4, payment: 300700),
        ], total: 250);
      });

      final note = await repository.findByPayment(
        customerPaymentId: 300743,
        customerId: 1,
      );

      expect(note?.id, 5);
      expect(calls, 1);
    });

    test('reads page 2 when page 1 holds no match', () async {
      final skips = <Object?>[];
      final repository = _repositoryWith((options) async {
        skips.add(options.queryParameters['skip']);
        return options.queryParameters['skip'] == 0
            ? _page([_noteJson(id: 5, payment: 1)], total: 2)
            : _page([_noteJson(id: 4, payment: 300743)], total: 2);
      });

      final note = await repository.findByPayment(
        customerPaymentId: 300743,
        customerId: 1,
      );

      expect(note?.id, 4);
      expect(skips, [0, 1]);
    });

    test('returns null when the customer holds no such note', () async {
      final repository = _repositoryWith(
        (options) async => _page([_noteJson(id: 5, payment: 1)], total: 1),
      );

      expect(
        await repository.findByPayment(customerPaymentId: 9, customerId: 1),
        isNull,
      );
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
