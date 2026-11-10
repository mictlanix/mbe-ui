import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/api_problem.dart';

void main() {
  group('ApiProblem.fromBody', () {
    test('reads a coded body: code, params and English detail', () {
      final problem = ApiProblem.fromBody({
        'status': 422,
        'code': 'customer.credit_hold',
        'detail': 'Customer is on credit hold',
        'params': {'customer_id': 812, 'overdue_count': 4, 'action': 'raise'},
      })!;

      expect(problem.codeName, 'customer.credit_hold');
      expect(problem.code, api.ErrorCode.customerPeriodCreditHold);
      expect(problem.detail, 'Customer is on credit hold');
      expect(problem.params['overdue_count'], 4);
      expect(problem.parts, isEmpty);
      expect(problem.detailItems, isEmpty);
    });

    test('an unknown code keeps its name and a null enum, never throws', () {
      final problem = ApiProblem.fromBody({
        'status': 409,
        'code': 'future.not_yet_invented',
        'detail': 'Some English',
      })!;

      expect(problem.codeName, 'future.not_yet_invented');
      expect(problem.code, isNull);
      expect(problem.detail, 'Some English');
    });

    test('a body without a string code is not a problem', () {
      expect(ApiProblem.fromBody({'detail': 'Not found'}), isNull);
      expect(ApiProblem.fromBody({'code': 42, 'detail': 'x'}), isNull);
      expect(ApiProblem.fromBody('plain text'), isNull);
      expect(ApiProblem.fromBody(null), isNull);
      expect(
        ApiProblem.fromBody([
          {'loc': <String>[], 'msg': 'x', 'type': 'y'},
        ]),
        isNull,
      );
    });

    test("today's dict detail: message is the detail, lines are the items", () {
      final problem = ApiProblem.fromBody({
        'status': 409,
        'code': 'sales_order.zero_priced_lines',
        'detail': {
          'message': 'Zero-priced lines',
          'lines': ['`A-1` has no price', '`B-2` has no price'],
        },
      })!;

      expect(problem.detail, 'Zero-priced lines');
      expect(problem.detailItems, ['`A-1` has no price', '`B-2` has no price']);
    });

    test('missing delivery details are read as items too', () {
      final problem = ApiProblem.fromBody({
        'status': 409,
        'code': 'sales_order.missing_delivery_details',
        'detail': {
          'message': 'Missing delivery details',
          'missing': ['destination', 'promise date'],
        },
      })!;

      expect(problem.detailItems, ['destination', 'promise date']);
    });

    test('errors[] parts keep their code, params and other keys', () {
      final problem = ApiProblem.fromBody({
        'status': 422,
        'code': 'inventory_count.batch_invalid',
        'detail': '2 invalid entries; nothing was applied',
        'errors': [
          {
            'index': 0,
            'product_code': 'X-1',
            'reason': 'unknown product',
            'code': 'inventory_count_line.product_unknown',
          },
          {
            'code': 'future.part',
            'params': {'product_code': 'Y-2'},
          },
        ],
      })!;

      expect(problem.parts, hasLength(2));
      expect(
        problem.parts[0].code,
        api.ErrorCode.inventoryCountLinePeriodProductUnknown,
      );
      expect(problem.parts[0].extra, {
        'index': 0,
        'product_code': 'X-1',
        'reason': 'unknown product',
      });
      expect(problem.parts[1].code, isNull);
      expect(problem.parts[1].codeName, 'future.part');
      expect(problem.parts[1].stringParam('product_code'), 'Y-2');
    });

    test('equal problems compare equal (AppError equality relies on it)', () {
      Map<String, Object?> body() => {
        'code': 'resource.not_found',
        'detail': 'Customer not found',
        'params': {'resource': 'customer', 'id': 9},
      };
      expect(ApiProblem.fromBody(body()), ApiProblem.fromBody(body()));
    });
  });

  group('typed param accessors', () {
    final problem = ApiProblem(
      codeName: 'x',
      params: {
        'count': 4,
        'count_text': '12',
        'count_bad': 'four',
        'amount': '18450.00',
        'amount_number': 12.5,
        'amount_bad': 'lots',
        'name': 'PT-001',
        'date': '2026-11-09',
        'datetime': '2026-11-09T10:30:00',
        'date_bad': 'tomorrow',
        'list': [1, 2],
        'maps': [
          {'resource': 'sales_order', 'count': 12},
          {'resource': 'inventory_transfer', 'count': 3},
        ],
        'maps_mixed': [
          {'resource': 'a'},
          'b',
        ],
      },
    );

    test('intParam: ints, numeric strings; null otherwise', () {
      expect(problem.intParam('count'), 4);
      expect(problem.intParam('count_text'), 12);
      expect(problem.intParam('count_bad'), isNull);
      expect(problem.intParam('absent'), isNull);
      expect(problem.intParam('name'), isNull);
    });

    test('decimalParam: numeric strings and numbers; null otherwise', () {
      expect(problem.decimalParam('amount'), '18450.00');
      expect(problem.decimalParam('amount_number'), '12.5');
      expect(problem.decimalParam('amount_bad'), isNull);
      expect(problem.decimalParam('absent'), isNull);
    });

    test('stringParam: strings only', () {
      expect(problem.stringParam('name'), 'PT-001');
      expect(problem.stringParam('count'), isNull);
    });

    test('dateParam: ISO date and datetime as wall-clock; null otherwise', () {
      expect(problem.dateParam('date'), DateTime(2026, 11, 9));
      expect(problem.dateParam('datetime'), DateTime(2026, 11, 9, 10, 30));
      expect(problem.dateParam('date_bad'), isNull);
      expect(problem.dateParam('count'), isNull);
    });

    test('listParam and mapListParam', () {
      expect(problem.listParam('list'), [1, 2]);
      expect(problem.listParam('count'), isNull);
      expect(problem.mapListParam('maps'), [
        {'resource': 'sales_order', 'count': 12},
        {'resource': 'inventory_transfer', 'count': 3},
      ]);
      expect(problem.mapListParam('maps_mixed'), isNull);
      expect(problem.mapListParam('absent'), isNull);
    });
  });
}
