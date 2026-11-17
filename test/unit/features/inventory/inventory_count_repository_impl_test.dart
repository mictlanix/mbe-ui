import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_count_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

Map<String, Object?> _countJson({
  int id = 412,
  String status = 'draft',
  int? serial,
  Object? lines,
  String? comment,
}) => {
  'inventory_count_id': id,
  'facility': 2,
  'warehouse': 3,
  'serial': serial,
  'status': status,
  'comment': comment,
  'creator': 5,
  'updater': 6,
  'creation_time': '2026-11-17T09:30:00.000',
  'modification_time': '2026-11-17T09:45:00.000',
  'lines': lines,
};

Map<String, Object?> _lineJson({
  String? quantityOnHand,
  String? difference,
  String? productCode = 'A-100',
}) => {
  'count_detail_id': 1200,
  'product': 7,
  'product_code': productCode,
  'product_name': 'Tornillo',
  'quantity': '8.5',
  'quantity_on_hand': quantityOnHand,
  'difference': difference,
};

void main() {
  test(
    'list sends the filter and no other parameter, and maps the page',
    () async {
      final requests = <RequestOptions>[];
      final repository = _repositoryWith((options) async {
        requests.add(options);
        return _ok({
          'items': [
            for (final status in ['draft', 'completed', 'cancelled'])
              {
                'inventory_count_id': status.length,
                'facility': 2,
                'warehouse': 3,
                'serial': status == 'completed' ? 57 : null,
                'status': status,
                'creator': 5,
                'creation_time': '2026-11-17T09:30:00.000',
              },
          ],
          'total': 41,
        });
      });

      final page = await repository.list(
        status: InventoryDocumentStatus.completed,
        warehouseId: 3,
        skip: 40,
        limit: 20,
      );
      await repository.list(skip: 0, limit: 20);

      expect(requests[0].queryParameters, {
        'status': 'completed',
        'warehouse': 3,
        'skip': 40,
        'limit': 20,
      });
      expect(requests[1].queryParameters, {'skip': 0, 'limit': 20});
      expect(page.total, 41);
      expect(page.pageIndex, 2);
      expect(page.pageSize, 20);
      expect(page.items.map((r) => r.status), [
        InventoryDocumentStatus.draft,
        InventoryDocumentStatus.completed,
        InventoryDocumentStatus.cancelled,
      ]);
      expect(page.items.map((r) => r.serial), [null, 57, null]);
      expect(page.items.first.creatorId, 5);
    },
  );

  test('a draft maps with no serial, blind lines with null figures, and an '
      'empty note as none', () async {
    final repository = _repositoryWith(
      (options) async => _ok(_countJson(lines: [_lineJson()], comment: '')),
    );

    final count = await repository.get(412);

    expect(count.serial, isNull);
    expect(count.isDraft, isTrue);
    expect(count.isCompleted, isFalse);
    expect(count.comment, isNull);
    expect(count.updaterId, 6);
    expect(count.updatedAt, DateTime(2026, 11, 17, 9, 45));
    final line = count.lines.single;
    expect(line.id, 1200);
    expect(line.quantity, Decimal.parse('8.5'));
    expect(line.quantityOnHand, isNull);
    expect(line.difference, isNull);
  });

  test('a completed count maps its serial, on-hand figures and differences, '
      'and a missing code to empty', () async {
    final repository = _repositoryWith(
      (options) async => _ok(
        _countJson(
          status: 'completed',
          serial: 57,
          comment: 'Anual',
          lines: [
            _lineJson(
              quantityOnHand: '10',
              difference: '-1.5',
              productCode: null,
            ),
          ],
        ),
      ),
    );

    final count = await repository.get(412);

    expect(count.isCompleted, isTrue);
    expect(count.serial, 57);
    expect(count.comment, 'Anual');
    final line = count.lines.single;
    expect(line.quantityOnHand, Decimal.parse('10'));
    expect(line.difference, Decimal.parse('-1.5'));
    expect(line.productCode, '');
  });

  test(
    'null lines map to empty, and a cancelled count reads as such',
    () async {
      final repository = _repositoryWith(
        (options) async => _ok(_countJson(status: 'cancelled')),
      );

      final count = await repository.get(412);

      expect(count.lines, isEmpty);
      expect(count.isCancelled, isTrue);
    },
  );

  test('a paid status is a mapping error, never guessed', () async {
    final repository = _repositoryWith(
      (options) async => _ok(_countJson(status: 'paid')),
    );

    await expectLater(repository.get(412), throwsA(isA<AppError>()));
  });

  test('setLines sends exactly one of product and product_code per item, '
      'with decimal-string quantities', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((options) async {
      requests.add(options);
      return _ok(_countJson());
    });

    await repository.setLines(412, [
      CountLineInput.byProduct(productId: 7, quantity: Decimal.parse('2.5')),
      CountLineInput.byCode(code: 'B-200', quantity: Decimal.zero),
    ]);

    expect(requests.single.method, 'PUT');
    expect(requests.single.path, '/api/v1/inventory-counts/412/lines');
    expect(_decoded(requests.single.data), {
      'lines': [
        {'product': 7, 'quantity': '2.5'},
        {'product_code': 'B-200', 'quantity': '0'},
      ],
    });
  });

  test('updateLine and removeLine hit their routes', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((options) async {
      requests.add(options);
      return _ok(_countJson());
    });

    await repository.updateLine(412, 1200, quantity: Decimal.parse('3'));
    await repository.removeLine(412, 1200);

    expect(requests[0].method, 'PUT');
    expect(requests[0].path, '/api/v1/inventory-counts/412/lines/1200');
    expect(_decoded(requests[0].data), {'quantity': '3'});
    expect(requests[1].method, 'DELETE');
    expect(requests[1].path, '/api/v1/inventory-counts/412/lines/1200');
  });

  test('create and updateHeader always send the comment', () async {
    final bodies = <Object?>[];
    final repository = _repositoryWith((options) async {
      bodies.add(options.data);
      return _ok(_countJson());
    });

    await repository.create(warehouseId: 3, comment: 'Anual');
    await repository.updateHeader(412, warehouseId: 4, comment: 'Nota');
    await repository.updateHeader(412, comment: null);

    expect(_decoded(bodies[0]), {'warehouse': 3, 'comment': 'Anual'});
    expect(_decoded(bodies[1]), {'warehouse': 4, 'comment': 'Nota'});
    expect(_decoded(bodies[2]), {'comment': ''});
  });

  test('confirm sends includeUncounted and maps the warnings', () async {
    final bodies = <Object?>[];
    final repository = _repositoryWith((options) async {
      bodies.add(options.data);
      return _ok({
        ..._countJson(
          status: 'completed',
          serial: 57,
          lines: [_lineJson(quantityOnHand: '10', difference: '-1.5')],
        ),
        'negative_available': [
          {
            'product': 7,
            'product_code': 'A-100',
            'counted': '2',
            'reserved': '5',
            'available': '-3',
          },
        ],
        'corrected_by_other_counts': [
          {
            'product': 8,
            'product_code': 'B-200',
            'inventory_count_id': 409,
            'serial': null,
          },
        ],
      });
    });

    final result = await repository.confirm(412, includeUncounted: true);

    expect(_decoded(bodies.single), {'include_uncounted': true});
    expect(result.count.isCompleted, isTrue);
    expect(result.count.serial, 57);
    expect(result.count.lines.single.difference, Decimal.parse('-1.5'));
    expect(result.warnings.isEmpty, isFalse);
    expect(
      result.warnings.negativeAvailable.single,
      isA<NegativeAvailableItem>()
          .having((n) => n.productId, 'productId', 7)
          .having((n) => n.reserved, 'reserved', Decimal.parse('5'))
          .having((n) => n.available, 'available', Decimal.parse('-3')),
    );
    final corrected = result.warnings.correctedByOtherCounts.single;
    expect(corrected.otherCountId, 409);
    expect(corrected.otherCountSerial, isNull);
    expect(corrected.productCode, 'B-200');
  });

  test('confirm with no warnings maps to empty warnings', () async {
    final repository = _repositoryWith(
      (options) async => _ok(_countJson(status: 'completed', serial: 57)),
    );

    final result = await repository.confirm(412, includeUncounted: false);

    expect(result.warnings.isEmpty, isTrue);
  });

  test('a batch refusal becomes a coded AppError whose parts keep their '
      'index', () async {
    final repository = _repositoryWith(
      (options) async => ResponseBody.fromString(
        jsonEncode({
          'detail': 'Some lines are invalid',
          'code': 'inventory_count.batch_invalid',
          'errors': [
            {
              'index': 1,
              'product_code': 'ZZZ',
              'code': 'inventory_count_line.product_unknown',
              'reason': 'unknown',
            },
          ],
        }),
        422,
        headers: _jsonHeaders,
      ),
    );

    await expectLater(
      repository.setLines(412, [
        CountLineInput.byCode(code: 'A-100', quantity: Decimal.one),
        CountLineInput.byCode(code: 'ZZZ', quantity: Decimal.one),
      ]),
      throwsA(
        isA<AppError>()
            .having(
              (e) => e.problem?.code,
              'code',
              api.ErrorCode.inventoryCountPeriodBatchInvalid,
            )
            .having(
              (e) => e.problem?.parts.single.code,
              'part code',
              api.ErrorCode.inventoryCountLinePeriodProductUnknown,
            )
            .having(
              (e) => e.problem?.parts.single.extra['index'],
              'part index',
              1,
            ),
      ),
    );
  });
}

ResponseBody _ok(Object body) =>
    ResponseBody.fromString(jsonEncode(body), 200, headers: _jsonHeaders);

Object? _decoded(Object? data) => data is String ? jsonDecode(data) : data;

InventoryCountRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return InventoryCountRepositoryImpl(dio);
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
