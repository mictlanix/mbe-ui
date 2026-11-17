import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

Map<String, Object?> _orderJson({
  int id = 500,
  int status = 0,
  int type = 1,
  List<Map<String, Object?>>? lines,
}) => {
  'delivery_order_id': id,
  'facility': 9,
  'serial': null,
  'customer': 7,
  'sales_orders': [42],
  'priority': 0,
  'status': status,
  'fulfillment_type': type,
  'creation_time': '2026-08-05T10:00:00.000',
  'modification_time': '2026-08-05T10:00:00.000',
  'lines': lines ?? [],
  'customer_display_name': 'Ferretería Acme',
  'ship_to_label': 'Av. Juárez 120, Centro, Puebla',
  'facility_name': 'Matriz',
};

Map<String, Object?> _lineJson() => {
  'delivery_order_detail_id': 900,
  'sales_order_detail': 1,
  'product': 11,
  'product_code': 'P-11',
  'product_name': 'Widget',
  'warehouse': 3,
  'quantity': '4.5',
  'committed_quantity': '4',
  'delivered_quantity': '1.25',
  'returned_quantity': '0',
  'open_quantity': '3.25',
};

Map<String, Object?> _summaryJson(int id, int status, int type) => {
  'delivery_order_id': id,
  'facility': 9,
  'customer': 7,
  'priority': 0,
  'status': status,
  'fulfillment_type': type,
  // A counter pickup (type 0) has no ship-to label.
  'customer_display_name': 'Ferretería Acme',
  'ship_to_label': type == 0 ? null : 'Av. Juárez 120, Centro, Puebla',
  'facility_name': 'Matriz',
};

final _png = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, //
]);

