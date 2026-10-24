import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_agreement.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_agreements_controller.dart';

class MockSupplierRepository extends Mock implements SupplierRepository {}

SupplierAgreement _agreement(int id, DateTime start) => SupplierAgreement(
  supplierAgreementId: id,
  supplierId: 1,
  start: start,
  end: DateTime(2030, 1, 1),
);

void main() {
  late MockSupplierRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockSupplierRepository();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [supplierRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group('SupplierAgreementsController', () {
    test('returns the agreements newest start first (FR-016)', () async {
      when(() => repository.listAgreements(supplierId: 1)).thenAnswer(
        (_) async => [
          _agreement(1, DateTime(2024, 1, 1)),
          _agreement(2, DateTime(2026, 1, 1)),
          _agreement(3, DateTime(2025, 1, 1)),
        ],
      );

      final result = await container.read(
        supplierAgreementsControllerProvider(1).future,
      );

      expect(result.map((a) => a.supplierAgreementId), [2, 3, 1]);
    });

    test('a repository error surfaces', () async {
      when(
        () => repository.listAgreements(supplierId: 1),
      ).thenThrow(const AppError.server());

      await expectLater(
        container.read(supplierAgreementsControllerProvider(1).future),
        throwsA(isA<AppError>()),
      );
    });
  });
}
