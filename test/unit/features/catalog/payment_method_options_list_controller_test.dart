import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/payment_method_options_list_controller.dart';

class MockPaymentMethodOptionRepository extends Mock
    implements PaymentMethodOptionRepository {}

PaymentMethodOption _option(int id) => PaymentMethodOption(
  paymentMethodOptionId: id,
  facilityId: 9,
  facilityName: 'Main Store',
  name: 'Option $id',
  numberOfPayments: 1,
  displayOnTicket: true,
  paymentMethod: 1,
  status: EntityStatus.active,
);

void main() {
  late MockPaymentMethodOptionRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockPaymentMethodOptionRepository();
    container = ProviderContainer(
      overrides: [
        paymentMethodOptionRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  group('PaymentMethodOptionFilterController', () {
    test('starts with no facets and empty search', () {
      final filter = container.read(paymentMethodOptionFilterControllerProvider);
      expect(filter.facilityId, isNull);
      expect(filter.status, isNull);
      expect(filter.search, isEmpty);
    });

    test('reset clears facets but preserves search', () {
      final controller = container.read(
        paymentMethodOptionFilterControllerProvider.notifier,
      );
      controller
        ..searchChanged('cash')
        ..facilitySelected(9, 'Main Store')
        ..statusChanged(EntityStatus.inactive);

      controller.reset();

      final filter = container.read(paymentMethodOptionFilterControllerProvider);
      expect(filter.search, 'cash');
      expect(filter.facilityId, isNull);
      expect(filter.status, isNull);
    });
  });

  group('PaymentMethodOptionsListController', () {
    test('build() maps the current filter to repository query params '
        'and performs exactly one list call (FR-026, SC-006)', () async {
      when(
        () => repository.list(
          search: null,
          facilityId: null,
          status: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => PaymentMethodOptionPage(items: [_option(1)], total: 1),
      );

      final result = await container.read(
        paymentMethodOptionsListControllerProvider.future,
      );

      expect(result.items, hasLength(1));
      expect(result.total, 1);
      verify(
        () => repository.list(
          search: null,
          facilityId: null,
          status: null,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
      // No per-row lookup: only the one list() call above touched the
      // repository — no get() for any row.
      verifyNever(() => repository.get(paymentMethodOptionId: any(named: 'paymentMethodOptionId')));
    });

    test('goToPage replaces the current page with the requested one', () async {
      when(
        () => repository.list(
          search: null,
          facilityId: null,
          status: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => PaymentMethodOptionPage(items: [_option(1)], total: 21),
      );
      await container.read(paymentMethodOptionsListControllerProvider.future);

      when(
        () => repository.list(
          search: null,
          facilityId: null,
          status: null,
          skip: 20,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => PaymentMethodOptionPage(items: [_option(2)], total: 21),
      );

      await container
          .read(paymentMethodOptionsListControllerProvider.notifier)
          .goToPage(1);

      final page = container
          .read(paymentMethodOptionsListControllerProvider)
          .value!;
      expect(page.items.map((o) => o.paymentMethodOptionId), [2]);
      expect(page.pageIndex, 1);
    });
  });
}
