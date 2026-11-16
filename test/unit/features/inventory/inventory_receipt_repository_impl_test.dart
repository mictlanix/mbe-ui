import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_receipt_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';

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
                },
            ],
            'total': 41,
          }),
          200,
          headers: _jsonHeaders,
        );
      });

      final page = await repository.list(
        status: ReceiptStatus.completed,
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
        ReceiptStatus.draft,
        ReceiptStatus.completed,
        ReceiptStatus.cancelled,
      ]);
      expect(page.items.first.serial, isNull);
    },
  );

  test(
    'get maps lines to Decimal quantities, a null lines to empty, '
    'keeps only the warning count, and reads an empty note as none',
    () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(
            _receiptJson(
              lines: [_lineJson(elsewhere: '2.5')],
              warnings: ['cost exception: product 7', 'another'],
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
      expect(receipt.serverWarningCount, 2);
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
      expect(bare.serverWarningCount, 0);
    },
  );

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
