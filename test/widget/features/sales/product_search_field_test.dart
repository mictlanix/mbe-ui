import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/presentation/capture/advanced_search_screen.dart';
import 'package:mbe_ui/features/sales/presentation/capture/capture_step.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_search_field.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_screen.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../golden/golden_harness.dart';
import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockSupplierRepository extends Mock implements SupplierRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

const _catalogReaderUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 2)],
);

ProductListItem _catalogProduct({
  required int productId,
  required String code,
  required String name,
}) => ProductListItem(
  productId: productId,
  code: code,
  name: name,
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Pieza',
  taxRate: '0.16',
  status: EntityStatus.active,
);

ProductLookupResult _product({
  required int product,
  required String code,
  required String name,
  String? photo,
}) => ProductLookupResult(
      product: product,
      code: code,
      name: name,
      photo: photo,
      price: '10.00',
      taxRate: '0.16',
      taxIncluded: false,
      minOrderQty: 1,
      stockRequired: false,
      stockable: true,
    );

// Mirrors AppSettings.inputDebounce's documented default (spec 036 FR-030,
// contracts/app-settings-additions.md C1) — fromEnvironment() reads
// compile-time values, so tests pump this explicitly rather than reading
// the provider (constitution §V's no-per-test-.env rule).
const _defaultInputDebounce = Duration(milliseconds: 300);

