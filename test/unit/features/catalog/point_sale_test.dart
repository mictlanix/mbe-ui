import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('PointSale.fromResponse (via PointSaleRepositoryImpl.list)', () {
    test('expands both the facility and warehouse summaries', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [
              _pointSaleJson(
                id: 1,
                facilityId: 9,
                facilityName: 'Main Store',
                warehouseId: 5,
                warehouseName: 'Main Warehouse',
              ),
            ],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final pointSale = (await repository.list()).items.single;

      expect(pointSale.pointSaleId, 1);
      expect(pointSale.facilityId, 9);
      expect(pointSale.facilityName, 'Main Store');
      expect(pointSale.warehouseId, 5);
      expect(pointSale.warehouseName, 'Main Warehouse');
      expect(pointSale.status, EntityStatus.active);
    });

    test('an unresolvable facility or warehouse falls back to the '
        'unknown labels rather than a blank/raw value (FR-021)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [
              _pointSaleJson(
                id: 1,
                facilityId: 9,
                facilityName: '',
                warehouseId: 5,
                warehouseName: '',
              ),
            ],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final pointSale = (await repository.list()).items.single;

      expect(
        pointSale.facilityDisplayName('Unknown facility'),
        'Unknown facility',
      );
      expect(
        pointSale.warehouseDisplayName('Unknown warehouse'),
        'Unknown warehouse',
      );
    });

    test('forwards search/facility/warehouse/status query params', () async {
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
        search: 'POS-1',
        facilityId: 9,
        warehouseId: 5,
        status: EntityStatus.active,
      );

      expect(captured['search'], 'POS-1');
      expect(captured['facility'], 9);
      expect(captured['warehouse'], 5);
      expect(captured['status'], 0);
    });
  });

  group('PointSaleRepositoryImpl.create', () {
    test('a cross-facility warehouse pairing rejection maps to a '
        'ValidationError (mbe-api#102)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'warehouse'],
                'msg': 'Warehouse does not belong to the selected facility',
                'type': 'value_error',
              },
            ],
          }),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.create(
          facilityId: 9,
          code: 'POS-1',
          name: 'Front Counter',
          warehouseId: 5,
        ),
        throwsA(isA<Object>()),
      );
    });
  });
}

Map<String, Object?> _pointSaleJson({
  required int id,
  required int facilityId,
  String facilityName = 'Main Store',
  required int warehouseId,
  String warehouseName = 'Main Warehouse',
  String code = 'POS-1',
  String name = 'Front Counter',
  int status = 0,
}) => {
  'point_sale_id': id,
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
  'warehouse': {
    'warehouse_id': warehouseId,
    'facility': facilityId,
    'code': 'WH-$warehouseId',
    'name': warehouseName,
    'status': 0,
  },
  'status': status,
};

PointSaleRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return PointSaleRepositoryImpl(dio);
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
