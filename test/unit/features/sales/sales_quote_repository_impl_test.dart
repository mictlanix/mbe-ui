import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/sales_quote_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_quote_repository.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

/// `SalesQuoteResponse` DTO-to-entity mapping (spec 040, data-model.md §1)
/// — through the real HTTP round trip, not a hand-built DTO, so a renamed
/// wire field fails here, not only in production (mirrors `sale_mapping_
/// test.dart`'s own rationale).
Map<String, Object?> _quoteJson({
  int salesQuoteId = 30,
  int? serial,
  String status = 'draft',
  bool hasExpired = false,
  List<Map<String, Object?>> lines = const [],
}) => {
  'sales_quote_id': salesQuoteId,
  'facility': 9,
  'serial': serial,
  'salesperson': 100,
  'customer': 7,
  'payment_terms': 0,
  'date': '2026-09-20T00:00:00.000Z',
  'due_date': '2026-10-20T00:00:00.000Z',
  'contact': null,
  'ship_to': null,
  'currency': 0,
  'exchange_rate': '1',
  'comment': null,
  'status': status,
  'has_expired': hasExpired,
  'lines': lines,
  'subtotal': '100.00',
  'tax_total': '16.00',
  'total': '116.00',
};

Map<String, Object?> _lineJson({
  int salesQuoteDetailId = 5,
  String priceAdjustment = '0',
}) => {
  'sales_quote_detail_id': salesQuoteDetailId,
  'product': 11,
  'product_code': 'P-11',
  'product_name': 'Widget',
  'quantity': '2',
  'price': '50.00',
  'price_adjustment': priceAdjustment,
  'discount_rate': '0',
  'tax_rate': '0.16',
  'tax_included': false,
  'currency': 0,
  'exchange_rate': '1',
  'comment': null,
  'subtotal': '100.00',
  'tax_total': '16.00',
  'total': '116.00',
};

