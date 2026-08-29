import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_grid_row.dart';

ProductListItem _product(int id) => ProductListItem(
  productId: id,
  code: 'SKU-$id',
  name: 'Product $id',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Piece',
  taxRate: '0.16',
  status: EntityStatus.active,
);

PriceList _priceList(int id, String name) =>
    PriceList(priceListId: id, name: name, highProfitMargin: '0', lowProfitMargin: '0');

ProductPrice _price({
  required int productId,
  required int priceListId,
  required String price,
}) => ProductPrice(
  productPriceId: productId * 100 + priceListId,
  productId: productId,
  priceList: _priceList(priceListId, 'List $priceListId'),
  price: price,
  lowProfit: '0',
  highProfit: '1',
);

void main() {
  group('buildPricingGridRows (spec 033 data-model.md §2, FR-005)', () {
    test('one row per product, in the given order', () {
      final rows = buildPricingGridRows(
        products: [_product(1), _product(2)],
        prices: const [],
      );

      expect(rows, hasLength(2));
      expect(rows[0].product.productId, 1);
      expect(rows[1].product.productId, 2);
    });

    test(
      'a product with no price on a list has no entry for it — "not set" is '
      'absence, not a null value, so it is distinguishable from a stored '
      'price of zero',
      () {
        final rows = buildPricingGridRows(
          products: [_product(1)],
          prices: [_price(productId: 1, priceListId: 5, price: '0.00')],
        );

        expect(rows.single.prices.containsKey(5), isTrue);
        expect(rows.single.prices[5]!.price, '0.00');
        expect(rows.single.prices.containsKey(9), isFalse);
      },
    );

    test('joins each price to its own product only', () {
      final rows = buildPricingGridRows(
        products: [_product(1), _product(2)],
        prices: [
          _price(productId: 1, priceListId: 5, price: '10.00'),
          _price(productId: 2, priceListId: 5, price: '20.00'),
          _price(productId: 1, priceListId: 9, price: '11.00'),
        ],
      );

      final byId = {for (final r in rows) r.product.productId: r};
      expect(byId[1]!.prices.keys, unorderedEquals([5, 9]));
      expect(byId[1]!.prices[5]!.price, '10.00');
      expect(byId[2]!.prices.keys, [5]);
      expect(byId[2]!.prices[5]!.price, '20.00');
    });

    test('a product with no matching price at all gets an empty map', () {
      final rows = buildPricingGridRows(products: [_product(1)], prices: const []);

      expect(rows.single.prices, isEmpty);
    });
  });
}
