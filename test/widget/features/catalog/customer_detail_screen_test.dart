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
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/config/app_settings.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_discount.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

const _editor = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.customers, rawValue: 15)],
);

// Adding a discount (spec 052) also needs Read on products.
const _editorWithProducts = User(
  userId: 'editor-products',
  email: 'editor-products@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.customers, rawValue: 15),
    Privilege(systemObject: SystemObject.products, rawValue: 2),
  ],
);

const _customer = Customer(
  customerId: 1,
  code: 'CUST-001',
  name: 'Acme Corp',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Retail'),
  status: EntityStatus.active,
);

/// The customer's full-screen surface (046-catalog-improvements,
/// constitution §VI v1.13.3).
void main() {
  late MockCustomerRepository repository;

  setUp(() {
    repository = MockCustomerRepository();
    when(
      () => repository.get(customerId: 1),
    ).thenAnswer((_) async => _customer);
    when(
      () => repository.listDiscounts(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => const []);
  });

  Future<GoRouter> pumpAt(
    WidgetTester tester,
    String location, {
    User user = _editor,
  }) async {
    await tester.binding.setSurfaceSize(const Size(1280, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = GoRouter(
      initialLocation: '/customers',
      routes: [
        GoRoute(
          path: '/customers',
          builder: (_, _) => const Scaffold(body: Text('customers list')),
        ),
        GoRoute(
          path: '/customers/new',
          builder: (_, _) => const CustomerDetailScreen(),
        ),
        GoRoute(
          path: '/customers/:customerId',
          builder: (_, state) => CustomerDetailScreen(
            customerId: int.parse(state.pathParameters['customerId']!),
            forceReadOnly: state.uri.queryParameters['view'] == 'true',
          ),
        ),
      ],
    );
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          // The Discounts section renders through `formattersProvider`.
          sharedPreferencesProvider.overrideWithValue(prefs),
          appSettingsProvider.overrideWithValue(
            AppSettings(
              apiBaseUrl: 'http://test',
              photosBaseUrl: 'http://test',
              posDefaultCustomerId: 1,
              brand: const BrandConfig(displayName: 'Test'),
              defaultLocale: const Locale('es', 'MX'),
              formatting: const FormattingSettings(),
            ),
          ),
          customerRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(
            AccessControlService(
              AuthState.authenticated(token: 't', user: user),
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
      'opens the same customer editable, titled "Edit"', (tester) async {
    final router = await pumpAt(tester, '/customers/1?view=true');

    expect(find.text('View customer'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byKey(const Key('code_field'))).enabled,
      isFalse,
    );

    await tester.tap(find.byKey(const Key('edit_customer_button')));
    await tester.pumpAndSettle();

    expect(router.state.uri.toString(), '/customers/1');
    expect(find.text('Edit customer'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byKey(const Key('code_field'))).enabled,
      isTrue,
    );
  });

  testWidgets('create mode is titled "New"', (tester) async {
    await pumpAt(tester, '/customers/new');

    expect(find.text('New customer'), findsOneWidget);
  });

  testWidgets('an existing customer shows the Discounts section below the '
      'Taxpayers section (spec 052 FR-001)', (tester) async {
    await pumpAt(tester, '/customers/1');

    final taxpayers = find.byKey(const Key('customer_taxpayers_section'));
    final discounts = find.byKey(const Key('customer_discounts_section'));
    expect(discounts, findsOneWidget);
    expect(
      tester.getTopLeft(discounts).dy,
      greaterThan(tester.getBottomLeft(taxpayers).dy),
    );
    verify(() => repository.listDiscounts(customerId: 1)).called(1);
  });

  testWidgets('a new customer shows the after-save note in the Discounts '
      'section and loads no discounts (spec 052 FR-007)', (tester) async {
    await pumpAt(tester, '/customers/new');

    expect(
      find.byKey(const Key('customer_discounts_after_save_note')),
      findsOneWidget,
    );
    verifyNever(
      () => repository.listDiscounts(customerId: any(named: 'customerId')),
    );
  });

  testWidgets('leaving with no edits goes straight back to the list', (
    tester,
  ) async {
    await pumpAt(tester, '/customers/1');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('customers list'), findsOneWidget);
  });

  testWidgets('leaving with unsaved edits asks first; cancelling stays, '
      'discarding leaves (spec 035 FR-032)', (tester) async {
    await pumpAt(tester, '/customers/1');
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
    expect(find.text('Edit customer'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('record_sheet_discard_confirm')));
    await tester.pumpAndSettle();
    expect(find.text('customers list'), findsOneWidget);
  });



  group('after a save (spec 052 FR-007a)', () {
    // Creating needs a price list, which the form picks through a search
    // field; set it through the controller instead of driving the picker.
    void fillNewCustomer(WidgetTester tester) {
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CustomerDetailScreen)),
      );
      container
          .read(customerFormControllerProvider(null).notifier)
          .priceListSelected(1, 'Retail');
    }

    void stubWrites() {
      final created = _customer.copyWith(customerId: 5, name: 'Nuevo');
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
      ).thenAnswer((_) async => created);
      when(
        () => repository.get(customerId: 5),
      ).thenAnswer((_) async => created);
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
      ).thenAnswer((_) async => _customer);
    }

    testWidgets('a successful create stays on the screen, reopened in edit '
        'mode at /customers/<id> with the add control available', (
      tester,
    ) async {
      stubWrites();
      final router = await pumpAt(
        tester,
        '/customers/new',
        user: _editorWithProducts,
      );
      expect(
        find.byKey(const Key('add_customer_discount_button')),
        findsNothing,
      );

      fillNewCustomer(tester);
      await tester.enterText(find.byKey(const Key('name_field')), 'Nuevo');
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), '/customers/5');
      expect(find.text('Edit customer'), findsOneWidget);
      expect(
        find.byKey(const Key('add_customer_discount_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('customer_discounts_after_save_note')),
        findsNothing,
      );
      expect(find.text('customers list'), findsNothing);
      verify(() => repository.listDiscounts(customerId: 5)).called(1);
    });

    testWidgets('a successful update returns to the list', (tester) async {
      stubWrites();
      await pumpAt(tester, '/customers/1');

      await tester.enterText(find.byKey(const Key('zone_field')), 'Norte');
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      expect(find.text('customers list'), findsOneWidget);
    });

    testWidgets('a create opened while the previous customer is still closing '
        'starts empty, not with that customer\'s fields (mbe-ui#207)', (
      tester,
    ) async {
      // A real load takes a moment. `pumpAndSettle` advances the clock in
      // 100 ms steps, so a shorter stub would finish before the form ever
      // built its loading state, and its fields would stay blank.
      when(() => repository.get(customerId: 1)).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 500),
          () => _customer,
        ),
      );
      final router = await pumpAt(tester, '/customers/1?view=true');
      String fieldText(String key) => tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(Key(key)),
              matching: find.byType(EditableText),
            ),
          )
          .controller
          .text;
      expect(fieldText('code_field'), 'CUST-001');

      // Back, then New before the back transition has finished — the old
      // screen is still mounted, and still holding its form state.
      router.pop();
      await tester.pump();
      router.push('/customers/new');
      await tester.pumpAndSettle();

      expect(find.text('New customer'), findsOneWidget);
      expect(fieldText('code_field'), isEmpty);
      expect(fieldText('name_field'), isEmpty);
    });

    testWidgets('changing a discount refreshes only the Discounts section: the '
        "customer's own unsaved edits stay pending (spec 052 FR-010)", (
      tester,
    ) async {
      const discount = CustomerDiscount(
        customerDiscountId: 7,
        customerId: 1,
        productId: 100,
        productCode: 'CLV-0125',
        productName: 'Clavo estándar',
        discount: '0.10000000',
      );
      var listCalls = 0;
      when(
        () => repository.listDiscounts(customerId: 1),
      ).thenAnswer((_) async {
        listCalls++;
        return const [discount];
      });
      when(
        () => repository.updateDiscount(
          customerId: 1,
          customerDiscountId: 7,
          discount: any(named: 'discount'),
        ),
      ).thenAnswer((_) async => discount);
      await pumpAt(tester, '/customers/1');
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CustomerDetailScreen)),
      );

      await tester.enterText(find.byKey(const Key('zone_field')), 'Norte');
      await tester.pump();
      expect(container.read(customerFormControllerProvider(1)).zone, 'Norte');

      await tester.tap(find.byKey(const Key('edit_customer_discount_7')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('customer_discount_percent_field')),
        '15',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('customer_discount_save_button')));
      await tester.pumpAndSettle();

      verify(
        () => repository.updateDiscount(
          customerId: 1,
          customerDiscountId: 7,
          discount: '0.15',
        ),
      ).called(1);
      expect(listCalls, 2, reason: 'only the discounts list was re-read');
      verify(() => repository.get(customerId: 1)).called(1);
      expect(
        container.read(customerFormControllerProvider(1)).zone,
        'Norte',
        reason: 'the unsaved customer edit is untouched',
      );
      verifyNever(
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
      );
      expect(find.text('Edit customer'), findsOneWidget);
    });
  });
}
