import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/features/pricing/domain/entities/price_list_delete_preview.dart';

PriceListDeletePreviewItem _item(String category, int count) =>
    PriceListDeletePreviewItem(
      (b) => b
        ..category = category
        ..count = count,
    );

PriceListDeletePreviewResponse _response(
  List<PriceListDeletePreviewItem> items,
  int total,
) => PriceListDeletePreviewResponse(
  (b) => b
    ..items = ListBuilder(items)
    ..total = total,
);

void main() {
  group('PriceListDeleteCategory.fate — whole-key match (research.md R2)', () {
    test('product_price.list is destroyed', () {
      expect(
        const PriceListDeleteCategory(
          key: 'product_price.list',
          count: 1,
        ).fate,
        PriceListDeleteFate.destroyed,
      );
    });

    test('customer.price_list is moved', () {
      expect(
        const PriceListDeleteCategory(
          key: 'customer.price_list',
          count: 1,
        ).fate,
        PriceListDeleteFate.moved,
      );
    });

    test('anything else blocks, including an invented future key', () {
      // A second foreign key from the same table would arrive under a
      // different column and must still block — prefix-matching the table
      // (as MergePreviewCategory.isDestroyed does) would misclassify this.
      expect(
        const PriceListDeleteCategory(
          key: 'product_price.tax_zone',
          count: 1,
        ).fate,
        PriceListDeleteFate.blocking,
      );
      expect(
        const PriceListDeleteCategory(
          key: 'sales_order.price_list',
          count: 38,
        ).fate,
        PriceListDeleteFate.blocking,
      );
    });

    test('table is the portion before the dot', () {
      expect(
        const PriceListDeleteCategory(
          key: 'sales_order.price_list',
          count: 1,
        ).table,
        'sales_order',
      );
    });
  });

  group('PriceListDeletePreview.fromResponse', () {
    test('preserves the server order and total verbatim', () {
      final preview = PriceListDeletePreview.fromResponse(
        _response([
          _item('product_price.list', 4312),
          _item('customer.price_list', 12),
        ], 4324),
      );

      expect(
        preview.categories.map((c) => c.key),
        ['product_price.list', 'customer.price_list'],
        reason: 'largest-first ordering comes from the server',
      );
      expect(preview.categories.map((c) => c.count), [4312, 12]);
      // SC-005: never re-summed client-side, so the figure always agrees
      // with the backend's own accounting.
      expect(preview.total, 4324);
    });

    test('keeps an unrecognized category rather than dropping it', () {
      final preview = PriceListDeletePreview.fromResponse(
        _response([_item('sales_order.price_list', 38)], 38),
      );

      expect(preview.categories, hasLength(1));
      expect(preview.categories.single.key, 'sales_order.price_list');
      expect(preview.total, 38);
    });

    test('an empty preview is empty and unblocked', () {
      final preview = PriceListDeletePreview.fromResponse(_response([], 0));

      expect(preview.isEmpty, isTrue);
      expect(preview.isBlocked, isFalse);
      expect(preview.movedCount, 0);
      expect(preview.destroyedCount, 0);
      expect(preview.total, 0);
    });
  });

  group('PriceListDeletePreview.isBlocked (research.md R11)', () {
    test('false when only known categories are present', () {
      final preview = PriceListDeletePreview.fromResponse(
        _response([
          _item('product_price.list', 4312),
          _item('customer.price_list', 12),
        ], 4324),
      );
      expect(preview.isBlocked, isFalse);
    });

    test('true when any unrecognized category is present', () {
      final preview = PriceListDeletePreview.fromResponse(
        _response([
          _item('product_price.list', 4312),
          _item('sales_order.price_list', 38),
        ], 4350),
      );
      expect(preview.isBlocked, isTrue);
    });
  });

  group('PriceListDeletePreview.movedCount / destroyedCount', () {
    test('read the matching category, 0 when absent', () {
      final priced = PriceListDeletePreview.fromResponse(
        _response([_item('product_price.list', 4312)], 4312),
      );
      expect(priced.destroyedCount, 4312);
      expect(priced.movedCount, 0);

      final assigned = PriceListDeletePreview.fromResponse(
        _response([_item('customer.price_list', 12)], 12),
      );
      expect(assigned.destroyedCount, 0);
      expect(assigned.movedCount, 12);
    });
  });
}
