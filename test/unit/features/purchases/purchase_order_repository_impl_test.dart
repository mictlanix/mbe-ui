import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/data/purchase_order_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

Map<String, Object?> _summaryJson({
  int id = 310,
  String status = 'draft',
  String? date,
  String? comment,
}) => {
  'purchase_order_id': id,
  'status': status,
  'supplier': 12,
  'supplier_name': 'Ferretera del Norte',
  'estimated_receipt_date': date,
  'comment': comment,
  'creator': 5,
  'updater': 5,
  'creation_time': '2026-11-26T09:30:00',
  'modification_time': '2026-11-26T09:30:00',
  'line_count': 2,
  'subtotal': '1000.00',
  'tax': '160.00',
  'total': '1160.00',
};

Map<String, Object?> _orderJson({
  String status = 'draft',
  String? date,
  String? comment,
  Object? lines,
  Object? warnings,
  Object? skipped,
  Object? receipts,
}) => {
  ..._summaryJson(status: status, date: date, comment: comment),
  'lines': lines,
  'warnings': warnings,
  'skipped': skipped,
  'receipts': receipts,
};

Map<String, Object?> _lineJson() => {
  'purchase_order_detail_id': 900,
  'product': 7,
  'product_code': 'A-100',
  'product_name': 'Tornillo',
  'warehouse': 3,
  'quantity': '8.5000',
  'price': '125.1234567',
  'tax_rate': '0.16',
  'amount': '1063.50',
  'purchase_request_detail': 55,
  'purchase_request': 212,
  'quantity_received': null,
  'quantity_pending': '8.5000',
};

ResponseBody _ok(Object? body, [int code = 200]) =>
    ResponseBody.fromString(jsonEncode(body), code, headers: _jsonHeaders);

