import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_payment.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/presentation/payment/applied_payments_panel.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'payments_list_screen_test.dart';

class _RecordingPaymentController extends PaymentController {
  static final reversals = <Map<String, Object?>>[];

  @override
  Future<void> reverse({
    required int saleId,
    required int customerPaymentId,
    required int applicationId,
    required String reason,
  }) async {
    reversals.add({
      'saleId': saleId,
      'customerPaymentId': customerPaymentId,
      'applicationId': applicationId,
      'reason': reason,
    });
  }
}

SalePayment _payment(int id, {bool cancelled = false}) => SalePayment(
  id: id,
  customerPayment: 18000 + id,
  amount: '500.00',
  methodCode: 1,
  currency: Currency.mxn,
  changeAmount: '0.00',
  cancelled: cancelled,
  type: PaymentType.immediate,
  paymentDate: DateTime(2026, 11, 12, 18, 2),
);

/// Spec 059 C7 (T007): the panel's two optional callbacks, and the register's
/// own reverse path staying exactly as it was.
void main() {
  late PaymentsMocks mocks;

  setUp(() {
    mocks = PaymentsMocks();
    _RecordingPaymentController.reversals.clear();
    when(
      () => mocks.payments.listForOrder(saleId: any(named: 'saleId')),
    ).thenAnswer((_) async => [_payment(9), _payment(10, cancelled: true)]);
  });

  Future<void> pump(
    WidgetTester tester, {
    bool enabled = true,
    void Function(SalePayment)? onReverse,
    void Function(int)? onOpenPayment,
  }) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          customerPaymentRepositoryProvider.overrideWithValue(mocks.payments),
          paymentControllerProvider.overrideWith(
            _RecordingPaymentController.new,
          ),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppliedPaymentsPanel(
              saleId: 7,
              enabled: enabled,
              onReverse: onReverse,
              onOpenPayment: onOpenPayment,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  final undo = find.byIcon(Icons.undo);

  testWidgets('the register path: the shared dialog, then '
      'PaymentController.reverse with the same arguments as before', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(undo);
    await tester.pumpAndSettle();

    expect(find.text(r'$500.00 aplicados al pedido #7.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('reversal_reason_field')),
      'Error de captura',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('reversal_reason_confirm')));
    await tester.pumpAndSettle();

    expect(_RecordingPaymentController.reversals, [
      {
        'saleId': 7,
        'customerPaymentId': 18009,
        'applicationId': 9,
        'reason': 'Error de captura',
      },
    ]);
  });

  testWidgets('cancelling the dialog reverses nothing', (tester) async {
    await pump(tester);

    await tester.tap(undo);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(_RecordingPaymentController.reversals, isEmpty);
  });

  testWidgets('onReverse takes over the tap: no dialog, no register write', (
    tester,
  ) async {
    final seen = <int>[];
    await pump(tester, onReverse: (payment) => seen.add(payment.id));

    await tester.tap(undo);
    await tester.pumpAndSettle();

    expect(seen, [9]);
    expect(find.byKey(const Key('reversal_reason_dialog')), findsNothing);
    expect(_RecordingPaymentController.reversals, isEmpty);
  });

  testWidgets('a row links to its payment only when onOpenPayment is set', (
    tester,
  ) async {
    await pump(tester);
    expect(find.byKey(const Key('applied_payment_open_18009')), findsNothing);

    final opened = <int>[];
    await pump(tester, onOpenPayment: opened.add);

    expect(find.byKey(const Key('applied_payment_open_18009')), findsOneWidget);
    // A reversed application still links: its payment is where it is explained.
    expect(find.byKey(const Key('applied_payment_open_18010')), findsOneWidget);

    await tester.tap(find.byKey(const Key('applied_payment_open_18009')));
    expect(opened, [18009]);
  });

  testWidgets('no reverse icon on a reversed row, or when disabled', (
    tester,
  ) async {
    await pump(tester);
    expect(undo, findsOneWidget);

    await pump(tester, enabled: false);
    expect(undo, findsNothing);
  });
}
