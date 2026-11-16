import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_batch_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_batch.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_batch_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_batches_controller.dart';

class MockTaxpayerBatchRepository extends Mock
    implements TaxpayerBatchRepository {}

TaxpayerBatch _batch(int id, String series, int typeCode) => TaxpayerBatch(
  taxpayerBatchId: id,
  taxpayer: 'XAXX010101000',
  series: series,
  typeCode: typeCode,
  kind: FiscalDocumentKind.fromCode(typeCode),
  template: const TaxpayerBatchTemplate(name: 'Plantilla'),
  inUse: false,
);

void main() {
  late MockTaxpayerBatchRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockTaxpayerBatchRepository();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        taxpayerBatchRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  test(
    'sorts by document kind, then series, with an unknown kind last',
    () async {
      when(() => repository.listForIssuer('A')).thenAnswer(
        (_) async => [
          _batch(1, 'P', 101),
          _batch(2, 'X', 7),
          _batch(3, 'B', 0),
          _batch(4, 'NC', 100),
          _batch(5, 'A', 0),
          _batch(6, 'EG', 1),
        ],
      );

      final batches = await container.read(
        taxpayerBatchesControllerProvider('A').future,
      );

      expect(
        [for (final b in batches) b.series],
        ['A', 'B', 'EG', 'NC', 'P', 'X'],
      );
    },
  );

  test('series in the same kind and name keep id order', () {
    final sorted = sortTaxpayerBatches([_batch(9, 'A', 0), _batch(3, 'A', 0)]);

    expect([for (final b in sorted) b.taxpayerBatchId], [3, 9]);
  });

  test('does not mutate the list it sorts', () {
    final input = [_batch(2, 'B', 0), _batch(1, 'A', 0)];

    sortTaxpayerBatches(input);

    expect([for (final b in input) b.series], ['B', 'A']);
  });

  test('asks the repository once per issuer and keeps issuers apart', () async {
    when(
      () => repository.listForIssuer('A'),
    ).thenAnswer((_) async => [_batch(1, 'A', 0)]);
    when(
      () => repository.listForIssuer('B'),
    ).thenAnswer((_) async => [_batch(2, 'Z', 0)]);
    container.listen(taxpayerBatchesControllerProvider('A'), (_, _) {});
    container.listen(taxpayerBatchesControllerProvider('B'), (_, _) {});

    final a = await container.read(
      taxpayerBatchesControllerProvider('A').future,
    );
    final b = await container.read(
      taxpayerBatchesControllerProvider('B').future,
    );
    await container.read(taxpayerBatchesControllerProvider('A').future);

    expect(a.single.series, 'A');
    expect(b.single.series, 'Z');
    verify(() => repository.listForIssuer('A')).called(1);
    verify(() => repository.listForIssuer('B')).called(1);
  });

  test('a repository error becomes an error state', () async {
    when(
      () => repository.listForIssuer('A'),
    ).thenAnswer((_) async => throw const AppError.network());
    container.listen(taxpayerBatchesControllerProvider('A'), (_, _) {});

    await expectLater(
      container.read(taxpayerBatchesControllerProvider('A').future),
      throwsA(isA<NetworkError>()),
    );
    expect(
      container.read(taxpayerBatchesControllerProvider('A')).hasError,
      isTrue,
    );
  });
}
