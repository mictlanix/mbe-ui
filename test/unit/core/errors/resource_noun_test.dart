import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/localize_problem.dart';

import 'problem_test_env.dart';

void main() {
  late ProblemEnv env;

  setUpAll(() async => env = await ProblemEnv.load());

  group('resourceNoun', () {
    test('singular and plural in both languages', () {
      expect(resourceNoun('customer', env.en), 'customer');
      expect(resourceNoun('customer', env.en, count: 3), 'customers');
      expect(resourceNoun('customer', env.es), 'cliente');
      expect(resourceNoun('customer', env.es, count: 3), 'clientes');
      expect(resourceNoun('sales_order', env.es, count: 12), 'pedidos');
      expect(
        resourceNoun('cash_session', env.es, count: 2),
        'sesiones de caja',
      );
      expect(resourceNoun('supplier_bank_account', env.es), 'cuenta bancaria');
      expect(
        resourceNoun('supplier_agreement', env.en, count: 2),
        'agreements',
      );
      expect(resourceGender('customer_address', env.es), 'feminine');
    });

    test('a kind the app has no noun for is the generic noun, never the '
        "server's internal name", () {
      expect(resourceNoun('some_new_table', env.en), 'record');
      expect(resourceNoun('some_new_table', env.es, count: 2), 'registros');
      expect(resourceNoun(null, env.es), 'registro');
    });
  });

  group('resourceGender', () {
    test('masculine and feminine for the Spanish sentence around the noun', () {
      expect(resourceGender('customer', env.es), 'masculine');
      expect(resourceGender('facility', env.es), 'feminine');
      expect(resourceGender('price_list', env.es), 'feminine');
      expect(resourceGender('warehouse', env.es), 'masculine');
      expect(resourceGender('some_new_table', env.es), 'masculine');
    });
  });
}
