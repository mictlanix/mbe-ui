import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/presentation/capture/customer_bar.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

Customer _customer({String creditLimit = '5000.00'}) => Customer(
  customerId: 7,
  code: 'C-7',
  name: 'PÚBLICO EN GENERAL',
  creditLimit: creditLimit,
  creditDays: 30,
  priceList: const PriceListRef(id: 1, name: 'Mostrador'),
  shipping: true,
  shippingRequiredDocument: false,
  status: EntityStatus.active,
);

void main() {
  late MockCustomerRepository customerRepository;
  late MockCustomerPaymentRepository paymentRepository;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    customerRepository = MockCustomerRepository();
    paymentRepository = MockCustomerPaymentRepository();
    when(
      () => paymentRepository.outstandingBalanceFor(
        customerId: any(named: 'customerId'),
      ),
    ).thenAnswer((_) async => '2091.00');
  });

  Future<void> pumpBar(WidgetTester tester, {Customer? customer}) async {
    when(
      () => customerRepository.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => customer ?? _customer());

    await pumpPos(
      tester,
      CustomerBar(sale: testSale()),
      overrides: [
        customerRepositoryProvider.overrideWithValue(customerRepository),
        customerPaymentRepositoryProvider.overrideWithValue(paymentRepository),
      ],
    );
  }

  group('the customer area (FR-011)', () {
    testWidgets('shows the customer name, credit line and price list', (
      tester,
    ) async {
      await pumpBar(tester);

      expect(find.byKey(const Key('pos_customer_facts')), findsOneWidget);
      expect(find.text('PÚBLICO EN GENERAL'), findsOneWidget);
      expect(find.text(r'$5,000.00'), findsOneWidget);
      expect(find.text('Mostrador'), findsOneWidget);
    });

    testWidgets('shows the outstanding balance, summed from the customer\'s '
        'open orders', (tester) async {
      await pumpBar(tester);
      expect(find.text(r'$2,091.00'), findsOneWidget);
    });

    testWidgets('an unavailable balance leaves the rest of the customer area '
        'intact', (tester) async {
      when(
        () => paymentRepository.outstandingBalanceFor(
          customerId: any(named: 'customerId'),
        ),
      ).thenThrow(Exception('boom'));

      await pumpBar(tester);

      expect(find.text(l10n.posCustomerBalanceLabel), findsNothing);
      expect(find.text('PÚBLICO EN GENERAL'), findsOneWidget);
      expect(find.text('Mostrador'), findsOneWidget);
    });

    testWidgets('a customer with no credit limit reads "sin línea" rather '
        r'than "$0.00"', (tester) async {
      await pumpBar(tester, customer: _customer(creditLimit: '0'));

      expect(find.text(l10n.posCustomerNoCredit), findsOneWidget);
    });

    testWidgets('the sale still opens with its customer preselected in the '
        'picker (FR-011)', (tester) async {
      await pumpBar(tester);
      expect(find.byKey(const Key('pos_customer_picker')), findsOneWidget);
    });

    testWidgets('a customer whose details cannot be read does not block '
        'capture', (tester) async {
      when(
        () => customerRepository.get(customerId: any(named: 'customerId')),
      ).thenThrow(Exception('boom'));

      await pumpPos(
        tester,
        CustomerBar(sale: testSale()),
        overrides: [
          customerRepositoryProvider.overrideWithValue(customerRepository),
          customerPaymentRepositoryProvider.overrideWithValue(paymentRepository),
        ],
      );

      expect(find.byKey(const Key('pos_customer_facts')), findsNothing);
      expect(find.byKey(const Key('pos_customer_picker')), findsOneWidget);
    });
  });
}
