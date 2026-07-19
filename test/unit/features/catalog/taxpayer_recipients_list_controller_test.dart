import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

  group('TaxpayerRecipientSearchController', () {
    test('starts empty', () {
      expect(container.read(taxpayerRecipientSearchControllerProvider), '');
    });

    test('updates on searchChanged', () {
      container
          .read(taxpayerRecipientSearchControllerProvider.notifier)
          .searchChanged('Acme');
      expect(
        container.read(taxpayerRecipientSearchControllerProvider),
        'Acme',
      );
    });
  });

  group('TaxpayerRecipientsListController', () {
    test(
      'build() maps the current search to repository query params',
      () async {
        when(
          () => repository.list(search: null, skip: 0, limit: 20),
        ).thenAnswer(
          (_) async => TaxpayerRecipientPage(
            items: [_taxpayer('XAXX010101000')],
            total: 1,
          ),
        );

        final result = await container.read(
          taxpayerRecipientsListControllerProvider.future,
        );

        expect(result.items, hasLength(1));
        expect(result.total, 1);
      },
    );

    test('goToPage replaces the current page with the requested one', () async {
      when(
        () => repository.list(search: null, skip: 0, limit: 20),
      ).thenAnswer(
        (_) async =>
            TaxpayerRecipientPage(items: [_taxpayer('AAA010101000')], total: 21),
      );
      await container.read(taxpayerRecipientsListControllerProvider.future);

      when(
        () => repository.list(search: null, skip: 20, limit: 20),
      ).thenAnswer(
        (_) async =>
            TaxpayerRecipientPage(items: [_taxpayer('BBB010101000')], total: 21),
      );

      await container
          .read(taxpayerRecipientsListControllerProvider.notifier)
          .goToPage(1);

      final page = container
          .read(taxpayerRecipientsListControllerProvider)
          .value!;
      expect(page.items.map((t) => t.taxpayerRecipientId), ['BBB010101000']);
      expect(page.pageIndex, 1);
    });
  });
}
