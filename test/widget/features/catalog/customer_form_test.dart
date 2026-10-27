import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/address_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/contact_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/address_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/contact_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/employee_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_recipient_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_form.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockPriceListRepository extends Mock implements PriceListRepository {}

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockContactRepository extends Mock implements ContactRepository {}

class MockTaxpayerRecipientRepository extends Mock
    implements TaxpayerRecipientRepository {}

/// Full customer access plus full access to the three linked kinds, so every
/// section control (link existing, New, unlink) is offered.
const _linkingUser = User(
  userId: 'linker',
  email: 'linker@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.customers, rawValue: 15),
    Privilege(systemObject: SystemObject.addresses, rawValue: 15),
    Privilege(systemObject: SystemObject.contacts, rawValue: 15),
    Privilege(systemObject: SystemObject.taxpayerRecipients, rawValue: 15),
  ],
);

const _linked = Customer(
  customerId: 3,
  code: 'CUST-003',
  name: 'Gamma SA',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Retail'),
  status: EntityStatus.active,
  addresses: [
    AddressListItem(
      addressId: 10,
      label: 'Calle 1 #2, Centro',
      type: AddressType.business,
    ),
    AddressListItem(
      addressId: 11,
      label: 'Av. 3 #4, Norte',
      type: AddressType.home,
      status: EntityStatus.inactive,
    ),
  ],
  contacts: [Contact(contactId: 20, name: 'Ana', mobile: '555-0101')],
  taxpayers: [
    TaxpayerRecipient(
      taxpayerRecipientId: 'AAA010101AAA',
      name: 'Gamma SA',
      email: 'a@gamma.mx',
    ),
    TaxpayerRecipient(
      taxpayerRecipientId: 'BBB010101BBB',
      name: 'Gamma Norte SA',
      email: 'b@gamma.mx',
    ),
  ],
);

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

const _existingWithSalesperson = Customer(
  customerId: 1,
  code: 'CUST-001',
  name: 'Acme Corp',
  creditLimit: '1000.50',
  creditDays: 30,
  priceList: PriceListRef(id: 1, name: 'Retail'),
  salesperson: EmployeeRef(id: 2, name: 'Jane Doe'),
  status: EntityStatus.active,
);

