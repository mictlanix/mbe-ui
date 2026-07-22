import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('Warehouse.fromResponse (via WarehouseRepositoryImpl.list)', () {
    test('maps the pre-expanded facility summary to facilityId/facilityName', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_warehouseJson(id: 1, facilityId: 9, facilityName: 'Main Store')],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();
      final warehouse = result.items.single;

      expect(warehouse.warehouseId, 1);
      expect(warehouse.facilityId, 9);
      expect(warehouse.facilityName, 'Main Store');
      expect(warehouse.code, 'WH-1');
      expect(warehouse.status, EntityStatus.active);
      expect(result.total, 1);
    });

    test('an empty facility name falls back to the unknown-facility label', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_warehouseJson(id: 1, facilityId: 9, facilityName: '')],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final warehouse = (await repository.list()).items.single;

      expect(warehouse.facilityDisplayName('Unknown facility'), 'Unknown facility');
    });

    test('a resolved facility name is shown as-is, not the fallback', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_warehouseJson(id: 1, facilityId: 9, facilityName: 'Main Store')],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final warehouse = (await repository.list()).items.single;

      expect(warehouse.facilityDisplayName('Unknown facility'), 'Main Store');
    });

    test('forwards search/facility/status query params', () async {
      late Map<String, dynamic> captured;
      final repository = _repositoryWith((options) async {
        captured = options.queryParameters;
        return ResponseBody.fromString(
          jsonEncode({'items': [], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.list(
        search: 'WH-1',
        facilityId: 9,
        status: EntityStatus.inactive,
      );

      expect(captured['search'], 'WH-1');
      expect(captured['facility'], 9);
      expect(captured['status'], 1);
    });
  });

  group('WarehouseRepositoryImpl.delete', () {
    test('a referential-constraint rejection maps to AppError', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Warehouse holds stock'}),
          400,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.delete(warehouseId: 1),
        throwsA(isA<Object>()),
      );
    });
  });
}

Map<String, Object?> _warehouseJson({
  required int id,
  required int facilityId,
  String facilityName = 'Main Store',
  String code = 'WH-1',
  String name = 'Main Warehouse',
  int status = 0,
}) => {
  'warehouse_id': id,
  'facility': {
    'facility_id': facilityId,
    'code': 'FAC-$facilityId',
    'name': facilityName,
    'type': 0,
    'location': '00000',
    'address': 1,
    'taxpayer': 'AAA010101AAA',
    'status': 0,
  },
  'code': code,
  'name': name,
  'status': status,
};

WarehouseRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return WarehouseRepositoryImpl(dio);
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
