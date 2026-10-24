import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('SupplierRepositoryImpl.list (picker projection)', () {
    test('200 returns lightweight SupplierListItems', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_supplierJson()],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();

      expect(result.total, 1);
      expect(result.items.single.supplierId, 1);
      expect(result.items.single.code, 'SUP-001');
      expect(result.items.single.name, 'Acme Corp');
    });
  });

  group('SupplierRepositoryImpl.listDetailed (catalog list projection)', () {
    test('200 returns full Supplier entities', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_supplierJson()],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.listDetailed();

      expect(result.total, 1);
      expect(result.items.single.zone, 'North');
      expect(result.items.single.creditLimit, '1000.50');
      expect(result.items.single.creditDays, 30);
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

      await repository.listDetailed(search: 'Acme', skip: 20, limit: 10);

      expect(captured!.queryParameters['search'], 'Acme');
      expect(captured!.queryParameters['skip'], 20);
      expect(captured!.queryParameters['limit'], 10);
    });

    test('5xx maps to AppError.server', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 503),
      );

      await expectLater(
        () => repository.listDetailed(),
        throwsA(const AppError.server(statusCode: 503)),
      );
    });
  });

  group('SupplierRepositoryImpl.get', () {
    test('200 maps to a Supplier', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_supplierJson()),
          200,
          headers: _jsonHeaders,
        ),
      );

      final supplier = await repository.get(supplierId: 1);

      expect(supplier.supplierId, 1);
      expect(supplier.code, 'SUP-001');
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Supplier not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.get(supplierId: 999),
        throwsA(const AppError.notFound('Supplier not found')),
      );
    });
  });

  group('SupplierRepositoryImpl.create', () {
    test('201 returns the created Supplier', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_supplierJson()),
          201,
          headers: _jsonHeaders,
        ),
      );

      final supplier = await repository.create(
        code: 'SUP-001',
        name: 'Acme Corp',
      );

      expect(supplier.name, 'Acme Corp');
    });

    test('sends creditLimit as a JSON decimal string, not a number '
        '(the AnyOf write path, contracts/mbe-api-catalogs.md §7)', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_supplierJson()),
          201,
          headers: _jsonHeaders,
        );
      });

      await repository.create(
        code: 'SUP-001',
        name: 'Acme Corp',
        creditLimit: '1000.50',
      );

      final sentBody = _decodeBody(captured!.data);
      expect(sentBody['credit_limit'], '1000.50');
      expect(sentBody['credit_limit'], isA<String>());
    });

    test('omits creditLimit from the request body when not provided', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_supplierJson()),
          201,
          headers: _jsonHeaders,
        );
      });

      await repository.create(code: 'SUP-001', name: 'Acme Corp');

      final sentBody = _decodeBody(captured!.data);
      expect(sentBody.containsKey('credit_limit'), isFalse);
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
        () => repository.create(code: 'SUP-001', name: 'Acme Corp'),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('SupplierRepositoryImpl.update', () {
    test('200 returns the updated Supplier', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({..._supplierJson(), 'name': 'Acme Corp Updated'}),
          200,
          headers: _jsonHeaders,
        ),
      );

      final supplier = await repository.update(
        supplierId: 1,
        name: 'Acme Corp Updated',
      );

      expect(supplier.name, 'Acme Corp Updated');
    });

    test('sends an updated creditLimit as a JSON string via the update-side '
        'wrapper class (CreditLimit1-style, research.md §4)', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_supplierJson()),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.update(supplierId: 1, creditLimit: '2000.00');

      final sentBody = _decodeBody(captured!.data);
      expect(sentBody['credit_limit'], '2000.00');
      expect(sentBody['credit_limit'], isA<String>());
      expect(sentBody.containsKey('name'), isFalse);
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Supplier not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.update(supplierId: 999, name: 'Anything'),
        throwsA(const AppError.notFound('Supplier not found')),
      );
    });
  });

  group('SupplierRepositoryImpl.delete', () {
    test('204 completes with no error', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );

      await expectLater(repository.delete(supplierId: 1), completes);
    });

    test(
      'a still-referenced rejection surfaces the server message (US1 §6)',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({'detail': 'Supplier is referenced by a product'}),
            400,
            headers: _jsonHeaders,
          ),
        );

        await expectLater(
          () => repository.delete(supplierId: 1),
          throwsA(
            const AppError.server(
              statusCode: 400,
              message: 'Supplier is referenced by a product',
            ),
          ),
        );
      },
    );

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Supplier not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.delete(supplierId: 999),
        throwsA(const AppError.notFound('Supplier not found')),
      );
    });
  });

  group('SupplierRepositoryImpl relations (spec 050)', () {
    test('get maps addresses, contacts and bank accounts', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            ..._supplierJson(),
            'addresses': [_addressJson()],
            'contacts': [_contactJson()],
            'bank_accounts': [_bankAccountJson()],
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final supplier = await repository.get(supplierId: 1);

      expect(supplier.addresses.single.addressId, 10);
      expect(supplier.contacts.single.contactId, 21);
      expect(supplier.bankAccounts.single.bankAccountId, 31);
      expect(supplier.bankAccounts.single.label, 'BBVA · 0123456789');
    });

    test('list leaves the relation lists empty', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_supplierJson()],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.listDetailed();

      expect(result.items.single.addresses, isEmpty);
      expect(result.items.single.contacts, isEmpty);
      expect(result.items.single.bankAccounts, isEmpty);
    });

    test('create puts the id lists in the request body', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_supplierJson()),
          201,
          headers: _jsonHeaders,
        );
      });

      await repository.create(
        code: 'SUP-001',
        name: 'Acme Corp',
        addressIds: [10, 11],
        contactIds: [21],
        bankAccountIds: [31],
      );

      final sentBody = _decodeBody(captured!.data);
      expect(sentBody['addresses'], [10, 11]);
      expect(sentBody['contacts'], [21]);
      expect(sentBody['bank_accounts'], [31]);
    });

    test('create omits the id lists when null', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_supplierJson()),
          201,
          headers: _jsonHeaders,
        );
      });

      await repository.create(code: 'SUP-001', name: 'Acme Corp');

      final sentBody = _decodeBody(captured!.data);
      expect(sentBody.containsKey('addresses'), isFalse);
      expect(sentBody.containsKey('contacts'), isFalse);
      expect(sentBody.containsKey('bank_accounts'), isFalse);
    });

    test('update sends [] to clear a relation and omits null ones', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_supplierJson()),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.update(
        supplierId: 1,
        addressIds: const [],
        contactIds: [21],
      );

      final sentBody = _decodeBody(captured!.data);
      expect(sentBody['addresses'], isEmpty);
      expect(sentBody['contacts'], [21]);
      expect(sentBody.containsKey('bank_accounts'), isFalse);
    });
  });

  group('SupplierRepositoryImpl agreements (spec 050)', () {
    test('listAgreements GETs the supplier agreements and maps them', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode([_agreementJson()]),
          200,
          headers: _jsonHeaders,
        );
      });

      final agreements = await repository.listAgreements(supplierId: 1);

      expect(captured!.method, 'GET');
      expect(captured!.path, '/api/v1/suppliers/1/agreements');
      expect(agreements.single.supplierAgreementId, 41);
      expect(agreements.single.supplierId, 1);
      expect(agreements.single.start, DateTime(2026, 1, 1));
      expect(agreements.single.end, DateTime(2026, 12, 31));
      expect(agreements.single.comment, 'Annual');
    });

    test(
      'createAgreement POSTs date-only start/end and maps the reply',
      () async {
        RequestOptions? captured;
        final repository = _repositoryWith((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode(_agreementJson()),
            201,
            headers: _jsonHeaders,
          );
        });

        final agreement = await repository.createAgreement(
          supplierId: 1,
          start: DateTime(2026, 1, 1, 13, 45),
          end: DateTime(2026, 12, 31),
          comment: 'Annual',
        );

        expect(captured!.method, 'POST');
        expect(captured!.path, '/api/v1/suppliers/1/agreements');
        final sentBody = _decodeBody(captured!.data);
        expect(sentBody['start'], '2026-01-01');
        expect(sentBody['end'], '2026-12-31');
        expect(sentBody['comment'], 'Annual');
        expect(agreement.supplierAgreementId, 41);
      },
    );

    test('updateAgreement PUTs to the agreement and maps the reply', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(_agreementJson()),
          200,
          headers: _jsonHeaders,
        );
      });

      final agreement = await repository.updateAgreement(
        supplierId: 1,
        agreementId: 41,
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 12, 31),
        comment: 'Annual',
      );

      expect(captured!.method, 'PUT');
      expect(captured!.path, '/api/v1/suppliers/1/agreements/41');
      final sentBody = _decodeBody(captured!.data);
      expect(sentBody['start'], '2026-01-01');
      expect(sentBody['end'], '2026-12-31');
      expect(agreement.comment, 'Annual');
    });

    test('deleteAgreement DELETEs the agreement', () async {
      RequestOptions? captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString('', 204);
      });

      await repository.deleteAgreement(supplierId: 1, agreementId: 41);

      expect(captured!.method, 'DELETE');
      expect(captured!.path, '/api/v1/suppliers/1/agreements/41');
    });

    test('a DioException maps to AppError', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Supplier not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.listAgreements(supplierId: 999),
        throwsA(const AppError.notFound('Supplier not found')),
      );
    });
  });
}

