import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/config/app_settings.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/product_price_repository.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
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
);
const _wholesale = PriceList(
  priceListId: 2,
  name: 'Wholesale',
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

/// spec 033 replaced `/pricing`'s product-picker mode with the grid
/// (`PricingGridScreen`); this screen kept only its pushed, single-product
/// mode, reached from the product detail screen's "view pricing" shortcut
/// (research.md §R1, FR-028a) — so every test here supplies
/// `initialProductId` and there is no longer a picker to drive.
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
    required int initialProductId,
    String? initialProductDisplayText,
    AppSettings? appSettings,
  }) async {
    final screen = PricingScreen(
      initialProductId: initialProductId,
      initialProductDisplayText: initialProductDisplayText,
    );
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          productRepositoryProvider.overrideWithValue(productRepository),
          priceListRepositoryProvider.overrideWithValue(priceListRepository),
          productPriceRepositoryProvider.overrideWithValue(
            productPriceRepository,
          ),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
          if (appSettings != null)
            appSettingsProvider.overrideWithValue(appSettings),
        ],
        // The screen supplies its own Scaffold/AppBar (it's pushed as a
        // full route) — no host Scaffold needed here.
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'preselects the product from the constructor and renders its own app '
    'bar with the given display text (product detail "view pricing" '
    'shortcut)',
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

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('SKU-1 — Widget'), findsOneWidget);
      expect(find.text('Retail'), findsOneWidget);
      expect(find.byKey(const Key('price_not_set_1')), findsOneWidget);
    },
  );

  testWidgets(
    'shows one row per price list, with an unpriced list rendering "not '
    'set" distinct from a zero price (FR-008)',
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
          ),
        ],
      );

      await pumpScreen(tester, signedInAs: _fullAccessUser, initialProductId: 1);

      expect(find.text('Retail'), findsOneWidget);
      expect(find.text('Wholesale'), findsOneWidget);
      expect(find.byKey(const Key('price_not_set_2')), findsOneWidget);
      expect(find.text(r'$120.00'), findsOneWidget);
      // No profit columns: the per-price thresholds this screen used to show
      // were retired with the sales-order validation that read them
      // (spec 033 US7/FR-034, mbe-api#185).
      expect(find.text('10.00 %'), findsNothing);
      expect(find.text('40.00 %'), findsNothing);
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

      await pumpScreen(tester, signedInAs: _readOnlyUser, initialProductId: 1);

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

      await pumpScreen(tester, signedInAs: _fullAccessUser, initialProductId: 1);

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(l10n.pricingNoPriceListsEmptyState), findsOneWidget);
    },
  );

  testWidgets(
    'a server error shows the shared failed state (not a raw exception '
    'string), and Retry re-fetches the same product (017-ui-consistency-'
    'filters US5, FR-031, FR-032)',
    (tester) async {
      when(
        () => priceListRepository.list(limit: 100),
      ).thenThrow(const AppError.server());

      await pumpScreen(tester, signedInAs: _fullAccessUser, initialProductId: 1);

      expect(find.byKey(const Key('list_state_failed')), findsOneWidget);
      expect(find.textContaining('Failed to load prices'), findsNothing);

      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productPriceRepository.listByProduct(
          productId: 1,
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);

      await tester.tap(find.byKey(const Key('list_state_retry_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('list_state_failed')), findsNothing);
      expect(find.text('Retail'), findsOneWidget);
    },
  );

  testWidgets(
    'the edit dialog seeds at the configured currency decimal digits, not '
    'the raw wire precision (spec 036 US8)',
    (tester) async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
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
            price: '20.1234',
          ),
        ],
      );

      await pumpScreen(tester, signedInAs: _fullAccessUser, initialProductId: 1);
      await tester.tap(find.byKey(const Key('edit_price_button_1')));
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(
        find.byKey(const Key('price_edit_price_field')),
      );
      expect(field.controller!.text, '20.12');
    },
  );

  testWidgets(
    'a deployment configured for 3 currency decimal digits seeds the edit '
    'dialog at that count (spec 036 US8)',
    (tester) async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
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
            price: '20.1234',
          ),
        ],
      );

      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        initialProductId: 1,
        appSettings: const AppSettings(
          apiBaseUrl: 'x',
          photosBaseUrl: 'x',
          posDefaultCustomerId: 1,
          brand: BrandConfig(displayName: 'X'),
          defaultLocale: Locale('es', 'MX'),
          formatting: FormattingSettings(currencyDecimalDigits: 3),
        ),
      );
      await tester.tap(find.byKey(const Key('edit_price_button_1')));
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(
        find.byKey(const Key('price_edit_price_field')),
      );
      expect(field.controller!.text, '20.123');
    },
  );
}
