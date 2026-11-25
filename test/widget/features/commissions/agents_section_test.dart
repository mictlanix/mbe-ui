import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/employee_repository.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';

import '../../../unit/features/commissions/commission_fixtures.dart';
import 'commission_harness.dart';

const _wide = Size(2200, 1000);
const _path = '/commissions/settings?section=agents';

class _MockEmployees extends Mock implements EmployeeRepository {}

EmployeeListItem _employee(int id, String name) => EmployeeListItem(
  employeeId: id,
  fullName: name,
  nickname: name,
  status: EntityStatus.active,
  salesPerson: true,
);

void main() {
  late CommissionHarness h;
  late _MockEmployees employees;

  setUpAll(() => registerFallbackValue(CommissionScheme.fullyPaid));

  setUp(() {
    h = CommissionHarness();
    employees = _MockEmployees();
    when(() => h.repo.listAgents()).thenAnswer((_) async => [anAgent()]);
    when(
      () => employees.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        salesPerson: any(named: 'salesPerson'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => EmployeeListResult(
        items: [_employee(7, 'Ana Ruiz'), _employee(9, 'Beto Díaz')],
        total: 2,
      ),
    );
  });

  Future<dynamic> pump(WidgetTester tester, {int commissions = 15}) => h.pump(
    tester,
    who: CommissionHarness.user(commissions: commissions),
    location: _path,
    surface: _wide,
    extraOverrides: [employeeRepositoryProvider.overrideWithValue(employees)],
  );

  testWidgets('a row shows the agent and the scheme', (tester) async {
    await pump(tester);
    expect(find.text('Ana Ruiz'), findsOneWidget);
    expect(find.text('Pago total'), findsOneWidget);
  });

  testWidgets('actions follow the rights', (tester) async {
    await pump(tester, commissions: 2);
    expect(key('commission_new_agent_button'), findsNothing);
    expect(key('commission_agent_edit_7'), findsNothing);
    // Ver tasas needs only Read.
    expect(key('commission_agent_rates_7'), findsOneWidget);
  });

  testWidgets('the picker leaves out current agents', (tester) async {
    await pump(tester);
    await tester.tap(key('commission_new_agent_button'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: key('commission_agent_employee_field'),
        matching: find.byType(TextField),
      ),
      'a',
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Beto Díaz'), findsOneWidget);
    // Only the table row behind the panel: she is not offered as an option.
    expect(find.text('Ana Ruiz'), findsOneWidget);
  });

  testWidgets('creating an agent without an employee asks for one', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(key('commission_new_agent_button'));
    await tester.pumpAndSettle();
    await tester.tap(key('commission_agent_save_button'));
    await tester.pumpAndSettle();
    expect(find.text('Elige un empleado.'), findsOneWidget);
    verifyNever(() => h.repo.createAgent(any(), any()));
  });

  testWidgets('changing the scheme updates the agent; the employee is fixed', (
    tester,
  ) async {
    when(
      () => h.repo.updateAgent(7, CommissionScheme.partialPayments),
    ).thenAnswer((_) async => anAgent());
    await pump(tester);

    await tester.tap(key('commission_agent_edit_7'));
    await tester.pumpAndSettle();
    final employee = tester.widget<TextField>(
      find.descendant(
        of: key('commission_agent_employee_field'),
        matching: find.byType(TextField),
      ),
    );
    expect(employee.enabled, isFalse);
    expect(key('commission_agent_scheme_note'), findsOneWidget);

    await tester.tap(key('commission_agent_scheme_partialPayments'));
    await tester.pumpAndSettle();
    await tester.tap(key('commission_agent_save_button'));
    await tester.pumpAndSettle();

    verify(
      () => h.repo.updateAgent(7, CommissionScheme.partialPayments),
    ).called(1);
    expect(key('commission_agent_save_button'), findsNothing);
  });

  testWidgets('removing an agent with rates shows the translated refusal', (
    tester,
  ) async {
    when(() => h.repo.deleteAgent(7)).thenThrow(
      aRefusal(
        api.ErrorCode.resourcePeriodStillReferenced,
        'resource.still_referenced',
        {
          'references': [
            {'resource': 'sales_order', 'count': 2},
          ],
          'more': 0,
        },
      ),
    );
    await pump(tester);

    await tester.tap(key('commission_agent_edit_7'));
    await tester.pumpAndSettle();
    await tester.tap(key('commission_agent_delete_button'));
    await tester.pumpAndSettle();
    await tester.tap(key('commission_agent_confirm_delete_button'));
    await tester.pumpAndSettle();

    expect(key('commission_agent_error'), findsOneWidget);
    expect(find.textContaining('todavía está en uso'), findsOneWidget);
    expect(find.text('SERVER TEXT'), findsNothing);
  });

  testWidgets('Ver tasas opens the rates section on that agent', (
    tester,
  ) async {
    final router = await pump(tester);
    await tester.tap(key('commission_agent_rates_7'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/commissions/settings');
    expect(router.state.uri.queryParameters, {
      'section': 'rates',
      'agent': '7',
    });
  });
}
