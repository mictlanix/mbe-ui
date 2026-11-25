import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../unit/features/commissions/commission_fixtures.dart';
import 'commission_harness.dart';

/// The test font is far wider than the app's, so the five-segment switch needs
/// a wider surface than the harness default.
const wide = Size(2200, 1000);

void main() {
  late CommissionHarness h;

  setUp(() {
    h = CommissionHarness();
    when(() => h.repo.listLabels()).thenAnswer((_) async => [aLabel()]);
    when(() => h.repo.listParticipations()).thenAnswer((_) async => []);
    when(() => h.repo.listAgents()).thenAnswer((_) async => [anAgent()]);
    when(
      () => h.repo.listAgentRates(agentId: any(named: 'agentId')),
    ).thenAnswer((_) async => []);
  });

  const note =
      'Los cambios aplican a meses abiertos y cálculos futuros, nunca a '
      'meses cerrados.';

  testWidgets('opens on Etiquetas and shows the note', (tester) async {
    await h.pump(tester, location: '/commissions/settings', surface: wide);

    expect(key('commission_labels_table'), findsOneWidget);
    expect(find.text(note), findsOneWidget);
    expect(key('commission_settings_section_switch'), findsOneWidget);
    expect(find.text('Productos'), findsOneWidget);
  });

  testWidgets('switching sections goes through the URL and keeps the note', (
    tester,
  ) async {
    final router = await h.pump(
      tester,
      location: '/commissions/settings?section=labels',
      surface: wide,
    );

    await tester.tap(find.text('Agentes'));
    await tester.pumpAndSettle();
    expect(router.state.uri.queryParameters['section'], 'agents');
    expect(key('commission_agents_table'), findsOneWidget);
    expect(find.text(note), findsOneWidget);

    await tester.tap(find.text('Participaciones'));
    await tester.pumpAndSettle();
    expect(router.state.uri.queryParameters['section'], 'participations');
    expect(find.text(note), findsOneWidget);

    await tester.tap(find.text('Tasas por agente'));
    await tester.pumpAndSettle();
    expect(router.state.uri.queryParameters['section'], 'rates');
    expect(key('commission_rates_agent_strip'), findsOneWidget);
    expect(find.text(note), findsOneWidget);
  });

  testWidgets('an unknown section falls back to Etiquetas', (tester) async {
    await h.pump(
      tester,
      location: '/commissions/settings?section=zzz',
      surface: wide,
    );
    expect(key('commission_labels_table'), findsOneWidget);
  });

  testWidgets('below 600 px the switch is a dropdown', (tester) async {
    final router = await h.pump(
      tester,
      location: '/commissions/settings',
      surface: const Size(500, 900),
    );
    expect(key('commission_settings_section_switch'), findsNothing);
    expect(key('commission_settings_section_dropdown'), findsOneWidget);

    await tester.tap(key('commission_settings_section_dropdown'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agentes').last);
    await tester.pumpAndSettle();
    expect(router.state.uri.queryParameters['section'], 'agents');
  });

  testWidgets('a Read-only user sees no create or edit actions', (
    tester,
  ) async {
    await h.pump(
      tester,
      who: CommissionHarness.readOnlyUser(),
      location: '/commissions/settings',
      surface: wide,
    );
    expect(key('commission_new_label_button'), findsNothing);
    expect(key('commission_label_edit_3'), findsNothing);

    for (final section in ['participations', 'agents']) {
      await tester.tap(
        find.text(section == 'agents' ? 'Agentes' : 'Participaciones'),
      );
      await tester.pumpAndSettle();
      expect(
        key(
          'commission_new_${section.substring(0, section.length - 1)}_button',
        ),
        findsNothing,
      );
    }
  });

  testWidgets('a failed load offers a retry', (tester) async {
    when(() => h.repo.listLabels()).thenThrow(Exception('boom'));
    await h.pump(tester, location: '/commissions/settings', surface: wide);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
