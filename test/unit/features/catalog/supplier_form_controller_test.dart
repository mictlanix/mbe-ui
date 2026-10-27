import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/bank_account.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_form_controller.dart';

class MockSupplierRepository extends Mock implements SupplierRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.suppliers, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  // read (2) + create (1) + update (4) + delete (8)
  privileges: [Privilege(systemObject: SystemObject.suppliers, rawValue: 15)],
);

ProviderContainer _containerFor(User user, SupplierRepository repository) {
  return ProviderContainer(
    retry: (_, _) => null,
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
      final notifier = container.read(
        supplierFormControllerProvider(null).notifier,
      );
      notifier.codeChanged('SUP-001');
      expect(
        container.read(supplierFormControllerProvider(null)).code,
        'SUP-001',
      );
    });
  });

  group('SupplierFormController.submitCreate validation (FR-010, FR-011)', () {
    test('an empty code/name is rejected before submit', () async {
      final notifier = container.read(
        supplierFormControllerProvider(null).notifier,
      );

      await notifier.submitCreate();

      final state = container.read(supplierFormControllerProvider(null));
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
      final notifier = container.read(
        supplierFormControllerProvider(null).notifier,
      );
      notifier
        ..codeChanged('SUP-001')
        ..nameChanged('Acme Corp')
        ..creditLimitChanged('-1');

      await notifier.submitCreate();

      final state = container.read(supplierFormControllerProvider(null));
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
          supplierFormControllerProvider(null).notifier,
        );
        notifier
          ..codeChanged('SUP-001')
          ..nameChanged('Acme Corp')
          ..creditLimitChanged('1000.50');

        await notifier.submitCreate();

        expect(
          container.read(supplierFormControllerProvider(null)).saved,
          isTrue,
        );
        expect(
          container.read(supplierFormControllerProvider(null)).supplierId,
          1,
        );
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

      final notifier = container.read(
        supplierFormControllerProvider(null).notifier,
      );
      notifier
        ..codeChanged('SUP-001')
        ..nameChanged('Acme Corp');

      await notifier.submitCreate();

      final state = container.read(supplierFormControllerProvider(null));
      expect(state.fieldErrors['code'], 'Code already in use');
    });
  });

  group('SupplierFormController privilege checks', () {
    test('submitCreate is denied for a read-only user', () async {
      final readOnlyContainer = _containerFor(_readOnlyUser, repository);
      addTearDown(readOnlyContainer.dispose);
      final notifier = readOnlyContainer.read(
        supplierFormControllerProvider(null).notifier,
      );
      notifier
        ..codeChanged('SUP-001')
        ..nameChanged('Acme Corp');

      await notifier.submitCreate();

      final state = readOnlyContainer.read(
        supplierFormControllerProvider(null),
      );
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
            addressIds: const <int>[],
            contactIds: const <int>[],
            bankAccountIds: const <int>[],
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
          supplierFormControllerProvider(null).notifier,
        );
        await notifier.loadForEdit(1);
        notifier.creditLimitChanged('2000.00');

        await notifier.submitUpdate();

        expect(
          container.read(supplierFormControllerProvider(null)).saved,
          isTrue,
        );
      },
    );
  });

  group('SupplierFormController.loadForEdit', () {
    test('fills the addresses, contacts and bank accounts lists', () async {
      when(() => repository.get(supplierId: 1)).thenAnswer(
        (_) async => const Supplier(
          supplierId: 1,
          code: 'SUP-001',
          name: 'Acme Corp',
          creditLimit: '0',
          creditDays: 0,
          addresses: [
            AddressListItem(
              addressId: 10,
              label: 'Main St 1',
              type: AddressType.fiscal,
            ),
          ],
          contacts: [Contact(contactId: 20, name: 'Ana')],
          bankAccounts: [
            BankAccount(
              bankAccountId: 30,
              bankName: 'BBVA',
              accountNumber: '0123456789',
            ),
          ],
        ),
      );

      await container
          .read(supplierFormControllerProvider(null).notifier)
          .loadForEdit(1);

      final state = container.read(supplierFormControllerProvider(null));
      expect(state.addresses.single.addressId, 10);
      expect(state.contacts.single.contactId, 20);
      expect(state.bankAccounts.single.bankAccountId, 30);
    });
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
          supplierFormControllerProvider(null).notifier,
        );
        await notifier.loadForEdit(1);

        await notifier.delete();

        final state = container.read(supplierFormControllerProvider(null));
        expect(state.deleted, isFalse);
        expect(state.error, SupplierFormErrorCode.deleteFailed);
        expect(state.errorDetail, 'Supplier is referenced by a product');
      },
    );
  });

  group('SupplierFormController linked records (spec 050 FR-005..FR-010)', () {
    const addressA = AddressListItem(
      addressId: 10,
      label: 'Main St 1',
      type: AddressType.fiscal,
    );
    const addressB = AddressListItem(
      addressId: 11,
      label: 'Side St 2',
      type: AddressType.other,
    );
    const contactA = Contact(contactId: 20, name: 'Ana');
    const bankA = BankAccount(
      bankAccountId: 30,
      bankName: 'BBVA',
      accountNumber: '0123456789',
    );
    const linked = Supplier(
      supplierId: 1,
      code: 'SUP-001',
      name: 'Acme Corp',
      creditLimit: '0',
      creditDays: 0,
      addresses: [addressA, addressB],
      contacts: [contactA],
      bankAccounts: [bankA],
    );

    SupplierFormController notifierOf() =>
        container.read(supplierFormControllerProvider(null).notifier);
    SupplierFormState stateOf() =>
        container.read(supplierFormControllerProvider(null));

    test('add de-duplicates by id and remove drops only that record', () {
      notifierOf()
        ..addressAdded(addressA)
        ..addressAdded(addressA)
        ..addressAdded(addressB)
        ..contactAdded(contactA)
        ..contactAdded(contactA)
        ..bankAccountAdded(bankA)
        ..bankAccountAdded(bankA);

      expect(stateOf().addresses, [addressA, addressB]);
      expect(stateOf().contacts, [contactA]);
      expect(stateOf().bankAccounts, [bankA]);

      notifierOf()
        ..addressRemoved(10)
        ..contactRemoved(20)
        ..bankAccountRemoved(30);

      expect(stateOf().addresses, [addressB]);
      expect(stateOf().contacts, isEmpty);
      expect(stateOf().bankAccounts, isEmpty);
    });

    test('a link change clears a prior error', () {
      notifierOf().codeChanged('');
      container.read(supplierFormControllerProvider(null).notifier).state =
          stateOf().copyWith(error: SupplierFormErrorCode.updateFailed);

      notifierOf().addressAdded(addressA);

      expect(stateOf().error, isNull);
    });

    test('submitUpdate sends all three lists, including empty ones', () async {
      when(() => repository.get(supplierId: 1)).thenAnswer((_) async => linked);
      when(
        () => repository.update(
          supplierId: any(named: 'supplierId'),
          code: any(named: 'code'),
          name: any(named: 'name'),
          zone: any(named: 'zone'),
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          comment: any(named: 'comment'),
          addressIds: any(named: 'addressIds'),
          contactIds: any(named: 'contactIds'),
          bankAccountIds: any(named: 'bankAccountIds'),
        ),
      ).thenAnswer((_) async => linked);

      await notifierOf().loadForEdit(1);
      notifierOf()
        ..addressRemoved(11)
        ..contactRemoved(20)
        ..bankAccountRemoved(30);
      await notifierOf().submitUpdate();

      verify(
        () => repository.update(
          supplierId: 1,
          code: 'SUP-001',
          name: 'Acme Corp',
          zone: '',
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          comment: '',
          addressIds: [10],
          contactIds: <int>[],
          bankAccountIds: <int>[],
        ),
      ).called(1);
    });

    test(
      'submitCreate sends non-empty lists and leaves empty ones out',
      () async {
        when(
          () => repository.create(
            code: any(named: 'code'),
            name: any(named: 'name'),
            zone: any(named: 'zone'),
            creditLimit: any(named: 'creditLimit'),
            creditDays: any(named: 'creditDays'),
            comment: any(named: 'comment'),
            addressIds: any(named: 'addressIds'),
            contactIds: any(named: 'contactIds'),
            bankAccountIds: any(named: 'bankAccountIds'),
          ),
        ).thenAnswer((_) async => linked);

        notifierOf()
          ..codeChanged('SUP-001')
          ..nameChanged('Acme Corp')
          ..addressAdded(addressA)
          ..addressAdded(addressB);
        await notifierOf().submitCreate();

        verify(
          () => repository.create(
            code: 'SUP-001',
            name: 'Acme Corp',
            zone: null,
            creditLimit: null,
            creditDays: null,
            comment: null,
            addressIds: [10, 11],
            contactIds: null,
            bankAccountIds: null,
          ),
        ).called(1);
      },
    );

    test('reloading drops pending link changes', () async {
      when(() => repository.get(supplierId: 1)).thenAnswer((_) async => linked);

      await notifierOf().loadForEdit(1);
      notifierOf().addressRemoved(10);
      expect(stateOf().addresses, [addressB]);

      await notifierOf().loadForEdit(1);

      expect(stateOf().addresses, [addressA, addressB]);
    });
  });

  group('SupplierFormController conflicts (spec 050 FR-011, FR-017)', () {
    const addressA = AddressListItem(
      addressId: 10,
      label: 'Main St 1',
      type: AddressType.fiscal,
    );
    const linked = Supplier(
      supplierId: 1,
      code: 'SUP-001',
      name: 'Acme Corp',
      creditLimit: '0',
      creditDays: 0,
      addresses: [addressA],
    );

    SupplierFormController notifierOf() =>
        container.read(supplierFormControllerProvider(null).notifier);
    SupplierFormState stateOf() =>
        container.read(supplierFormControllerProvider(null));

    AppError conflict() =>
        const AppError.server(statusCode: 409, message: 'Conflict detail');

    void stubCreate(Object error) {
      when(
        () => repository.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
          zone: any(named: 'zone'),
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          comment: any(named: 'comment'),
          addressIds: any(named: 'addressIds'),
          contactIds: any(named: 'contactIds'),
          bankAccountIds: any(named: 'bankAccountIds'),
        ),
      ).thenThrow(error);
    }

    void stubUpdate(Object error) {
      when(
        () => repository.update(
          supplierId: any(named: 'supplierId'),
          code: any(named: 'code'),
          name: any(named: 'name'),
          zone: any(named: 'zone'),
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          comment: any(named: 'comment'),
          addressIds: any(named: 'addressIds'),
          contactIds: any(named: 'contactIds'),
          bankAccountIds: any(named: 'bankAccountIds'),
        ),
      ).thenThrow(error);
    }

    test('a 409 on create maps to saveConflict and keeps the form', () async {
      stubCreate(conflict());
      notifierOf()
        ..codeChanged('SUP-001')
        ..nameChanged('Acme Corp')
        ..addressAdded(addressA);

      await notifierOf().submitCreate();

      expect(stateOf().error, SupplierFormErrorCode.saveConflict);
      expect(stateOf().errorDetail, isNull);
      expect(stateOf().submitting, isFalse);
      expect(stateOf().saved, isFalse);
      expect(stateOf().code, 'SUP-001');
      expect(stateOf().name, 'Acme Corp');
      expect(stateOf().addresses, [addressA]);
    });

    test('a 409 on update maps to saveConflict and keeps the form', () async {
      when(() => repository.get(supplierId: 1)).thenAnswer((_) async => linked);
      stubUpdate(conflict());
      await notifierOf().loadForEdit(1);
      notifierOf()
        ..nameChanged('Renamed')
        ..addressRemoved(10);

      await notifierOf().submitUpdate();

      expect(stateOf().error, SupplierFormErrorCode.saveConflict);
      expect(stateOf().errorDetail, isNull);
      expect(stateOf().submitting, isFalse);
      expect(stateOf().saved, isFalse);
      expect(stateOf().name, 'Renamed');
      expect(stateOf().addresses, isEmpty);
    });

    test('a non-409 failure keeps the generic create/update codes', () async {
      const failure = AppError.server(statusCode: 500, message: 'boom');
      stubCreate(failure);
      notifierOf()
        ..codeChanged('SUP-001')
        ..nameChanged('Acme Corp');
      await notifierOf().submitCreate();
      expect(stateOf().error, SupplierFormErrorCode.createFailed);
      expect(stateOf().errorDetail, 'boom');

      when(() => repository.get(supplierId: 1)).thenAnswer((_) async => linked);
      stubUpdate(failure);
      await notifierOf().loadForEdit(1);
      await notifierOf().submitUpdate();
      expect(stateOf().error, SupplierFormErrorCode.updateFailed);
    });

    test('a 409 on delete maps to deleteConflict and keeps the form', () async {
      when(() => repository.get(supplierId: 1)).thenAnswer((_) async => linked);
      when(() => repository.delete(supplierId: 1)).thenThrow(conflict());
      await notifierOf().loadForEdit(1);

      await notifierOf().delete();

      expect(stateOf().error, SupplierFormErrorCode.deleteConflict);
      expect(stateOf().errorDetail, isNull);
      expect(stateOf().submitting, isFalse);
      expect(stateOf().deleted, isFalse);
      expect(stateOf().name, 'Acme Corp');
      expect(stateOf().addresses, [addressA]);
    });
  });
}
