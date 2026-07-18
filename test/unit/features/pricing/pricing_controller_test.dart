import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/product_price_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_controller.dart';

class MockPriceListRepository extends Mock implements PriceListRepository {}

class MockProductPriceRepository extends Mock
    implements ProductPriceRepository {}

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

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.pricing, rawValue: 6)],
);

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.pricing, rawValue: 2)],
);

void main() {
  late MockPriceListRepository priceListRepository;
  late MockProductPriceRepository productPriceRepository;
  late ProviderContainer container;

  ProviderContainer buildContainer(User user) {
    priceListRepository = MockPriceListRepository();
    productPriceRepository = MockProductPriceRepository();
    final c = ProviderContainer(
      overrides: [
        priceListRepositoryProvider.overrideWithValue(priceListRepository),
        productPriceRepositoryProvider.overrideWithValue(
          productPriceRepository,
        ),
        accessControlProvider.overrideWithValue(
          AccessControlService(AuthState.authenticated(token: 't', user: user)),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    container = buildContainer(_fullAccessUser);
  });

  group('left join (research.md §5, FR-008)', () {
    test('every price list gets a row; a list with no price yields price == '
        'null ("not set"), distinct from a 0.00 price', () async {
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
            price: '0.00',
            lowProfit: '0.00',
            highProfit: '0.00',
          ),
        ],
      );

      final notifier = container.read(pricingControllerProvider.notifier);
      await notifier.selectProduct(productId: 1, displayText: 'SKU-1 — Widget');

      final state = container.read(pricingControllerProvider);
      expect(state.rows, hasLength(2));

      final retailRow = state.rows.firstWhere(
        (r) => r.priceList.priceListId == 1,
      );
      expect(retailRow.price, isNotNull);
      expect(retailRow.price!.price, '0.00');

      final wholesaleRow = state.rows.firstWhere(
        (r) => r.priceList.priceListId == 2,
      );
      expect(wholesaleRow.price, isNull);
    });
  });

  group('saveRow routing (research.md §5)', () {
    test('routes to create when the row has no existing price', () async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productPriceRepository.listByProduct(
          productId: 1,
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);
      when(
        () => productPriceRepository.create(
          productId: 1,
          priceListId: 1,
          price: '120.00',
          lowProfit: '90.00',
          highProfit: '150.00',
        ),
      ).thenAnswer(
        (_) async => ProductPrice(
          productPriceId: 99,
          productId: 1,
          priceList: _retail,
          price: '120.00',
          lowProfit: '90.00',
          highProfit: '150.00',
        ),
      );

      final notifier = container.read(pricingControllerProvider.notifier);
      await notifier.selectProduct(productId: 1, displayText: 'SKU-1');

      final errors = await notifier.saveRow(
        priceListId: 1,
        edit: const PricingRowEditState(
          price: '120.00',
          lowProfit: '90.00',
          highProfit: '150.00',
        ),
      );

      expect(errors, isEmpty);
      verify(
        () => productPriceRepository.create(
          productId: 1,
          priceListId: 1,
          price: '120.00',
          lowProfit: '90.00',
          highProfit: '150.00',
        ),
      ).called(1);
    });

    test('routes to update when the row already has a price', () async {
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
            price: '100.00',
            lowProfit: '80.00',
            highProfit: '130.00',
          ),
        ],
      );
      when(
        () => productPriceRepository.update(
          productPriceId: 10,
          price: '110.00',
          lowProfit: '80.00',
          highProfit: '130.00',
        ),
      ).thenAnswer(
        (_) async => ProductPrice(
          productPriceId: 10,
          productId: 1,
          priceList: _retail,
          price: '110.00',
          lowProfit: '80.00',
          highProfit: '130.00',
        ),
      );

      final notifier = container.read(pricingControllerProvider.notifier);
      await notifier.selectProduct(productId: 1, displayText: 'SKU-1');

      final errors = await notifier.saveRow(
        priceListId: 1,
        edit: const PricingRowEditState(
          price: '110.00',
          lowProfit: '80.00',
          highProfit: '130.00',
        ),
      );

      expect(errors, isEmpty);
      verifyNever(
        () => productPriceRepository.create(
          productId: any(named: 'productId'),
          priceListId: any(named: 'priceListId'),
          price: any(named: 'price'),
          lowProfit: any(named: 'lowProfit'),
          highProfit: any(named: 'highProfit'),
        ),
      );
    });

    test('a negative price is rejected before submit (FR-011)', () async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productPriceRepository.listByProduct(
          productId: 1,
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);

      final notifier = container.read(pricingControllerProvider.notifier);
      await notifier.selectProduct(productId: 1, displayText: 'SKU-1');

      final errors = await notifier.saveRow(
        priceListId: 1,
        edit: const PricingRowEditState(
          price: '-10',
          lowProfit: '0',
          highProfit: '0',
        ),
      );

      expect(errors['price'], PricingErrorCode.invalidAmount);
      verifyNever(
        () => productPriceRepository.create(
          productId: any(named: 'productId'),
          priceListId: any(named: 'priceListId'),
          price: any(named: 'price'),
          lowProfit: any(named: 'lowProfit'),
          highProfit: any(named: 'highProfit'),
        ),
      );
    });

    test('is denied for a user without update privilege', () async {
      container = buildContainer(_readOnlyUser);
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productPriceRepository.listByProduct(
          productId: 1,
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);

      final notifier = container.read(pricingControllerProvider.notifier);
      await notifier.selectProduct(productId: 1, displayText: 'SKU-1');

      final errors = await notifier.saveRow(
        priceListId: 1,
        edit: const PricingRowEditState(
          price: '10',
          lowProfit: '5',
          highProfit: '15',
        ),
      );

      expect(errors['error'], PricingErrorCode.updatePermissionDenied);
    });
  });

  group('stale product handling (spec Edge Cases)', () {
    test('a NotFoundError refetching prices clears the selection back to the '
        'empty state', () async {
      when(() => priceListRepository.list(limit: 100)).thenAnswer(
        (_) async => const PriceListResult(items: [_retail], total: 1),
      );
      when(
        () => productPriceRepository.listByProduct(
          productId: 1,
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const AppError.notFound('Product not found'));

      final notifier = container.read(pricingControllerProvider.notifier);
      await notifier.selectProduct(productId: 1, displayText: 'SKU-1');

      final state = container.read(pricingControllerProvider);
      expect(state.productId, isNull);
      expect(state.rows, isEmpty);
    });
  });
}
