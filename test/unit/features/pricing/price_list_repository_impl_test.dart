import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('PriceListRepositoryImpl.list', () {
    test('200 returns items and total', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_priceListJson()],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();

      expect(result.total, 1);
      expect(result.items, hasLength(1));
      expect(result.items.single.priceListId, 1);
      expect(result.items.single.name, 'Retail');
      expect(result.items.single.highProfitMargin, '0.40');
      expect(result.items.single.lowProfitMargin, '0.10');
    });

    test('forwards search/skip/limit as query params', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode({'items': [], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.list(search: 'Retail', skip: 20, limit: 10);

      expect(captured!.queryParameters['search'], 'Retail');
      expect(captured!.queryParameters['skip'], 20);
      expect(captured!.queryParameters['limit'], 10);
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

  group('PriceListRepositoryImpl.get', () {
    test('200 maps to a PriceList', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_priceListJson()),
          200,
          headers: _jsonHeaders,
        ),
      );

      final priceList = await repository.get(priceListId: 1);

      expect(priceList.priceListId, 1);
      expect(priceList.name, 'Retail');
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Price list not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.get(priceListId: 999),
        throwsA(const AppError.notFound('Price list not found')),
      );
    });
  });

  group('PriceListRepositoryImpl.create', () {
    test('201 returns the created PriceList', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_priceListJson()),
          201,
          headers: _jsonHeaders,
        ),
      );

      final priceList = await repository.create(name: 'Retail');

      expect(priceList.name, 'Retail');
    });

    test('sends high_profit_margin and low_profit_margin as JSON strings, '
        'not numbers (research.md §4 — the AnyOf write path)', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_priceListJson()),
          201,
          headers: _jsonHeaders,
        );
      });

      await repository.create(
        name: 'Retail',
        highProfitMargin: '0.40',
        lowProfitMargin: '0.10',
      );

      final sentBody = _decodeBody(captured!.data);
      expect(sentBody['high_profit_margin'], '0.40');
      expect(sentBody['high_profit_margin'], isA<String>());
      expect(sentBody['low_profit_margin'], '0.10');
      expect(sentBody['low_profit_margin'], isA<String>());
    });

    test('omits margins from the request body when not provided', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_priceListJson()),
          201,
          headers: _jsonHeaders,
        );
      });

      await repository.create(name: 'Retail');

      final sentBody = _decodeBody(captured!.data);
      expect(sentBody.containsKey('high_profit_margin'), isFalse);
      expect(sentBody.containsKey('low_profit_margin'), isFalse);
    });

    test('422 duplicate name maps to AppError.validation', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'name'],
                'msg': 'Name already in use',
                'type': 'value_error',
              },
            ],
          }),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.create(name: 'Retail'),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('PriceListRepositoryImpl.update', () {
    test('200 returns the updated PriceList', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({..._priceListJson(), 'name': 'Retail Updated'}),
          200,
          headers: _jsonHeaders,
        ),
      );

      final priceList = await repository.update(
        priceListId: 1,
        name: 'Retail Updated',
      );

      expect(priceList.name, 'Retail Updated');
    });

    test('sends an updated margin as a JSON string via the update-side '
        'wrapper class (Price1-style, research.md §4)', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_priceListJson()),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.update(priceListId: 1, highProfitMargin: '0.50');

      final sentBody = _decodeBody(captured!.data);
      expect(sentBody['high_profit_margin'], '0.50');
      expect(sentBody['high_profit_margin'], isA<String>());
      expect(sentBody.containsKey('low_profit_margin'), isFalse);
      expect(sentBody.containsKey('name'), isFalse);
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Price list not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.update(priceListId: 999, name: 'Anything'),
        throwsA(const AppError.notFound('Price list not found')),
      );
    });
  });

  group('PriceListRepositoryImpl.delete', () {
    test('204 completes with no error', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );

      await expectLater(repository.delete(priceListId: 1), completes);
    });

    test(
      'a still-in-use rejection surfaces the server message (US1 §6)',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({'detail': 'Price list is assigned to a customer'}),
            400,
            headers: _jsonHeaders,
          ),
        );

        await expectLater(
          () => repository.delete(priceListId: 1),
          throwsA(
            const AppError.server(
              statusCode: 400,
              message: 'Price list is assigned to a customer',
            ),
          ),
        );
      },
    );

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Price list not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.delete(priceListId: 999),
        throwsA(const AppError.notFound('Price list not found')),
      );
    });
  });
}

Map<String, Object?> _priceListJson() => {
  'price_list_id': 1,
  'name': 'Retail',
  'high_profit_margin': '0.40',
  'low_profit_margin': '0.10',
};

Map<String, Object?> _decodeBody(Object? data) => data is String
    ? jsonDecode(data) as Map<String, Object?>
    : data as Map<String, Object?>;

PriceListRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return PriceListRepositoryImpl(dio);
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
