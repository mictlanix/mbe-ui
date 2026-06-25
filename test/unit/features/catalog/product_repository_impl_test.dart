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

  group('ProductRepositoryImpl.create', () {
    test('201 returns the created Product', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_productResponseJson()),
          201,
          headers: _jsonHeaders,
        ),
      );

      final product = await repository.create(
        code: 'SKU-001',
        name: 'Widget',
        unitOfMeasurement: 'PCE',
        taxRate: '0.16',
      );

      expect(product.code, 'SKU-001');
      expect(product.deactivated, isFalse);
    });

    test('422 duplicate code maps to AppError.validation', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'code'],
                'msg': 'Code already in use',
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
          code: 'SKU-001',
          name: 'Widget',
          unitOfMeasurement: 'PCE',
        ),
        throwsA(isA<ValidationError>()),
      );
    });

    test('422 name too short maps to AppError.validation', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'name'],
                'msg': 'String should have at least 4 characters',
                'type': 'string_too_short',
              },
            ],
          }),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.create(
          code: 'SKU-002',
          name: 'Hi',
          unitOfMeasurement: 'PCE',
        ),
        throwsA(isA<ValidationError>()),
      );
    });

    test('422 invalid barcode maps to AppError.validation', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'bar_code'],
                'msg': 'Barcode must be empty or exactly 13 digits (EAN-13)',
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
          code: 'SKU-003',
          name: 'Widget',
          unitOfMeasurement: 'PCE',
          barCode: '12345',
        ),
        throwsA(isA<ValidationError>()),
      );
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
        throwsA(const AppError.notFound('Product not found')),
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
  group('ProductRepositoryImpl.update', () {
    test('200 returns the updated Product', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({..._productResponseJson(), 'name': 'Updated Widget'}),
          200,
          headers: _jsonHeaders,
        ),
      );

      final product = await repository.update(productId: 1, name: 'Updated Widget');

      expect(product.name, 'Updated Widget');
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
        () => repository.update(productId: 999, name: 'Anything'),
        throwsA(const AppError.notFound('Product not found')),
      );
    });

    test('422 duplicate code on rename maps to AppError.validation', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'code'],
                'msg': 'Code already in use',
                'type': 'value_error',
              },
            ],
          }),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.update(productId: 1, code: 'SKU-EXISTING'),
        throwsA(isA<ValidationError>()),
      );
    });

    test('a deactivate-only call sends just {deactivated: true}', () async {
      late Object? sentData;
      final repository = _repositoryWith((options) async {
        sentData = options.data;
        return ResponseBody.fromString(
          jsonEncode({..._productResponseJson(), 'deactivated': true}),
          200,
          headers: _jsonHeaders,
        );
      });

      final product = await repository.update(productId: 1, deactivated: true);

      expect(product.deactivated, isTrue);
      final sentBody = sentData is String
          ? jsonDecode(sentData as String) as Map<String, Object?>
          : sentData as Map<String, Object?>;
      expect(sentBody['deactivated'], isTrue);
      expect(sentBody.containsKey('code'), isFalse);
      expect(sentBody.containsKey('name'), isFalse);
    });
  });

  group('ProductRepositoryImpl.uploadPhoto', () {
    test('200 sends a multipart "file" field and returns the updated '
        'Product', () async {
      late RequestOptions sentOptions;
      final repository = _repositoryWith((options) async {
        sentOptions = options;
        return ResponseBody.fromString(
          jsonEncode({
            ..._productResponseJson(),
            'photo': 'http://test/images/abc123.png',
          }),
          200,
          headers: _jsonHeaders,
        );
      });

      final product = await repository.uploadPhoto(
        productId: 1,
        bytes: Uint8List.fromList([1, 2, 3]),
        filename: 'photo.png',
      );

      expect(product.photo, 'http://test/images/abc123.png');
      expect(sentOptions.path, '/api/v1/products/1/image');
      expect(sentOptions.method, 'POST');
      final formData = sentOptions.data as FormData;
      expect(formData.files.single.key, 'file');
      expect(formData.files.single.value.filename, 'photo.png');
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
        () => repository.uploadPhoto(
          productId: 999,
          bytes: Uint8List.fromList([1]),
          filename: 'photo.png',
        ),
        throwsA(const AppError.notFound('Product not found')),
      );
    });

    test('422 unsupported type / oversized file maps to '
        'AppError.validation', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'File exceeds the 2 MB limit'}),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.uploadPhoto(
          productId: 1,
          bytes: Uint8List.fromList([1]),
          filename: 'photo.png',
        ),
        throwsA(isA<ValidationError>()),
      );
    });

    test('a connection failure maps to AppError.network', () async {
      final repository = _repositoryWith(
        (options) async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'Connection dropped mid-upload',
        ),
      );

      await expectLater(
        () => repository.uploadPhoto(
          productId: 1,
          bytes: Uint8List.fromList([1]),
          filename: 'photo.png',
        ),
        throwsA(isA<NetworkError>()),
      );
    });
  });

  group('ProductRepositoryImpl.removePhoto', () {
    test('200 sends {"photo": null} and returns the updated Product',
        () async {
      late Object? sentData;
      late String sentPath;
      late String sentMethod;
      final repository = _repositoryWith((options) async {
        sentData = options.data;
        sentPath = options.path;
        sentMethod = options.method;
        return ResponseBody.fromString(
          jsonEncode({..._productResponseJson(), 'photo': null}),
          200,
          headers: _jsonHeaders,
        );
      });

      final product = await repository.removePhoto(productId: 1);

      expect(product.photo, isNull);
      expect(sentPath, '/api/v1/products/1');
      expect(sentMethod, 'PUT');
      final sentBody = sentData is String
          ? jsonDecode(sentData as String) as Map<String, Object?>
          : sentData as Map<String, Object?>;
      expect(sentBody.containsKey('photo'), isTrue);
      expect(sentBody['photo'], isNull);
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
        () => repository.removePhoto(productId: 999),
        throwsA(const AppError.notFound('Product not found')),
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
        () => repository.removePhoto(productId: 1),
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
