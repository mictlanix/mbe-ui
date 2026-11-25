import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/percent_input.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/agent_rates_controller.dart';

import '../../../widget/features/commissions/commission_harness.dart';
import 'commission_fixtures.dart';

void main() {
  late MockCommissionRepository repo;

  setUpAll(() => registerFallbackValue(d('0')));

  setUp(() {
    repo = MockCommissionRepository();
    when(() => repo.listLabels()).thenAnswer(
      (_) async => [
        CommissionLabel(id: 2, name: 'Zeta', rate: d('0.04')),
        CommissionLabel(id: 1, name: 'Alfa', rate: d('0.002')),
      ],
    );
    when(() => repo.listParticipations()).thenAnswer(
      (_) async => const [
        CommissionParticipation(id: 3, name: 'C'),
        CommissionParticipation(id: 1, name: 'A'),
      ],
    );
    when(() => repo.listAgentRates(agentId: 7)).thenAnswer(
      (_) async => [
        CommissionAgentRate(
          id: 50,
          agentId: 7,
          labelId: 1,
          participationId: 3,
          share: d('0.500000'),
        ),
      ],
    );
  });

  Future<(ProviderContainer, AgentRatesController)> start({
    int commissions = 15,
  }) async {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        commissionRepositoryProvider.overrideWithValue(repo),
        accessControlProvider.overrideWithValue(
          AccessControlService(
            AuthState.authenticated(
              token: 't',
              user: CommissionHarness.user(commissions: commissions),
            ),
          ),
        ),
      ],
    );
    addTearDown(c.dispose);
    final provider = agentRatesControllerProvider(7);
    c.listen(provider, (_, _) {});
    await c.read(provider.future);
    return (c, c.read(provider.notifier));
  }

  AgentRateGrid grid(ProviderContainer c) =>
      c.read(agentRatesControllerProvider(7)).requireValue;

  test('every label and participation appears, empty cells included', () async {
    final (c, _) = await start();
    final g = grid(c);
    expect(g.labels.map((l) => l.name), ['Alfa', 'Zeta']);
    expect(g.participations.map((p) => p.id), [1, 3]);
    expect(g.cells.length, 4);
    expect(g.cell(1, 3).rateId, 50);
    expect(g.cell(1, 3).wire, '0.5');
    expect(g.cell(1, 1).isEmpty, isTrue);
    expect(g.cell(2, 3).isEmpty, isTrue);
  });

  test('typing into an empty cell creates the rate', () async {
    when(
      () => repo.createAgentRate(
        agentId: 7,
        labelId: 2,
        participationId: 1,
        share: any(named: 'share'),
      ),
    ).thenAnswer(
      (_) async => CommissionAgentRate(
        id: 60,
        agentId: 7,
        labelId: 2,
        participationId: 1,
        share: d('0.025'),
      ),
    );
    final (c, n) = await start();
    expect(await n.writeCell(2, 1, '2.5'), isTrue);
    verify(
      () => repo.createAgentRate(
        agentId: 7,
        labelId: 2,
        participationId: 1,
        share: d('0.025'),
      ),
    ).called(1);
    expect(grid(c).cell(2, 1).rateId, 60);
    expect(grid(c).saved.containsKey((2, 1)), isTrue);
    // Patched in place: the rates were read once.
    verify(() => repo.listAgentRates(agentId: 7)).called(1);
  });

  test('changing a filled cell updates, clearing deletes', () async {
    when(() => repo.updateAgentRate(50, any())).thenAnswer(
      (_) async => CommissionAgentRate(
        id: 50,
        agentId: 7,
        labelId: 1,
        participationId: 3,
        share: d('0.25'),
      ),
    );
    when(() => repo.deleteAgentRate(50)).thenAnswer((_) async {});
    final (c, n) = await start();
    expect(await n.writeCell(1, 3, '25'), isTrue);
    verify(() => repo.updateAgentRate(50, d('0.25'))).called(1);
    expect(grid(c).cell(1, 3).wire, '0.25');
    expect(grid(c).saved[(1, 3)], d('0.5'));

    expect(await n.writeCell(1, 3, ''), isTrue);
    verify(() => repo.deleteAgentRate(50)).called(1);
    expect(grid(c).cell(1, 3).isEmpty, isTrue);
  });

  test('writability follows the rights of each call', () async {
    final (_, createOnly) = await start(commissions: 3);
    const empty = AgentRateCell(labelId: 1, participationId: 1);
    const filled = AgentRateCell(labelId: 1, participationId: 3, rateId: 50);
    expect(createOnly.isWritable(empty), isTrue);
    expect(createOnly.isWritable(filled), isFalse);
    expect(createOnly.canClear, isFalse);

    final (_, updateOnly) = await start(commissions: 6);
    expect(updateOnly.isWritable(empty), isFalse);
    expect(updateOnly.isWritable(filled), isTrue);

    final (_, readOnly) = await start(commissions: 2);
    expect(readOnly.isWritable(empty), isFalse);
    expect(readOnly.isWritable(filled), isFalse);
  });

  test('clearing without Delete is refused and keeps the value', () async {
    final (c, n) = await start(commissions: 6);
    expect(await n.writeCell(1, 3, ''), isFalse);
    verifyNever(() => repo.deleteAgentRate(any()));
    expect(grid(c).refusals[(1, 3)]!.clearNotAllowed, isTrue);
    expect(grid(c).cell(1, 3).wire, '0.5');
  });

  test('a value out of range is refused before sending', () async {
    final (c, n) = await start();
    expect(await n.writeCell(1, 1, '120'), isFalse);
    expect(grid(c).refusals[(1, 1)]!.input, PercentInputError.outOfRange);
    verifyNever(
      () => repo.createAgentRate(
        agentId: any(named: 'agentId'),
        labelId: any(named: 'labelId'),
        participationId: any(named: 'participationId'),
        share: any(named: 'share'),
      ),
    );
  });

  test('a duplicate and a non-agent refusal stay on their cell', () async {
    final (c, n) = await start();
    when(
      () => repo.createAgentRate(
        agentId: 7,
        labelId: 1,
        participationId: 1,
        share: any(named: 'share'),
      ),
    ).thenThrow(
      aRefusal(
        api.ErrorCode.resourcePeriodAlreadyExists,
        'resource.already_exists',
      ),
    );
    when(
      () => repo.createAgentRate(
        agentId: 7,
        labelId: 2,
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
    expect(await n.writeCell(1, 1, '10'), isFalse);
    expect(await n.writeCell(2, 1, '10'), isFalse);
    final g = grid(c);
    expect(
      g.refusals[(1, 1)]!.error!.problem!.codeName,
      'resource.already_exists',
    );
    expect(
      g.refusals[(2, 1)]!.error!.problem!.codeName,
      'commission_agent.salesperson_not_agent',
    );
    expect(g.cell(1, 1).isEmpty, isTrue);
    expect(g.cell(2, 1).isEmpty, isTrue);

    // The next write to the cell clears its refusal.
    when(
      () => repo.createAgentRate(
        agentId: 7,
        labelId: 1,
        participationId: 1,
        share: any(named: 'share'),
      ),
    ).thenAnswer(
      (_) async => CommissionAgentRate(
        id: 61,
        agentId: 7,
        labelId: 1,
        participationId: 1,
        share: d('0.1'),
      ),
    );
    expect(await n.writeCell(1, 1, '10'), isTrue);
    expect(grid(c).refusals.containsKey((1, 1)), isFalse);
    expect(grid(c).refusals.containsKey((2, 1)), isTrue);
  });
}
