import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

Map<String, Object?> _orderJson({
  int deliveryOrderId = 500,
  int fulfillmentType = 0,
  int? shipTo,
  List<Map<String, Object?>>? lines,
}) => {
  'delivery_order_id': deliveryOrderId,
  'facility': 9,
  'customer': 7,
  'ship_to': shipTo,
  'priority': 0,
  'status': 0,
  'fulfillment_type': fulfillmentType,
  'creation_time': '2026-08-05T10:00:00.000Z',
  'modification_time': '2026-08-05T10:00:00.000Z',
  'lines': lines ?? [],
};

Map<String, Object?> _lineJson({int salesOrderDetail = 1, String quantity = '4'}) => {
  'delivery_order_detail_id': 900,
  'sales_order_detail': salesOrderDetail,
  'product': 11,
  'product_code': 'P-11',
  'product_name': 'Widget',
  'quantity': quantity,
  'warehouse': 3,
  // Non-nullable on the response even though a draft destination has not
  // delivered anything yet — omitting them fails deserialization outright.
  'committed_quantity': quantity,
  'delivered_quantity': '0',
  'returned_quantity': '0',
  'open_quantity': quantity,
};

void main() {
  group('create — one call, header and line subset together', () {
    test('sends the whole destination — header and lines — on one POST, with '
        'the quantity as a string arm', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode(_orderJson(lines: [_lineJson()])),
          options.method == 'POST' ? 201 : 200,
          headers: _jsonHeaders,
        );
      });

      await repository.create(
        salesOrder: 42,
        fulfillmentType: FulfillmentType.delivery,
        lines: const [DestinationLineRequest(salesOrderDetail: 1, quantity: '4')],
      );

      final post = _decodeBody(requests.first.data);
      expect(requests.first.method, 'POST');
      expect(post['sales_order'], 42);
      // 1, not 0 — mbe-api#171 renumbered the wire scale (pickup=0,
      // delivery=1, mixed=2), unifying it with `sales_order.fulfillment_intent`.
      expect(post['fulfillment_type'], 1);
      expect((post['lines'] as List).single, {
        'sales_order_detail': 1,
        'quantity': '4',
      });
    });

    test('omitting lines claims everything the sale still owes — the '
        'counter-pickup remainder (FR-036)', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode(_orderJson(fulfillmentType: 0)),
          201,
          headers: _jsonHeaders,
        );
      });

      await repository.create(
        salesOrder: 42,
        fulfillmentType: FulfillmentType.counterPickup,
      );

      final post = _decodeBody(requests.single.data);
      expect(post.containsKey('lines'), isFalse);
      // 0, not 1 — see the renumbering note above.
      expect(post['fulfillment_type'], 0);
    });

    test('the header rides along on the same call (mbe-api#146)', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode(_orderJson(shipTo: 77)),
          201,
          headers: _jsonHeaders,
        );
      });

      final destination = await repository.create(
        salesOrder: 42,
        fulfillmentType: FulfillmentType.delivery,
        shipTo: 77,
        contact: 21,
        comment: 'Leave at the gate',
      );

      expect(
        requests.map((r) => r.method),
        ['POST'],
        reason: 'no follow-up PUT — the create carries the header now',
      );
      final post = _decodeBody(requests.single.data);
      expect(post['ship_to'], 77);
      expect(post['contact'], 21);
      expect(post['comment'], 'Leave at the gate');
      expect(destination.shipTo, 77);
    });

    test('a delivery date picked from the calendar reaches the wire — a '
        'local DateTime must not blow up serialization before the request '
        'is even sent', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode(_orderJson(shipTo: 11)),
          201,
          headers: _jsonHeaders,
        );
      });

      // Exactly what `showDatePicker` hands back: midnight, **local**.
      // built_value's DateTime serializer throws `ArgumentError` on a
      // non-UTC value, and dio surfaces that as a response-less
      // `DioException` — which maps to `NetworkError`, so the cashier sees
      // "couldn't reach the server" for a request that never left the
      // client.
      final picked = DateTime(2026, 8, 17);
      expect(picked.isUtc, isFalse, reason: 'the fixture must be a local date');

      await repository.create(
        salesOrder: 42,
        fulfillmentType: FulfillmentType.delivery,
        shipTo: 11,
        date: picked,
        lines: const [],
      );

      final post = _decodeBody(requests.single.data);
      expect(post['date'], isNotNull);
      expect(
        post['date'],
        contains('2026-08-17'),
        reason: 'the calendar day the cashier picked, not shifted by the '
            'local UTC offset',
      );
    });

    test('a refused create leaves nothing behind to roll back', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode({'detail': 'Address does not belong to the customer'}),
          409,
          headers: _jsonHeaders,
        );
      });

      await expectLater(
        () => repository.create(
          salesOrder: 42,
          fulfillmentType: FulfillmentType.delivery,
          shipTo: 999,
        ),
        throwsA(isA<ServerError>().having((e) => e.statusCode, 'statusCode', 409)),
      );

      expect(
        requests.map((r) => r.method),
        ['POST'],
        reason: 'the destination was never partially created (FR-037)',
      );
    });
  });

  group('addLine — assigning a line to an existing destination (mbe-api#163)', () {
    test('posts the line and returns the updated destination', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode(_orderJson(lines: [_lineJson(salesOrderDetail: 5, quantity: '6')])),
          201,
          headers: _jsonHeaders,
        );
      });

      final destination = await repository.addLine(
        destinationId: 500,
        salesOrderDetail: 5,
        quantity: '6',
      );

      final request = requests.single;
      expect(request.method, 'POST');
      expect(request.path, endsWith('/delivery-orders/500/lines'));
      expect(_decodeBody(request.data), {'sales_order_detail': 5, 'quantity': '6'});
      expect(destination.lines.single.quantity, '6');
    });

    test('a sale line already on this destination is refused with 409, not '
        'folded into the existing row', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Line 5 is already on this delivery order as line 900'}),
          409,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.addLine(destinationId: 500, salesOrderDetail: 5, quantity: '2'),
        throwsA(isA<ServerError>().having((e) => e.statusCode, 'statusCode', 409)),
      );
    });

    test('an over-claim or an unknown/foreign line is refused with 422',
        () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'The sales order line has 2 left to deliver; 6 was requested'}),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.addLine(destinationId: 500, salesOrderDetail: 5, quantity: '6'),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('updateHeader — editing an already-created destination (spec 030)', () {
    test('a successful update returns the changed destination', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode(_orderJson(shipTo: 22, lines: [_lineJson()])),
          200,
          headers: _jsonHeaders,
        );
      });

      final destination = await repository.updateHeader(
        destinationId: 500,
        shipTo: 22,
        contact: 8,
        comment: 'Entregar por la tarde',
      );

      final request = requests.single;
      expect(request.method, 'PUT');
      expect(request.path, endsWith('/delivery-orders/500'));
      expect(
        _decodeBody(request.data),
        {'ship_to': 22, 'contact': 8, 'comment': 'Entregar por la tarde'},
      );
      expect(destination.shipTo, 22);
    });

    test('a non-draft order (mbe-api\'s assert_editable) is refused with '
        '409', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'A delivery order in CONFIRMED can no longer be edited'}),
          409,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.updateHeader(destinationId: 500, shipTo: 22),
        throwsA(isA<ServerError>().having((e) => e.statusCode, 'statusCode', 409)),
      );
    });

    test('a malformed payload is refused with 422', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'priority must be >= 0'}),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.updateHeader(destinationId: 500, shipTo: 22),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('listForSale — filtered by the sale (mbe-api#147)', () {
    test('asks the server for this sale\'s delivery orders and reads each '
        'back in full, because the summary carries no lines', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        if (options.path.endsWith('/delivery-orders')) {
          return ResponseBody.fromString(
            jsonEncode({
              'items': [_summaryJson(500), _summaryJson(501)],
              'total': 2,
            }),
            200,
            headers: _jsonHeaders,
          );
        }
        final id = int.parse(options.path.split('/').last);
        return ResponseBody.fromString(
          jsonEncode(_orderJson(deliveryOrderId: id, lines: [_lineJson()])),
          200,
          headers: _jsonHeaders,
        );
      });

      final destinations = await repository.listForSale(salesOrder: 42);

      expect(requests.first.queryParameters['sales_order'], 42);
      expect(destinations.map((d) => d.id), [500, 501]);
      expect(destinations.first.lines, hasLength(1));
    });

    test('a sale with no destinations yields an empty list', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'items': <Object>[], 'total': 0}),
          200,
          headers: _jsonHeaders,
        ),
      );

      expect(await repository.listForSale(salesOrder: 42), isEmpty);
    });
  });
}

Map<String, Object?> _summaryJson(int id) => {
  'delivery_order_id': id,
  'facility': 9,
  'customer': 7,
  'priority': 0,
  'status': 0,
  'fulfillment_type': 0,
};

Map<String, Object?> _decodeBody(Object? data) => data is String
    ? jsonDecode(data) as Map<String, Object?>
    : data as Map<String, Object?>;

DeliveryOrderRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return DeliveryOrderRepositoryImpl(dio);
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