void main() {
  group('open — DTO-to-entity mapping (research.md R2)', () {
    test('maps the header, hasExpired, and lines empty by default', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode(_quoteJson(serial: null)),
          201,
          headers: _jsonHeaders,
        );
      });

      final quote = await repository.open(customer: 7, salesperson: 100);

      expect(requests.single.method, 'POST');
      expect(_decodeBody(requests.single.data), {
        'customer': 7,
        'salesperson': 100,
      });
      expect(quote.id, 30);
      expect(quote.facility, 9);
      expect(quote.customer, 7);
      expect(quote.hasExpired, isFalse);
      // Order-only fields have no quote counterpart (data-model.md §1) —
      // never sentinel-filled, always null.
      expect(quote.pointSale, isNull);
      expect(quote.promiseDate, isNull);
      expect(quote.priority, isNull);
      expect(quote.balance, isNull);
      expect(quote.lines, isEmpty);
    });

    test('hasExpired maps true when the server reports it', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_quoteJson(status: 'completed', hasExpired: true)),
          201,
          headers: _jsonHeaders,
        ),
      );

      final quote = await repository.open();
      expect(quote.hasExpired, isTrue);
    });
  });

  group('getById — maps every line, including priceAdjustment', () {
    test('a quote-only field an order line never has', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(
            _quoteJson(
              lines: [
                _lineJson(),
                _lineJson(salesQuoteDetailId: 6, priceAdjustment: '5.00'),
              ],
            ),
          ),
          200,
          headers: _jsonHeaders,
        ),
      );

      final quote = await repository.getById(quoteId: 30);

      expect(quote.lineCount, 2);
      expect(quote.lines.map((l) => l.id), [5, 6]);
      expect(quote.lines.first.priceAdjustment, '0');
      expect(quote.lines.last.priceAdjustment, '5.00');
      // Order-only line fields have no quote counterpart.
      expect(quote.lines.first.cost, isNull);
      expect(quote.lines.first.warehouse, isNull);
      expect(quote.lines.first.unit, isNull);
    });
  });

  group('addLine — sends priceAdjustment as a wire-value string', () {
    test('quantity, price and priceAdjustment all go through the string arm', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode(_quoteJson(lines: [_lineJson(priceAdjustment: '3.50')])),
          201,
          headers: _jsonHeaders,
        );
      });

      final quote = await repository.addLine(
        quoteId: 30,
        product: 11,
        quantity: '2',
        price: '50.00',
        priceAdjustment: '3.50',
        discountRate: '0',
      );

      final body = _decodeBody(requests.single.data);
      expect(body['product'], 11);
      expect(body['quantity'], '2');
      expect(body['price'], '50.00');
      expect(body['price_adjustment'], '3.50');
      expect(body['discount_rate'], '0');
      expect(quote.lines.single.priceAdjustment, '3.50');
    });

    test('omitting priceAdjustment leaves it off the request entirely', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode(_quoteJson(lines: [_lineJson()])),
          201,
          headers: _jsonHeaders,
        );
      });

      await repository.addLine(quoteId: 30, product: 11);

      expect(
        _decodeBody(requests.single.data).containsKey('price_adjustment'),
        isFalse,
        reason: 'an omitted value means "server default", not zero',
      );
    });
  });

  group('convert — maps the response as a SALES ORDER, not a quote', () {
    test('the returned Sale carries the order-only fields a quote lacks', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'sales_order_id': 99,
            'facility': 9,
            'point_sale': 3,
            'salesperson': 100,
            'customer': 7,
            'customer_name': null,
            'payment_terms': 0,
            'date': '2026-09-20T00:00:00.000Z',
            'due_date': '2026-09-27T00:00:00.000Z',
            'contact': null,
            'recipient': null,
            'recipient_name': null,
            'priority': 1,
            'comment': null,
            'currency': 0,
            'exchange_rate': '1',
            'ship_to': null,
            'promise_date': '2026-09-22T00:00:00.000Z',
            'status': 'draft',
            'lines': <Object>[],
            'subtotal': '100.00',
            'tax_total': '16.00',
            'total': '116.00',
            'balance': '116.00',
            'sales_quote': 30,
          }),
          201,
          headers: _jsonHeaders,
        ),
      );

      final order = await repository.convert(quoteId: 30);

      expect(order.id, 99);
      // Present, unlike a quote's own mapping — proof this went through
      // `Sale.fromResponse`, not `Sale.fromQuoteResponse`
      // (contracts/sales-quote-repository.md §1).
      expect(order.pointSale, 3);
      expect(order.promiseDate, isNotNull);
      expect(order.priority, isNotNull);
      expect(order.balance, '116.00');
    });
  });

  group('error mapping (contracts/sales-quote-repository.md §2)', () {
    test('a 422 with a plain-string detail maps to CreditHoldError, not a '
        'silently empty ValidationError — this is what mapDioException '
        'alone would lose', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'No point of sale is configured for your user'}),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.convert(quoteId: 30),
        throwsA(
          isA<CreditHoldError>().having(
            (e) => e.message,
            'message',
            'No point of sale is configured for your user',
          ),
        ),
      );
    });

    test('a 409 with a map-shaped detail keeps its message, via the shared '
        'interceptor mapping — no special handling needed here', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': {'message': 'Only a confirmed quote can be converted'},
          }),
          409,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.convert(quoteId: 30),
        throwsA(
          isA<ServerError>()
              .having((e) => e.statusCode, 'statusCode', 409)
              .having(
                (e) => e.message,
                'message',
                'Only a confirmed quote can be converted',
              ),
        ),
      );
    });

    test('a 409 with a plain-string detail keeps its message too', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Quote has expired and cannot be converted'}),
          409,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.convert(quoteId: 30),
        throwsA(
          isA<ServerError>()
              .having((e) => e.statusCode, 'statusCode', 409)
              .having(
                (e) => e.message,
                'message',
                'Quote has expired and cannot be converted',
              ),
        ),
      );
    });

    test('open and updateHeader carry the same 422 credit-hold recovery as '
        'convert', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Customer is on credit hold'}),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.open(),
        throwsA(isA<CreditHoldError>()),
      );
      await expectLater(
        () => repository.updateHeader(quoteId: 30, comment: 'x'),
        throwsA(isA<CreditHoldError>()),
      );
    });
  });
}

Map<String, Object?> _decodeBody(Object? data) => data is String
    ? jsonDecode(data) as Map<String, Object?>
    : data as Map<String, Object?>;

SalesQuoteRepository _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return SalesQuoteRepositoryImpl(dio);
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
