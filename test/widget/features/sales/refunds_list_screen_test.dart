import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_refund_repository.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_link_providers.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refunds_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class _MockCustomerRepository extends Mock implements CustomerRepository {}

/// Spec 057 US2 (T034), contracts C4: the "Devoluciones" list — columns,
/// facets, states, the new-refund dialog and the compact tier.
void main() {
  late MockCustomerRefundRepository refunds;
  late MockSalesOrderRepository salesOrders;
  late _MockCustomerRepository customers;
  late AppLocalizations l10n;
  var requests = <({RefundStatus? status, int? customer, int? order})>[];

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    refunds = MockCustomerRefundRepository();
    salesOrders = MockSalesOrderRepository();
    customers = _MockCustomerRepository();
    requests = [];
  });

  CustomerRefundSummary row(
    int id, {
    RefundStatus status = RefundStatus.draft,
    int? customer = 7,
    int order = 42,
    int? serial,
    String total = '10.00',
  }) => CustomerRefundSummary(
    id: id,
    salesOrderId: order,
    customerId: customer,
    serial: serial,
    date: serial == null ? null : DateTime(2026, 10, 28, 9, 30),
    currency: Currency.mxn,
    status: status,
    total: total,
  );

  /// A fake server over [all] that honours the three facets and paging.
  void serve(List<CustomerRefundSummary> all) {
    when(
      () => refunds.list(
        status: any(named: 'status'),
        customerId: any(named: 'customerId'),
        salesOrderId: any(named: 'salesOrderId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((i) async {
      final status = i.namedArguments[#status] as RefundStatus?;
      final customer = i.namedArguments[#customerId] as int?;
      final order = i.namedArguments[#salesOrderId] as int?;
      final skip = i.namedArguments[#skip] as int;
      final limit = i.namedArguments[#limit] as int;
      requests.add((status: status, customer: customer, order: order));
      final kept = [
        for (final r in all)
          if ((status == null || r.status == status) &&
              (customer == null || r.customerId == customer) &&
              (order == null || r.salesOrderId == order))
            r,
      ];
      final end = (skip + limit).clamp(0, kept.length);
      return RefundListResult(
        items: skip >= kept.length ? const [] : kept.sublist(skip, end),
        total: kept.length,
      );
    });
  }

  Override access({bool create = true, bool read = true}) =>
      accessControlProvider.overrideWithValue(
        AccessControlService(
          AuthState.authenticated(
            token: 't',
            user: User(
              userId: 'r',
              email: 'r@example.com',
              administrator: false,
              status: EntityStatus.active,
              sessionVersion: 1,
              privileges: [
                Privilege(
                  systemObject: SystemObject.customerRefunds,
                  rawValue: (read ? 2 : 0) | (create ? 1 : 0),
                ),
              ],
            ),
          ),
        ),
      );

  Future<GoRouter> pumpList(
    WidgetTester tester, {
    Override? who,
    String location = '/sales/refunds',
    bool ordersOpenable = false,
    Size surface = const Size(1400, 1000),
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        who ?? access(),
        customerRefundOverride(refunds),
        salesOrderOverride(salesOrders),
        customerRepositoryProvider.overrideWithValue(customers),
        inputDebounceProvider.overrideWithValue(
          const Duration(milliseconds: 100),
        ),
        customerDisplayNameProvider.overrideWith(
          (ref, id) async => 'Cliente $id',
        ),
        orderLinkTargetProvider.overrideWith(
          (ref, id) async => ordersOpenable ? '/sales/orders/$id' : null,
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/sales/refunds',
          builder: (context, state) => Scaffold(
            body: RefundsListScreen(query: ListQuery.fromUri(state.uri)),
          ),
        ),
        GoRoute(
          path: '/sales/refunds/:id',
          builder: (_, s) =>
              Scaffold(body: Text('refund-${s.pathParameters['id']}')),
        ),
        GoRoute(
          path: '/sales/orders/:id',
          builder: (_, s) =>
              Scaffold(body: Text('order-${s.pathParameters['id']}')),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  Finder key(String k) => find.byKey(Key(k));

  Future<void> openFilters(WidgetTester tester) async {
    await tester.tap(key('refunds_filter_button'));
    await tester.pumpAndSettle();
  }

  group('the table', () {
    testWidgets('shows the six columns, and "—" for a draft\'s folio and '
        'date', (tester) async {
      serve([
        row(2, status: RefundStatus.completed, serial: 15, total: '1025.00'),
        row(1),
      ]);
      await pumpList(tester);

      for (final header in [
        l10n.refundsColumnNumber,
        l10n.refundsColumnDate,
        l10n.refundsColumnCustomer,
        l10n.refundsColumnOrder,
        l10n.refundsColumnStatus,
        l10n.refundsColumnTotal,
      ]) {
        expect(find.text(header), findsOneWidget, reason: header);
      }
      expect(find.text('15'), findsOneWidget);
      expect(find.text(emptyValuePlaceholder), findsNWidgets(2));
      expect(find.text('Cliente 7'), findsNWidgets(2));
      expect(find.text('#42'), findsNWidgets(2));
      expect(find.text('\$1,025.00'), findsOneWidget);
      expect(key('refund_status_chip_completed'), findsOneWidget);
      expect(key('refund_status_chip_draft'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a refund with no customer shows "—" in Cliente', (
      tester,
    ) async {
      serve([row(1, customer: null, serial: 3)]);
      await pumpList(tester);

      expect(find.textContaining('Cliente'), findsOneWidget); // the header
      expect(find.text(emptyValuePlaceholder), findsNWidgets(1));
    });

    testWidgets('has no search box and no row edit icon', (tester) async {
      serve([row(1)]);
      await pumpList(tester);

      expect(find.byType(CatalogSearchBar), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(key('refunds_table'), findsOneWidget);
    });

    testWidgets('the order is a link when the user can open it', (
      tester,
    ) async {
      serve([row(1)]);
      final router = await pumpList(tester, ordersOpenable: true);

      await tester.tap(key('refund_order_link_42'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/orders/42');
    });

    testWidgets('a row tap opens the refund', (tester) async {
      serve([row(5, total: '77.00')]);
      final router = await pumpList(tester);

      await tester.tap(find.text('\$77.00'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/refunds/5');
      expect(find.text('refund-5'), findsOneWidget);
    });
  });

  group('the facets', () {
    final data = [
      row(4, status: RefundStatus.completed, serial: 9, customer: 7),
      row(3, customer: 8, order: 50),
      row(2, customer: 7, order: 50),
      row(1, status: RefundStatus.cancelled, customer: 8, order: 60),
    ];

    testWidgets('the drawer offers status, customer and order', (tester) async {
      serve(data);
      await pumpList(tester);
      await openFilters(tester);

      expect(key('refunds_status_filter'), findsOneWidget);
      expect(key('refunds_customer_filter'), findsOneWidget);
      expect(key('refunds_order_filter'), findsOneWidget);
      expect(find.text(l10n.refundsFilterOpen), findsOneWidget);
    });

    testWidgets('status narrows the list, writes the address and resets the '
        'page', (tester) async {
      serve(data);
      final router = await pumpList(
        tester,
        location: '/sales/refunds?page=1&order=50',
      );
      await openFilters(tester);

      await tester.tap(find.text(l10n.refundsFilterOpen));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['status'], 'draft');
      expect(router.state.uri.queryParameters['order'], '50');
      expect(router.state.uri.queryParameters.containsKey('page'), isFalse);
      expect(requests.last.status, RefundStatus.draft);
      expect(key('refund_status_chip_draft'), findsNWidgets(2));
      expect(key('refund_status_chip_completed'), findsNothing);
    });

    testWidgets('customer narrows the list and resets the page', (
      tester,
    ) async {
      serve(data);
      when(
        () => customers.list(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const CustomerPage(
          items: [
            CustomerListItem(
              customerId: 8,
              code: 'C8',
              name: 'Beta',
              creditLimit: '0',
              creditDays: 0,
              priceList: PriceListRef(id: 1, name: 'General'),
              status: EntityStatus.active,
            ),
          ],
          total: 1,
        ),
      );
      final router = await pumpList(tester, location: '/sales/refunds?page=1');
      await openFilters(tester);

      await tester.enterText(
        find.descendant(
          of: key('refunds_customer_filter'),
          matching: find.byType(TextFormField),
        ),
        'Bet',
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      await tester.tap(find.text('C8 — Beta'));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['customer'], '8');
      expect(router.state.uri.queryParameters.containsKey('page'), isFalse);
      expect(requests.last.customer, 8);
      expect(find.text('Cliente 8'), findsWidgets);
    });

    testWidgets('the order number applies after the typing pause, not per '
        'digit, and on submit', (tester) async {
      serve(data);
      final router = await pumpList(tester);
      await openFilters(tester);
      final before = requests.length;

      await tester.enterText(key('refunds_order_filter'), '5');
      await tester.pump(const Duration(milliseconds: 40));
      await tester.enterText(key('refunds_order_filter'), '50');
      await tester.pump(const Duration(milliseconds: 40));

      expect(requests.length, before); // nothing sent while typing
      expect(router.state.uri.queryParameters.containsKey('order'), isFalse);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['order'], '50');
      expect(requests.length, before + 1);
      expect(requests.last.order, 50);
      expect(requests.every((r) => r.order != 5), isTrue);

      await tester.enterText(key('refunds_order_filter'), '60');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['order'], '60');
    });

    testWidgets('clearing the order number removes the facet', (tester) async {
      serve(data);
      final router = await pumpList(
        tester,
        location: '/sales/refunds?order=50',
      );
      await openFilters(tester);

      await tester.enterText(key('refunds_order_filter'), '');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters.containsKey('order'), isFalse);
    });

    testWidgets('the badge counts the active facets', (tester) async {
      serve(data);
      await pumpList(tester, location: '/sales/refunds?status=draft&order=50');

      expect(find.text('2'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('empty', (tester) async {
      serve(const []);
      await pumpList(tester);

      expect(find.text(l10n.refundsEmpty), findsOneWidget);
    });

    testWidgets('filtered-empty offers to clear the filters', (tester) async {
      serve(const []);
      final router = await pumpList(
        tester,
        location: '/sales/refunds?status=draft',
      );

      expect(find.text(l10n.refundsEmpty), findsNothing);
      expect(find.text(l10n.clearFiltersButton), findsOneWidget);

      await tester.tap(find.text(l10n.clearFiltersButton));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, isEmpty);
    });

    testWidgets('a failed load offers a retry that works', (tester) async {
      var calls = 0;
      when(
        () => refunds.list(
          status: any(named: 'status'),
          customerId: any(named: 'customerId'),
          salesOrderId: any(named: 'salesOrderId'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async {
        if (++calls == 1) throw const AppError.network();
        return RefundListResult(items: [row(1)], total: 1);
      });
      await pumpList(tester);

      expect(find.text(l10n.retryButton), findsOneWidget);

      await tester.tap(find.text(l10n.retryButton));
      await tester.pumpAndSettle();

      expect(key('refunds_table'), findsOneWidget);
    });

    testWidgets('a 403 says so, with nothing to retry', (tester) async {
      when(
        () => refunds.list(
          status: any(named: 'status'),
          customerId: any(named: 'customerId'),
          salesOrderId: any(named: 'salesOrderId'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const AppError.server(statusCode: 403));
      await pumpList(tester);

      expect(key('refunds_forbidden'), findsOneWidget);
      expect(find.text(l10n.retryButton), findsNothing);
    });
  });

  group('Nueva devolución', () {
    testWidgets('is hidden without create access', (tester) async {
      serve([row(1)]);
      await pumpList(tester, who: access(create: false));

      expect(key('refunds_new_button'), findsNothing);
    });

    Future<void> submitOrder(WidgetTester tester, String number) async {
      await tester.tap(key('refunds_new_button'));
      await tester.pumpAndSettle();
      expect(key('refund_new_dialog'), findsOneWidget);
      await tester.enterText(key('refund_new_order_input'), number);
      await tester.tap(key('refund_new_continue'));
      await tester.pumpAndSettle();
    }

    testWidgets('opens a refund for a paid order and goes to it', (
      tester,
    ) async {
      serve(const []);
      when(
        () => salesOrders.getById(saleId: 42),
      ).thenAnswer((_) async => testSale(status: SaleStatus.paid));
      when(() => refunds.open(42)).thenAnswer((_) async => testRefund(id: 9));
      final router = await pumpList(tester);

      await submitOrder(tester, '42');

      verify(() => refunds.open(42)).called(1);
      expect(router.state.uri.path, '/sales/refunds/9');
      expect(key('refund_new_dialog'), findsNothing);
    });

    testWidgets('resumes the order\'s draft instead of opening another', (
      tester,
    ) async {
      serve([row(77, order: 42)]);
      final router = await pumpList(tester);

      await submitOrder(tester, '42');

      verifyNever(() => refunds.open(any()));
      expect(router.state.uri.path, '/sales/refunds/77');
    });

    testWidgets('an order that does not exist is refused inline', (
      tester,
    ) async {
      serve(const []);
      when(
        () => salesOrders.getById(saleId: 99),
      ).thenThrow(const AppError.notFound());
      await pumpList(tester);

      await submitOrder(tester, '99');

      expect(key('refund_new_dialog'), findsOneWidget);
      expect(
        tester.widget<Text>(key('refund_new_refusal')).data,
        l10n.refundRefusalOrderNotFound(99),
      );
    });

    testWidgets('a draft order is refused as not confirmed', (tester) async {
      serve(const []);
      when(
        () => salesOrders.getById(saleId: 42),
      ).thenAnswer((_) async => testSale(status: SaleStatus.draft));
      await pumpList(tester);

      await submitOrder(tester, '42');

      expect(find.text(l10n.refundRefusalNotCompleted(42)), findsOneWidget);
      verifyNever(() => refunds.open(any()));
    });

    testWidgets('an unpaid order is refused as not paid', (tester) async {
      serve(const []);
      when(
        () => salesOrders.getById(saleId: 42),
      ).thenAnswer((_) async => testSale(status: SaleStatus.completed));
      await pumpList(tester);

      await submitOrder(tester, '42');

      expect(find.text(l10n.refundRefusalNotPaid(42)), findsOneWidget);
      verifyNever(() => refunds.open(any()));
    });

    testWidgets('an order with nothing to return shows the server\'s reason', (
      tester,
    ) async {
      serve(const []);
      when(
        () => salesOrders.getById(saleId: 42),
      ).thenAnswer((_) async => testSale(status: SaleStatus.paid));
      when(() => refunds.open(42)).thenThrow(
        const AppError.server(statusCode: 409, message: 'Already returned'),
      );
      await pumpList(tester);

      await submitOrder(tester, '42');

      expect(
        find.text('${l10n.refundRefusalNothingToReturn(42)} Already returned'),
        findsOneWidget,
      );
      expect(key('refund_new_dialog'), findsOneWidget);
    });

    testWidgets('a refusal is cleared by the next attempt', (tester) async {
      serve(const []);
      when(
        () => salesOrders.getById(saleId: 42),
      ).thenAnswer((_) async => testSale(status: SaleStatus.completed));
      when(
        () => salesOrders.getById(saleId: 43),
      ).thenAnswer((_) async => testSale(id: 43, status: SaleStatus.paid));
      when(() => refunds.open(43)).thenAnswer((_) async => testRefund(id: 12));
      final router = await pumpList(tester);

      await submitOrder(tester, '42');
      expect(key('refund_new_refusal'), findsOneWidget);

      await tester.enterText(key('refund_new_order_input'), '43');
      await tester.tap(key('refund_new_continue'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/refunds/12');
    });
  });

  group('compact', () {
    testWidgets('drops Fecha, Cliente and Estado; the order carries a status '
        'dot; the button says "Nueva"', (tester) async {
      serve([row(2, status: RefundStatus.completed, serial: 5), row(1)]);
      await pumpList(tester, surface: const Size(390, 844));

      expect(find.text(l10n.refundsColumnNumber), findsOneWidget);
      expect(find.text(l10n.refundsColumnOrder), findsOneWidget);
      expect(find.text(l10n.refundsColumnTotal), findsOneWidget);
      expect(find.text(l10n.refundsColumnDate), findsNothing);
      expect(find.text(l10n.refundsColumnCustomer), findsNothing);
      expect(find.text(l10n.refundsColumnStatus), findsNothing);
      expect(key('refund_status_chip_draft'), findsNothing);
      expect(key('refund_status_dot_draft'), findsOneWidget);
      expect(key('refund_status_dot_completed'), findsOneWidget);
      expect(find.text(l10n.refundsNewShort), findsOneWidget);
      expect(find.text(l10n.refundsNew), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
