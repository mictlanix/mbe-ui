import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_payment_repository.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/payment_verification_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'payments_list_screen_test.dart';

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

/// A verifier: Payments Verification read, plus update and Facilities read
/// when asked. No Customer Payments right at all, as a real verifier may have.
User _verifier({bool update = true, bool facilities = false}) => User(
  userId: 'verifier-1',
  email: 'verifier@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(
      systemObject: SystemObject.paymentsVerification,
      rawValue: update ? 6 : 2,
    ),
    if (facilities)
      const Privilege(systemObject: SystemObject.facilities, rawValue: 2),
  ],
);

CustomerPayment _row(
  int id, {
  int facility = 9,
  String customer = 'Constructora Gil',
  String? reference = 'SPEI 88213',
  int method = 3,
}) => CustomerPayment(
  customerPaymentId: id,
  customerId: 77,
  customerName: customer,
  amount: '4250.00',
  currency: Currency.mxn,
  methodCode: method,
  reference: reference,
  date: DateTime(2026, 11, 13, 17, 20),
  facilityId: facility,
  type: PaymentType.creditPayment,
  unapplied: '4250.00',
);

/// Spec 060 C2 (T013): the verification queue screen.
void main() {
  late PaymentsMocks mocks;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => mocks = PaymentsMocks());

  void stubQueue(List<CustomerPayment> items, {int? total}) =>
      when(
        () => mocks.payments.listUnverified(
          facilityId: any(named: 'facilityId'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          methodCode: any(named: 'methodCode'),
          rejected: any(named: 'rejected'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => CustomerPaymentListResult(
          items: items,
          total: total ?? items.length,
        ),
      );

  Future<GoRouter> pump(
    WidgetTester tester, {
    User? user,
    String location = '/sales/payment-verification',
    Size size = const Size(1400, 1000),
    String? Function(int id)? facilityName,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: user ?? _verifier()),
          ),
        ),
        customerPaymentRepositoryProvider.overrideWithValue(mocks.payments),
        facilityDisplayNameProvider.overrideWith(
          (ref, id) async =>
              facilityName == null ? 'Sucursal $id' : facilityName(id),
        ),
      ],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: paymentVerificationPath,
          builder: (context, state) => Scaffold(
            body: PaymentVerificationScreen(
              query: ListQuery.fromUri(state.uri),
            ),
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
    return router;
  }

  Badge badge(WidgetTester tester) => tester.widget<Badge>(
    find.ancestor(
      of: find.byKey(const Key('verification_filter_button')),
      matching: find.byType(Badge),
    ),
  );

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('verification_filter_button')));
    await tester.pumpAndSettle();
  }

  group('rows and the list', () {
    testWidgets('show folio, facility, date, customer, method, reference and '
        'amount', (tester) async {
      stubQueue([_row(9131, facility: 4)]);
      await pump(tester);

      expect(find.text('9131'), findsOneWidget);
      expect(find.text('Sucursal 4'), findsOneWidget);
      expect(find.text('2026-11-13 17:20'), findsOneWidget);
      expect(find.text('Constructora Gil'), findsOneWidget);
      expect(find.textContaining('Transferencia'), findsWidgets);
      expect(find.text('SPEI 88213'), findsOneWidget);
      expect(find.text(r'$4,250.00 MXN'), findsOneWidget);
    });

    testWidgets('a facility whose name cannot be read shows its number', (
      tester,
    ) async {
      stubQueue([_row(9131, facility: 4)]);
      await pump(tester, facilityName: (_) => null);

      expect(find.text('#4'), findsOneWidget);
    });

    testWidgets('a rejected payment carries the rejection mark, with date and '
        'reason in its tooltip (mbe-api#310)', (tester) async {
      stubQueue([
        _row(9131).copyWith(
          lastRejection: PaymentRejection(
            reason: 'Sin comprobante',
            rejectedById: 12,
            rejectedAt: DateTime(2026, 11, 14, 9, 30),
          ),
        ),
        _row(9132),
      ]);
      await pump(tester);

      final icon = find.byKey(const Key('payment_icon_rejected'));
      expect(icon, findsOneWidget);
      expect(
        tester
            .widget<Tooltip>(
              find.ancestor(of: icon, matching: find.byType(Tooltip)).first,
            )
            .message,
        'Rechazado · 2026-11-14 09:30 · Sin comprobante',
      );
    });

    testWidgets('a missing reference shows a dash', (tester) async {
      stubQueue([_row(9131, reference: null)]);
      await pump(tester);

      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('the footer carries the server total, and nothing is added to '
        'the filter row (spec 060 FR-004, §VI)', (tester) async {
      // A full page: a table that claims more rows than it holds never settles.
      stubQueue([for (var i = 1; i <= 20; i++) _row(i)], total: 23);
      await pump(tester);

      expect(find.textContaining('de 23'), findsOneWidget);
      expect(find.byKey(const Key('verification_count')), findsNothing);
      // The filter row holds the filters button and no search box.
      expect(
        find.byKey(const Key('verification_filter_button')),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('the opening request and the filters', () {
    testWidgets('open on transfers from every facility, first page', (
      tester,
    ) async {
      stubQueue([_row(1)]);
      await pump(tester);

      verify(
        () => mocks.payments.listUnverified(
          facilityId: null,
          dateFrom: null,
          dateTo: null,
          methodCode: 3,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    });

    testWidgets('the badge reads 1 on the opening view, because Transfer '
        'already narrows', (tester) async {
      stubQueue([_row(1)]);
      await pump(tester);

      expect(badge(tester).isLabelVisible, isTrue);
      expect(badge(tester).label.toString(), contains('1'));
    });

    testWidgets('the badge shows nothing with "Todos"', (tester) async {
      stubQueue([_row(1)]);
      await pump(tester, location: '/sales/payment-verification?method=all');

      expect(badge(tester).isLabelVisible, isFalse);
    });

    testWidgets('choosing "Todos" writes method=all and asks for every '
        'method', (tester) async {
      stubQueue([_row(1)]);
      final router = await pump(tester);
      await openSheet(tester);

      await tester.tap(find.byKey(const Key('verification_filter_method')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.paymentVerificationMethodAll).last);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['method'], 'all');
      verify(
        () => mocks.payments.listUnverified(
          facilityId: null,
          dateFrom: null,
          dateTo: null,
          methodCode: null,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    });

    testWidgets('the "Rechazos" chips write rejected= and send it '
        '(mbe-api#310)', (tester) async {
      stubQueue([_row(1)]);
      final router = await pump(tester);
      await openSheet(tester);

      await tester.tap(
        find.byKey(const Key('verification_filter_rejected_yes')),
      );
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['rejected'], 'true');
      verify(
        () => mocks.payments.listUnverified(
          facilityId: null,
          dateFrom: null,
          dateTo: null,
          methodCode: 3,
          rejected: true,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    });

    testWidgets('a facility and a date range in the address are sent', (
      tester,
    ) async {
      stubQueue([_row(1)]);
      await pump(
        tester,
        location:
            '/sales/payment-verification?facility=4&date-from=2026-11-01'
            '&date-to=2026-11-13&method=1',
      );

      verify(
        () => mocks.payments.listUnverified(
          facilityId: 4,
          dateFrom: DateTime(2026, 11, 1),
          dateTo: DateTime(2026, 11, 13),
          methodCode: 1,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    });

    testWidgets('"Limpiar filtros" goes back to the opening state: transfers, '
        'every facility, any date', (tester) async {
      stubQueue([_row(1)]);
      final router = await pump(
        tester,
        location:
            '/sales/payment-verification?facility=4&method=all'
            '&date-from=2026-11-01&date-to=2026-11-13',
      );
      await openSheet(tester);

      await tester.tap(find.text(l10n.clearAllFilters));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/payment-verification');
      expect(router.state.uri.queryParameters, isEmpty);
    });

    testWidgets('the facility filter is offered with Facilities read', (
      tester,
    ) async {
      stubQueue([_row(1)]);
      await pump(tester, user: _verifier(facilities: true));
      await openSheet(tester);

      expect(
        find.byKey(const Key('verification_filter_facility')),
        findsOneWidget,
      );
    });

    testWidgets('without Facilities read there is no facility filter, and the '
        'rows still show (spec 060 R7)', (tester) async {
      stubQueue([_row(1)]);
      await pump(tester, user: _verifier());
      await openSheet(tester);

      expect(
        find.byKey(const Key('verification_filter_facility')),
        findsNothing,
      );
      expect(find.byKey(const Key('verification_table')), findsOneWidget);
    });
  });

  group('row actions', () {
    testWidgets('verify shows on every row with update', (tester) async {
      stubQueue([_row(1), _row(2)]);
      await pump(tester);

      expect(find.byKey(const Key('verify_payment_1')), findsOneWidget);
      expect(find.byKey(const Key('verify_payment_2')), findsOneWidget);
    });

    testWidgets('reject shows beside verify on every row, two icons and no '
        'menu', (tester) async {
      stubQueue([_row(1), _row(2)]);
      await pump(tester);

      expect(find.byKey(const Key('reject_payment_1')), findsOneWidget);
      expect(find.byKey(const Key('reject_payment_2')), findsOneWidget);
      expect(find.byType(PopupMenuButton<VoidCallback>), findsNothing);
      // Exactly two row icons: verify and reject.
      expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(2));
      expect(find.byIcon(Icons.block), findsNWidgets(2));
    });

    testWidgets('with read only there is no verify icon and no action column', (
      tester,
    ) async {
      stubQueue([_row(1), _row(2)]);
      await pump(tester, user: _verifier(update: false));

      expect(find.byKey(const Key('verify_payment_1')), findsNothing);
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
      expect(find.byIcon(Icons.block), findsNothing);
      expect(find.byKey(const Key('reject_payment_1')), findsNothing);
      // The rows themselves still show.
      expect(find.text('Constructora Gil'), findsNWidgets(2));
    });

    testWidgets('verifying confirms, reloads and says so; the row leaves', (
      tester,
    ) async {
      var rows = [_row(1), _row(2, customer: 'Materiales Ríos')];
      when(
        () => mocks.payments.listUnverified(
          facilityId: any(named: 'facilityId'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          methodCode: any(named: 'methodCode'),
          rejected: any(named: 'rejected'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async =>
            CustomerPaymentListResult(items: [...rows], total: rows.length),
      );
      when(() => mocks.payments.verify(customerPaymentId: 1)).thenAnswer((
        _,
      ) async {
        rows = [rows[1]];
        return _row(1);
      });
      await pump(tester);

      await tester.tap(find.byKey(const Key('verify_payment_1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('verify_payment_dialog')), findsOneWidget);

      await tester.tap(find.byKey(const Key('verify_payment_confirm')));
      await tester.pumpAndSettle();

      verify(() => mocks.payments.verify(customerPaymentId: 1)).called(1);
      expect(find.text('Pago 1 verificado.'), findsOneWidget);
      expect(find.byKey(const Key('verify_payment_1')), findsNothing);
      expect(find.byKey(const Key('verify_payment_2')), findsOneWidget);
    });

    testWidgets('rejecting sends the trimmed reason, says it stays in the '
        'queue, and the row is still listed', (tester) async {
      stubQueue([_row(1), _row(2, customer: 'Materiales Ríos')]);
      when(
        () => mocks.payments.reject(
          customerPaymentId: 1,
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async => _row(1));
      await pump(tester);

      await tester.tap(find.byKey(const Key('reject_payment_1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('reject_payment_dialog')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('reject_reason_field')),
        '  No aparece en el estado  ',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('reject_payment_confirm')));
      await tester.pumpAndSettle();

      verify(
        () => mocks.payments.reject(
          customerPaymentId: 1,
          reason: 'No aparece en el estado',
        ),
      ).called(1);
      expect(
        find.textContaining('sigue sin verificar y seguirá en la lista'),
        findsOneWidget,
      );
      // Nothing about the row changed: it is still there, with both icons.
      expect(find.byKey(const Key('verify_payment_1')), findsOneWidget);
      expect(find.byKey(const Key('reject_payment_1')), findsOneWidget);
      expect(find.text('Rechazado'), findsNothing);
    });

    testWidgets('a row tap opens the read-only panel from the row, even for '
        "another facility's payment, with no payment request", (tester) async {
      stubQueue([_row(1, facility: 14, customer: 'Materiales Ríos')]);
      await pump(tester);

      await tester.tap(find.text('Materiales Ríos'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('verification_panel_1')), findsOneWidget);
      verifyNever(
        () => mocks.payments.get(
          customerPaymentId: any(named: 'customerPaymentId'),
        ),
      );
    });
  });

  group('states', () {
    testWidgets('empty on the opening view says so and offers no clearing', (
      tester,
    ) async {
      stubQueue(const []);
      await pump(tester);

      expect(find.text(l10n.paymentVerificationEmpty), findsOneWidget);
      expect(find.text(l10n.clearFiltersButton), findsNothing);
    });

    testWidgets('empty with filters that differ from the opening ones offers '
        'to clear them', (tester) async {
      stubQueue(const []);
      final router = await pump(
        tester,
        location: '/sales/payment-verification?method=all',
      );

      // The shared view words a filtered-empty list itself.
      expect(find.text(l10n.filteredEmptyTitle), findsOneWidget);
      await tester.tap(find.text(l10n.clearFiltersButton));
      await tester.pumpAndSettle();
      expect(router.state.uri.queryParameters, isEmpty);
    });

    testWidgets('a failure offers a retry', (tester) async {
      when(
        () => mocks.payments.listUnverified(
          facilityId: any(named: 'facilityId'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          methodCode: any(named: 'methodCode'),
          rejected: any(named: 'rejected'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const AppError.server(statusCode: 500));
      await pump(tester);

      expect(find.text(l10n.retryButton), findsOneWidget);
    });

    testWidgets('a 403 says the user is not allowed and offers no retry', (
      tester,
    ) async {
      when(
        () => mocks.payments.listUnverified(
          facilityId: any(named: 'facilityId'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          methodCode: any(named: 'methodCode'),
          rejected: any(named: 'rejected'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const AppError.server(statusCode: 403));
      await pump(tester);

      expect(find.byKey(const Key('verification_forbidden')), findsOneWidget);
      expect(find.text(l10n.retryButton), findsNothing);
    });

    testWidgets('on a phone the rows stack and verify stays reachable, with '
        'no overflow', (tester) async {
      stubQueue([_row(9131, facility: 4)]);
      await pump(tester, size: const Size(420, 900));

      expect(find.byKey(const Key('verify_payment_9131')), findsOneWidget);
      expect(find.textContaining('Constructora Gil'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
