import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/cash_session_status.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/denomination_count.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('CashSessionRepositoryImpl.getCurrent', () {
    test('maps an open session, flattening the drawer and cashier names '
        'directly off CashDrawerSummary/EmployeeResponse — no resolution '
        'step (mbe-api#141, research.md §17)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'state': 'open',
            'session': _cashSessionJson(id: 42, drawerName: 'Caja 1', cashierFirst: 'Ana', cashierLast: 'López'),
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final current = await repository.getCurrent();

      expect(current.state, SessionState.open);
      expect(current.session!.cashSessionId, 42);
      expect(current.session!.cashDrawerName, 'Caja 1');
      expect(current.session!.cashierName, 'Ana López');
      expect(current.session!.end, isNull);
    });

    test('maps state=none with a null session', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'state': 'none', 'session': null}),
          200,
          headers: _jsonHeaders,
        ),
      );

      final current = await repository.getCurrent();

      expect(current.state, SessionState.none);
      expect(current.session, isNull);
    });

    test('maps state=stale', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'state': 'stale',
            'session': _cashSessionJson(id: 7, drawerName: 'Caja 2', cashierFirst: 'Luis', cashierLast: 'Reyes'),
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final current = await repository.getCurrent();

      expect(current.state, SessionState.stale);
    });
  });

  group('CashSessionRepositoryImpl.list', () {
    test('forwards cashDrawer, cashier and status query params', () async {
      final captured = <String, dynamic>{};
      final repository = _repositoryWith((options) async {
        captured.addAll(options.queryParameters);
        return ResponseBody.fromString(
          jsonEncode({'items': [], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.list(cashDrawerId: 1, cashierId: 2, status: CashSessionStatus.open);

      expect(captured['cash_drawer'], 1);
      expect(captured['cashier'], 2);
      expect(captured['status'], 'open');
    });

    test('maps items and total, each item flattening its drawer/cashier '
        'names', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [
              _cashSessionJson(id: 1, drawerName: 'Caja 1', cashierFirst: 'Ana', cashierLast: 'López'),
              _cashSessionJson(id: 2, drawerName: 'Caja 2', cashierFirst: 'Luis', cashierLast: 'Reyes'),
            ],
            'total': 2,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();

      expect(result.total, 2);
      expect(result.items.map((s) => s.cashSessionId), [1, 2]);
      expect(result.items[1].cashierName, 'Luis Reyes');
    });
  });

  group('CashSessionRepositoryImpl.open', () {
    test('sends opening_amount as a plain string, not a wrapped object — '
        'the AnyOf shim risk research.md flags explicitly', () async {
      Map<String, dynamic>? capturedBody;
      final repository = _repositoryWith((options) async {
        capturedBody = options.data as Map<String, dynamic>;
        return ResponseBody.fromString(
          jsonEncode(_cashSessionJson(id: 1, drawerName: 'Caja 1', cashierFirst: 'Ana', cashierLast: 'López')),
          201,
          headers: _jsonHeaders,
        );
      });

      await repository.open(cashDrawerId: 5, openingAmount: '500.00');

      expect(capturedBody!['cash_drawer'], 5);
      expect(capturedBody!['opening_amount'], '500.00');
      expect(capturedBody!['opening_amount'], isA<String>());
    });

    test('a null cashDrawerId omits cash_drawer from the request entirely', () async {
      Map<String, dynamic>? capturedBody;
      final repository = _repositoryWith((options) async {
        capturedBody = options.data as Map<String, dynamic>;
        return ResponseBody.fromString(
          jsonEncode(_cashSessionJson(id: 1, drawerName: 'Caja 1', cashierFirst: 'Ana', cashierLast: 'López')),
          201,
          headers: _jsonHeaders,
        );
      });

      await repository.open(openingAmount: '0');

      expect(capturedBody!.containsKey('cash_drawer'), isFalse);
    });

    test('409 drawer-busy maps to ServerError carrying the detail string', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'That cash drawer already has an open session'}),
          409,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.open(cashDrawerId: 1, openingAmount: '0'),
        throwsA(
          isA<ServerError>().having(
            (e) => e.message,
            'message',
            'That cash drawer already has an open session',
          ),
        ),
      );
    });

    test('409 cashier-busy maps to ServerError carrying its own distinct '
        'detail string — the repository does not discriminate the two, that '
        'is the form controller\'s job (research.md §4)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': 'You already have an open session; close it before opening another',
          }),
          409,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.open(cashDrawerId: 1, openingAmount: '0'),
        throwsA(
          isA<ServerError>().having(
            (e) => e.message,
            'message',
            'You already have an open session; close it before opening another',
          ),
        ),
      );
    });

    test('422 maps to AppError.validation', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'opening_amount'],
                'msg': 'No cash drawer is configured for your user; set one or supply it explicitly',
                'type': 'value_error',
              },
            ],
          }),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.open(openingAmount: '0'),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('CashSessionRepositoryImpl.get', () {
    test('maps to a CashSession', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_cashSessionJson(id: 9, drawerName: 'Caja 1', cashierFirst: 'Ana', cashierLast: 'López')),
          200,
          headers: _jsonHeaders,
        ),
      );

      final session = await repository.get(cashSessionId: 9);

      expect(session.cashSessionId, 9);
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Cash session not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.get(cashSessionId: 999),
        throwsA(const AppError.notFound('Cash session not found')),
      );
    });
  });

  group('CashSessionRepositoryImpl.close', () {
    test('sends each denomination as a plain string and quantity as an int', () async {
      Map<String, dynamic>? capturedBody;
      final repository = _repositoryWith((options) async {
        capturedBody = options.data as Map<String, dynamic>;
        return ResponseBody.fromString(
          jsonEncode(
            _cashSessionJson(
              id: 1,
              drawerName: 'Caja 1',
              cashierFirst: 'Ana',
              cashierLast: 'López',
              end: '2026-08-05T18:00:00',
            ),
          ),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.close(
        cashSessionId: 1,
        counts: const [
          DenominationCount(denomination: '500', quantity: 3),
          DenominationCount(denomination: '100', quantity: 2),
        ],
      );

      final counts = capturedBody!['counts'] as List<dynamic>;
      expect(counts, hasLength(2));
      expect(counts[0], {'denomination': '500', 'quantity': 3});
      expect(counts[1], {'denomination': '100', 'quantity': 2});
    });

    test('an empty counts list still sends an empty array, not an absent '
        'key — matches the server default', () async {
      Map<String, dynamic>? capturedBody;
      final repository = _repositoryWith((options) async {
        capturedBody = options.data as Map<String, dynamic>;
        return ResponseBody.fromString(
          jsonEncode(
            _cashSessionJson(
              id: 1,
              drawerName: 'Caja 1',
              cashierFirst: 'Ana',
              cashierLast: 'López',
              end: '2026-08-05T18:00:00',
            ),
          ),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.close(cashSessionId: 1, counts: const []);

      expect(capturedBody!['counts'], isEmpty);
    });

    test('409 already-closed maps to ServerError with the detail string', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Session is already closed'}),
          409,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.close(cashSessionId: 1, counts: const []),
        throwsA(
          isA<ServerError>().having((e) => e.message, 'message', 'Session is already closed'),
        ),
      );
    });
  });
}

Map<String, Object?> _cashSessionJson({
  required int id,
  required String drawerName,
  required String cashierFirst,
  required String cashierLast,
  String? end,
}) => {
  'cash_session_id': id,
  'cash_drawer': {
    'cash_drawer_id': 1,
    'facility': 1,
    'code': 'CJ1',
    'name': drawerName,
    'comment': null,
    'status': 0,
  },
  'cashier': _employeeJson(id: 100, firstName: cashierFirst, lastName: cashierLast),
  'start': '2026-08-05T09:00:00',
  'end': end,
  'cash_supervisor': null,
  'opening_amount': '500.00',
  'payments_by_method': [
    {'method': 1, 'total': '3240.00'},
  ],
};

Map<String, Object?> _employeeJson({
  required int id,
  required String firstName,
  required String lastName,
}) => {
  'employee_id': id,
  'first_name': firstName,
  'last_name': lastName,
  'nickname': firstName,
  'gender': 0,
  'birthday': '1990-01-01',
  'taxpayer_id': null,
  'sales_person': false,
  'status': 0,
  'personal_id': null,
  'start_job_date': '2020-01-01',
  'enroll_number': null,
  'comment': null,
};

CashSessionRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return CashSessionRepositoryImpl(dio);
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
