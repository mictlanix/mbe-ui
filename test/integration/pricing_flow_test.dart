import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/exchange_rate_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';

/// Golden-path integration test against a *real* mbe-api instance
/// (constitution §VII — no mocked/offline mode): create a price list, price
/// a known product on it, then record a daily exchange rate
/// (quickstart.md "Automated tests"; spec.md US1/US2/US3).
///
/// Requires mbe-api running at [apiBaseUrl] (default
/// `http://127.0.0.1:8000`) and a user with `PriceLists`/`Pricing`/
/// `ExchangeRates` create+update rights. Configure via `--dart-define`:
///   --dart-define=MBE_PRICING_TEST_USERNAME=...
///   --dart-define=MBE_PRICING_TEST_PASSWORD=...
///   --dart-define=MBE_KNOWN_PRODUCT_CODE=...   (an existing product's code)
///
/// Skipped entirely when credentials aren't provided — this test creates
/// and then deletes real records, so it must never run unattended against
/// an unknown environment.
const _username = String.fromEnvironment('MBE_PRICING_TEST_USERNAME');
const _password = String.fromEnvironment('MBE_PRICING_TEST_PASSWORD');
const _knownProductCode = String.fromEnvironment('MBE_KNOWN_PRODUCT_CODE');

const _hasCredentials = _username != '' && _password != '';
const _hasKnownProduct = _knownProductCode != '';
const _canRun = _hasCredentials && _hasKnownProduct;

void main() {
  test(
    'create price list → price a product on it → record an exchange rate',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';

      final priceListRepository = PriceListRepositoryImpl(dio);
      final productRepository = ProductRepositoryImpl(dio);
      final productPriceRepository = ProductPriceRepositoryImpl(dio);
      final exchangeRateRepository = ExchangeRateRepositoryImpl(dio);

      // 1. US1 — create a price list.
      final listName =
          'IntegrationTest-${DateTime.now().millisecondsSinceEpoch}';
      final priceList = await priceListRepository.create(
        name: listName,
        highProfitMargin: '0.40',
        lowProfitMargin: '0.10',
      );
      expect(priceList.name, listName);

      // 2. US2 — price a known product on that list (research.md §4's
      // AnyOf write path against the real server, not a fake adapter).
      final productSearch = await productRepository.list(
        search: _knownProductCode,
      );
      final product = productSearch.items.firstWhere(
        (p) => p.code == _knownProductCode,
      );
      final productPrice = await productPriceRepository.create(
        productId: product.productId,
        priceListId: priceList.priceListId,
        price: '120.00',
        lowProfit: '90.00',
        highProfit: '150.00',
      );
      expect(productPrice.price, '120.00');

      // Confirm the wire format survived the real round trip — the
      // feature's highest-risk unknown (research.md §4, plan.md Risks).
      final reloaded = await productPriceRepository.listByProduct(
        productId: product.productId,
        limit: 100,
      );
      expect(
        reloaded.any(
          (p) =>
              p.productPriceId == productPrice.productPriceId &&
              p.price == '120.00',
        ),
        isTrue,
      );

      // 3. US3 — record a daily exchange rate.
      final exchangeRate = await exchangeRateRepository.create(
        date: DateTime.now(),
        rate: '17.50',
        base: 1, // usd
        target: 0, // mxn
      );
      expect(exchangeRate.rate, '17.50');

      // Cleanup: leave no test data behind.
      await exchangeRateRepository.delete(
        exchangeRateId: exchangeRate.exchangeRateId,
      );
      await priceListRepository.delete(priceListId: priceList.priceListId);
    },
    skip: !_canRun,
  );
}
