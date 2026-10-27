import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_link_providers.dart';

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

CashSession _session(int id, {int? facilityId = 9}) => CashSession(
  cashSessionId: id,
  cashDrawerId: 1,
  cashDrawerName: 'Caja 1',
  cashDrawerCode: 'CJ1',
  cashDrawerFacilityId: facilityId,
  cashierId: 100,
  cashierName: 'Ana López',
  start: DateTime(2026, 8, 5, 9),
  openingAmount: '500',
);

/// Spec 054 FR-006a, R7: the cash-session picker has no search endpoint, and
/// the server would hand back any facility's session by id.
void main() {
  late MockCashSessionRepository repository;
  late AppFormatters fmt;

  setUpAll(() async => initializeDateFormatting());

  setUp(() {
    repository = MockCashSessionRepository();
    fmt = AppFormatters(
      locale: const Locale('es', 'MX'),
      settings: const FormattingSettings(),
    );
  });

  void stubList(List<CashSession> items) =>
      when(
        () => repository.list(
          facilityId: any(named: 'facilityId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => CashSessionListResult(items: items, total: items.length),
      );

  group('cashSessionLabel', () {
    test('formats #id · cashier · date', () {
      expect(
        cashSessionLabel(_session(42), fmt),
        '#42 · Ana López · 2026-08-05',
      );
    });
  });

  group('cashSessionLabelProvider', () {
    ProviderContainer container() {
      final c = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          cashSessionRepositoryProvider.overrideWithValue(repository),
          formattersProvider.overrideWithValue(fmt),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('resolves the session by id and formats its label', () async {
      when(
        () => repository.get(cashSessionId: 42),
      ).thenAnswer((_) async => _session(42));

      final label = await container().read(cashSessionLabelProvider(42).future);

      expect(label, '#42 · Ana López · 2026-08-05');
    });

    test('is null on any failure, so the caller falls back to the bare '
        'number', () async {
      when(
        () => repository.get(cashSessionId: 42),
      ).thenThrow(const AppError.notFound());

      final label = await container().read(cashSessionLabelProvider(42).future);

      expect(label, isNull);
    });
  });

  group('cashSessionPickerOptions', () {
    test('all digits: looks the session up by id and offers it when it '
        'belongs to the facility', () async {
      when(
        () => repository.get(cashSessionId: 42),
      ).thenAnswer((_) async => _session(42, facilityId: 9));

      final options = await cashSessionPickerOptions(
        repository,
        facilityId: 9,
        query: ' 42 ',
      );

      expect(options.map((s) => s.cashSessionId), [42]);
      verifyNever(
        () => repository.list(
          facilityId: any(named: 'facilityId'),
          limit: any(named: 'limit'),
        ),
      );
    });

    test('all digits: a session of another facility is not offered', () async {
      when(
        () => repository.get(cashSessionId: 42),
      ).thenAnswer((_) async => _session(42, facilityId: 4));

      expect(
        await cashSessionPickerOptions(repository, facilityId: 9, query: '42'),
        isEmpty,
      );
    });

    test(
      'all digits: a session with no known facility is not offered',
      () async {
        when(
          () => repository.get(cashSessionId: 42),
        ).thenAnswer((_) async => _session(42, facilityId: null));

        expect(
          await cashSessionPickerOptions(
            repository,
            facilityId: 9,
            query: '42',
          ),
          isEmpty,
        );
      },
    );

    test('all digits: a 404 gives no options', () async {
      when(
        () => repository.get(cashSessionId: 42),
      ).thenThrow(const AppError.notFound());

      expect(
        await cashSessionPickerOptions(repository, facilityId: 9, query: '42'),
        isEmpty,
      );
    });

    test('all digits: any other error gives no options', () async {
      when(
        () => repository.get(cashSessionId: 42),
      ).thenThrow(const AppError.network());

      expect(
        await cashSessionPickerOptions(repository, facilityId: 9, query: '42'),
        isEmpty,
      );
    });

    test('other text lists the facility\'s sessions, limit 20', () async {
      stubList([_session(1), _session(2)]);

      final options = await cashSessionPickerOptions(
        repository,
        facilityId: 9,
        query: 'ana',
      );

      expect(options.map((s) => s.cashSessionId), [1, 2]);
      verify(() => repository.list(facilityId: 9, limit: 20)).called(1);
      verifyNever(
        () => repository.get(cashSessionId: any(named: 'cashSessionId')),
      );
    });

    test('an empty box still lists the facility\'s sessions', () async {
      stubList([_session(1)]);

      final options = await cashSessionPickerOptions(
        repository,
        facilityId: 9,
        query: '',
      );

      expect(options, hasLength(1));
      verify(() => repository.list(facilityId: 9, limit: 20)).called(1);
    });

    test('a list error gives no options', () async {
      when(
        () => repository.list(
          facilityId: any(named: 'facilityId'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const AppError.server());

      expect(
        await cashSessionPickerOptions(repository, facilityId: 9, query: 'x'),
        isEmpty,
      );
    });

    test(
      'no facility: nothing is offered and the repository is untouched',
      () async {
        expect(
          await cashSessionPickerOptions(
            repository,
            facilityId: null,
            query: '42',
          ),
          isEmpty,
        );
        expect(
          await cashSessionPickerOptions(
            repository,
            facilityId: null,
            query: 'x',
          ),
          isEmpty,
        );
        verifyZeroInteractions(repository);
      },
    );
  });
}
