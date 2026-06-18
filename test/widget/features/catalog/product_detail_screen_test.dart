import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/product_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockProductRepository extends Mock implements ProductRepository {}

const _createUser = User(
  userId: 'creator',
  email: 'creator@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 1)],
);

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 2)],
);

const _editUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  // read (2) + update (4)
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 6)],
);

const _deleteUser = User(
  userId: 'deleter',
  email: 'deleter@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  // read (2) + update (4) + delete (8)
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 14)],
);

Product _product() => Product(
      productId: 1,
      code: 'SKU-001',
      name: 'Widget',
      unitOfMeasurement: 'PCE',
      taxRate: '0.16',
      taxIncluded: false,
      priceType: 0,
      currency: 0,
      minOrderQty: 1,
      stockable: false,
      perishable: false,
      seriable: false,
      purchasable: false,
      salable: false,
      invoiceable: false,
      stockRequired: false,
      deactivated: false,
      prices: const [],
    );

void main() {
  late MockAuthRepository authRepository;
  late MockTokenStorage tokenStorage;
  late MockProductRepository productRepository;

  setUp(() {
    authRepository = MockAuthRepository();
    tokenStorage = MockTokenStorage();
    productRepository = MockProductRepository();
    when(() => tokenStorage.read()).thenAnswer((_) async => 'test-token');
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? productId,
  }) async {
    when(() => authRepository.me()).thenAnswer((_) async => signedInAs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          productRepositoryProvider.overrideWithValue(productRepository),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProductDetailScreen(productId: productId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Like [pumpScreen], but backed by a real `GoRouter` with a route to pop
  /// back to — needed for tests that trigger `formState.saved`, since the
  /// screen calls `context.pop()` (go_router), which throws without a
  /// `GoRouter` ancestor.
  Future<void> pumpScreenWithRouter(
    WidgetTester tester, {
    required User signedInAs,
    required int productId,
  }) async {
    when(() => authRepository.me()).thenAnswer((_) async => signedInAs);
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SizedBox()),
        GoRoute(
          path: '/products/:productId',
          builder: (_, state) => ProductDetailScreen(
            productId: int.parse(state.pathParameters['productId']!),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          productRepositoryProvider.overrideWithValue(productRepository),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.push('/products/$productId');
    await tester.pumpAndSettle();
  }

  testWidgets('renders the create form fields (FR-003)', (tester) async {
    await pumpScreen(tester, signedInAs: _createUser);

    expect(find.byKey(const Key('code_field')), findsOneWidget);
    expect(find.byKey(const Key('name_field')), findsOneWidget);
    expect(find.byKey(const Key('unit_of_measurement_field')), findsOneWidget);
    expect(find.byKey(const Key('bar_code_field')), findsOneWidget);
    expect(find.byKey(const Key('save_button')), findsOneWidget);
  });

  testWidgets(
      'shows field-level validation errors and does not submit (FR-006, FR-014)',
      (tester) async {
    await pumpScreen(tester, signedInAs: _createUser);

    // Leave code/name/unit empty and tap Save.
    await tester.ensureVisible(find.byKey(const Key('save_button')));
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Code is required.'), findsOneWidget);
    expect(
      find.text('Name must be between 4 and 250 characters.'),
      findsOneWidget,
    );
    verifyNever(() => productRepository.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
          unitOfMeasurement: any(named: 'unitOfMeasurement'),
        ));
  });

  testWidgets('rejects an invalid barcode (FR-007)', (tester) async {
    await pumpScreen(tester, signedInAs: _createUser);

    await tester.enterText(find.byKey(const Key('code_field')), 'SKU-001');
    await tester.enterText(find.byKey(const Key('name_field')), 'Widget');
    await tester.enterText(
        find.byKey(const Key('unit_of_measurement_field')), 'PCE');
    await tester.enterText(find.byKey(const Key('bar_code_field')), '12345');
    await tester.ensureVisible(find.byKey(const Key('save_button')));
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Barcode must be empty or exactly 13 digits.'),
      findsOneWidget,
    );
  });

  testWidgets('a duplicate-code server rejection is shown on the code field '
      '(FR-004, FR-014)', (tester) async {
    when(() => productRepository.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
          unitOfMeasurement: any(named: 'unitOfMeasurement'),
          brand: any(named: 'brand'),
          model: any(named: 'model'),
          barCode: any(named: 'barCode'),
          location: any(named: 'location'),
          taxRate: any(named: 'taxRate'),
          comment: any(named: 'comment'),
          stockable: any(named: 'stockable'),
          perishable: any(named: 'perishable'),
          seriable: any(named: 'seriable'),
          purchasable: any(named: 'purchasable'),
          salable: any(named: 'salable'),
          invoiceable: any(named: 'invoiceable'),
        )).thenThrow(const AppError.validation([
      FieldError(loc: ['body', 'code'], msg: 'Code already in use', type: 'value_error'),
    ]));

    await pumpScreen(tester, signedInAs: _createUser);

    await tester.enterText(find.byKey(const Key('code_field')), 'SKU-001');
    await tester.enterText(find.byKey(const Key('name_field')), 'Widget');
    await tester.enterText(
        find.byKey(const Key('unit_of_measurement_field')), 'PCE');
    await tester.ensureVisible(find.byKey(const Key('save_button')));
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Code already in use'), findsOneWidget);
  });

  testWidgets('hides the Save action for a user without products.create '
      '(FR-012, FR-013)', (tester) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser);

    expect(find.byKey(const Key('save_button')), findsNothing);
  });

  group('edit mode', () {
    testWidgets('loads and displays the existing product (FR-008, FR-009)',
        (tester) async {
      when(() => productRepository.get(productId: 1))
          .thenAnswer((_) async => _product());

      await pumpScreen(tester, signedInAs: _editUser, productId: 1);

      final codeField =
          tester.widget<TextFormField>(find.byKey(const Key('code_field')));
      final nameField =
          tester.widget<TextFormField>(find.byKey(const Key('name_field')));
      expect(codeField.initialValue, 'SKU-001');
      expect(nameField.initialValue, 'Widget');
      expect(find.byKey(const Key('save_button')), findsOneWidget);
    });

    testWidgets(
        'renders read-only with no Save action for a Read-only account '
        '(FR-013)', (tester) async {
      when(() => productRepository.get(productId: 1))
          .thenAnswer((_) async => _product());

      await pumpScreen(tester, signedInAs: _readOnlyUser, productId: 1);

      final codeField =
          tester.widget<TextFormField>(find.byKey(const Key('code_field')));
      expect(codeField.initialValue, 'SKU-001');
      expect(codeField.enabled, isFalse);
      expect(find.byKey(const Key('save_button')), findsNothing);
    });

    testWidgets('saves an edit and calls the repository (FR-009)',
        (tester) async {
      when(() => productRepository.get(productId: 1))
          .thenAnswer((_) async => _product());
      when(() => productRepository.update(
            productId: 1,
            code: 'SKU-001',
            name: 'Updated Widget',
            unitOfMeasurement: 'PCE',
            brand: any(named: 'brand'),
            model: any(named: 'model'),
            barCode: any(named: 'barCode'),
            location: any(named: 'location'),
            taxRate: any(named: 'taxRate'),
            comment: any(named: 'comment'),
            stockable: any(named: 'stockable'),
            perishable: any(named: 'perishable'),
            seriable: any(named: 'seriable'),
            purchasable: any(named: 'purchasable'),
            salable: any(named: 'salable'),
            invoiceable: any(named: 'invoiceable'),
          )).thenAnswer((_) async => _product());

      await pumpScreenWithRouter(tester, signedInAs: _editUser, productId: 1);

      await tester.enterText(find.byKey(const Key('name_field')), 'Updated Widget');
      await tester.ensureVisible(find.byKey(const Key('save_button')));
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      verify(() => productRepository.update(
            productId: 1,
            code: 'SKU-001',
            name: 'Updated Widget',
            unitOfMeasurement: 'PCE',
            brand: any(named: 'brand'),
            model: any(named: 'model'),
            barCode: any(named: 'barCode'),
            location: any(named: 'location'),
            taxRate: any(named: 'taxRate'),
            comment: any(named: 'comment'),
            stockable: any(named: 'stockable'),
            perishable: any(named: 'perishable'),
            seriable: any(named: 'seriable'),
            purchasable: any(named: 'purchasable'),
            salable: any(named: 'salable'),
            invoiceable: any(named: 'invoiceable'),
          )).called(1);
    });

    testWidgets(
        'shows the Deactivate action for a user with products.delete '
        '(FR-010)', (tester) async {
      when(() => productRepository.get(productId: 1))
          .thenAnswer((_) async => _product());

      await pumpScreen(tester, signedInAs: _deleteUser, productId: 1);

      expect(find.byKey(const Key('deactivate_product_button')), findsOneWidget);
    });

    testWidgets(
        'hides the Deactivate action for a user without products.delete '
        '(FR-012)', (tester) async {
      when(() => productRepository.get(productId: 1))
          .thenAnswer((_) async => _product());

      await pumpScreen(tester, signedInAs: _editUser, productId: 1);

      expect(find.byKey(const Key('deactivate_product_button')), findsNothing);
    });

    testWidgets(
        'hides the Deactivate action for an already-deactivated product '
        '(edge case)', (tester) async {
      when(() => productRepository.get(productId: 1))
          .thenAnswer((_) async => _product().copyWith(deactivated: true));

      await pumpScreen(tester, signedInAs: _deleteUser, productId: 1);

      expect(find.byKey(const Key('deactivate_product_button')), findsNothing);
    });

    testWidgets('deactivates after confirmation (FR-010)', (tester) async {
      when(() => productRepository.get(productId: 1))
          .thenAnswer((_) async => _product());
      when(() => productRepository.update(productId: 1, deactivated: true))
          .thenAnswer((_) async => _product().copyWith(deactivated: true));

      await pumpScreen(tester, signedInAs: _deleteUser, productId: 1);

      await tester.tap(find.byKey(const Key('deactivate_product_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_deactivate_button')));
      await tester.pumpAndSettle();

      verify(() => productRepository.update(productId: 1, deactivated: true))
          .called(1);
      expect(find.byKey(const Key('deactivate_product_button')), findsNothing);
    });
  });
}
