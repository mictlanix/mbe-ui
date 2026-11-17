import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_transfer_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

Map<String, Object?> _transferJson({
  int id = 412,
  String status = 'draft',
  int? serial,
  Object? lines,
  String? comment,
}) => {
  'inventory_transfer_id': id,
  'facility': 2,
  'warehouse': 3,
  'warehouse_to': 4,
  'serial': serial,
  'status': status,
  'comment': comment,
  'creator': 5,
  'updater': 5,
  'creation_time': '2026-11-16T10:02:00.000',
  'modification_time': '2026-11-16T10:02:00.000',
  'lines': lines,
};

Map<String, Object?> _lineJson({
  String quantity = '8',
  String received = '0',
  String outstanding = '0',
}) => {
  'transfer_detail_id': 900,
  'product': 7,
  'product_code': 'A-100',
  'product_name': 'Tornillo',
  'quantity': quantity,
  'quantity_received': received,
  'quantity_outstanding': outstanding,
};

ResponseBody _ok(Object? json) =>
    ResponseBody.fromString(jsonEncode(json), 200, headers: _jsonHeaders);

void main() {
  test(
    'list sends the status as its wire value and maps every state',
    () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return _ok({
          'items': [
            for (final (i, status) in [
              'draft',
              'in_transit',
              'received',
              'cancelled',
            ].indexed)
              {
                'inventory_transfer_id': i + 1,
                'facility': 2,
                'warehouse': 3,
                'warehouse_to': 4,
                'serial': status == 'draft' ? null : 77,
                'status': status,
                'creator': 5,
                'creation_time': '2026-11-16T10:02:00.000',
              },
          ],
          'total': 41,
        });
      });

      final page = await repository.list(
        status: InventoryTransferStatus.inTransit,
        warehouseId: 3,
        skip: 40,
        limit: 20,
      );

      expect(requests.single.queryParameters, {
        'status': 'in_transit',
        'warehouse': 3,
        'skip': 40,
        'limit': 20,
      });
      expect(page.total, 41);
      expect(page.pageIndex, 2);
      expect(page.items.map((r) => r.status), InventoryTransferStatus.values);
      expect(page.items.first.serial, isNull);
      expect(page.items.first.warehouseToId, 4);
    },
  );

  test('a draft maps with no serial and an empty note as none', () async {
    final repository = _repositoryWith(
      (options) async => _ok(_transferJson(comment: '', lines: [_lineJson()])),
    );

    final transfer = await repository.get(412);

    expect(transfer.comment, isNull);
    expect(transfer.serial, isNull);
    expect(transfer.isDraft, isTrue);
    expect(transfer.isDispatched, isFalse);
    expect(transfer.lines.single.quantity, Decimal.parse('8'));
    expect(transfer.outstandingLines, isEmpty);
  });

  test('an in-transit transfer with a partial receipt keeps all three '
      'quantities', () async {
    final repository = _repositoryWith(
      (options) async => _ok(
        _transferJson(
          status: 'in_transit',
          serial: 77,
          comment: 'Urgente',
          lines: [
            _lineJson(quantity: '8.5', received: '3', outstanding: '5.5'),
          ],
        ),
      ),
    );

    final transfer = await repository.get(412);

    expect(transfer.isInTransit, isTrue);
    expect(transfer.isDispatched, isTrue);
    expect(transfer.comment, 'Urgente');
    final line = transfer.lines.single;
    expect(line.quantity, Decimal.parse('8.5'));
    expect(line.quantityReceived, Decimal.parse('3'));
    expect(line.quantityOutstanding, Decimal.parse('5.5'));
    expect(transfer.outstandingLines, [line]);
  });

  test('a legacy-style received transfer and a null lines list', () async {
    final transfer = await _repositoryWith(
      (options) async => _ok(_transferJson(status: 'received', serial: 9)),
    ).get(412);

    expect(transfer.status, InventoryTransferStatus.received);
    expect(transfer.isDispatched, isTrue);
    expect(transfer.lines, isEmpty);
  });

  test('line writes send the quantity as a decimal string', () async {
    final bodies = <Object?>[];
    final repository = _repositoryWith((options) async {
      bodies.add(options.data);
      return _ok(_transferJson());
    });

    await repository.addLine(412, productId: 7, quantity: Decimal.parse('2.5'));
    await repository.updateLine(412, 900, quantity: Decimal.parse('3'));
    await repository.addSalesOrderItems(412, salesOrderId: 61);

    expect(_decoded(bodies[0]), {'product': 7, 'quantity': '2.5'});
    expect(_decoded(bodies[1]), {'quantity': '3'});
    expect(_decoded(bodies[2]), {'sales_order': 61});
  });

  test('create and updateHeader send only the fields given', () async {
    final bodies = <Object?>[];
    final repository = _repositoryWith((options) async {
      bodies.add(options.data);
      return _ok(_transferJson());
    });

    await repository.updateHeader(412, comment: 'Nota');
    await repository.updateHeader(412, warehouseId: 5);
    await repository.updateHeader(412, warehouseToId: 6);
    await repository.updateHeader(412, clearComment: true);
    await repository.create(warehouseId: 3, warehouseToId: 4, comment: 'Hola');

    expect(_decoded(bodies[0]), {'comment': 'Nota'});
    expect(_decoded(bodies[1]), {'warehouse': 5});
    expect(_decoded(bodies[2]), {'warehouse_to': 6});
    expect(_decoded(bodies[3]), {'comment': ''});
    expect(_decoded(bodies[4]), {
      'warehouse': 3,
      'warehouse_to': 4,
      'comment': 'Hola',
    });
  });

  test('receive without lines sends no body, with lines sends them', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((options) async {
      requests.add(options);
      return _ok(_transferJson(status: 'in_transit', serial: 77));
    });

    await repository.receive(412);
    await repository.receive(
      412,
      lines: {900: Decimal.parse('2.5'), 901: Decimal.zero},
    );

    expect(requests[0].path, endsWith('/412/receive'));
    expect(requests[0].data, isNull);
    expect(_decoded(requests[1].data), {
      'lines': [
        {'line_id': 900, 'quantity': '2.5'},
        {'line_id': 901, 'quantity': '0'},
      ],
    });
  });

  test('dispatch, close and cancel post to their endpoints', () async {
    final paths = <String>[];
    final repository = _repositoryWith((options) async {
      paths.add('${options.method} ${options.path}');
      return _ok(_transferJson());
    });

    await repository.dispatch(412);
    await repository.close(412);
    await repository.cancel(412);
    await repository.removeLine(412, 900);

    expect(paths, [
      'POST /api/v1/inventory-transfers/412/dispatch',
      'POST /api/v1/inventory-transfers/412/close',
      'POST /api/v1/inventory-transfers/412/cancel',
      'DELETE /api/v1/inventory-transfers/412/lines/900',
    ]);
  });

  test('inTransit sends the facility and maps both lists', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((options) async {
      requests.add(options);
      return _ok({
        'facility': 2,
        'products': [
          {
            'product': 7,
            'product_code': 'A-100',
            'product_name': 'Tornillo',
            'quantity': '5.5',
          },
        ],
        'lines': [
          {
            'inventory_transfer_id': 412,
            'serial': 77,
            'warehouse': 3,
            'warehouse_to': 4,
            'transfer_detail_id': 900,
            'product': 7,
            'product_code': 'A-100',
            'product_name': 'Tornillo',
            'quantity_outstanding': '5.5',
          },
        ],
      });
    });

    final view = await repository.inTransit(facilityId: 2);

    expect(requests.single.queryParameters, {'facility': 2});
    expect(view.facilityId, 2);
    expect(view.products.single.quantity, Decimal.parse('5.5'));
    expect(view.lines.single.transferId, 412);
    expect(view.lines.single.lineId, 900);
    expect(view.lines.single.quantityOutstanding, Decimal.parse('5.5'));

    final empty = await _repositoryWith(
      (options) async => _ok({'facility': 2}),
    ).inTransit(facilityId: 2);
    expect(empty.products, isEmpty);
    expect(empty.lines, isEmpty);
  });

  test('a refusal becomes an AppError carrying its code', () async {
    final repository = _repositoryWith(
      (options) async => ResponseBody.fromString(
        jsonEncode({
          'detail': 'Not in transit',
          'code': 'inventory_transfer.not_in_transit',
          'params': {'resource': 'inventory_transfer'},
        }),
        409,
        headers: _jsonHeaders,
      ),
    );

    await expectLater(
      repository.receive(412),
      throwsA(
        isA<AppError>().having(
          (e) => e.problem?.code,
          'code',
          api.ErrorCode.inventoryTransferPeriodNotInTransit,
        ),
      ),
    );
  });
}

Object? _decoded(Object? data) => data is String ? jsonDecode(data) : data;

InventoryTransferRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return InventoryTransferRepositoryImpl(dio);
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
