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
import 'package:mbe_ui/features/sales/presentation/payment_verification/reject_payment_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'payments_list_screen_test.dart';

CustomerPayment _payment() => CustomerPayment(
  customerPaymentId: 9128,
  customerId: 77,
  customerName: 'Constructora Gil',
  amount: '12000.00',
  currency: Currency.mxn,
  methodCode: 3,
  reference: '0045122',
  date: DateTime(2026, 11, 13, 12, 5),
  facilityId: 9,
  type: PaymentType.creditPayment,
  unapplied: '12000.00',
);

/// Spec 060 C6 (T014): the reject dialog.
void main() {
  late PaymentsMocks mocks;
  bool? result;

  setUp(() {
    mocks = PaymentsMocks();
    result = null;
    when(
      () => mocks.payments.reject(
        customerPaymentId: 9128,
        reason: any(named: 'reason'),
      ),
    ).thenAnswer((_) async => _payment());
  });

  Future<void> open(WidgetTester tester) async {
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
                onPressed: () async =>
                    result = await showRejectPaymentDialog(context, _payment()),
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

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byKey(const Key('reject_reason_field')), text);
    await tester.pump();
  }

  bool confirmEnabled(WidgetTester tester) => tester
      .widget<FilledButton>(find.byKey(const Key('reject_payment_confirm')))
      .enabled;

  testWidgets('names the folio, customer, amount and reference, and says what '
      'a rejection does', (tester) async {
    await open(tester);

    expect(find.text('Rechazar pago'), findsOneWidget);
    expect(find.text('9128'), findsOneWidget);
    expect(find.text('Constructora Gil'), findsOneWidget);
    expect(find.text(r'$12,000.00 MXN'), findsOneWidget);
    expect(find.text('0045122'), findsOneWidget);
    expect(find.textContaining('seguirá sin verificar'), findsOneWidget);
  });

  group('the reason', () {
    testWidgets('confirm is disabled while it is empty', (tester) async {
      await open(tester);

      expect(confirmEnabled(tester), isFalse);
    });

    testWidgets('confirm stays disabled for spaces only', (tester) async {
      await open(tester);
      await type(tester, '     ');

      expect(confirmEnabled(tester), isFalse);
    });

    testWidgets('confirm is enabled once there is text', (tester) async {
      await open(tester);
      await type(tester, 'No aparece');

      expect(confirmEnabled(tester), isTrue);
    });

    testWidgets('is limited to 500 characters, with a counter', (tester) async {
      await open(tester);
      await type(tester, 'x' * 600);

      final field = tester.widget<TextField>(
        find.byKey(const Key('reject_reason_field')),
      );
      expect(field.controller!.text.length, 500);
      expect(find.text('500/500'), findsOneWidget);
    });
  });

  testWidgets('sends the trimmed reason once, closes with true, even when '
      'tapped twice', (tester) async {
    final gate = Completer<CustomerPayment>();
    when(
      () => mocks.payments.reject(
        customerPaymentId: 9128,
        reason: any(named: 'reason'),
      ),
    ).thenAnswer((_) => gate.future);
    await open(tester);
    await type(tester, '  No aparece en el estado de cuenta  ');

    await tester.tap(find.byKey(const Key('reject_payment_confirm')));
    await tester.pump();
    await tester.tap(
      find.byKey(const Key('reject_payment_confirm')),
      warnIfMissed: false,
    );
    await tester.pump();

    gate.complete(_payment());
    await tester.pumpAndSettle();

    verify(
      () => mocks.payments.reject(
        customerPaymentId: 9128,
        reason: 'No aparece en el estado de cuenta',
      ),
    ).called(1);
    expect(find.byKey(const Key('reject_payment_dialog')), findsNothing);
    expect(result, isTrue);
  });

  testWidgets('while it is in flight the buttons are disabled and the dialog '
      'cannot be dismissed', (tester) async {
    final gate = Completer<CustomerPayment>();
    when(
      () => mocks.payments.reject(
        customerPaymentId: 9128,
        reason: any(named: 'reason'),
      ),
    ).thenAnswer((_) => gate.future);
    await open(tester);
    await type(tester, 'No aparece');

    await tester.tap(find.byKey(const Key('reject_payment_confirm')));
    await tester.pump();

    expect(confirmEnabled(tester), isFalse);
    final cancel = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Cancelar'),
    );
    expect(cancel.onPressed, isNull);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.byKey(const Key('reject_payment_dialog')), findsOneWidget);

    gate.complete(_payment());
    await tester.pumpAndSettle();
  });

  testWidgets('Cancelar closes with false and rejects nothing', (tester) async {
    await open(tester);
    await type(tester, 'No aparece');

    await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
    await tester.pumpAndSettle();

    verifyNever(
      () => mocks.payments.reject(
        customerPaymentId: any(named: 'customerPaymentId'),
        reason: any(named: 'reason'),
      ),
    );
    expect(result, isFalse);
  });

  testWidgets("a server refusal shows the server's reason in Spanish and the "
      'only way on is to close', (tester) async {
    when(
      () => mocks.payments.reject(
        customerPaymentId: 9128,
        reason: any(named: 'reason'),
      ),
    ).thenAnswer(
      (_) async => throw const AppError.server(
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
    await type(tester, 'No aparece');

    await tester.tap(find.byKey(const Key('reject_payment_confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Otra persona ya verificó este pago.'), findsOneWidget);
    expect(find.byKey(const Key('reject_payment_confirm')), findsNothing);

    await tester.tap(find.byKey(const Key('reject_payment_close')));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('a lost connection says the result is unknown', (tester) async {
    when(
      () => mocks.payments.reject(
        customerPaymentId: 9128,
        reason: any(named: 'reason'),
      ),
    ).thenAnswer((_) async => throw const AppError.network());
    await open(tester);
    await type(tester, 'No aparece');

    await tester.tap(find.byKey(const Key('reject_payment_confirm')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reject_payment_unknown')), findsOneWidget);
    expect(find.textContaining('No sabemos si se registró'), findsOneWidget);
    expect(find.byKey(const Key('reject_payment_close')), findsOneWidget);
  });
}
