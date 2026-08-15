import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_capture_pane.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

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

  testWidgets(
    'a keyed amount survives the pane being torn down and remounted — the '
    'reflow switching between the one-column and two-pane shapes triggers '
    '(spec 025 research R5)',
    (tester) async {
      final container = await pumpPos(
        tester,
        PaymentCapturePane(
          key: const Key('mount_a'),
          sale: testSale(balance: '116.00'),
          enabled: true,
        ),
        overrides: [
          customerPaymentOverride(paymentRepository),
          paymentMethodOptionRepositoryProvider.overrideWithValue(optionRepository),
        ],
      );

      await tester.enterText(
        find.byKey(const Key('payment_amount_field')),
        '250.00',
      );
      await tester.pumpAndSettle();

      // The provider — not the widget's own controller — is the source of
      // truth a layout switch must not lose sight of.
      expect(container.read(paymentControllerProvider).amount, '250.00');

      // A different key on the same container is exactly what switching
      // between the two shapes does to this pane: the old State is
      // disposed and a fresh one is mounted, while the provider underneath
      // keeps its value.
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('es', 'MX'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: PaymentCapturePane(
                key: const Key('mount_b'),
                sale: testSale(balance: '116.00'),
                enabled: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(
        find.byKey(const Key('payment_amount_field')),
      );
      expect(field.controller!.text, '250.00');
    },
  );
}