void main() {
  test('list maps number0..number10 statuses and both types, and sends '
      'the filter without mine', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((options) async {
      requests.add(options);
      return ResponseBody.fromString(
        jsonEncode({
          'items': [
            for (var s = 0; s <= 10; s++)
              _summaryJson(s + 1, s, s.isEven ? 0 : 1),
          ],
          'total': 11,
        }),
        200,
        headers: _jsonHeaders,
      );
    });

    final page = await repository.list(
      statuses: [DeliveryOrderStatus.cancelled, DeliveryOrderStatus.draft],
      customer: 7,
      facility: 9,
      type: FulfillmentType.delivery,
      salesOrder: 42,
      dateFrom: DateTime(2026, 8, 1),
      dateTo: DateTime(2026, 8, 31),
      search: 'Acme',
      skip: 20,
    );

    final query = requests.single.queryParameters;
    // `status` repeats (mbe-api#312).
    expect(requests.single.uri.queryParametersAll['status'], ['10', '0']);
    expect(query['customer'], 7);
    expect(query['facility'], 9);
    expect(query['fulfillment_type'], 1);
    expect(query['sales_order'], 42);
    expect(query['date_from'], '2026-08-01T00:00:00.000');
    expect(query['date_to'], '2026-08-31T23:59:59.999');
    expect(query['search'], 'Acme');
    expect(query['skip'], 20);
    expect(query['limit'], 20);
    expect(query.containsKey('mine'), isFalse);
    expect(page.total, 11);
    expect(page.items.map((i) => i.status), DeliveryOrderStatus.values);
    expect(page.items[0].type, FulfillmentType.counterPickup);
    expect(page.items[1].type, FulfillmentType.delivery);
    expect(page.items[0].serial, isNull);
    // The server-joined names (mbe-api#324).
    expect(page.items[1].customerName, 'Ferretería Acme');
    expect(page.items[1].shipToLabel, 'Av. Juárez 120, Centro, Puebla');
    expect(page.items[1].facilityName, 'Matriz');
    expect(page.items[0].shipToLabel, isNull);
  });

  test('getById parses the four quantities and open as Decimal, with a null '
      'serial', () async {
    final repository = _repositoryWith(
      (options) async => ResponseBody.fromString(
        jsonEncode(_orderJson(lines: [_lineJson()])),
        200,
        headers: _jsonHeaders,
      ),
    );

    final order = await repository.getById(500);

    expect(order.serial, isNull);
    expect(order.isDraft, isTrue);
    expect(order.salesOrderIds, [42]);
    expect(order.customerName, 'Ferretería Acme');
    expect(order.shipToLabel, 'Av. Juárez 120, Centro, Puebla');
    expect(order.facilityName, 'Matriz');
    final line = order.lines.single;
    expect(line.quantity, Decimal.parse('4.5'));
    expect(line.committed, Decimal.parse('4'));
    expect(line.delivered, Decimal.parse('1.25'));
    expect(line.returned, Decimal.zero);
    expect(line.open, Decimal.parse('3.25'));
  });

  test('events maps a null from_status on the creation event', () async {
    final repository = _repositoryWith(
      (options) async => ResponseBody.fromString(
        jsonEncode([
          {
            'delivery_order_event_id': 1,
            'from_status': null,
            'to_status': 0,
            'employee': 5,
            'event_time': '2026-08-05T10:00:00.000',
          },
          {
            'delivery_order_event_id': 2,
            'from_status': 0,
            'to_status': 10,
            'employee': 5,
            'event_time': '2026-08-05T11:00:00.000',
            'reason': 'Duplicado',
          },
        ]),
        200,
        headers: _jsonHeaders,
      ),
    );

    final events = await repository.events(500);

    expect(events.first.from, isNull);
    expect(events.first.to, DeliveryOrderStatus.draft);
    expect(events.last.from, DeliveryOrderStatus.draft);
    expect(events.last.to, DeliveryOrderStatus.cancelled);
    expect(events.last.reason, 'Duplicado');
  });

  test('confirmPickup sends a multipart request', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((options) async {
      requests.add(options);
      return ResponseBody.fromString(
        jsonEncode(_orderJson(status: 4, type: 0)),
        200,
        headers: _jsonHeaders,
      );
    });

    final order = await repository.confirmPickup(
      id: 500,
      receiverName: 'Ana',
      receiverIdShown: 'INE 123',
      bytes: _png,
      filename: 'id.png',
    );

    final request = requests.single;
    expect(request.method, 'POST');
    expect(request.path, endsWith('/delivery-orders/500/pickup'));
    expect(request.data, isA<FormData>());
    final form = request.data as FormData;
    expect(form.fields.map((f) => f.key), [
      'receiver_name',
      'receiver_id_shown',
    ]);
    expect(form.files.single.value.filename, 'id.png');
    expect(order.status, DeliveryOrderStatus.pickedUp);
    expect(order.isPickup, isTrue);
    expect(order.isTerminal, isTrue);
  });

  test('proofImage returns PNG bytes and rejects anything else', () async {
    var body = _png;
    final repository = _repositoryWith(
      (options) async => ResponseBody.fromBytes(body, 200),
    );

    expect(await repository.proofImage(500), _png);

    body = Uint8List.fromList(utf8.encode('<html>login</html>'));
    await expectLater(
      () => repository.proofImage(500),
      throwsA(isA<ServerError>()),
    );
  });

  test('each write returns the mapped order', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((options) async {
      requests.add(options);
      return ResponseBody.fromString(
        jsonEncode(_orderJson(id: 500, lines: [_lineJson()])),
        200,
        headers: _jsonHeaders,
      );
    });

    final results = [
      await repository.updateHeader(
        id: 500,
        priority: 2,
        shipTo: 22,
        comment: 'x',
      ),
      await repository.addLine(id: 500, salesOrderDetail: 1, quantity: '2'),
      await repository.updateLine(id: 500, lineId: 900, quantity: '3'),
      await repository.removeLine(id: 500, lineId: 900),
      await repository.confirm(500),
      await repository.cancel(id: 500, reason: 'Duplicado'),
      await repository.requeue(500),
      await repository.markReadyForPickup(500),
    ];

    expect(results.map((o) => o.id), everyElement(500));
    expect(results.every((o) => o.lines.length == 1), isTrue);
    expect(
      requests.map(
        (r) => '${r.method} ${r.path.split('/delivery-orders').last}',
      ),
      [
        'PUT /500',
        'POST /500/lines',
        'PUT /500/lines/900',
        'DELETE /500/lines/900',
        'POST /500/confirm',
        'POST /500/cancel',
        'POST /500/requeue',
        'POST /500/ready-for-pickup',
      ],
    );
    final header = requests[0].data;
    final headerJson = header is String ? jsonDecode(header) : header;
    expect(headerJson['priority'], 2);
    expect(headerJson['ship_to'], 22);
    expect(headerJson['comment'], 'x');
    final body = requests[1].data;
    expect(body is String ? jsonDecode(body) : body, {
      'sales_order_detail': 1,
      'quantity': '2',
    });
  });

  group('approval (spec 062)', () {
    test('approvalQueue sends skip and limit and no facility, and maps the '
        'page with its total', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode({
            'items': [_summaryJson(31, 1, 1), _summaryJson(32, 1, 0)],
            'total': 23,
          }),
          200,
          headers: _jsonHeaders,
        );
      });

      final page = await repository.approvalQueue(skip: 20, limit: 20);

      expect(requests.single.method, 'GET');
      expect(requests.single.path, endsWith('/delivery-orders/approval'));
      expect(requests.single.queryParameters, {'skip': 20, 'limit': 20});
      expect(page.total, 23);
      expect(page.items.map((o) => o.id), [31, 32]);
      expect(
        page.items.map((o) => o.status),
        everyElement(DeliveryOrderStatus.pendingApproval),
      );
      expect(page.items.map((o) => o.type), [
        FulfillmentType.delivery,
        FulfillmentType.counterPickup,
      ]);
    });

    test('approve and reject hit the approval paths and map the order, and '
        'reject sends the reason as its body', () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        final approved = options.path.endsWith('/approve');
        return ResponseBody.fromString(
          jsonEncode(_orderJson(id: 500, status: approved ? 5 : 0)),
          200,
          headers: _jsonHeaders,
        );
      });

      final approved = await repository.approve(500);
      final rejected = await repository.reject(
        id: 500,
        reason: 'Dirección equivocada',
      );

      expect(approved.status, DeliveryOrderStatus.inPreparation);
      expect(rejected.status, DeliveryOrderStatus.draft);
      expect(
        requests.map(
          (r) => '${r.method} ${r.path.split('/delivery-orders').last}',
        ),
        ['POST /approval/500/approve', 'POST /approval/500/reject'],
      );
      final body = requests[1].data;
      expect(body is String ? jsonDecode(body) : body, {
        'reason': 'Dirección equivocada',
      });
    });

    test('a 409 answers an AppError that carries '
        'delivery_order.not_pending_approval', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': 'Only an order awaiting approval can be approved',
            'code': 'delivery_order.not_pending_approval',
            'params': {'status': 'APPROVED', 'action': 'approve'},
          }),
          409,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        repository.approve(500),
        throwsA(
          isA<AppError>().having(
            (e) => e.problem?.code,
            'code',
            api.ErrorCode.deliveryOrderPeriodNotPendingApproval,
          ),
        ),
      );
    });
  });
}

DeliveryOrderAdminRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return DeliveryOrderAdminRepositoryImpl(dio);
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
