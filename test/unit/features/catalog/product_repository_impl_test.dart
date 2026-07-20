import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
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
                'unit_of_measurement': {
                  'id': 'PCE',
                  'name': 'Piece',
                  'description': null,
                  'symbol': null,
                },
                'tax_rate': '0.16',
                'status': 0,
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
      expect(result.items.single.status, EntityStatus.active);
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

    test(
      'sends every selected label as a repeated query param (FR-008)',
      () async {
        RequestOptions? captured;
        final repository = _repositoryWith((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode({'items': [], 'total': 0}),
            200,
            headers: _jsonHeaders,
          );
        });

        await repository.list(labels: [5, 6, 7]);

        final label = captured!.queryParameters['label'] as ListParam;
        expect(label.value, [5, 6, 7]);
        expect(label.format, ListFormat.multi);
      },
    );

    test('omits the label param when no labels are selected', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode({'items': [], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.list();

      expect(captured!.queryParameters.containsKey('label'), isFalse);
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
      expect(product.status, EntityStatus.active);
    });

    test('sends sku in the request body', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_productResponseJson()),
          201,
          headers: _jsonHeaders,
        );
      });

      await repository.create(
        code: 'SKU-001',
        name: 'Widget',
        unitOfMeasurement: 'PCE',
        sku: 'SKU-NEW',
      );

      expect((captured!.data as Map)['sku'], 'SKU-NEW');
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
      expect(product.unitOfMeasurementCode, 'PCE');
      expect(product.status, EntityStatus.active);
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

  group('ProductRepositoryImpl.delete', () {
    test('204 completes with no error (hard delete)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );

      await expectLater(repository.delete(productId: 1), completes);
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
        () => repository.delete(productId: 999),
        throwsA(const AppError.notFound('Product not found')),
      );
    });

    test('a referential-integrity rejection surfaces the server message '
        '(FR-016b)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': 'Product is referenced by existing sales orders',
          }),
          400,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.delete(productId: 1),
        throwsA(
          const AppError.server(
            statusCode: 400,
            message: 'Product is referenced by existing sales orders',
          ),
        ),
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
        () => repository.delete(productId: 1),
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

      final product = await repository.update(
        productId: 1,
        name: 'Updated Widget',
      );

      expect(product.name, 'Updated Widget');
    });

    test('sends sku in the request body when provided', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_productResponseJson()),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.update(productId: 1, sku: 'SKU-NEW');

      expect((captured!.data as Map)['sku'], 'SKU-NEW');
    });

    test('omits sku from the request body when not provided', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_productResponseJson()),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.update(productId: 1, name: 'Updated Widget');

      expect((captured!.data as Map).containsKey('sku'), isFalse);
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

    test('a deactivate-only call sends just {status: inactive}', () async {
      late Object? sentData;
      final repository = _repositoryWith((options) async {
        sentData = options.data;
        return ResponseBody.fromString(
          jsonEncode({..._productResponseJson(), 'status': 1}),
          200,
          headers: _jsonHeaders,
        );
      });

      final product = await repository.update(
        productId: 1,
        status: EntityStatus.inactive,
      );

      expect(product.status, EntityStatus.inactive);
      final sentBody = sentData is String
          ? jsonDecode(sentData as String) as Map<String, Object?>
          : sentData as Map<String, Object?>;
      expect(sentBody['status'], 1);
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
    test('200 sends {"photo": null} and returns the updated Product', () async {
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

  group('ProductRepositoryImpl.productLabelFacets', () {
    test('200 maps rows to ProductLabelFacet entities', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode([
            {'label_id': 3, 'count': 42},
            {'label_id': 7, 'count': 12},
          ]),
          200,
          headers: _jsonHeaders,
        ),
      );

      final facets = await repository.productLabelFacets();

      expect(facets, hasLength(2));
      expect(facets[0].labelId, 3);
      expect(facets[0].count, 42);
      expect(facets[1].labelId, 7);
      expect(facets[1].count, 12);
    });

    test('200 with an empty array returns an empty list', () async {
      final repository = _repositoryWith(
        (options) async =>
            ResponseBody.fromString('[]', 200, headers: _jsonHeaders),
      );

      final facets = await repository.productLabelFacets();

      expect(facets, isEmpty);
    });

    test('forwards search/attribute filters and every selected label as a '
        'repeated query param, without skip/limit', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString('[]', 200, headers: _jsonHeaders);
      });

      await repository.productLabelFacets(
        search: 'drill',
        status: EntityStatus.active,
        stockable: true,
        labels: [1, 2],
      );

      expect(captured!.path, '/api/v1/products/labels/facets');
      expect(captured!.queryParameters['search'], 'drill');
      expect(captured!.queryParameters['status'], 0);
      expect(captured!.queryParameters['stockable'], true);
      final label = captured!.queryParameters['label'] as ListParam;
      expect(label.value, [1, 2]);
      expect(label.format, ListFormat.multi);
      expect(captured!.queryParameters.containsKey('skip'), isFalse);
      expect(captured!.queryParameters.containsKey('limit'), isFalse);
    });

    test('omits the label param when no labels are selected', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString('[]', 200, headers: _jsonHeaders);
      });

      await repository.productLabelFacets();

      expect(captured!.queryParameters.containsKey('label'), isFalse);
    });

    test('5xx maps to AppError.server', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 503),
      );

      await expectLater(
        () => repository.productLabelFacets(),
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

      await expectLater(
        () => repository.productLabelFacets(),
        throwsA(isA<NetworkError>()),
      );
    });
  });

  group('ProductRepositoryImpl.mergeProducts', () {
    test('204 completes with no error', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );

      await expectLater(
        repository.mergeProducts(productId: 1, duplicateId: 2),
        completes,
      );
    });

    test('sends product_id and duplicate_id in the request body', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString('', 204);
      });

      await repository.mergeProducts(productId: 1, duplicateId: 2);

      expect(captured!.path, '/api/v1/products/merge');
      expect(captured!.method, 'POST');
      final sentBody = captured!.data is String
          ? jsonDecode(captured!.data as String) as Map<String, Object?>
          : captured!.data as Map<String, Object?>;
      expect(sentBody['product_id'], 1);
      expect(sentBody['duplicate_id'], 2);
    });

    test('400 self-merge maps to AppError.server', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Cannot merge a product with itself'}),
          400,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.mergeProducts(productId: 1, duplicateId: 1),
        throwsA(
          const AppError.server(
            statusCode: 400,
            message: 'Cannot merge a product with itself',
          ),
        ),
      );
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Duplicate product not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.mergeProducts(productId: 1, duplicateId: 999),
        throwsA(const AppError.notFound('Duplicate product not found')),
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
        () => repository.mergeProducts(productId: 1, duplicateId: 2),
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
  'unit_of_measurement': {
    'id': 'PCE',
    'name': 'Piece',
    'description': null,
    'symbol': null,
  },
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
  'status': 0,
  'comment': null,
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
  ) => _handler(options);

  @override
  void close({bool force = false}) {}
}
