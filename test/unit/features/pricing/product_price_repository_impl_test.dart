import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('ProductPriceRepositoryImpl.listByProduct', () {
    test(
      '200 maps the nested price_list object, not an id (research.md §5)',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({
              'items': [_productPriceJson()],
              'total': 1,
            }),
            200,
            headers: _jsonHeaders,
          ),
        );

        final prices = await repository.listByProduct(productId: 1, limit: 100);

        expect(prices, hasLength(1));
        expect(prices.single.productPriceId, 1);
        expect(prices.single.productId, 1);
        expect(prices.single.priceList.priceListId, 5);
        expect(prices.single.priceList.name, 'Retail');
        expect(prices.single.price, '120.00');
      },
    );

    test('passes an explicit limit rather than relying on the API default of '
        '20 (contracts/mbe-api-pricing.md G5)', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode({'items': [], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.listByProduct(productId: 1, limit: 50);

      expect(captured!.queryParameters['limit'], 50);
      expect(captured!.queryParameters['product'], 1);
    });

    test('5xx maps to AppError.server', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 503),
      );

      await expectLater(
        () => repository.listByProduct(productId: 1, limit: 20),
        throwsA(const AppError.server(statusCode: 503)),
      );
    });
  });

  group(
    'ProductPriceRepositoryImpl.create — AnyOf write path (research.md §4)',
    () {
      test('201 returns the created ProductPrice', () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode(_productPriceJson()),
            201,
            headers: _jsonHeaders,
          ),
        );

        final price = await repository.create(
          productId: 1,
          priceListId: 5,
          price: '120.00',
          lowProfit: '90.00',
          highProfit: '150.00',
        );

        expect(price.price, '120.00');
      });

      test('⚠️ MANDATORY: sends price/low_profit/high_profit as JSON decimal '
          'strings, not num/null/{} (research.md §4, plan.md Risks — the '
          'codebase\'s first AnyOf construction site)', () async {
        RequestOptions? captured;
        final repository = _repositoryWith((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode(_productPriceJson()),
            201,
            headers: _jsonHeaders,
          );
        });

        await repository.create(
          productId: 1,
          priceListId: 5,
          price: '120.00',
          lowProfit: '90.50',
          highProfit: '150.25',
        );

        final sentBody = _decodeBody(captured!.data);
        expect(sentBody['price'], '120.00');
        expect(sentBody['price'], isA<String>());
        expect(sentBody['low_profit'], '90.50');
        expect(sentBody['low_profit'], isA<String>());
        expect(sentBody['high_profit'], '150.25');
        expect(sentBody['high_profit'], isA<String>());
        expect(sentBody['product'], 1);
        expect(sentBody['price_list'], 5);
      });

      test('422 maps to AppError.validation', () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({
              'detail': [
                {
                  'loc': ['body', 'price'],
                  'msg': 'Input should be a valid decimal',
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
            productId: 1,
            priceListId: 5,
            price: 'not-a-number',
            lowProfit: '0',
            highProfit: '0',
          ),
          throwsA(isA<ValidationError>()),
        );
      });
    },
  );

  group(
    'ProductPriceRepositoryImpl.update — AnyOf write path (Price1-style)',
    () {
      test('200 returns the updated ProductPrice', () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({..._productPriceJson(), 'price': '130.00'}),
            200,
            headers: _jsonHeaders,
          ),
        );

        final price = await repository.update(
          productPriceId: 1,
          price: '130.00',
          lowProfit: '90.00',
          highProfit: '150.00',
        );

        expect(price.price, '130.00');
      });

      test('⚠️ MANDATORY: sends the update-side wrapper values as JSON decimal '
          'strings too (Price1/LowProfit1/HighProfit1, not Price/LowProfit/'
          'HighProfit — research.md §4)', () async {
        RequestOptions? captured;
        final repository = _repositoryWith((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode(_productPriceJson()),
            200,
            headers: _jsonHeaders,
          );
        });

        await repository.update(
          productPriceId: 1,
          price: '130.00',
          lowProfit: '95.00',
          highProfit: '160.00',
        );

        final sentBody = _decodeBody(captured!.data);
        expect(sentBody['price'], '130.00');
        expect(sentBody['price'], isA<String>());
        expect(sentBody['low_profit'], '95.00');
        expect(sentBody['high_profit'], '160.00');
        // The update DTO carries no product/price_list — a row cannot be
        // moved between products or lists, only revalued (data-model.md §2).
        expect(sentBody.containsKey('product'), isFalse);
        expect(sentBody.containsKey('price_list'), isFalse);
      });

      test('404 maps to AppError.notFound', () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({'detail': 'Product price not found'}),
            404,
            headers: _jsonHeaders,
          ),
        );

        await expectLater(
          () => repository.update(
            productPriceId: 999,
            price: '1',
            lowProfit: '1',
            highProfit: '1',
          ),
          throwsA(const AppError.notFound('Product price not found')),
        );
      });
    },
  );
}

Map<String, Object?> _productPriceJson() => {
  'product_price_id': 1,
  'product': 1,
  'price_list': {
    'price_list_id': 5,
    'name': 'Retail',
    'high_profit_margin': '0.40',
    'low_profit_margin': '0.10',
  },
  'price': '120.00',
  'low_profit': '90.00',
  'high_profit': '150.00',
};

Map<String, Object?> _decodeBody(Object? data) => data is String
    ? jsonDecode(data) as Map<String, Object?>
    : data as Map<String, Object?>;

ProductPriceRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return ProductPriceRepositoryImpl(dio);
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
