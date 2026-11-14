import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/verification_payment_panel.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'payments_list_screen_test.dart';

CustomerPayment _payment({
  String? reference = '0045122',
  int? cashSessionId = 812,
  int facilityId = 9,
}) => CustomerPayment(
  customerPaymentId: 9128,
  customerId: 77,
  customerName: 'Constructora Gil',
  amount: '12000.00',
  currency: Currency.mxn,
  methodCode: 3,
  reference: reference,
  date: DateTime(2026, 11, 13, 12, 5),
  facilityId: facilityId,
  cashSessionId: cashSessionId,
  type: PaymentType.creditPayment,
  unapplied: '9000.00',
);

/// Spec 060 C4 (T010): the read-only panel a queue row opens, built from the
/// row's own data (FR-005a).
void main() {
  late PaymentsMocks mocks;

  setUp(() => mocks = PaymentsMocks());

  Future<void> open(
    WidgetTester tester,
    CustomerPayment payment, {
    String? facilityName = 'Norte',
  }) async {
    tester.view.physicalSize = const Size(1400, 1000);
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
          facilityDisplayNameProvider.overrideWith(
            (ref, id) async => facilityName,
          ),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                key: const Key('open'),
                onPressed: () => showVerificationPaymentPanel(context, payment),
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

  testWidgets('shows every field of the payment, read-only', (tester) async {
    await open(tester, _payment());

    expect(find.text('Pago 9128'), findsOneWidget);
    expect(find.byKey(const Key('verification_panel_9128')), findsOneWidget);
    expect(find.text('Sin verificar'), findsOneWidget);
    expect(find.text('Norte'), findsOneWidget);
    expect(find.text('2026-11-13 12:05'), findsOneWidget);
    expect(find.text('Constructora Gil'), findsOneWidget);
    expect(find.text('Pago de crédito'), findsOneWidget);
    expect(find.textContaining('Transferencia'), findsOneWidget);
    expect(find.text('0045122'), findsOneWidget);
    expect(find.text(r'$12,000.00 MXN'), findsOneWidget);
    expect(find.text(r'$9,000.00 MXN'), findsOneWidget);
    expect(find.text('#812'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('a missing reference and cash session show dashes', (
    tester,
  ) async {
    await open(tester, _payment(reference: null, cashSessionId: null));

    expect(find.text('—'), findsNWidgets(2));
  });

  testWidgets('a facility whose name can not be read shows its number', (
    tester,
  ) async {
    await open(tester, _payment(), facilityName: null);

    expect(find.text('#9'), findsOneWidget);
  });

  testWidgets("another facility's payment opens with no payment request at "
      'all', (tester) async {
    // Nothing is stubbed on the repository: any call would return null and
    // fail. The panel has to be complete from the row alone (FR-005a).
    await open(tester, _payment(facilityId: 14), facilityName: 'Sur');

    expect(find.text('Sur'), findsOneWidget);
    verifyZeroInteractions(mocks.payments);
  });

  testWidgets('offers no action besides closing', (tester) async {
    await open(tester, _payment());

    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.widgetWithText(TextButton, 'Verificar'), findsNothing);
    expect(find.widgetWithText(TextButton, 'Rechazar'), findsNothing);
  });
}
