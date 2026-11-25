import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/participation_form_controller.dart';

import '../../../widget/features/commissions/commission_harness.dart';

void main() {
  late MockCommissionRepository repo;
  const p = CommissionParticipation(id: 2, name: 'CANALIZACION');

  setUp(() => repo = MockCommissionRepository());

  CommissionParticipationFormController start(
    CommissionParticipation? participation,
  ) {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [commissionRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
    final provider = commissionParticipationFormControllerProvider(
      participation,
    );
    c.listen(provider, (_, _) {});
    return c.read(provider.notifier);
  }

  test('a blank name is refused', () async {
    final form = start(null);
    form.nameChanged('   ');
    expect(await form.save(), isFalse);
    expect(form.state.nameRequired, isTrue);
    verifyNever(() => repo.createParticipation(any()));
  });

  test('creates with the trimmed name', () async {
    when(() => repo.createParticipation('Nueva')).thenAnswer((_) async => p);
    when(() => repo.listParticipations()).thenAnswer((_) async => []);
    final form = start(null);
    form.nameChanged(' Nueva ');
    expect(await form.save(), isTrue);
    verify(() => repo.createParticipation('Nueva')).called(1);
  });

  test('updates and tracks dirtiness', () async {
    when(() => repo.updateParticipation(2, 'Otra')).thenAnswer((_) async => p);
    final form = start(p);
    expect(form.isDirty, isFalse);
    form.nameChanged('Otra');
    expect(form.isDirty, isTrue);
    expect(await form.save(), isTrue);
  });

  test('a participation in use is refused', () async {
    when(
      () => repo.deleteParticipation(2),
    ).thenThrow(aRefusal(api.ErrorCode.resourcePeriodStillReferenced, 'x', {}));
    final form = start(p);
    expect(await form.delete(), isFalse);
    expect(form.state.error, isNotNull);
  });
}
