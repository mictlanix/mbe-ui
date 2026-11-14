import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/verify_payment_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'payments_list_screen_test.dart';

CustomerPayment _payment({String? reference = 'SPEI 88213'}) => CustomerPayment(
  customerPaymentId: 9131,
  customerId: 77,
  customerName: 'Ferretería López',
  amount: '4250.00',
  currency: Currency.mxn,
  methodCode: 3,
  reference: reference,
  date: DateTime(2026, 11, 13, 17, 20),
  facilityId: 9,
  type: PaymentType.creditPayment,
  unapplied: '4250.00',
);

/// Spec 060 C5 (T009): the verify dialog.
void main() {
  late PaymentsMocks mocks;
  bool? result;

  setUp(() {
    mocks = PaymentsMocks();
    result = null;
  });

  void stubVerify(Future<CustomerPayment> Function() answer) => when(
    () => mocks.payments.verify(customerPaymentId: 9131),
  ).thenAnswer((_) => answer());

  Future<void> open(WidgetTester tester, {CustomerPayment? payment}) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          customerPaymentRepositoryProvider.overrideWithValue(mocks.payments),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                key: const Key('open'),
                onPressed: () async => result = await showVerifyPaymentDialog(
                  context,
                  payment ?? _payment(),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
  }

  bool confirmEnabled(WidgetTester tester) => tester
      .widget<FilledButton>(find.byKey(const Key('verify_payment_confirm')))
      .enabled;

  testWidgets('names the folio, customer, amount and reference, and says it '
      "can't be undone", (tester) async {
    await open(tester);

    expect(find.text('Verificar pago'), findsOneWidget);
    expect(find.text('9131'), findsOneWidget);
    expect(find.text('Ferretería López'), findsOneWidget);
    expect(find.text(r'$4,250.00 MXN'), findsOneWidget);
    expect(find.text('SPEI 88213'), findsOneWidget);
    expect(find.textContaining('No se puede deshacer'), findsOneWidget);
  });

  testWidgets('a payment with no reference shows a dash', (tester) async {
    await open(tester, payment: _payment(reference: null));

    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('confirming verifies once, closes with true, even when tapped '
      'twice', (tester) async {
    final gate = Completer<CustomerPayment>();
    stubVerify(() => gate.future);
    await open(tester);

    await tester.tap(find.byKey(const Key('verify_payment_confirm')));
    await tester.pump();
    // The button is busy and disabled, so a second tap does nothing.
    await tester.tap(
      find.byKey(const Key('verify_payment_confirm')),
      warnIfMissed: false,
    );
    await tester.pump();

    gate.complete(_payment());
    await tester.pumpAndSettle();

    verify(() => mocks.payments.verify(customerPaymentId: 9131)).called(1);
    expect(find.byKey(const Key('verify_payment_dialog')), findsNothing);
    expect(result, isTrue);
  });

  testWidgets('while it is in flight both buttons are disabled and the '
      'dialog cannot be dismissed', (tester) async {
    final gate = Completer<CustomerPayment>();
    stubVerify(() => gate.future);
    await open(tester);

    await tester.tap(find.byKey(const Key('verify_payment_confirm')));
    await tester.pump();

    expect(confirmEnabled(tester), isFalse);
    final cancel = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Cancelar'),
    );
    expect(cancel.onPressed, isNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.byKey(const Key('verify_payment_dialog')), findsOneWidget);

    gate.complete(_payment());
    await tester.pumpAndSettle();
  });

  testWidgets('Cancelar closes with false and verifies nothing', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
    await tester.pumpAndSettle();

    verifyNever(
      () => mocks.payments.verify(
        customerPaymentId: any(named: 'customerPaymentId'),
      ),
    );
    expect(result, isFalse);
  });

  testWidgets('a payment someone else already verified says so, and the only '
      'way on is to close', (tester) async {
    stubVerify(
      () async => throw const AppError.server(
        statusCode: 409,
        message: 'Payment is already verified',
        problem: ApiProblem(
          codeName: 'payment.already_verified',
          code: api.ErrorCode.paymentPeriodAlreadyVerified,
          params: {},
        ),
      ),
    );
    await open(tester);

    await tester.tap(find.byKey(const Key('verify_payment_confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Otra persona ya verificó este pago.'), findsOneWidget);
    expect(find.byKey(const Key('verify_payment_confirm')), findsNothing);
    expect(find.widgetWithText(TextButton, 'Cancelar'), findsNothing);

    await tester.tap(find.byKey(const Key('verify_payment_close')));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('a lost connection says the result is unknown, not that it '
      'failed', (tester) async {
    stubVerify(() async => throw const AppError.network());
    await open(tester);

    await tester.tap(find.byKey(const Key('verify_payment_confirm')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('verify_payment_unknown')), findsOneWidget);
    expect(find.textContaining('No sabemos si se verificó'), findsOneWidget);
    expect(find.byKey(const Key('verify_payment_close')), findsOneWidget);
  });
}
