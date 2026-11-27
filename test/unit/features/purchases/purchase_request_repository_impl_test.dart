import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

Map<String, Object?> _summaryJson({
  int id = 212,
  String status = 'draft',
  int? serial,
  String? comment,
}) => {
  'purchase_request_id': id,
  'serial': serial,
  'status': status,
  'warehouse': 3,
  'facility': 2,
  'date': '2026-11-26T09:30:00.000',
  'comment': comment,
  'creator': 5,
  'updater': 5,
  'approver': null,
  'approval_time': null,
  'line_count': 2,
};

Map<String, Object?> _requestJson({
  String status = 'draft',
  Object? lines,
  Object? warnings,
  String? comment,
}) => {
  ..._summaryJson(status: status, comment: comment),
  'lines': lines,
  'warnings': warnings,
};

Map<String, Object?> _lineJson({String? orderStatus, int? order}) => {
  'purchase_request_detail_id': 900,
  'product': 7,
  'product_code': 'A-100',
  'product_name': 'Tornillo',
  'quantity': '8.50',
  'warehouse': 3,
  'to_purchase': true,
  'min_order_qty': 12,
  'purchase_order_detail': null,
  'purchase_order': order,
  'purchase_order_status': orderStatus,
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
          for (final s in ['draft', 'submitted', 'approved', 'cancelled'])
            _summaryJson(status: s, serial: s == 'draft' ? null : 571),
        ],
        'total': 41,
      });
    });

    final page = await repository.list(
      all: true,
      status: PurchaseRequestStatus.submitted,
      facilityId: 2,
      warehouseId: 3,
      creatorId: 5,
      serial: 571,
      from: DateTime(2026, 11, 1),
      to: DateTime(2026, 11, 30),
      skip: 40,
      limit: 20,
    );

    expect(requests.single.queryParameters, {
      'all': true,
      'status': 'submitted',
      'facility': 2,
      'warehouse': 3,
      'creator': 5,
      'serial': 571,
      'from': '2026-11-01',
      'to': '2026-11-30',
      'skip': 40,
      'limit': 20,
    });
    expect(page.total, 41);
    expect(page.pageIndex, 2);
    expect(page.pageSize, 20);
    expect(page.items.map((r) => r.status), PurchaseRequestStatus.values);
    expect(page.items.first.serial, isNull);
    expect(page.items.first.lineCount, 2);
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

  test('approvalQueue sends the facility and the paging', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((options) async {
      requests.add(options);
      return _ok({
        'items': [_summaryJson(status: 'submitted', serial: 9)],
        'total': 1,
      });
    });

    final page = await repository.approvalQueue(
      facilityId: 2,
      skip: 0,
      limit: 20,
    );

    expect(requests.single.path, endsWith('/purchase-requests/approval-queue'));
    expect(requests.single.queryParameters, {
      'facility': 2,
      'skip': 0,
      'limit': 20,
    });
    expect(page.items.single.status, PurchaseRequestStatus.submitted);
  });

  test('get maps lines to Decimal quantities, the order status to the shared '
      'chip status, drops warnings, and reads a null lines and an empty note '
      'as none', () async {
    final repository = _repositoryWith(
      (options) async => _ok(
        _requestJson(
          lines: [_lineJson(orderStatus: 'completed', order: 77)],
          warnings: ['A-100 is below the minimum'],
          comment: '',
        ),
      ),
    );

    final request = await repository.get(212);

    expect(request.comment, isNull);
    final line = request.lines.single;
    expect(line.quantity, Decimal.parse('8.5'));
    expect(line.toPurchase, isTrue);
    expect(line.minOrderQty, 12);
    expect(line.purchaseOrderId, 77);
    expect(line.purchaseOrderStatus, InventoryDocumentStatus.completed);

    final bare = await _repositoryWith(
      (options) async => _ok(_requestJson()),
    ).get(212);
    expect(bare.lines, isEmpty);
  });

  test('a paid order status is a mapping error, never guessed', () async {
    final repository = _repositoryWith(
      (options) async =>
          _ok(_requestJson(lines: [_lineJson(orderStatus: 'paid', order: 77)])),
    );

    await expectLater(repository.get(212), throwsA(isA<AppError>()));
  });

  test('line writes send the quantity as a decimal string and only the given '
      'fields', () async {
    final bodies = <Object?>[];
    final repository = _repositoryWith((options) async {
      bodies.add(options.data);
      return _ok(_requestJson());
    });

    await repository.addLine(212, productId: 7);
    await repository.updateLine(212, 900, quantity: Decimal.parse('2.5'));
    await repository.updateLine(212, 900, productName: 'Otro', warehouseId: 4);

    expect(_decoded(bodies[0]), {'product': 7});
    expect(_decoded(bodies[1]), {'quantity': '2.5'});
    expect(_decoded(bodies[2]), {'product_name': 'Otro', 'warehouse': 4});
  });

  test('updateHeader sends only the fields that changed', () async {
    final bodies = <Object?>[];
    final repository = _repositoryWith((options) async {
      bodies.add(options.data);
      return _ok(_requestJson());
    });

    await repository.updateHeader(212, comment: 'Nota');
    await repository.updateHeader(212, warehouseId: 4);
    await repository.updateHeader(212, clearComment: true);

    expect(_decoded(bodies[0]), {'comment': 'Nota'});
    expect(_decoded(bodies[1]), {'warehouse': 4});
    expect(_decoded(bodies[2]), {'comment': ''});
  });

  test('the actions call their endpoints with their bodies', () async {
    final calls = <String>[];
    final bodies = <Object?>[];
    final repository = _repositoryWith((options) async {
      calls.add('${options.method} ${options.path.split('/api/v1').last}');
      bodies.add(options.data);
      return _ok(_requestJson());
    });

    await repository.create(warehouseId: 3, comment: 'n');
    await repository.removeLine(212, 900);
    await repository.submit(212);
    await repository.cancel(212);
    await repository.markLine(212, 900, toPurchase: true);
    await repository.approve(212);
    await repository.reject(212, reason: 'Falta presupuesto');

    expect(calls, [
      'POST /purchase-requests',
      'DELETE /purchase-requests/212/lines/900',
      'POST /purchase-requests/212/submit',
      'POST /purchase-requests/212/cancel',
      'PUT /purchase-requests/212/lines/900/to-purchase',
      'POST /purchase-requests/212/approve',
      'POST /purchase-requests/212/reject',
    ]);
    expect(_decoded(bodies[0]), {'warehouse': 3, 'comment': 'n'});
    expect(_decoded(bodies[4]), {'to_purchase': true});
    expect(_decoded(bodies[6]), {'reason': 'Falta presupuesto'});
  });

  test('approveMany returns approved and refused results, the refusal with a '
      'localizable problem', () async {
    Object? sent;
    final repository = _repositoryWith((options) async {
      sent = options.data;
      return _ok({
        'results': [
          {'purchase_request_id': 1, 'approved': true},
          {
            'purchase_request_id': 2,
            'approved': false,
            'reason': 'The request is no longer submitted',
            'code': 'purchase_request.not_submitted',
            'params': {'status': 'approved'},
          },
        ],
      });
    });

    final outcomes = await repository.approveMany([1, 2]);

    expect(_decoded(sent), {
      'ids': [1, 2],
    });
    expect(outcomes.map((o) => (o.requestId, o.approved)), [
      (1, true),
      (2, false),
    ]);
    expect(outcomes.first.problem, isNull);
    final problem = outcomes.last.problem!;
    expect(problem.codeName, 'purchase_request.not_submitted');
    expect(problem.code, api.ErrorCode.purchaseRequestPeriodNotSubmitted);
    expect(problem.stringParam('status'), 'approved');
  });

  test('approveMany throws on a whole-call failure', () async {
    final repository = _repositoryWith(
      (options) async =>
          _ok({'detail': 'Forbidden', 'code': 'auth.forbidden'}, 403),
    );

    await expectLater(repository.approveMany([1]), throwsA(isA<AppError>()));
  });

  test('a refusal becomes an AppError carrying its code', () async {
    final repository = _repositoryWith(
      (options) async => _ok({
        'detail': 'The request has no lines',
        'code': 'purchase_request.no_lines',
      }, 409),
    );

    await expectLater(
      repository.submit(212),
      throwsA(
        isA<AppError>().having(
          (e) => e.problem?.code,
          'code',
          api.ErrorCode.purchaseRequestPeriodNoLines,
        ),
      ),
    );
  });
}

Object? _decoded(Object? data) => data is String ? jsonDecode(data) : data;

PurchaseRequestRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return PurchaseRequestRepositoryImpl(dio);
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
