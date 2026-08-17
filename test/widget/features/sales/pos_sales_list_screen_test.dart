import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/date_range_filter_chip.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sales_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);

  final AuthState _state;

  @override
  Future<AuthState> build() async => _state;
}

const _pointSale = 3;

User _user({
  bool canUpdateSalesOrders = true,
  bool canCreatePos = true,
  int? pointSaleId = _pointSale,
}) => User(
  userId: 'cashier-1',
  email: 'cashier@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  settings: pointSaleId == null ? null : UserSettings(pointSaleId: pointSaleId),
  privileges: [
    if (canUpdateSalesOrders)
      const Privilege(systemObject: SystemObject.salesOrders, rawValue: 4),
    if (canCreatePos) const Privilege(systemObject: SystemObject.pos, rawValue: 1),
  ],
);

void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCashSessionRepository cashSessions;
  late MockCustomerRepository customers;

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    cashSessions = MockCashSessionRepository();
    customers = MockCustomerRepository();
    // Nothing here should ever reach for a customer: the Cliente column
    // reads the name mbe-api joins onto the row (#173). Stubbed to throw so
    // a regression that reintroduces the per-row lookup fails loudly rather
    // than quietly costing a request per row.
    when(() => customers.get(customerId: any(named: 'customerId')))
        .thenAnswer((_) async => throw const AppError.notFound());
    // The register's open-sales set (`openSalesSelectorControllerProvider`)
    // is watched for `saleIsWorkable`'s resumable-ids fallback — stubbed
    // empty by default so it resolves without needing delivery/facility
    // overrides too (its paid-bucket short-circuits on an empty list).
    for (final status in SaleStatus.values) {
      if (status == SaleStatus.cancelled) continue;
      when(
        () => salesOrders.listOpen(
          pointSale: any(named: 'pointSale'),
          status: status,
          dateFrom: any(named: 'dateFrom'),
        ),
      ).thenAnswer((_) async => const OpenSalePage(items: [], total: 0));
    }
    when(() => cashSessions.getCurrent()).thenAnswer(
      (_) async => const CurrentSession(state: SessionState.open),
    );
  });

  Future<void> pumpList(
    WidgetTester tester, {
    ListQuery query = const ListQuery(),
    User? user,
    bool sessionOpen = true,
  }) async {
    when(() => cashSessions.getCurrent()).thenAnswer(
      (_) async => CurrentSession(
        state: sessionOpen ? SessionState.open : SessionState.none,
      ),
    );
    await pumpPos(
      tester,
      PosSalesListScreen(query: query),
      overrides: [
        authNotifierProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: user ?? _user()),
          ),
        ),
        salesOrderOverride(salesOrders),
        cashSessionRepositoryProvider.overrideWithValue(cashSessions),
        customerRepositoryProvider.overrideWithValue(customers),
      ],
    );
  }

  // A real `GoRouter`, for tests that actually trigger a `context.go` (the
  // filter drawer's own navigation calls) rather than only inspecting
  // widget state — `pumpList`/`pumpPos` above have no GoRouter in their
  // tree at all, which is fine for read-only assertions but throws the
  // moment anything calls `context.go`.
  Future<GoRouter> pumpListRouted(
    WidgetTester tester, {
    ListQuery query = const ListQuery(),
  }) async {
    when(() => cashSessions.getCurrent()).thenAnswer(
      (_) async => const CurrentSession(state: SessionState.open),
    );
    final (router, _) = await pumpPosRouted(
      tester,
      initialLocation: query.toUri('/sales/pos').toString(),
      overrides: [
        authNotifierProvider.overrideWith(
          () => _FixedAuthNotifier(AuthState.authenticated(token: 't', user: _user())),
        ),
        salesOrderOverride(salesOrders),
        cashSessionRepositoryProvider.overrideWithValue(cashSessions),
        customerRepositoryProvider.overrideWithValue(customers),
      ],
    );
    return router;
  }

  group('PosSalesListScreen — rows and Edit gating (FR-006, FR-006a)', () {
    testWidgets('a draft sale shows an Edit icon', (tester) async {
      stubListSales(
        salesOrders,
        page: testSalesPage([testOpenSale(id: 1, status: SaleStatus.draft)]),
      );
      await pumpList(tester);

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('a completed sale with a balance shows an Edit icon', (
      tester,
    ) async {
      stubListSales(
        salesOrders,
        page: testSalesPage([
          testOpenSale(id: 2, status: SaleStatus.completed, balance: '50.00'),
        ]),
      );
      await pumpList(tester);

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets(
      'a finished (paid, zero balance, not in the resumable set) sale shows no Edit icon',
      (tester) async {
        stubListSales(
          salesOrders,
          page: testSalesPage([
            testOpenSale(id: 3, status: SaleStatus.paid, balance: '0'),
          ]),
        );
        await pumpList(tester);

        expect(find.byIcon(Icons.edit_outlined), findsNothing);
      },
    );

    testWidgets('a cancelled sale shows no Edit icon', (tester) async {
      stubListSales(
        salesOrders,
        page: testSalesPage([testOpenSale(id: 4, status: SaleStatus.cancelled)]),
      );
      await pumpList(tester);

      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    });

    testWidgets(
      'a workable sale still shows no Edit icon without the salesOrders update privilege',
      (tester) async {
        stubListSales(
          salesOrders,
          page: testSalesPage([testOpenSale(id: 1, status: SaleStatus.draft)]),
        );
        await pumpList(tester, user: _user(canUpdateSalesOrders: false));

        expect(find.byIcon(Icons.edit_outlined), findsNothing);
      },
    );

    testWidgets('every row renders its status chip, total and balance', (
      tester,
    ) async {
      stubListSales(
        salesOrders,
        page: testSalesPage([
          testOpenSale(
            id: 5,
            status: SaleStatus.draft,
            customerName: 'Acme Corp',
            total: '116.00',
          ),
        ]),
      );
      await pumpList(tester);

      expect(find.text('Acme Corp'), findsOneWidget);
      expect(find.byKey(const Key('pos_sale_status_chip_draft')), findsOneWidget);
      // es-MX renders as "116,00 $" (comma decimal, trailing symbol) —
      // MoneyFormatters.currency's own format, not a literal "116.00".
      expect(find.textContaining('116,00'), findsWidgets);
    });

    testWidgets(
      'the Cliente column names the customer from the joined display name — '
      'the shape every ordinary row has',
      (tester) async {
        // `customer_name` is the per-document override, null on every
        // ordinary sale (mictlanix/mbe-api#172). mbe-api#173 joins the
        // customer's own name onto the summary instead, which is what this
        // column reads — and why nothing here resolves a customer per row.
        stubListSales(
          salesOrders,
          page: testSalesPage([
            testOpenSale(
              id: 7,
              customerName: null,
              customerDisplayName: 'FERRETERÍA LOS PINOS',
            ),
          ]),
        );
        await pumpList(tester);
        await tester.pumpAndSettle();

        expect(find.text('FERRETERÍA LOS PINOS'), findsOneWidget);
        expect(find.text('—'), findsNothing);
        verifyNever(() => customers.get(customerId: any(named: 'customerId')));
      },
    );

    testWidgets(
      'a sale carrying a name override shows that instead — the document '
      'deliberately names someone else',
      (tester) async {
        stubListSales(
          salesOrders,
          page: testSalesPage([
            testOpenSale(
              id: 8,
              customerName: 'OBRA LOS ENCINOS',
              customerDisplayName: 'FERRETERÍA LOS PINOS',
            ),
          ]),
        );
        await pumpList(tester);
        await tester.pumpAndSettle();

        expect(find.text('OBRA LOS ENCINOS'), findsOneWidget);
        expect(find.text('FERRETERÍA LOS PINOS'), findsNothing);
      },
    );

    testWidgets(
      'a row from an mbe-api older than #173 still falls back rather than '
      'breaking',
      (tester) async {
        stubListSales(
          salesOrders,
          page: testSalesPage([
            testOpenSale(id: 9, customerName: null, customerDisplayName: null),
          ]),
        );
        await pumpList(tester);
        await tester.pumpAndSettle();

        expect(find.text('—'), findsOneWidget);
      },
    );
  });

  group('PosSalesListScreen — date range default and empty states', () {
    testWidgets('defaults to today and shows the "no sales today" message '
        'when empty', (tester) async {
      stubListSales(salesOrders, page: testSalesPage(const []));
      await pumpList(tester);
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(const Locale('es', 'MX'));
      expect(find.text(l10n.posSalesEmptyToday), findsOneWidget);
      // The date-range/status facets moved into the shared filter drawer
      // (spec 027 US4) — no inline chip renders any more; the badged button
      // is what's visible in the filter row, with no badge count since
      // today's default range and "every status" are both inactive.
      expect(find.byKey(const Key('pos_sales_filter_button')), findsOneWidget);
      expect(find.text(l10n.dateRangeFilterToday), findsNothing);
      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isFalse);
    });

    testWidgets(
      'a date-range facet shows the shared generic filtered-empty message '
      'instead of the "no sales today" one',
      (tester) async {
        stubListSales(salesOrders, page: testSalesPage(const []));
        await pumpList(
          tester,
          query: const ListQuery(facets: {'date-from': ['2026-08-01']}),
        );
        await tester.pumpAndSettle();

        final l10n = await AppLocalizations.delegate.load(const Locale('es', 'MX'));
        // `emptyMessage` renders only in the plain-empty state
        // (list_state_views.dart) — a filtered result gets the shared
        // generic message every other catalog uses.
        expect(find.text(l10n.filteredEmptyTitle), findsOneWidget);
        expect(find.text(l10n.posSalesEmptyToday), findsNothing);
      },
    );
  });

  group('PosSalesListScreen — filter drawer (spec 027 US4/FR-025/FR-026)', () {
    testWidgets(
      'no inline facet chips — only the search box, primary action and one '
      'badged filters button',
      (tester) async {
        stubListSales(salesOrders, page: testSalesPage(const []));
        await pumpList(tester);
        await tester.pumpAndSettle();

        expect(find.byType(DateRangeFilterChip), findsNothing);
        expect(find.byKey(const Key('pos_sales_status_filter_chip')), findsNothing);
        expect(find.byKey(const Key('pos_sales_search_field')), findsOneWidget);
        expect(find.byKey(const Key('pos_sales_new_sale_button')), findsOneWidget);
        expect(find.byKey(const Key('pos_sales_filter_button')), findsOneWidget);
      },
    );

    testWidgets('the badge reflects an active status facet', (tester) async {
      stubListSales(salesOrders, page: testSalesPage(const []));
      await pumpList(
        tester,
        query: const ListQuery(facets: {'status': ['draft']}),
      );
      await tester.pumpAndSettle();

      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isTrue);
      expect((badge.label as Text?)?.data, '1');
    });

    testWidgets(
      'opening the drawer and choosing a status navigates to a URL carrying '
      'that facet',
      (tester) async {
        stubListSales(salesOrders, page: testSalesPage(const []));
        await pumpListRouted(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('pos_sales_filter_button')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('pos_sales_filter_status_draft')));
        await tester.pumpAndSettle();

        verify(
          () => salesOrders.listSales(
            pointSale: any(named: 'pointSale'),
            status: SaleStatus.draft,
            dateFrom: any(named: 'dateFrom'),
            dateTo: any(named: 'dateTo'),
            search: any(named: 'search'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).called(greaterThan(0));
      },
    );

    testWidgets(
      'clear-all from the drawer returns to today\'s range and no status — '
      'never an unbounded range',
      (tester) async {
        stubListSales(salesOrders, page: testSalesPage(const []));
        await pumpListRouted(
          tester,
          query: const ListQuery(
            facets: {
              'date-from': ['2026-08-01'],
              'date-to': ['2026-08-01'],
              'status': ['draft'],
            },
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('pos_sales_filter_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('filter_sheet_clear_all_button')));
        await tester.pumpAndSettle();

        final badge = tester.widget<Badge>(find.byType(Badge));
        expect(badge.isLabelVisible, isFalse);
      },
    );
  });

  group('PosSalesListScreen — no register configured', () {
    testWidgets('explains a register is needed and issues no query', (
      tester,
    ) async {
      await pumpList(tester, user: _user(pointSaleId: null));

      expect(find.byKey(const Key('pos_sales_no_register')), findsOneWidget);
      verifyNever(
        () => salesOrders.listSales(
          pointSale: any(named: 'pointSale'),
          status: any(named: 'status'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      );
    });
  });

  group('PosSalesListScreen — "Nueva venta" (contracts/pos-sales-list.md §7)', () {
    testWidgets('enabled with an open cash session', (tester) async {
      stubListSales(salesOrders, page: testSalesPage(const []));
      await pumpList(tester, sessionOpen: true);
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(
        find.byKey(const Key('pos_sales_new_sale_button')),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('disabled with no cash session', (tester) async {
      stubListSales(salesOrders, page: testSalesPage(const []));
      await pumpList(tester, sessionOpen: false);
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(
        find.byKey(const Key('pos_sales_new_sale_button')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('absent without the pos create privilege', (tester) async {
      stubListSales(salesOrders, page: testSalesPage(const []));
      await pumpList(tester, user: _user(canCreatePos: false));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pos_sales_new_sale_button')), findsNothing);
    });
  });
}
