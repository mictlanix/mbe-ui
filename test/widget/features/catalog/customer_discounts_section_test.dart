import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_discount.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_discounts_section.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

// Customers: read 2, update 4, create 1, delete 8.
const _editor = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.customers, rawValue: 15)],
);

// Adding a discount also needs Read on products, to search them.
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

const _readerWithProducts = User(
  userId: 'reader-products',
  email: 'reader-products@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.customers, rawValue: 2),
    Privilege(systemObject: SystemObject.products, rawValue: 2),
  ],
);

const _concreto = ProductListItem(
  productId: 103,
  code: 'CLV-0140',
  name: 'Clavo para concreto',
  unitOfMeasurementCode: 'KG',
  unitOfMeasurementName: 'Kilogram',
  taxRate: '0.16',
  status: EntityStatus.active,
);

const _reader = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.customers, rawValue: 2)],
);

const _discounts = [
  CustomerDiscount(
    customerDiscountId: 1,
    customerId: 1,
    productId: 101,
    productCode: 'CLV-0125',
    productName: 'Clavo estándar',
    discount: '0.10000000',
  ),
  CustomerDiscount(
    customerDiscountId: 2,
    customerId: 1,
    productId: 102,
    productCode: 'TOR-0310',
    productName: 'Tornillo hexagonal',
    discount: '0.12500000',
  ),
];

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockCustomerRepository repository;
  late MockProductRepository productRepository;

  setUp(() {
    repository = MockCustomerRepository();
    productRepository = MockProductRepository();
    when(
      () => productRepository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const ProductListResult(items: [_concreto], total: 1),
    );
  });

  Future<void> pumpSection(
    WidgetTester tester, {
    int? customerId = 1,
    bool readOnly = false,
    User user = _editorWithProducts,
    List<CustomerDiscount> discounts = const [],
    Object? loadError,
    Future<List<CustomerDiscount>>? pending,
    Future<List<CustomerDiscount>> Function()? loader,
    Size size = const Size(1024, 800),
  }) async {
    final stub = when(
      () => repository.listDiscounts(customerId: any(named: 'customerId')),
    );
    if (loadError != null) {
      stub.thenThrow(loadError);
    } else if (pending != null) {
      stub.thenAnswer((_) => pending);
    } else if (loader != null) {
      stub.thenAnswer((_) => loader());
    } else {
      stub.thenAnswer((_) async => discounts);
    }
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          customerRepositoryProvider.overrideWithValue(repository),
          productRepositoryProvider.overrideWithValue(productRepository),
          accessControlProvider.overrideWithValue(_accessFor(user)),
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
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: CustomerDiscountsSection(
                customerId: customerId,
                readOnly: readOnly,
              ),
            ),
          ),
        ),
      ),
    );
    // A pending load never settles: pump a frame, not until idle.
    await tester.pump();
    if (pending == null) await tester.pumpAndSettle();
  }

  testWidgets('an empty section shows its empty state (US1-2)', (tester) async {
    await pumpSection(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.customerDiscountsEmpty), findsOneWidget);
    expect(find.byKey(const Key('customer_discounts_table')), findsNothing);
  });

  testWidgets('a populated table shows code, product and the discount as a '
      'percentage (US1-1)', (tester) async {
    await pumpSection(tester, discounts: _discounts);

    expect(find.byKey(const Key('customer_discounts_table')), findsOneWidget);
    expect(find.text('Code'), findsOneWidget);
    expect(find.text('Product'), findsOneWidget);
    expect(find.text('Discount'), findsOneWidget);
    expect(find.text('CLV-0125'), findsOneWidget);
    expect(find.text('Clavo estándar'), findsOneWidget);
    expect(find.text('TOR-0310'), findsOneWidget);
  });

  testWidgets('rows keep the server\'s order', (tester) async {
    await pumpSection(tester, discounts: _discounts);

    final first = tester.getTopLeft(find.text('CLV-0125')).dy;
    final second = tester.getTopLeft(find.text('TOR-0310')).dy;
    expect(first, lessThan(second));
  });

  testWidgets('discounts render in the application percent format; 0.125 '
      'reads 12.50 % (FR-003, US1-3)', (tester) async {
    await pumpSection(tester, discounts: _discounts);

    expect(find.text('10.00 %'), findsOneWidget);
    expect(find.text('12.50 %'), findsOneWidget);
  });

  testWidgets('the compact tier drops the Code column and prefixes the code '
      'into the product cell', (tester) async {
    await pumpSection(
      tester,
      discounts: _discounts,
      size: const Size(400, 800),
    );

    expect(find.text('Code'), findsNothing);
    expect(find.text('CLV-0125'), findsNothing);
    expect(find.text('CLV-0125 · Clavo estándar'), findsOneWidget);
    expect(find.text('10.00 %'), findsOneWidget);
  });

  testWidgets('a null customerId shows the after-save note and loads nothing '
      '(FR-007)', (tester) async {
    await pumpSection(tester, customerId: null);

    expect(
      find.byKey(const Key('customer_discounts_after_save_note')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('customer_discounts_table')), findsNothing);
    verifyNever(
      () => repository.listDiscounts(customerId: any(named: 'customerId')),
    );
  });

  testWidgets('a failed load shows the error view, and Retry reads again', (
    tester,
  ) async {
    await pumpSection(tester, loadError: const AppError.server());

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.retryButton), findsOneWidget);
    expect(find.byKey(const Key('customer_discounts_table')), findsNothing);

    when(
      () => repository.listDiscounts(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _discounts);
    await tester.tap(find.text(l10n.retryButton));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer_discounts_table')), findsOneWidget);
    verify(() => repository.listDiscounts(customerId: 1)).called(2);
  });

  testWidgets('read-only, or without Update: rows show but there are no '
      'add or edit controls (US1-4)', (tester) async {
    await pumpSection(tester, readOnly: true, discounts: _discounts);
    expect(find.byKey(const Key('customer_discounts_table')), findsOneWidget);
    expect(find.byKey(const Key('add_customer_discount_button')), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);

    await pumpSection(tester, user: _reader, discounts: _discounts);
    expect(find.byKey(const Key('customer_discounts_table')), findsOneWidget);
    expect(find.byKey(const Key('add_customer_discount_button')), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });

  group('the add button (spec 052 FR-004, FR-012)', () {
    const addButton = Key('add_customer_discount_button');

    testWidgets('shows for a saved customer with Update on customers and '
        'Read on products', (tester) async {
      await pumpSection(tester, discounts: _discounts);

      expect(find.byKey(addButton), findsOneWidget);
    });

    testWidgets('is hidden when read-only', (tester) async {
      await pumpSection(tester, readOnly: true, discounts: _discounts);

      expect(find.byKey(addButton), findsNothing);
    });

    testWidgets('is hidden without Update on customers', (tester) async {
      await pumpSection(
        tester,
        user: _readerWithProducts,
        discounts: _discounts,
      );

      expect(find.byKey(addButton), findsNothing);
    });

    testWidgets('is hidden without Read on products, though rows still '
        'show', (tester) async {
      await pumpSection(tester, user: _editor, discounts: _discounts);

      expect(find.byKey(addButton), findsNothing);
      expect(find.byKey(const Key('customer_discounts_table')), findsOne);
    });

    testWidgets('is hidden for a customer that is not saved yet', (
      tester,
    ) async {
      await pumpSection(tester, customerId: null);

      expect(find.byKey(addButton), findsNothing);
    });

    testWidgets('is hidden while the list loads, then appears (FR-005: the '
        'taken products must be known)', (tester) async {
      final pending = Completer<List<CustomerDiscount>>();
      await pumpSection(tester, pending: pending.future);

      expect(find.byKey(addButton), findsNothing);

      pending.complete(_discounts);
      await tester.pumpAndSettle();

      expect(find.byKey(addButton), findsOneWidget);
    });

    testWidgets('is hidden when the list failed to load', (tester) async {
      await pumpSection(tester, loadError: const AppError.server());

      expect(find.byKey(addButton), findsNothing);
    });

    testWidgets('wraps below the title on a narrow width without '
        'overflowing', (tester) async {
      await pumpSection(tester, size: const Size(220, 800));

      expect(tester.takeException(), isNull);
      final title = tester.getTopLeft(find.text('Discounts'));
      final button = tester.getTopLeft(find.byKey(addButton));
      expect(button.dy, greaterThan(title.dy));
    });

    testWidgets('opens the dialog, and a saved discount refreshes the '
        'list', (tester) async {
      var calls = 0;
      when(
        () => repository.createDiscount(
          customerId: 1,
          productId: 103,
          discount: any(named: 'discount'),
        ),
      ).thenAnswer((_) async => _discounts.first);
      await pumpSection(
        tester,
        loader: () async => ++calls == 1 ? const [] : _discounts,
      );

      await tester.tap(find.byKey(addButton));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('customer_discount_save_button')),
        findsOneWidget,
      );

      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('customer_discount_product_field')),
          matching: find.byType(TextFormField),
        ),
        'clavo',
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      await tester.tap(find.text('Clavo para concreto').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('customer_discount_percent_field')),
        '10',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('customer_discount_save_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('customer_discount_save_button')),
        findsNothing,
      );
      expect(find.byKey(const Key('customer_discounts_table')), findsOneWidget);
      expect(find.text('CLV-0125'), findsOneWidget);
      expect(calls, 2);
    });
  });

  group('the row actions (spec 052 FR-008, FR-009, FR-012)', () {
    testWidgets('each row has exactly one action, Edit, and no Delete icon', (
      tester,
    ) async {
      await pumpSection(tester, discounts: _discounts);

      expect(find.byKey(const Key('edit_customer_discount_1')), findsOne);
      expect(find.byKey(const Key('edit_customer_discount_2')), findsOne);
      expect(find.byType(IconButton), findsNWidgets(2));
      expect(find.byIcon(Icons.edit_outlined), findsNWidgets(2));
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('Edit is hidden when read-only, and without Update on '
        'customers', (tester) async {
      await pumpSection(tester, readOnly: true, discounts: _discounts);
      expect(find.byKey(const Key('edit_customer_discount_1')), findsNothing);

      await pumpSection(
        tester,
        user: _readerWithProducts,
        discounts: _discounts,
      );
      expect(find.byKey(const Key('edit_customer_discount_1')), findsNothing);
    });

    testWidgets('Edit shows without Read on products: nothing is searched '
        'when editing', (tester) async {
      await pumpSection(tester, user: _editor, discounts: _discounts);

      expect(find.byKey(const Key('edit_customer_discount_1')), findsOne);
      expect(
        find.byKey(const Key('add_customer_discount_button')),
        findsNothing,
      );
    });

    testWidgets('Edit opens the dialog on that row, product read-only', (
      tester,
    ) async {
      await pumpSection(tester, discounts: _discounts);

      await tester.tap(find.byKey(const Key('edit_customer_discount_2')));
      await tester.pumpAndSettle();

      expect(find.text('Edit discount'), findsOneWidget);
      expect(find.text('TOR-0310 — Tornillo hexagonal'), findsOneWidget);
      expect(
        find.byKey(const Key('customer_discount_delete_button')),
        findsOneWidget,
      );
    });

    testWidgets('a discount on a since-deactivated product is still listed '
        'and can be edited (spec edge case)', (tester) async {
      // The list endpoint carries no product status, so an inactive product
      // arrives like any other: it must not be filtered out of the section.
      await pumpSection(tester, discounts: [_discounts.first]);

      expect(find.text('CLV-0125'), findsOneWidget);
      await tester.tap(find.byKey(const Key('edit_customer_discount_1')));
      await tester.pumpAndSettle();

      expect(find.text('CLV-0125 — Clavo estándar'), findsOneWidget);
    });

    testWidgets('removing a discount refreshes the list', (tester) async {
      var calls = 0;
      when(
        () => repository.deleteDiscount(customerId: 1, customerDiscountId: 1),
      ).thenAnswer((_) async {});
      await pumpSection(
        tester,
        loader: () async => ++calls == 1 ? _discounts : [_discounts.last],
      );
      expect(find.text('CLV-0125'), findsOneWidget);

      await tester.tap(find.byKey(const Key('edit_customer_discount_1')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('customer_discount_delete_button')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('confirm_delete_customer_discount_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('CLV-0125'), findsNothing);
      expect(find.text('TOR-0310'), findsOneWidget);
      expect(calls, 2);
    });
  });
}
