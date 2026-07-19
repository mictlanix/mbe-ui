import 'dart:typed_data';

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
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/domain/entities/sat_catalog_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/sat_catalog_repository.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/product_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/product_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockSatCatalogRepository extends Mock implements SatCatalogRepository {}

class MockSupplierRepository extends Mock implements SupplierRepository {}

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

const _editUserWithPricing = User(
  userId: 'editor-pricing',
  email: 'editor-pricing@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [
    // read (2) + update (4)
    Privilege(systemObject: SystemObject.products, rawValue: 6),
    Privilege(systemObject: SystemObject.pricing, rawValue: 2),
  ],
);

/// A minimal valid 1x1 PNG, used so a staged-photo preview can actually
/// decode (mirrors test/integration/product_photo_flow_test.dart).
final _tinyPngBytes = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x64,
  0x60,
  0x60,
  0x60,
  0x00,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x5D,
  0x4C,
  0x8F,
  0x0C,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

Product _product() => Product(
  productId: 1,
  code: 'SKU-001',
  name: 'Widget',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Piece',
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
);

void main() {
  late MockAuthRepository authRepository;
  late MockTokenStorage tokenStorage;
  late MockProductRepository productRepository;
  late MockSatCatalogRepository satCatalogRepository;
  late MockSupplierRepository supplierRepository;

  setUp(() {
    authRepository = MockAuthRepository();
    tokenStorage = MockTokenStorage();
    productRepository = MockProductRepository();
    satCatalogRepository = MockSatCatalogRepository();
    supplierRepository = MockSupplierRepository();
    when(() => tokenStorage.read()).thenAnswer((_) async => 'test-token');
    when(
      () => satCatalogRepository.listUnitsOfMeasurement(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const SatCatalogListResult(items: [], total: 0));
    when(
      () => satCatalogRepository.listProductServices(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const SatCatalogListResult(items: [], total: 0));
    when(
      () => supplierRepository.list(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const SupplierListResult(items: [], total: 0));
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? productId,
    List<LabelItem> labels = const [],
    bool forceReadOnly = false,
  }) async {
    when(() => authRepository.me()).thenAnswer((_) async => signedInAs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          productRepositoryProvider.overrideWithValue(productRepository),
          satCatalogRepositoryProvider.overrideWithValue(satCatalogRepository),
          supplierRepositoryProvider.overrideWithValue(supplierRepository),
          allLabelsProvider.overrideWith((_) async => labels),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProductDetailScreen(
            productId: productId,
            forceReadOnly: forceReadOnly,
          ),
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
          satCatalogRepositoryProvider.overrideWithValue(satCatalogRepository),
          supplierRepositoryProvider.overrideWithValue(supplierRepository),
          allLabelsProvider.overrideWith((_) async => []),
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

  /// Like [pumpScreen], but returns the `ProviderContainer` backing the
  /// widget tree so tests can drive [ProductFormController] directly for
  /// states that have no UI trigger in widget tests (e.g. a file picked via
  /// the native file dialog).
  Future<ProviderContainer> pumpScreenWithContainer(
    WidgetTester tester, {
    required User signedInAs,
    int? productId,
  }) async {
    when(() => authRepository.me()).thenAnswer((_) async => signedInAs);
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        tokenStorageProvider.overrideWithValue(tokenStorage),
        productRepositoryProvider.overrideWithValue(productRepository),
        satCatalogRepositoryProvider.overrideWithValue(satCatalogRepository),
        supplierRepositoryProvider.overrideWithValue(supplierRepository),
        allLabelsProvider.overrideWith((_) async => []),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProductDetailScreen(productId: productId),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('renders the create form fields (FR-003)', (tester) async {
    await pumpScreen(tester, signedInAs: _createUser);

    expect(find.byKey(const Key('code_field')), findsOneWidget);
    expect(find.byKey(const Key('name_field')), findsOneWidget);
    expect(find.byKey(const Key('sku_field')), findsOneWidget);
    expect(find.byKey(const Key('unit_of_measurement_field')), findsOneWidget);
    expect(find.byKey(const Key('bar_code_field')), findsOneWidget);
    expect(find.byKey(const Key('save_button')), findsOneWidget);
  });

  testWidgets(
    'the supplier picker still searches via SupplierRepository.list() after '
    'Suppliers was promoted to a full CRUD catalog (spec 012 regression '
    'guard, SC-005)',
    (tester) async {
      when(
        () => supplierRepository.list(
          search: 'Acme',
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const SupplierListResult(
          items: [
            SupplierListItem(supplierId: 1, code: 'SUP-001', name: 'Acme Corp'),
          ],
          total: 1,
        ),
      );

      await pumpScreen(tester, signedInAs: _createUser);

      expect(find.byKey(const Key('supplier_field')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('supplier_field')), 'Acme');
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      expect(find.text('SUP-001 — Acme Corp'), findsOneWidget);
    },
  );

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
      verifyNever(
        () => productRepository.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
          unitOfMeasurement: any(named: 'unitOfMeasurement'),
        ),
      );
    },
  );

  testWidgets('rejects an invalid barcode (FR-007)', (tester) async {
    await pumpScreen(tester, signedInAs: _createUser);

    await tester.enterText(find.byKey(const Key('code_field')), 'SKU-001');
    await tester.enterText(find.byKey(const Key('name_field')), 'Widget');
    await tester.enterText(
      find.byKey(const Key('unit_of_measurement_field')),
      'PCE',
    );
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
    when(
      () => productRepository.create(
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
        supplier: any(named: 'supplier'),
        key: any(named: 'key'),
        currency: any(named: 'currency'),
        labels: any(named: 'labels'),
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

    // Use pumpScreenWithContainer so we can drive the unit picker via the
    // controller (Autocomplete has no way to programmatically "select" an
    // option without a real pointer interaction in widget tests).
    final container = await pumpScreenWithContainer(
      tester,
      signedInAs: _createUser,
    );

    await tester.enterText(find.byKey(const Key('code_field')), 'SKU-001');
    await tester.enterText(find.byKey(const Key('name_field')), 'Widget');
    container
        .read(productFormControllerProvider.notifier)
        .unitSelected(const SatCatalogItem(code: 'PCE'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('save_button')));
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Code already in use'), findsOneWidget);
  });

  testWidgets(
    'shows the upload control for a create-privilege user with no photo '
    '(FR-003, FR-008)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _createUser);

      expect(find.byKey(const Key('upload_photo_button')), findsOneWidget);
    },
  );

  testWidgets('hides the upload control for a user without products.create '
      '(FR-008, FR-009)', (tester) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser);

    expect(find.byKey(const Key('upload_photo_button')), findsNothing);
  });

  testWidgets('shows replace/remove controls for a product with a photo when '
      'canUpdate (FR-004, FR-005)', (tester) async {
    when(
      () => productRepository.get(productId: 1),
    ).thenAnswer((_) async => _product().copyWith(photo: 'http://test/p.png'));

    await pumpScreen(tester, signedInAs: _editUser, productId: 1);

    expect(find.byKey(const Key('replace_photo_button')), findsOneWidget);
    expect(find.byKey(const Key('remove_photo_button')), findsOneWidget);
    expect(find.byKey(const Key('upload_photo_button')), findsNothing);
  });

  testWidgets('hides the remove control for a product with no photo (spec.md '
      'Edge Cases)', (tester) async {
    when(
      () => productRepository.get(productId: 1),
    ).thenAnswer((_) async => _product());

    await pumpScreen(tester, signedInAs: _editUser, productId: 1);

    expect(find.byKey(const Key('remove_photo_button')), findsNothing);
    expect(find.byKey(const Key('replace_photo_button')), findsNothing);
    expect(find.byKey(const Key('upload_photo_button')), findsOneWidget);
  });

  testWidgets('hides replace/remove controls for a Read-only account viewing a '
      'product with a photo (FR-009)', (tester) async {
    when(
      () => productRepository.get(productId: 1),
    ).thenAnswer((_) async => _product().copyWith(photo: 'http://test/p.png'));

    await pumpScreen(tester, signedInAs: _readOnlyUser, productId: 1);

    expect(find.byKey(const Key('replace_photo_button')), findsNothing);
    expect(find.byKey(const Key('remove_photo_button')), findsNothing);
    final photo = tester.widget<ProductPhoto>(find.byType(ProductPhoto));
    expect(photo.photoUrl, 'http://test/p.png');
  });

  testWidgets('removing a photo reverts the preview to the placeholder before '
      'save (FR-005)', (tester) async {
    when(
      () => productRepository.get(productId: 1),
    ).thenAnswer((_) async => _product().copyWith(photo: 'http://test/p.png'));
    final container = await pumpScreenWithContainer(
      tester,
      signedInAs: _editUser,
      productId: 1,
    );

    container
        .read(productFormControllerProvider.notifier)
        .photoRemoveRequested();
    await tester.pumpAndSettle();

    final photo = tester.widget<ProductPhoto>(find.byType(ProductPhoto));
    expect(photo.photoUrl, isNull);
    expect(find.byKey(const Key('upload_photo_button')), findsOneWidget);
  });

  testWidgets(
    'shows a staged photo preview at the enlarged size with a non-cropping '
    'fit (FR-017, FR-018)',
    (tester) async {
      final container = await pumpScreenWithContainer(
        tester,
        signedInAs: _createUser,
      );

      container
          .read(productFormControllerProvider.notifier)
          .photoPicked(_tinyPngBytes, 'photo.png');
      await tester.pumpAndSettle();

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.width, 168);
      expect(image.height, 168);
      expect(image.fit, BoxFit.contain);
    },
  );

  testWidgets('shows a photo field error after an invalid pick (FR-006)', (
    tester,
  ) async {
    final container = await pumpScreenWithContainer(
      tester,
      signedInAs: _createUser,
    );
    container
        .read(productFormControllerProvider.notifier)
        .photoPicked(Uint8List.fromList([1, 2, 3]), 'document.pdf');
    await tester.pumpAndSettle();

    expect(find.text('Photo must be a JPEG or PNG file.'), findsOneWidget);
  });

  testWidgets('hides the Save action for a user without products.create '
      '(FR-012, FR-013)', (tester) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser);

    expect(find.byKey(const Key('save_button')), findsNothing);
  });

  group('edit mode', () {
    testWidgets('loads and displays the existing product (FR-008, FR-009)', (
      tester,
    ) async {
      when(
        () => productRepository.get(productId: 1),
      ).thenAnswer((_) async => _product());

      await pumpScreen(tester, signedInAs: _editUser, productId: 1);

      final codeField = tester.widget<TextFormField>(
        find.byKey(const Key('code_field')),
      );
      final nameField = tester.widget<TextFormField>(
        find.byKey(const Key('name_field')),
      );
      expect(codeField.initialValue, 'SKU-001');
      expect(nameField.initialValue, 'Widget');
      expect(find.byKey(const Key('save_button')), findsOneWidget);
    });

    testWidgets(
      'displays and allows editing the sku field, seeded from the loaded '
      'product (FR-010)',
      (tester) async {
        when(
          () => productRepository.get(productId: 1),
        ).thenAnswer((_) async => _product().copyWith(sku: 'SKU-ABC'));

        final container = await pumpScreenWithContainer(
          tester,
          signedInAs: _editUser,
          productId: 1,
        );

        final skuField = tester.widget<TextFormField>(
          find.byKey(const Key('sku_field')),
        );
        expect(skuField.initialValue, 'SKU-ABC');
        expect(skuField.enabled, isTrue);

        await tester.enterText(find.byKey(const Key('sku_field')), 'SKU-XYZ');
        await tester.pump();

        expect(container.read(productFormControllerProvider).sku, 'SKU-XYZ');
      },
    );

    testWidgets('displays the loaded product photo via ProductPhoto (FR-001)', (
      tester,
    ) async {
      when(() => productRepository.get(productId: 1)).thenAnswer(
        (_) async => _product().copyWith(photo: 'http://test/images/p.png'),
      );

      await pumpScreen(tester, signedInAs: _editUser, productId: 1);

      final photo = tester.widget<ProductPhoto>(find.byType(ProductPhoto));
      expect(photo.photoUrl, 'http://test/images/p.png');
      expect(photo.size, 168);
    });

    testWidgets('displays the placeholder when the product has no photo '
        '(FR-002)', (tester) async {
      when(
        () => productRepository.get(productId: 1),
      ).thenAnswer((_) async => _product());

      await pumpScreen(tester, signedInAs: _editUser, productId: 1);

      final photo = tester.widget<ProductPhoto>(find.byType(ProductPhoto));
      expect(photo.photoUrl, isNull);
    });

    testWidgets('renders read-only with no Save action for a Read-only account '
        '(FR-013)', (tester) async {
      when(
        () => productRepository.get(productId: 1),
      ).thenAnswer((_) async => _product());

      await pumpScreen(tester, signedInAs: _readOnlyUser, productId: 1);

      final codeField = tester.widget<TextFormField>(
        find.byKey(const Key('code_field')),
      );
      expect(codeField.initialValue, 'SKU-001');
      expect(codeField.enabled, isFalse);
      expect(find.byKey(const Key('save_button')), findsNothing);
    });

    testWidgets(
      'titles the app bar "View Product" when read-only via lack of update '
      'rights, with no Edit affordance (FR-005, FR-006)',
      (tester) async {
        when(
          () => productRepository.get(productId: 1),
        ).thenAnswer((_) async => _product());

        await pumpScreen(tester, signedInAs: _readOnlyUser, productId: 1);

        expect(find.text('View Product'), findsOneWidget);
        expect(find.text('Edit Product'), findsNothing);
        expect(find.byKey(const Key('edit_product_button')), findsNothing);
      },
    );

    testWidgets(
      'titles the app bar "View Product" and shows an Edit affordance when '
      'read-only via row click for a user with update rights (FR-005, '
      'FR-006)',
      (tester) async {
        when(
          () => productRepository.get(productId: 1),
        ).thenAnswer((_) async => _product());

        await pumpScreen(
          tester,
          signedInAs: _editUser,
          productId: 1,
          forceReadOnly: true,
        );

        expect(find.text('View Product'), findsOneWidget);
        expect(find.byKey(const Key('edit_product_button')), findsOneWidget);
        expect(find.byKey(const Key('code_field')), findsOneWidget);
        expect(
          tester
              .widget<TextFormField>(find.byKey(const Key('code_field')))
              .enabled,
          isFalse,
        );
      },
    );

    testWidgets(
      'titles the app bar "Edit Product" with no Edit affordance in the '
      'ordinary editable case (FR-005, FR-006)',
      (tester) async {
        when(
          () => productRepository.get(productId: 1),
        ).thenAnswer((_) async => _product());

        await pumpScreen(tester, signedInAs: _editUser, productId: 1);

        expect(find.text('Edit Product'), findsOneWidget);
        expect(find.text('View Product'), findsNothing);
        expect(find.byKey(const Key('edit_product_button')), findsNothing);
      },
    );

    testWidgets('saves an edit and calls the repository (FR-009)', (
      tester,
    ) async {
      when(
        () => productRepository.get(productId: 1),
      ).thenAnswer((_) async => _product());
      when(
        () => productRepository.update(
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
          supplier: any(named: 'supplier'),
          key: any(named: 'key'),
          currency: any(named: 'currency'),
          labels: any(named: 'labels'),
        ),
      ).thenAnswer((_) async => _product());

      await pumpScreenWithRouter(tester, signedInAs: _editUser, productId: 1);

      await tester.enterText(
        find.byKey(const Key('name_field')),
        'Updated Widget',
      );
      await tester.ensureVisible(find.byKey(const Key('save_button')));
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      verify(
        () => productRepository.update(
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
          supplier: any(named: 'supplier'),
          key: any(named: 'key'),
          currency: any(named: 'currency'),
          labels: any(named: 'labels'),
        ),
      ).called(1);
    });

    testWidgets('shows no delete icon in the app bar (FR-014)', (tester) async {
      when(
        () => productRepository.get(productId: 1),
      ).thenAnswer((_) async => _product());

      await pumpScreen(tester, signedInAs: _deleteUser, productId: 1);

      expect(find.byKey(const Key('deactivate_product_button')), findsNothing);
      expect(find.byIcon(Icons.block), findsNothing);
    });

    testWidgets(
      'shows a warning-styled Delete button below Save for a user with '
      'products.delete (FR-015)',
      (tester) async {
        when(
          () => productRepository.get(productId: 1),
        ).thenAnswer((_) async => _product());

        await pumpScreen(tester, signedInAs: _deleteUser, productId: 1);

        final saveTop = tester
            .getTopLeft(find.byKey(const Key('save_button')))
            .dy;
        final deleteTop = tester
            .getTopLeft(find.byKey(const Key('delete_product_button')))
            .dy;
        expect(deleteTop, greaterThan(saveTop));

        final button = tester.widget<FilledButton>(
          find.byKey(const Key('delete_product_button')),
        );
        final theme = Theme.of(tester.element(find.byType(Scaffold).first));
        expect(
          button.style?.backgroundColor?.resolve({}),
          theme.colorScheme.error,
        );
      },
    );

    testWidgets(
      'hides the Delete button for a user without products.delete (FR-015)',
      (tester) async {
        when(
          () => productRepository.get(productId: 1),
        ).thenAnswer((_) async => _product());

        await pumpScreen(tester, signedInAs: _editUser, productId: 1);

        expect(find.byKey(const Key('delete_product_button')), findsNothing);
      },
    );

    testWidgets(
      'still shows the Delete button for an already-deactivated product '
      '(FR-015 — not gated by deactivated state)',
      (tester) async {
        when(
          () => productRepository.get(productId: 1),
        ).thenAnswer((_) async => _product().copyWith(deactivated: true));

        await pumpScreen(tester, signedInAs: _deleteUser, productId: 1);

        expect(find.byKey(const Key('delete_product_button')), findsOneWidget);
      },
    );

    testWidgets('hides the Delete button in create mode', (tester) async {
      await pumpScreen(tester, signedInAs: _deleteUser);

      expect(find.byKey(const Key('delete_product_button')), findsNothing);
    });

    testWidgets(
      'confirmation dialog communicates the deletion is permanent (FR-016)',
      (tester) async {
        when(
          () => productRepository.get(productId: 1),
        ).thenAnswer((_) async => _product());

        await pumpScreen(tester, signedInAs: _deleteUser, productId: 1);

        await tester.ensureVisible(
          find.byKey(const Key('delete_product_button')),
        );
        await tester.tap(find.byKey(const Key('delete_product_button')));
        await tester.pumpAndSettle();

        expect(find.text('Delete product permanently?'), findsOneWidget);
        expect(find.textContaining('cannot be undone'), findsOneWidget);
      },
    );

    testWidgets(
      'deletes permanently after confirmation and returns to the list '
      '(FR-016a)',
      (tester) async {
        when(
          () => productRepository.get(productId: 1),
        ).thenAnswer((_) async => _product());
        when(
          () => productRepository.delete(productId: 1),
        ).thenAnswer((_) async {});

        await pumpScreenWithRouter(
          tester,
          signedInAs: _deleteUser,
          productId: 1,
        );

        await tester.ensureVisible(
          find.byKey(const Key('delete_product_button')),
        );
        await tester.tap(find.byKey(const Key('delete_product_button')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('confirm_delete_product_button')),
        );
        await tester.pumpAndSettle();

        verify(() => productRepository.delete(productId: 1)).called(1);
        expect(find.byType(ProductDetailScreen), findsNothing);
      },
    );

    group('view pricing shortcut', () {
      testWidgets('regression guard: the product detail form no longer shows a '
          '"view pricing" shortcut button, even with pricing read access', (
        tester,
      ) async {
        when(
          () => productRepository.get(productId: 1),
        ).thenAnswer((_) async => _product());

        await pumpScreen(
          tester,
          signedInAs: _editUserWithPricing,
          productId: 1,
        );

        expect(find.byKey(const Key('view_pricing_button')), findsNothing);
      });
    });
  });

  group('responsive form layout (US2)', () {
    testWidgets(
      'lays fields into exactly two columns on a wide viewport without '
      'overflow (FR-008, FR-009)',
      (tester) async {
        // A wide (large-tier) viewport: >= 1200 logical px. The form caps at
        // two columns even here (maxColumns: 2).
        tester.view.physicalSize = const Size(1600, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await pumpScreen(tester, signedInAs: _createUser);

        // The responsive grid is in use and all fields are still present.
        expect(find.byType(ResponsiveFormGrid), findsOneWidget);
        expect(find.byKey(const Key('code_field')), findsOneWidget);
        expect(find.byKey(const Key('name_field')), findsOneWidget);

        // Code and Name pair on the first row (same top edge, different x). A
        // RenderFlex overflow during pump would already have failed the test.
        final codeTop = tester.getTopLeft(find.byKey(const Key('code_field')));
        final nameTop = tester.getTopLeft(find.byKey(const Key('name_field')));
        expect(codeTop.dy, nameTop.dy);
        expect(codeTop.dx, lessThan(nameTop.dx));

        // Two columns only: the third field (sku) wraps to the next row
        // under Code, rather than sitting in a third column beside Name —
        // and unit (the fourth field) pairs beside it under Name.
        final skuTop = tester.getTopLeft(find.byKey(const Key('sku_field')));
        final unitTop = tester.getTopLeft(
          find.byKey(const Key('unit_of_measurement_field')),
        );
        expect(skuTop.dy, greaterThan(codeTop.dy));
        expect(skuTop.dx, codeTop.dx);
        expect(unitTop.dy, skuTop.dy);
        expect(unitTop.dx, nameTop.dx);
      },
    );

    testWidgets(
      'brackets the attributes/labels band with dividers (Material 3)',
      (tester) async {
        tester.view.physicalSize = const Size(1600, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        when(
          () => productRepository.get(productId: 1),
        ).thenAnswer((_) async => _product());

        await pumpScreen(tester, signedInAs: _editUser, productId: 1);

        final topDivider = tester.getTopLeft(
          find.byKey(const Key('attributes_divider_top')),
        );
        final bottomDivider = tester.getTopLeft(
          find.byKey(const Key('attributes_divider_bottom')),
        );
        final stockable = tester.getTopLeft(
          find.byKey(const Key('stockable_switch')),
        );
        // Top divider is above the switches, bottom divider below them.
        expect(topDivider.dy, lessThan(stockable.dy));
        expect(bottomDivider.dy, greaterThan(stockable.dy));
      },
    );

    testWidgets('never renders a price-list section (FR-012)', (tester) async {
      when(
        () => productRepository.get(productId: 1),
      ).thenAnswer((_) async => _product());

      await pumpScreen(
        tester,
        signedInAs: _editUser,
        productId: 1,
        labels: const [LabelItem(labelId: 1, name: 'Clearance')],
      );

      expect(find.text('Prices'), findsNothing);
      expect(find.byKey(const Key('label_multi_picker')), findsOneWidget);
    });

    testWidgets(
      'stacks fields into a single column on a narrow viewport (FR-009)',
      (tester) async {
        // A compact viewport: < 600 logical px -> 1 column.
        tester.view.physicalSize = const Size(500, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await pumpScreen(tester, signedInAs: _createUser);

        final codeTop = tester.getTopLeft(find.byKey(const Key('code_field')));
        final nameTop = tester.getTopLeft(find.byKey(const Key('name_field')));
        // Single column: Name is below Code, sharing the same left edge.
        expect(nameTop.dy, greaterThan(codeTop.dy));
        expect(codeTop.dx, nameTop.dx);
      },
    );

    testWidgets(
      'places the photo actions beside the thumbnail on a wide viewport (US3, '
      'FR-012)',
      (tester) async {
        tester.view.physicalSize = const Size(1600, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        when(() => productRepository.get(productId: 1)).thenAnswer(
          (_) async => _product().copyWith(photo: 'http://test/p.png'),
        );

        await pumpScreen(tester, signedInAs: _editUser, productId: 1);

        // The Replace/Remove controls sit to the right of the thumbnail
        // (beside it), not stacked below — their left edge is past the
        // thumbnail's right edge.
        final photoRight = tester.getBottomRight(find.byType(ProductPhoto)).dx;
        final replaceLeft = tester
            .getTopLeft(find.byKey(const Key('replace_photo_button')))
            .dx;
        expect(replaceLeft, greaterThan(photoRight));
        expect(find.byKey(const Key('remove_photo_button')), findsOneWidget);
      },
    );

    testWidgets(
      'places the labels control beside the switches on a wide viewport '
      '(FR-013)',
      (tester) async {
        tester.view.physicalSize = const Size(1600, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        when(
          () => productRepository.get(productId: 1),
        ).thenAnswer((_) async => _product());

        await pumpScreen(
          tester,
          signedInAs: _editUser,
          productId: 1,
          labels: const [LabelItem(labelId: 1, name: 'Clearance')],
        );

        // Labels header sits to the right of the switches (two-column band),
        // not below them.
        final switchLeft = tester
            .getTopLeft(find.byKey(const Key('stockable_switch')))
            .dx;
        final labelsLeft = tester
            .getTopLeft(find.byKey(const Key('label_multi_picker')))
            .dx;
        expect(labelsLeft, greaterThan(switchLeft));
      },
    );

    testWidgets(
      'stacks the labels control below the switches on a compact viewport '
      '(FR-013 compact fallback)',
      (tester) async {
        tester.view.physicalSize = const Size(500, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        when(
          () => productRepository.get(productId: 1),
        ).thenAnswer((_) async => _product());

        await pumpScreen(
          tester,
          signedInAs: _editUser,
          productId: 1,
          labels: const [LabelItem(labelId: 1, name: 'Clearance')],
        );

        final switchBottom = tester
            .getBottomLeft(find.byKey(const Key('invoiceable_switch')))
            .dy;
        final labelsTop = tester
            .getTopLeft(find.byKey(const Key('label_multi_picker')))
            .dy;
        expect(labelsTop, greaterThan(switchBottom));
      },
    );

    testWidgets(
      'stacks the photo actions below the thumbnail on a compact viewport '
      '(US3 compact fallback)',
      (tester) async {
        tester.view.physicalSize = const Size(500, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        when(() => productRepository.get(productId: 1)).thenAnswer(
          (_) async => _product().copyWith(photo: 'http://test/p.png'),
        );

        await pumpScreen(tester, signedInAs: _editUser, productId: 1);

        final photoBottom = tester.getBottomRight(find.byType(ProductPhoto)).dy;
        final replaceTop = tester
            .getTopLeft(find.byKey(const Key('replace_photo_button')))
            .dy;
        expect(replaceTop, greaterThan(photoBottom));
      },
    );
  });

  group('regression guard: spec 011 must not reintroduce prices (FR-007a)', () {
    testWidgets(
      'the product form shows no price section or price values anywhere, '
      'and labels still occupy the switches|labels band (007 FR-012/FR-013; '
      'spec 011 FR-007a, research.md §1)',
      (tester) async {
        when(
          () => productRepository.get(productId: 1),
        ).thenAnswer((_) async => _product());

        await pumpScreen(
          tester,
          signedInAs: _editUser,
          productId: 1,
          labels: const [LabelItem(labelId: 1, name: 'Fragile')],
        );

        // No price-related field, column, or currency text anywhere on the
        // form — spec 011's pricing tool lives on its own /pricing screen,
        // not here (research.md §1, decided 2026-07-14).
        expect(find.textContaining(RegExp(r'[Pp]rice')), findsNothing);
        expect(find.byKey(const Key('price_field')), findsNothing);
        expect(find.byKey(const Key('high_profit_margin_field')), findsNothing);
        expect(find.byKey(const Key('low_profit_margin_field')), findsNothing);

        // The switches|labels band (007's replacement for the old price
        // section) is intact: the labels control renders in that band.
        expect(find.byKey(const Key('attributes_divider_top')), findsOneWidget);
        expect(find.byKey(const Key('label_multi_picker')), findsOneWidget);
        expect(
          find.byKey(const Key('attributes_divider_bottom')),
          findsOneWidget,
        );
      },
    );
  });
}
