import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_recipient_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_recipients_list_controller.dart';

class MockTaxpayerRecipientRepository extends Mock
    implements TaxpayerRecipientRepository {}

TaxpayerRecipientListItem _taxpayer(String id) => TaxpayerRecipientListItem(
  taxpayerRecipientId: id,
  name: 'Taxpayer $id',
  email: 'test@example.com',
);

void main() {
  late MockTaxpayerRecipientRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockTaxpayerRecipientRepository();
    container = ProviderContainer(
      overrides: [
        taxpayerRecipientRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  group(
    'TaxpayerRecipientFilter.fromQuery (017-ui-consistency-filters FR-017)',
    () {
      test('derives every field from a ListQuery', () {
        final filter = TaxpayerRecipientFilter.fromQuery(
          const ListQuery(search: 'Acme', pageIndex: 2),
        );

        expect(filter.search, 'Acme');
        expect(filter.pageIndex, 2);
      });

      test('defaults from an empty ListQuery', () {
        final filter = TaxpayerRecipientFilter.fromQuery(const ListQuery());

        expect(filter.search, '');
        expect(filter.pageIndex, 0);
      });
    },
  );

  group(
    'TaxpayerRecipientsListController (a family keyed by TaxpayerRecipientFilter)',
    () {
      test(
        'build(filter) maps the filter to repository query params',
        () async {
          when(
            () => repository.list(search: null, skip: 0, limit: 20),
          ).thenAnswer(
            (_) async => TaxpayerRecipientPage(
              items: [_taxpayer('XAXX010101000')],
              total: 1,
            ),
          );

          const filter = TaxpayerRecipientFilter();
          final result = await container.read(
            taxpayerRecipientsListControllerProvider(filter).future,
          );

          expect(result.items, hasLength(1));
          expect(result.total, 1);
        },
      );

      test(
        'a different pageIndex maps to skip = pageIndex * pageSize',
        () async {
          when(
            () => repository.list(search: null, skip: 0, limit: 20),
          ).thenAnswer(
            (_) async => TaxpayerRecipientPage(
              items: [_taxpayer('AAA010101000')],
              total: 21,
            ),
          );
          when(
            () => repository.list(search: null, skip: 20, limit: 20),
          ).thenAnswer(
            (_) async => TaxpayerRecipientPage(
              items: [_taxpayer('BBB010101000')],
              total: 21,
            ),
          );

          final page0 = await container.read(
            taxpayerRecipientsListControllerProvider(
              const TaxpayerRecipientFilter(),
            ).future,
          );
          final page1 = await container.read(
            taxpayerRecipientsListControllerProvider(
              const TaxpayerRecipientFilter(pageIndex: 1),
            ).future,
          );

          expect(page0.items.map((t) => t.taxpayerRecipientId), [
            'AAA010101000',
          ]);
          expect(page0.pageIndex, 0);
          expect(page1.items.map((t) => t.taxpayerRecipientId), [
            'BBB010101000',
          ]);
          expect(page1.pageIndex, 1);
        },
      );

      test(
        'invalidating the provider re-fetches the SAME page rather than '
        'resetting to page 0 (017-ui-consistency-filters FR-025, research §3)',
        () async {
          const filter = TaxpayerRecipientFilter(pageIndex: 1);
          when(
            () => repository.list(search: null, skip: 20, limit: 20),
          ).thenAnswer(
            (_) async => TaxpayerRecipientPage(
              items: [_taxpayer('BBB010101000')],
              total: 21,
            ),
          );

          await container.read(
            taxpayerRecipientsListControllerProvider(filter).future,
          );

          when(
            () => repository.list(search: null, skip: 20, limit: 20),
          ).thenAnswer(
            (_) async => TaxpayerRecipientPage(
              items: [_taxpayer('ZZZ010101000')],
              total: 21,
            ),
          );
          container.invalidate(
            taxpayerRecipientsListControllerProvider(filter),
          );

          final refreshed = await container.read(
            taxpayerRecipientsListControllerProvider(filter).future,
          );
          expect(refreshed.pageIndex, 1);
          expect(refreshed.items.single.taxpayerRecipientId, 'ZZZ010101000');
        },
      );
    },
  );
}
