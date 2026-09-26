import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sales_quote_summary.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

User _user({bool canCreate = true, bool canUpdate = true}) => User(
  userId: 'salesperson-1',
  email: 'salesperson@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(
      systemObject: SystemObject.salesQuotes,
      rawValue: (canCreate ? 1 : 0) | (canUpdate ? 4 : 0),
    ),
  ],
);

SalesQuoteSummary _quoteSummary({
  int id = 1,
  int? serial,
  int customer = 7,
  String? customerDisplayName = 'FERRETERÍA LOS PINOS',
  SaleStatus status = SaleStatus.draft,
  bool hasExpired = false,
  String total = '116.00',
}) => SalesQuoteSummary(
  id: id,
  serial: serial,
  customer: customer,
  customerDisplayName: customerDisplayName,
  salesperson: 100,
  date: DateTime(2026, 8, 5),
  dueDate: DateTime(2026, 8, 12),
  currency: Currency.mxn,
  status: status,
  hasExpired: hasExpired,
  total: total,
);

void stubListQuotes(
  MockSalesQuoteRepository repository, {
  required SalesQuotePage page,
}) {
  when(
    () => repository.listQuotes(
      mine: any(named: 'mine'),
      customer: any(named: 'customer'),
      salesperson: any(named: 'salesperson'),
      status: any(named: 'status'),
      search: any(named: 'search'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => page);
}

/// spec 040 FR-034…FR-039: the quotes list screen — column shape, the
/// expired marker's independence from the status chip, row-edit and create
/// gating, and the status/customer facets round-tripping through the URL.
/// Mirrors `sales_orders_list_screen_test.dart`'s own shape, simplified for
/// what this list actually offers (no date range, no admin-only facets —
/// data-model.md §4).
void main() {
  late MockSalesQuoteRepository salesQuotes;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesQuotes = MockSalesQuoteRepository();
  });

  Future<GoRouter> pumpListRouted(
    WidgetTester tester, {
    User? user,
    ListQuery query = const ListQuery(),
  }) async {
    final (router, _) = await pumpQuotesRouted(
      tester,
      initialLocation: query.toUri('/sales/quotes').toString(),
      overrides: [
        authNotifierProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: user ?? _user()),
          ),
        ),
        salesQuoteOverride(salesQuotes),
      ],
    );
    return router;
  }

  group('the default view (FR-034, FR-035)', () {
    testWidgets("shows the six columns and a row's data", (tester) async {
      stubListQuotes(
        salesQuotes,
        page: SalesQuotePage(
          items: [_quoteSummary(id: 501, serial: 4001)],
          total: 1,
        ),
      );

      await pumpListRouted(tester);
      await tester.pumpAndSettle();

      expect(find.text(l10n.salesQuotesColumnReference), findsOneWidget);
      expect(find.text(l10n.salesQuotesColumnCustomer), findsOneWidget);
      expect(find.text(l10n.salesQuotesColumnDate), findsOneWidget);
      expect(find.text(l10n.salesQuotesColumnExpiry), findsOneWidget);
      expect(find.text(l10n.salesQuotesColumnStatus), findsOneWidget);
      expect(find.text(l10n.salesQuotesColumnTotal), findsOneWidget);
      expect(find.text('4001'), findsOneWidget);
      expect(find.text('FERRETERÍA LOS PINOS'), findsOneWidget);
    });

    testWidgets(
      'a draft with no folio shows its provisional reference (the bare id)',
      (tester) async {
        stubListQuotes(
          salesQuotes,
          page: SalesQuotePage(
            items: [_quoteSummary(id: 501, serial: null)],
            total: 1,
          ),
        );

        await pumpListRouted(tester);
        await tester.pumpAndSettle();

        expect(find.text('501'), findsOneWidget);
      },
    );

    testWidgets(
      'hasExpired renders as a marker separate from the status chip — '
      'never folded into it (FR-024, FR-037)',
      (tester) async {
        stubListQuotes(
          salesQuotes,
          page: SalesQuotePage(
            items: [
              _quoteSummary(id: 1, status: SaleStatus.completed, hasExpired: true),
            ],
            total: 1,
          ),
        );

        await pumpListRouted(tester);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('sales_quote_status_chip_completed')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('sales_quote_expired_marker')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'no expired marker for a quote that has not expired',
      (tester) async {
        stubListQuotes(
          salesQuotes,
          page: SalesQuotePage(
            items: [_quoteSummary(id: 1, status: SaleStatus.draft)],
            total: 1,
          ),
        );

        await pumpListRouted(tester);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('sales_quote_expired_marker')),
          findsNothing,
        );
      },
    );

    testWidgets('New quote is absent without create rights', (tester) async {
      stubListQuotes(salesQuotes, page: const SalesQuotePage(items: [], total: 0));

      await pumpListRouted(tester, user: _user(canCreate: false));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sales_quotes_new_quote_button')), findsNothing);
    });

    testWidgets('New quote is present with create rights', (tester) async {
      stubListQuotes(salesQuotes, page: const SalesQuotePage(items: [], total: 0));

      await pumpListRouted(tester);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sales_quotes_new_quote_button')), findsOneWidget);
    });

    testWidgets('Edit row action is absent without update rights', (tester) async {
      stubListQuotes(
        salesQuotes,
        page: SalesQuotePage(items: [_quoteSummary(id: 1)], total: 1),
      );

      await pumpListRouted(tester, user: _user(canUpdate: false));
      await tester.pumpAndSettle();

      expect(find.byTooltip(l10n.editActionTooltip), findsNothing);
    });

    testWidgets(
      'Edit row action is absent for a confirmed quote — draft only',
      (tester) async {
        stubListQuotes(
          salesQuotes,
          page: SalesQuotePage(
            items: [_quoteSummary(id: 1, status: SaleStatus.completed)],
            total: 1,
          ),
        );

        await pumpListRouted(tester);
        await tester.pumpAndSettle();

        expect(find.byTooltip(l10n.editActionTooltip), findsNothing);
      },
    );

    testWidgets(
      'Edit row action is present for a draft quote and an updater',
      (tester) async {
        stubListQuotes(
          salesQuotes,
          page: SalesQuotePage(
            items: [_quoteSummary(id: 1, status: SaleStatus.draft)],
            total: 1,
          ),
        );

        await pumpListRouted(tester);
        await tester.pumpAndSettle();

        expect(find.byTooltip(l10n.editActionTooltip), findsOneWidget);
      },
    );
  });

  group('filters (FR-036)', () {
    testWidgets(
      'the status facet narrows the request and lands in the address, '
      'counted in the badge',
      (tester) async {
        stubListQuotes(salesQuotes, page: const SalesQuotePage(items: [], total: 0));

        final router = await pumpListRouted(tester);
        await tester.tap(find.byKey(const Key('sales_quotes_filter_button')));
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('sales_quotes_filter_status_draft')),
        );
        await tester.pumpAndSettle();

        expect(router.state.uri.queryParameters['status'], 'draft');
        verify(
          () => salesQuotes.listQuotes(
            mine: any(named: 'mine'),
            customer: any(named: 'customer'),
            salesperson: any(named: 'salesperson'),
            status: SaleStatus.draft,
            search: any(named: 'search'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).called(greaterThan(0));

        final badge = tester.widget<Badge>(
          find.ancestor(
            of: find.byKey(const Key('sales_quotes_filter_button')),
            matching: find.byType(Badge),
          ),
        );
        expect(badge.isLabelVisible, isTrue);
      },
    );

    testWidgets(
      'the customer facet narrows the request and lands in the address',
      (tester) async {
        stubListQuotes(salesQuotes, page: const SalesQuotePage(items: [], total: 0));

        final router = await pumpListRouted(tester);
        router.go(
          const ListQuery()
              .withFacet('customer', '7')
              .toUri('/sales/quotes')
              .toString(),
        );
        await tester.pumpAndSettle();

        verify(
          () => salesQuotes.listQuotes(
            mine: any(named: 'mine'),
            customer: 7,
            salesperson: any(named: 'salesperson'),
            status: any(named: 'status'),
            search: any(named: 'search'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).called(greaterThan(0));
      },
    );

    testWidgets(
      'clear-all drops both facets rather than leaving either behind',
      (tester) async {
        stubListQuotes(salesQuotes, page: const SalesQuotePage(items: [], total: 0));

        final router = await pumpListRouted(
          tester,
          query: const ListQuery(
            facets: {
              'status': ['draft'],
              'customer': ['7'],
            },
          ),
        );
        await tester.tap(find.byKey(const Key('sales_quotes_filter_button')));
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('filter_sheet_clear_all_button')),
        );
        await tester.pumpAndSettle();

        expect(router.state.uri.queryParameters.containsKey('status'), isFalse);
        expect(
          router.state.uri.queryParameters.containsKey('customer'),
          isFalse,
        );
      },
    );

    testWidgets(
      'a non-numeric search term narrows the list rather than being '
      'silently dropped (regression guard, mbe-api#213)',
      (tester) async {
        stubListQuotes(salesQuotes, page: const SalesQuotePage(items: [], total: 0));

        final router = await pumpListRouted(tester);
        await tester.enterText(
          find.byKey(const Key('sales_quotes_search_field')),
          'Acme',
        );
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        expect(router.state.uri.queryParameters['search'], 'Acme');
        verify(
          () => salesQuotes.listQuotes(
            mine: any(named: 'mine'),
            customer: any(named: 'customer'),
            salesperson: any(named: 'salesperson'),
            status: any(named: 'status'),
            search: 'Acme',
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).called(greaterThan(0));
      },
    );
  });
}
