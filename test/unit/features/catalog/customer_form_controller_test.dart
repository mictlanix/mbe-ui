import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/config/app_settings.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_form_controller.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.customers, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.customers, rawValue: 15)],
);

/// [walkInCustomerId] is the deployment's POS default customer. It defaults
/// to an id no fixture uses, so the walk-in rule (FR-021) only applies in the
/// tests that ask for it.
ProviderContainer _containerFor(
  User user,
  CustomerRepository repository, {
  int walkInCustomerId = 999,
}) {
  return ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      appSettingsProvider.overrideWithValue(
        AppSettings(
          apiBaseUrl: 'http://test',
          photosBaseUrl: 'http://test',
          posDefaultCustomerId: walkInCustomerId,
          brand: const BrandConfig(displayName: 'Test'),
          defaultLocale: const Locale('es', 'MX'),
          formatting: const FormattingSettings(),
        ),
      ),
      customerRepositoryProvider.overrideWithValue(repository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
}

Customer _customer({
  EmployeeRef? salesperson,
  List<AddressListItem> addresses = const [],
  List<Contact> contacts = const [],
  List<TaxpayerRecipient> taxpayers = const [],
}) => Customer(
  customerId: 1,
  code: 'CUST-001',
  name: 'Acme Corp',
  creditLimit: '1000.50',
  creditDays: 30,
  priceList: const PriceListRef(id: 1, name: 'Retail'),
  salesperson: salesperson,
  status: EntityStatus.active,
  addresses: addresses,
  contacts: contacts,
  taxpayers: taxpayers,
);

const _address10 = AddressListItem(
  addressId: 10,
  label: 'Calle 1 #2, Centro',
  type: AddressType.business,
);
const _address11 = AddressListItem(
  addressId: 11,
  label: 'Av. 3 #4, Norte',
  type: AddressType.home,
);
const _contact20 = Contact(contactId: 20, name: 'Ana', mobile: '555-0101');
const _rfcA = TaxpayerRecipient(
  taxpayerRecipientId: 'AAA010101AAA',
  name: 'Acme SA',
  email: 'a@acme.mx',
);
const _rfcB = TaxpayerRecipient(
  taxpayerRecipientId: 'BBB010101BBB',
  name: 'Acme Norte SA',
  email: 'b@acme.mx',
);

void main() {
  late MockCustomerRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockCustomerRepository();
    container = _containerFor(_fullAccessUser, repository);
    addTearDown(container.dispose);
  });

  group('CustomerFormController.submitCreate validation (FR-018, FR-019)', () {
    test('name/priceList are required before submit', () async {
      final notifier = container.read(customerFormControllerProvider.notifier);

      await notifier.submitCreate();

      final state = container.read(customerFormControllerProvider);
      expect(state.fieldErrors['name'], CustomerFormErrorCode.nameRequired);
      expect(
        state.fieldErrors['priceList'],
        CustomerFormErrorCode.priceListRequired,
      );
      verifyNever(
        () => repository.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
          priceList: any(named: 'priceList'),
        ),
      );
    });

    test(
      // spec 036 FR-011: `code` is optional — an empty value must not block
      // submission, unlike name/priceList above.
      'code is not required before submit',
      () async {
        final notifier = container.read(
          customerFormControllerProvider.notifier,
        );

        await notifier.submitCreate();

        final state = container.read(customerFormControllerProvider);
        expect(state.fieldErrors.containsKey('code'), isFalse);
      },
    );

    test(
      'a valid submission (with salesperson) creates the customer',
      () async {
        when(
          () => repository.create(
            code: 'CUST-001',
            name: 'Acme Corp',
            priceList: 1,
            zone: null,
            creditLimit: null,
            creditDays: null,
            salesperson: 2,
            comment: null,
          ),
        ).thenAnswer(
          (_) async => _customer(
            salesperson: const EmployeeRef(id: 2, name: 'Jane Doe'),
          ),
        );

        final notifier = container.read(
          customerFormControllerProvider.notifier,
        );
        notifier
          ..codeChanged('CUST-001')
          ..nameChanged('Acme Corp')
          ..priceListSelected(1, 'Retail')
          ..salespersonSelected(2, 'Jane Doe');

        await notifier.submitCreate();

        expect(container.read(customerFormControllerProvider).saved, isTrue);
      },
    );

    test('a negative credit limit is rejected before submit', () async {
      final notifier = container.read(customerFormControllerProvider.notifier);
      notifier
        ..codeChanged('CUST-001')
        ..nameChanged('Acme Corp')
        ..priceListSelected(1, 'Retail')
        ..creditLimitChanged('-1');

      await notifier.submitCreate();

      final state = container.read(customerFormControllerProvider);
      expect(
        state.fieldErrors['creditLimit'],
        CustomerFormErrorCode.creditLimitInvalid,
      );
    });
  });

  group('CustomerFormController privilege checks', () {
    test('submitCreate is denied for a read-only user', () async {
      final readOnlyContainer = _containerFor(_readOnlyUser, repository);
      addTearDown(readOnlyContainer.dispose);
      final notifier = readOnlyContainer.read(
        customerFormControllerProvider.notifier,
      );
      notifier
        ..codeChanged('CUST-001')
        ..nameChanged('Acme Corp')
        ..priceListSelected(1, 'Retail');

      await notifier.submitCreate();

      final state = readOnlyContainer.read(customerFormControllerProvider);
      expect(state.error, CustomerFormErrorCode.createPermissionDenied);
    });
  });

  group('CustomerFormController.loadForEdit', () {
    test(
      'a customer with no salesperson pre-fills an empty display text',
      () async {
        when(
          () => repository.get(customerId: 1),
        ).thenAnswer((_) async => _customer());

        final notifier = container.read(
          customerFormControllerProvider.notifier,
        );
        await notifier.loadForEdit(1);

        final state = container.read(customerFormControllerProvider);
        expect(state.salespersonId, isNull);
        expect(state.salespersonDisplayText, '');
        expect(state.priceListDisplayText, 'Retail');
      },
    );
  });

  group('CustomerFormController.delete', () {
    test(
      'a still-referenced rejection is surfaced and the customer stays loaded',
      () async {
        when(
          () => repository.get(customerId: 1),
        ).thenAnswer((_) async => _customer());
        when(() => repository.delete(customerId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Customer has existing sales orders',
          ),
        );

        final notifier = container.read(
          customerFormControllerProvider.notifier,
        );
        await notifier.loadForEdit(1);

        await notifier.delete();

        final state = container.read(customerFormControllerProvider);
        expect(state.deleted, isFalse);
        expect(state.error, CustomerFormErrorCode.deleteFailed);
        expect(state.errorDetail, 'Customer has existing sales orders');
      },
    );
  });

  group('CustomerFormController linked records (046-catalog-improvements US1)', () {
    void stubUpdate() => when(
      () => repository.update(
        customerId: any(named: 'customerId'),
        code: any(named: 'code'),
        name: any(named: 'name'),
        priceList: any(named: 'priceList'),
        zone: any(named: 'zone'),
        creditLimit: any(named: 'creditLimit'),
        creditDays: any(named: 'creditDays'),
        salesperson: any(named: 'salesperson'),
        status: any(named: 'status'),
        comment: any(named: 'comment'),
        addresses: any(named: 'addresses'),
        contacts: any(named: 'contacts'),
        taxpayers: any(named: 'taxpayers'),
      ),
    ).thenAnswer((_) async => _customer());

    test('loadForEdit seeds all three link lists', () async {
      when(() => repository.get(customerId: 1)).thenAnswer(
        (_) async => _customer(
          addresses: [_address10],
          contacts: [_contact20],
          taxpayers: [_rfcA, _rfcB],
        ),
      );

      await container
          .read(customerFormControllerProvider.notifier)
          .loadForEdit(1);

      final state = container.read(customerFormControllerProvider);
      expect(state.addresses, [_address10]);
      expect(state.contacts, [_contact20]);
      expect(state.taxpayers.map((t) => t.taxpayerRecipientId), [
        'AAA010101AAA',
        'BBB010101BBB',
      ]);
    });

    test('add de-duplicates and remove drops only the named record', () {
      final notifier = container.read(customerFormControllerProvider.notifier);
      notifier
        ..addressAdded(_address10)
        ..addressAdded(_address10)
        ..addressAdded(_address11)
        ..contactAdded(_contact20)
        ..contactAdded(_contact20)
        ..taxpayerAdded(TaxpayerRecipientListItem.fromRecipient(_rfcA))
        ..taxpayerAdded(TaxpayerRecipientListItem.fromRecipient(_rfcA));

      var state = container.read(customerFormControllerProvider);
      expect(state.addresses, [_address10, _address11]);
      expect(state.contacts, [_contact20]);
      expect(state.taxpayers, hasLength(1));

      notifier
        ..addressRemoved(10)
        ..contactRemoved(20)
        ..taxpayerRemoved('AAA010101AAA');
      state = container.read(customerFormControllerProvider);
      expect(state.addresses, [_address11]);
      expect(state.contacts, isEmpty);
      expect(state.taxpayers, isEmpty);
    });

    test('a link change makes the state differ from its loaded snapshot, '
        'which is what marks the form dirty (FR-005)', () async {
      when(
        () => repository.get(customerId: 1),
      ).thenAnswer((_) async => _customer(addresses: [_address10]));
      final notifier = container.read(customerFormControllerProvider.notifier);
      await notifier.loadForEdit(1);
      final loaded = container.read(customerFormControllerProvider);

      notifier.addressAdded(_address11);

      expect(container.read(customerFormControllerProvider), isNot(loaded));
    });

    test('saving an unrelated change keeps every RFC of a multi-RFC customer, '
        'and every other link (FR-006)', () async {
      when(() => repository.get(customerId: 1)).thenAnswer(
        (_) async => _customer(
          addresses: [_address10],
          contacts: [_contact20],
          taxpayers: [_rfcA, _rfcB],
        ),
      );
      stubUpdate();
      final notifier = container.read(customerFormControllerProvider.notifier);
      await notifier.loadForEdit(1);

      notifier.zoneChanged('Norte');
      await notifier.submitUpdate();

      verify(
        () => repository.update(
          customerId: 1,
          code: any(named: 'code'),
          name: any(named: 'name'),
          priceList: any(named: 'priceList'),
          zone: 'Norte',
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          salesperson: any(named: 'salesperson'),
          status: any(named: 'status'),
          comment: any(named: 'comment'),
          addresses: [10],
          contacts: [20],
          taxpayers: ['AAA010101AAA', 'BBB010101BBB'],
        ),
      ).called(1);
    });

    test('unlinking sends the shorter list and never deletes the record '
        'itself (FR-004)', () async {
      when(() => repository.get(customerId: 1)).thenAnswer(
        (_) async => _customer(taxpayers: [_rfcA, _rfcB]),
      );
      stubUpdate();
      final notifier = container.read(customerFormControllerProvider.notifier);
      await notifier.loadForEdit(1);

      notifier.taxpayerRemoved('AAA010101AAA');
      await notifier.submitUpdate();

      final sent = verify(
        () => repository.update(
          customerId: 1,
          code: any(named: 'code'),
          name: any(named: 'name'),
          priceList: any(named: 'priceList'),
          zone: any(named: 'zone'),
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          salesperson: any(named: 'salesperson'),
          status: any(named: 'status'),
          comment: any(named: 'comment'),
          addresses: any(named: 'addresses'),
          contacts: any(named: 'contacts'),
          taxpayers: captureAny(named: 'taxpayers'),
        ),
      ).captured;
      expect(sent.single, ['BBB010101BBB']);
      // The only write is the customer's own link list.
      verifyNever(() => repository.delete(customerId: any(named: 'customerId')));
    });

    test('create sends the links chosen before the first save (FR-007)', () async {
      when(
        () => repository.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
          priceList: any(named: 'priceList'),
          zone: any(named: 'zone'),
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          salesperson: any(named: 'salesperson'),
          comment: any(named: 'comment'),
          addresses: any(named: 'addresses'),
          contacts: any(named: 'contacts'),
          taxpayers: any(named: 'taxpayers'),
        ),
      ).thenAnswer((_) async => _customer());
      final notifier = container.read(customerFormControllerProvider.notifier);
      notifier
        ..nameChanged('Acme Corp')
        ..priceListSelected(1, 'Retail')
        ..addressAdded(_address10)
        ..contactAdded(_contact20)
        ..taxpayerAdded(TaxpayerRecipientListItem.fromRecipient(_rfcA));

      await notifier.submitCreate();

      verify(
        () => repository.create(
          code: any(named: 'code'),
          name: 'Acme Corp',
          priceList: 1,
          zone: any(named: 'zone'),
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          salesperson: any(named: 'salesperson'),
          comment: any(named: 'comment'),
          addresses: [10],
          contacts: [20],
          taxpayers: ['AAA010101AAA'],
        ),
      ).called(1);
    });

    test('the POS single-RFC picker replaces the whole set (research R4)', () {
      final notifier = container.read(customerFormControllerProvider.notifier);
      notifier
        ..taxpayerAdded(TaxpayerRecipientListItem.fromRecipient(_rfcA))
        ..taxpayerAdded(TaxpayerRecipientListItem.fromRecipient(_rfcB))
        ..taxpayerSelected('CCC010101CCC', 'Otra SA');

      final taxpayers = container.read(customerFormControllerProvider).taxpayers;
      expect(taxpayers.map((t) => t.taxpayerRecipientId), ['CCC010101CCC']);

      notifier.taxpayerSelected(null, '');
      expect(container.read(customerFormControllerProvider).taxpayers, isEmpty);
    });
  });
  group('the walk-in customer (046-catalog-improvements FR-021)', () {
    late ProviderContainer walkIn;

    setUp(() {
      walkIn = _containerFor(_fullAccessUser, repository, walkInCustomerId: 1);
      addTearDown(walkIn.dispose);
      when(() => repository.get(customerId: 1)).thenAnswer(
        (_) async =>
            _customer(addresses: [_address10], taxpayers: [_rfcA, _rfcB]),
      );
      when(
        () => repository.update(
          customerId: any(named: 'customerId'),
          code: any(named: 'code'),
          name: any(named: 'name'),
          priceList: any(named: 'priceList'),
          zone: any(named: 'zone'),
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          salesperson: any(named: 'salesperson'),
          status: any(named: 'status'),
          comment: any(named: 'comment'),
          addresses: any(named: 'addresses'),
          contacts: any(named: 'contacts'),
          taxpayers: any(named: 'taxpayers'),
        ),
      ).thenAnswer((_) async => _customer());
    });

    test(
      'nothing can be linked to it, and its RFCs cannot be removed',
      () async {
        final notifier = walkIn.read(customerFormControllerProvider.notifier);
        await notifier.loadForEdit(1);
        expect(notifier.isGenericCustomer, isTrue);

        notifier
          ..addressAdded(_address11)
          ..contactAdded(_contact20)
          ..taxpayerAdded(TaxpayerRecipientListItem.fromRecipient(_rfcB))
          ..taxpayerRemoved('AAA010101AAA');

        final state = walkIn.read(customerFormControllerProvider);
        expect(state.addresses, [_address10]);
        expect(state.contacts, isEmpty);
        expect(state.taxpayers, hasLength(2));
      },
    );

    test('a stray address can still be unlinked', () async {
      final notifier = walkIn.read(customerFormControllerProvider.notifier);
      await notifier.loadForEdit(1);

      notifier.addressRemoved(10);

      expect(walkIn.read(customerFormControllerProvider).addresses, isEmpty);
    });

    test(
      'saving always sends the generic RFC alone, correcting any other',
      () async {
        final notifier = walkIn.read(customerFormControllerProvider.notifier);
        await notifier.loadForEdit(1);

        await notifier.submitUpdate();

        final sent = verify(
          () => repository.update(
            customerId: 1,
            code: any(named: 'code'),
            name: any(named: 'name'),
            priceList: any(named: 'priceList'),
            zone: any(named: 'zone'),
            creditLimit: any(named: 'creditLimit'),
            creditDays: any(named: 'creditDays'),
            salesperson: any(named: 'salesperson'),
            status: any(named: 'status'),
            comment: any(named: 'comment'),
            addresses: any(named: 'addresses'),
            contacts: any(named: 'contacts'),
            taxpayers: captureAny(named: 'taxpayers'),
          ),
        ).captured;
        expect(sent.single, [genericTaxpayerRfc]);
      },
    );

    test('any other customer is not affected', () async {
      final notifier = container.read(customerFormControllerProvider.notifier);
      await notifier.loadForEdit(1);

      expect(notifier.isGenericCustomer, isFalse);
    });
  });
}