Map<String, Object?> _supplierJson() => {
  'supplier_id': 1,
  'code': 'SUP-001',
  'name': 'Acme Corp',
  'zone': 'North',
  'credit_limit': '1000.50',
  'credit_days': 30,
  'comment': null,
};

Map<String, Object?> _addressJson() => {
  'address_id': 10,
  'nickname': 'Matriz',
  'type': 3,
  'street': 'Calle 1',
  'exterior_number': '2',
  'interior_number': null,
  'postal_code': '06500',
  'neighborhood': 'Centro',
  'locality': null,
  'borough': 'Cuauhtémoc',
  'state': 'CDMX',
  'city': null,
  'country': 'México',
  'url_address': null,
  'comment': null,
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

Map<String, Object?> _bankAccountJson() => {
  'bank_account_id': 31,
  'bank_name': 'BBVA',
  'account_number': '0123456789',
  'reference': null,
  'routing_number': null,
  'comment': null,
};

Map<String, Object?> _agreementJson() => {
  'supplier_agreement_id': 41,
  'supplier': 1,
  'start': '2026-01-01',
  'end': '2026-12-31',
  'comment': 'Annual',
};

Map<String, Object?> _decodeBody(Object? data) => data is String
    ? jsonDecode(data) as Map<String, Object?>
    : data as Map<String, Object?>;

SupplierRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return SupplierRepositoryImpl(dio);
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
