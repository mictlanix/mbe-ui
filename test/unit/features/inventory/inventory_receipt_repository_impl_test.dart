import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_receipt_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/receipt_cost_warning.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

Map<String, Object?> _receiptJson({
  int id = 318,
  String status = 'draft',
  Object? lines,
  Object? warnings,
  String? comment,
  int? purchaseOrder,
}) => {
  'inventory_receipt_id': id,
  'facility': 2,
  'warehouse': 3,
  'purchase_order': purchaseOrder,
  'serial': null,
  'status': status,
  'comment': comment,
  'creator': 5,
  'updater': 5,
  'creation_time': '2026-11-16T10:02:00.000',
  'modification_time': '2026-11-16T10:02:00.000',
  'lines': lines,
  'warnings': warnings,
};

Map<String, Object?> _lineJson({String? elsewhere}) => {
  'receipt_detail_id': 900,
  'product': 7,
  'product_code': 'A-100',
  'product_name': 'Tornillo',
  'quantity': '8.5',
  'purchase_order_detail': 12,
  'quantity_ordered': '10',
  'quantity_received_elsewhere': elsewhere,
};

void main() {
  test(
    'list sends the filter and no other parameter, and maps the page',
    () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return ResponseBody.fromString(
          jsonEncode({
            'items': [
              for (final status in ['draft', 'completed', 'cancelled'])
                {
                  'inventory_receipt_id': status.length,
                  'facility': 2,
                  'warehouse': 3,
                  'purchase_order': null,
                  'serial': status == 'draft' ? null : 1043,
                  'status': status,
                  'creator': 5,
                  'creation_time': '2026-11-16T10:02:00.000',
                  // A row whose creator is gone has no creator_name.
                  'warehouse_name': 'Centro',
                  'facility_name': 'Matriz',
                  'creator_name': status == 'draft' ? 'Ana Ruiz' : null,
                },
            ],
            'total': 41,
          }),
          200,
          headers: _jsonHeaders,
        );
      });

      final page = await repository.list(
        status: InventoryDocumentStatus.completed,
        warehouseId: 3,
        skip: 40,
        limit: 20,
      );

      expect(requests.single.queryParameters, {
        'status': 'completed',
        'warehouse': 3,
        'skip': 40,
        'limit': 20,
      });
      expect(page.total, 41);
      expect(page.pageIndex, 2);
      expect(page.pageSize, 20);
      expect(page.items.map((r) => r.status), [
        InventoryDocumentStatus.draft,
        InventoryDocumentStatus.completed,
        InventoryDocumentStatus.cancelled,
      ]);
      expect(page.items.first.serial, isNull);
      expect(page.items.first.warehouseName, 'Centro');
      expect(page.items.first.facilityName, 'Matriz');
      expect(page.items.first.creatorName, 'Ana Ruiz');
      expect(page.items.last.creatorName, isNull);
    },
  );

  test('get maps lines to Decimal quantities, a null lines to empty, '
      'maps the cost warnings by code (dropping over-receipts), and reads an '
      'empty note as none', () async {
    final repository = _repositoryWith(
      (options) async => ResponseBody.fromString(
        jsonEncode(
          _receiptJson(
            lines: [_lineJson(elsewhere: '2.5')],
            warnings: [
              {
                'code': 'inventory_receipt.over_received',
                'detail': 'Over-received A1 by 2',
                'params': {'product_id': 7, 'product_code': 'A1'},
              },
              {
                'code': 'purchase_cost.zero_price',
                'detail': 'A1 is priced at 0',
                'params': {'product_id': 7, 'product_code': 'A1'},
              },
              {
                'code': 'purchase_cost.not_restored',
                'detail': 'Cost of B2 not restored',
                'params': {
                  'product_id': 8,
                  'product_code': 'B2',
                  'receipt': '1044',
                  'inventory_receipt_id': 410,
                },
              },
            ],
            comment: '',
            purchaseOrder: 5512,
          ),
        ),
        200,
        headers: _jsonHeaders,
      ),
    );

    final receipt = await repository.get(318);

    expect(receipt.comment, isNull);
    expect(receipt.isLinked, isTrue);
    expect(receipt.costWarnings, [
      (
        kind: ReceiptCostWarningKind.zeroPrice,
        productCode: 'A1',
        receipt: null,
      ),
      (
        kind: ReceiptCostWarningKind.notRestored,
        productCode: 'B2',
        receipt: '1044',
      ),
    ]);
    final line = receipt.lines.single;
    expect(line.quantity, Decimal.parse('8.5'));
    expect(line.quantityOrdered, Decimal.parse('10'));
    expect(line.quantityReceivedElsewhere, Decimal.parse('2.5'));
    expect(line.purchaseOrderLineId, 12);

    final bare = await _repositoryWith(
      (options) async => ResponseBody.fromString(
        jsonEncode(_receiptJson()),
        200,
        headers: _jsonHeaders,
      ),
    ).get(318);
    expect(bare.lines, isEmpty);
    expect(bare.costWarnings, isEmpty);
  });

  test('a paid status is a mapping error, never guessed', () async {
    final repository = _repositoryWith(
      (options) async => ResponseBody.fromString(
        jsonEncode(_receiptJson(status: 'paid')),
        200,
        headers: _jsonHeaders,
      ),
    );

    await expectLater(repository.get(318), throwsA(isA<AppError>()));
  });

  test('complementary returns the receipt of a 200 and of a 201', () async {
    for (final code in [200, 201]) {
      final repository = _repositoryWith((options) async {
        expect(options.method, 'POST');
        expect(options.path, endsWith('/inventory-receipts/318/complementary'));
        return ResponseBody.fromString(
          jsonEncode(_receiptJson(id: 400 + code)),
          code,
          headers: _jsonHeaders,
        );
      });

      expect((await repository.complementary(318)).id, 400 + code);
    }
  });

  test('line writes send the quantity as a decimal string', () async {
    final bodies = <Object?>[];
    final repository = _repositoryWith((options) async {
      bodies.add(options.data);
      return ResponseBody.fromString(
        jsonEncode(_receiptJson()),
        200,
        headers: _jsonHeaders,
      );
    });

    await repository.addLine(318, productId: 7, quantity: Decimal.parse('2.5'));
    await repository.updateLine(318, 900, quantity: Decimal.parse('3'));

    expect(_decoded(bodies[0]), {'product': 7, 'quantity': '2.5'});
    expect(_decoded(bodies[1]), {'quantity': '3'});
  });

  test('updateHeader sends only the fields that changed', () async {
    final bodies = <Object?>[];
    final repository = _repositoryWith((options) async {
      bodies.add(options.data);
      return ResponseBody.fromString(
        jsonEncode(_receiptJson()),
        200,
        headers: _jsonHeaders,
      );
    });

    await repository.updateHeader(318, comment: 'Nota');
    await repository.updateHeader(318, warehouseId: 4);
    await repository.updateHeader(318, clearComment: true);

    expect(_decoded(bodies[0]), {'comment': 'Nota'});
    expect(_decoded(bodies[1]), {'warehouse': 4});
    expect(_decoded(bodies[2]), {'comment': ''});
  });

  test('a refusal becomes an AppError carrying its code', () async {
    final repository = _repositoryWith(
      (options) async => ResponseBody.fromString(
        jsonEncode({
          'detail': 'The receipt has no lines',
          'code': 'inventory_document.no_lines',
          'params': {'resource': 'inventory_receipt'},
        }),
        409,
        headers: _jsonHeaders,
      ),
    );

    await expectLater(
      repository.confirm(318),
      throwsA(
        isA<AppError>().having(
          (e) => e.problem?.code,
          'code',
          api.ErrorCode.inventoryDocumentPeriodNoLines,
        ),
      ),
    );
  });
}

Object? _decoded(Object? data) => data is String ? jsonDecode(data) : data;

InventoryReceiptRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return InventoryReceiptRepositoryImpl(dio);
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
