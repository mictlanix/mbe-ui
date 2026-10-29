import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/customer_refund_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

Map<String, dynamic> _lineJson() => {
  'customer_refund_detail_id': 11,
  'sales_order_detail': 511,
  'product': 711,
  'product_code': 'TOR-08',
  'product_name': 'Tornillo',
  'quantity': '10.000000',
  'price': '2.5000',
  'discount': '0.000000',
  'tax_rate': '0.160000',
  'tax_included': false,
  'currency': 0,
  'warehouse': 3,
  'refundable_quantity': '50.000000',
  'subtotal': '25.0000',
  'tax_total': '4.0000',
  'total': '29.0000',
};

Map<String, dynamic> _refundJson({String status = 'draft'}) => {
  'customer_refund_id': 9,
  'sales_order': 42,
  'customer': 7,
  'sales_person': 100,
  'facility': 8,
  'serial': null,
  'date': null,
  'currency': 0,
  'exchange_rate': '1.000000',
  'status': status,
  'lines': [_lineJson()],
  'subtotal': '25.0000',
  'tax_total': '4.0000',
  'total': '29.0000',
};

Map<String, dynamic> _summaryJson(int id) => {
  'customer_refund_id': id,
  'sales_order': 42,
  'customer': null,
  'serial': null,
  'date': null,
  'currency': 0,
  'status': 'draft',
  'total': '29.0000',
};

ResponseBody _json(Object body, [int status = 200]) =>
    ResponseBody.fromString(jsonEncode(body), status, headers: _jsonHeaders);

void main() {
  group('list', () {
    test('sends the filters and paging as given', () async {
      late RequestOptions seen;
      final repository = _repositoryWith((options) async {
        seen = options;
        return _json({
          'items': [_summaryJson(1), _summaryJson(2)],
          'total': 57,
        });
      });

      final page = await repository.list(
        status: RefundStatus.completed,
        customerId: 7,
        salesOrderId: 42,
        skip: 40,
        limit: 20,
      );

      expect(seen.path, endsWith('/api/v1/customer-refunds'));
      expect(seen.queryParameters['customer'], 7);
      expect(seen.queryParameters['sales_order'], 42);
      expect(seen.queryParameters['status'], 'completed');
      expect(seen.queryParameters['skip'], 40);
      expect(seen.queryParameters['limit'], 20);
      expect(page.total, 57);
      expect(page.items.map((r) => r.id), [1, 2]);
    });

    test('sends no status when the filter is null', () async {
      late RequestOptions seen;
      final repository = _repositoryWith((options) async {
        seen = options;
        return _json({'items': <Object>[], 'total': 0});
      });

      await repository.list(skip: 0, limit: 20);

      expect(seen.queryParameters.containsKey('status'), isFalse);
      expect(seen.queryParameters.containsKey('customer'), isFalse);
      expect(seen.queryParameters.containsKey('sales_order'), isFalse);
    });

    test('each status filter sends its wire name', () async {
      final sent = <Object?>[];
      final repository = _repositoryWith((options) async {
        sent.add(options.queryParameters['status']);
        return _json({'items': <Object>[], 'total': 0});
      });

      for (final s in RefundStatus.values) {
        await repository.list(status: s, skip: 0, limit: 20);
      }

      expect(sent, ['draft', 'completed', 'cancelled']);
    });
  });

  test('getById reads the refund by id', () async {
    late RequestOptions seen;
    final repository = _repositoryWith((options) async {
      seen = options;
      return _json(_refundJson());
    });

    final refund = await repository.getById(9);

    expect(seen.method, 'GET');
    expect(seen.path, endsWith('/api/v1/customer-refunds/9'));
    expect(refund.id, 9);
    expect(refund.total, '29.0000');
  });

  test('open sends sales_order', () async {
    late RequestOptions seen;
    final repository = _repositoryWith((options) async {
      seen = options;
      return _json(_refundJson(), 201);
    });

    final refund = await repository.open(42);

    expect(seen.method, 'POST');
    expect(seen.path, endsWith('/api/v1/customer-refunds'));
    expect(seen.data, {'sales_order': 42});
    expect(refund.salesOrderId, 42);
  });

  group('updateLine', () {
    test('sends quantity as a string and omits an unset warehouse', () async {
      late RequestOptions seen;
      final repository = _repositoryWith((options) async {
        seen = options;
        return _json(_refundJson());
      });

      await repository.updateLine(9, 11, quantity: '10');

      expect(seen.method, 'PUT');
      expect(seen.path, endsWith('/api/v1/customer-refunds/9/lines/11'));
      expect(seen.data, {'quantity': '10'});
    });

    test('sends the warehouse alone when no quantity is given', () async {
      late RequestOptions seen;
      final repository = _repositoryWith((options) async {
        seen = options;
        return _json(_refundJson());
      });

      await repository.updateLine(9, 11, warehouseId: 4);

      expect(seen.data, {'warehouse': 4});
    });
  });

  group('confirm', () {
    test('sends the payout wire value', () async {
      final bodies = <Object?>[];
      late RequestOptions seen;
      final repository = _repositoryWith((options) async {
        seen = options;
        bodies.add(options.data);
        return _json(_refundJson(status: 'completed'));
      });

      final refund = await repository.confirm(9, RefundPayout.creditNote);
      await repository.confirm(9, RefundPayout.cash);

      expect(seen.method, 'POST');
      expect(seen.path, endsWith('/api/v1/customer-refunds/9/confirm'));
      expect(bodies, [
        {'payout': 'credit_note'},
        {'payout': 'cash'},
      ]);
      expect(refund.status, RefundStatus.completed);
    });
  });

  test('cancel posts to the cancel endpoint', () async {
    late RequestOptions seen;
    final repository = _repositoryWith((options) async {
      seen = options;
      return _json(_refundJson(status: 'cancelled'));
    });

    final refund = await repository.cancel(9);

    expect(seen.method, 'POST');
    expect(seen.path, endsWith('/api/v1/customer-refunds/9/cancel'));
    expect(refund.status, RefundStatus.cancelled);
  });

  group('errors', () {
    test('a null body becomes AppError.server', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 200),
      );

      await expectLater(() => repository.getById(9), throwsA(isA<AppError>()));
      await expectLater(
        () => repository.list(skip: 0, limit: 20),
        throwsA(isA<AppError>()),
      );
    });

    test('a 404 becomes NotFoundError', () async {
      final repository = _repositoryWith(
        (options) async => _json({'detail': 'Customer refund not found'}, 404),
      );

      await expectLater(
        () => repository.getById(9),
        throwsA(isA<NotFoundError>()),
      );
    });
  });
}

CustomerRefundRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return CustomerRefundRepositoryImpl(dio);
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
