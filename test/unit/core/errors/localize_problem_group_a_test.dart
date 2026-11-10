import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';

import 'problem_test_env.dart';

void main() {
  late ProblemEnv env;

  setUpAll(() async => env = await ProblemEnv.load());

  String? en(api.ErrorCode code, [Map<String, Object?> params = const {}]) =>
      localizeProblem(
        ApiProblem(codeName: 'x', code: code, params: params),
        env.en,
        env.fmtEn,
      );
  String? es(api.ErrorCode code, [Map<String, Object?> params = const {}]) =>
      localizeProblem(
        ApiProblem(codeName: 'x', code: code, params: params),
        env.es,
        env.fmtEs,
      );

  group('customer.credit_hold', () {
    test('counts the overdue orders with the right plural', () {
      expect(
        es(api.ErrorCode.customerPeriodCreditHold, {'overdue_count': 4}),
        'Este cliente tiene 4 pedidos a crédito vencidos. Liquídalos antes de '
        'crear un nuevo pedido a crédito.',
      );
      expect(
        es(api.ErrorCode.customerPeriodCreditHold, {'overdue_count': 1}),
        'Este cliente tiene 1 pedido a crédito vencido. Liquídalos antes de '
        'crear un nuevo pedido a crédito.',
      );
      expect(
        en(api.ErrorCode.customerPeriodCreditHold, {'overdue_count': 4}),
        'This customer has 4 overdue credit orders. Settle them before '
        'creating a new credit order.',
      );
      expect(
        en(api.ErrorCode.customerPeriodCreditHold, {'overdue_count': 1}),
        'This customer has 1 overdue credit order. Settle them before '
        'creating a new credit order.',
      );
    });

    test('a missing or mistyped count has no message', () {
      expect(en(api.ErrorCode.customerPeriodCreditHold), isNull);
      expect(
        en(api.ErrorCode.customerPeriodCreditHold, {'overdue_count': 'four'}),
        isNull,
      );
    });
  });

  group('credit limit', () {
    const params = {
      'customer_id': 812,
      'outstanding': '18450.00',
      'limit': '15000.00',
    };

    test('amounts go through the shared currency formatter', () {
      expect(
        es(api.ErrorCode.customerPeriodCreditLimitExceeded, params),
        'Con este pedido el saldo del cliente llegaría a \$18,450.00, arriba '
        r'de su límite de crédito de $15,000.00.',
      );
      expect(
        en(api.ErrorCode.customerPeriodCreditLimitReached, params),
        r'The customer owes $18,450.00, which reaches their credit limit of '
        r'$15,000.00. They must pay before buying again.',
      );
    });

    test('a missing amount has no message', () {
      expect(
        es(api.ErrorCode.customerPeriodCreditLimitExceeded, {
          'outstanding': '18450.00',
        }),
        isNull,
      );
      expect(
        es(api.ErrorCode.customerPeriodCreditLimitExceeded, {
          'outstanding': '18450.00',
          'limit': 'lots',
        }),
        isNull,
      );
    });
  });

  test('cash session busy codes read as the form shows them today', () {
    expect(
      es(api.ErrorCode.cashSessionPeriodDrawerBusy, {'cash_drawer_id': 3}),
      'Esa caja ya tiene una sesión abierta.',
    );
    expect(
      es(api.ErrorCode.cashSessionPeriodUserBusy, {'cash_session_id': 41}),
      'Ya tienes una sesión abierta. Ciérrala antes de abrir otra.',
    );
    expect(
      en(api.ErrorCode.cashSessionPeriodNotOpen),
      'You need an open cash session for this.',
    );
  });

  test('csd refusals name what is wrong with the files', () {
    expect(
      es(api.ErrorCode.csdPeriodKeyMismatch),
      'La llave (.key) no corresponde al certificado (.cer).',
    );
    expect(
      en(api.ErrorCode.csdPeriodKeyUnreadable),
      "The key couldn't be opened. Check the password and the .key file.",
    );
  });
}
