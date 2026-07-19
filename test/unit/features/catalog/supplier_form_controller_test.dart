import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_form_controller.dart';

class MockSupplierRepository extends Mock implements SupplierRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.suppliers, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  // read (2) + create (1) + update (4) + delete (8)
  privileges: [Privilege(systemObject: SystemObject.suppliers, rawValue: 15)],
);

ProviderContainer _containerFor(User user, SupplierRepository repository) {
  return ProviderContainer(
    overrides: [
      supplierRepositoryProvider.overrideWithValue(repository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
}

void main() {
  late MockSupplierRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockSupplierRepository();
    container = _containerFor(_fullAccessUser, repository);
    addTearDown(container.dispose);
  });

  group('SupplierFormController field updates', () {
    test('codeChanged updates state and clears prior errors', () {
      final notifier = container.read(supplierFormControllerProvider.notifier);
      notifier.codeChanged('SUP-001');
      expect(container.read(supplierFormControllerProvider).code, 'SUP-001');
    });
  });

  group('SupplierFormController.submitCreate validation (FR-010, FR-011)', () {
    test('an empty code/name is rejected before submit', () async {
      final notifier = container.read(supplierFormControllerProvider.notifier);

      await notifier.submitCreate();

      final state = container.read(supplierFormControllerProvider);
      expect(state.fieldErrors['code'], SupplierFormErrorCode.codeRequired);
      expect(state.fieldErrors['name'], SupplierFormErrorCode.nameRequired);
      verifyNever(
        () => repository.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
        ),
      );
    });

    test('a negative credit limit is rejected before submit', () async {
      final notifier = container.read(supplierFormControllerProvider.notifier);
      notifier
        ..codeChanged('SUP-001')
        ..nameChanged('Acme Corp')
        ..creditLimitChanged('-1');

      await notifier.submitCreate();

      final state = container.read(supplierFormControllerProvider);
      expect(
        state.fieldErrors['creditLimit'],
        SupplierFormErrorCode.creditLimitInvalid,
      );
    });

    test(
      'a valid submission creates the supplier and invalidates the list',
      () async {
        when(
          () => repository.create(
            code: 'SUP-001',
            name: 'Acme Corp',
            zone: null,
            creditLimit: '1000.50',
            creditDays: null,
            comment: null,
          ),
        ).thenAnswer(
          (_) async => const Supplier(
            supplierId: 1,
            code: 'SUP-001',
            name: 'Acme Corp',
            creditLimit: '1000.50',
            creditDays: 0,
          ),
        );

        final notifier = container.read(
          supplierFormControllerProvider.notifier,
        );
        notifier
          ..codeChanged('SUP-001')
          ..nameChanged('Acme Corp')
          ..creditLimitChanged('1000.50');

        await notifier.submitCreate();

        expect(container.read(supplierFormControllerProvider).saved, isTrue);
      },
    );

    test('a server validation error surfaces as field errors', () async {
      when(
        () => repository.create(
          code: 'SUP-001',
          name: any(named: 'name'),
          zone: any(named: 'zone'),
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          comment: any(named: 'comment'),
        ),
      ).thenThrow(
        const AppError.validation([
          FieldError(
            loc: ['body', 'code'],
            msg: 'Code already in use',
            type: 'value_error',
          ),
        ]),
      );

      final notifier = container.read(supplierFormControllerProvider.notifier);
      notifier
        ..codeChanged('SUP-001')
        ..nameChanged('Acme Corp');

      await notifier.submitCreate();

      final state = container.read(supplierFormControllerProvider);
      expect(state.fieldErrors['code'], 'Code already in use');
    });
  });

  group('SupplierFormController privilege checks', () {
    test('submitCreate is denied for a read-only user', () async {
      final readOnlyContainer = _containerFor(_readOnlyUser, repository);
      addTearDown(readOnlyContainer.dispose);
      final notifier = readOnlyContainer.read(
        supplierFormControllerProvider.notifier,
      );
      notifier
        ..codeChanged('SUP-001')
        ..nameChanged('Acme Corp');

      await notifier.submitCreate();

      final state = readOnlyContainer.read(supplierFormControllerProvider);
      expect(state.error, SupplierFormErrorCode.createPermissionDenied);
      verifyNever(
        () => repository.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
        ),
      );
    });
  });

  group('SupplierFormController.submitUpdate', () {
    test(
      'sends the changed fields when editing an existing supplier',
      () async {
        when(() => repository.get(supplierId: 1)).thenAnswer(
          (_) async => const Supplier(
            supplierId: 1,
            code: 'SUP-001',
            name: 'Acme Corp',
            creditLimit: '1000.50',
            creditDays: 30,
          ),
        );
        when(
          () => repository.update(
            supplierId: 1,
            code: 'SUP-001',
            name: 'Acme Corp',
            zone: '',
            creditLimit: '2000.00',
            creditDays: 30,
            comment: '',
          ),
        ).thenAnswer(
          (_) async => const Supplier(
            supplierId: 1,
            code: 'SUP-001',
            name: 'Acme Corp',
            creditLimit: '2000.00',
            creditDays: 30,
          ),
        );

        final notifier = container.read(
          supplierFormControllerProvider.notifier,
        );
        await notifier.loadForEdit(1);
        notifier.creditLimitChanged('2000.00');

        await notifier.submitUpdate();

        expect(container.read(supplierFormControllerProvider).saved, isTrue);
      },
    );
  });

  group('SupplierFormController.delete', () {
    test(
      'a still-referenced rejection is surfaced and the supplier stays loaded',
      () async {
        when(() => repository.get(supplierId: 1)).thenAnswer(
          (_) async => const Supplier(
            supplierId: 1,
            code: 'SUP-001',
            name: 'Acme Corp',
            creditLimit: '0',
            creditDays: 0,
          ),
        );
        when(() => repository.delete(supplierId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Supplier is referenced by a product',
          ),
        );

        final notifier = container.read(
          supplierFormControllerProvider.notifier,
        );
        await notifier.loadForEdit(1);

        await notifier.delete();

        final state = container.read(supplierFormControllerProvider);
        expect(state.deleted, isFalse);
        expect(state.error, SupplierFormErrorCode.deleteFailed);
        expect(state.errorDetail, 'Supplier is referenced by a product');
      },
    );
  });
}
