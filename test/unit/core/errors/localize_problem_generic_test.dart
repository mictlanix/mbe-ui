import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';

import 'problem_test_env.dart';

ApiProblem _problem(
  api.ErrorCode code, [
  Map<String, Object?> params = const {},
]) => ApiProblem(codeName: 'x', code: code, params: params);

void main() {
  late ProblemEnv env;

  setUpAll(() async => env = await ProblemEnv.load());

  String? en(api.ErrorCode code, [Map<String, Object?> params = const {}]) =>
      localizeProblem(_problem(code, params), env.en, env.fmtEn);
  String? es(api.ErrorCode code, [Map<String, Object?> params = const {}]) =>
      localizeProblem(_problem(code, params), env.es, env.fmtEs);

  group('codes with no params', () {
    test('render in both languages', () {
      expect(
        en(api.ErrorCode.authPeriodInvalidCredentials),
        'Invalid username or password.',
      );
      expect(
        es(api.ErrorCode.authPeriodInvalidCredentials),
        'Usuario o contraseña incorrectos.',
      );
      expect(
        es(api.ErrorCode.serverPeriodError),
        'Ocurrió un error en el servidor. Inténtalo de nuevo más tarde.',
      );
      expect(
        es(api.ErrorCode.authPeriodNotAuthenticated),
        'Tu sesión expiró. Vuelve a iniciar sesión.',
      );
    });

    test('auth.forbidden never lists the grants that would open the route', () {
      const required = [
        {'system_object': 7, 'right': 2},
      ];
      expect(
        es(api.ErrorCode.authPeriodForbidden, {'required': required}),
        'No tienes permiso para esta acción.',
      );
      expect(
        en(api.ErrorCode.authPeriodForbidden, {'required': required}),
        isNot(contains('7')),
      );
    });
  });

  group('resource.not_found', () {
    test('names the record kind, with Spanish gender agreement', () {
      expect(
        en(api.ErrorCode.resourcePeriodNotFound, {
          'resource': 'customer',
          'id': 9,
        }),
        "Couldn't find the customer. It may have been deleted.",
      );
      expect(
        es(api.ErrorCode.resourcePeriodNotFound, {
          'resource': 'customer',
          'id': 9,
        }),
        'No se encontró el cliente. Puede que se haya eliminado.',
      );
      expect(
        es(api.ErrorCode.resourcePeriodNotFound, {'resource': 'price_list'}),
        'No se encontró la lista de precios. Puede que se haya eliminado.',
      );
    });

    test(
      'an unknown record kind uses the generic noun, not the server name',
      () {
        final text = es(api.ErrorCode.resourcePeriodNotFound, {
          'resource': 'some_new_table',
        });
        expect(
          text,
          'No se encontró el registro. Puede que se haya eliminado.',
        );
        expect(text, isNot(contains('some_new_table')));
      },
    );

    test('a missing resource param has no message', () {
      expect(en(api.ErrorCode.resourcePeriodNotFound), isNull);
      expect(en(api.ErrorCode.resourcePeriodNotFound, {'resource': 7}), isNull);
    });
  });

  test('resource.already_exists agrees in gender and avoids articles', () {
    expect(
      en(api.ErrorCode.resourcePeriodAlreadyExists, {
        'resource': 'sales_order',
        'field': 'folio',
      }),
      'That value is already in use. Another order has it.',
    );
    expect(
      es(api.ErrorCode.resourcePeriodAlreadyExists, {
        'resource': 'sales_order',
        'field': 'folio',
      }),
      'Ese valor ya está en uso en otro pedido.',
    );
    expect(
      es(api.ErrorCode.resourcePeriodAlreadyExists, {
        'resource': 'facility',
        'field': 'name',
      }),
      'Ese valor ya está en uso en otra sucursal.',
    );
  });

  group('resource.still_referenced', () {
    const params = {
      'references': [
        {'resource': 'sales_order', 'count': 12},
        {'resource': 'inventory_transfer', 'count': 1},
      ],
      'more': 0,
    };

    test('lists the blockers with their counts, in the right plural', () {
      expect(
        en(api.ErrorCode.resourcePeriodStillReferenced, params),
        "This record can't be deleted because it's still in use: 12 orders, 1 transfer.",
      );
      expect(
        es(api.ErrorCode.resourcePeriodStillReferenced, params),
        'Este registro no se puede eliminar porque todavía está en uso: 12 pedidos, 1 traspaso.',
      );
    });

    test('says how many more there are', () {
      final more = {...params, 'more': 3};
      expect(
        es(api.ErrorCode.resourcePeriodStillReferenced, more),
        'Este registro no se puede eliminar porque todavía está en uso: 12 pedidos, 1 traspaso y 3 más.',
      );
      expect(
        en(api.ErrorCode.resourcePeriodStillReferenced, {...params, 'more': 1}),
        "This record can't be deleted because it's still in use: 12 orders, 1 transfer and 1 other.",
      );
    });

    test("a customer's own link records are named, not counted as records", () {
      expect(
        es(api.ErrorCode.resourcePeriodStillReferenced, {
          'references': [
            {'resource': 'sales_order', 'count': 11},
            {'resource': 'customer_address', 'count': 2},
            {'resource': 'customer_contact', 'count': 1},
          ],
          'more': 0,
        }),
        'Este registro no se puede eliminar porque todavía está en uso: '
        '11 pedidos, 2 direcciones, 1 contacto.',
      );
    });

    test('a blocker kind the app has no noun for is counted as records', () {
      expect(
        en(api.ErrorCode.resourcePeriodStillReferenced, {
          'references': [
            {'resource': 'future_table', 'count': 2},
          ],
        }),
        "This record can't be deleted because it's still in use: 2 records.",
      );
    });

    test('blockers that cannot be read fall back to the plain sentence', () {
      for (final broken in <Map<String, Object?>>[
        const {},
        const {'references': []},
        const {
          'references': [
            {'resource': 'sales_order', 'count': 'many'},
          ],
        },
      ]) {
        expect(
          es(api.ErrorCode.resourcePeriodStillReferenced, broken),
          'Este registro todavía está en uso y no se puede eliminar.',
        );
      }
    });
  });

  test('a problem with no known code has no message', () {
    expect(
      localizeProblem(
        const ApiProblem(codeName: 'future.code'),
        env.es,
        env.fmtEs,
      ),
      isNull,
    );
  });
}
