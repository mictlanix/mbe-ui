import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_month_controller.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_period_actions.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_periods_controller.dart';

import '../../../widget/features/commissions/commission_harness.dart';
import 'commission_fixtures.dart';

void main() {
  late MockCommissionRepository repo;
  late ProviderContainer container;
  const month = CommissionMonth(year: 2026, month: 10);
  var monthReads = 0;
  var listReads = 0;

  setUp(() {
    repo = MockCommissionRepository();
    monthReads = 0;
    listReads = 0;
    when(() => repo.getPeriod(month, agentId: null)).thenAnswer((_) async {
      monthReads++;
      return aPeriod();
    });
    when(() => repo.listPeriods()).thenAnswer((_) async {
      listReads++;
      return [aPeriodSummary()];
    });
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [commissionRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
  });

  /// Keeps both providers alive, as the month screen does, and reads them
  /// once.
  Future<void> watchBoth() async {
    container.listen(commissionMonthControllerProvider(month, null), (_, _) {});
    container.listen(commissionPeriodsControllerProvider, (_, _) {});
    await container.read(commissionMonthControllerProvider(month, null).future);
    await container.read(commissionPeriodsControllerProvider.future);
    expect((monthReads, listReads), (1, 1));
  }

  CommissionPeriodActions actions() =>
      container.read(commissionPeriodActionsProvider.notifier);

  group('success re-reads the month and the months list', () {
    test('close', () async {
      when(
        () => repo.closePeriod(month),
      ).thenAnswer((_) async => aPeriodSummary());
      await watchBoth();

      expect(await actions().close(month), isNull);
      await container.read(
        commissionMonthControllerProvider(month, null).future,
      );
      await container.read(commissionPeriodsControllerProvider.future);

      verify(() => repo.closePeriod(month)).called(1);
      expect((monthReads, listReads), (2, 2));
    });

    test('reopen', () async {
      when(
        () => repo.reopenPeriod(month),
      ).thenAnswer((_) async => aPeriodSummary());
      await watchBoth();

      expect(await actions().reopen(month), isNull);
      await container.read(
        commissionMonthControllerProvider(month, null).future,
      );
      await container.read(commissionPeriodsControllerProvider.future);

      expect((monthReads, listReads), (2, 2));
    });

    test('pay', () async {
      when(
        () => repo.payPeriod(month),
      ).thenAnswer((_) async => aPeriodSummary());
      await watchBoth();

      expect(await actions().pay(month), isNull);
      await container.read(
        commissionMonthControllerProvider(month, null).future,
      );
      await container.read(commissionPeriodsControllerProvider.future);

      expect((monthReads, listReads), (2, 2));
    });
  });

  group('every refusal surfaces and still re-reads both', () {
    final closeCodes = {
      api.ErrorCode.commissionPeriodPeriodNotEnded:
          'commission_period.not_ended',
      api.ErrorCode.commissionPeriodPeriodPreviousNotClosed:
          'commission_period.previous_not_closed',
      api.ErrorCode.commissionPeriodPeriodLaterClosed:
          'commission_period.later_closed',
      api.ErrorCode.commissionPeriodPeriodAlreadyClosed:
          'commission_period.already_closed',
      api.ErrorCode.commissionPeriodPeriodAlreadyPaid:
          'commission_period.already_paid',
    };
    final reopenCodes = {
      api.ErrorCode.commissionPeriodPeriodNotClosed:
          'commission_period.not_closed',
      api.ErrorCode.commissionPeriodPeriodPaidCannotReopen:
          'commission_period.paid_cannot_reopen',
      api.ErrorCode.commissionPeriodPeriodLaterClosed:
          'commission_period.later_closed',
    };
    final payCodes = {
      api.ErrorCode.commissionPeriodPeriodNotClosed:
          'commission_period.not_closed',
      api.ErrorCode.commissionPeriodPeriodAlreadyPaid:
          'commission_period.already_paid',
    };

    Future<void> expectRefused(
      Future<AppError?> Function() run,
      api.ErrorCode code,
    ) async {
      await watchBoth();
      final error = await run();
      expect(error, isNotNull);
      expect(error!.problem?.code, code);
      await container.read(
        commissionMonthControllerProvider(month, null).future,
      );
      await container.read(commissionPeriodsControllerProvider.future);
      expect((monthReads, listReads), (2, 2));
    }

    for (final entry in closeCodes.entries) {
      test('close: ${entry.value}', () async {
        when(
          () => repo.closePeriod(month),
        ).thenThrow(aRefusal(entry.key, entry.value));
        await expectRefused(() => actions().close(month), entry.key);
      });
    }
    for (final entry in reopenCodes.entries) {
      test('reopen: ${entry.value}', () async {
        when(
          () => repo.reopenPeriod(month),
        ).thenThrow(aRefusal(entry.key, entry.value));
        await expectRefused(() => actions().reopen(month), entry.key);
      });
    }
    for (final entry in payCodes.entries) {
      test('pay: ${entry.value}', () async {
        when(
          () => repo.payPeriod(month),
        ).thenThrow(aRefusal(entry.key, entry.value));
        await expectRefused(() => actions().pay(month), entry.key);
      });
    }
  });

  group('assignLabel', () {
    test(
      'sets the product label, then re-reads the month and the list',
      () async {
        when(() => repo.setProductLabel(5, 3)).thenAnswer(
          (_) async => const CommissionProductLabel(
            productId: 5,
            productCode: 'T-5',
            productName: 'Tornillo',
            labelId: 3,
          ),
        );
        await watchBoth();

        expect(await actions().assignLabel(5, 3), isNull);
        await container.read(
          commissionMonthControllerProvider(month, null).future,
        );
        await container.read(commissionPeriodsControllerProvider.future);

        verify(() => repo.setProductLabel(5, 3)).called(1);
        expect((monthReads, listReads), (2, 2));
      },
    );

    test('a refusal is answered and the month is still re-read', () async {
      when(() => repo.setProductLabel(5, 3)).thenThrow(
        aRefusal(api.ErrorCode.authPeriodForbidden, 'auth.forbidden'),
      );
      await watchBoth();

      final error = await actions().assignLabel(5, 3);
      await container.read(
        commissionMonthControllerProvider(month, null).future,
      );
      await container.read(commissionPeriodsControllerProvider.future);

      expect(error?.problem?.code, api.ErrorCode.authPeriodForbidden);
      expect((monthReads, listReads), (2, 2));
    });
  });
}
