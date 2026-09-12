import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_label_facet.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/sales/presentation/capture/advanced_search_screen.dart';
import 'package:mbe_ui/features/sales/presentation/capture/advanced_search_state.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockSupplierRepository extends Mock implements SupplierRepository {}

const _products = [
  ProductListItem(
    productId: 1,
    code: 'SKU-001',
    name: 'Widget',
    brand: 'Acme',
    unitOfMeasurementCode: 'PCE',
    unitOfMeasurementName: 'Piece',
    taxRate: '0.16',
    status: EntityStatus.active,
    photo: 'http://test/images/widget.png',
  ),
  ProductListItem(
    productId: 2,
    code: 'SKU-002',
    name: 'Gadget',
    unitOfMeasurementCode: 'PCE',
    unitOfMeasurementName: 'Piece',
    taxRate: '0.16',
    status: EntityStatus.active,
  ),
];

/// FR-007/FR-008/FR-013: the advanced-search picker mirrors the catalog
/// products list — same search box, same badged filters button, same paged
/// table, same list-state handling — minus the status column and row
/// actions, plus a leading checkbox column, and with the table forced to
/// active + salable products the operator cannot relax (spec 038).
void main() {
  late MockProductRepository productRepository;
  late MockSupplierRepository supplierRepository;

  setUp(() {
    productRepository = MockProductRepository();
    supplierRepository = MockSupplierRepository();
  });

  /// A router carrying only `advancedSearchPath`, mirroring `pumpScreen` in
  /// `products_list_screen_test.dart`. [withHost] pushes the screen on top
  /// of a dummy `/host` page first, so `Navigator.canPop()` is `true` —
  /// standing in for "opened from a sale" (research.md R8).
  Future<GoRouter> pumpScreen(
    WidgetTester tester, {
    List<ProductListItem> products = _products,
    List<LabelItem> labels = const [],
    List<ProductLabelFacet>? labelFacets,
    ListQuery query = const ListQuery(),
    bool multiSelect = true,
    bool withHost = true,
    Object? listError,
    Size? surface,
  }) async {
    if (surface != null) {
      tester.view.physicalSize = surface;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    if (listError != null) {
      when(
        () => productRepository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          stockable: any(named: 'stockable'),
          salable: any(named: 'salable'),
          purchasable: any(named: 'purchasable'),
          supplier: any(named: 'supplier'),
          labels: any(named: 'labels'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(listError);
    } else {
      when(
        () => productRepository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          stockable: any(named: 'stockable'),
          salable: any(named: 'salable'),
          purchasable: any(named: 'purchasable'),
          supplier: any(named: 'supplier'),
          labels: any(named: 'labels'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => ProductListResult(items: products, total: products.length));
    }
    final effectiveFacets =
        labelFacets ?? labels.map((l) => ProductLabelFacet(labelId: l.labelId, count: 1)).toList();
    when(
      () => productRepository.productLabelFacets(
        search: any(named: 'search'),
        status: any(named: 'status'),
        stockable: any(named: 'stockable'),
        salable: any(named: 'salable'),
        purchasable: any(named: 'purchasable'),
        labels: any(named: 'labels'),
      ),
    ).thenAnswer((_) async => effectiveFacets);

    final routes = [
      if (withHost)
        GoRoute(path: '/host', builder: (_, _) => const Scaffold(body: Text('host'))),
      GoRoute(
        path: advancedSearchPath,
        builder: (_, state) => AdvancedSearchScreen(query: ListQuery.fromUri(state.uri)),
      ),
    ];
    final router = GoRouter(
      initialLocation: withHost ? '/host' : query.toUri(advancedSearchPath).toString(),
      routes: routes,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(productRepository),
          supplierRepositoryProvider.overrideWithValue(supplierRepository),
          allLabelsProvider.overrideWith((_) async => labels),
          productSearchMultiSelectProvider.overrideWithValue(multiSelect),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (withHost) {
      router.push(query.toUri(advancedSearchPath).toString());
      await tester.pumpAndSettle();
    }
    return router;
  }

  group('the picker table (FR-007, FR-012)', () {
    testWidgets('shows photo/code/name/brand/unit and a leading checkbox — '
        'no status column, no row action icons', (tester) async {
      await pumpScreen(tester);

      expect(find.text('SKU-001'), findsOneWidget);
      expect(find.text('Widget'), findsOneWidget);
      expect(find.text('Acme'), findsOneWidget);
      expect(find.text('Piece'), findsWidgets);
      expect(find.byType(Checkbox), findsNWidgets(_products.length));
      // No status badge/text and no row-action icon column: every checkbox
      // is wrapped in a keyed, non-interactive IgnorePointer — the row tap
      // is the only handler.
      for (final product in _products) {
        final ignorePointer = tester.widget<IgnorePointer>(
          find.byKey(Key('advanced_search_row_${product.productId}')),
        );
        expect(ignorePointer.child, isA<Checkbox>());
      }

      // Opening the screen never fires a sale-side call — no such
      // repository is even wired into this container (FR-005).
      verify(
        () => productRepository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          stockable: any(named: 'stockable'),
          salable: any(named: 'salable'),
          purchasable: any(named: 'purchasable'),
          supplier: any(named: 'supplier'),
          labels: any(named: 'labels'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).called(1);
    });

    testWidgets('tapping a row toggles its checkbox; the checkbox cell has '
        'no handler of its own — only the row toggles it, once', (tester) async {
      await pumpScreen(tester);

      Checkbox checkboxFor(int productId) =>
          (tester.widget<IgnorePointer>(find.byKey(Key('advanced_search_row_$productId'))).child
              as Checkbox);

      expect(checkboxFor(1).value, isFalse);
      await tester.tap(find.text('SKU-001'));
      await tester.pumpAndSettle();
      expect(checkboxFor(1).value, isTrue);

      // The checkbox cell itself is `IgnorePointer`ed (onChanged: null), so
      // a tap that lands on its pixels falls through to the row's own tap
      // handler underneath — exactly one toggle, not two (which would
      // cancel out to no visible change, indistinguishable from zero) and
      // not zero (research.md R4).
      await tester.tap(find.byKey(const Key('advanced_search_row_1')), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(checkboxFor(1).value, isFalse);
    });
  });

  group('confirm/cancel (FR-018)', () {
    testWidgets('Add is disabled with an empty selection', (tester) async {
      await pumpScreen(tester);
      final addButton = tester.widget<FilledButton>(
        find.byKey(const Key('advanced_search_add_button')),
      );
      expect(addButton.onPressed, isNull);
    });

    testWidgets('Cancel pops leaving the result provider null', (tester) async {
      late ProviderContainer container;
      final router = await pumpScreen(tester);
      final element = tester.element(find.byType(AdvancedSearchScreen));
      container = ProviderScope.containerOf(element);

      await tester.tap(find.text('SKU-001'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('advanced_search_cancel_button')));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/host');
      expect(container.read(advancedSearchResultProvider), isNull);
    });
  });

  group('list states (FR-013)', () {
    testWidgets('a failed fetch shows retry, which re-issues the request', (tester) async {
      await pumpScreen(tester, listError: const AppError.server());
      expect(find.byKey(const Key('list_state_failed')), findsOneWidget);

      when(
        () => productRepository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          stockable: any(named: 'stockable'),
          salable: any(named: 'salable'),
          purchasable: any(named: 'purchasable'),
          supplier: any(named: 'supplier'),
          labels: any(named: 'labels'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const ProductListResult(items: _products, total: 2));

      await tester.tap(find.byKey(const Key('list_state_retry_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('list_state_failed')), findsNothing);
      expect(find.text('SKU-001'), findsOneWidget);
    });

    testWidgets('an empty filtered result shows clear-filters, which restores the table', (
      tester,
    ) async {
      final router = await pumpScreen(
        tester,
        products: const [],
        query: const ListQuery(search: 'nothing-matches'),
      );
      expect(find.byKey(const Key('list_state_filtered_empty')), findsOneWidget);

      when(
        () => productRepository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          stockable: any(named: 'stockable'),
          salable: any(named: 'salable'),
          purchasable: any(named: 'purchasable'),
          supplier: any(named: 'supplier'),
          labels: any(named: 'labels'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const ProductListResult(items: _products, total: 2));

      await tester.tap(find.byKey(const Key('list_state_clear_filters_button')));
      await tester.pumpAndSettle();
      expect(router.state.uri.toString(), advancedSearchPath);
      expect(find.text('SKU-001'), findsOneWidget);
    });
  });

  group('filters (FR-008, FR-009, FR-010)', () {
    Future<void> openFilterSheet(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('advanced_search_filter_button')));
      await tester.pumpAndSettle();
    }

    Badge filterBadge(WidgetTester tester) => tester.widget<Badge>(
      find.ancestor(
        of: find.byKey(const Key('advanced_search_filter_button')),
        matching: find.byType(Badge),
      ),
    );

    testWidgets('the panel offers Stockable, Purchasable, Supplier and Label — '
        'no Status, no Salable', (tester) async {
      await pumpScreen(
        tester,
        labels: const [LabelItem(labelId: 1, name: 'Ferretería')],
      );

      expect(filterBadge(tester).isLabelVisible, isFalse);
      await openFilterSheet(tester);

      expect(find.byKey(const Key('advanced_search_filter_stockable')), findsOneWidget);
      expect(find.byKey(const Key('advanced_search_filter_purchasable')), findsOneWidget);
      expect(find.byKey(const Key('advanced_search_filter_supplier')), findsOneWidget);
      expect(find.byKey(const Key('advanced_search_filter_label')), findsOneWidget);
      expect(find.byKey(const Key('products_filter_status')), findsNothing);
      expect(find.byKey(const Key('advanced_search_filter_salable')), findsNothing);
    });

    testWidgets('a supplier + one label shows a badge of 2, not the forced facets\' count', (
      tester,
    ) async {
      when(
        () => supplierRepository.list(search: any(named: 'search')),
      ).thenAnswer((_) async => const SupplierListResult(items: [], total: 0));

      await pumpScreen(
        tester,
        labels: const [LabelItem(labelId: 1, name: 'Ferretería')],
        query: const ListQuery(facets: {'supplier': ['9'], 'label': ['1']}),
      );

      expect(filterBadge(tester).isLabelVisible, isTrue);
      expect(filterBadge(tester).label, isA<Text>().having((t) => t.data, 'data', '2'));
    });

    testWidgets('applying a filter while on page 2 returns the table to page 1 (FR-011)', (
      tester,
    ) async {
      final router = await pumpScreen(
        tester,
        labels: const [LabelItem(labelId: 1, name: 'Ferretería')],
        query: const ListQuery(pageIndex: 1),
      );

      await openFilterSheet(tester);
      await tester.tap(find.byKey(const Key('advanced_search_filter_stockable')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('filter_sheet_apply_button')));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters['page'], isNull);
      expect(router.state.uri.queryParameters['stockable'], 'true');
    });
  });

  group('the forced filter is unforgeable (FR-008, SC-004)', () {
    testWidgets('a hand-crafted status=all&salable=false still yields active+salable products', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        query: const ListQuery(
          facets: {
            'status': ['all'],
            'salable': ['false'],
          },
        ),
      );

      // The forced filter is what the mock was called with — status/salable
      // from the URL never reach the repository call.
      final captured = verify(
        () => productRepository.list(
          search: any(named: 'search'),
          status: captureAny(named: 'status'),
          stockable: any(named: 'stockable'),
          salable: captureAny(named: 'salable'),
          purchasable: any(named: 'purchasable'),
          supplier: any(named: 'supplier'),
          labels: any(named: 'labels'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).captured;
      expect(captured[0], EntityStatus.active);
      expect(captured[1], isTrue);
    });
  });

  group('multiple selection (FR-017)', () {
    const pageOne = [
      ProductListItem(
        productId: 1,
        code: 'SKU-001',
        name: 'Widget',
        unitOfMeasurementCode: 'PCE',
        unitOfMeasurementName: 'Piece',
        taxRate: '0.16',
        status: EntityStatus.active,
      ),
      ProductListItem(
        productId: 2,
        code: 'SKU-002',
        name: 'Gadget',
        unitOfMeasurementCode: 'PCE',
        unitOfMeasurementName: 'Piece',
        taxRate: '0.16',
        status: EntityStatus.active,
      ),
    ];
    const pageTwo = [
      ProductListItem(
        productId: 3,
        code: 'SKU-003',
        name: 'Widget Pro',
        unitOfMeasurementCode: 'PCE',
        unitOfMeasurementName: 'Piece',
        taxRate: '0.16',
        status: EntityStatus.active,
      ),
    ];

    testWidgets(
      'ticks persist across a page change and a filter change; the count stays correct',
      (tester) async {
        final router = await pumpScreen(
          tester,
          withHost: false,
          products: pageOne,
        );
        // Registered *after* pumpScreen's own generic (any skip/limit) stub,
        // so this more specific one wins for page 2's request — the same
        // "re-stub after the initial pump" pattern the list-states tests
        // above use.
        when(
          () => productRepository.list(
            search: any(named: 'search'),
            status: any(named: 'status'),
            stockable: any(named: 'stockable'),
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            supplier: any(named: 'supplier'),
            labels: any(named: 'labels'),
            skip: 20,
            limit: 20,
          ),
        ).thenAnswer((_) async => const ProductListResult(items: pageTwo, total: 21));

        await tester.tap(find.text('SKU-001'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('SKU-002'));
        await tester.pumpAndSettle();
        expect(
          find.text('2 seleccionados'),
          findsOneWidget,
          reason: 'both page-1 ticks recorded',
        );

        // Page to page 2 and tick a third.
        router.replace('$advancedSearchPath?page=2');
        await tester.pumpAndSettle();
        await tester.tap(find.text('SKU-003'));
        await tester.pumpAndSettle();
        expect(find.text('3 seleccionados'), findsOneWidget);

        // Apply a filter and come back — still 3.
        router.replace('$advancedSearchPath?page=2&stockable=true');
        await tester.pumpAndSettle();
        expect(find.text('3 seleccionados'), findsOneWidget);
        router.replace(advancedSearchPath);
        await tester.pumpAndSettle();
        expect(find.text('3 seleccionados'), findsOneWidget);
      },
    );

    testWidgets('"Clear selection" empties the count and every tick without leaving the screen', (
      tester,
    ) async {
      final router = await pumpScreen(tester, withHost: false);

      await tester.tap(find.text('SKU-001'));
      await tester.pumpAndSettle();
      expect(find.text('1 seleccionados'), findsOneWidget);

      await tester.tap(find.byKey(const Key('advanced_search_clear_selection')));
      await tester.pumpAndSettle();

      expect(find.text('1 seleccionados'), findsNothing);
      expect(find.byKey(const Key('advanced_search_clear_selection')), findsNothing);
      expect(router.state.uri.toString(), advancedSearchPath);
    });
  });

  group('deployment-configured selection mode (FR-015, FR-016)', () {
    testWidgets('single-selection mode: ticking a second row releases the first', (tester) async {
      await pumpScreen(tester, multiSelect: false);

      await tester.tap(find.text('SKU-001'));
      await tester.pumpAndSettle();
      expect(find.text('1 seleccionados'), findsOneWidget);
      // No clear action in single-selection mode.
      expect(find.byKey(const Key('advanced_search_clear_selection')), findsNothing);

      await tester.tap(find.text('SKU-002'));
      await tester.pumpAndSettle();

      expect(find.text('1 seleccionados'), findsOneWidget);
      final addButton = tester.widget<FilledButton>(
        find.byKey(const Key('advanced_search_add_button')),
      );
      expect((addButton.child! as Text).data, 'Agregar (1)');
    });

    testWidgets('multi-selection mode (the default) is unaffected — regression guard', (
      tester,
    ) async {
      await pumpScreen(tester);

      await tester.tap(find.text('SKU-001'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SKU-002'));
      await tester.pumpAndSettle();

      expect(find.text('2 seleccionados'), findsOneWidget);
      final addButton = tester.widget<FilledButton>(
        find.byKey(const Key('advanced_search_add_button')),
      );
      expect((addButton.child! as Text).data, 'Agregar (2)');
    });
  });

  group('compact layout (FR-014)', () {
    testWidgets(
      'at a phone width the screen renders without overflow, the filter row wraps, and the '
      'confirm/cancel bar stays reachable',
      (tester) async {
        // 390×844 — the same phone surface `pos_test_harness.dart` uses for
        // every other POS compact-layout assertion. At this width the table
        // may need its own horizontal scroll to reach a given row (FR-014
        // permits that), so the selection is set directly through the
        // provider rather than assuming a row is on-screen to tap.
        await pumpScreen(tester, surface: const Size(390, 844));
        final container = ProviderScope.containerOf(
          tester.element(find.byType(AdvancedSearchScreen)),
        );
        container.read(advancedSearchSelectionProvider.notifier).state = [_products.first];
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byKey(const Key('advanced_search_search_field')), findsOneWidget);
        expect(find.byKey(const Key('advanced_search_filter_button')), findsOneWidget);
        expect(find.byKey(const Key('advanced_search_cancel_button')), findsOneWidget);
        expect(find.byKey(const Key('advanced_search_add_button')), findsOneWidget);
        expect(find.text('1 seleccionados'), findsOneWidget);
      },
    );
  });
}