void main() {
  test('list sends every filter, the paging and the dates as dates, and maps '
      'the page', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((options) async {
      requests.add(options);
      return _ok({
        'items': [
          for (final s in ['draft', 'completed', 'cancelled'])
            _summaryJson(status: s),
        ],
        'total': 41,
      });
    });

    final page = await repository.list(
      all: true,
      status: InventoryDocumentStatus.completed,
      supplierId: 12,
      creatorId: 5,
      orderId: 310,
      from: DateTime(2026, 11, 1),
      to: DateTime(2026, 11, 30),
      skip: 40,
      limit: 20,
    );

    expect(requests.single.queryParameters, {
      'all': true,
      'status': 'completed',
      'supplier': 12,
      'creator': 5,
      'id': 310,
      'from': '2026-11-01',
      'to': '2026-11-30',
      'skip': 40,
      'limit': 20,
    });
    expect(page.total, 41);
    expect(page.pageIndex, 2);
    expect(page.items.map((o) => o.status), InventoryDocumentStatus.values);
    expect(page.items.first.total, Decimal.parse('1160.00'));
    expect(page.items.first.supplierName, 'Ferretera del Norte');
    expect(page.items.first.createdAt, DateTime(2026, 11, 26, 9, 30));
  });

  test('list sends no filter by default, not even all=false', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((options) async {
      requests.add(options);
      return _ok({'items': <Object?>[], 'total': 0});
    });

    await repository.list(skip: 0, limit: 20);

    expect(requests.single.queryParameters, {'skip': 0, 'limit': 20});
  });

  test(
    'list never sends a facility, in any filter combination (FR-003)',
    () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return _ok({'items': <Object?>[], 'total': 0});
      });

      await repository.list(skip: 0, limit: 20);
      await repository.list(
        all: true,
        status: InventoryDocumentStatus.draft,
        supplierId: 1,
        creatorId: 2,
        orderId: 3,
        from: DateTime(2026, 11, 1),
        to: DateTime(2026, 11, 2),
        skip: 20,
        limit: 20,
      );

      for (final r in requests) {
        expect(r.queryParameters.containsKey('facility'), isFalse);
      }
    },
  );

  test('get maps every status, the decimal strings and the lines', () async {
    for (final entry in {
      'draft': InventoryDocumentStatus.draft,
      'completed': InventoryDocumentStatus.completed,
      'cancelled': InventoryDocumentStatus.cancelled,
    }.entries) {
      final repository = _repositoryWith(
        (options) async =>
            _ok(_orderJson(status: entry.key, lines: [_lineJson()])),
      );

      final order = await repository.get(310);

      expect(order.status, entry.value);
    }
    final repository = _repositoryWith(
      (options) async => _ok(_orderJson(lines: [_lineJson()])),
    );

    final order = await repository.get(310);

    expect(order.id, 310);
    expect(order.subtotal, Decimal.parse('1000.00'));
    expect(order.total, Decimal.parse('1160.00'));
    final line = order.lines.single;
    expect(line.id, 900);
    expect(line.quantity, Decimal.parse('8.5'));
    expect(line.price, Decimal.parse('125.1234567'));
    expect(line.taxRate, Decimal.parse('0.16'));
    expect(line.amount, Decimal.parse('1063.50'));
    expect(line.requestLineId, 55);
    expect(line.requestId, 212);
    expect(line.quantityReceived, isNull);
    expect(line.quantityPending, Decimal.parse('8.5'));
  });

  test('a paid status is a mapping error, never a guess', () async {
    final repository = _repositoryWith(
      (options) async => _ok(_orderJson(status: 'paid')),
    );

    await expectLater(repository.get(310), throwsA(isA<AppError>()));
  });

  test('a null lines, receipts and skipped are empty, warnings are dropped, '
      'an empty note is no note', () async {
    final repository = _repositoryWith(
      (options) async =>
          _ok(_orderJson(warnings: ['Some English'], comment: '')),
    );

    final order = await repository.get(310);

    expect(order.lines, isEmpty);
    expect(order.receipts, isEmpty);
    expect(order.skippedCount, 0);
    expect(order.comment, isNull);
  });

  test('skipped maps to a count only', () async {
    final repository = _repositoryWith(
      (options) async => _ok(
        _orderJson(
          skipped: [
            {'purchase_request_detail': 1, 'reason': 'No product'},
            {'purchase_request_detail': 2, 'reason': 'Already ordered'},
          ],
        ),
      ),
    );

    final order = await repository.addRequestLines(310, requestId: 212);

    expect(order.skippedCount, 2);
  });

  test('the receipts of a confirm map to OrderReceipt', () async {
    final repository = _repositoryWith(
      (options) async => _ok(
        _orderJson(
          status: 'completed',
          receipts: [
            {
              'inventory_receipt_id': 70,
              'warehouse': 3,
              'facility': 2,
              'line_count': 4,
            },
          ],
        ),
      ),
    );

    final order = await repository.confirm(310);

    final receipt = order.receipts.single;
    expect(receipt.id, 70);
    expect(receipt.warehouseId, 3);
    expect(receipt.facilityId, 2);
    expect(receipt.lineCount, 4);
  });

  test(
    'create sends the supplier, the date as a date and the comment',
    () async {
      Object? sent;
      final repository = _repositoryWith((options) async {
        sent = options.data;
        return _ok(_orderJson());
      });

      await repository.create(
        supplierId: 12,
        estimatedReceiptDate: DateTime(2026, 12, 5),
        comment: 'Urgente',
      );

      expect(_decoded(sent), {
        'supplier': 12,
        'estimated_receipt_date': '2026-12-05',
        'comment': 'Urgente',
      });
    },
  );

  test('updateHeader sends only the supplier when only it changed', () async {
    Object? sent;
    final repository = _repositoryWith((options) async {
      sent = options.data;
      return _ok(_orderJson());
    });

    await repository.updateHeader(310, supplierId: 9);

    expect(_decoded(sent), {'supplier': 9});
  });

  test('updateHeader sends a changed date and note, and no supplier', () async {
    Object? sent;
    final repository = _repositoryWith((options) async {
      sent = options.data;
      return _ok(_orderJson());
    });

    await repository.updateHeader(
      310,
      estimatedReceiptDate: DateTime(2026, 12, 5),
      comment: 'Nuevo',
    );

    expect(_decoded(sent), {
      'estimated_receipt_date': '2026-12-05',
      'comment': 'Nuevo',
    });
  });

  test('clearComment sends an empty string', () async {
    Object? sent;
    final repository = _repositoryWith((options) async {
      sent = options.data;
      return _ok(_orderJson());
    });

    await repository.updateHeader(310, clearComment: true);

    expect(_decoded(sent), {'comment': ''});
  });

  test('clearDate sends an explicit null date through a raw PUT and maps the '
      'response', () async {
    RequestOptions? request;
    final repository = _repositoryWith((options) async {
      request = options;
      return _ok(_orderJson());
    });

    final order = await repository.updateHeader(310, clearDate: true);

    expect(request!.method, 'PUT');
    expect(request!.path, '/api/v1/purchase-orders/310');
    final body = _decoded(request!.data)! as Map;
    expect(body.containsKey('estimated_receipt_date'), isTrue);
    expect(body['estimated_receipt_date'], isNull);
    expect(body.containsKey('supplier'), isFalse);
    expect(order.id, 310);
  });

  test('clearDate with clearComment sends both', () async {
    Object? sent;
    final repository = _repositoryWith((options) async {
      sent = options.data;
      return _ok(_orderJson());
    });

    await repository.updateHeader(310, clearDate: true, clearComment: true);

    expect(_decoded(sent), {'comment': '', 'estimated_receipt_date': null});
  });

  test('the estimated date round-trips as the same calendar day, also near '
      'midnight (spec 043)', () async {
    Object? sent;
    final repository = _repositoryWith((options) async {
      sent = options.data;
      return _ok(_orderJson(date: '2026-12-05T00:00:00'));
    });

    final order = await repository.updateHeader(
      310,
      estimatedReceiptDate: DateTime(2026, 12, 5, 23, 59),
    );

    expect(_decoded(sent), {'estimated_receipt_date': '2026-12-05'});
    expect(order.estimatedReceiptDate, DateTime(2026, 12, 5));

    for (final wire in ['2026-12-05T23:59:59', '2026-12-05T00:00:01']) {
      final near = await _repositoryWith(
        (options) async => _ok(_orderJson(date: wire)),
      ).get(310);
      final day = near.estimatedReceiptDate!;
      expect((day.year, day.month, day.day), (2026, 12, 5));
    }
  });

  test(
    'addLine sends the product and the quantity as a decimal string',
    () async {
      Object? sent;
      final repository = _repositoryWith((options) async {
        sent = options.data;
        return _ok(_orderJson());
      });

      await repository.addLine(
        310,
        productId: 7,
        quantity: Decimal.parse('2.5'),
      );

      expect(_decoded(sent), {'product': 7, 'quantity': '2.5'});
    },
  );

  test('updateLine sends only the given fields, decimals as strings', () async {
    final bodies = <Object?>[];
    final repository = _repositoryWith((options) async {
      bodies.add(options.data);
      return _ok(_orderJson());
    });

    await repository.updateLine(310, 900, warehouseId: 4);
    await repository.updateLine(
      310,
      900,
      quantity: Decimal.parse('3'),
      price: Decimal.parse('0.1234567'),
      taxRate: Decimal.parse('0.08'),
    );

    expect(_decoded(bodies[0]), {'warehouse': 4});
    expect(_decoded(bodies[1]), {
      'quantity': '3',
      'price': '0.1234567',
      'tax_rate': '0.08',
    });
  });

  test('removeLine, confirm and cancel hit their endpoints', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((options) async {
      requests.add(options);
      return _ok(_orderJson());
    });

    await repository.removeLine(310, 900);
    await repository.confirm(310);
    await repository.cancel(310);

    expect(requests.map((r) => '${r.method} ${r.path}'), [
      'DELETE /api/v1/purchase-orders/310/lines/900',
      'POST /api/v1/purchase-orders/310/confirm',
      'POST /api/v1/purchase-orders/310/cancel',
    ]);
  });

  test('addRequestLines sends the request id', () async {
    Object? sent;
    final repository = _repositoryWith((options) async {
      sent = options.data;
      return _ok(_orderJson());
    });

    await repository.addRequestLines(310, requestId: 212);

    expect(_decoded(sent), {'purchase_request': 212});
  });

  test('toPurchase sends the facility only when given and keeps the server '
      'order', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((options) async {
      requests.add(options);
      return _ok({
        'groups': [
          for (final (supplier, name) in [(null, null), (12, 'Ferretera')])
            {
              'supplier': supplier,
              'supplier_name': name,
              'facility': 2,
              'line_count': 1,
              'estimated_total': '1000.00',
              'lines': [
                {
                  'purchase_request_detail_id': 900,
                  'purchase_request': 212,
                  'serial': null,
                  'product': 7,
                  'product_code': 'A-100',
                  'product_name': null,
                  'quantity': '8.0000',
                  'warehouse': 3,
                  'cost': '0.00',
                },
              ],
            },
        ],
      });
    });

    final groups = await repository.toPurchase(facilityId: 2);
    await repository.toPurchase();

    expect(requests.first.queryParameters, {'facility': 2});
    expect(requests.last.queryParameters, isEmpty);
    expect(groups.map((g) => g.supplierId), [null, 12]);
    expect(groups.first.estimatedTotal, Decimal.parse('1000'));
    final line = groups.first.lines.single;
    expect(line.requestLineId, 900);
    expect(line.serial, isNull);
    expect(line.productName, isNull);
    expect(line.quantity, Decimal.parse('8'));
    expect(line.cost, Decimal.zero);
  });

  test('createFromGroup sends the supplier and the facility', () async {
    Object? sent;
    final repository = _repositoryWith((options) async {
      sent = options.data;
      return _ok(
        _orderJson(
          skipped: [
            {'purchase_request_detail': 1, 'reason': 'x'},
          ],
        ),
      );
    });

    final order = await repository.createFromGroup(
      supplierId: 12,
      facilityId: 2,
    );

    expect(_decoded(sent), {'supplier': 12, 'facility': 2});
    expect(order.skippedCount, 1);
  });

  test(
    'email sends the recipients and the message and maps the receipt',
    () async {
      Object? sent;
      final repository = _repositoryWith((options) async {
        sent = options.data;
        return _ok({
          'recipients': ['a@x.mx', 'b@x.mx'],
          'sent_at': '2026-11-27T10:15:00',
        });
      });

      final receipt = await repository.email(
        310,
        recipients: ['a@x.mx', 'b@x.mx'],
        message: 'Hola',
      );

      expect(_decoded(sent), {
        'to': ['a@x.mx', 'b@x.mx'],
        'message': 'Hola',
      });
      expect(receipt.recipients, ['a@x.mx', 'b@x.mx']);
      expect(receipt.sentAt, DateTime(2026, 11, 27, 10, 15));
    },
  );

  test('a refusal becomes an AppError carrying its code', () async {
    final repository = _repositoryWith(
      (options) async => _ok({
        'detail': 'The order has no lines',
        'code': 'purchase_order.no_lines',
      }, 409),
    );

    await expectLater(
      repository.confirm(310),
      throwsA(
        isA<AppError>().having(
          (e) => e.problem?.code,
          'code',
          api.ErrorCode.purchaseOrderPeriodNoLines,
        ),
      ),
    );
  });

  test(
    'a refusal of the raw clear-date PUT is also a coded AppError',
    () async {
      final repository = _repositoryWith(
        (options) async => _ok({
          'detail': 'Cancelled',
          'code': 'purchase_order.already_cancelled',
        }, 409),
      );

      await expectLater(
        repository.updateHeader(310, clearDate: true),
        throwsA(
          isA<AppError>().having(
            (e) => e.problem?.code,
            'code',
            api.ErrorCode.purchaseOrderPeriodAlreadyCancelled,
          ),
        ),
      );
    },
  );
}

Object? _decoded(Object? data) => data is String ? jsonDecode(data) : data;

PurchaseOrderRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return PurchaseOrderRepositoryImpl(dio);
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