const _existingNoSalesperson = Customer(
  customerId: 2,
  code: 'CUST-002',
  name: 'Beta LLC',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Retail'),
  status: EntityStatus.active,
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

/// The Discounts section (spec 052) renders through `formattersProvider`, which
/// needs shared preferences and the app settings.
Future<SharedPreferences> _prefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

AppSettings _testSettings() => AppSettings(
  apiBaseUrl: 'http://test',
  photosBaseUrl: 'http://test',
  posDefaultCustomerId: 1,
  brand: const BrandConfig(displayName: 'Test'),
  defaultLocale: const Locale('es', 'MX'),
  formatting: const FormattingSettings(),
);

void main() {
  late MockCustomerRepository repository;
  late MockPriceListRepository priceListRepository;
  late MockEmployeeRepository employeeRepository;
  late MockAddressRepository addressRepository;
  late MockContactRepository contactRepository;
  late MockTaxpayerRecipientRepository taxpayerRepository;

  setUp(() {
    repository = MockCustomerRepository();
    priceListRepository = MockPriceListRepository();
    employeeRepository = MockEmployeeRepository();
    addressRepository = MockAddressRepository();
    contactRepository = MockContactRepository();
    taxpayerRepository = MockTaxpayerRecipientRepository();
    when(
      () => repository.listDiscounts(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => const []);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? customerId,
    Customer existing = _existingWithSalesperson,
    bool forceReadOnly = false,
    // The deployment's POS default customer; by default an id no fixture
    // uses, so the walk-in rule (FR-021) applies only where a test asks.
    int walkInCustomerId = 999,
  }) async {
    if (customerId != null) {
      when(
        () => repository.get(customerId: customerId),
      ).thenAnswer((_) async => existing);
    }
    // Tall enough for the whole form, linked-record sections included, so
    // every action button is on screen without scrolling.
    await tester.binding.setSurfaceSize(const Size(1024, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final prefs = await _prefs();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          customerRepositoryProvider.overrideWithValue(repository),
          priceListRepositoryProvider.overrideWithValue(priceListRepository),
          employeeRepositoryProvider.overrideWithValue(employeeRepository),
          addressRepositoryProvider.overrideWithValue(addressRepository),
          contactRepositoryProvider.overrideWithValue(contactRepository),
          taxpayerRecipientRepositoryProvider.overrideWithValue(
            taxpayerRepository,
          ),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
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
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CustomerForm(
              customerId: customerId,
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
      expect(find.byKey(const Key('price_list_field')), findsOneWidget);
      expect(find.byKey(const Key('salesperson_field')), findsOneWidget);
      expect(find.byKey(const Key('save_button')), findsOneWidget);
      expect(find.byKey(const Key('delete_customer_button')), findsNothing);
      // Create mode has no customer loaded yet, so the disabled toggle
      // (edit-only) must not render.
      expect(find.byKey(const Key('customer_disabled_switch')), findsNothing);
    });

    // spec 036 FR-013: the two shipping toggles are gone entirely.
    testWidgets('renders no shipping-related toggle', (tester) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.byKey(const Key('shipping_switch')), findsNothing);
      expect(
        find.byKey(const Key('shipping_required_document_switch')),
        findsNothing,
      );
    });

    // spec 036 FR-012: `code` sits immediately after `credit days`, not at
    // the top of the form.
    testWidgets('places code_field after credit_days_field', (tester) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      final creditDaysTop = tester
          .getTopLeft(find.byKey(const Key('credit_days_field')))
          .dy;
      final codeTop = tester.getTopLeft(find.byKey(const Key('code_field'))).dy;
      expect(
        codeTop,
        greaterThanOrEqualTo(creditDaysTop),
        reason: 'code_field must not render above credit_days_field',
      );
    });
  });

  group('view mode (forceReadOnly)', () {
    testWidgets(
      'renders the price-list and salesperson names, with the edit toggle '
      'in the record action area — this form has no AppBar of its own at '
      'all now (spec 035)',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          customerId: 1,
          forceReadOnly: true,
        );

        final priceListField = tester.widget<TextFormField>(
          find.descendant(
            of: find.byKey(const Key('price_list_field')),
            matching: find.byType(TextFormField),
          ),
        );
        expect(priceListField.initialValue, 'Retail');
        final salespersonField = tester.widget<TextFormField>(
          find.descendant(
            of: find.byKey(const Key('salesperson_field')),
            matching: find.byType(TextFormField),
          ),
        );
        expect(salespersonField.initialValue, 'Jane Doe');
        expect(find.byKey(const Key('save_button')), findsNothing);
        expect(find.byKey(const Key('delete_customer_button')), findsNothing);
        expect(find.byKey(const Key('edit_customer_button')), findsOneWidget);

        expect(find.byType(AppBar), findsNothing);
      },
    );

    testWidgets(
      'a customer with no salesperson shows the "none assigned" fallback '
      '(FR-021)',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          customerId: 2,
          existing: _existingNoSalesperson,
          forceReadOnly: true,
        );

        final salespersonField = tester.widget<TextFormField>(
          find.descendant(
            of: find.byKey(const Key('salesperson_field')),
            matching: find.byType(TextFormField),
          ),
        );
        expect(salespersonField.initialValue, 'None assigned');
      },
    );
  });

  group('edit mode', () {
    testWidgets('a read-only user sees disabled fields and no Delete', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser, customerId: 1);

      final codeField = tester.widget<TextFormField>(
        find.byKey(const Key('code_field')),
      );
      expect(codeField.enabled, isFalse);
      expect(find.byKey(const Key('delete_customer_button')), findsNothing);
    });

    testWidgets(
      'a user with delete privilege sees the Delete button, and confirming '
      'a server rejection leaves the form in place',
      (tester) async {
        when(() => repository.delete(customerId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Customer has existing sales orders',
          ),
        );

        await pumpScreen(tester, signedInAs: _fullAccessUser, customerId: 1);

        expect(find.byKey(const Key('delete_customer_button')), findsOneWidget);
        await tester.ensureVisible(
          find.byKey(const Key('delete_customer_button')),
        );
        await tester.tap(find.byKey(const Key('delete_customer_button')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('confirm_delete_customer_button')),
        );
        await tester.pumpAndSettle();

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
          customerId: 1,
          forceReadOnly: true,
        );

        expect(
          tester
              .widget<TextFormField>(find.byKey(const Key('code_field')))
              .enabled,
          isFalse,
        );

        await tester.tap(find.byKey(const Key('edit_customer_button')));
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
      final key = GlobalKey<CustomerFormPanelState>();
      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            customerRepositoryProvider.overrideWithValue(repository),
            priceListRepositoryProvider.overrideWithValue(priceListRepository),
            employeeRepositoryProvider.overrideWithValue(employeeRepository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: CustomerForm(key: key)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isFalse);
    });

    testWidgets('false until loading finishes, then true after a field edit', (
      tester,
    ) async {
      final key = GlobalKey<CustomerFormPanelState>();
      when(
        () => repository.get(customerId: 1),
      ).thenAnswer((_) async => _existingWithSalesperson);

      final prefs = await _prefs();
      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            appSettingsProvider.overrideWithValue(_testSettings()),
            customerRepositoryProvider.overrideWithValue(repository),
            priceListRepositoryProvider.overrideWithValue(priceListRepository),
            employeeRepositoryProvider.overrideWithValue(employeeRepository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: CustomerForm(key: key, customerId: 1)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isFalse);

      await tester.enterText(find.byKey(const Key('code_field')), 'CUST-999');
      await tester.pump();

      expect(key.currentState!.isDirty(), isTrue);
    });
  });

  group('linked records (046-catalog-improvements US1)', () {
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
    ).thenAnswer((_) async => _linked);

    List<dynamic> capturedUpdate() => verify(
      () => repository.update(
        customerId: 3,
        code: any(named: 'code'),
        name: any(named: 'name'),
        priceList: any(named: 'priceList'),
        zone: any(named: 'zone'),
        creditLimit: any(named: 'creditLimit'),
        creditDays: any(named: 'creditDays'),
        salesperson: any(named: 'salesperson'),
        status: any(named: 'status'),
        comment: any(named: 'comment'),
        addresses: captureAny(named: 'addresses'),
        contacts: captureAny(named: 'contacts'),
        taxpayers: captureAny(named: 'taxpayers'),
      ),
    ).captured;

    testWidgets('the three sections list every linked record, and an '
        'inactive address is marked (FR-001)', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _linkingUser,
        customerId: 3,
        existing: _linked,
      );

      expect(
        find.byKey(const Key('customer_addresses_section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('customer_contacts_section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('customer_taxpayers_section')),
        findsOneWidget,
      );
      expect(find.text('Calle 1 #2, Centro'), findsOneWidget);
      expect(find.text('Av. 3 #4, Norte'), findsOneWidget);
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('AAA010101AAA'), findsOneWidget);
      expect(find.text('BBB010101BBB'), findsOneWidget);
      expect(find.byKey(const Key('status_badge_inactive')), findsOneWidget);
      // The old single-RFC picker is gone.
      expect(find.byKey(const Key('taxpayer_field')), findsNothing);
    });

    testWidgets('a read-only view lists the links with no controls '
        '(FR-008)', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _linkingUser,
        customerId: 3,
        existing: _linked,
        forceReadOnly: true,
      );

      expect(find.text('Calle 1 #2, Centro'), findsOneWidget);
      expect(find.byKey(const Key('unlink_addresses_10')), findsNothing);
      expect(find.byKey(const Key('linked_new_addresses')), findsNothing);
      expect(find.byKey(const Key('linked_new_contacts')), findsNothing);
      expect(find.byKey(const Key('linked_new_taxpayers')), findsNothing);
      expect(find.byKey(const Key('linked_picker_addresses_0')), findsNothing);
    });

    testWidgets('without privileges on the linked kinds, "New" and the '
        'search are hidden but unlink still works (FR-008)', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        customerId: 3,
        existing: _linked,
      );

      expect(find.byKey(const Key('linked_new_addresses')), findsNothing);
      expect(find.byKey(const Key('linked_new_contacts')), findsNothing);
      expect(find.byKey(const Key('linked_new_taxpayers')), findsNothing);
      expect(find.byKey(const Key('linked_picker_addresses_0')), findsNothing);
      expect(find.byKey(const Key('unlink_addresses_10')), findsOneWidget);
    });

    testWidgets('with privileges on the linked kinds, "New" and the search '
        'are offered', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _linkingUser,
        customerId: 3,
        existing: _linked,
      );

      expect(find.byKey(const Key('linked_new_addresses')), findsOneWidget);
      expect(find.byKey(const Key('linked_new_contacts')), findsOneWidget);
      expect(find.byKey(const Key('linked_new_taxpayers')), findsOneWidget);
      expect(
        find.byKey(const Key('linked_picker_addresses_0')),
        findsOneWidget,
      );
    });

    testWidgets('saving an unrelated change keeps both RFCs and every other '
        'link (FR-006)', (tester) async {
      stubUpdate();
      await pumpScreen(
        tester,
        signedInAs: _linkingUser,
        customerId: 3,
        existing: _linked,
      );

      await tester.enterText(find.byKey(const Key('zone_field')), 'Norte');
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      expect(capturedUpdate(), [
        [10, 11],
        [20],
        ['AAA010101AAA', 'BBB010101BBB'],
      ]);
    });

    testWidgets('unlinking marks the form dirty and saves the shorter list, '
        'without deleting the record (FR-004/FR-005)', (tester) async {
      stubUpdate();
      final key = GlobalKey<CustomerFormPanelState>();
      when(
        () => repository.get(customerId: 3),
      ).thenAnswer((_) async => _linked);
      await tester.binding.setSurfaceSize(const Size(1024, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final prefs = await _prefs();
      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            appSettingsProvider.overrideWithValue(_testSettings()),
            customerRepositoryProvider.overrideWithValue(repository),
            priceListRepositoryProvider.overrideWithValue(priceListRepository),
            employeeRepositoryProvider.overrideWithValue(employeeRepository),
            addressRepositoryProvider.overrideWithValue(addressRepository),
            contactRepositoryProvider.overrideWithValue(contactRepository),
            taxpayerRecipientRepositoryProvider.overrideWithValue(
              taxpayerRepository,
            ),
            accessControlProvider.overrideWithValue(_accessFor(_linkingUser)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: CustomerForm(key: key, customerId: 3)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(key.currentState!.isDirty(), isFalse);

      await tester.tap(find.byKey(const Key('unlink_taxpayers_AAA010101AAA')));
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isTrue);
      expect(find.text('AAA010101AAA'), findsNothing);

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      expect(capturedUpdate()[2], ['BBB010101BBB']);
      verifyNever(
        () => repository.delete(customerId: any(named: 'customerId')),
      );
    });

    testWidgets('a contact created with "New" survives a failed save, and '
        'the retry links it once without creating it again (spec edge case)', (
      tester,
    ) async {
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
      var attempts = 0;
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
      ).thenAnswer((_) async {
        if (attempts++ == 0) {
          throw const AppError.server(statusCode: 500, message: 'down');
        }
        return _linked;
      });
      await pumpScreen(
        tester,
        signedInAs: _linkingUser,
        customerId: 3,
        existing: _linked,
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
      expect(find.text('Luis'), findsOneWidget);

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();
      expect(find.text('down'), findsOneWidget);
      expect(find.text('Luis'), findsOneWidget);

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      final calls = capturedUpdate();
      // Two saves, each capturing addresses/contacts/taxpayers.
      expect(calls[1], [20, 21]);
      expect(calls[4], [20, 21]);
      verify(
        () => contactRepository.create(
          name: 'Luis',
          jobTitle: any(named: 'jobTitle'),
          phone: any(named: 'phone'),
          mobile: any(named: 'mobile'),
          email: any(named: 'email'),
        ),
      ).called(1);
    });
  });

  testWidgets('the walk-in customer offers nothing to link, keeps its RFC '
      'fixed, says why, and still lets a stray address be unlinked '
      '(046-catalog-improvements FR-021)', (tester) async {
    await pumpScreen(
      tester,
      signedInAs: _linkingUser,
      customerId: 3,
      existing: _linked,
      walkInCustomerId: 3,
    );

    for (final section in ['addresses', 'contacts', 'taxpayers']) {
      expect(find.byKey(Key('linked_new_$section')), findsNothing);
      expect(find.byKey(Key('linked_picker_${section}_0')), findsNothing);
    }
    expect(
      find.byKey(const Key('unlink_taxpayers_AAA010101AAA')),
      findsNothing,
    );
    expect(find.byKey(const Key('unlink_addresses_10')), findsOneWidget);
    expect(
      find.byKey(const Key('customer_generic_taxpayer_note')),
      findsOneWidget,
    );
  });
}
