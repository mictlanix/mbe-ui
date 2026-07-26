import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/features/catalog/domain/entities/merge_preview.dart';

ProductMergePreviewItem _item(String category, int count) =>
    ProductMergePreviewItem(
      (b) => b
        ..category = category
        ..count = count,
    );

ProductMergePreviewResponse _response(
  List<ProductMergePreviewItem> items,
  int total,
) => ProductMergePreviewResponse(
  (b) => b
    ..items = ListBuilder(items)
    ..total = total,
);

void main() {
  group('MergePreview.fromResponse', () {
    test('preserves the server order and total verbatim', () {
      final preview = MergePreview.fromResponse(
        _response([
          _item('sales_order_detail.product', 42),
          _item('purchase_order_detail.product', 18),
          _item('product_price.product', 3),
        ], 63),
      );

      expect(
        preview.categories.map((c) => c.key),
        ['sales_order_detail.product', 'purchase_order_detail.product',
         'product_price.product'],
        reason: 'largest-first ordering comes from the server',
      );
      expect(preview.categories.map((c) => c.count), [42, 18, 3]);
      // SC-006: never re-summed client-side, so the figure always agrees
      // with the backend's own accounting.
      expect(preview.total, 63);
    });

    test('keeps an unrecognized category rather than dropping it', () {
      final preview = MergePreview.fromResponse(
        _response([_item('some_future_table.product', 7)], 7),
      );

      expect(preview.categories, hasLength(1));
      expect(preview.categories.single.key, 'some_future_table.product');
      expect(preview.total, 7);
    });

    test('an empty preview is empty', () {
      final preview = MergePreview.fromResponse(_response([], 0));
      expect(preview.isEmpty, isTrue);
      expect(preview.total, 0);
    });
  });

  group('MergePreviewCategory', () {
    test('isDestroyed is true only for price rows', () {
      // A merge moves every reference except product_price, which it deletes
      // outright — the one category the summary must not call "reassigned".
      expect(
        const MergePreviewCategory(key: 'product_price.product', count: 1)
            .isDestroyed,
        isTrue,
      );
      for (final key in [
        'sales_order_detail.product',
        'product_label.product',
        'fiscal_document_detail.product',
        'lot_serial_tracking.product',
      ]) {
        expect(
          MergePreviewCategory(key: key, count: 1).isDestroyed,
          isFalse,
          reason: '$key is moved to the kept product, not destroyed',
        );
      }
    });

    test('table strips the column suffix', () {
      expect(
        const MergePreviewCategory(
          key: 'inventory_receipt_detail.product',
          count: 1,
        ).table,
        'inventory_receipt_detail',
      );
    });
  });
}
