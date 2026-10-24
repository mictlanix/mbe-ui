import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_agreement.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_agreement_dialog_controller.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_agreements_controller.dart';

class MockSupplierRepository extends Mock implements SupplierRepository {}

final _existing = SupplierAgreement(
  supplierAgreementId: 7,
  supplierId: 1,
  start: DateTime(2026, 3, 5),
  end: DateTime(2026, 12, 31),
  comment: 'Net 30',
);

void main() {
  late MockSupplierRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockSupplierRepository();
    when(
      () => repository.listAgreements(supplierId: any(named: 'supplierId')),
    ).thenAnswer((_) async => [_existing]);
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [supplierRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  SupplierAgreementDialogController notifierOf([SupplierAgreement? e]) =>
      container.read(supplierAgreementDialogControllerProvider(1, e).notifier);
  SupplierAgreementDialogState stateOf([SupplierAgreement? e]) =>
      container.read(supplierAgreementDialogControllerProvider(1, e));

  group('canSubmit', () {
    test('false until both dates are set', () {
      expect(stateOf().canSubmit, isFalse);
      notifierOf().startChanged(DateTime(2026, 1, 1));
      expect(stateOf().canSubmit, isFalse);
      notifierOf().endChanged(DateTime(2026, 2, 1));
      expect(stateOf().canSubmit, isTrue);
    });

    test('equal dates are valid', () {
      notifierOf()
        ..startChanged(DateTime(2026, 1, 1))
        ..endChanged(DateTime(2026, 1, 1));
      expect(stateOf().canSubmit, isTrue);
      expect(stateOf().endBeforeStart, isFalse);
    });

    test('end before start is invalid', () {
      notifierOf()
        ..startChanged(DateTime(2026, 2, 1))
        ..endChanged(DateTime(2026, 1, 1));
      expect(stateOf().endBeforeStart, isTrue);
      expect(stateOf().canSubmit, isFalse);
    });

    test('a comment over 500 characters is invalid, 500 is valid', () {
      notifierOf()
        ..startChanged(DateTime(2026, 1, 1))
        ..endChanged(DateTime(2026, 2, 1))
        ..commentChanged('a' * 500);
      expect(stateOf().canSubmit, isTrue);
      notifierOf().commentChanged('a' * 501);
      expect(stateOf().canSubmit, isFalse);
    });

    test('an existing agreement starts valid and filled in', () {
      expect(stateOf(_existing).start, _existing.start);
      expect(stateOf(_existing).comment, 'Net 30');
      expect(stateOf(_existing).canSubmit, isTrue);
    });
  });

  group('submit', () {
    test('create sends null for an empty comment, invalidates the list and '
        'finishes', () async {
      when(
        () => repository.createAgreement(
          supplierId: 1,
          start: any(named: 'start'),
          end: any(named: 'end'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => _existing);
      // Keep the list provider alive so an invalidation is observable.
      container.listen(supplierAgreementsControllerProvider(1), (_, _) {});
      await container.read(supplierAgreementsControllerProvider(1).future);
      notifierOf()
        ..startChanged(DateTime(2026, 1, 1))
        ..endChanged(DateTime(2026, 2, 1))
        ..commentChanged('   ');

      await notifierOf().submit();

      verify(
        () => repository.createAgreement(
          supplierId: 1,
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 2, 1),
          comment: null,
        ),
      ).called(1);
      expect(stateOf().done, isTrue);
      await container.read(supplierAgreementsControllerProvider(1).future);
      verify(() => repository.listAgreements(supplierId: 1)).called(2);
    });

    test('update sends the trimmed comment, including an empty one', () async {
      when(
        () => repository.updateAgreement(
          supplierId: 1,
          agreementId: 7,
          start: any(named: 'start'),
          end: any(named: 'end'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => _existing);
      notifierOf(_existing).commentChanged('  ');

      await notifierOf(_existing).submit();

      verify(
        () => repository.updateAgreement(
          supplierId: 1,
          agreementId: 7,
          start: _existing.start,
          end: _existing.end,
          comment: '',
        ),
      ).called(1);
      expect(stateOf(_existing).done, isTrue);
    });

    test('an invalid range never reaches the repository', () async {
      notifierOf()
        ..startChanged(DateTime(2026, 2, 1))
        ..endChanged(DateTime(2026, 1, 1));

      await notifierOf().submit();

      verifyNever(
        () => repository.createAgreement(
          supplierId: any(named: 'supplierId'),
          start: any(named: 'start'),
          end: any(named: 'end'),
          comment: any(named: 'comment'),
        ),
      );
      expect(stateOf().done, isFalse);
    });

    test('a ValidationError maps to fieldErrors by loc.last', () async {
      when(
        () => repository.createAgreement(
          supplierId: 1,
          start: any(named: 'start'),
          end: any(named: 'end'),
          comment: any(named: 'comment'),
        ),
      ).thenThrow(
        const AppError.validation([
          FieldError(loc: ['body', 'end'], msg: 'Bad end', type: 'value_error'),
        ]),
      );
      notifierOf()
        ..startChanged(DateTime(2026, 1, 1))
        ..endChanged(DateTime(2026, 2, 1));

      await notifierOf().submit();

      expect(stateOf().fieldErrors['end'], 'Bad end');
      expect(stateOf().done, isFalse);
      expect(stateOf().submitting, isFalse);
    });

    test('any other error is kept with its server detail', () async {
      when(
        () => repository.createAgreement(
          supplierId: 1,
          start: any(named: 'start'),
          end: any(named: 'end'),
          comment: any(named: 'comment'),
        ),
      ).thenThrow(const AppError.server(message: 'boom'));
      notifierOf()
        ..startChanged(DateTime(2026, 1, 1))
        ..endChanged(DateTime(2026, 2, 1));

      await notifierOf().submit();

      expect(stateOf().error, SupplierAgreementDialogErrorCode.saveFailed);
      expect(stateOf().errorDetail, 'boom');
      expect(stateOf().start, DateTime(2026, 1, 1));
      expect(stateOf().done, isFalse);
    });
  });

  group('delete', () {
    test('deletes, invalidates the list and finishes', () async {
      when(
        () => repository.deleteAgreement(supplierId: 1, agreementId: 7),
      ).thenAnswer((_) async {});
      container.listen(supplierAgreementsControllerProvider(1), (_, _) {});
      await container.read(supplierAgreementsControllerProvider(1).future);

      await notifierOf(_existing).delete();

      verify(
        () => repository.deleteAgreement(supplierId: 1, agreementId: 7),
      ).called(1);
      expect(stateOf(_existing).done, isTrue);
      await container.read(supplierAgreementsControllerProvider(1).future);
      verify(() => repository.listAgreements(supplierId: 1)).called(2);
    });

    test('a failure is kept as deleteFailed', () async {
      when(
        () => repository.deleteAgreement(supplierId: 1, agreementId: 7),
      ).thenThrow(const AppError.server(message: 'conflict'));

      await notifierOf(_existing).delete();

      expect(
        stateOf(_existing).error,
        SupplierAgreementDialogErrorCode.deleteFailed,
      );
      expect(stateOf(_existing).errorDetail, 'conflict');
      expect(stateOf(_existing).done, isFalse);
    });
  });
}
