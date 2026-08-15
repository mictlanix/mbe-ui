import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_payment.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_step.dart';

import 'pos_test_harness.dart';

class MockPaymentMethodOptionRepository extends Mock
    implements PaymentMethodOptionRepository {}

/// The payment step's own shapes (spec 025 contracts/payment-surface.md):
/// two panes at the Large tier with nothing to scroll to reach any control
/// (US1, SC-001), and — once built out further in this same file by later
/// tasks — the one-column/pinned-footer shape below it and the keypad's
/// proportions under both.
void main() {
  late MockCustomerPaymentRepository paymentRepository;
  late MockPaymentMethodOptionRepository optionRepository;

  setUp(() {
    paymentRepository = MockCustomerPaymentRepository();
    optionRepository = MockPaymentMethodOptionRepository();
    // Empty until a payment is actually applied — the applied-payments
    // listing is re-fetched (`orderPaymentsControllerProvider` invalidated)
    // once `submit()` succeeds, so the second call onward reflects it.
    var applied = false;
    when(
      () => paymentRepository.listForOrder(saleId: any(named: 'saleId')),
    ).thenAnswer(
      (_) async => applied
          ? [
              SalePayment(
                id: 1,
                customerPayment: 500,
                amount: '116.00',
                methodCode: 1,
                currency: Currency.mxn,
                changeAmount: '0',
                cancelled: false,
                paymentDate: DateTime(2026, 8, 15),
              ),
            ]
          : [],
    );
    when(
      () => paymentRepository.applyPayment(
        customerPaymentId: any(named: 'customerPaymentId'),
        salesOrder: any(named: 'salesOrder'),
        amount: any(named: 'amount'),
        amountChange: any(named: 'amountChange'),
      ),
    ).thenAnswer((_) async {
      applied = true;
    });
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
  });

  Future<void> pumpStep(
    WidgetTester tester, {
    required Size surface,
    String balance = '116.00',
  }) => pumpPos(
    tester,
    PaymentStep(sale: testSale(status: SaleStatus.completed, balance: balance), onClose: () {}),
    surface: surface,
    overrides: [
      customerPaymentOverride(paymentRepository),
      paymentMethodOptionRepositoryProvider.overrideWithValue(optionRepository),
    ],
  );

  group('the two-pane shape at the Large tier (US1, SC-001)', () {
    testWidgets(
      'the amount, a method tile, the keypad and the exit are all present '
      'with nothing to scroll',
      (tester) async {
        await pumpStep(tester, surface: const Size(1280, 900));

        expect(find.byKey(const Key('payment_amount_field')), findsOneWidget);
        expect(find.byKey(const Key('payment_method_1')), findsOneWidget);
        expect(find.byKey(const Key('number_pad_7')), findsOneWidget);
        expect(find.byKey(const Key('payment_close_button')), findsOneWidget);

        // The capture pane and the summary do not scroll at this tier
        // (FR-006) — every control below is already laid out and
        // hit-testable without moving anything. (No applied payments exist
        // yet in this case, so the rail shows its empty state rather than a
        // `ListView` — nothing to scroll either way.)
        for (final key in [
          'payment_amount_field',
          'payment_method_1',
          'number_pad_7',
          'payment_close_button',
        ]) {
          final rect = tester.getRect(find.byKey(Key(key)));
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.bottom, lessThanOrEqualTo(900));
        }
      },
    );

    testWidgets(
      'applying a cash payment end to end adds it to the rail with no '
      'scroll gesture',
      (tester) async {
        await pumpStep(tester, surface: const Size(1280, 900));

        await tester.tap(find.byKey(const Key('payment_method_1')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('payment_amount_field')),
          '116.00',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('payment_submit_button')));
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (w) => w is Container && w.key == const Key('applied_payment_1'),
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('the one-column shape below the Large tier (US3)', () {
    testWidgets(
      'the summary and the exit are pinned outside the scrolling region at '
      '1024x768',
      (tester) async {
        await pumpStep(tester, surface: const Size(1024, 768));

        // The close button lives in the pinned footer band (FR-004), never
        // inside the scrolling `ListView` that carries the header, the
        // capture pane and the applied payments.
        expect(
          find.ancestor(
            of: find.byKey(const Key('payment_close_button')),
            matching: find.byType(ListView),
          ),
          findsNothing,
        );
        expect(find.byKey(const Key('payment_close_button')), findsOneWidget);
      },
    );

    testWidgets(
      'the method grid and the keypad stack vertically once the pane is '
      'narrower than 900px (research R2)',
      (tester) async {
        // 700px window, one-column tier, no rail competing for width — the
        // capture pane still ends up under the 900px in-pane threshold.
        await pumpStep(tester, surface: const Size(700, 900));

        final methodTop = tester.getTopLeft(
          find.byKey(const Key('payment_method_1')),
        );
        final keypadTop = tester.getTopLeft(
          find.byKey(const Key('number_pad_7')),
        );
        // Stacked: the keypad starts well below where the methods start.
        // Side by side would put them at (roughly) the same y.
        expect(keypadTop.dy, greaterThan(methodTop.dy + 50));
      },
    );
  });

  group('the keypad keeps its proportions under every shape (US5)', () {
    // `NumberPad`'s own `childAspectRatio` is fixed at 1.8 (research R3) —
    // one independent pump per width (rather than three pumps in one test,
    // which left a pending timer behind) proves that placing it beside the
    // methods (Large tier), beneath them (tablet) or in a scrolling column
    // (phone) never stretches it, whatever height each pane hands it.
    const expectedRatio = 1.8;

    Future<void> expectUnstretchedAt(WidgetTester tester, Size surface) async {
      await pumpStep(tester, surface: surface);
      final size = tester.getSize(find.byKey(const Key('number_pad_7')));
      expect(size.width / size.height, closeTo(expectedRatio, 0.01));
    }

    testWidgets(
      "the '7' key keeps its ratio in the phone's scrolling column",
      (tester) => expectUnstretchedAt(tester, const Size(390, 900)),
    );

    testWidgets(
      "the '7' key keeps its ratio stacked beneath the methods (tablet)",
      (tester) => expectUnstretchedAt(tester, const Size(1024, 768)),
    );

    testWidgets(
      "the '7' key keeps its ratio beside the methods (Large tier)",
      (tester) => expectUnstretchedAt(tester, const Size(1440, 900)),
    );
  });
}
