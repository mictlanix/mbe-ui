import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/presentation/shared/commission_lookups.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../widget/features/commissions/commission_harness.dart';
import 'commission_fixtures.dart';

ProviderContainer _container(
  MockCommissionRepository repo, {
  String? employeeName,
}) {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      commissionRepositoryProvider.overrideWithValue(repo),
      employeeDisplayNameProvider.overrideWith((ref, id) async => employeeName),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  late MockCommissionRepository repo;

  setUp(() {
    repo = MockCommissionRepository();
    when(() => repo.listAgents()).thenAnswer((_) async => [anAgent()]);
  });

  group('commissionAgentNameProvider (research R3)', () {
    test('a current agent resolves to the agents list name', () async {
      final container = _container(repo, employeeName: 'Otro nombre');
      final name = await container.read(commissionAgentNameProvider(7).future);
      expect(name, anAgent().name);
    });

    test('a former agent falls back to the employee name', () async {
      final container = _container(repo, employeeName: 'Ana Pérez');
      final name = await container.read(commissionAgentNameProvider(99).future);
      expect(name, 'Ana Pérez');
    });

    test('an unknown employee resolves to null', () async {
      final container = _container(repo);
      final name = await container.read(commissionAgentNameProvider(99).future);
      expect(name, isNull);
    });

    test('a failed agents read degrades to the employee name', () async {
      when(() => repo.listAgents()).thenThrow(Exception('boom'));
      final container = _container(repo, employeeName: 'Ana Pérez');
      final name = await container.read(commissionAgentNameProvider(7).future);
      expect(name, 'Ana Pérez');
    });
  });

  group('list providers', () {
    test('labels and participations read through the repository', () async {
      when(() => repo.listLabels()).thenAnswer((_) async => [aLabel()]);
      when(() => repo.listParticipations()).thenAnswer((_) async => []);
      final container = _container(repo);
      expect(await container.read(commissionLabelsProvider.future), [aLabel()]);
      expect(
        await container.read(commissionParticipationsProvider.future),
        isEmpty,
      );
    });
  });

  group('CommissionAgentName', () {
    Future<void> pumpName(WidgetTester tester, int id) async {
      final container = _container(repo);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('es', 'MX'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: CommissionAgentName(agentId: id)),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows the agent name', (tester) async {
      await pumpName(tester, 7);
      expect(find.text(anAgent().name), findsOneWidget);
    });

    testWidgets('shows the localized fallback when nothing knows the id', (
      tester,
    ) async {
      await pumpName(tester, 99);
      expect(find.text('Agente #99'), findsOneWidget);
    });
  });
}
