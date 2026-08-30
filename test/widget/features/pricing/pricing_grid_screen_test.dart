import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_missing_price_facet.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/product_price_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_grid_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockPriceListRepository extends Mock implements PriceListRepository {}

class MockProductPriceRepository extends Mock implements ProductPriceRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.pricing, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.pricing, rawValue: 6)],
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

const _retail = PriceList(
  priceListId: 5,
  name: 'Retail',
);

/// The deployment's cost list sits at id **0** — a falsy primary key, which is
/// why every check on a price-list id in this feature tests for null rather
/// than truthiness (FR-019a).
const _costo = PriceList(
  priceListId: 0,
  name: 'Costo',
);

ProductListItem _product(int id, {String code = 'SKU', String name = 'Product'}) =>
    ProductListItem(
      productId: id,
      code: '$code-$id',
      name: '$name $id',
      unitOfMeasurementCode: 'PCE',
      unitOfMeasurementName: 'Piece',
      taxRate: '0.16',
      status: EntityStatus.active,
    );

void main() {
  late MockProductRepository productRepository;
  late MockPriceListRepository priceListRepository;
  late MockProductPriceRepository productPriceRepository;

  setUp(() {
    productRepository = MockProductRepository();
    priceListRepository = MockPriceListRepository();
    productPriceRepository = MockProductPriceRepository();
    // Default: the worklist facet call answers with nothing. Tests that care
    // about the chips override this.
    when(
      () => productRepository.productMissingPriceFacets(
        search: any(named: 'search'),
        status: any(named: 'status'),
        stockable: any(named: 'stockable'),
        salable: any(named: 'salable'),
        purchasable: any(named: 'purchasable'),
        supplier: any(named: 'supplier'),
        labels: any(named: 'labels'),
      ),
    ).thenAnswer((_) async => const []);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    ListQuery query = const ListQuery(),
    bool settle = true,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    // The grid is desktop-first and sizes itself to `640 + 176 per shown
    // price list`, so the 800x600 default surface puts the second price
    // column outside the viewport — where a tap cannot reach it. Pump at a
    // realistic desktop width instead of asserting against a layout no user
    // has (constitution §VI).
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          productRepositoryProvider.overrideWithValue(productRepository),
          priceListRepositoryProvider.overrideWithValue(priceListRepository),
          productPriceRepositoryProvider.overrideWithValue(productPriceRepository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: PricingGridScreen(query: query)),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  /// Like [pumpScreen], but behind a real `GoRouter` so `context.go` resolves
  /// — the only way to observe that a navigation the screen guards actually
  /// went through. Returns the router, whose location is the assertion.
  Future<GoRouter> pumpRoutedScreen(
    WidgetTester tester, {
    required User signedInAs,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final router = GoRouter(
      initialLocation: '/pricing',
      routes: [
        GoRoute(
          path: '/pricing',
          builder: (context, state) =>
              Scaffold(body: PricingGridScreen(query: ListQuery.fromUri(state.uri))),
        ),
      ],
    );
    addTearDown(router.dispose);

    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          productRepositoryProvider.overrideWithValue(productRepository),
          priceListRepositoryProvider.overrideWithValue(priceListRepository),
          productPriceRepositoryProvider.overrideWithValue(productPriceRepository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    return router;
  }

  testWidgets(
    'renders a populated grid with no product selection required (FR-001), '
    'one column per price list',
    (tester) async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productRepository.list(
          search: null,
          status: null,
          stockable: null,
          salable: null,
          purchasable: null,
          supplier: null,
          labels: const [],
          missingPriceList: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => ProductListResult(items: [_product(1), _product(2)], total: 2),
      );
      when(
        () => productPriceRepository.listForProducts(
          productIds: [1, 2],
          priceListIds: [5],
        ),
      ).thenAnswer(
        (_) async => [
          ProductPrice(
            productPriceId: 100,
            productId: 1,
            priceList: _retail,
            price: '25.00',
          ),
        ],
      );

      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.byKey(const Key('pricing_grid_table')), findsOneWidget);
      expect(find.text('Retail'), findsOneWidget);
      expect(find.text('SKU-1'), findsOneWidget);
      expect(find.text('SKU-2'), findsOneWidget);
    },
  );

  testWidgets(
    'a product with no price on a list shows "not set", distinct from a '
    'stored price of zero (FR-005)',
    (tester) async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productRepository.list(
          search: null,
          status: null,
          stockable: null,
          salable: null,
          purchasable: null,
          supplier: null,
          labels: const [],
          missingPriceList: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer((_) async => ProductListResult(items: [_product(1)], total: 1));
      when(
        () => productPriceRepository.listForProducts(
          productIds: [1],
          priceListIds: [5],
        ),
      ).thenAnswer((_) async => const []);

      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.text('Not set'), findsOneWidget);
    },
  );

  testWidgets(
    'no price lists exist shows the shared "create one first" empty state '
    'rather than an empty grid frame',
    (tester) async {
      when(
        () => priceListRepository.list(limit: 100),
      ).thenAnswer((_) async => const PriceListResult(items: [], total: 0));

      await pumpScreen(tester, signedInAs: _fullAccessUser);

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(l10n.pricingNoPriceListsEmptyState), findsOneWidget);
      expect(find.byKey(const Key('pricing_grid_table')), findsNothing);
    },
  );

  group('column actions menu (US3, mbe-api#183)', () {
    void primeGrid() {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail, _costo], total: 2),
      );
      when(
        () => productRepository.list(
          search: null,
          status: null,
          stockable: null,
          salable: null,
          purchasable: null,
          supplier: null,
          labels: const [],
          missingPriceList: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer((_) async => ProductListResult(items: [_product(1)], total: 1));
      when(
        () => productPriceRepository.listForProducts(
          productIds: [1],
          priceListIds: [5, 0],
        ),
      ).thenAnswer(
        (_) async => [
          ProductPrice(
            productPriceId: 100,
            productId: 1,
            priceList: _retail,
            price: '25.00',
          ),
        ],
      );
    }

    testWidgets('a user with update rights gets the ⋮ menu on each price '
        'column (FR-013)', (tester) async {
      primeGrid();

      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(
        find.byKey(const Key('pricing_grid_column_menu_5')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('pricing_grid_column_menu_0')),
        findsOneWidget,
      );
    });

    testWidgets(
      'a read-only user gets no menu at all — absent, not disabled (FR-026)',
      (tester) async {
        primeGrid();

        await pumpScreen(tester, signedInAs: _readOnlyUser);

        expect(find.byKey(const Key('pricing_grid_column_menu_5')), findsNothing);
        expect(find.byIcon(Icons.more_vert), findsNothing);
      },
    );

    testWidgets('the menu offers fill-down, copy-from-cost naming the cost '
        'list, and an adjust-by-percent row (FR-013)', (tester) async {
      primeGrid();
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      await tester.tap(find.byKey(const Key('pricing_grid_column_menu_5')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pricing_grid_fill_down_5')), findsOneWidget);
      expect(find.byKey(const Key('pricing_grid_copy_cost_5')), findsOneWidget);
      expect(find.text('Copy from Costo'), findsOneWidget);
      expect(
        find.byKey(const Key('pricing_grid_adjust_field_5')),
        findsOneWidget,
      );
    });

    testWidgets(
      'the cost column offers no copy-from-cost — copying a list into itself '
      'is not an action (FR-013)',
      (tester) async {
        primeGrid();
        await pumpScreen(tester, signedInAs: _fullAccessUser);

        await tester.tap(find.byKey(const Key('pricing_grid_column_menu_0')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('pricing_grid_fill_down_0')), findsOneWidget);
        expect(find.byKey(const Key('pricing_grid_copy_cost_0')), findsNothing);
      },
    );

    testWidgets('applying a percentage issues one bulk write and reports how '
        'many rows changed (FR-014, FR-015)', (tester) async {
      primeGrid();
      when(() => productPriceRepository.applyPriceChanges(any())).thenAnswer((
        invocation,
      ) async {
        final writes =
            invocation.positionalArguments.first as List<PriceCellWrite>;
        return [
          for (final w in writes)
            ProductPrice(
              productPriceId: 100,
              productId: w.productId,
              priceList: _retail,
              price: w.price,
            ),
        ];
      });

      await pumpScreen(tester, signedInAs: _fullAccessUser);
      await tester.tap(find.byKey(const Key('pricing_grid_column_menu_5')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('pricing_grid_adjust_field_5')),
        '10',
      );
      await tester.tap(find.byKey(const Key('pricing_grid_adjust_apply_5')));
      await tester.pumpAndSettle();

      final captured =
          verify(() => productPriceRepository.applyPriceChanges(captureAny()))
                  .captured
                  .single
              as List<PriceCellWrite>;
      expect(captured, hasLength(1));
      expect(captured.single.price, '27.5');
      // Scoped to the SnackBar: the summary bar renders the same sentence,
      // which is the point — the report and the running count agree.
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text('1 price changed'),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'a failed column action says no prices changed, rather than implying a '
      'partial one (FR-015)',
      (tester) async {
        primeGrid();
        when(
          () => productPriceRepository.applyPriceChanges(any()),
        ).thenThrow(const AppError.server());

        await pumpScreen(tester, signedInAs: _fullAccessUser);
        await tester.tap(find.byKey(const Key('pricing_grid_column_menu_5')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('pricing_grid_adjust_field_5')),
          '10',
        );
        await tester.tap(find.byKey(const Key('pricing_grid_adjust_apply_5')));
        await tester.pumpAndSettle();

        expect(
          find.text('Could not apply the action. No prices changed.'),
          findsOneWidget,
        );
      },
    );
  });

  group('worklist chips (US2, mbe-api#184)', () {
    void primeGrid({int? missingPriceList}) {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail, _costo], total: 2),
      );
      when(
        () => productRepository.list(
          search: null,
          status: null,
          stockable: null,
          salable: null,
          purchasable: null,
          supplier: null,
          labels: const [],
          missingPriceList: missingPriceList,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer((_) async => ProductListResult(items: [_product(1)], total: 1));
      when(
        () => productPriceRepository.listForProducts(
          productIds: [1],
          priceListIds: [5, 0],
        ),
      ).thenAnswer((_) async => const []);
    }

    void primeFacets(List<ProductMissingPriceFacet> facets) {
      when(
        () => productRepository.productMissingPriceFacets(
          search: any(named: 'search'),
          status: any(named: 'status'),
          stockable: any(named: 'stockable'),
          salable: any(named: 'salable'),
          purchasable: any(named: 'purchasable'),
          supplier: any(named: 'supplier'),
          labels: any(named: 'labels'),
        ),
      ).thenAnswer((_) async => facets);
    }

    testWidgets('render an "all" chip plus one per shown list, with its '
        'count (FR-017)', (tester) async {
      primeGrid();
      primeFacets(const [
        ProductMissingPriceFacet(priceListId: 5, missingCount: 14),
        ProductMissingPriceFacet(priceListId: 0, missingCount: 3),
      ]);

      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.byKey(const Key('pricing_grid_worklist_all')), findsOneWidget);
      expect(find.text('Missing Retail (14)'), findsOneWidget);
      expect(find.text('Missing Costo (3)'), findsOneWidget);
    });

    testWidgets(
      'a price list at id 0 still gets its chip — Costo sits at id 0, and a '
      'truthiness check on the id would drop it (FR-019a)',
      (tester) async {
        primeGrid();
        primeFacets(const [
          ProductMissingPriceFacet(priceListId: 0, missingCount: 3),
        ]);

        await pumpScreen(tester, signedInAs: _fullAccessUser);

        expect(find.byKey(const Key('pricing_grid_worklist_0')), findsOneWidget);
      },
    );

    testWidgets(
      'the chip for the selected list is the one marked selected, including '
      'when that list is id 0 (FR-019a)',
      (tester) async {
        primeGrid(missingPriceList: 0);
        primeFacets(const [
          ProductMissingPriceFacet(priceListId: 0, missingCount: 3),
        ]);

        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          query: const ListQuery(
            facets: {
              'missing': ['0'],
            },
          ),
        );

        final selected = tester.widget<ChoiceChip>(
          find.byKey(const Key('pricing_grid_worklist_0')),
        );
        final all = tester.widget<ChoiceChip>(
          find.byKey(const Key('pricing_grid_worklist_all')),
        );
        expect(selected.selected, isTrue);
        expect(all.selected, isFalse);
      },
    );

    testWidgets(
      'selecting a worklist chip narrows the products request to that list',
      (tester) async {
        primeGrid(missingPriceList: 5);
        primeFacets(const [
          ProductMissingPriceFacet(priceListId: 5, missingCount: 14),
        ]);

        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          query: const ListQuery(
            facets: {
              'missing': ['5'],
            },
          ),
        );

        verify(
          () => productRepository.list(
            search: null,
            status: null,
            stockable: null,
            salable: null,
            purchasable: null,
            supplier: null,
            labels: const [],
            missingPriceList: 5,
            skip: 0,
            limit: 20,
          ),
        ).called(1);
      },
    );

    testWidgets(
      'a failed facet call renders NO chips rather than chips reading zero '
      '(FR-019)',
      (tester) async {
        primeGrid();
        when(
          () => productRepository.productMissingPriceFacets(
            search: any(named: 'search'),
            status: any(named: 'status'),
            stockable: any(named: 'stockable'),
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            supplier: any(named: 'supplier'),
            labels: any(named: 'labels'),
          ),
        ).thenThrow(const AppError.server());

        await pumpScreen(tester, signedInAs: _fullAccessUser);

        expect(find.byKey(const Key('pricing_grid_worklist_all')), findsNothing);
        expect(find.byKey(const Key('pricing_grid_worklist_5')), findsNothing);
        // The grid itself still renders — a facet failure is not a page failure.
        expect(find.byKey(const Key('pricing_grid_table')), findsOneWidget);
      },
    );

    testWidgets('the facet call carries no missing_price_list of its own, so '
        'selecting a chip does not move the other counts (FR-018)', (
      tester,
    ) async {
      primeGrid(missingPriceList: 5);
      primeFacets(const [
        ProductMissingPriceFacet(priceListId: 5, missingCount: 14),
      ]);

      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        query: const ListQuery(
          facets: {
            'missing': ['5'],
          },
        ),
      );

      // Still reads "14" while filtered to that very list.
      expect(find.text('Missing Retail (14)'), findsOneWidget);
    });
  });

  testWidgets(
    'read-only user reaches no editing affordance and sees the read-only '
    'hint (FR-026, US5)',
    (tester) async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productRepository.list(
          search: null,
          status: null,
          stockable: null,
          salable: null,
          purchasable: null,
          supplier: null,
          labels: const [],
          missingPriceList: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer((_) async => ProductListResult(items: [_product(1)], total: 1));
      when(
        () => productPriceRepository.listForProducts(
          productIds: [1],
          priceListIds: [5],
        ),
      ).thenAnswer(
        (_) async => [
          ProductPrice(
            productPriceId: 100,
            productId: 1,
            priceList: _retail,
            price: '25.00',
          ),
        ],
      );

      await pumpScreen(tester, signedInAs: _readOnlyUser);

      await tester.tap(find.byKey(const Key('price_cell_1_5')));
      await tester.pump();

      expect(find.byKey(const Key('price_cell_field_1_5')), findsNothing);
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(l10n.pricingGridReadOnlyHint), findsOneWidget);
      // The price itself is still legible — read-only is not "hidden".
      expect(find.textContaining('25.00'), findsOneWidget);
    },
  );

  testWidgets(
    'the undo shortcut is inert for a read-only user — a keyboard binding '
    'must not become the one editing affordance they can reach (FR-026)',
    (tester) async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productRepository.list(
          search: null,
          status: null,
          stockable: null,
          salable: null,
          purchasable: null,
          supplier: null,
          labels: const [],
          missingPriceList: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer((_) async => ProductListResult(items: [_product(1)], total: 1));
      when(
        () => productPriceRepository.listForProducts(
          productIds: [1],
          priceListIds: [5],
        ),
      ).thenAnswer((_) async => const []);

      await pumpScreen(tester, signedInAs: _readOnlyUser);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      verifyNever(() => productPriceRepository.applyPriceChanges(any()));
      expect(tester.takeException(), isNull);
    },
  );

  group('change summary bar & discard guard (US4)', () {
    void primeGrid() {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productRepository.list(
          search: null,
          status: null,
          stockable: null,
          salable: null,
          purchasable: null,
          supplier: null,
          labels: const [],
          missingPriceList: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer((_) async => ProductListResult(items: [_product(1)], total: 1));
      when(
        () => productPriceRepository.listForProducts(
          productIds: [1],
          priceListIds: [5],
        ),
      ).thenAnswer(
        (_) async => [
          ProductPrice(
            productPriceId: 100,
            productId: 1,
            priceList: _retail,
            price: '25.00',
          ),
        ],
      );
      when(
        () => productPriceRepository.update(productPriceId: 100, price: '30'),
      ).thenAnswer(
        (_) async => ProductPrice(
          productPriceId: 100,
          productId: 1,
          priceList: _retail,
          price: '30',
        ),
      );
    }

    /// A full first page against a larger total, so the pagination control is
    /// live. The row count must match the page size: `PaginatedDataTable2`
    /// renders every unfilled index as a *loading* row, and those spinners
    /// never settle.
    void primeGridPaged() {
      final products = [for (var i = 1; i <= 20; i++) _product(i)];
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productRepository.list(
          search: null,
          status: null,
          stockable: null,
          salable: null,
          purchasable: null,
          supplier: null,
          labels: const [],
          missingPriceList: null,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer((_) async => ProductListResult(items: products, total: 40));
      when(
        () => productPriceRepository.listForProducts(
          productIds: [for (var i = 1; i <= 20; i++) i],
          priceListIds: [5],
        ),
      ).thenAnswer(
        (_) async => [
          ProductPrice(
            productPriceId: 100,
            productId: 1,
            priceList: _retail,
            price: '25.00',
          ),
        ],
      );
      when(
        () => productPriceRepository.update(productPriceId: 100, price: '30'),
      ).thenAnswer(
        (_) async => ProductPrice(
          productPriceId: 100,
          productId: 1,
          priceList: _retail,
          price: '30',
        ),
      );
    }

    Future<void> editOneCell(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('price_cell_1_5')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('price_cell_field_1_5')),
        '30',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    testWidgets('is absent until something changes, then counts the change '
        '(FR-023)', (tester) async {
      primeGrid();
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.byKey(const Key('pricing_grid_summary_bar')), findsNothing);

      await editOneCell(tester);

      expect(find.byKey(const Key('pricing_grid_summary_bar')), findsOneWidget);
      expect(find.text('1 price changed'), findsOneWidget);
    });

    testWidgets('shows the saved badge and a "was" tooltip on the changed '
        'cell (FR-022)', (tester) async {
      primeGrid();
      await pumpScreen(tester, signedInAs: _fullAccessUser);
      await editOneCell(tester);

      expect(
        find.byKey(const Key('price_cell_badge_1_5')),
        findsOneWidget,
      );
      final tooltip = tester.widget<Tooltip>(
        find
            .ancestor(
              of: find.byKey(const Key('price_cell_1_5')),
              matching: find.byType(Tooltip),
            )
            .first,
      );
      expect(tooltip.message, contains('was'));
      expect(tooltip.message, contains('25.00'));
    });

    testWidgets('a rejected value counts separately and stays on screen '
        '(FR-009, FR-023)', (tester) async {
      primeGrid();
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      await tester.tap(find.byKey(const Key('price_cell_1_5')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('price_cell_field_1_5')),
        'abc',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('abc'), findsOneWidget);
      expect(find.textContaining('1 rejected'), findsOneWidget);
    });

    testWidgets('revert all restores the load-time value (FR-024)', (
      tester,
    ) async {
      primeGrid();
      when(() => productPriceRepository.applyPriceChanges(any())).thenAnswer((
        invocation,
      ) async {
        final writes =
            invocation.positionalArguments.first as List<PriceCellWrite>;
        return [
          for (final w in writes)
            ProductPrice(
              productPriceId: 100,
              productId: w.productId,
              priceList: _retail,
              price: w.price,
            ),
        ];
      });
      await pumpScreen(tester, signedInAs: _fullAccessUser);
      await editOneCell(tester);

      await tester.tap(find.byKey(const Key('pricing_grid_revert_all')));
      await tester.pumpAndSettle();

      final captured =
          verify(() => productPriceRepository.applyPriceChanges(captureAny()))
                  .captured
                  .last
              as List<PriceCellWrite>;
      expect(captured.single.price, '25.00');
      expect(find.byKey(const Key('pricing_grid_summary_bar')), findsNothing);
    });

    testWidgets(
      'a read-only user never sees the summary bar — they cannot have caused '
      'a change (FR-026)',
      (tester) async {
        primeGrid();
        await pumpScreen(tester, signedInAs: _readOnlyUser);

        expect(find.byKey(const Key('pricing_grid_summary_bar')), findsNothing);
      },
    );

    testWidgets(
      'changing page with outstanding changes warns first, and staying '
      'cancels the navigation (FR-025)',
      (tester) async {
        primeGridPaged();
        await pumpScreen(tester, signedInAs: _fullAccessUser, settle: false);
        await editOneCell(tester);

        // `pump`, not `pumpAndSettle`: `PaginatedDataTable2` advances its own
        // cursor the instant it is tapped, so the rows behind the dialog are
        // the not-yet-fetched page's loading placeholders, and their spinners
        // never settle while the dialog is up.
        await tester.tap(find.byIcon(Icons.chevron_right).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          find.byKey(const Key('pricing_grid_discard_dialog')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('pricing_grid_discard_cancel')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Still here, still holding the change — and the table has been put
        // back on the page our state is actually showing.
        expect(find.byKey(const Key('pricing_grid_discard_dialog')), findsNothing);
        expect(find.byKey(const Key('pricing_grid_summary_bar')), findsOneWidget);
      },
    );

    testWidgets('with nothing outstanding, navigation is not interrupted', (
      tester,
    ) async {
      primeGridPaged();
      when(
        () => productRepository.list(
          search: null,
          status: null,
          stockable: null,
          salable: null,
          purchasable: null,
          supplier: null,
          labels: const [],
          missingPriceList: null,
          skip: 20,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => ProductListResult(items: [_product(21)], total: 40),
      );
      when(
        () => productPriceRepository.listForProducts(
          productIds: [21],
          priceListIds: [5],
        ),
      ).thenAnswer((_) async => const []);

      final router = await pumpRoutedScreen(tester, signedInAs: _fullAccessUser);

      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('pricing_grid_discard_dialog')), findsNothing);
      expect(
        router.routeInformationProvider.value.uri.toString(),
        contains('page=2'),
      );
    });
  });
}
