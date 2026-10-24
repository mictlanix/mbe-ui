import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/address_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/bank_account_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/contact_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/bank_account.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_agreement.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/address_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/bank_account_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/contact_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_form.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockSupplierRepository extends Mock implements SupplierRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockContactRepository extends Mock implements ContactRepository {}

class MockBankAccountRepository extends Mock implements BankAccountRepository {}

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
  privileges: [Privilege(systemObject: SystemObject.suppliers, rawValue: 15)],
);

const _existing = Supplier(
  supplierId: 1,
  code: 'SUP-001',
  name: 'Acme Corp',
  creditLimit: '1000.50',
  creditDays: 30,
);

/// Supplier editor who can also read and create every linkable kind.
const _linkingUser = User(
  userId: 'linker',
  email: 'linker@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.suppliers, rawValue: 15),
    Privilege(systemObject: SystemObject.addresses, rawValue: 15),
    Privilege(systemObject: SystemObject.contacts, rawValue: 15),
    Privilege(systemObject: SystemObject.bankAccounts, rawValue: 15),
  ],
);

const _addressA = AddressListItem(
  addressId: 10,
  label: 'Main St 1',
  type: AddressType.fiscal,
);
const _addressB = AddressListItem(
  addressId: 11,
  label: 'Side St 2',
  type: AddressType.other,
);
const _contactA = Contact(contactId: 20, name: 'Ana');
const _bankA = BankAccount(
  bankAccountId: 30,
  bankName: 'BBVA',
  accountNumber: '0123456789',
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockSupplierRepository repository;
  late MockAddressRepository addressRepository;
  late MockContactRepository contactRepository;
  late MockBankAccountRepository bankAccountRepository;

  setUp(() {
    repository = MockSupplierRepository();
    addressRepository = MockAddressRepository();
    contactRepository = MockContactRepository();
    bankAccountRepository = MockBankAccountRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? supplierId,
    bool forceReadOnly = false,
    Supplier supplier = _existing,
    GlobalKey<SupplierFormPanelState>? formKey,
  }) async {
    if (supplierId != null) {
      when(
        () => repository.get(supplierId: supplierId),
      ).thenAnswer((_) async => supplier);
    }

    when(
      () => repository.listAgreements(supplierId: any(named: 'supplierId')),
    ).thenAnswer((_) async => const []);
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(const Size(1024, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          supplierRepositoryProvider.overrideWithValue(repository),
          addressRepositoryProvider.overrideWithValue(addressRepository),
          contactRepositoryProvider.overrideWithValue(contactRepository),
          bankAccountRepositoryProvider.overrideWithValue(
            bankAccountRepository,
          ),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SupplierForm(
              key: formKey,
              supplierId: supplierId,
              forceReadOnly: forceReadOnly,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('create mode', () {
    testWidgets('shows an empty form with Save and no Delete', (tester) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.byKey(const Key('code_field')), findsOneWidget);
      expect(find.byKey(const Key('save_button')), findsOneWidget);
      expect(find.byKey(const Key('delete_supplier_button')), findsNothing);
    });
  });

  group('linked sections (spec 050)', () {
    testWidgets('create mode shows the four sections, with the after-save '
        'note in place of the agreements', (tester) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      for (final key in [
        'supplier_addresses_section',
        'supplier_contacts_section',
        'supplier_bank_accounts_section',
        'supplier_agreements_section',
      ]) {
        expect(find.byKey(Key(key)), findsOneWidget);
      }
      expect(
        find.byKey(const Key('supplier_agreements_after_save_note')),
        findsOneWidget,
      );
    });

    testWidgets('a supplier with no links shows the empty-state messages', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser, supplierId: 1);

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(l10n.supplierAddressesEmpty), findsOneWidget);
      expect(find.text(l10n.supplierContactsEmpty), findsOneWidget);
      expect(find.text(l10n.supplierBankAccountsEmpty), findsOneWidget);
      expect(find.text(l10n.supplierAgreementsEmpty), findsOneWidget);
    });

    testWidgets('linked records show their labels and subtitles, and with no '
        'read/create on the linked kinds there is no picker or New button '
        'but each row can still be unlinked', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        supplierId: 1,
        supplier: _existing.copyWith(
          addresses: const [
            AddressListItem(
              addressId: 10,
              label: 'Main St 1',
              type: AddressType.fiscal,
              status: EntityStatus.inactive,
            ),
          ],
          contacts: const [
            Contact(
              contactId: 20,
              name: 'Ana',
              jobTitle: 'Buyer',
              email: 'ana@example.com',
            ),
          ],
          bankAccounts: const [
            BankAccount(
              bankAccountId: 30,
              bankName: 'BBVA',
              accountNumber: '0123456789',
              reference: 'Main',
            ),
          ],
        ),
      );

      expect(find.text('Main St 1'), findsOneWidget);
      expect(find.byType(EntityStatusCell), findsOneWidget);
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Buyer · ana@example.com'), findsOneWidget);
      expect(find.text('BBVA · 0123456789'), findsOneWidget);
      expect(find.text('Main'), findsOneWidget);
      expect(find.byIcon(Icons.link_off), findsNWidgets(3));
      expect(find.byType(CatalogEntityPicker<Contact>), findsNothing);
      expect(find.byKey(const Key('linked_new_contacts')), findsNothing);
    });
  });

  group('linking and unlinking (spec 050 US2)', () {
    final linkedSupplier = _existing.copyWith(
      addresses: const [_addressA],
      contacts: const [_contactA],
      bankAccounts: const [_bankA],
    );

    void stubUpdate() => when(
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
    ).thenAnswer((_) async => linkedSupplier);

    /// The three id lists sent by the last update, in address, contact,
    /// bank-account order.
    List<List<int>?> capturedLists() {
      final call = verify(
        () => repository.update(
          supplierId: any(named: 'supplierId'),
          code: any(named: 'code'),
          name: any(named: 'name'),
          zone: any(named: 'zone'),
          creditLimit: any(named: 'creditLimit'),
          creditDays: any(named: 'creditDays'),
          comment: any(named: 'comment'),
          addressIds: captureAny(named: 'addressIds'),
          contactIds: captureAny(named: 'contactIds'),
          bankAccountIds: captureAny(named: 'bankAccountIds'),
        ),
      );
      return call.captured.cast<List<int>?>();
    }

    Future<void> searchIn(WidgetTester tester, String section) async {
      await tester.enterText(
        find.descendant(
          of: find.byKey(Key('linked_picker_${section}_0')),
          matching: find.byType(TextFormField),
        ),
        'a',
      );
      await tester.pumpAndSettle();
    }

    testWidgets('linking through the picker adds the row, hides it from the '
        'picker afterwards (FR-009), and Save sends the id', (tester) async {
      stubUpdate();
      when(
        () => addressRepository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
        ),
      ).thenAnswer(
        (_) async =>
            const AddressListResult(items: [_addressA, _addressB], total: 2),
      );
      await pumpScreen(
        tester,
        signedInAs: _linkingUser,
        supplierId: 1,
        supplier: linkedSupplier,
      );

      await searchIn(tester, 'addresses');
      // Main St 1 is already linked: shown in its row only, not as an option.
      expect(find.text('Main St 1'), findsOneWidget);
      await tester.tap(find.text('Side St 2'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('linked_row_addresses_11')), findsOneWidget);

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      expect(capturedLists(), [
        [10, 11],
        [20],
        [30],
      ]);
    });

    testWidgets('adding an agreement through the dialog leaves unsaved edits '
        'and pending links untouched (FR-012, R4)', (tester) async {
      final agreement = SupplierAgreement(
        supplierAgreementId: 7,
        supplierId: 1,
        start: DateTime(2026, 3, 5),
        end: DateTime(2026, 12, 31),
      );
      var agreements = <SupplierAgreement>[];
      when(
        () => repository.createAgreement(
          supplierId: 1,
          start: any(named: 'start'),
          end: any(named: 'end'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async {
        agreements = [agreement];
        return agreement;
      });
      when(
        () => addressRepository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
        ),
      ).thenAnswer(
        (_) async =>
            const AddressListResult(items: [_addressA, _addressB], total: 2),
      );
      final key = GlobalKey<SupplierFormPanelState>();
      await pumpScreen(
        tester,
        signedInAs: _linkingUser,
        supplierId: 1,
        supplier: linkedSupplier,
        formKey: key,
      );
      // After the pump: pumpScreen stubs an empty list of its own.
      when(
        () => repository.listAgreements(supplierId: any(named: 'supplierId')),
      ).thenAnswer((_) async => agreements);
      await searchIn(tester, 'addresses');
      await tester.tap(find.text('Side St 2'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('zone_field')), 'Norte');
      await tester.pump();
      expect(key.currentState!.isDirty(), isTrue);

      await tester.ensureVisible(find.byKey(const Key('add_agreement_button')));
      await tester.tap(find.byKey(const Key('add_agreement_button')));
      await tester.pumpAndSettle();
      for (final field in ['agreement_start_field', 'agreement_end_field']) {
        await tester.tap(find.byKey(Key(field)));
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(field == 'agreement_start_field' ? '5' : '25'),
        );
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const Key('agreement_save_button')));
      await tester.pumpAndSettle();

      verify(
        () => repository.createAgreement(
          supplierId: 1,
          start: any(named: 'start'),
          end: any(named: 'end'),
          comment: null,
        ),
      ).called(1);
      expect(
        find.byKey(const Key('supplier_agreements_table')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('edit_agreement_7')), findsOneWidget);
      expect(find.byKey(const Key('agreement_save_button')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('zone_field')),
          matching: find.text('Norte'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('linked_row_addresses_11')), findsOneWidget);
      expect(key.currentState!.isDirty(), isTrue);
    });

    testWidgets('the address picker only offers active addresses', (
      tester,
    ) async {
      when(
        () => addressRepository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
        ),
      ).thenAnswer(
        (_) async => const AddressListResult(items: [_addressB], total: 1),
      );
      await pumpScreen(
        tester,
        signedInAs: _linkingUser,
        supplierId: 1,
        supplier: linkedSupplier,
      );

      await searchIn(tester, 'addresses');

      verify(
        () => addressRepository.list(search: 'a', status: EntityStatus.active),
      ).called(1);
    });

    testWidgets('unlinking marks the form dirty and Save sends the shorter '
        'list, without deleting the record', (tester) async {
      stubUpdate();
      final key = GlobalKey<SupplierFormPanelState>();
      when(
        () => repository.get(supplierId: 1),
      ).thenAnswer((_) async => linkedSupplier);
      when(
        () => repository.listAgreements(supplierId: any(named: 'supplierId')),
      ).thenAnswer((_) async => const []);
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      await tester.binding.setSurfaceSize(const Size(1024, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            supplierRepositoryProvider.overrideWithValue(repository),
            addressRepositoryProvider.overrideWithValue(addressRepository),
            contactRepositoryProvider.overrideWithValue(contactRepository),
            bankAccountRepositoryProvider.overrideWithValue(
              bankAccountRepository,
            ),
            accessControlProvider.overrideWithValue(_accessFor(_linkingUser)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: SupplierForm(key: key, supplierId: 1)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(key.currentState!.isDirty(), isFalse);

      await tester.tap(find.byKey(const Key('unlink_contacts_20')));
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isTrue);
      expect(find.byKey(const Key('linked_row_contacts_20')), findsNothing);

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      expect(capturedLists(), [
        [10],
        <int>[],
        [30],
      ]);
      verifyNever(
        () => repository.delete(supplierId: any(named: 'supplierId')),
      );
    });

    testWidgets('New contact creates and links it, and a bank account too', (
      tester,
    ) async {
      stubUpdate();
      when(
        () => contactRepository.create(
          name: any(named: 'name'),
          jobTitle: any(named: 'jobTitle'),
          phone: any(named: 'phone'),
          mobile: any(named: 'mobile'),
          email: any(named: 'email'),
        ),
      ).thenAnswer(
        (_) async => const Contact(contactId: 21, name: 'Luis', mobile: '555'),
      );
      when(
        () => bankAccountRepository.create(
          bankName: any(named: 'bankName'),
          accountNumber: any(named: 'accountNumber'),
          reference: any(named: 'reference'),
          routingNumber: any(named: 'routingNumber'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer(
        (_) async => const BankAccount(
          bankAccountId: 31,
          bankName: 'Banorte',
          accountNumber: '999',
        ),
      );
      await pumpScreen(
        tester,
        signedInAs: _linkingUser,
        supplierId: 1,
        supplier: linkedSupplier,
      );

      await tester.tap(find.byKey(const Key('linked_new_contacts')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('contact_name_field')),
        'Luis',
      );
      await tester.enterText(
        find.byKey(const Key('contact_mobile_field')),
        '555',
      );
      await tester.tap(find.byKey(const Key('contact_save_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('linked_row_contacts_21')), findsOneWidget);

      await tester.tap(find.byKey(const Key('linked_new_bank_accounts')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('bank_account_bank_name_field')),
        'Banorte',
      );
      await tester.enterText(
        find.byKey(const Key('bank_account_number_field')),
        '999',
      );
      await tester.tap(find.byKey(const Key('bank_account_save_button')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('linked_row_bank_accounts_31')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      expect(capturedLists(), [
        [10],
        [20, 21],
        [30, 31],
      ]);
    });

    testWidgets('privilege matrix (a): Update but no Read on bank accounts '
        'means no bank-account picker, yet rows stay and can be unlinked '
        '(FR-019)', (tester) async {
      const noBankRead = User(
        userId: 'u',
        email: 'u@example.com',
        administrator: false,
        status: EntityStatus.active,
        sessionVersion: 1,
        privileges: [
          Privilege(systemObject: SystemObject.suppliers, rawValue: 15),
          Privilege(systemObject: SystemObject.addresses, rawValue: 15),
          Privilege(systemObject: SystemObject.contacts, rawValue: 15),
          // create (1) only
          Privilege(systemObject: SystemObject.bankAccounts, rawValue: 1),
        ],
      );
      await pumpScreen(
        tester,
        signedInAs: noBankRead,
        supplierId: 1,
        supplier: linkedSupplier,
      );

      expect(
        find.byKey(const Key('linked_picker_bank_accounts_0')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('linked_picker_addresses_0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('linked_row_bank_accounts_30')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('unlink_bank_accounts_30')), findsOneWidget);

      await tester.tap(find.byKey(const Key('unlink_bank_accounts_30')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('linked_row_bank_accounts_30')),
        findsNothing,
      );
    });

    testWidgets('privilege matrix (b): no Create on contacts means no New '
        'button there, while the other sections keep theirs', (tester) async {
      const noContactCreate = User(
        userId: 'u',
        email: 'u@example.com',
        administrator: false,
        status: EntityStatus.active,
        sessionVersion: 1,
        privileges: [
          Privilege(systemObject: SystemObject.suppliers, rawValue: 15),
          Privilege(systemObject: SystemObject.addresses, rawValue: 15),
          // read (2) only
          Privilege(systemObject: SystemObject.contacts, rawValue: 2),
          Privilege(systemObject: SystemObject.bankAccounts, rawValue: 15),
        ],
      );
      await pumpScreen(
        tester,
        signedInAs: noContactCreate,
        supplierId: 1,
        supplier: linkedSupplier,
      );

      expect(find.byKey(const Key('linked_new_contacts')), findsNothing);
      expect(find.byKey(const Key('linked_picker_contacts_0')), findsOneWidget);
      expect(find.byKey(const Key('linked_new_addresses')), findsOneWidget);
      expect(find.byKey(const Key('linked_new_bank_accounts')), findsOneWidget);
    });

    testWidgets('privilege matrix (c): without Suppliers Update there are no '
        'link controls at all, whatever the linked-kind privileges', (
      tester,
    ) async {
      const readOnlySupplier = User(
        userId: 'u',
        email: 'u@example.com',
        administrator: false,
        status: EntityStatus.active,
        sessionVersion: 1,
        privileges: [
          Privilege(systemObject: SystemObject.suppliers, rawValue: 2),
          Privilege(systemObject: SystemObject.addresses, rawValue: 15),
          Privilege(systemObject: SystemObject.contacts, rawValue: 15),
          Privilege(systemObject: SystemObject.bankAccounts, rawValue: 15),
        ],
      );
      await pumpScreen(
        tester,
        signedInAs: readOnlySupplier,
        supplierId: 1,
        supplier: linkedSupplier,
      );

      expect(find.byKey(const Key('linked_row_addresses_10')), findsOneWidget);
      expect(find.byIcon(Icons.link_off), findsNothing);
      for (final section in ['addresses', 'contacts', 'bank_accounts']) {
        expect(find.byKey(Key('linked_new_$section')), findsNothing);
        expect(find.byKey(Key('linked_picker_${section}_0')), findsNothing);
      }
    });
  });

  group('view mode (forceReadOnly)', () {
    testWidgets(
      'renders fields disabled with no Save/Delete, and the edit toggle '
      'appears in the record action area — this form has no AppBar of its '
      'own at all now (spec 035)',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          supplierId: 1,
          forceReadOnly: true,
        );

        final codeField = tester.widget<TextFormField>(
          find.byKey(const Key('code_field')),
        );
        expect(codeField.enabled, isFalse);
        expect(find.byKey(const Key('save_button')), findsNothing);
        expect(find.byKey(const Key('delete_supplier_button')), findsNothing);
        expect(find.byKey(const Key('edit_supplier_button')), findsOneWidget);

        expect(find.byType(AppBar), findsNothing);
      },
    );
  });

  group('edit mode', () {
    testWidgets('a read-only user sees disabled fields and no Delete', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser, supplierId: 1);

      final codeField = tester.widget<TextFormField>(
        find.byKey(const Key('code_field')),
      );
      expect(codeField.enabled, isFalse);
      expect(find.byKey(const Key('delete_supplier_button')), findsNothing);
    });

    testWidgets(
      'a user with delete privilege sees the Delete button, and confirming '
      'a server rejection leaves the form in place (US1 §6)',
      (tester) async {
        when(() => repository.delete(supplierId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Supplier is referenced by a product',
          ),
        );

        await pumpScreen(tester, signedInAs: _fullAccessUser, supplierId: 1);

        expect(find.byKey(const Key('delete_supplier_button')), findsOneWidget);
        await tester.tap(find.byKey(const Key('delete_supplier_button')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('confirm_delete_supplier_button')),
        );
        await tester.pumpAndSettle();

        // Still in the panel — the form did not pop.
        expect(find.byKey(const Key('code_field')), findsOneWidget);
      },
    );
  });

  group('in-panel Edit toggle (spec 035 FR-027/FR-028)', () {
    testWidgets(
      'pressing Edit on a read-only form makes it editable in place — no '
      'navigation, since there is no route to navigate to anymore',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          supplierId: 1,
          forceReadOnly: true,
        );

        expect(
          tester
              .widget<TextFormField>(find.byKey(const Key('code_field')))
              .enabled,
          isFalse,
        );

        await tester.tap(find.byKey(const Key('edit_supplier_button')));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<TextFormField>(find.byKey(const Key('code_field')))
              .enabled,
          isTrue,
        );
        expect(find.byKey(const Key('save_button')), findsOneWidget);
      },
    );
  });

  group('isDirty (spec 035 FR-032, data-model.md §3)', () {
    testWidgets('false immediately after a create-mode form mounts', (
      tester,
    ) async {
      final key = GlobalKey<SupplierFormPanelState>();
      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            supplierRepositoryProvider.overrideWithValue(repository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: SupplierForm(key: key)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isFalse);
    });

    testWidgets('false until loading finishes, then true after a field edit', (
      tester,
    ) async {
      final key = GlobalKey<SupplierFormPanelState>();
      when(
        () => repository.get(supplierId: 1),
      ).thenAnswer((_) async => _existing);
      when(
        () => repository.listAgreements(supplierId: any(named: 'supplierId')),
      ).thenAnswer((_) async => const []);
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            supplierRepositoryProvider.overrideWithValue(repository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: SupplierForm(key: key, supplierId: 1)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isFalse);

      await tester.enterText(find.byKey(const Key('code_field')), 'SUP-002');
      await tester.pump();

      expect(key.currentState!.isDirty(), isTrue);
    });
  });

  group('conflict banners (spec 050 US4)', () {
    testWidgets('a 409 on Save shows the save-conflict banner and keeps the '
        "user's edits", (tester) async {
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
      ).thenThrow(
        const AppError.server(statusCode: 409, message: 'Server detail'),
      );

      await pumpScreen(tester, signedInAs: _fullAccessUser, supplierId: 1);
      await tester.enterText(find.byKey(const Key('code_field')), 'SUP-002');
      await tester.pump();
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('supplier_save_conflict_banner')),
        findsOneWidget,
      );
      expect(
        find.textContaining('Another supplier already uses that code'),
        findsOneWidget,
      );
      expect(find.text('Server detail'), findsNothing);
      expect(find.text('SUP-002'), findsOneWidget);
    });

    testWidgets('a 409 on Delete shows the delete-conflict banner and keeps '
        'the form', (tester) async {
      when(() => repository.delete(supplierId: 1)).thenThrow(
        const AppError.server(statusCode: 409, message: 'Server detail'),
      );

      await pumpScreen(tester, signedInAs: _fullAccessUser, supplierId: 1);
      await tester.enterText(find.byKey(const Key('name_field')), 'Edited');
      await tester.pump();
      await tester.tap(find.byKey(const Key('delete_supplier_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_delete_supplier_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('supplier_delete_conflict_banner')),
        findsOneWidget,
      );
      expect(
        find.textContaining("This supplier can't be deleted"),
        findsOneWidget,
      );
      expect(find.text('Server detail'), findsNothing);
      expect(find.text('Edited'), findsOneWidget);
    });
  });
}
