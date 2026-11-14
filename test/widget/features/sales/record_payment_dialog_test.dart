import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/facility_payment_options_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/record_payment_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'payments_list_screen_test.dart';

class _Session extends CurrentSessionController {
  _Session(this._state);
  final SessionState _state;

  @override
  Future<CurrentSession> build() async => CurrentSession(state: _state);
}

CustomerListItem _customer(int id, String name) => CustomerListItem(
  customerId: id,
  code: 'C-$id',
  name: name,
  creditLimit: '0',
  creditDays: 0,
  priceList: const PriceListRef(id: 1, name: 'General'),
  status: EntityStatus.active,
);

PaymentMethodOption _option(
  int id,
  String name,
  int method, {
  bool requiresReference = false,
}) => PaymentMethodOption(
  paymentMethodOptionId: id,
  facilityId: 9,
  facilityName: 'Sucursal Centro',
  name: name,
  numberOfPayments: 1,
  displayOnTicket: true,
  paymentMethod: method,
  status: EntityStatus.active,
  requiresReference: requiresReference,
);

final _options = [
  _option(11, 'Efectivo caja', 1),
  _option(12, 'Transferencia SPEI', 3, requiresReference: true),
];

/// Spec 059 C2 (T013): recording a credit payment or an advance.
void main() {
  late PaymentsMocks mocks;
  String? landedOn;

  setUpAll(() => registerFallbackValue(PaymentType.immediate));

  setUp(() {
    mocks = PaymentsMocks();
    landedOn = null;
    when(
      () => mocks.customers.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        priceList: any(named: 'priceList'),
        salesperson: any(named: 'salesperson'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => CustomerPage(
        items: [_customer(12, 'Ferretería Sol'), _customer(1, 'Público')],
        total: 2,
      ),
    );
    when(
      () => mocks.payments.createPayment(
        customer: any(named: 'customer'),
        amount: any(named: 'amount'),
        method: any(named: 'method'),
        currency: any(named: 'currency'),
        paymentCharge: any(named: 'paymentCharge'),
        reference: any(named: 'reference'),
        type: any(named: 'type'),
      ),
    ).thenAnswer((_) async => 55);
  });

  Future<void> open(
    WidgetTester tester, {
    SessionState session = SessionState.open,
  }) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: ElevatedButton(
              key: const Key('open'),
              onPressed: () => showRecordPaymentDialog(context),
              child: const Text('open'),
            ),
          ),
        ),
        GoRoute(
          path: '/sales/payments/:id',
          builder: (_, state) {
            landedOn = state.uri.path;
            return Scaffold(
              body: Text('payment-${state.pathParameters['id']}'),
            );
          },
        ),
        GoRoute(
          path: '/sales/cash-sessions',
          builder: (_, _) => const Scaffold(body: Text('sessions-list')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          customerPaymentRepositoryProvider.overrideWithValue(mocks.payments),
          customerRepositoryProvider.overrideWithValue(mocks.customers),
          userFacilityIdProvider.overrideWithValue(9),
          facilityPaymentOptionsControllerProvider(
            9,
          ).overrideWith((ref) async => _options),
          currentSessionControllerProvider.overrideWith(
            () => _Session(session),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
  }

  Future<void> pickCustomer(WidgetTester tester, String optionText) async {
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('record_payment_customer')),
        matching: find.byType(TextFormField),
      ),
      'a',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.text(optionText));
    await tester.pumpAndSettle();
  }

  Future<void> pickMethod(WidgetTester tester, String name) async {
    await tester.tap(find.byKey(const Key('record_payment_method')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  Future<void> typeAmount(WidgetTester tester, String text) async {
    await tester.enterText(
      find.byKey(const Key('record_payment_amount')),
      text,
    );
    await tester.pump();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('record_payment_save')));
    await tester.pumpAndSettle();
  }

  void verifyNoPayment() => verifyNever(
    () => mocks.payments.createPayment(
      customer: any(named: 'customer'),
      amount: any(named: 'amount'),
      method: any(named: 'method'),
      currency: any(named: 'currency'),
      paymentCharge: any(named: 'paymentCharge'),
      reference: any(named: 'reference'),
      type: any(named: 'type'),
    ),
  );

  testWidgets('an empty form names each missing field and records nothing', (
    tester,
  ) async {
    await open(tester);

    await save(tester);

    expect(find.text('Elige un cliente.'), findsOneWidget);
    expect(find.text('Elige un método de pago.'), findsOneWidget);
    expect(find.text('Escribe un monto mayor que cero.'), findsOneWidget);
    verifyNoPayment();
  });

  testWidgets('the general-public customer is refused under the field', (
    tester,
  ) async {
    await open(tester);
    await pickCustomer(tester, 'C-1 — Público');
    await pickMethod(tester, 'Efectivo caja');
    await typeAmount(tester, '100');

    await save(tester);

    expect(
      find.textContaining('el público en general no puede tener anticipos'),
      findsOneWidget,
    );
    verifyNoPayment();
  });

  testWidgets('a method that needs a reference refuses without one', (
    tester,
  ) async {
    await open(tester);
    await pickCustomer(tester, 'C-12 — Ferretería Sol');
    await pickMethod(tester, 'Transferencia SPEI');
    await typeAmount(tester, '100');

    await save(tester);

    expect(find.text('Este método necesita una referencia.'), findsOneWidget);
    verifyNoPayment();
  });

  testWidgets('zero, negative or text amounts are refused', (tester) async {
    await open(tester);
    await pickCustomer(tester, 'C-12 — Ferretería Sol');
    await pickMethod(tester, 'Efectivo caja');

    for (final text in ['0', '-5', 'abc']) {
      await typeAmount(tester, text);
      await save(tester);
      expect(
        find.text('Escribe un monto mayor que cero.'),
        findsOneWidget,
        reason: text,
      );
    }
    verifyNoPayment();
  });

  testWidgets('cash without an open session today is refused, with a way to '
      'the sessions list', (tester) async {
    await open(tester, session: SessionState.none);
    await pickCustomer(tester, 'C-12 — Ferretería Sol');
    await pickMethod(tester, 'Efectivo caja');
    await typeAmount(tester, '100');

    await save(tester);

    expect(
      find.text('Para registrar efectivo necesitas una caja abierta hoy.'),
      findsOneWidget,
    );
    verifyNoPayment();

    await tester.tap(find.byKey(const Key('record_payment_go_sessions')));
    await tester.pumpAndSettle();
    expect(find.text('sessions-list'), findsOneWidget);
  });

  testWidgets('a stale session counts as none for cash', (tester) async {
    await open(tester, session: SessionState.stale);
    await pickCustomer(tester, 'C-12 — Ferretería Sol');
    await pickMethod(tester, 'Efectivo caja');
    await typeAmount(tester, '100');

    await save(tester);

    expect(
      find.byKey(const Key('record_payment_cash_session_error')),
      findsOneWidget,
    );
    verifyNoPayment();
  });

  testWidgets('a transfer is recorded without any cash session', (
    tester,
  ) async {
    await open(tester, session: SessionState.none);
    await pickCustomer(tester, 'C-12 — Ferretería Sol');
    await pickMethod(tester, 'Transferencia SPEI');
    await tester.enterText(
      find.byKey(const Key('record_payment_reference')),
      ' SPEI 88213 ',
    );
    await typeAmount(tester, '3000.00');

    await save(tester);

    verify(
      () => mocks.payments.createPayment(
        customer: 12,
        amount: '3000',
        method: 3,
        currency: null,
        paymentCharge: 12,
        reference: 'SPEI 88213',
        type: PaymentType.creditPayment,
      ),
    ).called(1);
  });

  testWidgets('an advance is recorded as an advance, and cash with a session '
      'goes through', (tester) async {
    await open(tester);
    await pickCustomer(tester, 'C-12 — Ferretería Sol');
    await tester.tap(find.text('Pago anticipado'));
    await tester.pump();
    await pickMethod(tester, 'Efectivo caja');
    await typeAmount(tester, '5000');

    await save(tester);

    verify(
      () => mocks.payments.createPayment(
        customer: 12,
        amount: '5000',
        method: 1,
        currency: null,
        paymentCharge: 11,
        reference: null,
        type: PaymentType.paymentInAdvance,
      ),
    ).called(1);
  });

  testWidgets('success closes the dialog and opens the new payment', (
    tester,
  ) async {
    await open(tester);
    await pickCustomer(tester, 'C-12 — Ferretería Sol');
    await pickMethod(tester, 'Efectivo caja');
    await typeAmount(tester, '100');

    await save(tester);

    expect(find.byKey(const Key('record_payment_dialog')), findsNothing);
    expect(find.text('payment-55'), findsOneWidget);
    expect(landedOn, '/sales/payments/55');
  });

  testWidgets('a second tap while saving records one payment', (tester) async {
    await open(tester);
    await pickCustomer(tester, 'C-12 — Ferretería Sol');
    await pickMethod(tester, 'Efectivo caja');
    await typeAmount(tester, '100');
    final gate = Completer<int>();
    when(
      () => mocks.payments.createPayment(
        customer: any(named: 'customer'),
        amount: any(named: 'amount'),
        method: any(named: 'method'),
        currency: any(named: 'currency'),
        paymentCharge: any(named: 'paymentCharge'),
        reference: any(named: 'reference'),
        type: any(named: 'type'),
      ),
    ).thenAnswer((_) => gate.future);

    await tester.tap(find.byKey(const Key('record_payment_save')));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(const Key('record_payment_save')));
    await tester.pump();

    verify(
      () => mocks.payments.createPayment(
        customer: 12,
        amount: '100',
        method: 1,
        currency: null,
        paymentCharge: 11,
        reference: null,
        type: PaymentType.creditPayment,
      ),
    ).called(1);

    gate.complete(55);
    await tester.pumpAndSettle();
  });

  testWidgets('a server refusal shows in the dialog with the form kept', (
    tester,
  ) async {
    await open(tester);
    await pickCustomer(tester, 'C-12 — Ferretería Sol');
    await pickMethod(tester, 'Efectivo caja');
    await typeAmount(tester, '100');
    when(
      () => mocks.payments.createPayment(
        customer: any(named: 'customer'),
        amount: any(named: 'amount'),
        method: any(named: 'method'),
        currency: any(named: 'currency'),
        paymentCharge: any(named: 'paymentCharge'),
        reference: any(named: 'reference'),
        type: any(named: 'type'),
      ),
    ).thenThrow(const AppError.server());

    await save(tester);

    expect(find.byKey(const Key('record_payment_dialog')), findsOneWidget);
    expect(find.byType(ErrorBanner), findsOneWidget);
    expect(
      find.byKey(const Key('record_payment_unknown_result')),
      findsNothing,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('record_payment_amount')))
          .controller!
          .text,
      '100',
    );
  });

  testWidgets('a network failure says the result is unknown and offers no '
      'blind retry', (tester) async {
    await open(tester);
    await pickCustomer(tester, 'C-12 — Ferretería Sol');
    await pickMethod(tester, 'Efectivo caja');
    await typeAmount(tester, '100');
    when(
      () => mocks.payments.createPayment(
        customer: any(named: 'customer'),
        amount: any(named: 'amount'),
        method: any(named: 'method'),
        currency: any(named: 'currency'),
        paymentCharge: any(named: 'paymentCharge'),
        reference: any(named: 'reference'),
        type: any(named: 'type'),
      ),
    ).thenThrow(const AppError.network());

    await save(tester);

    expect(
      find.byKey(const Key('record_payment_unknown_result')),
      findsOneWidget,
    );
    expect(
      find.textContaining('No sabemos si el pago se registró'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('record_payment_dialog')), findsOneWidget);
  });
}
