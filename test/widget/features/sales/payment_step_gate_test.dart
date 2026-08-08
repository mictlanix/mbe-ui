import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_step.dart';

import 'pos_test_harness.dart';

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
        paymentMethodOptionRepositoryProvider.overrideWithValue(optionRepository),
      ],
    );
  }

  FilledButton closeButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byKey(const Key('payment_close_button')));

  group('close gate (FR-049, FR-051)', () {
    testWidgets('disabled while a balance is outstanding on immediate terms', (
      tester,
    ) async {
      await pumpStep(tester, balance: '116.00');
      expect(closeButton(tester).onPressed, isNull);
    });

    testWidgets('enabled once the balance reaches exactly zero', (tester) async {
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

  group('the tender itself', () {
    testWidgets('applying is blocked until an amount and a method are chosen '
        '(FR-046)', (tester) async {
      await pumpStep(tester, balance: '116.00');
      final submit = tester.widget<FilledButton>(
        find.byKey(const Key('payment_submit_button')),
      );
      expect(submit.onPressed, isNull);
    });

    testWidgets('choosing a method and an amount enables applying', (tester) async {
      await pumpStep(tester, balance: '116.00');

      // The facility has no options configured, so the grid falls back to the
      // shared PaymentMethod enum — cash is code 1.
      await tester.tap(find.byKey(const Key('payment_method_1')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('payment_amount_field')), '116.00');
      await tester.pumpAndSettle();

      final submit = tester.widget<FilledButton>(
        find.byKey(const Key('payment_submit_button')),
      );
      expect(submit.onPressed, isNotNull);
    });

    testWidgets('an amount of zero is never submittable', (tester) async {
      await pumpStep(tester, balance: '116.00');

      await tester.tap(find.byKey(const Key('payment_method_1')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('payment_amount_field')), '0');
      await tester.pumpAndSettle();

      final submit = tester.widget<FilledButton>(
        find.byKey(const Key('payment_submit_button')),
      );
      expect(submit.onPressed, isNull);
    });
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
}
