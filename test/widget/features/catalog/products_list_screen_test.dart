import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_label_facet.dart';
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
    List<LabelItem> labels = const [],
    // `null` (default) => every label in [labels] is reported available, so
    // existing/unrelated tests keep today's all-enabled behavior. Tests
    // exercising the facet-driven enable/disable pass an explicit list.
    List<ProductLabelFacet>? labelFacets,
  }) async {
    when(() => authRepository.me()).thenAnswer((_) async => signedInAs);
    when(
      () => productRepository.list(
        search: any(named: 'search'),
        deactivated: any(named: 'deactivated'),
        stockable: any(named: 'stockable'),
        salable: any(named: 'salable'),
        purchasable: any(named: 'purchasable'),
        labels: any(named: 'labels'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => ProductListResult(items: products, total: products.length),
    );
    final effectiveFacets = labelFacets ??
        labels
            .map((l) => ProductLabelFacet(labelId: l.labelId, count: 1))
            .toList();
    when(
      () => productRepository.productLabelFacets(
        search: any(named: 'search'),
        deactivated: any(named: 'deactivated'),
        stockable: any(named: 'stockable'),
        salable: any(named: 'salable'),
        purchasable: any(named: 'purchasable'),
        labels: any(named: 'labels'),
      ),
    ).thenAnswer((_) async => effectiveFacets);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          productRepositoryProvider.overrideWithValue(productRepository),
          allLabelsProvider.overrideWith((_) async => labels),
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

  /// Like [pumpScreen], but backed by a real `GoRouter` so tests can assert
  /// on where a row click/action navigates (FR-003, FR-004). The
  /// destination route renders the matched URI as text so tests can assert
  /// on it directly.
  Future<void> pumpScreenWithRouter(
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

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const ProductsListScreen()),
        GoRoute(
          path: '/products/:productId',
          builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
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
      expect(photos[0].size, 84);
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
          labels: any(named: 'labels'),
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
          labels: const [],
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

  testWidgets(
    'the label filter is multi-select, not a single-choice dropdown '
    '(FR-007)',
    (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _readOnlyUser,
        labels: const [
          LabelItem(labelId: 1, name: 'Clearance'),
          LabelItem(labelId: 2, name: 'Seasonal'),
        ],
      );
      await openFilterSheet(tester);

      expect(find.byType(DropdownButton<int?>), findsNothing);
      expect(find.byKey(const Key('products_filter_label')), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Clearance'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Seasonal'), findsOneWidget);
    },
  );

  testWidgets(
    'selecting two labels sends both and narrows the list to products '
    'carrying all of them — AND, not OR (spec 009 FR-001, FR-002; also '
    'counts 2 toward the badge, FR-008, FR-009)',
    (tester) async {
      const clearance = LabelItem(labelId: 1, name: 'Clearance');
      const seasonal = LabelItem(labelId: 2, name: 'Seasonal');
      final bothProducts = _testProducts; // 2 items with labels [1]
      final narrowedProduct = [_testProducts.first]; // only 1 has both

      await pumpScreen(
        tester,
        signedInAs: _readOnlyUser,
        labels: const [clearance, seasonal],
      );
      // Selecting just Clearance -> both fixture products (server-side AND
      // with a single label is a no-op narrowing).
      when(
        () => productRepository.list(
          search: any(named: 'search'),
          deactivated: any(named: 'deactivated'),
          stockable: any(named: 'stockable'),
          salable: any(named: 'salable'),
          purchasable: any(named: 'purchasable'),
          labels: [1],
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async =>
            ProductListResult(items: bothProducts, total: bothProducts.length),
      );
      // Adding Seasonal (AND) -> narrows to the single product with both.
      when(
        () => productRepository.list(
          search: any(named: 'search'),
          deactivated: any(named: 'deactivated'),
          stockable: any(named: 'stockable'),
          salable: any(named: 'salable'),
          purchasable: any(named: 'purchasable'),
          labels: [1, 2],
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => ProductListResult(
          items: narrowedProduct,
          total: narrowedProduct.length,
        ),
      );
      await openFilterSheet(tester);

      await tester.tap(find.widgetWithText(FilterChip, 'Clearance'));
      await tester.pumpAndSettle();
      expect(find.text('SKU-001'), findsOneWidget);
      expect(find.text('SKU-002'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'Seasonal'));
      await tester.pumpAndSettle();

      verify(
        () => productRepository.list(
          search: any(named: 'search'),
          deactivated: any(named: 'deactivated'),
          stockable: any(named: 'stockable'),
          salable: any(named: 'salable'),
          purchasable: any(named: 'purchasable'),
          labels: [1, 2],
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).called(greaterThanOrEqualTo(1));
      // Combining labels narrowed the list, it did not broaden it (AND).
      expect(find.text('SKU-001'), findsOneWidget);
      expect(find.text('SKU-002'), findsNothing);

      final filterBadge = tester.widget<Badge>(
        find.ancestor(
          of: find.byKey(const Key('products_filter_button')),
          matching: find.byType(Badge),
        ),
      );
      expect(
        filterBadge.label,
        isA<Text>().having((t) => t.data, 'data', '2'),
      );
    },
  );

  testWidgets(
    'Clear all empties the label selection along with the other facets',
    (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _readOnlyUser,
        labels: const [LabelItem(labelId: 1, name: 'Clearance')],
      );
      await openFilterSheet(tester);

      await tester.tap(find.widgetWithText(FilterChip, 'Clearance'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Clearance'))
            .selected,
        isTrue,
      );

      await tester.tap(find.byKey(const Key('filter_sheet_clear_all_button')));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Clearance'))
            .selected,
        isFalse,
      );
    },
  );

  group('faceted label availability (spec 009)', () {
    bool chipInteractive(WidgetTester tester, String label) =>
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, label))
            .onSelected !=
        null;

    testWidgets(
      'selecting a label disables labels that no longer co-occur, while the '
      'selected one and its co-occurring labels stay interactive (FR-003, '
      'FR-004, FR-006)',
      (tester) async {
        const trupper = LabelItem(labelId: 1, name: 'Trupper');
        const dewalt = LabelItem(labelId: 2, name: 'DeWalt');
        const makita = LabelItem(labelId: 3, name: 'Makita');

        await pumpScreen(
          tester,
          signedInAs: _readOnlyUser,
          labels: const [trupper, dewalt, makita],
        );
        // With Trupper selected, only Trupper+DeWalt co-occur; Makita does not.
        when(
          () => productRepository.productLabelFacets(
            search: any(named: 'search'),
            deactivated: any(named: 'deactivated'),
            stockable: any(named: 'stockable'),
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            labels: [1],
          ),
        ).thenAnswer(
          (_) async => const [
            ProductLabelFacet(labelId: 1, count: 2),
            ProductLabelFacet(labelId: 2, count: 1),
          ],
        );
        await openFilterSheet(tester);

        await tester.tap(find.widgetWithText(FilterChip, 'Trupper'));
        await tester.pumpAndSettle();

        expect(chipInteractive(tester, 'Trupper'), isTrue); // selected
        expect(chipInteractive(tester, 'DeWalt'), isTrue); // available
        expect(chipInteractive(tester, 'Makita'), isFalse); // unavailable
      },
    );

    testWidgets(
      'while the facet lookup is loading or fails, every label stays '
      'selectable — fail open (FR-010)',
      (tester) async {
        const trupper = LabelItem(labelId: 1, name: 'Trupper');
        const makita = LabelItem(labelId: 2, name: 'Makita');

        await pumpScreen(
          tester,
          signedInAs: _readOnlyUser,
          labels: const [trupper, makita],
        );
        when(
          () => productRepository.productLabelFacets(
            search: any(named: 'search'),
            deactivated: any(named: 'deactivated'),
            stockable: any(named: 'stockable'),
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            labels: any(named: 'labels'),
          ),
        ).thenThrow(const AppError.server());
        await openFilterSheet(tester);

        expect(chipInteractive(tester, 'Trupper'), isTrue);
        expect(chipInteractive(tester, 'Makita'), isTrue);
      },
    );

    testWidgets(
      'deselecting a label re-enables labels that co-occur with the '
      'remaining selection (FR-007)',
      (tester) async {
        const trupper = LabelItem(labelId: 1, name: 'Trupper');
        const dewalt = LabelItem(labelId: 2, name: 'DeWalt');
        const makita = LabelItem(labelId: 3, name: 'Makita');

        await pumpScreen(
          tester,
          signedInAs: _readOnlyUser,
          labels: const [trupper, dewalt, makita],
        );
        when(
          () => productRepository.productLabelFacets(
            search: any(named: 'search'),
            deactivated: any(named: 'deactivated'),
            stockable: any(named: 'stockable'),
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            labels: [1, 2],
          ),
        ).thenAnswer(
          (_) async => const [
            ProductLabelFacet(labelId: 1, count: 1),
            ProductLabelFacet(labelId: 2, count: 1),
          ],
        );
        when(
          () => productRepository.productLabelFacets(
            search: any(named: 'search'),
            deactivated: any(named: 'deactivated'),
            stockable: any(named: 'stockable'),
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            labels: [1],
          ),
        ).thenAnswer(
          (_) async => const [
            ProductLabelFacet(labelId: 1, count: 2),
            ProductLabelFacet(labelId: 2, count: 1),
            ProductLabelFacet(labelId: 3, count: 1),
          ],
        );
        await openFilterSheet(tester);

        await tester.tap(find.widgetWithText(FilterChip, 'Trupper'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilterChip, 'DeWalt'));
        await tester.pumpAndSettle();
        expect(chipInteractive(tester, 'Makita'), isFalse);

        await tester.tap(find.widgetWithText(FilterChip, 'DeWalt'));
        await tester.pumpAndSettle();

        expect(chipInteractive(tester, 'Makita'), isTrue);
      },
    );

    testWidgets(
      'Clear all restores the all-enabled label drawer (FR-008)',
      (tester) async {
        const trupper = LabelItem(labelId: 1, name: 'Trupper');
        const makita = LabelItem(labelId: 2, name: 'Makita');

        await pumpScreen(
          tester,
          signedInAs: _readOnlyUser,
          labels: const [trupper, makita],
        );
        when(
          () => productRepository.productLabelFacets(
            search: any(named: 'search'),
            deactivated: any(named: 'deactivated'),
            stockable: any(named: 'stockable'),
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            labels: [1],
          ),
        ).thenAnswer(
          (_) async => const [ProductLabelFacet(labelId: 1, count: 1)],
        );
        await openFilterSheet(tester);

        await tester.tap(find.widgetWithText(FilterChip, 'Trupper'));
        await tester.pumpAndSettle();
        expect(chipInteractive(tester, 'Makita'), isFalse);

        await tester.tap(find.byKey(const Key('filter_sheet_clear_all_button')));
        await tester.pumpAndSettle();

        expect(chipInteractive(tester, 'Trupper'), isTrue);
        expect(chipInteractive(tester, 'Makita'), isTrue);
      },
    );
  });

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
    'shows only the Edit row action for a user with update rights '
    '(FR-001, FR-002)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      final rowActionIcons = {Icons.edit_outlined, Icons.delete_outline};
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

      // One Edit icon per row (both rows), never a Delete icon.
      expect(icons, [Icons.edit_outlined, Icons.edit_outlined]);
    },
  );

  testWidgets(
    'omits the Edit row action for a read-only user (FR-004)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser);

      final rowActionIcons = {Icons.edit_outlined, Icons.delete_outline};
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

      expect(icons, isEmpty);
    },
  );

  testWidgets(
    'no column is frozen/pinned (FR-001)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser);

      expect(
        tester
            .widget<DataTable2>(
              find.descendant(
                of: find.byKey(const Key('products_table')),
                matching: find.byType(DataTable2),
              ),
            )
            .fixedLeftColumns,
        0,
      );
    },
  );

  testWidgets(
    'shows the photo as the first column with a blank header (FR-019)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser);

      final headerRow = tester.widget<DataTable2>(
        find.descendant(
          of: find.byKey(const Key('products_table')),
          matching: find.byType(DataTable2),
        ),
      );
      final labels = headerRow.columns
          .map((c) => (c.label as Text).data ?? '')
          .toList();

      expect(labels.first, '');
      // Every column between the photo and the trailing row-actions column
      // (which also has no header, by existing design) has a label.
      expect(
        labels.sublist(1, labels.length - 1).every((l) => l.isNotEmpty),
        isTrue,
      );

      // The photo cell sits to the left of the code cell in each row.
      final photoLeft = tester
          .getTopLeft(
            find
                .descendant(
                  of: find.byKey(const Key('products_table')),
                  matching: find.byType(ProductPhoto),
                )
                .first,
          )
          .dx;
      final codeLeft = tester.getTopLeft(find.text('SKU-001')).dx;
      expect(photoLeft, lessThan(codeLeft));
    },
  );

  testWidgets(
    'copies the product code to the clipboard with a confirmation (FR-020)',
    (tester) async {
      // Mocked directly rather than round-tripping through
      // Clipboard.getData(): this Flutter SDK's test binding doesn't
      // auto-provide a response for the platform clipboard-read channel,
      // so awaiting it hangs indefinitely. Capturing the Clipboard.setData
      // call is sufficient to verify the copied value.
      String? copiedText;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copiedText = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await pumpScreen(tester, signedInAs: _readOnlyUser);

      // Invoked directly rather than via tester.tap(): PaginatedDataTable2's
      // scrollable render tree makes precise hit-testing of small nested
      // cell widgets unreliable in the test environment. This still
      // exercises the real onPressed behavior.
      final button = tester.widget<IconButton>(
        find.byKey(const Key('copy_code_button_1')),
      );
      button.onPressed!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(copiedText, 'SKU-001');
      expect(find.text('Code copied to clipboard'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping a row opens the product read-only, not the editable form '
    '(FR-003)',
    (tester) async {
      await pumpScreenWithRouter(tester, signedInAs: _fullAccessUser);

      await tester.tap(find.text('Widget'));
      await tester.pumpAndSettle();

      expect(find.text('/products/1?view=true'), findsOneWidget);
    },
  );

  testWidgets(
    'the Edit row action opens the product editable form (FR-004)',
    (tester) async {
      await pumpScreenWithRouter(tester, signedInAs: _fullAccessUser);

      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();

      expect(find.text('/products/1'), findsOneWidget);
    },
  );

  testWidgets(
    'shows the Merge entry point for a user with productsMerge/create '
    '(specs/008-merge-products FR-012)',
    (tester) async {
      const mergeUser = User(
        userId: 'merger',
        email: 'merger@example.com',
        administrator: false,
        disabled: false,
        sessionVersion: 1,
        privileges: [
          Privilege(systemObject: SystemObject.products, rawValue: 2),
          Privilege(systemObject: SystemObject.productsMerge, rawValue: 1),
        ],
      );
      await pumpScreen(tester, signedInAs: mergeUser);

      expect(find.byKey(const Key('merge_products_button')), findsOneWidget);
    },
  );

  testWidgets(
    'hides the Merge entry point for a user without productsMerge/create '
    '(specs/008-merge-products FR-012)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.byKey(const Key('merge_products_button')), findsNothing);
    },
  );
}
