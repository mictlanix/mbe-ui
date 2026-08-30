import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/exchange_rate_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/product_price_repository.dart';

/// Golden-path integration test against a *real* mbe-api instance
/// (constitution §VII — no mocked/offline mode).
///
/// Rewritten for spec 033 (US7 T055): it now exercises the **grid's** wire
/// paths rather than the retired per-product screen's —
/// `listForProducts` (mbe-api#182's repeated `product`) and
/// `applyPriceChanges` (mbe-api#183's transactional bulk upsert) — and the
/// profit-free price-list form (US7, mbe-api#185).
///
/// Requires mbe-api running at [apiBaseUrl] (default
/// `http://127.0.0.1:8000`) and a user with `PriceLists`/`Pricing`/
/// `ExchangeRates` create+update rights. Configure via
/// `--dart-define-from-file=.env`, which supplies:
///   MBE_PRICING_TEST_USERNAME / MBE_PRICING_TEST_PASSWORD
///   MBE_KNOWN_PRODUCT_CODE   (an existing product's code)
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

/// mbe-api stores prices as `Numeric(18,4)` and returns them at full scale,
/// so a price sent as `120.00` reads back as `120.0000`. Every assertion
/// here compares the **amount**, never the spelling — the mismatch that
/// made this file's original assertions wrong the first time it ever ran
/// against a live server.
Matcher _amount(String expected) => predicate<String>(
  (actual) => Decimal.parse(actual) == Decimal.parse(expected),
  'the amount $expected, at any scale',
);

void main() {
  test(
    'create price list → price products via the grid\'s batched read and '
    'bulk upsert → record an exchange rate',
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

      // 1. US7 — create a price list with a name and nothing else. The two
      // profit-margin fields are gone from the form and from the repository;
      // the server defaults both to 0 (FR-035, mbe-api#185).
      final listName =
          'IntegrationTest-${DateTime.now().millisecondsSinceEpoch}';
      final priceList = await priceListRepository.create(name: listName);
      expect(priceList.name, listName);

      // 2. US1 — price a known product on that list. The grid never sends a
      // profit band; the row takes one from the price list server-side
      // (FR-012, mbe-api#185). A create that is refused for want of margins
      // fails here.
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
      );
      expect(productPrice.price, _amount('120.00'));

      // 3. US1 — the grid's read path: one request for a page of products
      // against the shown columns (mbe-api#182's repeated `product`). The
      // single-id case is the same call, so this covers both.
      final batched = await productPriceRepository.listForProducts(
        productIds: [product.productId],
        priceListIds: [priceList.priceListId],
      );
      expect(
        batched.singleWhere(
          (p) => p.productPriceId == productPrice.productPriceId,
        ).price,
        _amount('120.00'),
      );
      // Scoped to the asked-for columns — a price on another list must not
      // leak into the page.
      expect(
        batched.every((p) => p.priceList.priceListId == priceList.priceListId),
        isTrue,
      );

      // 4. US3 — the column actions' write path: one transactional upsert
      // keyed on `(product, price_list)` (mbe-api#183). Keyed on the pair,
      // so this same call updates the row created above with no
      // create-vs-update branch on the client.
      final upserted = await productPriceRepository.applyPriceChanges([
        PriceCellWrite(
          productId: product.productId,
          priceListId: priceList.priceListId,
          price: '132.00',
        ),
      ]);
      expect(upserted, hasLength(1));
      expect(upserted.single.price, _amount('132.00'));
      expect(upserted.single.productPriceId, productPrice.productPriceId);

      // And it stuck — re-read rather than trusting the response echo.
      final reloaded = await productPriceRepository.listForProducts(
        productIds: [product.productId],
        priceListIds: [priceList.priceListId],
      );
      expect(
        reloaded.singleWhere(
          (p) => p.productPriceId == productPrice.productPriceId,
        ).price,
        _amount('132.00'),
      );

      // 5. Spec 011 US3 — record a daily exchange rate.
      final exchangeRate = await exchangeRateRepository.create(
        date: DateTime.now(),
        rate: '17.50',
        base: 1, // usd
        target: 0, // mxn
      );
      expect(exchangeRate.rate, _amount('17.50'));

      // Cleanup: leave no test data behind. Deleting the price list now
      // sweeps its `product_price` rows with it (mbe-api#181) — before that
      // landed, this line failed on any list that had ever been priced,
      // which is what #181 was filed about.
      await exchangeRateRepository.delete(
        exchangeRateId: exchangeRate.exchangeRateId,
      );
      await priceListRepository.delete(priceListId: priceList.priceListId);
    },
    skip: !_canRun,
  );
}
