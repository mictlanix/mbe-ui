import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

/// `listOrders` (spec 029 FR-006–FR-011, contracts/mbe-api-sales-orders.md
/// §1) through the **real** generated client with a fake HTTP adapter,
/// mirroring `sales_order_list_open_test.dart`'s pattern — what matters here
/// is exactly which query parameters reach the wire, which a mocked
/// repository can't show.
const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('listOrders query parameters', () {
    test('every parameter reaches the wire when supplied', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode({'items': <Object?>[], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.listOrders(
        mine: true,
        facility: 9,
        salesperson: 100,
        status: SaleStatus.draft,
        dateFrom: DateTime(2026, 8, 1),
        dateTo: DateTime(2026, 8, 31),
        search: 'Acme',
        skip: 20,
        limit: 20,
      );

      expect(requests, hasLength(1));
      final query = requests.single.queryParameters;
      expect(query['mine'], true);
      expect(query['facility'], 9);
      expect(query['salesperson'], 100);
      expect(query['status'], 'draft');
      expect(query['date_from'], '2026-08-01T00:00:00.000Z');
      expect(query['date_to'], '2026-08-31T23:59:59.999Z');
      expect(query['search'], 'Acme');
      expect(query['skip'], 20);
      expect(query['limit'], 20);
    });

    test('omitting facility sends no facility param at all — the server '
        'defaults to the caller\'s own facility (FR-006)', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode({'items': <Object?>[], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.listOrders(mine: true);

      final query = requests.single.queryParameters;
      expect(query.containsKey('facility'), isFalse);
      expect(query.containsKey('salesperson'), isFalse);
      expect(query.containsKey('status'), isFalse);
      expect(query.containsKey('date_from'), isFalse);
      expect(query.containsKey('date_to'), isFalse);
      expect(query.containsKey('search'), isFalse);
    });

    test('mine defaults to false when not passed', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode({'items': <Object?>[], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.listOrders();

      expect(requests.single.queryParameters['mine'], false);
    });

    test('OpenSalePage.total round-trips from the response', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_summaryJson(id: 337427), _summaryJson(id: 337426)],
            'total': 2,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final page = await repository.listOrders(mine: true);

      expect(page.total, 2);
      expect(page.items.map((o) => o.id), [337427, 337426]);
    });
  });
}

Map<String, Object?> _summaryJson({required int id}) => {
  'sales_order_id': id,
  'serial': null,
  'customer': 1,
  'customer_name': null,
  'customer_display_name': 'PÚBLICO EN GENERAL',
  'salesperson': 100,
  'date': '2026-08-18T00:00:00.000Z',
  'due_date': '2026-08-18T00:00:00.000Z',
  'currency': 0,
  'status': 'draft',
  'total': '17962.00',
  'balance': '17962.00',
};

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
