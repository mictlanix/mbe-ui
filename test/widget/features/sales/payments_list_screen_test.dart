import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/presentation/document_preview_dialog.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_payment_repository.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/core/documents/document_fakes.dart';

class MockCustomerPaymentRepository extends Mock
    implements CustomerPaymentRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockPaymentMethodOptionRepository extends Mock
    implements PaymentMethodOptionRepository {}

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

/// A user who can read Customer Payments (8), optionally POS (44), with a
/// facility unless [facilityId] is `null`.
User paymentsUser({
  bool pos = false,
  bool editor = false,
  bool customerPaymentsRead = true,
  int? facilityId = 9,
}) => User(
  userId: 'cashier-1',
  email: 'cashier@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  settings: facilityId == null ? null : UserSettings(facilityId: facilityId),
  privileges: [
    if (customerPaymentsRead)
      const Privilege(systemObject: SystemObject.customerPayments, rawValue: 2),
    if (pos) const Privilege(systemObject: SystemObject.pos, rawValue: 2),
    if (editor)
      const Privilege(systemObject: SystemObject.paymentsEditor, rawValue: 2),
  ],
);

CustomerPayment testPayment({
  int id = 501,
  int customerId = 7,
  String? customerName,
  String amount = '1250.00',
  Currency currency = Currency.mxn,
  int methodCode = 1,
  int? paymentOptionId,
  String? reference,
  PaymentType type = PaymentType.immediate,
  int? verifierId,
  String unapplied = '0.00',
}) => CustomerPayment(
  customerPaymentId: id,
  customerId: customerId,
  customerName: customerName,
  amount: amount,
  currency: currency,
  methodCode: methodCode,
  paymentOptionId: paymentOptionId,
  reference: reference,
  date: DateTime(2026, 8, 5, 9, 30),
  facilityId: 9,
  type: type,
  verifierId: verifierId,
  unapplied: unapplied,
);

