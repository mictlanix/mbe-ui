import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/agent_form_controller.dart';

import '../../../widget/features/commissions/commission_harness.dart';
import 'commission_fixtures.dart';

void main() {
  late MockCommissionRepository repo;

  setUpAll(() => registerFallbackValue(CommissionScheme.fullyPaid));
  setUp(() => repo = MockCommissionRepository());

  CommissionAgentFormController start(CommissionAgent? agent) {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [commissionRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
    final provider = commissionAgentFormControllerProvider(agent);
    c.listen(provider, (_, _) {});
    return c.read(provider.notifier);
  }

  test('creating without an employee is refused', () async {
    final form = start(null);
    expect(await form.save(), isFalse);
    expect(form.state.employeeRequired, isTrue);
    verifyNever(() => repo.createAgent(any(), any()));
  });

  test('creates with fullyPaid by default', () async {
    when(
      () => repo.createAgent(9, CommissionScheme.fullyPaid),
    ).thenAnswer((_) async => anAgent(employeeId: 9));
    when(() => repo.listAgents()).thenAnswer((_) async => []);
    final form = start(null);
    form.employeeChosen(9);
    expect(await form.save(), isTrue);
    verify(() => repo.createAgent(9, CommissionScheme.fullyPaid)).called(1);
  });

  test('changing the scheme updates the same employee', () async {
    when(
      () => repo.updateAgent(7, CommissionScheme.partialPayments),
    ).thenAnswer((_) async => anAgent());
    final form = start(anAgent());
    expect(form.isDirty, isFalse);
    form.schemeChanged(CommissionScheme.partialPayments);
    expect(form.isDirty, isTrue);
    expect(await form.save(), isTrue);
  });

  test('an agent with rates is refused on delete', () async {
    when(
      () => repo.deleteAgent(7),
    ).thenThrow(aRefusal(api.ErrorCode.resourcePeriodStillReferenced, 'x', {}));
    final form = start(anAgent());
    expect(await form.delete(), isFalse);
    expect(form.state.error, isNotNull);
  });
}
