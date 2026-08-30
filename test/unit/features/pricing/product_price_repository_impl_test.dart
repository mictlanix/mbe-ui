import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/product_price_repository.dart';

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
      // `product` repeats since mbe-api#182, so one id goes over the wire as
      // a one-element list rather than a bare int.
      final param = captured!.queryParameters['product'] as ListParam;
      expect(param.value, [1]);
      expect(param.format, ListFormat.multi);
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
    'ProductPriceRepositoryImpl.listForProducts (spec 033 research.md §R5)',
    () {
      test(
        'asks for every product in ONE request, repeating `product` '
        '(mbe-api#182 — this method shipped as a fan-out and collapsed here)',
        () async {
          var calls = 0;
          RequestOptions? captured;
          final repository = _repositoryWith((options) async {
            calls++;
            captured = options;
            return ResponseBody.fromString(
              jsonEncode({
                'items': [
                  {..._productPriceJson(), 'product_price_id': 1, 'product': 1},
                  {..._productPriceJson(), 'product_price_id': 2, 'product': 2},
                  {..._productPriceJson(), 'product_price_id': 3, 'product': 3},
                ],
                'total': 3,
              }),
              200,
              headers: _jsonHeaders,
            );
          });

          final prices = await repository.listForProducts(
            productIds: [1, 2, 3],
            priceListIds: [5],
          );

          expect(calls, 1);
          // `multi`, not CSV: the server reads `?product=1&product=2&product=3`.
          final param = captured!.queryParameters['product'] as ListParam;
          expect(param.value, [1, 2, 3]);
          expect(param.format, ListFormat.multi);
          expect(prices, hasLength(3));
        },
      );

      test(
        'asks for a page big enough to hold products x lists — the API caps '
        'both the read and the bulk write at BULK_LIMIT, and a truncated '
        'page reads as "these products have no price"',
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

          await repository.listForProducts(productIds: [1], priceListIds: [5]);

          expect(captured!.queryParameters['limit'], kProductPriceBulkLimit);
        },
      );

      test('filters to the given price-list ids', () async {
        var call = 0;
        final repository = _repositoryWith((options) async {
          call++;
          return ResponseBody.fromString(
            jsonEncode({
              'items': [
                _productPriceJson(),
                {
                  ..._productPriceJson(),
                  'product_price_id': 2,
                  'price_list': {
                    'price_list_id': 9,
                    'name': 'Wholesale',
                    'high_profit_margin': '0.40',
                    'low_profit_margin': '0.10',
                  },
                },
              ],
              'total': 2,
            }),
            200,
            headers: _jsonHeaders,
          );
        });

        final prices = await repository.listForProducts(
          productIds: [1],
          priceListIds: [5],
        );

        expect(call, 1);
        expect(prices, hasLength(1));
        expect(prices.single.priceList.priceListId, 5);
      });

      test('issues no request for an empty product list', () async {
        var calls = 0;
        final repository = _repositoryWith((options) async {
          calls++;
          return ResponseBody.fromString('', 500);
        });

        final prices = await repository.listForProducts(
          productIds: const [],
          priceListIds: const [5],
        );

        expect(prices, isEmpty);
        expect(calls, 0);
      });
    },
  );

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
        );

        expect(price.price, '120.00');
      });

      test('⚠️ MANDATORY: sends price as a JSON decimal string, not '
          'num/null/{} (research.md §4, plan.md Risks — the codebase\'s '
          'first AnyOf construction site)', () async {
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
        );

        final sentBody = _decodeBody(captured!.data);
        expect(sentBody['price'], '120.00');
        expect(sentBody['price'], isA<String>());
        expect(sentBody['product'], 1);
        expect(sentBody['price_list'], 5);
        // Never a profit band: deprecated since mbe-api#185, and a created
        // row takes the price list's margins server-side (spec 033 US7).
        expect(sentBody['low_profit'], isNull);
        expect(sentBody['high_profit'], isNull);
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
        );

        expect(price.price, '130.00');
      });

      test('⚠️ MANDATORY: sends the update-side wrapper value as a JSON '
          'decimal string too (`Price1`, not `Price` — research.md §4)', () async {
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
        );

        final sentBody = _decodeBody(captured!.data);
        expect(sentBody['price'], '130.00');
        expect(sentBody['price'], isA<String>());
        // Omitted, which mbe-api#185 reads as "leave the stored band alone".
        expect(sentBody['low_profit'], isNull);
        expect(sentBody['high_profit'], isNull);
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
          ),
          throwsA(const AppError.notFound('Product price not found')),
        );
      });
    },
  );

  group(
    'ProductPriceRepositoryImpl.applyPriceChanges — bulk upsert (mbe-api#183)',
    () {
      test('sends one body item per write, keyed on (product, price_list), '
          'with the price as a decimal string', () async {
        RequestOptions? captured;
        final repository = _repositoryWith((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode([_productPriceJson()]),
            200,
            headers: _jsonHeaders,
          );
        });

        await repository.applyPriceChanges(const [
          PriceCellWrite(productId: 1, priceListId: 5, price: '10.00'),
          PriceCellWrite(productId: 2, priceListId: 5, price: '20.00'),
        ]);

        expect(captured!.method, 'PUT');
        expect(captured!.path, '/api/v1/product-prices');
        final body = _decodeList(captured!.data);
        expect(body, hasLength(2));
        expect(body[0]['product'], 1);
        expect(body[0]['price_list'], 5);
        expect(body[0]['price'], '10.00');
        expect(body[0]['price'], isA<String>());
        expect(body[1]['product'], 2);
        expect(body[1]['price'], '20.00');
      });

      test(
        'names no profit band — a created row takes the price list margins '
        'server-side, an updated one keeps what it had (mbe-api#185)',
        () async {
          RequestOptions? captured;
          final repository = _repositoryWith((options) async {
            captured = options;
            return ResponseBody.fromString(
              jsonEncode([_productPriceJson()]),
              200,
              headers: _jsonHeaders,
            );
          });

          await repository.applyPriceChanges(const [
            PriceCellWrite(productId: 1, priceListId: 5, price: '10.00'),
          ]);

          final item = _decodeList(captured!.data).single;
          expect(item.containsKey('low_profit'), isFalse);
          expect(item.containsKey('high_profit'), isFalse);
        },
      );

      test('maps the response rows back to ProductPrice entities', () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode([
              _productPriceJson(),
              {..._productPriceJson(), 'product_price_id': 2, 'price': '20.00'},
            ]),
            200,
            headers: _jsonHeaders,
          ),
        );

        final prices = await repository.applyPriceChanges(const [
          PriceCellWrite(productId: 1, priceListId: 5, price: '10.00'),
          PriceCellWrite(productId: 2, priceListId: 5, price: '20.00'),
        ]);

        expect(prices, hasLength(2));
        expect(prices[1].price, '20.00');
      });

      test('issues no request for an empty write list', () async {
        var calls = 0;
        final repository = _repositoryWith((options) async {
          calls++;
          return ResponseBody.fromString('[]', 200, headers: _jsonHeaders);
        });

        expect(await repository.applyPriceChanges(const []), isEmpty);
        expect(calls, 0);
      });

      test(
        'a 400 on a duplicate (product, price_list) surfaces as a domain '
        'error rather than a raw DioException — the server refuses to '
        'resolve two cells for one cell, and so must the client',
        () async {
          final repository = _repositoryWith(
            (options) async => ResponseBody.fromString(
              jsonEncode({
                'detail': 'Duplicate entry for product 1 on price list 5',
              }),
              400,
              headers: _jsonHeaders,
            ),
          );

          await expectLater(
            () => repository.applyPriceChanges(const [
              PriceCellWrite(productId: 1, priceListId: 5, price: '10.00'),
              PriceCellWrite(productId: 1, priceListId: 5, price: '11.00'),
            ]),
            throwsA(isA<AppError>()),
          );
        },
      );

      test('5xx maps to AppError.server, leaving no row changed', () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString('', 503),
        );

        await expectLater(
          () => repository.applyPriceChanges(const [
            PriceCellWrite(productId: 1, priceListId: 5, price: '10.00'),
          ]),
          throwsA(const AppError.server(statusCode: 503)),
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

List<Map<String, Object?>> _decodeList(Object? data) {
  final decoded = data is String ? jsonDecode(data) : data;
  return (decoded as List).cast<Map<String, Object?>>();
}

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
