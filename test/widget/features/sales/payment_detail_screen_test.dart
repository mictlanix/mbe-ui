import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_detail_screen.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_link_providers.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'payments_list_screen_test.dart';

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

User _user({
  bool pos = false,
  bool editor = false,
  int? facilityId = 9,
}) => User(
  userId: 'u1',
  email: 'u1@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  settings: facilityId == null ? null : UserSettings(facilityId: facilityId),
  privileges: [
    const Privilege(systemObject: SystemObject.customerPayments, rawValue: 2),
    if (pos) const Privilege(systemObject: SystemObject.pos, rawValue: 2),
    if (editor)
      const Privilege(systemObject: SystemObject.paymentsEditor, rawValue: 2),
  ],
);

PaymentApplication _app(
  int id,
  int saleId,
  String amount, {
  bool reversed = false,
  int? applierId,
}) => PaymentApplication(
  id: id,
  saleId: saleId,
  amount: amount,
  change: '0.00',
  applierId: applierId,
  date: DateTime(2026, 8, 6, 10),
  reversed: reversed,
);

/// Spec 054 US2, FR-003, FR-013–FR-015: the read-only payment screen.
void main() {
  late PaymentsMocks mocks;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    mocks = PaymentsMocks();
    when(
      () => mocks.payments.listApplications(
        customerPaymentId: any(named: 'customerPaymentId'),
      ),
    ).thenAnswer((_) async => const []);
  });

  void stubGet(CustomerPayment payment) => when(
    () => mocks.payments.get(customerPaymentId: payment.customerPaymentId),
  ).thenAnswer((_) async => payment);

  void stubApps(List<PaymentApplication> apps) => when(
    () => mocks.payments.listApplications(customerPaymentId: 501),
  ).thenAnswer((_) async => apps);

  Future<GoRouter> pumpDetail(
    WidgetTester tester, {
    User? user,
    String location = '/sales/payments/501',
    int? paymentId = 501,
    Map<int, String?> orderTargets = const {},
  }) async {
    tester.view.physicalSize = const Size(1400, 1400);
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
            AuthState.authenticated(token: 't', user: user ?? _user()),
          ),
        ),
        customerPaymentRepositoryProvider.overrideWithValue(mocks.payments),
        customerRepositoryProvider.overrideWithValue(mocks.customers),
        paymentMethodOptionRepositoryProvider.overrideWithValue(mocks.options),
        facilityDisplayNameProvider.overrideWith(
          (ref, id) async => 'Sucursal Centro',
        ),
        employeeDisplayNameProvider.overrideWith(
          (ref, id) async => 'Luis Reyes',
        ),
        orderLinkTargetProvider.overrideWith(
          (ref, saleId) async => orderTargets[saleId],
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/sales/payments',
          builder: (_, _) => const Scaffold(body: Text('payments-list')),
        ),
        GoRoute(
          path: '/sales/payments/:paymentId',
          builder: (context, state) => PaymentDetailScreen(
            paymentId: int.tryParse(state.pathParameters['paymentId']!),
          ),
        ),
        GoRoute(
          path: '/sales/orders/:id',
          builder: (_, s) =>
              Scaffold(body: Text('order-${s.pathParameters['id']}')),
        ),
        GoRoute(
          path: '/sales/cash-sessions/:id',
          builder: (_, s) =>
              Scaffold(body: Text('session-${s.pathParameters['id']}')),
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

  Finder inKey(String key, Finder matching) =>
      find.descendant(of: find.byKey(Key(key)), matching: matching);

  group('header and summary', () {
    testWidgets('shows "Pago N", the verified chip and the three amounts, '
        'Aplicado excluding reversed applications', (tester) async {
      stubGet(
        testPayment(verifierId: 5, unapplied: '200.00', amount: '500.00'),
      );
      stubApps([
        _app(1, 10, '200.00'),
        _app(2, 11, '100.00'),
        _app(3, 12, '999.00', reversed: true),
      ]);

      await pumpDetail(tester);

      expect(find.text(l10n.paymentViewTitle), findsOneWidget);
      expect(find.text('Pago 501'), findsOneWidget);
      expect(find.byKey(const Key('payment_chip_verified')), findsOneWidget);
      expect(
        inKey('payment_summary_amount', find.text(r'$500.00 MXN')),
        findsOneWidget,
      );
      expect(
        inKey('payment_summary_applied', find.text(r'$300.00 MXN')),
        findsOneWidget,
      );
      expect(
        inKey('payment_summary_unapplied', find.text(r'$200.00 MXN')),
        findsOneWidget,
      );
    });

    testWidgets('an unverified payment shows the unverified chip', (
      tester,
    ) async {
      stubGet(testPayment(verifierId: null));

      await pumpDetail(tester);

      expect(find.byKey(const Key('payment_chip_unverified')), findsOneWidget);
    });
  });

  group('fields', () {
    testWidgets('shows every field with resolved names', (tester) async {
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
      stubGet(
        testPayment(
          methodCode: 4,
          paymentOptionId: 3,
          reference: 'REF-99',
          verifierId: 5,
        ).copyWith(cashSessionId: 77),
      );

      await pumpDetail(tester);

      expect(find.text('Aceros del Bajío'), findsOneWidget);
      expect(find.text('2026-08-05 09:30'), findsOneWidget);
      expect(find.text('3 MSI'), findsOneWidget);
      expect(find.text('REF-99'), findsOneWidget);
      expect(find.text(l10n.paymentTypeImmediate), findsOneWidget);
      expect(find.text('Sucursal Centro'), findsOneWidget);
      expect(find.text('Luis Reyes'), findsOneWidget);
      expect(find.text('#77'), findsOneWidget);
    });

    testWidgets('empty fields show "—": no option, reference, cash session or '
        'verifier', (tester) async {
      stubGet(testPayment());

      await pumpDetail(tester);

      // Option, reference, cash session and verifier.
      expect(find.text('—'), findsNWidgets(4));
    });

    testWidgets('an option or employee that cannot be resolved falls back to '
        'its number', (tester) async {
      // `mocks.options.get` throws for the unstubbed option.
      stubGet(testPayment(paymentOptionId: 3));

      await pumpDetail(tester);

      expect(find.text('#3'), findsOneWidget);
    });
  });

  group('cash-session link', () {
    testWidgets('is a link with POS read and opens the session', (
      tester,
    ) async {
      stubGet(testPayment().copyWith(cashSessionId: 77));

      final router = await pumpDetail(tester, user: _user(pos: true));
      await tester.tap(find.byKey(const Key('payment_cash_session_link')));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/cash-sessions/77');
    });

    testWidgets('is plain text without POS read', (tester) async {
      stubGet(testPayment().copyWith(cashSessionId: 77));

      await pumpDetail(tester, user: _user(pos: false));

      expect(find.byKey(const Key('payment_cash_session_link')), findsNothing);
      expect(find.text('#77'), findsOneWidget);
    });
  });

  group('applications', () {
    testWidgets('reversed ones are muted and carry the "Revertida" chip, live '
        'ones do not', (tester) async {
      stubGet(testPayment());
      stubApps([_app(1, 10, '200.00'), _app(3, 12, '999.00', reversed: true)]);

      await pumpDetail(tester);

      expect(find.byKey(const Key('payment_chip_reversed')), findsOneWidget);
      final disabled = Theme.of(
        tester.element(find.byKey(const Key('payment_applications_table'))),
      ).disabledColor;
      expect(
        tester.widget<Text>(find.text(r'$999.00 MXN')).style?.color,
        disabled,
      );
      expect(
        tester
            .widget<Text>(
              inKey('payment_applications_table', find.text(r'$200.00 MXN')),
            )
            .style
            ?.color,
        isNot(disabled),
      );
    });

    testWidgets('an empty list shows the "not applied" message', (
      tester,
    ) async {
      stubGet(testPayment(unapplied: '1250.00'));

      await pumpDetail(tester);

      expect(
        find.byKey(const Key('payment_applications_empty')),
        findsOneWidget,
      );
      expect(find.text(l10n.paymentApplicationsEmpty), findsOneWidget);
      expect(
        inKey('payment_summary_applied', find.text(r'$0.00 MXN')),
        findsOneWidget,
      );
    });

    testWidgets('order numbers are links only where a route is available, '
        'plain "#id" otherwise', (tester) async {
      stubGet(testPayment());
      stubApps([_app(1, 10, '200.00'), _app(2, 11, '100.00')]);

      final router = await pumpDetail(
        tester,
        orderTargets: {10: '/sales/orders/10'},
      );

      expect(find.byKey(const Key('payment_order_link_10')), findsOneWidget);
      expect(find.byKey(const Key('payment_order_link_11')), findsNothing);
      expect(find.text('#11'), findsOneWidget);

      await tester.tap(find.byKey(const Key('payment_order_link_10')));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/sales/orders/10');
    });

    testWidgets('the applier shows by name, or "—" when unknown', (
      tester,
    ) async {
      stubGet(testPayment());
      stubApps([_app(1, 10, '200.00', applierId: 5), _app(2, 11, '100.00')]);

      await pumpDetail(tester);

      expect(find.text('Luis Reyes'), findsOneWidget);
      // Option, reference, cash session, verifier and the second applier.
      expect(find.text('—'), findsWidgets);
    });

    testWidgets('a failure shows an inline error with retry while the '
        'payment\'s fields stay visible', (tester) async {
      stubGet(testPayment(reference: 'REF-99'));
      when(
        () => mocks.payments.listApplications(customerPaymentId: 501),
      ).thenThrow(const AppError.server());

      await pumpDetail(tester);

      expect(find.text('Pago 501'), findsOneWidget);
      expect(find.text('REF-99'), findsOneWidget);
      expect(find.text(l10n.retryButton), findsOneWidget);
      // The total is unknown, not a wrong figure.
      expect(inKey('payment_summary_applied', find.text('—')), findsOneWidget);

      stubApps(const []);
      await tester.tap(find.text(l10n.retryButton));
      await tester.pumpAndSettle();

      expect(find.text(l10n.retryButton), findsNothing);
      expect(
        find.byKey(const Key('payment_applications_empty')),
        findsOneWidget,
      );
      expect(find.text('REF-99'), findsOneWidget);
    });
  });

  group('not found and failure', () {
    testWidgets('a 404 shows the not-found state', (tester) async {
      when(
        () => mocks.payments.get(customerPaymentId: 501),
      ).thenThrow(const AppError.notFound());

      await pumpDetail(tester);

      expect(find.byKey(const Key('payment_not_found')), findsOneWidget);
      expect(find.text(l10n.paymentBackToList), findsOneWidget);
    });

    testWidgets('"Volver a Pagos" returns to the list', (tester) async {
      when(
        () => mocks.payments.get(customerPaymentId: 501),
      ).thenThrow(const AppError.notFound());

      final router = await pumpDetail(tester);
      await tester.tap(find.text(l10n.paymentBackToList));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/sales/payments');
    });

    testWidgets('a non-numeric id shows not-found without any request', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        location: '/sales/payments/abc',
        paymentId: null,
      );

      expect(find.byKey(const Key('payment_not_found')), findsOneWidget);
      verifyZeroInteractions(mocks.payments);
    });

    testWidgets('another facility\'s payment is not found without Payments '
        'Editor read, and its applications are never requested', (
      tester,
    ) async {
      stubGet(testPayment().copyWith(facilityId: 4));

      await pumpDetail(tester, user: _user(facilityId: 9));

      expect(find.byKey(const Key('payment_not_found')), findsOneWidget);
      expect(find.text('Pago 501'), findsNothing);
      verifyNever(
        () => mocks.payments.listApplications(
          customerPaymentId: any(named: 'customerPaymentId'),
        ),
      );
    });

    testWidgets('a user with no facility is refused the same way', (
      tester,
    ) async {
      stubGet(testPayment());

      await pumpDetail(tester, user: _user(facilityId: null));

      expect(find.byKey(const Key('payment_not_found')), findsOneWidget);
    });

    testWidgets('a Payments Editor reader may open another facility\'s '
        'payment', (tester) async {
      stubGet(testPayment().copyWith(facilityId: 4));

      await pumpDetail(tester, user: _user(facilityId: 9, editor: true));

      expect(find.byKey(const Key('payment_not_found')), findsNothing);
      expect(find.text('Pago 501'), findsOneWidget);
    });

    testWidgets('a generic load failure shows the retry view, and retry '
        'loads the payment', (tester) async {
      when(
        () => mocks.payments.get(customerPaymentId: 501),
      ).thenThrow(const AppError.server());

      await pumpDetail(tester);

      expect(find.text(l10n.retryButton), findsOneWidget);
      expect(find.byKey(const Key('payment_not_found')), findsNothing);

      stubGet(testPayment());
      await tester.tap(find.text(l10n.retryButton));
      await tester.pumpAndSettle();

      expect(find.text('Pago 501'), findsOneWidget);
    });
  });

  group('read-only (FR-003)', () {
    testWidgets('has no verify, reject, reverse or edit control', (
      tester,
    ) async {
      stubGet(testPayment(verifierId: 5));
      stubApps([_app(1, 10, '200.00'), _app(2, 11, '5.00', reversed: true)]);

      await pumpDetail(
        tester,
        user: _user(pos: true, editor: true),
        orderTargets: {10: '/sales/orders/10'},
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.actions ?? const [], isEmpty);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byWidgetPredicate(
            (w) =>
                w is ElevatedButton ||
                w is FilledButton ||
                w is IconButton ||
                w is TextButton,
          ),
        ),
        findsNothing,
      );
      final action = RegExp('verif|rechaz|revert|editar', caseSensitive: false);
      final buttons = find.byWidgetPredicate(
        (w) =>
            w is ElevatedButton ||
            w is FilledButton ||
            w is OutlinedButton ||
            w is TextButton ||
            w is IconButton,
      );
      for (final button in buttons.evaluate()) {
        final texts = find.descendant(
          of: find.byWidget(button.widget),
          matching: find.byType(Text),
        );
        for (final t in texts.evaluate()) {
          expect(action.hasMatch((t.widget as Text).data ?? ''), isFalse);
        }
      }
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.byType(Checkbox), findsNothing);
    });
  });

  group('layout (FR-019)', () {
    PaymentApplication app(int id, String amount, {bool reversed = false}) =>
        PaymentApplication(
          id: id,
          saleId: 5000 + id,
          amount: amount,
          change: '0.00',
          applierId: 4,
          date: DateTime(2026, 8, 5, 10),
          reversed: reversed,
        );

    for (final (name, size) in [
      ('Expanded', const Size(1280, 900)),
      ('phone', const Size(400, 800)),
    ]) {
      testWidgets('$name width: pumps with no overflow, applications '
          'included', (tester) async {
        stubGet(testPayment(paymentOptionId: 3, reference: 'SPEI 0123456789'));
        stubApps([app(1, '1000.00'), app(2, '250.50', reversed: true)]);
        await pumpDetail(tester);
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.byKey(const Key('payment_applications_table')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('payment_summary_applied')),
          findsOneWidget,
        );
      });
    }
  });
}
