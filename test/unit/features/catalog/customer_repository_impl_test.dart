import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('CustomerRepositoryImpl.list', () {
    test('200 maps expanded priceList/salesperson FKs to display names '
        '(research.md §7)', () async {
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
    });

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
      'forwards search/status/priceList/salesperson/skip/limit as query params',
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
          status: EntityStatus.active,
          priceList: 1,
          salesperson: 2,
          skip: 20,
          limit: 10,
        );

        expect(captured!.queryParameters['search'], 'Acme');
        expect(captured!.queryParameters['status'], 0);
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
    test('sends creditLimit as a JSON decimal string and priceList/salesperson '
        'as plain ids, not expanded objects (research.md §7)', () async {
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
          code: 'CUST-001',
          name: 'Acme Corp',
          priceList: 1,
        ),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group(
    'embedded addresses/contacts (020-point-of-sale, mbe-api#132/#133)',
    () {
      test('get() maps the embedded collections onto the entity', () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode(
              _customerJson(
                addresses: [_addressJson()],
                contacts: [_contactJson()],
              ),
            ),
            200,
            headers: _jsonHeaders,
          ),
        );

        final customer = await repository.get(customerId: 1);

        expect(customer.addresses, hasLength(1));
        expect(customer.addresses.single.addressId, 11);
        expect(customer.contacts, hasLength(1));
        expect(customer.contacts.single.contactId, 21);
        expect(customer.contacts.single.name, 'Ana López');
        expect(customer.contacts.single.mobile, '5544332211');
      });

      test('a response omitting them yields empty lists, not null — list '
          'projections never include them', () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode(_customerJson()),
            200,
            headers: _jsonHeaders,
          ),
        );

        final customer = await repository.get(customerId: 1);

        expect(customer.addresses, isEmpty);
        expect(customer.contacts, isEmpty);
      });

      test('update() omits both keys when neither is passed, so existing links '
          'are left alone (replace-all semantics)', () async {
        RequestOptions? captured;
        final repository = _repositoryWith((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode(_customerJson()),
            200,
            headers: _jsonHeaders,
          );
        });

        await repository.update(customerId: 1, name: 'Renamed');

        final sentBody = _decodeBody(captured!.data);
        expect(sentBody.containsKey('addresses'), isFalse);
        expect(sentBody.containsKey('contacts'), isFalse);
      });

      test('update() sends the id lists when passed', () async {
        RequestOptions? captured;
        final repository = _repositoryWith((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode(_customerJson()),
            200,
            headers: _jsonHeaders,
          );
        });

        await repository.update(
          customerId: 1,
          addresses: [11, 12],
          contacts: [21],
        );

        final sentBody = _decodeBody(captured!.data);
        expect(sentBody['addresses'], [11, 12]);
        expect(sentBody['contacts'], [21]);
      });

      test('an empty list is sent, not dropped — it deliberately unlinks '
          'everything', () async {
        RequestOptions? captured;
        final repository = _repositoryWith((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode(_customerJson()),
            200,
            headers: _jsonHeaders,
          );
        });

        await repository.update(customerId: 1, addresses: []);

        final sentBody = _decodeBody(captured!.data);
        expect(sentBody['addresses'], isEmpty);
        expect(sentBody.containsKey('addresses'), isTrue);
      });
    },
  );

  group('CustomerRepositoryImpl.update', () {
    test('sends an updated creditLimit via the update-side wrapper class '
        '(CreditLimit1-style, research.md §4)', () async {
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

  group('CustomerRepositoryImpl discounts (spec 052)', () {
    test('list maps rows to entities in the server\'s order', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode([
            _discountJson(id: 5, code: 'AAA-1', discount: '0.10000000'),
            _discountJson(id: 6, code: 'BBB-2', discount: '0.12500000'),
          ]),
          200,
          headers: _jsonHeaders,
        );
      });

      final result = await repository.listDiscounts(customerId: 7);

      expect(captured!.method, 'GET');
      expect(captured!.path, '/api/v1/customers/7/discounts');
      expect(result.map((d) => d.productCode), ['AAA-1', 'BBB-2']);
      expect(result.last.customerDiscountId, 6);
      expect(result.last.customerId, 7);
      expect(result.last.productId, 100);
      expect(result.last.productName, 'Product BBB-2');
      expect(result.last.discount, '0.12500000');
    });

    test('create sends product and the String arm of discount', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_discountJson(id: 9, code: 'AAA-1', discount: '0.1')),
          201,
          headers: _jsonHeaders,
        );
      });

      final created = await repository.createDiscount(
        customerId: 7,
        productId: 100,
        discount: '0.1',
      );

      expect(captured!.method, 'POST');
      expect(captured!.path, '/api/v1/customers/7/discounts');
      expect(_decodeBody(captured!.data), {'product': 100, 'discount': '0.1'});
      expect(created.customerDiscountId, 9);
    });

    test('update sends only the discount', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_discountJson(id: 9, code: 'AAA-1', discount: '0.125')),
          200,
          headers: _jsonHeaders,
        );
      });

      final updated = await repository.updateDiscount(
        customerId: 7,
        customerDiscountId: 9,
        discount: '0.125',
      );

      expect(captured!.method, 'PUT');
      expect(captured!.path, '/api/v1/customers/7/discounts/9');
      expect(_decodeBody(captured!.data), {'discount': '0.125'});
      expect(updated.discount, '0.125');
    });

    test('delete calls the discount path and completes on 204', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString('', 204);
      });

      await expectLater(
        repository.deleteDiscount(customerId: 7, customerDiscountId: 9),
        completes,
      );

      expect(captured!.method, 'DELETE');
      expect(captured!.path, '/api/v1/customers/7/discounts/9');
    });

    test(
      'a repeat create maps 409 to a ServerError with the message',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({
              'detail': 'Customer already has a discount for this product',
            }),
            409,
            headers: _jsonHeaders,
          ),
        );

        await expectLater(
          () => repository.createDiscount(
            customerId: 7,
            productId: 100,
            discount: '0.1',
          ),
          throwsA(
            const AppError.server(
              statusCode: 409,
              message: 'Customer already has a discount for this product',
            ),
          ),
        );
      },
    );

    test('an unknown product maps 422 with a plain detail to a '
        'ValidationError carrying the message', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Product not found'}),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.createDiscount(
          customerId: 7,
          productId: 999,
          discount: '0.1',
        ),
        throwsA(
          isA<ValidationError>()
              .having((e) => e.errors, 'errors', isEmpty)
              .having((e) => e.message, 'message', 'Product not found'),
        ),
      );
    });

    test('update and delete map 404 to NotFoundError', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Discount not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.updateDiscount(
          customerId: 7,
          customerDiscountId: 9,
          discount: '0.2',
        ),
        throwsA(const AppError.notFound('Discount not found')),
      );
      await expectLater(
        () => repository.deleteDiscount(customerId: 7, customerDiscountId: 9),
        throwsA(const AppError.notFound('Discount not found')),
      );
    });
  });
}

Map<String, Object?> _discountJson({
  required int id,
  required String code,
  required String discount,
}) => {
  'customer_discount_id': id,
  'customer': 7,
  'product': {'product_id': 100, 'code': code, 'name': 'Product $code'},
  'discount': discount,
};

Map<String, Object?> _addressJson() => {
  'address_id': 11,
  'street': 'Av. Reforma',
  'exterior_number': '100',
  'postal_code': '06600',
  'neighborhood': 'Juárez',
  'borough': 'Cuauhtémoc',
  'state': 'CDMX',
  'country': 'MX',
  'type': 0,
  'status': 0,
};

Map<String, Object?> _contactJson() => {
  'contact_id': 21,
  'name': 'Ana López',
  'job_title': 'Almacén',
  'phone': '5555555555',
  'mobile': '5544332211',
  'email': 'ana@example.com',
};

Map<String, Object?> _customerJson({
  Object? salesperson = _defaultSalesperson,
  List<Map<String, Object?>>? addresses,
  List<Map<String, Object?>>? contacts,
}) => {
  'addresses': ?addresses,
  'contacts': ?contacts,
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
          'status': 0,
          'start_job_date': '2020-01-10',
        }
      : salesperson,
  'status': 0,
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
