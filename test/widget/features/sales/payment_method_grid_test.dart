import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_method_grid.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';
import 'session_override.dart';

class MockPaymentMethodOptionRepository extends Mock
    implements PaymentMethodOptionRepository {}

/// Tiles for [PaymentMethodGrid] (spec 025 T017, contracts/
/// payment-surface.md §4): one tile per configured `PaymentMethodOption`
/// carrying the right secondary line, the fallback set for a facility with no
/// options, and the loading/error passthrough unchanged. Since spec 047 a tap
/// applies the payment (so no tile is ever shown selected), and a method that
/// requires a reference asks for it in a dialog first.
void main() {
  late MockPaymentMethodOptionRepository optionRepository;
  late MockCustomerPaymentRepository paymentRepository;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    optionRepository = MockPaymentMethodOptionRepository();
    paymentRepository = MockCustomerPaymentRepository();
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
      () => paymentRepository.listForOrder(saleId: any(named: 'saleId')),
    ).thenAnswer((_) async => []);
  });

  final sale = testSale(status: SaleStatus.completed, balance: '116.00');

  PaymentMethodOption testOption({
    int id = 1,
    String name = 'Efectivo',
    int paymentMethod = 1,
    bool requiresReference = false,
  }) => PaymentMethodOption(
    paymentMethodOptionId: id,
    facilityId: 9,
    facilityName: 'Matriz',
    name: name,
    numberOfPayments: 1,
    displayOnTicket: true,
    paymentMethod: paymentMethod,
    status: EntityStatus.active,
    requiresReference: requiresReference,
  );

  void stubOptions(List<PaymentMethodOption> items) {
    when(
      () => optionRepository.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => PaymentMethodOptionPage(items: items, total: items.length),
    );
  }

  Future<ProviderContainer> pumpGrid(
    WidgetTester tester, {
    bool enabled = true,
  }) async {
    final container = await pumpPos(
      tester,
      PaymentMethodGrid(sale: sale, facilityId: 9, enabled: enabled),
      overrides: [
        paymentMethodOptionRepositoryProvider.overrideWithValue(
          optionRepository,
        ),
        customerPaymentOverride(paymentRepository),
        openSessionOverride(),
      ],
    );
    // The step pre-fills the amount; the grid alone does not.
    container.read(paymentControllerProvider.notifier).setAmount('116.00');
    return container;
  }

  void verifyCreated({String? reference}) => verify(
    () => paymentRepository.createPayment(
      customer: 7,
      amount: '116.00',
      method: any(named: 'method'),
      currency: any(named: 'currency'),
      paymentCharge: any(named: 'paymentCharge'),
      reference: reference,
    ),
  ).called(1);

  Container tileContainer(WidgetTester tester, Key tileKey) =>
      tester.widget<Container>(
        find.descendant(
          of: find.byKey(tileKey),
          matching: find.byType(Container),
        ),
      );

  group('configured options', () {
    testWidgets('one tile per option, each with the right secondary line', (
      tester,
    ) async {
      stubOptions([
        testOption(id: 1, name: 'Efectivo', requiresReference: false),
        testOption(
          id: 2,
          name: 'Tarjeta de crédito',
          paymentMethod: PaymentMethod.creditCard.code,
          requiresReference: true,
        ),
      ]);

      await pumpGrid(tester);

      expect(find.text('Efectivo'), findsOneWidget);
      expect(find.text('Tarjeta de crédito'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('payment_option_1')),
          matching: find.text(l10n.posPaymentMethodNoReference),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('payment_option_2')),
          matching: find.text(l10n.posPaymentMethodRequiresReference),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping a tile applies the payment and leaves it unselected', (
      tester,
    ) async {
      stubOptions([
        testOption(id: 1, name: 'Efectivo'),
        testOption(id: 2, name: 'Tarjeta', requiresReference: true),
      ]);
      await pumpGrid(tester);

      await tester.tap(find.byKey(const Key('payment_option_1')));
      await tester.pumpAndSettle();

      verify(
        () => paymentRepository.createPayment(
          customer: 7,
          amount: '116.00',
          method: 1,
          currency: any(named: 'currency'),
          paymentCharge: 1,
          reference: null,
        ),
      ).called(1);
      final border =
          (tileContainer(tester, const Key('payment_option_1')).decoration
                  as BoxDecoration)
              .border!
              .top;
      expect(border.width, 1);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('a tile is inert while the grid is disabled', (tester) async {
      stubOptions([testOption(id: 1, name: 'Efectivo')]);
      await pumpGrid(tester, enabled: false);

      await tester.tap(find.byKey(const Key('payment_option_1')));
      await tester.pumpAndSettle();

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

    group('a method that requires a reference', () {
      setUp(() {
        stubOptions([
          testOption(
            id: 2,
            name: 'Tarjeta',
            paymentMethod: PaymentMethod.creditCard.code,
            requiresReference: true,
          ),
        ]);
      });

      testWidgets('asks for it, and cancelling applies nothing', (
        tester,
      ) async {
        await pumpGrid(tester);

        await tester.tap(find.byKey(const Key('payment_option_2')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('payment_reference_dialog')),
          findsOneWidget,
        );

        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('payment_reference_dialog')), findsNothing);
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

      testWidgets('confirming applies the payment with that reference', (
        tester,
      ) async {
        await pumpGrid(tester);

        await tester.tap(find.byKey(const Key('payment_option_2')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('payment_reference_input')),
          'AUTH-123',
        );
        await tester.pump();
        await tester.tap(find.byKey(const Key('payment_reference_confirm')));
        await tester.pumpAndSettle();

        verifyCreated(reference: 'AUTH-123');
      });
    });
  });

  testWidgets(
    'a facility with no options renders the fallback tiles, none requiring '
    'a reference',
    (tester) async {
      stubOptions(const []);

      await pumpGrid(tester);

      for (final method in [
        PaymentMethod.cash,
        PaymentMethod.creditCard,
        PaymentMethod.debitCard,
        PaymentMethod.eft,
      ]) {
        expect(
          find.byKey(Key('payment_method_${method.code}')),
          findsOneWidget,
        );
      }
      expect(find.text(l10n.posPaymentMethodRequiresReference), findsNothing);
      expect(find.text(l10n.posPaymentMethodNoReference), findsNWidgets(4));
    },
  );

  testWidgets('a fallback tile applies the payment like a configured one', (
    tester,
  ) async {
    stubOptions(const []);
    await pumpGrid(tester);

    await tester.tap(
      find.byKey(Key('payment_method_${PaymentMethod.cash.code}')),
    );
    await tester.pumpAndSettle();

    verifyCreated();
  });

  testWidgets('shows a progress indicator while the options load', (
    tester,
  ) async {
    when(
      () => optionRepository.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
      // Never resolves — the point is to observe the loading frame. A
      // `LinearProgressIndicator` animates indefinitely, so `pumpGrid`'s
      // `pumpAndSettle` (via `pumpPos`) would time out waiting for it to
      // stop; pump the tree directly and settle only the microtask queue
      // with a single frame instead.
    ).thenAnswer((_) => Completer<PaymentMethodOptionPage>().future);

    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        paymentMethodOptionRepositoryProvider.overrideWithValue(
          optionRepository,
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: PaymentMethodGrid(sale: sale, facilityId: 9)),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets(
    'renders nothing blocking on failure — the rest of the step stays usable',
    (tester) async {
      when(
        () => optionRepository.list(
          search: any(named: 'search'),
          facilityId: any(named: 'facilityId'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('boom'));

      await pumpGrid(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(
        find.byKey(Key('payment_method_${PaymentMethod.cash.code}')),
        findsNothing,
      );
    },
  );

  group('credit tile (spec 056 FR-001, FR-002)', () {
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
      stubOptions([testOption()]);
    });

    Future<ProviderContainer> pumpCredit(
      WidgetTester tester, {
      Sale? onSale,
      List<CreditNote>? notes,
      Override? access,
    }) async {
      final target =
          onSale ?? testSale(status: SaleStatus.completed, balance: '1000.00');
      when(
        () => creditRepository.listSpendable(any()),
      ).thenAnswer((_) async => notes ?? [note(1, '300.00')]);
      when(
        () => salesOrders.getById(saleId: 42),
      ).thenAnswer((_) async => target);
      final container = await pumpPos(
        tester,
        PaymentMethodGrid(sale: target, facilityId: 9),
        overrides: [
          paymentMethodOptionRepositoryProvider.overrideWithValue(
            optionRepository,
          ),
          customerPaymentOverride(paymentRepository),
          openSessionOverride(),
          fixedPosSale(target),
          salesOrderOverride(salesOrders),
          creditNoteOverride(creditRepository),
          access ?? creditAccessOverride(),
        ],
      );
      container.read(paymentControllerProvider.notifier).setAmount('1000.00');
      return container;
    }

    const tile = Key('payment_credit_note_tile');

    testWidgets('shows the customer\'s balance as its second line', (
      tester,
    ) async {
      await pumpCredit(tester, notes: [note(1, '300.00'), note(2, '50.00')]);

      expect(find.byKey(tile), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(tile),
          matching: find.text(l10n.paymentCreditNoteTile),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(tile),
          matching: find.text(l10n.paymentCreditNoteBalance('\$350.00')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('is absent when the customer holds nothing spendable', (
      tester,
    ) async {
      await pumpCredit(tester, notes: [note(1, '0'), note(2, '0.000000')]);

      expect(find.byKey(tile), findsNothing);
    });

    testWidgets('is absent on a walk-in sale (FR-004)', (tester) async {
      await pumpCredit(
        tester,
        onSale: testSale(
          status: SaleStatus.completed,
          balance: '1000.00',
          customer: 1,
        ),
      );

      expect(find.byKey(tile), findsNothing);
    });

    testWidgets('is absent on a cancelled sale (FR-007)', (tester) async {
      await pumpCredit(
        tester,
        onSale: testSale(status: SaleStatus.cancelled, balance: '1000.00'),
      );

      expect(find.byKey(tile), findsNothing);
    });

    testWidgets('is absent when nothing is owed (FR-007)', (tester) async {
      await pumpCredit(
        tester,
        onSale: testSale(status: SaleStatus.paid, balance: '0.00'),
      );

      expect(find.byKey(tile), findsNothing);
    });

    testWidgets('is absent without credit-payments read (FR-014)', (
      tester,
    ) async {
      await pumpCredit(tester, access: creditAccessOverride(creditRead: false));

      expect(find.byKey(tile), findsNothing);
    });

    testWidgets('is absent without customer-payments create (FR-014)', (
      tester,
    ) async {
      await pumpCredit(
        tester,
        access: creditAccessOverride(paymentsCreate: false),
      );

      expect(find.byKey(tile), findsNothing);
    });

    testWidgets('tapping applies the note\'s own payment, creating none', (
      tester,
    ) async {
      await pumpCredit(tester);

      await tester.tap(find.byKey(tile));
      await tester.pumpAndSettle();

      verify(
        () => paymentRepository.applyPayment(
          customerPaymentId: 501,
          salesOrder: 42,
          // `Decimal` drops the trailing zeros: 300.00 is sent as 300.
          amount: '300',
          amountChange: null,
        ),
      ).called(1);
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

    testWidgets('is inert while the grid is disabled', (tester) async {
      final target = testSale(status: SaleStatus.completed, balance: '1000.00');
      when(
        () => creditRepository.listSpendable(any()),
      ).thenAnswer((_) async => [note(1, '300.00')]);
      await pumpPos(
        tester,
        PaymentMethodGrid(sale: target, facilityId: 9, enabled: false),
        overrides: [
          paymentMethodOptionRepositoryProvider.overrideWithValue(
            optionRepository,
          ),
          customerPaymentOverride(paymentRepository),
          openSessionOverride(),
          fixedPosSale(target),
          creditNoteOverride(creditRepository),
          creditAccessOverride(),
        ],
      );

      await tester.tap(find.byKey(tile));
      await tester.pumpAndSettle();

      verifyNever(
        () => paymentRepository.applyPayment(
          customerPaymentId: any(named: 'customerPaymentId'),
          salesOrder: any(named: 'salesOrder'),
          amount: any(named: 'amount'),
          amountChange: any(named: 'amountChange'),
        ),
      );
    });
  });

  group('redeem tile (spec 056 FR-005, FR-014)', () {
    late MockCreditNoteRepository creditRepository;
    late MockSalesOrderRepository salesOrders;

    const tile = Key('payment_credit_note_redeem_tile');
    const walkIn = 1;

    Sale walkInSale({
      SaleStatus status = SaleStatus.completed,
      String balance = '500.00',
    }) => testSale(status: status, balance: balance, customer: walkIn);

    setUp(() {
      creditRepository = MockCreditNoteRepository();
      salesOrders = MockSalesOrderRepository();
      stubOptions([testOption()]);
      when(
        () => creditRepository.listSpendable(any()),
      ).thenAnswer((_) async => const []);
      when(() => paymentRepository.get(customerPaymentId: 500)).thenAnswer(
        (_) async => CustomerPayment(
          customerPaymentId: 500,
          customerId: walkIn,
          amount: '200.00',
          currency: Currency.mxn,
          methodCode: 0,
          date: DateTime(2026, 9, 29),
          facilityId: 9,
          type: PaymentType.creditNote,
          unapplied: '200.00',
        ),
      );
      when(() => creditRepository.findByPayment(500)).thenAnswer(
        (_) async => CreditNote(
          id: 990,
          customerId: walkIn,
          salesOrderId: 343533,
          customerRefundId: 9605,
          customerPaymentId: 500,
          issued: '200.00',
          remaining: '200.00',
          date: DateTime(2026, 9, 29),
        ),
      );
    });

    Future<ProviderContainer> pumpRedeem(
      WidgetTester tester, {
      Sale? onSale,
      Override? access,
    }) async {
      final target = onSale ?? walkInSale();
      when(
        () => salesOrders.getById(saleId: 42),
      ).thenAnswer((_) async => target);
      final container = await pumpPos(
        tester,
        PaymentMethodGrid(sale: target, facilityId: 9),
        overrides: [
          paymentMethodOptionRepositoryProvider.overrideWithValue(
            optionRepository,
          ),
          customerPaymentOverride(paymentRepository),
          openSessionOverride(),
          fixedPosSale(target),
          salesOrderOverride(salesOrders),
          creditNoteOverride(creditRepository),
          access ?? creditAccessOverride(paymentsRead: true),
        ],
      );
      container.read(paymentControllerProvider.notifier).setAmount('500.00');
      return container;
    }

    testWidgets('shows on a walk-in sale, with its hint', (tester) async {
      await pumpRedeem(tester);

      expect(find.byKey(tile), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(tile),
          matching: find.text(l10n.paymentCreditNoteRedeemTile),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(tile),
          matching: find.text(l10n.paymentCreditNoteRedeemHint),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('payment_credit_note_tile')), findsNothing);
    });

    testWidgets('is absent on a named customer\'s sale', (tester) async {
      await pumpRedeem(
        tester,
        onSale: testSale(status: SaleStatus.completed, balance: '500.00'),
      );

      expect(find.byKey(tile), findsNothing);
    });

    testWidgets('is absent on a cancelled sale (FR-007)', (tester) async {
      await pumpRedeem(
        tester,
        onSale: walkInSale(status: SaleStatus.cancelled),
      );

      expect(find.byKey(tile), findsNothing);
    });

    testWidgets('is absent when nothing is owed (FR-007)', (tester) async {
      await pumpRedeem(
        tester,
        onSale: walkInSale(status: SaleStatus.paid, balance: '0.00'),
      );

      expect(find.byKey(tile), findsNothing);
    });

    testWidgets('needs credit-payments read (FR-014)', (tester) async {
      await pumpRedeem(
        tester,
        access: creditAccessOverride(creditRead: false, paymentsRead: true),
      );

      expect(find.byKey(tile), findsNothing);
    });

    testWidgets('needs customer-payments create (FR-014)', (tester) async {
      await pumpRedeem(
        tester,
        access: creditAccessOverride(paymentsCreate: false, paymentsRead: true),
      );

      expect(find.byKey(tile), findsNothing);
    });

    testWidgets(
      'needs customer-payments read, to look the ticket up (FR-014)',
      (tester) async {
        await pumpRedeem(tester, access: creditAccessOverride());

        expect(find.byKey(tile), findsNothing);
      },
    );

    testWidgets('tile, ticket, confirm: applies that note\'s payment for what '
        'the dialog showed', (tester) async {
      await pumpRedeem(tester);

      await tester.tap(find.byKey(tile));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('credit_note_ticket_input')),
        '500',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('credit_note_ticket_confirm')));
      await tester.pumpAndSettle();

      verify(
        () => paymentRepository.applyPayment(
          customerPaymentId: 500,
          salesOrder: 42,
          amount: '200',
          amountChange: null,
        ),
      ).called(1);
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

    testWidgets('cancelling the dialog applies nothing', (tester) async {
      await pumpRedeem(tester);

      await tester.tap(find.byKey(tile));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.cancelButton));
      await tester.pumpAndSettle();

      verifyNever(
        () => paymentRepository.applyPayment(
          customerPaymentId: any(named: 'customerPaymentId'),
          salesOrder: any(named: 'salesOrder'),
          amount: any(named: 'amount'),
          amountChange: any(named: 'amountChange'),
        ),
      );
    });
  });
}
