import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
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

  group(
    'PaymentMethodOptionFilter.fromQuery (017-ui-consistency-filters FR-017)',
    () {
      test('derives every field from a ListQuery', () {
        final filter = PaymentMethodOptionFilter.fromQuery(
          const ListQuery(
            search: 'cash',
            pageIndex: 2,
            facets: {
              'facility': ['9'],
              'status': ['inactive'],
            },
          ),
        );

        expect(filter.search, 'cash');
        expect(filter.pageIndex, 2);
        expect(filter.facilityId, 9);
        expect(filter.status, EntityStatus.inactive);
      });

      test('defaults from an empty ListQuery', () {
        final filter = PaymentMethodOptionFilter.fromQuery(const ListQuery());

        expect(filter.search, isEmpty);
        expect(filter.pageIndex, 0);
        expect(filter.facilityId, isNull);
        expect(filter.status, isNull);
      });
    },
  );

  group(
    'PaymentMethodOptionsListController (a family keyed by PaymentMethodOptionFilter)',
    () {
      test('build(filter) maps the current filter to repository query params '
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

        const filter = PaymentMethodOptionFilter();
        final result = await container.read(
          paymentMethodOptionsListControllerProvider(filter).future,
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
        verifyNever(
          () => repository.get(
            paymentMethodOptionId: any(named: 'paymentMethodOptionId'),
          ),
        );
      });

      test(
        'a different pageIndex maps to skip = pageIndex * pageSize',
        () async {
          when(
            () => repository.list(
              search: null,
              facilityId: null,
              status: null,
              skip: 0,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async =>
                PaymentMethodOptionPage(items: [_option(1)], total: 21),
          );
          when(
            () => repository.list(
              search: null,
              facilityId: null,
              status: null,
              skip: 20,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async =>
                PaymentMethodOptionPage(items: [_option(2)], total: 21),
          );

          final page0 = await container.read(
            paymentMethodOptionsListControllerProvider(
              const PaymentMethodOptionFilter(),
            ).future,
          );
          final page1 = await container.read(
            paymentMethodOptionsListControllerProvider(
              const PaymentMethodOptionFilter(pageIndex: 1),
            ).future,
          );

          expect(page0.items.map((o) => o.paymentMethodOptionId), [1]);
          expect(page0.pageIndex, 0);
          expect(page1.items.map((o) => o.paymentMethodOptionId), [2]);
          expect(page1.pageIndex, 1);
        },
      );

      test(
        'invalidating the provider re-fetches the SAME page rather than '
        'resetting to page 0 (017-ui-consistency-filters FR-025, research §3)',
        () async {
          const filter = PaymentMethodOptionFilter(pageIndex: 1);
          when(
            () => repository.list(
              search: null,
              facilityId: null,
              status: null,
              skip: 20,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async =>
                PaymentMethodOptionPage(items: [_option(2)], total: 21),
          );

          await container.read(
            paymentMethodOptionsListControllerProvider(filter).future,
          );

          when(
            () => repository.list(
              search: null,
              facilityId: null,
              status: null,
              skip: 20,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async =>
                PaymentMethodOptionPage(items: [_option(99)], total: 21),
          );
          container.invalidate(
            paymentMethodOptionsListControllerProvider(filter),
          );

          final refreshed = await container.read(
            paymentMethodOptionsListControllerProvider(filter).future,
          );
          expect(refreshed.pageIndex, 1);
          expect(refreshed.items.single.paymentMethodOptionId, 99);
        },
      );
    },
  );
}
