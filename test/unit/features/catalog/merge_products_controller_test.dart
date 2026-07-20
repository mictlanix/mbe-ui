import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/merge_products_controller.dart';
import 'package:mbe_ui/features/catalog/presentation/merge_products_state.dart';

class MockProductRepository extends Mock implements ProductRepository {}

const _canonical = ProductListItem(
  productId: 1,
  code: 'SKU-001',
  name: 'Widget',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Piece',
  taxRate: '0.16',
  status: EntityStatus.active,
);

const _duplicate = ProductListItem(
  productId: 2,
  code: 'SKU-002',
  name: 'Widget (dup)',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Piece',
  taxRate: '0.16',
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

  group('selection transitions', () {
    test('canonicalSelected/duplicateSelected set the fields', () {
      final container = _containerWith(repository);
      addTearDown(container.dispose);
      final controller = container.read(
        mergeProductsControllerProvider.notifier,
      );

      controller.canonicalSelected(_canonical);
      controller.duplicateSelected(_duplicate);

      final state = container.read(mergeProductsControllerProvider);
      expect(state.canonical, _canonical);
      expect(state.duplicate, _duplicate);
    });

    test('canonicalCleared/duplicateCleared reset the fields', () {
      final container = _containerWith(repository);
      addTearDown(container.dispose);
      final controller = container.read(
        mergeProductsControllerProvider.notifier,
      );

      controller.canonicalSelected(_canonical);
      controller.duplicateSelected(_duplicate);
      controller.canonicalCleared();
      controller.duplicateCleared();

      final state = container.read(mergeProductsControllerProvider);
      expect(state.canonical, isNull);
      expect(state.duplicate, isNull);
    });
  });

  group('canSubmit / validation rules', () {
    test('cannot submit with no selections', () {
      final container = _containerWith(repository);
      addTearDown(container.dispose);
      final state = container.read(mergeProductsControllerProvider);

      expect(state.canSubmit, isFalse);
      expect(state.validationMessageCode, MergeValidationCode.bothRequired);
    });

    test('cannot submit with only one selection', () {
      final container = _containerWith(repository);
      addTearDown(container.dispose);
      final controller = container.read(
        mergeProductsControllerProvider.notifier,
      );

      controller.canonicalSelected(_canonical);

      final state = container.read(mergeProductsControllerProvider);
      expect(state.canSubmit, isFalse);
      expect(state.validationMessageCode, MergeValidationCode.bothRequired);
    });

    test('cannot submit when both selections are the same product', () {
      final container = _containerWith(repository);
      addTearDown(container.dispose);
      final controller = container.read(
        mergeProductsControllerProvider.notifier,
      );

      controller.canonicalSelected(_canonical);
      controller.duplicateSelected(_canonical);

      final state = container.read(mergeProductsControllerProvider);
      expect(state.canSubmit, isFalse);
      expect(state.validationMessageCode, MergeValidationCode.sameProduct);
    });

    test('can submit with two distinct selections', () {
      final container = _containerWith(repository);
      addTearDown(container.dispose);
      final controller = container.read(
        mergeProductsControllerProvider.notifier,
      );

      controller.canonicalSelected(_canonical);
      controller.duplicateSelected(_duplicate);

      final state = container.read(mergeProductsControllerProvider);
      expect(state.canSubmit, isTrue);
      expect(state.validationMessageCode, isNull);
    });
  });

  group('submit', () {
    test('calls mergeProducts with the selected ids and ends in AsyncData '
        'on success', () async {
      when(
        () => repository.mergeProducts(
          productId: any(named: 'productId'),
          duplicateId: any(named: 'duplicateId'),
        ),
      ).thenAnswer((_) async {});
      final container = _containerWith(repository);
      addTearDown(container.dispose);
      final controller = container.read(
        mergeProductsControllerProvider.notifier,
      );
      controller.canonicalSelected(_canonical);
      controller.duplicateSelected(_duplicate);

      await controller.submit();

      verify(
        () => repository.mergeProducts(productId: 1, duplicateId: 2),
      ).called(1);
      final state = container.read(mergeProductsControllerProvider);
      expect(state.submission.hasValue, isTrue);
      expect(state.submission.isLoading, isFalse);
    });

    test(
      'preserves both selections and surfaces the error on failure',
      () async {
        when(
          () => repository.mergeProducts(
            productId: any(named: 'productId'),
            duplicateId: any(named: 'duplicateId'),
          ),
        ).thenThrow(const AppError.notFound('Duplicate product not found'));
        final container = _containerWith(repository);
        addTearDown(container.dispose);
        final controller = container.read(
          mergeProductsControllerProvider.notifier,
        );
        controller.canonicalSelected(_canonical);
        controller.duplicateSelected(_duplicate);

        await controller.submit();

        final state = container.read(mergeProductsControllerProvider);
        expect(state.canonical, _canonical);
        expect(state.duplicate, _duplicate);
        expect(state.submission.hasError, isTrue);
        expect(state.submission.error, isA<NotFoundError>());
      },
    );

    test('no-ops when canSubmit is false (e.g. missing selection)', () async {
      final container = _containerWith(repository);
      addTearDown(container.dispose);
      final controller = container.read(
        mergeProductsControllerProvider.notifier,
      );
      controller.canonicalSelected(_canonical);

      await controller.submit();

      verifyNever(
        () => repository.mergeProducts(
          productId: any(named: 'productId'),
          duplicateId: any(named: 'duplicateId'),
        ),
      );
    });
  });
}
