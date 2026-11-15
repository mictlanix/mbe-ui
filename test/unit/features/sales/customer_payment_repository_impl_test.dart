import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

Map<String, dynamic> _paymentJson({
  int id = 1,
  int? verifier,
  Map<String, dynamic>? lastRejection,
}) => {
  'customer_payment_id': id,
  'serial': id,
  'customer': 77,
  'customer_display_name': 'Ana López',
  'amount': '100.00',
  'currency': 0,
  'method': 1,
  'payment_charge': null,
  'reference': null,
  'date': '2026-10-27T10:14:00',
  'facility': 3,
  'cash_session': null,
  'payment_type': 1,
  'verifier': verifier,
  'unapplied': '0.00',
  'last_rejection': lastRejection,
};

ResponseBody _page(List<Map<String, dynamic>> items, {int? total}) =>
    ResponseBody.fromString(
      jsonEncode({'items': items, 'total': total ?? items.length}),
      200,
      headers: _jsonHeaders,
    );

void main() {
  group('list (FR-004, R4)', () {
    test('always sends the facility and forwards every filter', () async {
      late RequestOptions seen;
      final repository = _repositoryWith((options) async {
        seen = options;
        return _page([_paymentJson()]);
      });

      final page = await repository.list(
        facilityId: 3,
        customerId: 77,
        cashSessionId: 812,
        dateFrom: DateTime(2026, 10, 1, 15, 30),
        dateTo: DateTime(2026, 10, 27, 8),
        methodCode: 28,
        verified: true,
        skip: 40,
        limit: 20,
      );

      expect(seen.path, endsWith('/api/v1/customer-payments'));
      final q = seen.queryParameters;
      expect(q['facility'], 3);
      expect(q['customer'], 77);
      expect(q['cash_session'], 812);
      expect(q['method'], 28);
      expect(q['verified'], true);
      expect(q['skip'], 40);
      expect(q['limit'], 20);
      expect(page.items, hasLength(1));
      expect(page.total, 1);
    });

    test(
      'sends the start of the first day and the end of the last (spec 043)',
      () async {
        late Map<String, dynamic> q;
        final repository = _repositoryWith((options) async {
          q = options.queryParameters;
          return _page(const []);
        });

        await repository.list(
          facilityId: 3,
          dateFrom: DateTime(2026, 10, 1, 15, 30),
          dateTo: DateTime(2026, 10, 27, 8),
        );

        expect('${q['date_from']}', startsWith('2026-10-01T00:00:00'));
        expect('${q['date_to']}', startsWith('2026-10-27T23:59:59'));
      },
    );

    test('forwards a customer-name search and carries the name back '
        '(spec 055 FR-007, FR-009)', () async {
      late Map<String, dynamic> q;
      final repository = _repositoryWith((options) async {
        q = options.queryParameters;
        return _page([_paymentJson()]);
      });

      final page = await repository.list(facilityId: 3, search: 'lópez');

      expect(q['search'], 'lópez');
      expect(page.items.single.customerName, 'Ana López');
    });

    test('a null or blank search sends none (spec 055 FR-010)', () async {
      final seen = <Map<String, dynamic>>[];
      final repository = _repositoryWith((options) async {
        seen.add(Map.of(options.queryParameters));
        return _page(const []);
      });

      await repository.list(facilityId: 3);
      await repository.list(facilityId: 3, search: '   ');

      expect(seen[0].containsKey('search'), isFalse);
      expect(seen[1].containsKey('search'), isFalse);
    });

    test('verified is tri-state: true, false and null (any)', () async {
      final seen = <Map<String, dynamic>>[];
      final repository = _repositoryWith((options) async {
        seen.add(Map.of(options.queryParameters));
        return _page(const []);
      });

      await repository.list(facilityId: 3, verified: true);
      await repository.list(facilityId: 3, verified: false);
      await repository.list(facilityId: 3);

      expect(seen[0]['verified'], true);
      expect(seen[1]['verified'], false);
      expect(seen[2].containsKey('verified'), isFalse);
    });

    test('omits filters that are not set', () async {
      late Map<String, dynamic> q;
      final repository = _repositoryWith((options) async {
        q = options.queryParameters;
        return _page(const []);
      });

      await repository.list(facilityId: 3);

      expect(q.keys.toSet(), {'facility', 'skip', 'limit'});
    });

    test('maps rows and the total', () async {
      final repository = _repositoryWith(
        (options) async => _page([
          _paymentJson(id: 2, verifier: 9),
          _paymentJson(id: 1),
        ], total: 57),
      );

      final page = await repository.list(facilityId: 3);

      expect(page.total, 57);
      expect(page.items.map((p) => p.customerPaymentId), [2, 1]);
      expect(page.items.first.isVerified, isTrue);
      expect(page.items.first.type, PaymentType.immediate);
    });
  });

  group('searchAcrossFacilities (FR-010)', () {
    test('forwards the reference, customer and date range', () async {
      late RequestOptions seen;
      final repository = _repositoryWith((options) async {
        seen = options;
        return _page([_paymentJson()]);
      });

      final page = await repository.searchAcrossFacilities(
        customerId: 77,
        reference: 'SPEI 98',
        dateFrom: DateTime(2026, 10, 1),
        dateTo: DateTime(2026, 10, 27),
        skip: 20,
      );

      expect(seen.path, endsWith('/api/v1/customer-payments/search'));
      final q = seen.queryParameters;
      expect(q['customer'], 77);
      expect(q['reference'], 'SPEI 98');
      expect('${q['date_from']}', startsWith('2026-10-01T00:00:00'));
      expect('${q['date_to']}', startsWith('2026-10-27T23:59:59'));
      expect(q['skip'], 20);
      expect(q.containsKey('facility'), isFalse);
      expect(page.items, hasLength(1));
    });
  });

  group('get', () {
    test('maps the payment', () async {
      late RequestOptions seen;
      final repository = _repositoryWith((options) async {
        seen = options;
        return ResponseBody.fromString(
          jsonEncode(_paymentJson(id: 18342)),
          200,
          headers: _jsonHeaders,
        );
      });

      final payment = await repository.get(customerPaymentId: 18342);

      expect(seen.path, endsWith('/api/v1/customer-payments/18342'));
      expect(payment.customerPaymentId, 18342);
      expect(payment.facilityId, 3);
    });

    test('a 404 becomes AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Payment not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.get(customerPaymentId: 99999),
        throwsA(const AppError.notFound('Payment not found')),
      );
    });
  });

  group('listApplications', () {
    test('maps every application, reversed ones included', () async {
      late RequestOptions seen;
      final repository = _repositoryWith((options) async {
        seen = options;
        return ResponseBody.fromString(
          jsonEncode([
            {
              'sales_order_payment_id': 1,
              'sales_order': 5512,
              'customer_payment': 18342,
              'amount': '1000.00',
              'amount_change': '0.00',
              'applier': 4,
              'date': '2026-10-27T10:15:00',
              'cancelled': false,
            },
            {
              'sales_order_payment_id': 2,
              'sales_order': 5498,
              'customer_payment': 18342,
              'amount': '300.00',
              'amount_change': '0.00',
              'applier': null,
              'date': null,
              'cancelled': true,
            },
          ]),
          200,
          headers: _jsonHeaders,
        );
      });

      final applications = await repository.listApplications(
        customerPaymentId: 18342,
      );

      expect(
        seen.path,
        endsWith('/api/v1/customer-payments/18342/applications'),
      );
      expect(applications.map((a) => a.saleId), [5512, 5498]);
      expect(applications.map((a) => a.reversed), [false, true]);
      expect(applications.last.applierId, isNull);
      expect(applications.last.date, isNull);
    });
  });

  group('createPayment (spec 059 R6)', () {
    Future<Map<String, dynamic>> bodyOf(PaymentType? type) async {
      late Map<String, dynamic> body;
      final repository = _repositoryWith((options) async {
        body = options.data as Map<String, dynamic>;
        return ResponseBody.fromString(
          jsonEncode(_paymentJson(id: 55)),
          201,
          headers: _jsonHeaders,
        );
      });

      final id = type == null
          ? await repository.createPayment(
              customer: 77,
              amount: '100.00',
              method: 1,
            )
          : await repository.createPayment(
              customer: 77,
              amount: '100.00',
              method: 1,
              type: type,
            );

      expect(id, 55);
      return body;
    }

    test('records a credit payment and an advance with their type', () async {
      expect((await bodyOf(PaymentType.creditPayment))['payment_type'], 2);
      expect((await bodyOf(PaymentType.paymentInAdvance))['payment_type'], 3);
    });

    test('leaves the type at IMMEDIATE (1) for the register', () async {
      expect((await bodyOf(null))['payment_type'], 1);
    });
  });

  group('listOutstandingOrders (spec 059 R5)', () {
    Map<String, dynamic> row(int id, {int? serial}) => {
      'sales_order_id': id,
      'serial': serial,
      'customer': 77,
      'customer_name': null,
      'customer_display_name': 'Ana López',
      'date': '2026-11-10T09:30:00',
      'due_date': '2026-11-25T00:00:00',
      'currency': 0,
      'total': '2400.00',
      'balance': '1800.00',
    };

    test('forwards the customer, facility, search and paging', () async {
      late RequestOptions seen;
      final repository = _repositoryWith((options) async {
        seen = options;
        return _page(const []);
      });

      await repository.listOutstandingOrders(
        customerId: 77,
        facilityId: 3,
        search: ' 1047 ',
        skip: 20,
        limit: 20,
      );

      expect(seen.path, endsWith('/customer-payments/outstanding-orders'));
      final q = seen.queryParameters;
      expect(q['customer'], 77);
      expect(q['facility'], 3);
      expect(q['search'], '1047');
      expect(q['skip'], 20);
      expect(q['limit'], 20);
    });

    test('a blank search sends none', () async {
      late Map<String, dynamic> q;
      final repository = _repositoryWith((options) async {
        q = options.queryParameters;
        return _page(const []);
      });

      await repository.listOutstandingOrders(
        customerId: 77,
        facilityId: 9,
        search: '  ',
      );

      expect(q.containsKey('search'), isFalse);
    });

    test('maps the rows and the total', () async {
      final repository = _repositoryWith(
        (options) async => _page([row(1047, serial: 812), row(1052)], total: 9),
      );

      final page = await repository.listOutstandingOrders(
        customerId: 77,
        facilityId: 9,
      );

      expect(page.total, 9);
      expect(page.items.map((o) => o.id), [1047, 1052]);
      expect(page.items.first.serial, 812);
      expect(page.items.last.serial, isNull);
      expect(page.items.first.balance, '1800.00');
    });

    test('a server failure surfaces as an AppError', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'boom'}),
          500,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.listOutstandingOrders(customerId: 77, facilityId: 9),
        throwsA(isA<AppError>()),
      );
    });
  });

  group('verification queue (spec 060 R2)', () {
    test('listUnverified hits /unverified and forwards every filter', () async {
      late RequestOptions seen;
      final repository = _repositoryWith((options) async {
        seen = options;
        return _page([_paymentJson(id: 9)], total: 23);
      });

      final page = await repository.listUnverified(
        facilityId: 3,
        dateFrom: DateTime(2026, 10, 1, 15, 30),
        dateTo: DateTime(2026, 10, 27, 8),
        methodCode: 3,
        skip: 20,
        limit: 20,
      );

      expect(seen.path, endsWith('/api/v1/customer-payments/unverified'));
      final q = seen.queryParameters;
      expect(q['facility'], 3);
      expect(q['method'], 3);
      expect(q['skip'], 20);
      expect(q['limit'], 20);
      expect('${q['date_from']}', startsWith('2026-10-01T00:00:00'));
      expect('${q['date_to']}', startsWith('2026-10-27T23:59:59'));
      expect(page.items.single.customerPaymentId, 9);
      expect(page.total, 23);
    });

    test('listUnverified forwards the rejected facet and maps the last '
        'rejection (mbe-api#310)', () async {
      late Map<String, dynamic> q;
      final repository = _repositoryWith((options) async {
        q = options.queryParameters;
        return _page([
          _paymentJson(
            id: 9,
            lastRejection: {
              'reason': 'Sin comprobante',
              'rejected_by': 12,
              'rejected_at': '2026-11-14T09:30:00',
            },
          ),
          _paymentJson(id: 10),
        ]);
      });

      final page = await repository.listUnverified(rejected: true);

      expect(q['rejected'], true);
      expect(
        page.items.first.lastRejection,
        PaymentRejection(
          reason: 'Sin comprobante',
          rejectedById: 12,
          rejectedAt: DateTime(2026, 11, 14, 9, 30),
        ),
      );
      expect(page.items.last.lastRejection, isNull);
    });

    test('listUnverified omits unset filters and never sends an amount '
        'range', () async {
      late Map<String, dynamic> q;
      final repository = _repositoryWith((options) async {
        q = options.queryParameters;
        return _page(const []);
      });

      await repository.listUnverified();

      expect(q.containsKey('facility'), isFalse);
      expect(q.containsKey('method'), isFalse);
      expect(q.containsKey('date_from'), isFalse);
      expect(q.containsKey('date_to'), isFalse);
      expect(q.containsKey('rejected'), isFalse);
      expect(q.containsKey('amount_min'), isFalse);
      expect(q.containsKey('amount_max'), isFalse);
    });

    test('verify posts to the payment and maps the verified payment', () async {
      late RequestOptions seen;
      final repository = _repositoryWith((options) async {
        seen = options;
        return ResponseBody.fromString(
          jsonEncode(_paymentJson(id: 41, verifier: 12)),
          200,
          headers: _jsonHeaders,
        );
      });

      final payment = await repository.verify(customerPaymentId: 41);

      expect(seen.method, 'POST');
      expect(seen.path, endsWith('/api/v1/customer-payments/41/verify'));
      expect(payment.customerPaymentId, 41);
      expect(payment.verifierId, 12);
    });

    test('reject posts the reason and maps the unchanged payment', () async {
      late RequestOptions seen;
      final repository = _repositoryWith((options) async {
        seen = options;
        return ResponseBody.fromString(
          jsonEncode(_paymentJson(id: 42)),
          200,
          headers: _jsonHeaders,
        );
      });

      final payment = await repository.reject(
        customerPaymentId: 42,
        reason: 'No aparece en el estado de cuenta',
      );

      expect(seen.method, 'POST');
      expect(seen.path, endsWith('/api/v1/customer-payments/42/reject'));
      expect(seen.data, {'reason': 'No aparece en el estado de cuenta'});
      expect(payment.verifierId, isNull);
    });

    test('an already-verified payment surfaces as an AppError carrying the '
        'code', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'status': 409,
            'code': 'payment.already_verified',
            'detail': 'Payment is already verified',
          }),
          409,
          headers: _jsonHeaders,
        ),
      );

      final error = await repository
          .verify(customerPaymentId: 41)
          .then<AppError?>((_) => null)
          .catchError((Object e) => e as AppError);

      expect(error, isA<AppError>());
      expect(error!.problem!.code, api.ErrorCode.paymentPeriodAlreadyVerified);
    });
  });

  group('a server failure', () {
    test('surfaces as an AppError, not a DioException', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'boom'}),
          500,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.list(facilityId: 3),
        throwsA(isA<AppError>()),
      );
    });
  });
}

CustomerPaymentRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return CustomerPaymentRepositoryImpl(dio);
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