/// spec 023 contracts/capture-surface.md §3 — the field offers candidates as
/// the cashier types, debounced, and never auto-adds from that path; only
/// the scanner's type-and-Enter path still adds a single exact match
/// directly (FR-033–FR-036).
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRepository customers;
  late MockProductRepository productRepository;
  late MockSupplierRepository supplierRepository;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    customers = MockCustomerRepository();
    productRepository = MockProductRepository();
    supplierRepository = MockSupplierRepository();
    when(() => salesOrders.open()).thenAnswer((_) async => testSale());
    when(() => customers.get(customerId: any(named: 'customerId'))).thenAnswer(
      (_) async => const Customer(
        customerId: 7,
        code: 'C-7',
        name: 'PÚBLICO EN GENERAL',
        creditLimit: '0',
        creditDays: 0,
        priceList: PriceListRef(id: 1, name: 'Mostrador'),
        status: EntityStatus.active,
      ),
    );
  });

  Future<ProductLookupResult?> pumpField(WidgetTester tester) async {
    ProductLookupResult? selected;
    await pumpPos(
      tester,
      ProductSearchField(onProductSelected: (result) async => selected = result),
      overrides: [
        salesOrderOverride(salesOrders),
        customerRepositoryProvider.overrideWithValue(customers),
      ],
    );
    return selected;
  }

  /// Routes `advancedSearchPath` for real, so pressing the field's own
  /// "Advanced search" button can genuinely push and pop it (spec 038).
  /// `/host` renders the real `CaptureStep` — the same widget
  /// `pos_lazy_open_test.dart`'s `pumpRegister` pumps — so `_addLine` is the
  /// production code path, not a test stub.
  Future<PosRoutedHarness> pumpRoutedField(
    WidgetTester tester, {
    List<ProductListItem> catalogProducts = const [],
  }) async {
    // Matches `pumpPos`'s own default — tall enough that CaptureStep's full
    // content lays out without overflowing.
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

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
    ).thenAnswer(
      (_) async => ProductListResult(items: catalogProducts, total: catalogProducts.length),
    );
    when(
      () => productRepository.productLabelFacets(
        search: any(named: 'search'),
        status: any(named: 'status'),
        stockable: any(named: 'stockable'),
        salable: any(named: 'salable'),
        purchasable: any(named: 'purchasable'),
        labels: any(named: 'labels'),
      ),
    ).thenAnswer((_) async => const []);

    final router = GoRouter(
      initialLocation: '/host',
      routes: [
        GoRoute(
          path: '/host',
          builder: (_, _) => Scaffold(
            body: Consumer(
              builder: (context, ref, _) =>
                  CaptureStep(sale: ref.watch(posSaleControllerProvider).valueOrNull),
            ),
          ),
        ),
        GoRoute(
          path: advancedSearchPath,
          builder: (_, state) => AdvancedSearchScreen(query: ListQuery.fromUri(state.uri)),
        ),
      ],
    );

    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        salesOrderOverride(salesOrders),
        customerRepositoryProvider.overrideWithValue(customers),
        productRepositoryProvider.overrideWithValue(productRepository),
        supplierRepositoryProvider.overrideWithValue(supplierRepository),
        allLabelsProvider.overrideWith((_) async => const []),
        authNotifierProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: _catalogReaderUser),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (router, container);
  }

  // Under the **real** app theme: the field re-shapes whatever borders
  // `inputDecorationTheme` resolved, so a bare `MaterialApp` — which defines
  // none — would show nothing to assert on.
  group('the field is a stadium (mock frame 2a)', () {
    setUpAll(loadGoldenFonts);

    testWidgets('every border state is fully rounded, and keeps the theme\'s '
        'own colour and width', (tester) async {
      await pumpGoldenScenario(
        tester,
        ProductSearchField(onProductSelected: (_) async {}),
        brightness: Brightness.dark,
        width: 1440,
        overrides: [
          salesOrderOverride(salesOrders),
          customerRepositoryProvider.overrideWithValue(customers),
        ],
      );

      final decoration = tester
          .widget<TextField>(
            find.descendant(
              of: find.byType(ProductSearchField),
              matching: find.byType(TextField),
            ),
          )
          .decoration!;
      final themed =
          Theme.of(
            tester.element(find.byType(ProductSearchField)),
          ).inputDecorationTheme;

      for (final (name, border, source) in <(String, InputBorder?, InputBorder?)>[
        ('border', decoration.border, themed.border),
        ('enabled', decoration.enabledBorder, themed.enabledBorder),
        ('focused', decoration.focusedBorder, themed.focusedBorder),
        ('error', decoration.errorBorder, themed.errorBorder),
      ]) {
        final outline = border! as OutlineInputBorder;
        // Big enough that the corners resolve to a stadium at any height this
        // field is drawn at, rather than to a fixed "quite rounded".
        expect(
          outline.borderRadius.topLeft.x,
          greaterThan(100),
          reason: name,
        );
        // Only the corners change — the colour and width are still the
        // theme's, so a brand change still reaches this field.
        expect(
          outline.borderSide,
          (source! as OutlineInputBorder).borderSide,
          reason: name,
        );
      }
    });
  });

  group('typing offers candidates, debounced, never auto-adding (FR-033, FR-036)', () {
    testWidgets('candidates appear after the debounce with no Enter pressed', (
      tester,
    ) async {
      await pumpField(tester);
      when(
        () => salesOrders.productLookup(
          pattern: any(named: 'pattern'),
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer(
        (_) async => [_product(product: 1, code: 'CLA', name: 'Clavo estándar')],
      );

      await tester.enterText(find.byType(TextField), 'cla');
      // Not yet — still inside the debounce window.
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('CLA — Clavo estándar'), findsNothing);

      await tester.pump(_defaultInputDebounce);
      await tester.pumpAndSettle();

      expect(find.text('CLA — Clavo estándar'), findsOneWidget);
    });

    testWidgets('a candidate carries the product\'s own photo — no second call '
        'to show it (mbe-api#157)', (tester) async {
      await pumpField(tester);
      when(
        () => salesOrders.productLookup(
          pattern: any(named: 'pattern'),
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer(
        (_) async => [
          _product(
            product: 1,
            code: 'CLA',
            name: 'Clavo estándar',
            photo: 'https://cdn.example.com/images/cla.jpg',
          ),
          _product(product: 2, code: 'TOR', name: 'Tornillo'),
        ],
      );

      await tester.enterText(find.byType(TextField), 'c');
      await tester.pump(_defaultInputDebounce);
      await tester.pumpAndSettle();

      final photos = tester
          .widgetList<ProductPhoto>(find.byType(ProductPhoto))
          .map((p) => p.photoUrl)
          .toList();
      // One slot per candidate, and a product with no photo still gets its
      // slot rather than a ragged list.
      expect(photos, ['https://cdn.example.com/images/cla.jpg', null]);
    });

    testWidgets(
      'a single match while typing is only offered, never added directly',
      (tester) async {
        ProductLookupResult? selected;
        await pumpPos(
          tester,
          ProductSearchField(onProductSelected: (result) async => selected = result),
          overrides: [
            salesOrderOverride(salesOrders),
            customerRepositoryProvider.overrideWithValue(customers),
          ],
        );
        when(
          () => salesOrders.productLookup(
            pattern: any(named: 'pattern'),
            customer: any(named: 'customer'),
            warehouse: any(named: 'warehouse'),
          ),
        ).thenAnswer(
          (_) async => [_product(product: 1, code: 'CLA', name: 'Clavo estándar')],
        );

        await tester.enterText(find.byType(TextField), 'CLA');
        await tester.pump(_defaultInputDebounce + const Duration(milliseconds: 50));
        await tester.pumpAndSettle();

        expect(selected, isNull);
        expect(find.text('CLA — Clavo estándar'), findsOneWidget);
      },
    );

    testWidgets('a search that matches nothing states so', (tester) async {
      await pumpField(tester);
      when(
        () => salesOrders.productLookup(
          pattern: any(named: 'pattern'),
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer((_) async => const []);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump(_defaultInputDebounce + const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(find.text(l10n.posProductSearchNoResults), findsOneWidget);
    });

    testWidgets('a stale (superseded) lookup is dropped even if it resolves last', (
      tester,
    ) async {
      await pumpField(tester);
      final shortPrefixCompleter = <ProductLookupResult>[
        _product(product: 1, code: 'CEM', name: 'Cemento'),
      ];
      final longerPrefixResult = <ProductLookupResult>[
        _product(product: 2, code: 'CEMENTO-30', name: 'Cemento gris 30kg'),
      ];

      when(
        () => salesOrders.productLookup(
          pattern: 'cem',
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer((_) async {
        // Resolves *after* the longer prefix's own lookup below, simulating
        // a slow first request overtaken by a faster later one.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return shortPrefixCompleter;
      });
      when(
        () => salesOrders.productLookup(
          pattern: 'cemento',
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer((_) async => longerPrefixResult);

      await tester.enterText(find.byType(TextField), 'cem');
      await tester.pump(_defaultInputDebounce);
      await tester.enterText(find.byType(TextField), 'cemento');
      await tester.pump(_defaultInputDebounce);
      await tester.pumpAndSettle();

      expect(find.text('CEMENTO-30 — Cemento gris 30kg'), findsOneWidget);
      expect(find.text('CEM — Cemento'), findsNothing);
    });
  });

  group("the scanner's type-and-Enter path (FR-034)", () {
    testWidgets(
      'a scanned code with exactly one match is added directly, no picking',
      (tester) async {
        final selected = await pumpField(tester);
        when(
          () => salesOrders.productLookup(
            pattern: any(named: 'pattern'),
            customer: any(named: 'customer'),
            warehouse: any(named: 'warehouse'),
          ),
        ).thenAnswer(
          (_) async => [_product(product: 1, code: 'SCN1', name: 'Escaneado')],
        );

        await tester.enterText(find.byType(TextField), 'SCN1');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        expect(selected, isNull); // captured before the async completes below
      },
    );

    testWidgets('the field clears and keeps focus after an exact-match scan', (
      tester,
    ) async {
      ProductLookupResult? selected;
      await pumpPos(
        tester,
        ProductSearchField(onProductSelected: (result) async => selected = result),
        overrides: [
          salesOrderOverride(salesOrders),
          customerRepositoryProvider.overrideWithValue(customers),
        ],
      );
      when(
        () => salesOrders.productLookup(
          pattern: any(named: 'pattern'),
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer(
        (_) async => [_product(product: 1, code: 'SCN1', name: 'Escaneado')],
      );

      await tester.enterText(find.byType(TextField), 'SCN1');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(selected?.code, 'SCN1');
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
    });
  });

  group('dismissing the candidate list (FR-036)', () {
    testWidgets('Escape closes it without clearing the typed text', (
      tester,
    ) async {
      await pumpField(tester);
      when(
        () => salesOrders.productLookup(
          pattern: any(named: 'pattern'),
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer(
        (_) async => [
          _product(product: 1, code: 'A', name: 'Uno'),
          _product(product: 2, code: 'B', name: 'Dos'),
        ],
      );

      await tester.enterText(find.byType(TextField), 'x');
      await tester.pump(_defaultInputDebounce + const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(find.text('A — Uno'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('A — Uno'), findsNothing);
      expect(find.text('x'), findsOneWidget);
    });
  });

  // spec 036 SC-008: changing the search-debounce setting changes this
  // field's delay, from one place, with no field left on its own hardcoded
  // literal.
  testWidgets(
    'overriding inputDebounceProvider changes when candidates actually appear',
    (tester) async {
      const overriddenDebounce = Duration(milliseconds: 900);
      await pumpPos(
        tester,
        ProductSearchField(onProductSelected: (_) async {}),
        overrides: [
          salesOrderOverride(salesOrders),
          customerRepositoryProvider.overrideWithValue(customers),
          inputDebounceProvider.overrideWithValue(overriddenDebounce),
        ],
      );
      when(
        () => salesOrders.productLookup(
          pattern: any(named: 'pattern'),
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer(
        (_) async => [_product(product: 1, code: 'CLA', name: 'Clavo estándar')],
      );

      await tester.enterText(find.byType(TextField), 'cla');
      // Past the default (300ms) debounce, but short of the overridden one:
      // candidates must not have arrived yet.
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('CLA — Clavo estándar'), findsNothing);

      await tester.pump(const Duration(milliseconds: 550));
      await tester.pumpAndSettle();
      expect(find.text('CLA — Clavo estándar'), findsOneWidget);
    },
  );

  group('Advanced search (spec 038)', () {
    void stubAddLine() {
      when(
        () => salesOrders.addLine(
          saleId: any(named: 'saleId'),
          product: any(named: 'product'),
          quantity: any(named: 'quantity'),
          price: any(named: 'price'),
          discountRate: any(named: 'discountRate'),
          taxRate: any(named: 'taxRate'),
          warehouse: any(named: 'warehouse'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => testSale(lines: [testLine()]));
    }

    void stubLookup(List<ProductLookupResult> results) {
      when(
        () => salesOrders.productLookup(
          pattern: any(named: 'pattern'),
          customer: any(named: 'customer'),
          warehouse: any(named: 'warehouse'),
        ),
      ).thenAnswer((_) async => results);
    }

    Future<void> openAndTick(WidgetTester tester, String code) async {
      await tester.tap(find.byKey(const Key('advanced_search_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(code));
      await tester.pumpAndSettle();
    }

    Future<void> openAndTickMany(WidgetTester tester, List<String> codes) async {
      await tester.tap(find.byKey(const Key('advanced_search_button')));
      await tester.pumpAndSettle();
      for (final code in codes) {
        await tester.tap(find.text(code));
        await tester.pumpAndSettle();
      }
    }

    // `pumpAndSettle` never terminates once the host's `TextField` regains
    // focus after this flow re-enables it (a `pump`-vs-`pumpAndSettle`
    // interaction with `EditableText`'s cursor-blink ticker, not a
    // production bug) — a bounded run of pumps settles every async step our
    // mocks resolve near-instantly, without waiting on the blink forever.
    Future<void> pumpSettled(WidgetTester tester, {int times = 20}) async {
      for (var i = 0; i < times; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    testWidgets(
      'the button carries the field\'s text as the initial search, and confirming one '
      'product adds a correctly priced line (FR-001, FR-004, FR-019, FR-020)',
      (tester) async {
        stubLookup([_product(product: 1, code: 'CLA', name: 'Clavo estándar')]);
        stubAddLine();
        final (router, _) = await pumpRoutedField(
          tester,
          catalogProducts: [_catalogProduct(productId: 1, code: 'CLA', name: 'Clavo estándar')],
        );

        await tester.enterText(find.byType(TextField), 'cla');
        await tester.tap(find.byKey(const Key('advanced_search_button')));
        await tester.pumpAndSettle();

        expect(router.state.uri.path, advancedSearchPath);
        final searchField = tester.widget<TextField>(
          find.descendant(
            of: find.byKey(const Key('advanced_search_search_field')),
            matching: find.byType(TextField),
          ),
        );
        expect(searchField.controller!.text, 'cla');

        await tester.tap(find.text('CLA'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('advanced_search_add_button')));
        await pumpSettled(tester);

        expect(router.state.uri.path, '/host');
        verify(
          () => salesOrders.addLine(
            saleId: any(named: 'saleId'),
            product: 1,
            quantity: any(named: 'quantity'),
            price: any(named: 'price'),
            discountRate: any(named: 'discountRate'),
            taxRate: any(named: 'taxRate'),
            warehouse: any(named: 'warehouse'),
            comment: any(named: 'comment'),
          ),
        ).called(1);
      },
    );

    testWidgets('Cancel returns to the sale with nothing added', (tester) async {
      final (router, _) = await pumpRoutedField(
        tester,
        catalogProducts: [_catalogProduct(productId: 1, code: 'CLA', name: 'Clavo estándar')],
      );

      await openAndTick(tester, 'CLA');
      await tester.tap(find.byKey(const Key('advanced_search_cancel_button')));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/host');
      verifyNever(
        () => salesOrders.addLine(
          saleId: any(named: 'saleId'),
          product: any(named: 'product'),
          quantity: any(named: 'quantity'),
          price: any(named: 'price'),
          discountRate: any(named: 'discountRate'),
          taxRate: any(named: 'taxRate'),
          warehouse: any(named: 'warehouse'),
          comment: any(named: 'comment'),
        ),
      );
    });

    testWidgets(
      'submitting a search inside the screen replaces its own location rather than '
      'unmounting the sale beneath (research.md R1)',
      (tester) async {
        stubLookup([_product(product: 1, code: 'CLA', name: 'Clavo estándar')]);
        final (router, container) = await pumpRoutedField(
          tester,
          catalogProducts: [_catalogProduct(productId: 1, code: 'CLA', name: 'Clavo estándar')],
        );
        final sale = await container.read(posSaleControllerProvider.notifier).ensureOpen();
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('advanced_search_button')));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, advancedSearchPath);

        await tester.enterText(
          find.descendant(
            of: find.byKey(const Key('advanced_search_search_field')),
            matching: find.byType(TextField),
          ),
          'martillo',
        );
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        // Still the same screen, at the same address family — a `go` would
        // have unmounted `/host` and, with it, this sale.
        expect(router.state.uri.path, advancedSearchPath);
        expect(container.read(posSaleControllerProvider).valueOrNull?.id, sale.id);
        verify(() => salesOrders.open()).called(1);
      },
    );

    testWidgets(
      'the field and the button are disabled while a selection is being added, so it '
      'cannot be reopened mid-batch (FR-022)',
      (tester) async {
        final completer = Completer<List<ProductLookupResult>>();
        when(
          () => salesOrders.productLookup(
            pattern: any(named: 'pattern'),
            customer: any(named: 'customer'),
            warehouse: any(named: 'warehouse'),
          ),
        ).thenAnswer((_) => completer.future);
        stubAddLine();
        final (router, _) = await pumpRoutedField(
          tester,
          catalogProducts: [_catalogProduct(productId: 1, code: 'CLA', name: 'Clavo estándar')],
        );

        await openAndTick(tester, 'CLA');
        await tester.tap(find.byKey(const Key('advanced_search_add_button')));
        // The lookup Completer is still unresolved, so this settles the
        // pop's page-transition only — nothing races ahead of it.
        await pumpSettled(tester);

        expect(router.state.uri.path, '/host');
        Finder hostFieldFinder() => find.descendant(
          of: find.byKey(const Key('pos_product_search_field')),
          matching: find.byType(TextField),
        );
        expect(tester.widget<TextField>(hostFieldFinder()).enabled, isFalse);
        expect(
          tester.widget<IconButton>(find.byKey(const Key('advanced_search_button'))).onPressed,
          isNull,
        );

        // Attempting to reopen while mid-add does nothing — the button has
        // no handler to invoke.
        await tester.tap(
          find.byKey(const Key('advanced_search_button')),
          warnIfMissed: false,
        );
        await tester.pump();
        expect(router.state.uri.path, '/host');

        completer.complete([_product(product: 1, code: 'CLA', name: 'Clavo estándar')]);
        await pumpSettled(tester);

        verify(
          () => salesOrders.addLine(
            saleId: any(named: 'saleId'),
            product: 1,
            quantity: any(named: 'quantity'),
            price: any(named: 'price'),
            discountRate: any(named: 'discountRate'),
            taxRate: any(named: 'taxRate'),
            warehouse: any(named: 'warehouse'),
            comment: any(named: 'comment'),
          ),
        ).called(1);
        expect(tester.widget<TextField>(hostFieldFinder()).enabled, isTrue);
      },
    );

    testWidgets(
      'confirming a selection before any sale exists opens exactly one sale and adds '
      'exactly one line (FR-023)',
      (tester) async {
        stubLookup([_product(product: 1, code: 'CLA', name: 'Clavo estándar')]);
        stubAddLine();
        await pumpRoutedField(
          tester,
          catalogProducts: [_catalogProduct(productId: 1, code: 'CLA', name: 'Clavo estándar')],
        );

        verifyNever(() => salesOrders.open());

        await openAndTick(tester, 'CLA');
        await tester.tap(find.byKey(const Key('advanced_search_add_button')));
        await pumpSettled(tester);

        verify(() => salesOrders.open()).called(1);
        verify(
          () => salesOrders.addLine(
            saleId: any(named: 'saleId'),
            product: 1,
            quantity: any(named: 'quantity'),
            price: any(named: 'price'),
            discountRate: any(named: 'discountRate'),
            taxRate: any(named: 'taxRate'),
            warehouse: any(named: 'warehouse'),
            comment: any(named: 'comment'),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'inside the back-office order screen, a confirmed selection reaches that order\'s own '
      'editor, not the register\'s (FR-001, research.md R2)',
      (tester) async {
        when(() => salesOrders.getById(saleId: 501)).thenAnswer((_) async => testSale(id: 501));
        stubLookup([_product(product: 1, code: 'CLA', name: 'Clavo estándar')]);
        stubAddLine();
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
        ).thenAnswer(
          (_) async => ProductListResult(
            items: [_catalogProduct(productId: 1, code: 'CLA', name: 'Clavo estándar')],
            total: 1,
          ),
        );
        when(
          () => productRepository.productLabelFacets(
            search: any(named: 'search'),
            status: any(named: 'status'),
            stockable: any(named: 'stockable'),
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            labels: any(named: 'labels'),
          ),
        ).thenAnswer((_) async => const []);

        const updaterUser = User(
          userId: 'order-updater',
          email: 'order-updater@example.com',
          administrator: false,
          status: EntityStatus.active,
          sessionVersion: 1,
          privileges: [
            Privilege(systemObject: SystemObject.salesOrders, rawValue: 4),
            Privilege(systemObject: SystemObject.products, rawValue: 2),
          ],
        );

        final router = GoRouter(
          initialLocation: '/host',
          routes: [
            GoRoute(path: '/host', builder: (_, _) => const OrderScreen(orderId: 501)),
            GoRoute(
              path: advancedSearchPath,
              builder: (_, state) => AdvancedSearchScreen(query: ListQuery.fromUri(state.uri)),
            ),
          ],
        );
        tester.view.physicalSize = const Size(1200, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({});
        final sharedPreferences = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            salesOrderOverride(salesOrders),
            customerRepositoryProvider.overrideWithValue(customers),
            productRepositoryProvider.overrideWithValue(productRepository),
            supplierRepositoryProvider.overrideWithValue(supplierRepository),
            allLabelsProvider.overrideWith((_) async => const []),
            authNotifierProvider.overrideWith(
              () => _FixedAuthNotifier(AuthState.authenticated(token: 't', user: updaterUser)),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: router,
              locale: const Locale('es', 'MX'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('advanced_search_button')), findsOneWidget);

        await openAndTick(tester, 'CLA');
        await tester.tap(find.byKey(const Key('advanced_search_add_button')));
        await pumpSettled(tester);

        expect(router.state.uri.path, '/host');
        // Reached through the order's own SaleEditor — the register's
        // PosSaleController never opened anything.
        verify(
          () => salesOrders.addLine(
            saleId: 501,
            product: 1,
            quantity: any(named: 'quantity'),
            price: any(named: 'price'),
            discountRate: any(named: 'discountRate'),
            taxRate: any(named: 'taxRate'),
            warehouse: any(named: 'warehouse'),
            comment: any(named: 'comment'),
          ),
        ).called(1);
        verifyNever(() => salesOrders.open());
      },
    );

    testWidgets(
      'one product that cannot be priced is skipped and named; the rest are still added '
      '(FR-021, SC-006)',
      (tester) async {
        // CLA resolves; TOR's lookup returns no row matching its productId —
        // simulating a product that can no longer be priced for this sale.
        when(
          () => salesOrders.productLookup(
            pattern: any(named: 'pattern'),
            customer: any(named: 'customer'),
            warehouse: any(named: 'warehouse'),
          ),
        ).thenAnswer((invocation) async {
          final pattern = invocation.namedArguments[#pattern] as String;
          if (pattern == 'TOR') return const [];
          return [_product(product: 1, code: 'CLA', name: 'Clavo estándar')];
        });
        stubAddLine();
        await pumpRoutedField(
          tester,
          catalogProducts: [
            _catalogProduct(productId: 1, code: 'CLA', name: 'Clavo estándar'),
            _catalogProduct(productId: 2, code: 'TOR', name: 'Tornillo'),
          ],
        );

        await openAndTickMany(tester, ['CLA', 'TOR']);
        await tester.tap(find.byKey(const Key('advanced_search_add_button')));
        await pumpSettled(tester);

        verify(
          () => salesOrders.addLine(
            saleId: any(named: 'saleId'),
            product: 1,
            quantity: any(named: 'quantity'),
            price: any(named: 'price'),
            discountRate: any(named: 'discountRate'),
            taxRate: any(named: 'taxRate'),
            warehouse: any(named: 'warehouse'),
            comment: any(named: 'comment'),
          ),
        ).called(1);
        verifyNever(
          () => salesOrders.addLine(
            saleId: any(named: 'saleId'),
            product: 2,
            quantity: any(named: 'quantity'),
            price: any(named: 'price'),
            discountRate: any(named: 'discountRate'),
            taxRate: any(named: 'taxRate'),
            warehouse: any(named: 'warehouse'),
            comment: any(named: 'comment'),
          ),
        );
        // A dismissable SnackBar, not a persistent block — swipeable, and
        // gone on its own after a few seconds.
        expect(find.byKey(const Key('advanced_search_skipped')), findsOneWidget);
        expect(find.textContaining('TOR — Tornillo'), findsOneWidget);
      },
    );

    testWidgets(
      'a batch of 10 products is added in tick order with visible progress, no duplicates, '
      'none dropped (SC-005)',
      (tester) async {
        final products = [
          for (var i = 1; i <= 10; i++)
            _catalogProduct(productId: i, code: 'P$i', name: 'Producto $i'),
        ];
        var lookupCalls = 0;
        when(
          () => salesOrders.productLookup(
            pattern: any(named: 'pattern'),
            customer: any(named: 'customer'),
            warehouse: any(named: 'warehouse'),
          ),
        ).thenAnswer((invocation) async {
          // A small real delay spreads the batch across several frames, so
          // the progress text is genuinely observable mid-flight rather
          // than the whole loop resolving within one microtask flush.
          await Future<void>.delayed(const Duration(milliseconds: 20));
          lookupCalls++;
          final pattern = invocation.namedArguments[#pattern] as String;
          final id = int.parse(pattern.substring(1));
          return [_product(product: id, code: pattern, name: 'Producto $id')];
        });
        stubAddLine();
        await pumpRoutedField(tester, catalogProducts: products);

        await openAndTickMany(tester, [for (final p in products) p.code]);

        // Progress is visible partway through the batch, before it settles.
        await tester.tap(find.byKey(const Key('advanced_search_add_button')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 20));
        expect(find.textContaining('Agregando'), findsOneWidget);

        await pumpSettled(tester, times: 40);

        expect(lookupCalls, 10);
        for (var i = 1; i <= 10; i++) {
          verify(
            () => salesOrders.addLine(
              saleId: any(named: 'saleId'),
              product: i,
              quantity: any(named: 'quantity'),
              price: any(named: 'price'),
              discountRate: any(named: 'discountRate'),
              taxRate: any(named: 'taxRate'),
              warehouse: any(named: 'warehouse'),
              comment: any(named: 'comment'),
            ),
          ).called(1);
        }
        expect(find.byKey(const Key('advanced_search_skipped')), findsNothing);
      },
    );
  });

  group('access gating (spec 038 FR-002, FR-003, SC-007)', () {
    testWidgets('the button is absent for a user without products read access', (tester) async {
      // `pumpField` overrides no auth provider — `accessControlProvider`
      // defaults to `AuthState.unauthenticated()`, which holds no privileges.
      await pumpField(tester);
      expect(find.byKey(const Key('advanced_search_button')), findsNothing);
    });

    testWidgets('the button is present for a user with products read access', (tester) async {
      await pumpPos(
        tester,
        ProductSearchField(onProductSelected: (_) async {}),
        overrides: [
          salesOrderOverride(salesOrders),
          customerRepositoryProvider.overrideWithValue(customers),
          authNotifierProvider.overrideWith(
            () => _FixedAuthNotifier(
              AuthState.authenticated(token: 't', user: _catalogReaderUser),
            ),
          ),
        ],
      );
      expect(find.byKey(const Key('advanced_search_button')), findsOneWidget);
    });

    testWidgets('the button is disabled whenever the field itself is disabled (FR-003)', (
      tester,
    ) async {
      await pumpPos(
        tester,
        ProductSearchField(onProductSelected: (_) async {}, enabled: false),
        overrides: [
          salesOrderOverride(salesOrders),
          customerRepositoryProvider.overrideWithValue(customers),
          authNotifierProvider.overrideWith(
            () => _FixedAuthNotifier(
              AuthState.authenticated(token: 't', user: _catalogReaderUser),
            ),
          ),
        ],
      );

      final button = tester.widget<IconButton>(
        find.byKey(const Key('advanced_search_button')),
      );
      expect(button.onPressed, isNull);
    });
  });
}
