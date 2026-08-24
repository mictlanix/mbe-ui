import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

/// The five header parameters spec 029 adds to `updateHeader` — `promiseDate`,
/// `salesperson`, `priority`, `comment`, `recipient` — through the real
/// generated client with a fake HTTP adapter, so what actually reaches the
/// wire is what's asserted, not what a mock was told to expect
/// (contracts/mbe-api-sales-orders.md §3).
const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('updateHeader — new back-office fields', () {
    test('every new field reaches the request body', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode(_saleJson()),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.updateHeader(
        saleId: 42,
        promiseDate: DateTime.utc(2026, 8, 20),
        salesperson: 100,
        priority: Priority.high,
        comment: 'Entregar en bodega 2',
        recipient: 'XAXX010101000',
      );

      expect(requests, hasLength(1));
      expect(requests.single.method, 'PUT');
      final body = _decodeBody(requests.single.data);
      expect(body['promise_date'], '2026-08-20T00:00:00.000Z');
      expect(body['salesperson'], 100);
      // Priority.high = 2 (mbe-api LOW=0, NORMAL=1, HIGH=2, CRITICAL=3).
      expect(body['priority'], 2);
      expect(body['comment'], 'Entregar en bodega 2');
      expect(body['recipient'], 'XAXX010101000');
    });

    test('unset fields are absent from the request body — a partial update '
        'stays partial', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode(_saleJson()),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.updateHeader(saleId: 42, priority: Priority.critical);

      final body = _decodeBody(requests.single.data);
      expect(body.containsKey('promise_date'), isFalse);
      expect(body.containsKey('salesperson'), isFalse);
      expect(body.containsKey('comment'), isFalse);
      expect(body.containsKey('recipient'), isFalse);
      expect(body['priority'], 3);
    });

    test('no request ever carries a due date — it is server-derived and '
        'SalesOrderUpdate has no field for it', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode(_saleJson()),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.updateHeader(
        saleId: 42,
        promiseDate: DateTime.utc(2026, 8, 20),
        priority: Priority.normal,
        comment: 'test',
        recipient: 'XAXX010101000',
        salesperson: 100,
      );

      final body = _decodeBody(requests.single.data);
      expect(body.containsKey('due_date'), isFalse);
    });
  });
}

Map<String, Object?> _saleJson() => {
  'sales_order_id': 42,
  'serial': null,
  'facility': 9,
  'point_sale': 3,
  'salesperson': 100,
  'customer': 7,
  'customer_name': null,
  'payment_terms': 0,
  'date': '2026-08-05T00:00:00.000Z',
  'promise_date': '2026-08-05T00:00:00.000Z',
  'due_date': '2026-08-05T00:00:00.000Z',
  'contact': null,
  'ship_to': null,
  'recipient': null,
  'recipient_name': null,
  'currency': 0,
  'exchange_rate': '1',
  'priority': 1,
  'comment': null,
  'fulfillment_intent': null,
  'status': 'draft',
  'lines': <Object?>[],
  'subtotal': '0',
  'tax_total': '0',
  'total': '0',
  'balance': '0',
};

Map<String, Object?> _decodeBody(Object? data) => data is String
    ? jsonDecode(data) as Map<String, Object?>
    : data as Map<String, Object?>;

SalesOrderRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return SalesOrderRepositoryImpl(dio);
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
