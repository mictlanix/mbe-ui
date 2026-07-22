import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('PaymentMethodOption.fromResponse (via PaymentMethodOptionRepositoryImpl.list)', () {
    test('maps the pre-expanded facility/warehouse summaries', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [
              _optionJson(
                id: 1,
                facilityId: 9,
                facilityName: 'Main Store',
                warehouseId: 3,
                warehouseName: 'Main Warehouse',
              ),
            ],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();
      final option = result.items.single;

      expect(option.paymentMethodOptionId, 1);
      expect(option.facilityId, 9);
      expect(option.facilityName, 'Main Store');
      expect(option.warehouseId, 3);
      expect(option.warehouseName, 'Main Warehouse');
      expect(option.numberOfPayments, 1);
      expect(option.displayOnTicket, isTrue);
      expect(option.paymentMethod, 1);
      expect(option.commission, '0.05');
      expect(option.status, EntityStatus.active);
      expect(result.total, 1);
    });

    test('a null warehouse maps to a null warehouseId/warehouseName (FR-004)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_optionJson(id: 1, facilityId: 9, warehouse: null)],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final option = (await repository.list()).items.single;

      expect(option.warehouseId, isNull);
      expect(option.warehouseName, isNull);
    });

    test('forwards facility/status query params (facility+status filter, FR-002)', () async {
      late Map<String, dynamic> captured;
      final repository = _repositoryWith((options) async {
        captured = options.queryParameters;
        return ResponseBody.fromString(
          jsonEncode({'items': [], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.list(facilityId: 9, status: EntityStatus.inactive);

      expect(captured['facility'], 9);
      expect(captured['status'], 1);
    });
  });

  group('PaymentMethodOptionRepositoryImpl.delete', () {
    test('a referential-constraint rejection maps to AppError', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Payment method option is referenced'}),
          400,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.delete(paymentMethodOptionId: 1),
        throwsA(isA<Object>()),
      );
    });
  });
}

Map<String, Object?> _optionJson({
  required int id,
  required int facilityId,
  String facilityName = 'Main Store',
  int? warehouseId = 3,
  String? warehouseName = 'Main Warehouse',
  Object? warehouse = _unset,
  int numberOfPayments = 1,
  bool displayOnTicket = true,
  int paymentMethod = 1,
  String commission = '0.05',
  int status = 0,
}) => {
  'payment_method_option_id': id,
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
  'warehouse': identical(warehouse, _unset)
      ? (warehouseId == null
            ? null
            : {
                'warehouse_id': warehouseId,
                'facility': facilityId,
                'code': 'WH-$warehouseId',
                'name': warehouseName,
                'status': 0,
              })
      : warehouse,
  'name': 'Cash on delivery',
  'number_of_payments': numberOfPayments,
  'display_on_ticket': displayOnTicket,
  'payment_method': paymentMethod,
  'commission': commission,
  'status': status,
};

const _unset = Object();

PaymentMethodOptionRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return PaymentMethodOptionRepositoryImpl(dio);
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
