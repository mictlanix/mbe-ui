import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/cash_session_status.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/presentation/cash_sessions_list_controller.dart';

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

CashSession _session(int id) => CashSession(
  cashSessionId: id,
  cashDrawerId: 1,
  cashDrawerName: 'Caja 1',
  cashDrawerCode: 'CJ1',
  cashierId: 100,
  cashierName: 'Ana López',
  start: DateTime(2026, 8, 5, 9),
  openingAmount: '500',
);

void main() {
  group('CashSessionFilter.fromQuery', () {
    test('no facets decode to all-null, page 0', () {
      final filter = CashSessionFilter.fromQuery(const ListQuery());
      expect(filter.cashDrawerId, isNull);
      expect(filter.cashierId, isNull);
      expect(filter.status, isNull);
      expect(filter.pageIndex, 0);
    });

    test('decodes the cash-drawer, cashier and status facets', () {
      final query = const ListQuery()
          .withFacet('cash-drawer', '5')
          .withFacet('cashier', '100')
          .withFacet('status', 'open');
      final filter = CashSessionFilter.fromQuery(query);
      expect(filter.cashDrawerId, 5);
      expect(filter.cashierId, 100);
      expect(filter.status, CashSessionStatus.open);
    });

    test('an unparseable facet value degrades to null rather than throwing', () {
      final query = const ListQuery().withFacet('cash-drawer', 'not-a-number');
      final filter = CashSessionFilter.fromQuery(query);
      expect(filter.cashDrawerId, isNull);
    });

    test('an unrecognized status name degrades to null', () {
      final query = const ListQuery().withFacet('status', 'not-a-status');
      final filter = CashSessionFilter.fromQuery(query);
      expect(filter.status, isNull);
    });
  });

  group('CashSessionFilterBadge', () {
    test('activeFilterCount counts each set facet independently', () {
      const filter = CashSessionFilter(cashDrawerId: 1, status: CashSessionStatus.open);
      expect(filter.activeFilterCount, 2);
      expect(filter.hasActiveFilters, isTrue);
    });

    test('no facets set means no active filters', () {
      const filter = CashSessionFilter();
      expect(filter.activeFilterCount, 0);
      expect(filter.hasActiveFilters, isFalse);
    });
  });

  group('CashSessionsListController', () {
    late MockCashSessionRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = MockCashSessionRepository();
      container = ProviderContainer(
        overrides: [cashSessionRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
    });

    test('forwards cashDrawerId, cashierId and status to the repository', () async {
      when(
        () => repository.list(
          cashDrawerId: 5,
          cashierId: 100,
          status: CashSessionStatus.open,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer((_) async => const CashSessionListResult(items: [], total: 0));

      const filter = CashSessionFilter(
        cashDrawerId: 5,
        cashierId: 100,
        status: CashSessionStatus.open,
      );
      await container.read(cashSessionsListControllerProvider(filter).future);

      verify(
        () => repository.list(
          cashDrawerId: 5,
          cashierId: 100,
          status: CashSessionStatus.open,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    });

    test('maps items and total onto a CatalogPage', () async {
      when(
        () => repository.list(
          cashDrawerId: any(named: 'cashDrawerId'),
          cashierId: any(named: 'cashierId'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => CashSessionListResult(items: [_session(1), _session(2)], total: 2),
      );

      final page = await container.read(
        cashSessionsListControllerProvider(const CashSessionFilter()).future,
      );

      expect(page.total, 2);
      expect(page.items.map((s) => s.cashSessionId), [1, 2]);
      expect(page.pageSize, 20);
    });

    test('a page beyond the result set clamps to the last valid page '
        '(shared fetchClampedPage behavior)', () async {
      when(
        () => repository.list(
          cashDrawerId: any(named: 'cashDrawerId'),
          cashierId: any(named: 'cashierId'),
          status: any(named: 'status'),
          skip: 100,
          limit: 20,
        ),
      ).thenAnswer((_) async => const CashSessionListResult(items: [], total: 5));
      when(
        () => repository.list(
          cashDrawerId: any(named: 'cashDrawerId'),
          cashierId: any(named: 'cashierId'),
          status: any(named: 'status'),
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer((_) async => CashSessionListResult(items: [_session(1)], total: 5));

      final page = await container.read(
        cashSessionsListControllerProvider(const CashSessionFilter(pageIndex: 5)).future,
      );

      expect(page.pageIndex, 0);
      expect(page.items, hasLength(1));
    });
  });
}
