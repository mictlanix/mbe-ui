import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';

import '../../../unit/features/commissions/commission_fixtures.dart';
import 'commission_harness.dart';

const _wide = Size(2200, 1000);
const _path = '/commissions/settings?section=rates';

CommissionAgentRate _rate(
  int id,
  int label,
  int participation,
  String share, {
  int agent = 7,
}) => CommissionAgentRate(
  id: id,
  agentId: agent,
  labelId: label,
  participationId: participation,
  share: d(share),
);

void main() {
  late CommissionHarness h;

  setUpAll(() => registerFallbackValue(d('0')));

  setUp(() {
    h = CommissionHarness();
    when(() => h.repo.listLabels()).thenAnswer(
      (_) async => [
        CommissionLabel(id: 2, name: 'Zeta', rate: d('0.04')),
        CommissionLabel(id: 1, name: 'Alfa', rate: d('0.002')),
      ],
    );
    when(() => h.repo.listParticipations()).thenAnswer(
      (_) async => const [
        CommissionParticipation(id: 3, name: 'CAMPO'),
        CommissionParticipation(id: 1, name: 'VITALICIO'),
      ],
    );
    when(() => h.repo.listAgents()).thenAnswer(
      (_) async => [
        const CommissionAgent(
          employeeId: 9,
          name: 'Beto Díaz',
          scheme: CommissionScheme.fullyPaid,
        ),
        anAgent(),
      ],
    );
    when(() => h.repo.listAgentRates(agentId: 7)).thenAnswer(
      (_) async => [_rate(50, 1, 3, '0.500000'), _rate(51, 2, 1, '1.000000')],
    );
    when(
      () => h.repo.listAgentRates(agentId: 9),
    ).thenAnswer((_) async => [_rate(70, 2, 3, '0.25', agent: 9)]);
  });

  Future<void> pump(
    WidgetTester tester, {
    int commissions = 15,
    String location = _path,
    Size surface = _wide,
  }) => h.pump(
    tester,
    who: CommissionHarness.user(commissions: commissions),
    location: location,
    surface: surface,
  );

  Finder field(int label, int participation) =>
      key('commission_rate_field_${label}_$participation');

  Future<void> typeAndEnter(WidgetTester tester, Finder f, String text) async {
    await tester.enterText(f, text);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  String fieldText(WidgetTester tester, Finder f) =>
      tester.widget<TextField>(f).controller!.text;

  testWidgets('the first agent by name, every cell present', (tester) async {
    await pump(tester);

    expect(find.text('Ana Ruiz'), findsOneWidget);
    expect(key('commission_rates_agent_strip'), findsOneWidget);
    for (final l in [1, 2]) {
      for (final p in [1, 3]) {
        expect(field(l, p), findsOneWidget);
      }
    }
    // Rows by label name, columns by participation id.
    expect(
      tester.getTopLeft(key('commission_rate_row_1')).dy,
      lessThan(tester.getTopLeft(key('commission_rate_row_2')).dy),
    );
    expect(
      tester.getTopLeft(find.text('VITALICIO')).dx,
      lessThan(tester.getTopLeft(find.text('CAMPO')).dx),
    );
    expect(fieldText(tester, field(1, 3)), '50');
    expect(fieldText(tester, field(2, 1)), '100');
    expect(fieldText(tester, field(1, 1)), '');
    // The label's own rate sits beside its name.
    expect(find.text('0.20 %'), findsOneWidget);
  });

  testWidgets('typing into an empty cell and Enter creates the rate', (
    tester,
  ) async {
    when(
      () => h.repo.createAgentRate(
        agentId: 7,
        labelId: 1,
        participationId: 1,
        share: any(named: 'share'),
      ),
    ).thenAnswer((_) async => _rate(60, 1, 1, '0.025'));
    await pump(tester);

    await typeAndEnter(tester, field(1, 1), '2.5');

    verify(
      () => h.repo.createAgentRate(
        agentId: 7,
        labelId: 1,
        participationId: 1,
        share: d('0.025'),
      ),
    ).called(1);
    expect(fieldText(tester, field(1, 1)), '2.5');
    expect(find.text('Guardado'), findsOneWidget);
    // Patched in place: no refetch.
    verify(() => h.repo.listAgentRates(agentId: 7)).called(1);
  });

  testWidgets('changing a filled cell updates it and says what it was', (
    tester,
  ) async {
    when(
      () => h.repo.updateAgentRate(50, any()),
    ).thenAnswer((_) async => _rate(50, 1, 3, '0.25'));
    await pump(tester);

    await typeAndEnter(tester, field(1, 3), '25');

    verify(() => h.repo.updateAgentRate(50, d('0.25'))).called(1);
    expect(fieldText(tester, field(1, 3)), '25');
    expect(find.text('Guardado · antes 50.00 %'), findsOneWidget);
  });

  testWidgets('a cell can be changed and changed back in a row', (
    tester,
  ) async {
    when(
      () => h.repo.updateAgentRate(50, any()),
    ).thenAnswer((i) async => _rate(50, 1, 3, '${i.positionalArguments[1]}'));
    await pump(tester);

    await typeAndEnter(tester, field(1, 3), '25');
    verify(() => h.repo.updateAgentRate(50, d('0.25'))).called(1);

    await typeAndEnter(tester, field(1, 3), '50');
    verify(() => h.repo.updateAgentRate(50, d('0.5'))).called(1);
    expect(fieldText(tester, field(1, 3)), '50');
  });

  testWidgets('clearing a filled cell deletes the rate', (tester) async {
    when(() => h.repo.deleteAgentRate(50)).thenAnswer((_) async {});
    await pump(tester);

    await typeAndEnter(tester, field(1, 3), '');

    verify(() => h.repo.deleteAgentRate(50)).called(1);
    expect(fieldText(tester, field(1, 3)), '');
  });

  testWidgets('a Create-only user edits empty cells, not filled ones', (
    tester,
  ) async {
    await pump(tester, commissions: 3);

    expect(field(1, 1), findsOneWidget);
    expect(field(2, 3), findsOneWidget);
    expect(field(1, 3), findsNothing);
    expect(field(2, 1), findsNothing);
    expect(find.text('50.00 %'), findsOneWidget);
    expect(find.text('100.00 %'), findsOneWidget);
  });

  testWidgets('an Update-only user edits filled cells, not empty ones', (
    tester,
  ) async {
    await pump(tester, commissions: 6);

    expect(field(1, 3), findsOneWidget);
    expect(field(2, 1), findsOneWidget);
    expect(field(1, 1), findsNothing);
    expect(field(2, 3), findsNothing);
  });

  testWidgets('an Update-only user clearing a cell is refused and keeps the '
      'value', (tester) async {
    await pump(tester, commissions: 6);

    await typeAndEnter(tester, field(1, 3), '');

    verifyNever(() => h.repo.deleteAgentRate(any()));
    expect(find.text('No tienes permiso para borrar tasas.'), findsOneWidget);
    expect(fieldText(tester, field(1, 3)), '50');
  });

  testWidgets('120 is refused before sending, with the reason', (tester) async {
    await pump(tester);

    await typeAndEnter(tester, field(1, 1), '120');

    verifyNever(
      () => h.repo.createAgentRate(
        agentId: any(named: 'agentId'),
        labelId: any(named: 'labelId'),
        participationId: any(named: 'participationId'),
        share: any(named: 'share'),
      ),
    );
    expect(find.text('Debe estar entre 0 y 100.'), findsOneWidget);
    expect(fieldText(tester, field(1, 1)), '');
  });

  testWidgets('leaving a cell without Enter discards what was typed', (
    tester,
  ) async {
    await pump(tester);

    await tester.enterText(field(1, 1), '9');
    await tester.pump();
    // Focus moves to another cell: the draft is abandoned.
    await tester.tap(field(2, 3));
    await tester.pumpAndSettle();

    expect(fieldText(tester, field(1, 1)), '');
    verifyNever(
      () => h.repo.createAgentRate(
        agentId: any(named: 'agentId'),
        labelId: any(named: 'labelId'),
        participationId: any(named: 'participationId'),
        share: any(named: 'share'),
      ),
    );
  });

  testWidgets('a server refusal shows under the cell, in our words', (
    tester,
  ) async {
    when(
      () => h.repo.createAgentRate(
        agentId: 7,
        labelId: 1,
        participationId: 1,
        share: any(named: 'share'),
      ),
    ).thenThrow(
      aRefusal(
        api.ErrorCode.commissionAgentPeriodSalespersonNotAgent,
        'commission_agent.salesperson_not_agent',
        {'salesperson_id': 7},
      ),
    );
    await pump(tester);

    await typeAndEnter(tester, field(1, 1), '10');

    expect(key('commission_rate_error_1_1'), findsOneWidget);
    expect(
      find.text('El empleado #7 no es agente de comisiones.'),
      findsOneWidget,
    );
    expect(find.text('SERVER TEXT'), findsNothing);
    expect(fieldText(tester, field(1, 1)), '');
  });

  testWidgets('a Read-only user sees the grid as text', (tester) async {
    await pump(tester, commissions: 2);

    expect(find.byType(TextField), findsNothing);
    expect(key('commission_rate_text_1_3'), findsOneWidget);
    expect(find.text('50.00 %'), findsOneWidget);
    expect(find.text('100.00 %'), findsOneWidget);
  });

  testWidgets('"Ver tasas" opens the grid on that agent', (tester) async {
    await pump(tester, location: '$_path&agent=9');

    expect(find.text('Beto Díaz'), findsOneWidget);
    expect(fieldText(tester, field(2, 3)), '25');
    verify(() => h.repo.listAgentRates(agentId: 9)).called(1);
    verifyNever(() => h.repo.listAgentRates(agentId: 7));
  });

  testWidgets('the agent is picked in the filter drawer', (tester) async {
    await pump(tester);

    await tester.tap(key('commission_rates_filter_button'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: key('commission_rates_agent_picker'),
        matching: find.byType(TextField),
      ),
      'Beto',
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beto Díaz').last);
    await tester.pumpAndSettle();
    await tester.tap(key('filter_sheet_apply_button'));
    await tester.pumpAndSettle();

    expect(fieldText(tester, field(2, 3)), '25');
    expect(
      find.descendant(
        of: key('commission_rates_agent_strip'),
        matching: find.text('Beto Díaz'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('still a table at compact width', (tester) async {
    await pump(tester, surface: const Size(400, 900));

    expect(tester.takeException(), isNull);
    expect(key('commission_rates_grid'), findsOneWidget);
    expect(find.text('VITALICIO'), findsOneWidget);
    expect(find.text('CAMPO'), findsOneWidget);
  });

  group('the grid row is a control band (constitution §VI)', () {
    double baselineY(WidgetTester tester, Finder finder) {
      final box = tester.renderObject<RenderBox>(finder);
      return box.localToGlobal(Offset.zero).dy +
          box.getDryBaseline(box.constraints, TextBaseline.alphabetic)!;
    }

    for (final scale in [1.0, 1.3]) {
      testWidgets('equal insets and one text baseline at text scale $scale', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pump(tester);

        for (final labelId in [1, 2]) {
          final row = tester.getRect(key('commission_rate_row_$labelId'));
          final cells = [
            for (final p in [1, 3])
              tester.getRect(
                find.descendant(
                  of: key('commission_rate_${labelId}_$p'),
                  matching: find.byType(TextField),
                ),
              ),
          ];
          final top = cells.map((r) => r.top).reduce((a, b) => a < b ? a : b);
          final bottom = cells
              .map((r) => r.bottom)
              .reduce((a, b) => a > b ? a : b);
          expect(top - row.top, greaterThan(0));
          expect(top - row.top, closeTo(row.bottom - bottom, 0.5));

          final name = labelId == 1 ? 'Alfa' : 'Zeta';
          final rate = labelId == 1 ? '0.20 %' : '4.00 %';
          final inRow = find.descendant(
            of: key('commission_rate_row_$labelId'),
            matching: find.text(name),
          );
          final rateText = find.descendant(
            of: key('commission_rate_row_$labelId'),
            matching: find.text(rate),
          );
          final reference = baselineY(tester, inRow);
          expect(baselineY(tester, rateText), closeTo(reference, 0.5));
          for (final p in [1, 3]) {
            final text = find.descendant(
              of: key('commission_rate_${labelId}_$p'),
              matching: find.byType(EditableText),
            );
            expect(baselineY(tester, text), closeTo(reference, 0.5));
          }
        }
      });
    }

    testWidgets('read-only cell text shares the label baseline', (
      tester,
    ) async {
      await pump(tester, commissions: 2);

      final reference = baselineY(
        tester,
        find.descendant(
          of: key('commission_rate_row_1'),
          matching: find.text('Alfa'),
        ),
      );
      expect(
        baselineY(tester, key('commission_rate_text_1_3')),
        closeTo(reference, 0.5),
      );
    });
  });
}
