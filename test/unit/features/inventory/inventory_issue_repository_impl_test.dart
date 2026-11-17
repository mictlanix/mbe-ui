import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_issue_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

Map<String, Object?> _issueJson({
  int id = 318,
  String status = 'draft',
  Object? lines,
  String? comment,
  int? supplierReturn,
}) => {
  'inventory_issue_id': id,
  'facility': 2,
  'warehouse': 3,
  'supplier_return': supplierReturn,
  'serial': null,
  'status': status,
  'comment': comment,
  'creator': 5,
  'updater': 5,
  'creation_time': '2026-11-16T10:02:00.000',
  'modification_time': '2026-11-16T10:02:00.000',
  'lines': lines,
};

Map<String, Object?> _lineJson() => {
  'issue_detail_id': 900,
  'product': 7,
  'product_code': 'A-100',
  'product_name': 'Tornillo',
  'quantity': '8.5',
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
                  'inventory_issue_id': status.length,
                  'facility': 2,
                  'warehouse': 3,
                  'supplier_return': 41,
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

  test('get maps lines to Decimal quantities, a supplier return, a null lines '
      'to empty, and reads an empty note as none', () async {
    final repository = _repositoryWith(
      (options) async => ResponseBody.fromString(
        jsonEncode(
          _issueJson(lines: [_lineJson()], comment: '', supplierReturn: 5512),
        ),
        200,
        headers: _jsonHeaders,
      ),
    );

    final issue = await repository.get(318);

    expect(issue.comment, isNull);
    expect(issue.supplierReturnId, 5512);
    expect(issue.serial, isNull);
    expect(issue.isDraft, isTrue);
    final line = issue.lines.single;
    expect(line.quantity, Decimal.parse('8.5'));
    expect(line.productCode, 'A-100');

    final bare = await _repositoryWith(
      (options) async => ResponseBody.fromString(
        jsonEncode(_issueJson(status: 'completed', comment: 'Merma')),
        200,
        headers: _jsonHeaders,
      ),
    ).get(318);
    expect(bare.lines, isEmpty);
    expect(bare.supplierReturnId, isNull);
    expect(bare.comment, 'Merma');
    expect(bare.status, InventoryDocumentStatus.completed);
  });

  test('a paid status is a mapping error, never guessed', () async {
    final repository = _repositoryWith(
      (options) async => ResponseBody.fromString(
        jsonEncode(_issueJson(status: 'paid')),
        200,
        headers: _jsonHeaders,
      ),
    );

    await expectLater(repository.get(318), throwsA(isA<AppError>()));
  });

  test('line writes send the quantity as a decimal string', () async {
    final bodies = <Object?>[];
    final repository = _repositoryWith((options) async {
      bodies.add(options.data);
      return ResponseBody.fromString(
        jsonEncode(_issueJson()),
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
        jsonEncode(_issueJson()),
        200,
        headers: _jsonHeaders,
      );
    });

    await repository.updateHeader(318, comment: 'Nota');
    await repository.updateHeader(318, warehouseId: 4);
    await repository.updateHeader(318, clearComment: true);
    await repository.create(warehouseId: 3, comment: 'Merma');

    expect(_decoded(bodies[0]), {'comment': 'Nota'});
    expect(_decoded(bodies[1]), {'warehouse': 4});
    expect(_decoded(bodies[2]), {'comment': ''});
    expect(_decoded(bodies[3]), {'warehouse': 3, 'comment': 'Merma'});
  });

  test('a refusal becomes an AppError carrying its code', () async {
    final repository = _repositoryWith(
      (options) async => ResponseBody.fromString(
        jsonEncode({
          'detail': 'The issue has no lines',
          'code': 'inventory_document.no_lines',
          'params': {'resource': 'inventory_issue'},
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

InventoryIssueRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return InventoryIssueRepositoryImpl(dio);
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
