import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/formatting/percent_input.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/label_form_controller.dart';

import '../../../widget/features/commissions/commission_harness.dart';
import 'commission_fixtures.dart';

void main() {
  late MockCommissionRepository repo;

  setUpAll(() async {
    registerFallbackValue(d('0'));
    await initializeDateFormatting();
  });
  setUp(() => repo = MockCommissionRepository());

  Future<ProviderContainer> container() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        commissionRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<CommissionLabelFormController> start(
    ProviderContainer c, [
    CommissionLabel? label,
  ]) async {
    final provider = commissionLabelFormControllerProvider(label);
    c.listen(provider, (_, _) {});
    return c.read(provider.notifier);
  }

  test('a blank name is refused and nothing is sent', () async {
    final c = await container();
    final form = await start(c);
    form.rateChanged('2.5');
    expect(await form.save(), isFalse);
    expect(
      c.read(commissionLabelFormControllerProvider(null)).nameRequired,
      isTrue,
    );
    verifyNever(
      () => repo.createLabel(
        name: any(named: 'name'),
        rate: any(named: 'rate'),
        comment: any(named: 'comment'),
      ),
    );
  });

  test('a rate over 100 is out of range', () async {
    final c = await container();
    final form = await start(c);
    form.nameChanged('Premium');
    form.rateChanged('100.5');
    expect(await form.save(), isFalse);
    expect(
      c.read(commissionLabelFormControllerProvider(null)).rateError,
      PercentInputError.outOfRange,
    );
  });

  test('more than four decimals is too precise, and text is invalid', () async {
    final c = await container();
    final form = await start(c);
    form.nameChanged('Premium');
    form.rateChanged('2.12345');
    await form.save();
    expect(
      c.read(commissionLabelFormControllerProvider(null)).rateError,
      PercentInputError.tooPrecise,
    );
    form.rateChanged('abc');
    await form.save();
    expect(
      c.read(commissionLabelFormControllerProvider(null)).rateError,
      PercentInputError.invalid,
    );
  });

  test('creates with 2.5 sent as the fraction 0.025', () async {
    when(
      () => repo.createLabel(
        name: any(named: 'name'),
        rate: any(named: 'rate'),
        comment: any(named: 'comment'),
      ),
    ).thenAnswer((_) async => aLabel());
    when(() => repo.listLabels()).thenAnswer((_) async => []);
    final c = await container();
    final form = await start(c);
    form.nameChanged(' Premium ');
    form.rateChanged('2.5');
    expect(await form.save(), isTrue);
    verify(
      () => repo.createLabel(name: 'Premium', rate: d('0.025'), comment: null),
    ).called(1);
  });

  test('editing fills the rate as a percentage and updates', () async {
    when(
      () => repo.updateLabel(
        any(),
        name: any(named: 'name'),
        rate: any(named: 'rate'),
        comment: any(named: 'comment'),
      ),
    ).thenAnswer((_) async => aLabel());
    final c = await container();
    final label = aLabel(rate: '0.075000');
    final form = await start(c, label);
    expect(c.read(commissionLabelFormControllerProvider(label)).rate, '7.5');
    expect(form.isDirty, isFalse);
    form.commentChanged('x');
    expect(form.isDirty, isTrue);
    expect(await form.save(), isTrue);
    verify(
      () =>
          repo.updateLabel(3, name: 'Premium', rate: d('0.075'), comment: 'x'),
    ).called(1);
  });

  test('a label in use is refused and kept in the error', () async {
    when(
      () => repo.deleteLabel(3),
    ).thenThrow(aRefusal(api.ErrorCode.resourcePeriodStillReferenced, 'x', {}));
    final c = await container();
    final label = aLabel();
    final form = await start(c, label);
    expect(await form.delete(), isFalse);
    expect(
      c.read(commissionLabelFormControllerProvider(label)).error,
      isNotNull,
    );
  });
}
