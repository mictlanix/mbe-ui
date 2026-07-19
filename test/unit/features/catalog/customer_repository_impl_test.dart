import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('CustomerRepositoryImpl.list', () {
    test(
      '200 maps expanded priceList/salesperson FKs to display names '
      '(research.md §7)',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({
              'items': [_customerJson()],
              'total': 1,
            }),
            200,
            headers: _jsonHeaders,
          ),
        );

        final result = await repository.list();

        expect(result.items.single.priceList.name, 'Retail');
        expect(result.items.single.salesperson?.name, 'Jane Doe');
      },
    );

    test('a null salesperson maps to no EmployeeRef', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_customerJson(salesperson: null)],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();

      expect(result.items.single.salesperson, isNull);
    });

    test(
      'forwards search/disabled/priceList/salesperson/skip/limit as query params',
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

        await repository.list(
          search: 'Acme',
          disabled: false,
          priceList: 1,
          salesperson: 2,
          skip: 20,
          limit: 10,
        );

        expect(captured!.queryParameters['search'], 'Acme');
        expect(captured!.queryParameters['disabled'], false);
        expect(captured!.queryParameters['price_list'], 1);
        expect(captured!.queryParameters['salesperson'], 2);
        expect(captured!.queryParameters['skip'], 20);
        expect(captured!.queryParameters['limit'], 10);
      },
    );
  });

  group('CustomerRepositoryImpl.get', () {
    test('200 maps to a Customer with expanded FKs', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_customerJson()),
          200,
          headers: _jsonHeaders,
        ),
      );

      final customer = await repository.get(customerId: 1);

      expect(customer.priceList.name, 'Retail');
      expect(customer.salesperson?.name, 'Jane Doe');
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Customer not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.get(customerId: 999),
        throwsA(const AppError.notFound('Customer not found')),
      );
    });
  });

  group('CustomerRepositoryImpl.create', () {
    test(
      'sends creditLimit as a JSON decimal string and priceList/salesperson '
      'as plain ids, not expanded objects (research.md §7)',
      () async {
        RequestOptions? captured;
        final repository = _repositoryWith((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode(_customerJson()),
            201,
            headers: _jsonHeaders,
          );
        });

        await repository.create(
          code: 'CUST-001',
          name: 'Acme Corp',
          priceList: 1,
          creditLimit: '1000.50',
          salesperson: 2,
        );

        final sentBody = _decodeBody(captured!.data);
        expect(sentBody['credit_limit'], '1000.50');
        expect(sentBody['credit_limit'], isA<String>());
        expect(sentBody['price_list'], 1);
        expect(sentBody['salesperson'], 2);
      },
    );

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
        () => repository.create(code: 'CUST-001', name: 'Acme Corp', priceList: 1),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('CustomerRepositoryImpl.update', () {
    test(
      'sends an updated creditLimit via the update-side wrapper class '
      '(CreditLimit1-style, research.md §4)',
      () async {
        RequestOptions? captured;
        final repository = _repositoryWith((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode(_customerJson()),
            200,
            headers: _jsonHeaders,
          );
        });

        await repository.update(customerId: 1, creditLimit: '2000.00');

        final sentBody = _decodeBody(captured!.data);
        expect(sentBody['credit_limit'], '2000.00');
        expect(sentBody['credit_limit'], isA<String>());
        expect(sentBody.containsKey('name'), isFalse);
      },
    );

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Customer not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.update(customerId: 999, name: 'Anything'),
        throwsA(const AppError.notFound('Customer not found')),
      );
    });
  });

  group('CustomerRepositoryImpl.delete', () {
    test('204 completes with no error', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );

      await expectLater(repository.delete(customerId: 1), completes);
    });

    test(
      'a still-referenced rejection surfaces the server message (spec Edge Cases)',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({'detail': 'Customer has existing sales orders'}),
            400,
            headers: _jsonHeaders,
          ),
        );

        await expectLater(
          () => repository.delete(customerId: 1),
          throwsA(
            const AppError.server(
              statusCode: 400,
              message: 'Customer has existing sales orders',
            ),
          ),
        );
      },
    );
  });
}

Map<String, Object?> _customerJson({Object? salesperson = _defaultSalesperson}) => {
  'customer_id': 1,
  'code': 'CUST-001',
  'name': 'Acme Corp',
  'zone': 'North',
  'credit_limit': '1000.50',
  'credit_days': 30,
  'price_list': {
    'price_list_id': 1,
    'name': 'Retail',
    'high_profit_margin': '0.40',
    'low_profit_margin': '0.10',
  },
  'shipping': false,
  'shipping_required_document': false,
  'salesperson': salesperson == _defaultSalesperson
      ? {
          'employee_id': 2,
          'first_name': 'Jane',
          'last_name': 'Doe',
          'nickname': 'Janie',
          'gender': 0,
          'birthday': '1990-05-15',
          'sales_person': true,
          'active': true,
          'start_job_date': '2020-01-10',
        }
      : salesperson,
  'disabled': false,
  'comment': null,
};

const _defaultSalesperson = Object();

Map<String, Object?> _decodeBody(Object? data) => data is String
    ? jsonDecode(data) as Map<String, Object?>
    : data as Map<String, Object?>;

CustomerRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return CustomerRepositoryImpl(dio);
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
