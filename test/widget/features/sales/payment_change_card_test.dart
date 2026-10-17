import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_change_card.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_step.dart';

import 'pos_test_harness.dart';
import 'session_override.dart';

class MockPaymentMethodOptionRepository extends Mock
    implements PaymentMethodOptionRepository {}

/// spec 047 US6 (contracts C7): the change owed after a cash overpayment
/// stays on screen until dismissed, while the summary's own "Cambio" row
/// remains the live preview while an amount is keyed.
void main() {
  late MockCustomerPaymentRepository paymentRepository;
  late MockPaymentMethodOptionRepository optionRepository;

  setUp(() {
    paymentRepository = MockCustomerPaymentRepository();
    optionRepository = MockPaymentMethodOptionRepository();
    when(
      () => paymentRepository.listForOrder(saleId: any(named: 'saleId')),
    ).thenAnswer((_) async => []);
    when(
      () => paymentRepository.createPayment(
        customer: any(named: 'customer'),
        amount: any(named: 'amount'),
        method: any(named: 'method'),
        currency: any(named: 'currency'),
        paymentCharge: any(named: 'paymentCharge'),
        reference: any(named: 'reference'),
      ),
    ).thenAnswer((_) async => 500);
    when(
      () => paymentRepository.applyPayment(
        customerPaymentId: any(named: 'customerPaymentId'),
        salesOrder: any(named: 'salesOrder'),
        amount: any(named: 'amount'),
        amountChange: any(named: 'amountChange'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => optionRepository.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const PaymentMethodOptionPage(items: [], total: 0),
    );
  });

  testWidgets('the card shows the change and stays until dismissed', (tester) async {
    var dismissed = 0;
    await pumpPos(
      tester,
      PaymentChangeCard(amount: '34.00', onDismiss: () => dismissed++),
    );

    expect(find.byKey(const Key('payment_change_card')), findsOneWidget);
    expect(find.text('Cambio a entregar'), findsOneWidget);
    expect(find.textContaining('34.00'), findsOneWidget);
    expect(find.text('Entendido'), findsOneWidget);

    await tester.tap(find.byKey(const Key('payment_change_dismiss')));
    expect(dismissed, 1);
  });

  group('on the payment step', () {
    final sale = testSale(status: SaleStatus.completed, balance: '116.00');

    Future<void> pumpStep(WidgetTester tester, {Size? surface}) => pumpPos(
      tester,
      PaymentStep(sale: sale, onClose: () {}),
      surface: surface ?? const Size(1280, 900),
      overrides: [
        customerPaymentOverride(paymentRepository),
        openSessionOverride(),
        paymentMethodOptionRepositoryProvider.overrideWithValue(optionRepository),
      ],
    );

    testWidgets('a cash overpayment shows the card, which survives until '
        'dismissed; the live Cambio row previews while typing', (tester) async {
      await pumpStep(tester);
      expect(find.byKey(const Key('payment_change_card')), findsNothing);

      await tester.enterText(find.byKey(const Key('payment_amount_field')), '150.00');
      await tester.pumpAndSettle();
      // The preview: the summary's own row shows the excess while typing.
      expect(
        find.descendant(
          of: find.byKey(const Key('payment_summary_panel')),
          matching: find.textContaining('34.00'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('payment_change_card')), findsNothing);

      await tester.tap(find.byKey(const Key('payment_method_1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('payment_change_card')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('payment_change_card')),
          matching: find.textContaining('34.00'),
        ),
        findsOneWidget,
      );
      verify(
        () => paymentRepository.applyPayment(
          customerPaymentId: 500,
          salesOrder: 42,
          amount: '116.00',
          amountChange: '34',
        ),
      ).called(1);

      await tester.tap(find.byKey(const Key('payment_change_dismiss')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('payment_change_card')), findsNothing);
    });

    testWidgets('a non-cash overpayment shows the error and applies nothing', (
      tester,
    ) async {
      await pumpStep(tester);

      await tester.enterText(find.byKey(const Key('payment_amount_field')), '150.00');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('payment_method_4')));
      await tester.pumpAndSettle();

      expect(find.text('Solo el efectivo puede exceder el saldo.'), findsOneWidget);
      expect(find.byKey(const Key('payment_change_card')), findsNothing);
      verifyNever(
        () => paymentRepository.createPayment(
          customer: any(named: 'customer'),
          amount: any(named: 'amount'),
          method: any(named: 'method'),
          currency: any(named: 'currency'),
          paymentCharge: any(named: 'paymentCharge'),
          reference: any(named: 'reference'),
        ),
      );
    });

    testWidgets('fits a phone with no horizontal scroll', (tester) async {
      await pumpStep(tester, surface: const Size(390, 844));

      await tester.enterText(find.byKey(const Key('payment_amount_field')), '150.00');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('payment_method_1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('payment_change_card')), findsOneWidget);
      expect(tester.takeException(), isNull);
      expectNoHorizontalScroll(tester);
    });
  });
}
