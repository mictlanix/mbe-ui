import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/config/app_settings.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_cell_key.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/product_price_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/price_cell.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_grid_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockPriceListRepository extends Mock implements PriceListRepository {}

class MockProductPriceRepository extends Mock implements ProductPriceRepository {}

const _filter = PricingGridFilter();

ProductListItem _product(int id) => ProductListItem(
  productId: id,
  code: 'SKU-$id',
  name: 'Product $id',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Piece',
  taxRate: '0.16',
  status: EntityStatus.active,
);

PriceList _priceList(int id) => PriceList(priceListId: id, name: 'List $id');

ProductPrice _price({required int productId, required int priceListId, required String price}) =>
    ProductPrice(
      productPriceId: productId * 100 + priceListId,
      productId: productId,
      priceList: _priceList(priceListId),
      price: price,
    );

void main() {
  late MockProductRepository productRepository;
  late MockPriceListRepository priceListRepository;
  late MockProductPriceRepository productPriceRepository;
  late ProviderContainer container;

  setUp(() async {
    productRepository = MockProductRepository();
    priceListRepository = MockPriceListRepository();
    productPriceRepository = MockProductPriceRepository();
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        productRepositoryProvider.overrideWithValue(productRepository),
        priceListRepositoryProvider.overrideWithValue(priceListRepository),
        productPriceRepositoryProvider.overrideWithValue(productPriceRepository),
      ],
    );
    addTearDown(container.dispose);

    when(() => priceListRepository.list(limit: 100)).thenAnswer(
      (_) async => PriceListResult(items: [_priceList(5)], total: 1),
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

    await container.read(pricingGridControllerProvider(_filter).future);
  });

  Future<void> pump(
    WidgetTester tester, {
    required ProductPrice? price,
    RejectedEdit? rejected,
    bool isActive = false,
    bool canUpdate = true,
    List<PriceCellMove> moves = const [],
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PriceCell(
              filter: _filter,
              productId: 1,
              priceListId: 5,
              price: price,
              rejected: rejected,
              inFlight: false,
              isActive: isActive,
              canUpdate: canUpdate,
              onMove: moves.add,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('reading state shows "not set" for a product with no price on '
      'this list (FR-005)', (tester) async {
    await pump(tester, price: null);
    expect(find.text('Not set'), findsOneWidget);
  });

  testWidgets('reading state shows the formatted price when one exists', (
    tester,
  ) async {
    await pump(tester, price: _price(productId: 1, priceListId: 5, price: '25.00'));
    expect(find.textContaining('25.00'), findsOneWidget);
  });

  testWidgets('a canUpdate cell opens for editing on tap', (tester) async {
    await pump(tester, price: null);
    await tester.tap(find.byKey(const Key('price_cell_1_5')));
    await tester.pump();

    final state = container.read(pricingGridControllerProvider(_filter)).requireValue;
    expect(state.active?.productId, 1);
    expect(state.active?.priceListId, 5);
  });

  testWidgets('a !canUpdate cell does not open for editing on tap', (
    tester,
  ) async {
    await pump(tester, price: null, canUpdate: false);
    await tester.tap(find.byKey(const Key('price_cell_1_5')));
    await tester.pump();

    final state = container.read(pricingGridControllerProvider(_filter)).requireValue;
    expect(state.active, isNull);
  });

  testWidgets(
    'editing state renders a TextField seeded with the stored price',
    (tester) async {
      await pump(
        tester,
        price: _price(productId: 1, priceListId: 5, price: '25.00'),
        isActive: true,
      );

      final field = tester.widget<TextField>(
        find.byKey(const Key('price_cell_field_1_5')),
      );
      expect(field.controller!.text, '25.00');
    },
  );

  testWidgets(
    'seeds at the configured currency decimal digits, not the raw wire '
    'precision (spec 036 US8)',
    (tester) async {
      await pump(
        tester,
        price: _price(productId: 1, priceListId: 5, price: '25.1234'),
        isActive: true,
      );

      final field = tester.widget<TextField>(
        find.byKey(const Key('price_cell_field_1_5')),
      );
      expect(field.controller!.text, '25.12');
    },
  );

  testWidgets(
    'a deployment configured for 3 currency decimal digits seeds at that '
    'count (spec 036 US8)',
    (tester) async {
      final customContainer = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
          productRepositoryProvider.overrideWithValue(productRepository),
          priceListRepositoryProvider.overrideWithValue(priceListRepository),
          productPriceRepositoryProvider.overrideWithValue(
            productPriceRepository,
          ),
          appSettingsProvider.overrideWithValue(
            const AppSettings(
              apiBaseUrl: 'x',
              photosBaseUrl: 'x',
              posDefaultCustomerId: 1,
              brand: BrandConfig(displayName: 'X'),
              defaultLocale: Locale('es', 'MX'),
              formatting: FormattingSettings(currencyDecimalDigits: 3),
            ),
          ),
        ],
      );
      addTearDown(customContainer.dispose);
      customContainer.listen(pricingGridControllerProvider(_filter), (_, _) {});
      await customContainer.read(
        pricingGridControllerProvider(_filter).future,
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: customContainer,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: PriceCell(
                filter: _filter,
                productId: 1,
                priceListId: 5,
                price: _price(productId: 1, priceListId: 5, price: '25.1234'),
                rejected: null,
                inFlight: false,
                isActive: true,
                canUpdate: true,
                onMove: (_) {},
              ),
            ),
          ),
        ),
      );

      final field = tester.widget<TextField>(
        find.byKey(const Key('price_cell_field_1_5')),
      );
      expect(field.controller!.text, '25.123');
    },
  );

  testWidgets('Enter commits and reports a downward move (contracts §2)', (
    tester,
  ) async {
    when(
      () => productPriceRepository.create(
        productId: 1,
        priceListId: 5,
        // Sent as `30`, not the raw typed `30.00` — spec 036 US8 routes a
        // commit through `field.parsePrice()`, which round-trips through
        // `Decimal` (contracts/app-settings-additions.md C3).
        price: '30',
      ),
    ).thenAnswer((_) async => _price(productId: 1, priceListId: 5, price: '30.00'));
    final moves = <PriceCellMove>[];
    await pump(tester, price: null, isActive: true, moves: moves);

    await tester.enterText(find.byKey(const Key('price_cell_field_1_5')), '30.00');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(moves, [PriceCellMove.down]);
    // No profit band named — mbe-api#185 defaults it from the price list.
    verify(
      () => productPriceRepository.create(
        productId: 1,
        priceListId: 5,
        price: '30',
      ),
    ).called(1);
  });

  testWidgets('Tab commits and reports a rightward move', (tester) async {
    when(
      () => productPriceRepository.create(
        productId: any(named: 'productId'),
        priceListId: any(named: 'priceListId'),
        price: any(named: 'price'),
      ),
    ).thenAnswer((_) async => _price(productId: 1, priceListId: 5, price: '30.00'));
    final moves = <PriceCellMove>[];
    await pump(tester, price: null, isActive: true, moves: moves);

    await tester.enterText(find.byKey(const Key('price_cell_field_1_5')), '30.00');
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    expect(moves, [PriceCellMove.right]);
  });

  testWidgets('Escape discards without committing and reports no move', (
    tester,
  ) async {
    final moves = <PriceCellMove>[];
    await pump(tester, price: null, isActive: true, moves: moves);

    await tester.enterText(find.byKey(const Key('price_cell_field_1_5')), 'abc');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(moves, isEmpty);
    verifyNever(
      () => productPriceRepository.create(
        productId: any(named: 'productId'),
        priceListId: any(named: 'priceListId'),
        price: any(named: 'price'),
      ),
    );
    final state = container.read(pricingGridControllerProvider(_filter)).requireValue;
    expect(state.active, isNull);
  });

  testWidgets(
    'a rejected cell keeps the typed text visible, flagged, in reading state '
    '(FR-009)',
    (tester) async {
      await container
          .read(pricingGridControllerProvider(_filter).notifier)
          .commitCell(productId: 1, priceListId: 5, typed: 'abc');

      final state = container.read(pricingGridControllerProvider(_filter)).requireValue;
      final rejection = state.rejected.values.single;

      await pump(tester, price: null, rejected: rejection);

      expect(find.text('abc'), findsOneWidget);
    },
  );

  // ── spec 036 US3: commit-before-switch (contracts/pricing-grid-commit.md) ──

  testWidgets(
    'typing into the cell then a click straight into a different cell '
    'commits exactly once, and that other cell ends active (C1, FR-009)',
    (tester) async {
      when(
        () => productPriceRepository.create(
          productId: 1,
          priceListId: 5,
          price: '30', // parsed/round-tripped, not the raw typed '30.00'
        ),
      ).thenAnswer((_) async => _price(productId: 1, priceListId: 5, price: '30.00'));
      final notifier = container.read(pricingGridControllerProvider(_filter).notifier);
      // Syncs the controller's own `active` with this test's `isActive: true`
      // widget prop — this file pumps `PriceCell` directly rather than
      // through the screen that normally drives `openCell` on a real tap, so
      // nothing else would set it.
      notifier.openCell(const PriceCellKey(productId: 1, priceListId: 5));
      await pump(tester, price: null, isActive: true);

      await tester.enterText(find.byKey(const Key('price_cell_field_1_5')), '30.00');
      await tester.pump();

      // Production's own onTap for another (reading-mode) cell calls exactly
      // this — `openCell` is the one place C1's commit-before-switch lives,
      // so calling it directly here exercises the real fix for a mouse click
      // straight into another cell (research.md R9's root cause) without
      // needing a second `PriceCell` mounted in this single-cell test file.
      notifier.openCell(const PriceCellKey(productId: 2, priceListId: 5));
      await tester.pumpAndSettle();

      verify(
        () => productPriceRepository.create(
          productId: 1,
          priceListId: 5,
          price: '30',
        ),
      ).called(1);
      final state = container.read(pricingGridControllerProvider(_filter)).requireValue;
      expect(state.active, const PriceCellKey(productId: 2, priceListId: 5));
    },
  );

  testWidgets(
    'a keyboard commit followed by the screen opening the next cell does '
    'not commit a second time (C2, no double-commit)',
    (tester) async {
      when(
        () => productPriceRepository.create(
          productId: 1,
          priceListId: 5,
          price: '30', // parsed/round-tripped, not the raw typed '30.00'
        ),
      ).thenAnswer((_) async => _price(productId: 1, priceListId: 5, price: '30.00'));
      final moves = <PriceCellMove>[];
      await pump(tester, price: null, isActive: true, moves: moves);

      await tester.enterText(find.byKey(const Key('price_cell_field_1_5')), '30.00');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      // `pricing_grid_screen.dart`'s `onMoveFrom` resolves the next cell and
      // opens it right after the keyboard move's own explicit commit — this
      // is that same second call, exercised directly since this file pumps
      // one cell in isolation.
      container
          .read(pricingGridControllerProvider(_filter).notifier)
          .openCell(const PriceCellKey(productId: 2, priceListId: 5));
      await tester.pumpAndSettle();

      verify(
        () => productPriceRepository.create(
          productId: 1,
          priceListId: 5,
          price: '30',
        ),
      ).called(1);
    },
  );

  testWidgets(
    'a still-active cell that unmounts outright (a page or filter change) '
    'still commits its draft (research.md R9)',
    (tester) async {
      when(
        () => productPriceRepository.create(
          productId: 1,
          priceListId: 5,
          price: '30', // parsed/round-tripped, not the raw typed '30.00'
        ),
      ).thenAnswer((_) async => _price(productId: 1, priceListId: 5, price: '30.00'));
      await pump(tester, price: null, isActive: true);

      await tester.enterText(find.byKey(const Key('price_cell_field_1_5')), '30.00');
      await tester.pump();

      // No move, no Escape — just the cell disappearing, the one case
      // R9 found the old focus-lost-driven commit could never catch.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      verify(
        () => productPriceRepository.create(
          productId: 1,
          priceListId: 5,
          price: '30',
        ),
      ).called(1);
    },
  );

  testWidgets(
    'typing an invalid value then opening a different cell still shows the '
    'rejected badge and reason (FR-010)',
    (tester) async {
      final notifier = container.read(pricingGridControllerProvider(_filter).notifier);
      notifier.openCell(const PriceCellKey(productId: 1, priceListId: 5));
      await pump(tester, price: null, isActive: true);

      await tester.enterText(find.byKey(const Key('price_cell_field_1_5')), 'abc');
      await tester.pump();

      notifier.openCell(const PriceCellKey(productId: 2, priceListId: 5));
      await tester.pumpAndSettle();

      final state = container.read(pricingGridControllerProvider(_filter)).requireValue;
      final rejection = state.rejected[const PriceCellKey(productId: 1, priceListId: 5)];
      expect(rejection?.typed, 'abc');
      expect(rejection?.reason, PricingGridErrorCode.invalidAmount);

      await pump(tester, price: null, rejected: rejection);
      expect(find.text('abc'), findsOneWidget);
      expect(find.byKey(const Key('price_cell_badge_1_5')), findsOneWidget);
    },
  );
}