void stubSearch(
  MockCustomerPaymentRepository repository,
  List<CustomerPayment> items, {
  int? total,
}) =>
    when(
      () => repository.searchAcrossFacilities(
        customerId: any(named: 'customerId'),
        reference: any(named: 'reference'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async =>
          CustomerPaymentListResult(items: items, total: total ?? items.length),
    );

void stubPayments(
  MockCustomerPaymentRepository repository,
  List<CustomerPayment> items, {
  int? total,
}) =>
    when(
      () => repository.list(
        facilityId: any(named: 'facilityId'),
        customerId: any(named: 'customerId'),
        cashSessionId: any(named: 'cashSessionId'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        methodCode: any(named: 'methodCode'),
        verified: any(named: 'verified'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async =>
          CustomerPaymentListResult(items: items, total: total ?? items.length),
    );

Customer testCustomer(int id, String name) => Customer(
  customerId: id,
  code: 'C-$id',
  name: name,
  creditLimit: '0',
  creditDays: 0,
  priceList: const PriceListRef(id: 1, name: 'General'),
  status: EntityStatus.active,
);

/// The repositories a Pagos screen reads, plus the routed harness around it.
class PaymentsMocks {
  final payments = MockCustomerPaymentRepository();
  final customers = MockCustomerRepository();
  final options = MockPaymentMethodOptionRepository();
  final cashSessions = MockCashSessionRepository();

  PaymentsMocks() {
    // Unstubbed lookups (an unknown customer or option) fail, which is the
    // "name unavailable" path the screen must tolerate.
    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((i) async => testCustomer(7, 'Aceros del Bajío'));
    when(
      () => options.get(
        paymentMethodOptionId: any(named: 'paymentMethodOptionId'),
      ),
    ).thenThrow(const AppError.notFound());
    when(
      () => customers.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        priceList: any(named: 'priceList'),
        salesperson: any(named: 'salesperson'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const CustomerPage(items: [], total: 0));
  }
}

/// Pumps the real Pagos screen under a `GoRouter` with a stub detail route,
/// on a wide surface (desktop/web first, constitution §VI).
Future<(GoRouter, ProviderContainer)> pumpPayments(
  WidgetTester tester,
  PaymentsMocks mocks, {
  User? user,
  String initialLocation = '/sales/payments',
  List<Override> extraOverrides = const [],
}) async {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      authProvider.overrideWith(
        () => _FixedAuthNotifier(
          AuthState.authenticated(token: 't', user: user ?? paymentsUser()),
        ),
      ),
      customerPaymentRepositoryProvider.overrideWithValue(mocks.payments),
      customerRepositoryProvider.overrideWithValue(mocks.customers),
      paymentMethodOptionRepositoryProvider.overrideWithValue(mocks.options),
      cashSessionRepositoryProvider.overrideWithValue(mocks.cashSessions),
      facilityDisplayNameProvider.overrideWith(
        (ref, id) async => 'Sucursal $id',
      ),
      ...extraOverrides,
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/sales/payments',
        builder: (context, state) => Scaffold(
          body: PaymentsListScreen(query: ListQuery.fromUri(state.uri)),
        ),
      ),
      GoRoute(
        path: '/sales/payments/:paymentId',
        builder: (context, state) => Scaffold(
          body: Text('payment-${state.pathParameters['paymentId']}'),
        ),
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
  return (router, container);
}

/// A full page: a table that claims more rows than it holds never settles.
List<CustomerPayment> _fullPage() => [
  for (var i = 1; i <= 20; i++) testPayment(id: i),
];

/// Spec 054 US1, FR-005, FR-008, FR-018: the Pagos list screen.
void main() {
  late PaymentsMocks mocks;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    mocks = PaymentsMocks();
  });

  group('rows', () {
    testWidgets('show every column for a payment', (tester) async {
      when(() => mocks.options.get(paymentMethodOptionId: 3)).thenAnswer(
        (_) async => const PaymentMethodOption(
          paymentMethodOptionId: 3,
          facilityId: 9,
          facilityName: 'Main Store',
          name: '3 MSI',
          numberOfPayments: 3,
          displayOnTicket: true,
          paymentMethod: 4,
          status: EntityStatus.active,
        ),
      );
      stubPayments(mocks.payments, [
        testPayment(
          methodCode: PaymentMethod.creditCard.code,
          paymentOptionId: 3,
          reference: 'REF-99',
          type: PaymentType.creditPayment,
          verifierId: 5,
          unapplied: '250.00',
        ),
      ]);

      await pumpPayments(tester, mocks);

      for (final header in [
        l10n.paymentsColumnFolio,
        l10n.paymentsColumnDate,
        l10n.paymentsColumnCustomer,
        l10n.paymentsColumnAmount,
        l10n.paymentsColumnMethod,
        l10n.paymentsColumnReference,
        l10n.paymentsColumnType,
        l10n.paymentsColumnUnapplied,
        l10n.paymentsColumnVerified,
      ]) {
        expect(find.text(header), findsWidgets, reason: header);
      }
      expect(find.text('501'), findsOneWidget);
      expect(find.text('2026-08-05 09:30'), findsOneWidget);
      expect(find.text('Aceros del Bajío'), findsOneWidget);
      expect(find.text(r'$1,250.00 MXN'), findsOneWidget);
      expect(
        find.text(
          '${paymentMethodLabel(l10n, PaymentMethod.creditCard.code)} · 3 MSI',
        ),
        findsOneWidget,
      );
      expect(find.text('REF-99'), findsOneWidget);
      expect(find.text(l10n.paymentTypeCreditPayment), findsOneWidget);
      expect(find.text(r'$250.00 MXN'), findsOneWidget);
      expect(find.byKey(const Key('payment_icon_verified')), findsOneWidget);
    });

    testWidgets('an unverified payment shows the greyed unverified icon', (
      tester,
    ) async {
      stubPayments(mocks.payments, [testPayment(verifierId: null)]);

      await pumpPayments(tester, mocks);

      expect(find.byKey(const Key('payment_icon_unverified')), findsOneWidget);
      expect(find.byKey(const Key('payment_icon_verified')), findsNothing);
      // The label is still there for a pointer and a screen reader.
      expect(find.byTooltip(l10n.paymentUnverified), findsOneWidget);
    });

    testWidgets('a payment with no reference shows the empty placeholder', (
      tester,
    ) async {
      stubPayments(mocks.payments, [testPayment(reference: null)]);

      await pumpPayments(tester, mocks);

      // The shared formatter's null placeholder, not a blank cell.
      expect(find.text('—'), findsWidgets);
    });

    testWidgets('a foreign-currency amount shows its ISO code', (tester) async {
      stubPayments(mocks.payments, [
        testPayment(
          amount: '80.00',
          currency: Currency.usd,
          unapplied: '80.00',
        ),
      ]);

      await pumpPayments(tester, mocks);

      expect(find.textContaining('USD'), findsWidgets);
      expect(find.textContaining('MXN'), findsNothing);
    });

    testWidgets('a peso amount shows MXN', (tester) async {
      stubPayments(mocks.payments, [testPayment()]);

      await pumpPayments(tester, mocks);

      expect(find.textContaining('MXN'), findsWidgets);
    });
  });

  group('customer name (FR-018)', () {
    testWidgets('shows a placeholder while loading, then the name', (
      tester,
    ) async {
      final completer = Completer<Customer>();
      when(
        () => mocks.customers.get(customerId: 7),
      ).thenAnswer((_) => completer.future);
      stubPayments(mocks.payments, [testPayment()]);

      await pumpPayments(tester, mocks);
      // `pumpAndSettle` returns with the lookup still pending.
      expect(find.text('…'), findsOneWidget);
      expect(find.text('Aceros del Bajío'), findsNothing);

      completer.complete(testCustomer(7, 'Aceros del Bajío'));
      await tester.pumpAndSettle();

      expect(find.text('…'), findsNothing);
      expect(find.text('Aceros del Bajío'), findsOneWidget);
    });

    testWidgets('falls back to #<id> when the lookup fails, keeping the row', (
      tester,
    ) async {
      when(
        () => mocks.customers.get(customerId: 7),
      ).thenThrow(const AppError.notFound());
      stubPayments(mocks.payments, [testPayment()]);

      await pumpPayments(tester, mocks);

      expect(find.text('#7'), findsOneWidget);
      expect(find.text('501'), findsOneWidget);
    });

    testWidgets('looks each distinct customer up once', (tester) async {
      stubPayments(mocks.payments, [
        testPayment(id: 1),
        testPayment(id: 2),
        testPayment(id: 3),
      ]);

      await pumpPayments(tester, mocks);

      verify(() => mocks.customers.get(customerId: 7)).called(1);
    });
  });

  group('states', () {
    testWidgets('empty without filters shows the empty message and no clear '
        'button', (tester) async {
      stubPayments(mocks.payments, const []);

      await pumpPayments(tester, mocks);

      expect(find.text(l10n.paymentsListEmpty), findsOneWidget);
      expect(find.text(l10n.clearFiltersButton), findsNothing);
    });

    testWidgets('empty with filters shows the filtered-empty view, and its '
        'clear button returns to the bare address', (tester) async {
      stubPayments(mocks.payments, const []);

      final (router, _) = await pumpPayments(
        tester,
        mocks,
        initialLocation: '/sales/payments?verified=true&customer=7',
      );

      expect(find.text(l10n.paymentsListEmpty), findsNothing);
      expect(find.text(l10n.clearFiltersButton), findsOneWidget);

      await tester.tap(find.text(l10n.clearFiltersButton));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, isEmpty);
      expect(find.text(l10n.paymentsListEmpty), findsOneWidget);
    });

    testWidgets('an error shows retry, keeps the filters in the address, and '
        'retry refetches with them', (tester) async {
      when(
        () => mocks.payments.list(
          facilityId: any(named: 'facilityId'),
          customerId: any(named: 'customerId'),
          cashSessionId: any(named: 'cashSessionId'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          methodCode: any(named: 'methodCode'),
          verified: any(named: 'verified'),
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const AppError.server());

      final (router, _) = await pumpPayments(
        tester,
        mocks,
        initialLocation: '/sales/payments?verified=false',
      );

      expect(find.text(l10n.retryButton), findsOneWidget);
      expect(router.state.uri.queryParameters['verified'], 'false');

      stubPayments(mocks.payments, [testPayment()]);
      await tester.tap(find.text(l10n.retryButton));
      await tester.pumpAndSettle();

      expect(find.text('501'), findsOneWidget);
      expect(find.text(l10n.retryButton), findsNothing);
      verify(
        () => mocks.payments.list(
          facilityId: 9,
          customerId: null,
          cashSessionId: null,
          dateFrom: null,
          dateTo: null,
          methodCode: null,
          verified: false,
          search: null,
          skip: 0,
          limit: 20,
        ),
      ).called(greaterThan(1));
    });
  });

  group('interaction', () {
    testWidgets('tapping a row navigates to the payment\'s own route', (
      tester,
    ) async {
      stubPayments(mocks.payments, [testPayment(id: 501)]);

      final (router, _) = await pumpPayments(tester, mocks);
      await tester.tap(find.text('501'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/payments/501');
      expect(find.text('payment-501'), findsOneWidget);
    });

    testWidgets('has a customer search box and no Edit, delete or overflow '
        'icons', (tester) async {
      stubPayments(mocks.payments, [testPayment()]);

      await pumpPayments(tester, mocks);

      // spec 055 FR-009: the facility scope searches by customer name.
      expect(find.byType(CatalogSearchBar), findsOneWidget);
      expect(find.text(l10n.paymentsSearchCustomerHint), findsOneWidget);
      expect(find.byKey(const Key('payments_filter_button')), findsOneWidget);
      // An immediate payment has no ticket, so its row has no icon at all.
      expect(find.byIcon(Icons.receipt_long_outlined), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.byIcon(Icons.more_vert), findsNothing);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    });

    testWidgets('the request always carries the user\'s facility', (
      tester,
    ) async {
      stubPayments(mocks.payments, [testPayment()]);

      await pumpPayments(
        tester,
        mocks,
        user: paymentsUser(facilityId: 4),
        initialLocation: '/sales/payments?facility=99',
      );

      verify(
        () => mocks.payments.list(
          facilityId: 4,
          customerId: null,
          cashSessionId: null,
          dateFrom: null,
          dateTo: null,
          methodCode: null,
          verified: null,
          search: null,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    });
  });

  group('scope switch and all-facilities mode (US3)', () {
    testWidgets('the switch exists only with Payments Editor read', (
      tester,
    ) async {
      stubPayments(mocks.payments, [testPayment()]);
      await pumpPayments(tester, mocks, user: paymentsUser(editor: true));
      expect(find.byKey(const Key('payments_scope_switch')), findsOneWidget);
      expect(find.text(l10n.paymentsScopeFacility), findsOneWidget);
      expect(find.text(l10n.paymentsScopeAll), findsOneWidget);
    });

    testWidgets('a user without it has no switch', (tester) async {
      stubPayments(mocks.payments, [testPayment()]);
      await pumpPayments(tester, mocks);
      expect(find.byKey(const Key('payments_scope_switch')), findsNothing);
    });

    testWidgets('a user without it opening ?scope=all sees the own-facility '
        'list with no switch, and the search text is a customer search', (
      tester,
    ) async {
      stubPayments(mocks.payments, [testPayment()]);

      await pumpPayments(
        tester,
        mocks,
        initialLocation: '/sales/payments?scope=all&search=REF',
      );

      expect(find.byKey(const Key('payments_scope_switch')), findsNothing);
      expect(find.byKey(const Key('payments_search_field')), findsOneWidget);
      expect(find.text(l10n.paymentsSearchCustomerHint), findsOneWidget);
      expect(find.text('501'), findsOneWidget);
      expect(find.text(l10n.paymentsColumnFacility), findsNothing);
      verify(
        () => mocks.payments.list(
          facilityId: 9,
          customerId: null,
          cashSessionId: null,
          dateFrom: null,
          dateTo: null,
          methodCode: null,
          verified: null,
          search: 'REF',
          skip: 0,
          limit: 20,
        ),
      ).called(1);
      verifyNever(
        () => mocks.payments.searchAcrossFacilities(
          customerId: any(named: 'customerId'),
          reference: any(named: 'reference'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      );
    });

    testWidgets('the facility scope has the customer search box and no '
        'Sucursal column for an editor either', (tester) async {
      stubPayments(mocks.payments, [testPayment()]);
      await pumpPayments(tester, mocks, user: paymentsUser(editor: true));
      expect(find.byKey(const Key('payments_search_field')), findsOneWidget);
      expect(find.text(l10n.paymentsSearchCustomerHint), findsOneWidget);
      expect(find.text(l10n.paymentsColumnFacility), findsNothing);
    });

    testWidgets('all mode shows the search box, the Sucursal column and the '
        'facility name per row, from the cross-facility search', (
      tester,
    ) async {
      stubSearch(mocks.payments, [
        testPayment(id: 1),
        testPayment(id: 2).copyWith(facilityId: 4),
      ]);

      await pumpPayments(
        tester,
        mocks,
        user: paymentsUser(editor: true),
        initialLocation: '/sales/payments?scope=all',
      );

      expect(find.byKey(const Key('payments_search_field')), findsOneWidget);
      expect(find.text(l10n.paymentsColumnFacility), findsOneWidget);
      expect(find.text('Sucursal 9'), findsOneWidget);
      expect(find.text('Sucursal 4'), findsOneWidget);
      // (The controller never calling `list` for an editor in this scope is
      // asserted in the controller unit tests; the first frame here renders
      // before the auth state resolves, so it can't be asserted at this
      // level.)
      verify(
        () => mocks.payments.searchAcrossFacilities(
          customerId: null,
          reference: null,
          dateFrom: null,
          dateTo: null,
          skip: 0,
          limit: 20,
        ),
      ).called(greaterThan(0));
    });

    testWidgets('switching scope navigates via paymentsQueryForScope: keeps '
        'customer and dates, clears facility-only facets and the page', (
      tester,
    ) async {
      stubPayments(mocks.payments, _fullPage(), total: 100);
      stubSearch(mocks.payments, [testPayment()]);

      final (router, _) = await pumpPayments(
        tester,
        mocks,
        user: paymentsUser(editor: true),
        initialLocation:
            '/sales/payments?page=3&customer=7&date-from=2026-08-01'
            '&date-to=2026-08-05&verified=true&method=1&cash-session=5',
      );

      await tester.tap(find.text(l10n.paymentsScopeAll));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, {
        'scope': 'all',
        'customer': '7',
        'date-from': '2026-08-01',
        'date-to': '2026-08-05',
      });

      await tester.tap(find.text(l10n.paymentsScopeFacility));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, {
        'customer': '7',
        'date-from': '2026-08-01',
        'date-to': '2026-08-05',
      });
    });

    testWidgets('submitting a reference writes `search` and returns to page '
        '1', (tester) async {
      stubSearch(mocks.payments, _fullPage(), total: 100);

      final (router, _) = await pumpPayments(
        tester,
        mocks,
        user: paymentsUser(editor: true),
        initialLocation: '/sales/payments?scope=all&page=3',
      );

      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('payments_search_field')),
          matching: find.byType(TextField),
        ),
        'REF-9',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['search'], 'REF-9');
      expect(router.state.uri.queryParameters['scope'], 'all');
      expect(router.state.uri.queryParameters.containsKey('page'), isFalse);
      verify(
        () => mocks.payments.searchAcrossFacilities(
          customerId: null,
          reference: 'REF-9',
          dateFrom: null,
          dateTo: null,
          skip: 0,
          limit: 20,
        ),
      ).called(greaterThan(0));
    });

    testWidgets('opening a result then Back returns to the same scope, '
        'search and page (quickstart step 7)', (tester) async {
      stubSearch(mocks.payments, [
        for (var i = 1; i <= 20; i++) testPayment(id: i),
      ], total: 100);
      const location = '/sales/payments?scope=all&search=REF&page=3';

      final (router, _) = await pumpPayments(
        tester,
        mocks,
        user: paymentsUser(editor: true),
        initialLocation: location,
      );
      await tester.tap(find.text('7'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/sales/payments/7');

      router.pop();
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), location);
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: find.byKey(const Key('payments_search_field')),
                matching: find.byType(TextField),
              ),
            )
            .controller
            ?.text,
        'REF',
      );
      verify(
        () => mocks.payments.searchAcrossFacilities(
          customerId: null,
          reference: 'REF',
          dateFrom: null,
          dateTo: null,
          skip: 40,
          limit: 20,
        ),
      ).called(greaterThan(0));
    });

    testWidgets('the empty state in all scope without a search is the plain '
        'empty message', (tester) async {
      stubSearch(mocks.payments, const []);
      await pumpPayments(
        tester,
        mocks,
        user: paymentsUser(editor: true),
        initialLocation: '/sales/payments?scope=all',
      );
      expect(find.text(l10n.paymentsListEmpty), findsOneWidget);
      expect(find.text(l10n.clearFiltersButton), findsNothing);
    });

    testWidgets('a search with no results shows the filtered-empty view, and '
        'clearing keeps scope=all', (tester) async {
      stubSearch(mocks.payments, const []);
      final (router, _) = await pumpPayments(
        tester,
        mocks,
        user: paymentsUser(editor: true),
        initialLocation: '/sales/payments?scope=all&search=zzz&customer=7',
      );
      expect(find.text(l10n.paymentsListEmpty), findsNothing);
      expect(find.text(l10n.clearFiltersButton), findsOneWidget);

      await tester.tap(find.text(l10n.clearFiltersButton));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, {'scope': 'all'});
      expect(find.byKey(const Key('payments_search_field')), findsOneWidget);
    });
  });
  group('ticket (spec 055 FR-002, FR-003, FR-005)', () {
    late FakeDocumentSource source;
    late FakeDocumentOutput output;

    setUp(() {
      source = FakeDocumentSource();
      output = FakeDocumentOutput();
    });

    List<Override> documents() => [
      documentSourceProvider.overrideWithValue(source),
      documentOutputProvider.overrideWithValue(output),
    ];

    List<CustomerPayment> onePerType() => [
      testPayment(id: 501, type: PaymentType.immediate),
      testPayment(id: 502, type: PaymentType.creditPayment),
      testPayment(id: 503, type: PaymentType.paymentInAdvance),
      testPayment(id: 504, type: PaymentType.creditNote),
      testPayment(id: 505, type: PaymentType.expense),
      testPayment(id: 506, type: PaymentType.na),
    ];

    testWidgets('only a credit payment and an advance offer the ticket', (
      tester,
    ) async {
      stubPayments(mocks.payments, onePerType());
      await pumpPayments(tester, mocks, extraOverrides: documents());

      expect(find.byKey(const Key('payment_view_ticket_502')), findsOneWidget);
      expect(find.byKey(const Key('payment_view_ticket_503')), findsOneWidget);
      for (final id in [501, 504, 505, 506]) {
        expect(find.byKey(Key('payment_view_ticket_$id')), findsNothing);
      }
    });

    testWidgets('a user without Customer Payments read is not offered it', (
      tester,
    ) async {
      stubPayments(mocks.payments, onePerType());
      await pumpPayments(
        tester,
        mocks,
        user: paymentsUser(customerPaymentsRead: false),
        extraOverrides: documents(),
      );

      expect(find.byKey(const Key('payment_view_ticket_502')), findsNothing);
    });

    testWidgets('the icon opens the ticket preview and does not open the '
        'payment', (tester) async {
      stubPayments(mocks.payments, onePerType());
      final (router, _) = await pumpPayments(
        tester,
        mocks,
        extraOverrides: documents(),
      );

      await tester.tap(find.byKey(const Key('payment_view_ticket_502')));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
      expect(source.fetched, hasLength(1));
      expect(source.fetched.single.kind, DocumentKind.customerPaymentTicket);
      expect(source.fetched.single.recordId, 502);
      expect(source.fetched.single.title, 'Ticket de pago · #502');
      expect(router.state.uri.path, '/sales/payments');
    });

    testWidgets('the row itself still opens the payment', (tester) async {
      stubPayments(mocks.payments, onePerType());
      await pumpPayments(tester, mocks, extraOverrides: documents());

      await tester.tap(find.text('502'));
      await tester.pumpAndSettle();

      expect(find.text('payment-502'), findsOneWidget);
      expect(source.fetched, isEmpty);
    });

    testWidgets('the all-facilities scope offers it too', (tester) async {
      stubSearch(mocks.payments, onePerType());
      await pumpPayments(
        tester,
        mocks,
        user: paymentsUser(editor: true),
        initialLocation: '/sales/payments?scope=all',
        extraOverrides: documents(),
      );

      expect(find.byKey(const Key('payment_view_ticket_502')), findsOneWidget);
      expect(find.byKey(const Key('payment_view_ticket_501')), findsNothing);
    });
  });
  group('customer name and search (spec 055 US2)', () {
    Finder searchTextField() => find.descendant(
      of: find.byKey(const Key('payments_search_field')),
      matching: find.byType(TextField),
    );

    testWidgets('a name that arrives with the payment is shown at once, with '
        'no customer lookup (FR-007)', (tester) async {
      stubPayments(mocks.payments, [
        testPayment(id: 601, customerId: 7, customerName: 'Ana López'),
        testPayment(id: 602, customerId: 8, customerName: 'Luis Reyes'),
      ]);

      await pumpPayments(tester, mocks);

      expect(find.text('Ana López'), findsOneWidget);
      expect(find.text('Luis Reyes'), findsOneWidget);
      expect(find.text('…'), findsNothing);
      verifyNever(
        () => mocks.customers.get(customerId: any(named: 'customerId')),
      );
    });

    testWidgets('a payment with no name falls back to the lookup (FR-008)', (
      tester,
    ) async {
      stubPayments(mocks.payments, [
        testPayment(id: 601, customerId: 7, customerName: 'Ana López'),
        testPayment(id: 602, customerId: 7),
      ]);

      await pumpPayments(tester, mocks);

      expect(find.text('Ana López'), findsOneWidget);
      expect(find.text('Aceros del Bajío'), findsOneWidget);
      verify(() => mocks.customers.get(customerId: 7)).called(1);
    });

    testWidgets('submitting text writes `search`, returns to page 1 and '
        'queries the facility by customer name (FR-009, FR-013)', (
      tester,
    ) async {
      stubPayments(mocks.payments, _fullPage(), total: 100);

      final (router, _) = await pumpPayments(
        tester,
        mocks,
        initialLocation: '/sales/payments?page=3&customer=7',
      );

      await tester.enterText(searchTextField(), 'lópez');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['search'], 'lópez');
      expect(router.state.uri.queryParameters['customer'], '7');
      expect(router.state.uri.queryParameters.containsKey('page'), isFalse);
      verify(
        () => mocks.payments.list(
          facilityId: 9,
          customerId: 7,
          cashSessionId: null,
          dateFrom: null,
          dateTo: null,
          methodCode: null,
          verified: null,
          search: 'lópez',
          skip: 0,
          limit: 20,
        ),
      ).called(greaterThan(0));
      verifyNever(
        () => mocks.payments.searchAcrossFacilities(
          customerId: any(named: 'customerId'),
          reference: any(named: 'reference'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      );
    });

    testWidgets('the box shows the search text from the address', (
      tester,
    ) async {
      stubPayments(mocks.payments, [testPayment()]);

      await pumpPayments(
        tester,
        mocks,
        initialLocation: '/sales/payments?search=ana',
      );

      expect(
        tester.widget<TextField>(searchTextField()).controller?.text,
        'ana',
      );
    });

    testWidgets('a search with no results shows the filtered-empty view, and '
        'clearing removes the text', (tester) async {
      stubPayments(mocks.payments, const []);

      final (router, _) = await pumpPayments(
        tester,
        mocks,
        initialLocation: '/sales/payments?search=zzz',
      );
      expect(find.text(l10n.paymentsListEmpty), findsNothing);
      expect(find.text(l10n.clearFiltersButton), findsOneWidget);

      await tester.tap(find.text(l10n.clearFiltersButton));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, isEmpty);
      expect(
        tester.widget<TextField>(searchTextField()).controller?.text,
        isEmpty,
      );
    });

    testWidgets('the hint names what each scope searches (FR-011)', (
      tester,
    ) async {
      stubPayments(mocks.payments, [testPayment()]);
      stubSearch(mocks.payments, [testPayment()]);

      await pumpPayments(tester, mocks, user: paymentsUser(editor: true));
      expect(find.text(l10n.paymentsSearchCustomerHint), findsOneWidget);
      expect(find.text(l10n.paymentsSearchReferenceHint), findsNothing);

      await tester.tap(find.text(l10n.paymentsScopeAll));
      await tester.pumpAndSettle();

      expect(find.text(l10n.paymentsSearchReferenceHint), findsOneWidget);
      expect(find.text(l10n.paymentsSearchCustomerHint), findsNothing);
    });

    testWidgets('switching scope clears the search text, in both directions '
        '(FR-012)', (tester) async {
      stubPayments(mocks.payments, [testPayment()]);
      stubSearch(mocks.payments, [testPayment()]);

      final (router, _) = await pumpPayments(
        tester,
        mocks,
        user: paymentsUser(editor: true),
        initialLocation: '/sales/payments?search=ana',
      );
      expect(
        tester.widget<TextField>(searchTextField()).controller?.text,
        'ana',
      );

      await tester.tap(find.text(l10n.paymentsScopeAll));
      await tester.pumpAndSettle();
      expect(router.state.uri.queryParameters, {'scope': 'all'});
      expect(
        tester.widget<TextField>(searchTextField()).controller?.text,
        isEmpty,
      );

      await tester.enterText(searchTextField(), 'REF-1');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(router.state.uri.queryParameters['search'], 'REF-1');

      await tester.tap(find.text(l10n.paymentsScopeFacility));
      await tester.pumpAndSettle();
      expect(router.state.uri.queryParameters, isEmpty);
      expect(
        tester.widget<TextField>(searchTextField()).controller?.text,
        isEmpty,
      );
    });
  });
  group('a refused list (spec 055 FR-016)', () {
    void stubFailure(AppError error) => when(
      () => mocks.payments.list(
        facilityId: any(named: 'facilityId'),
        customerId: any(named: 'customerId'),
        cashSessionId: any(named: 'cashSessionId'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        methodCode: any(named: 'methodCode'),
        verified: any(named: 'verified'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(error);

    testWidgets('a 403 says the user isn\'t allowed, with nothing to retry', (
      tester,
    ) async {
      stubFailure(
        const AppError.server(
          statusCode: 403,
          message: 'Another facility\'s payments require PaymentsEditor read',
        ),
      );

      await pumpPayments(tester, mocks);

      expect(find.byKey(const Key('payments_list_forbidden')), findsOneWidget);
      expect(find.text(l10n.paymentsListForbidden), findsOneWidget);
      expect(find.byKey(const Key('list_state_retry_button')), findsNothing);
      expect(find.byKey(const Key('list_state_failed')), findsNothing);
      // The filter row stays, so the user can change what they asked for.
      expect(find.byKey(const Key('payments_filter_button')), findsOneWidget);
    });

    testWidgets('any other failure still offers a retry', (tester) async {
      stubFailure(const AppError.server(statusCode: 500));

      await pumpPayments(tester, mocks);

      expect(find.byKey(const Key('list_state_failed')), findsOneWidget);
      expect(find.byKey(const Key('list_state_retry_button')), findsOneWidget);
      expect(find.byKey(const Key('payments_list_forbidden')), findsNothing);
    });
  });
}
