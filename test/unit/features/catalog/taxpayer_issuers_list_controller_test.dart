import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_issuer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_issuer_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_issuers_list_controller.dart';

class MockTaxpayerIssuerRepository extends Mock
    implements TaxpayerIssuerRepository {}

TaxpayerIssuerListItem _issuer(String rfc) =>
    TaxpayerIssuerListItem(rfc: rfc, name: 'Issuer $rfc');

void main() {
  late MockTaxpayerIssuerRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockTaxpayerIssuerRepository();
    container = ProviderContainer(
      overrides: [
        taxpayerIssuerRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  group('TaxpayerIssuerSearchController', () {
    test('starts empty', () {
      expect(container.read(taxpayerIssuerSearchControllerProvider), '');
    });

    test('updates on searchChanged', () {
      container
          .read(taxpayerIssuerSearchControllerProvider.notifier)
          .searchChanged('Acme');
      expect(container.read(taxpayerIssuerSearchControllerProvider), 'Acme');
    });
  });

  group('TaxpayerIssuersListController', () {
    test('build() maps the current search to repository query params and '
        'performs exactly one list call — no per-row get() (FR-026, SC-006)', () async {
      when(
        () => repository.list(search: null, skip: 0, limit: 20),
      ).thenAnswer(
        (_) async => TaxpayerIssuerListResult(
          items: [_issuer('XAXX010101000')],
          total: 1,
        ),
      );

      final result = await container.read(
        taxpayerIssuersListControllerProvider.future,
      );

      expect(result.items, hasLength(1));
      expect(result.total, 1);
      verify(() => repository.list(search: null, skip: 0, limit: 20)).called(1);
      verifyNever(() => repository.get(any()));
    });

    test('goToPage replaces the current page with the requested one', () async {
      when(
        () => repository.list(search: null, skip: 0, limit: 20),
      ).thenAnswer(
        (_) async => TaxpayerIssuerListResult(
          items: [_issuer('AAA010101000')],
          total: 21,
        ),
      );
      await container.read(taxpayerIssuersListControllerProvider.future);

      when(
        () => repository.list(search: null, skip: 20, limit: 20),
      ).thenAnswer(
        (_) async => TaxpayerIssuerListResult(
          items: [_issuer('BBB010101000')],
          total: 21,
        ),
      );

      await container
          .read(taxpayerIssuersListControllerProvider.notifier)
          .goToPage(1);

      final page = container.read(taxpayerIssuersListControllerProvider).value!;
      expect(page.items.map((t) => t.rfc), ['BBB010101000']);
      expect(page.pageIndex, 1);
    });
  });
}
