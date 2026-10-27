import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_payment.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_step.dart';

import 'pos_test_harness.dart';
import 'session_override.dart';

class MockPaymentMethodOptionRepository extends Mock
    implements PaymentMethodOptionRepository {}

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

  Future<void> pumpStep(
    WidgetTester tester, {
    required String balance,
    PaymentTerms paymentTerms = PaymentTerms.immediate,
    VoidCallback? onClose,
    CurrentSession? session,
  }) async {
    await pumpPos(
      tester,
      PaymentStep(
        sale: testSale(
          status: SaleStatus.completed,
          balance: balance,
          paymentTerms: paymentTerms,
        ),
        onClose: onClose ?? () {},
      ),
      overrides: [
        customerPaymentOverride(paymentRepository),
        session == null ? openSessionOverride() : sessionOverride(session),
        paymentMethodOptionRepositoryProvider.overrideWithValue(
          optionRepository,
        ),
      ],
    );
  }

  FloatingActionButton closeButton(WidgetTester tester) =>
      tester.widget<FloatingActionButton>(
        find.byKey(const Key('payment_close_button')),
      );

  group('close gate (FR-049, FR-051)', () {
    testWidgets('disabled while a balance is outstanding on immediate terms', (
      tester,
    ) async {
      await pumpStep(tester, balance: '116.00');
      expect(closeButton(tester).onPressed, isNull);
    });

    testWidgets('enabled once the balance reaches exactly zero', (
      tester,
    ) async {
      await pumpStep(tester, balance: '0.00');
      expect(closeButton(tester).onPressed, isNotNull);
    });

    testWidgets('a balance of "0" and "0.00" are both zero — the gate compares '
        'decimals, not strings', (tester) async {
      await pumpStep(tester, balance: '0');
      expect(closeButton(tester).onPressed, isNotNull);
    });

    testWidgets('credit terms open the gate with a balance outstanding '
        '(FR-051)', (tester) async {
      await pumpStep(
        tester,
        balance: '116.00',
        paymentTerms: PaymentTerms.netD,
      );
      expect(closeButton(tester).onPressed, isNotNull);
    });

    testWidgets('closing invokes the host callback', (tester) async {
      var closed = false;
      await pumpStep(tester, balance: '0.00', onClose: () => closed = true);

      await tester.tap(find.byKey(const Key('payment_close_button')));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
    });
  });

  group('the tender itself (spec 047 US5)', () {
    void stubTender() {
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
    }

    String amountText(WidgetTester tester) => tester
        .widget<TextField>(find.byKey(const Key('payment_amount_field')))
        .controller!
        .text;

    testWidgets('there is no apply button, and the amount opens pre-filled '
        'with the balance (FR-016)', (tester) async {
      await pumpStep(tester, balance: '116.00');

      expect(find.byKey(const Key('payment_submit_button')), findsNothing);
      expect(find.byKey(const Key('payment_reference_field')), findsNothing);
      expect(amountText(tester), '116.00');
    });

    testWidgets('tapping a method applies the keyed amount with that method', (
      tester,
    ) async {
      stubTender();
      await pumpStep(tester, balance: '116.00');

      await tester.enterText(
        find.byKey(const Key('payment_amount_field')),
        '50.00',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('payment_method_1')));
      await tester.pumpAndSettle();

      verify(
        () => paymentRepository.createPayment(
          customer: 7,
          amount: '50.00',
          method: 1,
          currency: any(named: 'currency'),
          paymentCharge: null,
          reference: null,
        ),
      ).called(1);
    });

    testWidgets('an empty or zero amount applies nothing and says why', (
      tester,
    ) async {
      stubTender();
      await pumpStep(tester, balance: '116.00');

      await tester.enterText(
        find.byKey(const Key('payment_amount_field')),
        '0',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('payment_method_1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('payment_issue_message')), findsOneWidget);
      expect(find.text('Captura un monto mayor a cero.'), findsOneWidget);
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
  });

  group('the cash session gate (spec 047 FR-004)', () {
    final stale = CurrentSession(
      state: SessionState.stale,
      session: CashSession(
        cashSessionId: 77,
        cashDrawerId: 1,
        cashDrawerName: 'Caja 1',
        cashDrawerCode: 'CJ1',
        cashierId: 100,
        cashierName: 'Ana López',
        start: DateTime(2026, 8, 4, 9),
        openingAmount: '500',
      ),
    );

    testWidgets('an open session shows no banner and enables the tiles', (
      tester,
    ) async {
      await pumpStep(tester, balance: '116.00');

      expect(find.byKey(const Key('pos_session_blocked_banner')), findsNothing);
      final tile = tester.widget<InkWell>(
        find.descendant(
          of: find.byKey(const Key('payment_method_1')),
          matching: find.byType(InkWell),
        ),
      );
      expect(tile.onTap, isNotNull);
    });

    for (final (label, current) in [
      ('stale', stale),
      ('none', const CurrentSession(state: SessionState.none)),
    ]) {
      testWidgets('a $label session shows the blocking banner and disables '
          'the tiles', (tester) async {
        await pumpStep(tester, balance: '116.00', session: current);

        expect(
          find.byKey(const Key('pos_session_blocked_banner')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('pos_session_blocked_action')),
          findsOneWidget,
        );
        final tile = tester.widget<InkWell>(
          find.descendant(
            of: find.byKey(const Key('payment_method_1')),
            matching: find.byType(InkWell),
          ),
        );
        expect(tile.onTap, isNull);
      });
    }
  });

  group('the status filter passed to the option catalog', () {
    testWidgets('only active options are offered', (tester) async {
      await pumpStep(tester, balance: '116.00');
      verify(
        () => optionRepository.list(
          facilityId: 9,
          status: EntityStatus.active,
          limit: 100,
        ),
      ).called(1);
    });
  });

  group('spending credit notes (spec 056)', () {
    late MockCreditNoteRepository creditRepository;
    late MockSalesOrderRepository salesOrders;

    CreditNote note(int id, String remaining) => CreditNote(
      id: id,
      customerId: 7,
      salesOrderId: 300 + id,
      customerRefundId: 400 + id,
      customerPaymentId: 500 + id,
      issued: remaining,
      remaining: remaining,
      date: DateTime(2026, 9, id),
    );

    setUp(() {
      creditRepository = MockCreditNoteRepository();
      salesOrders = MockSalesOrderRepository();
    });

    Future<void> pumpCreditStep(WidgetTester tester) async {
      final sale = testSale(status: SaleStatus.completed, balance: '1000.00');
      when(
        () => creditRepository.listForCustomer(any()),
      ).thenAnswer((_) async => [note(1, '300.00'), note(2, '700.00')]);
      when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => sale);
      await pumpPos(
        tester,
        PaymentStep(sale: sale, onClose: () {}),
        overrides: [
          customerPaymentOverride(paymentRepository),
          openSessionOverride(),
          paymentMethodOptionRepositoryProvider.overrideWithValue(
            optionRepository,
          ),
          fixedPosSale(sale),
          salesOrderOverride(salesOrders),
          creditNoteOverride(creditRepository),
          creditAccessOverride(),
        ],
      );
    }

    testWidgets('an applied credit note reads "Nota de crédito · Nº {ticket}" '
        '(FR-009)', (tester) async {
      when(
        () => paymentRepository.listForOrder(saleId: any(named: 'saleId')),
      ).thenAnswer(
        (_) async => [
          SalePayment(
            id: 1,
            customerPayment: 501,
            amount: '300.00',
            methodCode: 0,
            currency: Currency.mxn,
            changeAmount: '0',
            cancelled: false,
            type: PaymentType.creditNote,
            paymentDate: DateTime(2026, 9, 1),
          ),
        ],
      );
      await pumpCreditStep(tester);

      expect(find.textContaining('Nota de crédito · Nº 501'), findsOneWidget);
    });

    testWidgets('a partly applied spend shows what was applied above the '
        'server\'s reason', (tester) async {
      var calls = 0;
      when(
        () => paymentRepository.applyPayment(
          customerPaymentId: any(named: 'customerPaymentId'),
          salesOrder: any(named: 'salesOrder'),
          amount: any(named: 'amount'),
          amountChange: any(named: 'amountChange'),
        ),
      ).thenAnswer((_) async {
        if (++calls == 2) throw const AppError.server();
      });
      await pumpCreditStep(tester);

      await tester.tap(find.byKey(const Key('payment_credit_note_tile')));
      await tester.pumpAndSettle();

      final issue = find.byKey(const Key('payment_issue_message'));
      final banner = find.byType(ErrorBanner);
      expect(issue, findsOneWidget);
      expect(banner, findsOneWidget);
      expect(
        tester.widget<Text>(issue).data,
        contains('\$300.00'),
        reason: 'the message names the credit that did go through',
      );
      expect(
        tester.getTopLeft(issue).dy,
        lessThan(tester.getTopLeft(banner).dy),
        reason: 'the issue line sits above the banner',
      );
    });

    testWidgets('a server error alone still shows only the banner', (
      tester,
    ) async {
      when(
        () => paymentRepository.createPayment(
          customer: any(named: 'customer'),
          amount: any(named: 'amount'),
          method: any(named: 'method'),
          currency: any(named: 'currency'),
          paymentCharge: any(named: 'paymentCharge'),
          reference: any(named: 'reference'),
        ),
      ).thenThrow(const AppError.server());
      await pumpCreditStep(tester);

      await tester.tap(find.byKey(const Key('payment_method_1')));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.byKey(const Key('payment_issue_message')), findsNothing);
    });
  });
}
