import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/merge_products_comparison_provider.dart';

class MockProductRepository extends Mock implements ProductRepository {}

Product _product({required int productId, required String code}) => Product(
  productId: productId,
  code: code,
  name: 'Widget $productId',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Piece',
  taxRate: '0.16',
  taxIncluded: false,
  priceType: 0,
  currency: 0,
  minOrderQty: 1,
  stockable: false,
  perishable: false,
  seriable: false,
  purchasable: false,
  salable: false,
  invoiceable: false,
  stockRequired: false,
  status: EntityStatus.active,
);

ProviderContainer _containerWith(ProductRepository repository) {
  return ProviderContainer(
    overrides: [productRepositoryProvider.overrideWithValue(repository)],
  );
}

void main() {
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
  });

  test('fetches both products and maps them to kept/deleted', () async {
    when(
      () => repository.get(productId: 1),
    ).thenAnswer((_) async => _product(productId: 1, code: 'KEEP'));
    when(
      () => repository.get(productId: 2),
    ).thenAnswer((_) async => _product(productId: 2, code: 'DUP'));

    final container = _containerWith(repository);
    addTearDown(container.dispose);

    final comparison = await container.read(
      mergeComparisonProvider(canonicalId: 1, duplicateId: 2).future,
    );

    // The canonical id is the kept record and the duplicate id the deleted
    // one — the mapping the whole review step's labeling depends on.
    expect(comparison.kept.productId, 1);
    expect(comparison.kept.code, 'KEEP');
    expect(comparison.deleted.productId, 2);
    expect(comparison.deleted.code, 'DUP');
  });

  test(
    'issues both fetches concurrently rather than one after the other',
    () async {
      var inFlight = 0;
      var maxInFlight = 0;

      Future<Product> delayed(int productId) async {
        inFlight++;
        maxInFlight = inFlight > maxInFlight ? inFlight : maxInFlight;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        inFlight--;
        return _product(productId: productId, code: 'C$productId');
      }

      when(() => repository.get(productId: 1)).thenAnswer((_) => delayed(1));
      when(() => repository.get(productId: 2)).thenAnswer((_) => delayed(2));

      final container = _containerWith(repository);
      addTearDown(container.dispose);

      await container.read(
        mergeComparisonProvider(canonicalId: 1, duplicateId: 2).future,
      );

      expect(maxInFlight, 2, reason: 'both gets should overlap (Future.wait)');
    },
  );

  test('surfaces a NotFoundError on either id as an error', () async {
    when(
      () => repository.get(productId: 1),
    ).thenAnswer((_) async => _product(productId: 1, code: 'KEEP'));
    when(
      () => repository.get(productId: 2),
    ).thenThrow(const NotFoundError('Product not found'));

    final container = _containerWith(repository);
    addTearDown(container.dispose);

    await expectLater(
      container.read(
        mergeComparisonProvider(canonicalId: 1, duplicateId: 2).future,
      ),
      throwsA(isA<NotFoundError>()),
    );
  });

  test('re-keys per pair so a swapped selection is a distinct fetch', () async {
    when(
      () => repository.get(productId: 1),
    ).thenAnswer((_) async => _product(productId: 1, code: 'KEEP'));
    when(
      () => repository.get(productId: 2),
    ).thenAnswer((_) async => _product(productId: 2, code: 'DUP'));

    final container = _containerWith(repository);
    addTearDown(container.dispose);

    final original = await container.read(
      mergeComparisonProvider(canonicalId: 1, duplicateId: 2).future,
    );
    final swapped = await container.read(
      mergeComparisonProvider(canonicalId: 2, duplicateId: 1).future,
    );

    expect(original.kept.productId, 1);
    expect(swapped.kept.productId, 2);
    expect(swapped.deleted.productId, 1);
  });
}
