import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('ProductRepositoryImpl.list', () {
    test('200 returns items and total', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [
              {
                'product_id': 1,
                'code': 'SKU-001',
                'name': 'Widget',
                'brand': 'Acme',
                'model': null,
                'unit_of_measurement': 'PCE',
                'tax_rate': '0.16',
                'deactivated': false,
              },
            ],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();

      expect(result.total, 1);
      expect(result.items, hasLength(1));
      expect(result.items.single.productId, 1);
      expect(result.items.single.code, 'SKU-001');
      expect(result.items.single.deactivated, isFalse);
    });

    test('422 maps to AppError.validation', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['query', 'limit'],
                'msg': 'Input should be less than or equal to 100',
                'type': 'less_than_equal',
              },
            ],
          }),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.list(limit: 1000),
        throwsA(isA<ValidationError>()),
      );
    });

    test('5xx maps to AppError.server', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 503),
      );

      await expectLater(
        () => repository.list(),
        throwsA(const AppError.server(statusCode: 503)),
      );
    });

    test('a connection failure maps to AppError.network', () async {
      final repository = _repositoryWith(
        (options) async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'Failed host lookup',
        ),
      );

      await expectLater(() => repository.list(), throwsA(isA<NetworkError>()));
    });
  });

  group('ProductRepositoryImpl.get', () {
    test('200 maps to a Product', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_productResponseJson()),
          200,
          headers: _jsonHeaders,
        ),
      );

      final product = await repository.get(productId: 1);

      expect(product.productId, 1);
      expect(product.code, 'SKU-001');
      expect(product.name, 'Widget');
      expect(product.unitOfMeasurement, 'PCE');
      expect(product.deactivated, isFalse);
      expect(product.prices, hasLength(1));
      expect(product.prices.single.priceList, 1);
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Product not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.get(productId: 999),
        throwsA(const AppError.notFound()),
      );
    });

    test('5xx maps to AppError.server', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 500),
      );

      await expectLater(
        () => repository.get(productId: 1),
        throwsA(const AppError.server(statusCode: 500)),
      );
    });

    test('a connection failure maps to AppError.network', () async {
      final repository = _repositoryWith(
        (options) async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'Connection refused',
        ),
      );

      await expectLater(
        () => repository.get(productId: 1),
        throwsA(isA<NetworkError>()),
      );
    });
  });
}

Map<String, Object?> _productResponseJson() => {
      'product_id': 1,
      'code': 'SKU-001',
      'name': 'Widget',
      'photo': null,
      'sku': null,
      'brand': 'Acme',
      'model': null,
      'bar_code': null,
      'location': null,
      'unit_of_measurement': 'PCE',
      'key': null,
      'tax_rate': '0.16',
      'tax_included': false,
      'price_type': 0,
      'currency': 0,
      'min_order_qty': 1,
      'supplier': null,
      'stockable': true,
      'perishable': false,
      'seriable': false,
      'purchasable': true,
      'salable': true,
      'invoiceable': true,
      'stock_verification': true,
      'deactivated': false,
      'comment': null,
      'prices': [
        {
          'product_price_id': 10,
          'price_list': 1,
          'price': '0',
          'low_profit': '0',
          'high_profit': '0',
        },
      ],
    };

ProductRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return ProductRepositoryImpl(dio);
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      _handler(options);

  @override
  void close({bool force = false}) {}
}
