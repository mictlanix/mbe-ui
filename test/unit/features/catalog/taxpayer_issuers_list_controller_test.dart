import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart'
    show FiscalCertificationProvider;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_issuer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_issuer_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_issuers_list_controller.dart';

class MockTaxpayerIssuerRepository extends Mock
    implements TaxpayerIssuerRepository {}

TaxpayerIssuer _issuer(String rfc) => TaxpayerIssuer(
  rfc: rfc,
  name: 'Issuer $rfc',
  provider: FiscalCertificationProvider.number1,
);

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

  group(
    'TaxpayerIssuerFilter.fromQuery (017-ui-consistency-filters FR-017)',
    () {
      test('derives every field from a ListQuery', () {
        final filter = TaxpayerIssuerFilter.fromQuery(
          const ListQuery(search: 'Acme', pageIndex: 2),
        );

        expect(filter.search, 'Acme');
        expect(filter.pageIndex, 2);
      });

      test('defaults from an empty ListQuery', () {
        final filter = TaxpayerIssuerFilter.fromQuery(const ListQuery());

        expect(filter.search, '');
        expect(filter.pageIndex, 0);
      });
    },
  );

  group(
    'TaxpayerIssuersListController (a family keyed by TaxpayerIssuerFilter)',
    () {
      test(
        'build(filter) maps the filter to repository query params and '
        'performs exactly one listDetail call — no per-row get() (FR-026, '
        'SC-006)',
        () async {
          when(
            () => repository.listDetail(search: null, skip: 0, limit: 20),
          ).thenAnswer(
            (_) async => TaxpayerIssuerPage(
              items: [_issuer('XAXX010101000')],
              total: 1,
            ),
          );

          const filter = TaxpayerIssuerFilter();
          final result = await container.read(
            taxpayerIssuersListControllerProvider(filter).future,
          );

          expect(result.items, hasLength(1));
          expect(result.total, 1);
          verify(
            () => repository.listDetail(search: null, skip: 0, limit: 20),
          ).called(1);
          verifyNever(() => repository.get(any()));
        },
      );

      test(
        'a different pageIndex maps to skip = pageIndex * pageSize',
        () async {
          when(
            () => repository.listDetail(search: null, skip: 0, limit: 20),
          ).thenAnswer(
            (_) async => TaxpayerIssuerPage(
              items: [_issuer('AAA010101000')],
              total: 21,
            ),
          );
          when(
            () => repository.listDetail(search: null, skip: 20, limit: 20),
          ).thenAnswer(
            (_) async => TaxpayerIssuerPage(
              items: [_issuer('BBB010101000')],
              total: 21,
            ),
          );

          final page0 = await container.read(
            taxpayerIssuersListControllerProvider(
              const TaxpayerIssuerFilter(),
            ).future,
          );
          final page1 = await container.read(
            taxpayerIssuersListControllerProvider(
              const TaxpayerIssuerFilter(pageIndex: 1),
            ).future,
          );

          expect(page0.items.map((t) => t.rfc), ['AAA010101000']);
          expect(page0.pageIndex, 0);
          expect(page1.items.map((t) => t.rfc), ['BBB010101000']);
          expect(page1.pageIndex, 1);
        },
      );

      test(
        'invalidating the provider re-fetches the SAME page rather than '
        'resetting to page 0 (017-ui-consistency-filters FR-025, research §3)',
        () async {
          const filter = TaxpayerIssuerFilter(pageIndex: 1);
          when(
            () => repository.listDetail(search: null, skip: 20, limit: 20),
          ).thenAnswer(
            (_) async => TaxpayerIssuerPage(
              items: [_issuer('BBB010101000')],
              total: 21,
            ),
          );

          await container.read(
            taxpayerIssuersListControllerProvider(filter).future,
          );

          when(
            () => repository.listDetail(search: null, skip: 20, limit: 20),
          ).thenAnswer(
            (_) async => TaxpayerIssuerPage(
              items: [_issuer('ZZZ010101000')],
              total: 21,
            ),
          );
          container.invalidate(taxpayerIssuersListControllerProvider(filter));

          final refreshed = await container.read(
            taxpayerIssuersListControllerProvider(filter).future,
          );
          expect(refreshed.pageIndex, 1);
          expect(refreshed.items.single.rfc, 'ZZZ010101000');
        },
      );
    },
  );
}
