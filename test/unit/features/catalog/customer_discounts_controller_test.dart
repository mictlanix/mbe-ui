import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_discount.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_discounts_controller.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

CustomerDiscount _discount(int id, String code) => CustomerDiscount(
  customerDiscountId: id,
  customerId: 1,
  productId: id + 100,
  productCode: code,
  productName: 'Product $code',
  discount: '0.10000000',
);

void main() {
  late MockCustomerRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockCustomerRepository();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [customerRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group('CustomerDiscountsController', () {
    test('returns the discounts in the server\'s order, unsorted '
        '(FR-002)', () async {
      when(() => repository.listDiscounts(customerId: 1)).thenAnswer(
        (_) async => [
          _discount(2, 'AAA-1'),
          _discount(1, 'BBB-2'),
          _discount(3, 'CCC-3'),
        ],
      );

      final result = await container.read(
        customerDiscountsControllerProvider(1).future,
      );

      expect(result.map((d) => d.customerDiscountId), [2, 1, 3]);
    });

    test('is keyed by customer: two customers load separately', () async {
      when(
        () => repository.listDiscounts(customerId: 1),
      ).thenAnswer((_) async => [_discount(1, 'AAA-1')]);
      when(
        () => repository.listDiscounts(customerId: 2),
      ).thenAnswer((_) async => const []);

      final first = await container.read(
        customerDiscountsControllerProvider(1).future,
      );
      final second = await container.read(
        customerDiscountsControllerProvider(2).future,
      );

      expect(first, hasLength(1));
      expect(second, isEmpty);
    });

    test('a repository error surfaces', () async {
      when(
        () => repository.listDiscounts(customerId: 1),
      ).thenThrow(const AppError.server());

      await expectLater(
        container.read(customerDiscountsControllerProvider(1).future),
        throwsA(isA<AppError>()),
      );
    });
  });
}
