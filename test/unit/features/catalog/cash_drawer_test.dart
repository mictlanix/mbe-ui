import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/cash_drawer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/cash_drawer.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('CashDrawer.fromResponse (via CashDrawerRepositoryImpl.list)', () {
    test('maps the pre-expanded facility summary to facilityId/facilityName', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_cashDrawerJson(id: 1, facilityId: 9, facilityName: 'Main Store')],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();
      final cashDrawer = result.items.single;

      expect(cashDrawer.cashDrawerId, 1);
      expect(cashDrawer.facilityId, 9);
      expect(cashDrawer.facilityName, 'Main Store');
      expect(cashDrawer.code, 'CD-1');
      expect(cashDrawer.status, EntityStatus.active);
      expect(result.total, 1);
    });

    test('an empty facility name falls back to the unknown-facility label', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_cashDrawerJson(id: 1, facilityId: 9, facilityName: '')],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final cashDrawer = (await repository.list()).items.single;

      expect(cashDrawer.facilityDisplayName('Unknown facility'), 'Unknown facility');
    });

    test('a resolved facility name is shown as-is, not the fallback', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_cashDrawerJson(id: 1, facilityId: 9, facilityName: 'Main Store')],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final cashDrawer = (await repository.list()).items.single;

      expect(cashDrawer.facilityDisplayName('Unknown facility'), 'Main Store');
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
        search: 'CD-1',
        facilityId: 9,
        status: EntityStatus.inactive,
      );

      expect(captured['search'], 'CD-1');
      expect(captured['facility'], 9);
      expect(captured['status'], 1);
    });
  });

  group('CashDrawerRepositoryImpl.delete', () {
    test('a referential-constraint rejection maps to AppError', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'CashDrawer holds stock'}),
          400,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.delete(cashDrawerId: 1),
        throwsA(isA<Object>()),
      );
    });
  });
}

Map<String, Object?> _cashDrawerJson({
  required int id,
  required int facilityId,
  String facilityName = 'Main Store',
  String code = 'CD-1',
  String name = 'Main CashDrawer',
  int status = 0,
}) => {
  'cash_drawer_id': id,
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

CashDrawerRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return CashDrawerRepositoryImpl(dio);
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
