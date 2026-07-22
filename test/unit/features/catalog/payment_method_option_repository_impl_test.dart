import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('PaymentMethodOptionRepositoryImpl.get', () {
    test('200 returns the mapped option', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_optionJson()),
          200,
          headers: _jsonHeaders,
        ),
      );

      final option = await repository.get(paymentMethodOptionId: 1);

      expect(option.paymentMethodOptionId, 1);
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Payment method option not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.get(paymentMethodOptionId: 999),
        throwsA(const AppError.notFound('Payment method option not found')),
      );
    });
  });

  group('PaymentMethodOptionRepositoryImpl.create', () {
    test('sends facility/warehouse/name/paymentMethod and the commission '
        'AnyOf as a string arm', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_optionJson()),
          201,
          headers: _jsonHeaders,
        );
      });

      await repository.create(
        facilityId: 9,
        warehouseId: 3,
        name: 'Cash on delivery',
        paymentMethod: 1,
        commission: '0.05',
      );

      final body = _decodeBody(captured!.data);
      expect(body['facility'], 9);
      expect(body['warehouse'], 3);
      expect(body['name'], 'Cash on delivery');
      expect(body['payment_method'], 1);
      expect(body['commission'], '0.05');
    });

    test('a duplicate/invalid rejection maps to AppError.validation', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'name'],
                'msg': 'Name already in use for this facility',
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
          name: 'Duplicate',
          paymentMethod: 1,
        ),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('PaymentMethodOptionRepositoryImpl.update', () {
    test('only the changed fields are sent (partial update)', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_optionJson()),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.update(paymentMethodOptionId: 1, commission: '0.10');

      expect(captured!.path, contains('1'));
      final body = _decodeBody(captured!.data);
      expect(body['commission'], '0.10');
      expect(body.containsKey('name'), isFalse);
      expect(body.containsKey('facility'), isFalse);
    });
  });

  group('PaymentMethodOptionRepositoryImpl.delete', () {
    test('204 completes with no error', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );

      await expectLater(
        repository.delete(paymentMethodOptionId: 1),
        completes,
      );
    });
  });
}

Map<String, Object?> _optionJson() => {
  'payment_method_option_id': 1,
  'facility': {
    'facility_id': 9,
    'code': 'FAC-9',
    'name': 'Main Store',
    'type': 0,
    'location': '00000',
    'address': 1,
    'taxpayer': 'AAA010101AAA',
    'status': 0,
  },
  'warehouse': {
    'warehouse_id': 3,
    'facility': 9,
    'code': 'WH-3',
    'name': 'Main Warehouse',
    'status': 0,
  },
  'name': 'Cash on delivery',
  'number_of_payments': 1,
  'display_on_ticket': true,
  'payment_method': 1,
  'commission': '0.05',
  'status': 0,
};

Map<String, Object?> _decodeBody(Object? data) => data is String
    ? jsonDecode(data) as Map<String, Object?>
    : data as Map<String, Object?>;

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
