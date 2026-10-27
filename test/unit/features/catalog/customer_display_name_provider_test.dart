import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockPaymentMethodOptionRepository extends Mock
    implements PaymentMethodOptionRepository {}

/// Spec 054 FR-018, R2/R3: name lookups never throw — a failed one is `null`
/// and the caller falls back to the bare number.
void main() {
  late MockCustomerRepository customers;
  late MockPaymentMethodOptionRepository options;
  late ProviderContainer container;

  setUp(() {
    customers = MockCustomerRepository();
    options = MockPaymentMethodOptionRepository();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        customerRepositoryProvider.overrideWithValue(customers),
        paymentMethodOptionRepositoryProvider.overrideWithValue(options),
      ],
    );
    addTearDown(container.dispose);
  });

  group('customerDisplayNameProvider', () {
    test('returns the customer\'s name', () async {
      when(() => customers.get(customerId: 7)).thenAnswer(
        (_) async => const Customer(
          customerId: 7,
          code: 'C-7',
          name: 'Aceros del Bajío',
          creditLimit: '0',
          creditDays: 0,
          priceList: PriceListRef(id: 1, name: 'General'),
          status: EntityStatus.active,
        ),
      );

      expect(
        await container.read(customerDisplayNameProvider(7).future),
        'Aceros del Bajío',
      );
    });

    test('is null when the lookup fails (404, no Customers read)', () async {
      when(
        () => customers.get(customerId: 7),
      ).thenThrow(const AppError.notFound());

      expect(
        await container.read(customerDisplayNameProvider(7).future),
        isNull,
      );
    });
  });

  group('paymentMethodOptionNameProvider', () {
    test('returns the option\'s name', () async {
      when(() => options.get(paymentMethodOptionId: 3)).thenAnswer(
        (_) async => const PaymentMethodOption(
          paymentMethodOptionId: 3,
          facilityId: 9,
          facilityName: 'Main Store',
          name: '3 MSI',
          numberOfPayments: 3,
          displayOnTicket: true,
          paymentMethod: 4,
          status: EntityStatus.active,
        ),
      );

      expect(
        await container.read(paymentMethodOptionNameProvider(3).future),
        '3 MSI',
      );
    });

    test('is null when the option was removed or the lookup fails', () async {
      when(
        () => options.get(paymentMethodOptionId: 3),
      ).thenThrow(const AppError.notFound());

      expect(
        await container.read(paymentMethodOptionNameProvider(3).future),
        isNull,
      );
    });
  });
}
