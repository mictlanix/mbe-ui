import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/products_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockProductRepository extends Mock implements ProductRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 15)],
);

const _testProducts = [
  ProductListItem(
    productId: 1,
    code: 'SKU-001',
    name: 'Widget',
    unitOfMeasurementCode: 'PCE',
    unitOfMeasurementName: 'Piece',
    taxRate: '0.16',
    deactivated: false,
    photo: 'http://test/images/widget.png',
  ),
  ProductListItem(
    productId: 2,
    code: 'SKU-002',
    name: 'Gadget',
    unitOfMeasurementCode: 'PCE',
    unitOfMeasurementName: 'Piece',
    taxRate: '0.16',
    deactivated: true,
  ),
];

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
    List<ProductListItem> products = _testProducts,
  }) async {
    when(() => authRepository.me()).thenAnswer((_) async => signedInAs);
    when(
      () => productRepository.list(
        search: any(named: 'search'),
        deactivated: any(named: 'deactivated'),
        stockable: any(named: 'stockable'),
        salable: any(named: 'salable'),
        purchasable: any(named: 'purchasable'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => ProductListResult(items: products, total: products.length),
    );

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
          home: const ProductsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Opens the filter panel by tapping the Filters button (facets now live in
  /// a sheet rather than inline; FR-001/FR-003).
  Future<void> openFilterSheet(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('products_filter_button')));
    await tester.pumpAndSettle();
  }

  testWidgets('shows products with their status (FR-001, FR-002)', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser);

    expect(find.text('SKU-001'), findsOneWidget);
    expect(find.text('Widget'), findsOneWidget);
    expect(find.text('SKU-002'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.byKey(const Key('inactive_badge')), findsOneWidget);
    expect(find.text('Inactive'), findsOneWidget);
  });

  testWidgets(
    'shows a ProductPhoto per row, with the placeholder for a product with '
    'no photo (FR-001, FR-002)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser);

      final photos = tester
          .widgetList<ProductPhoto>(
            find.descendant(
              of: find.byKey(const Key('products_table')),
              matching: find.byType(ProductPhoto),
            ),
          )
          .toList();

      expect(photos, hasLength(_testProducts.length));
      expect(photos[0].photoUrl, 'http://test/images/widget.png');
      expect(photos[1].photoUrl, isNull);
    },
  );

  testWidgets(
    'shows the search field and a Filters button; facets live in the sheet '
    '(FR-001, FR-002, FR-003)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser);

      // At rest: only the search box and the Filters button — no inline facets.
      expect(find.byKey(const Key('products_search_field')), findsOneWidget);
      expect(find.byKey(const Key('products_filter_button')), findsOneWidget);
      expect(
        find.byKey(const Key('products_filter_show_inactive')),
        findsNothing,
      );
      expect(find.byKey(const Key('products_filter_stockable')), findsNothing);

      // Opening the panel reveals every facet control.
      await openFilterSheet(tester);
      expect(
        find.byKey(const Key('products_filter_show_inactive')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('products_filter_stockable')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('products_filter_salable')), findsOneWidget);
      expect(
        find.byKey(const Key('products_filter_purchasable')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'the Filters button badge counts active facets and clears via Clear all '
    '(FR-003, FR-004)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser);

      Badge filterBadge() => tester.widget<Badge>(
        find.ancestor(
          of: find.byKey(const Key('products_filter_button')),
          matching: find.byType(Badge),
        ),
      );

      // No badge at rest.
      expect(filterBadge().isLabelVisible, isFalse);

      // Activate the stockable facet -> badge shows a count of 1.
      await openFilterSheet(tester);
      await tester.tap(find.byKey(const Key('products_filter_stockable')));
      await tester.pumpAndSettle();
      expect(filterBadge().isLabelVisible, isTrue);
      expect(
        filterBadge().label,
        isA<Text>().having((t) => t.data, 'data', '1'),
      );

      // Clear all resets facets and removes the badge; the chip avatar clears.
      await tester.tap(find.byKey(const Key('filter_sheet_clear_all_button')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilterChip>(
              find.byKey(const Key('products_filter_stockable')),
            )
            .avatar,
        isNull,
      );
      expect(filterBadge().isLabelVisible, isFalse);
    },
  );

  testWidgets(
    'opens a right-anchored side sheet with facets on a wide viewport '
    '(FR-005)',
    (tester) async {
      // >= 840 logical px selects the side-sheet (showGeneralDialog) branch.
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpScreen(tester, signedInAs: _readOnlyUser);
      await openFilterSheet(tester);

      // The side-sheet chrome (titled header with a close button) and the
      // facets are present.
      expect(
        find.byKey(const Key('filter_sheet_close_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('products_filter_stockable')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('filter_sheet_apply_button')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'does not re-query while typing; queries only on submit (FR-010)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser);
      clearInteractions(productRepository);

      await tester.enterText(
        find.byKey(const Key('products_search_field')),
        'widget',
      );
      await tester.pump();

      verifyNever(
        () => productRepository.list(
          search: any(named: 'search'),
          deactivated: any(named: 'deactivated'),
          stockable: any(named: 'stockable'),
          salable: any(named: 'salable'),
          purchasable: any(named: 'purchasable'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      );

      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      verify(
        () => productRepository.list(
          search: 'widget',
          deactivated: null,
          stockable: null,
          salable: null,
          purchasable: null,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    },
  );

  testWidgets(
    'cycles the stockable filter through null -> true -> false -> null',
    (tester) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser);
      await openFilterSheet(tester);
      final chipFinder = find.byKey(const Key('products_filter_stockable'));

      await tester.tap(chipFinder);
      await tester.pumpAndSettle();
      expect(
        tester.widget<FilterChip>(chipFinder).avatar,
        isA<Icon>().having((i) => i.icon, 'icon', Icons.check),
      );

      await tester.tap(chipFinder);
      await tester.pumpAndSettle();
      expect(
        tester.widget<FilterChip>(chipFinder).avatar,
        isA<Icon>().having((i) => i.icon, 'icon', Icons.close),
      );

      await tester.tap(chipFinder);
      await tester.pumpAndSettle();
      expect(tester.widget<FilterChip>(chipFinder).avatar, isNull);
    },
  );

  testWidgets('shows an empty state when there are no matches', (tester) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser, products: const []);

    expect(find.text('No products found.'), findsOneWidget);
  });

  testWidgets('shows the New product action for a user with create right', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.byKey(const Key('new_product_button')), findsOneWidget);
  });

  testWidgets(
    'hides the New product action for a user without products.create',
    (tester) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser);

      expect(find.byKey(const Key('new_product_button')), findsNothing);
    },
  );

  testWidgets(
    'shows View/Edit/Delete row actions in fixed order for full access '
    '(FR-003, FR-004)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      final rowActionIcons = {
        Icons.visibility_outlined,
        Icons.edit_outlined,
        Icons.delete_outline,
      };
      final icons = tester
          .widgetList<IconButton>(
            find.descendant(
              of: find.byKey(const Key('products_table')),
              matching: find.byType(IconButton),
            ),
          )
          .map((b) => (b.icon as Icon).icon)
          .where(rowActionIcons.contains)
          .toList();

      // SKU-001 is active (View/Edit/Delete); SKU-002 is already deactivated,
      // so Delete is omitted for it even with full access.
      expect(icons, [
        Icons.visibility_outlined,
        Icons.edit_outlined,
        Icons.delete_outline,
        Icons.visibility_outlined,
        Icons.edit_outlined,
      ]);
    },
  );

  testWidgets(
    'omits Edit/Delete row actions for a read-only user, keeping View '
    '(FR-012)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser);

      final rowActionIcons = {
        Icons.visibility_outlined,
        Icons.edit_outlined,
        Icons.delete_outline,
      };
      final icons = tester
          .widgetList<IconButton>(
            find.descendant(
              of: find.byKey(const Key('products_table')),
              matching: find.byType(IconButton),
            ),
          )
          .map((b) => (b.icon as Icon).icon)
          .where(rowActionIcons.contains)
          .toList();

      expect(icons, [Icons.visibility_outlined, Icons.visibility_outlined]);
    },
  );
}
