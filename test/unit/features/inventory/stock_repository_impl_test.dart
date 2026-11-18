import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/stock_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

Map<String, Object?> _rowJson({
  int warehouse = 3,
  String? productCode = 'A-100',
  String? productName = 'Tornillo',
  String onHand = '10.5',
}) => {
  'product': 7,
  'product_code': productCode,
  'product_name': productName,
  'warehouse': warehouse,
  'on_hand': onHand,
  'reserved': '2',
  'available': '8.5',
  'incoming': '1',
};

void main() {
  test('list always sends the warehouse, and the search only when it is not '
      'empty', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((options) async {
      requests.add(options);
      return _ok({'items': <Object>[], 'total': 0});
    });

    await repository.list(
      warehouseId: 3,
      q: 'torn',
      includeZero: true,
      skip: 100,
      limit: 50,
    );
    await repository.list(
      warehouseId: 4,
      includeZero: false,
      skip: 0,
      limit: 500,
    );

    expect(requests[0].path, '/api/v1/stock');
    expect(requests[0].queryParameters, {
      'warehouse': 3,
      'q': 'torn',
      'include_zero': true,
      'skip': 100,
      'limit': 50,
    });
    expect(requests[1].queryParameters, {
      'warehouse': 4,
      'include_zero': false,
      'skip': 0,
      'limit': 500,
    });
  });

  test('list maps each row, a negative on-hand as negative and missing '
      'names as empty', () async {
    final repository = _repositoryWith(
      (options) async => _ok({
        'items': [
          _rowJson(),
          _rowJson(onHand: '-3', productCode: null, productName: null),
        ],
        'total': 41,
      }),
    );

    final page = await repository.list(
      warehouseId: 3,
      includeZero: false,
      skip: 0,
      limit: 50,
    );

    expect(page.total, 41);
    final row = page.items.first;
    expect(row.productId, 7);
    expect(row.productCode, 'A-100');
    expect(row.productName, 'Tornillo');
    expect(row.warehouseId, 3);
    expect(row.onHand, Decimal.parse('10.5'));
    expect(row.reserved, Decimal.parse('2'));
    expect(row.available, Decimal.parse('8.5'));
    expect(row.incoming, Decimal.one);
    expect(page.items.last.onHand, Decimal.parse('-3'));
    expect(page.items.last.productCode, '');
    expect(page.items.last.productName, '');
  });

  test('product maps the warehouses and the in-transit holdings, with '
      'totals over the warehouses', () async {
    final requests = <RequestOptions>[];
    final repository = _repositoryWith((options) async {
      requests.add(options);
      return _ok({
        'product': 7,
        'warehouses': [_rowJson(), _rowJson(warehouse: 4, onHand: '-0.5')],
        'in_transit': [
          {'facility': 2, 'warehouse': 9, 'on_hand': '4'},
        ],
      });
    });

    final stock = await repository.product(7);

    expect(requests.single.path, '/api/v1/stock/products/7');
    expect(stock.productId, 7);
    expect(stock.warehouses.map((w) => w.warehouseId), [3, 4]);
    expect(stock.inTransit.single.facilityId, 2);
    expect(stock.inTransit.single.warehouseId, 9);
    expect(stock.inTransit.single.onHand, Decimal.parse('4'));
    expect(stock.totals.onHand, Decimal.parse('10'));
    expect(stock.totals.reserved, Decimal.parse('4'));
    expect(stock.totals.available, Decimal.parse('17'));
    expect(stock.totals.incoming, Decimal.parse('2'));
    expect(stock.isEmpty, isFalse);
  });

  test('product maps null lists to empty', () async {
    final repository = _repositoryWith(
      (options) async =>
          _ok({'product': 7, 'warehouses': null, 'in_transit': null}),
    );

    final stock = await repository.product(7);

    expect(stock.warehouses, isEmpty);
    expect(stock.inTransit, isEmpty);
    expect(stock.isEmpty, isTrue);
    expect(stock.totals.onHand, Decimal.zero);
  });

  test('an in-transit warehouse refusal becomes a coded AppError that keeps '
      'its params', () async {
    final repository = _repositoryWith(
      (options) async => ResponseBody.fromString(
        jsonEncode({
          'detail': 'In-transit location',
          'code': 'warehouse.in_transit_location',
          'params': {'warehouse': 9},
        }),
        422,
        headers: _jsonHeaders,
      ),
    );

    await expectLater(
      repository.list(warehouseId: 9, includeZero: false, skip: 0, limit: 50),
      throwsA(
        isA<AppError>()
            .having(
              (e) => e.problem?.code,
              'code',
              api.ErrorCode.warehousePeriodInTransitLocation,
            )
            .having((e) => e.problem?.params['warehouse'], 'params', 9),
      ),
    );
  });
}

ResponseBody _ok(Object body) =>
    ResponseBody.fromString(jsonEncode(body), 200, headers: _jsonHeaders);

StockRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return StockRepositoryImpl(dio);
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
