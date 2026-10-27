import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
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
}
