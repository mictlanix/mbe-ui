import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/product_price_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_controller.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockPriceListRepository extends Mock implements PriceListRepository {}

class MockProductPriceRepository extends Mock
    implements ProductPriceRepository {}

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

const _retail = PriceList(
  priceListId: 1,
  name: 'Retail',
  highProfitMargin: '0.40',
  lowProfitMargin: '0.10',
);
const _wholesale = PriceList(
  priceListId: 2,
  name: 'Wholesale',
  highProfitMargin: '0.20',
  lowProfitMargin: '0.05',
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockProductRepository productRepository;
  late MockPriceListRepository priceListRepository;
  late MockProductPriceRepository productPriceRepository;

  setUp(() {
    productRepository = MockProductRepository();
    priceListRepository = MockPriceListRepository();
    productPriceRepository = MockProductPriceRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? initialProductId,
    String? initialProductDisplayText,
    bool standalone = false,
  }) async {
    final screen = PricingScreen(
      initialProductId: initialProductId,
      initialProductDisplayText: initialProductDisplayText,
      standalone: standalone,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(productRepository),
          priceListRepositoryProvider.overrideWithValue(priceListRepository),
          productPriceRepositoryProvider.overrideWithValue(
            productPriceRepository,
          ),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // A standalone PricingScreen supplies its own Scaffold (it's
          // pushed as a full route, not embedded in the shell's AppBar) —
          // wrapping it in another one here would just nest Scaffolds.
          home: standalone ? screen : Scaffold(body: screen),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows an empty state when no product is selected (US2 §8)', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.pricingSelectProductPrompt), findsOneWidget);
  });

  testWidgets(
    'selecting a product shows one row per price list, with an unpriced '
    'list rendering "not set" distinct from a zero price (FR-008)',
    (tester) async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async =>
            const PriceListResult(items: [_retail, _wholesale], total: 2),
      );
      when(
        () => productPriceRepository.listByProduct(
          productId: 1,
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => [
          ProductPrice(
            productPriceId: 10,
            productId: 1,
            priceList: _retail,
            price: '120.00',
            lowProfit: '0.10',
            highProfit: '0.40',
          ),
        ],
      );

      await pumpScreen(tester, signedInAs: _fullAccessUser);

      await tester.tap(find.byKey(const Key('pricing_product_picker')));
      await tester.enterText(
        find.byKey(const Key('pricing_product_picker')),
        'Widget',
      );
      await tester.pump(const Duration(milliseconds: 400));

      // Directly drive the controller since Autocomplete's overlay is
      // awkward to interact with in a widget test — the picker's own
      // behavior is covered by its dedicated core/widgets test.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PricingScreen)),
      );
      await container
          .read(pricingControllerProvider.notifier)
          .selectProduct(productId: 1, displayText: 'SKU-1 — Widget');
      await tester.pumpAndSettle();

      expect(find.text('Retail'), findsOneWidget);
      expect(find.text('Wholesale'), findsOneWidget);
      expect(find.byKey(const Key('price_not_set_2')), findsOneWidget);
      expect(find.text(r'$120.00'), findsOneWidget);
      // Low/high profit are percentage thresholds, not currency (corrected
      // 2026-07-18 — live verification showed values like 0.00/1.00 across
      // every list, matching the legacy "profit threshold" semantics
      // PriceList's own margins already use, FR-006/FR-011).
      expect(find.text('10%'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
    },
  );

  testWidgets(
    'read-only user (no update privilege) sees no Edit affordance on rows '
    '(FR-012)',
    (tester) async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productPriceRepository.listByProduct(
          productId: 1,
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);

      await pumpScreen(tester, signedInAs: _readOnlyUser);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(PricingScreen)),
      );
      await container
          .read(pricingControllerProvider.notifier)
          .selectProduct(productId: 1, displayText: 'SKU-1');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('edit_price_button_1')), findsNothing);
    },
  );

  testWidgets(
    'zero price lists shows the "create a price list first" empty state',
    (tester) async {
      when(
        () => priceListRepository.list(limit: 100),
      ).thenAnswer((_) async => const PriceListResult(items: [], total: 0));
      when(
        () => productPriceRepository.listByProduct(
          productId: 1,
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);

      await pumpScreen(tester, signedInAs: _fullAccessUser);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(PricingScreen)),
      );
      await container
          .read(pricingControllerProvider.notifier)
          .selectProduct(productId: 1, displayText: 'SKU-1');
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(l10n.pricingNoPriceListsEmptyState), findsOneWidget);
    },
  );

  testWidgets(
    'preselects the product and loads its prices when arriving from the '
    'product detail screen\'s "view pricing" shortcut',
    (tester) async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productPriceRepository.listByProduct(
          productId: 1,
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);

      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        initialProductId: 1,
        initialProductDisplayText: 'SKU-1 — Widget',
      );

      // No manual selection via the picker — the product is preloaded from
      // the constructor params alone.
      expect(find.text('Retail'), findsOneWidget);
      expect(find.byKey(const Key('price_not_set_1')), findsOneWidget);
    },
  );

  group('standalone mode (product detail "view pricing" shortcut)', () {
    testWidgets(
      'hides the product picker and renders its own app bar with a back '
      'button',
      (tester) async {
        when(() => priceListRepository.list(limit: 100)).thenAnswer(
          (_) async => const PriceListResult(items: [_retail], total: 1),
        );
        when(
          () => productPriceRepository.listByProduct(
            productId: 1,
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => []);

        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          initialProductId: 1,
          initialProductDisplayText: 'SKU-1 — Widget',
          standalone: true,
        );

        expect(find.byKey(const Key('pricing_product_picker')), findsNothing);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('SKU-1 — Widget'), findsOneWidget);
        expect(find.text('Retail'), findsOneWidget);
      },
    );

    testWidgets(
      'still shows the product picker in non-standalone (shell branch) mode',
      (tester) async {
        await pumpScreen(tester, signedInAs: _fullAccessUser);

        expect(find.byKey(const Key('pricing_product_picker')), findsOneWidget);
      },
    );
  });
}
