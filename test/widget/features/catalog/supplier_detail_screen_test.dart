import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/config/app_settings.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/bank_account.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockSupplierRepository extends Mock implements SupplierRepository {}

const _editor = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.suppliers, rawValue: 15)],
);

const _supplier = Supplier(
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
  contacts: [Contact(contactId: 20, name: 'Ana', jobTitle: 'Buyer')],
  bankAccounts: [
    BankAccount(
      bankAccountId: 30,
      bankName: 'BBVA',
      accountNumber: '0123456789',
    ),
  ],
);

/// The supplier's full-screen surface (spec 050, constitution §VI v1.14.0).
void main() {
  late MockSupplierRepository repository;

  setUp(() {
    repository = MockSupplierRepository();
    when(
      () => repository.get(supplierId: 1),
    ).thenAnswer((_) async => _supplier);
    when(
      () => repository.listAgreements(supplierId: 1),
    ).thenAnswer((_) async => const []);
  });

  Future<GoRouter> pumpAt(WidgetTester tester, String location) async {
    await tester.binding.setSurfaceSize(const Size(1280, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final router = GoRouter(
      initialLocation: '/suppliers',
      routes: [
        GoRoute(
          path: '/suppliers',
          builder: (_, _) => const Scaffold(body: Text('suppliers list')),
        ),
        GoRoute(
          path: '/suppliers/new',
          builder: (_, _) => const SupplierDetailScreen(),
        ),
        GoRoute(
          path: '/suppliers/:supplierId',
          builder: (_, state) => SupplierDetailScreen(
            supplierId: int.parse(state.pathParameters['supplierId']!),
            forceReadOnly: state.uri.queryParameters['view'] == 'true',
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          supplierRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(
            AccessControlService(
              AuthState.authenticated(token: 't', user: _editor),
            ),
          ),
          appSettingsProvider.overrideWithValue(
            const AppSettings(
              apiBaseUrl: 'http://test',
              photosBaseUrl: 'http://test',
              posDefaultCustomerId: 1,
              brand: BrandConfig(displayName: 'Test'),
              defaultLocale: Locale('es', 'MX'),
              formatting: FormattingSettings(),
            ),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.push(location);
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('a row click\'s read-only screen is titled "View", and Edit '
      'opens the same supplier editable, titled "Edit"', (tester) async {
    final router = await pumpAt(tester, '/suppliers/1?view=true');

    expect(find.text('View supplier'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byKey(const Key('code_field'))).enabled,
      isFalse,
    );

    await tester.tap(find.byKey(const Key('edit_supplier_button')));
    await tester.pumpAndSettle();

    expect(router.state.uri.toString(), '/suppliers/1');
    expect(find.text('Edit supplier'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byKey(const Key('code_field'))).enabled,
      isTrue,
    );
  });

  testWidgets('create mode is titled "New"', (tester) async {
    await pumpAt(tester, '/suppliers/new');

    expect(find.text('New supplier'), findsOneWidget);
    expect(
      find.byKey(const Key('supplier_agreements_after_save_note')),
      findsOneWidget,
    );
  });

  testWidgets('view mode shows all four sections and their records, with no '
      'controls (FR-018)', (tester) async {
    await pumpAt(tester, '/suppliers/1?view=true');

    for (final key in [
      'supplier_addresses_section',
      'supplier_contacts_section',
      'supplier_bank_accounts_section',
      'supplier_agreements_section',
    ]) {
      expect(find.byKey(Key(key)), findsOneWidget);
    }
    expect(find.text('Main St 1'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Buyer'), findsOneWidget);
    expect(find.text('BBVA · 0123456789'), findsOneWidget);
    expect(find.byIcon(Icons.link_off), findsNothing);
    expect(find.byKey(const Key('add_agreement_button')), findsNothing);
    expect(find.byKey(const Key('save_button')), findsNothing);
  });

  testWidgets('leaving with no edits goes straight back to the list', (
    tester,
  ) async {
    await pumpAt(tester, '/suppliers/1');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('suppliers list'), findsOneWidget);
  });

  testWidgets('leaving with unsaved edits asks first; cancelling stays, '
      'discarding leaves (spec 035 FR-032)', (tester) async {
    await pumpAt(tester, '/suppliers/1');
    await tester.enterText(find.byKey(const Key('zone_field')), 'Norte');
    await tester.pump();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('record_sheet_discard_dialog')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('record_sheet_discard_cancel')));
    await tester.pumpAndSettle();
    expect(find.text('Edit supplier'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('record_sheet_discard_confirm')));
    await tester.pumpAndSettle();
    expect(find.text('suppliers list'), findsOneWidget);
  });

  void stubWrites() {
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
    ).thenAnswer(
      (_) async => _supplier.copyWith(supplierId: 5, code: 'NEW', name: 'New'),
    );
    when(
      () => repository.get(supplierId: 5),
    ).thenAnswer((_) async => _supplier.copyWith(supplierId: 5));
    when(
      () => repository.listAgreements(supplierId: 5),
    ).thenAnswer((_) async => const []);
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
    ).thenAnswer((_) async => _supplier);
  }

  testWidgets('a successful create stays on the screen, reopened in edit mode '
      'at /suppliers/<id> with agreements available (FR-015a)', (tester) async {
    stubWrites();
    final router = await pumpAt(tester, '/suppliers/new');

    await tester.enterText(find.byKey(const Key('code_field')), 'NEW');
    await tester.enterText(find.byKey(const Key('name_field')), 'New');
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();

    expect(router.state.uri.toString(), '/suppliers/5');
    expect(find.text('Edit supplier'), findsOneWidget);
    expect(find.byKey(const Key('add_agreement_button')), findsOneWidget);
    expect(
      find.byKey(const Key('supplier_agreements_after_save_note')),
      findsNothing,
    );
    expect(find.text('suppliers list'), findsNothing);
  });

  testWidgets('a successful update returns to the list', (tester) async {
    stubWrites();
    await pumpAt(tester, '/suppliers/1');

    await tester.enterText(find.byKey(const Key('zone_field')), 'Norte');
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();

    expect(find.text('suppliers list'), findsOneWidget);
  });
}
