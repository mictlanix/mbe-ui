import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'merge_preview.freezed.dart';

/// The blast radius of a merge: every category of record attached to the
/// product marked for deletion, with counts
/// (specs/016-product-merge-review FR-006), from
/// `GET /api/v1/products/merge/preview`.
@freezed
class MergePreview with _$MergePreview {
  const factory MergePreview({
    /// One entry per referencing relation, in the server's order (largest
    /// count first).
    required List<MergePreviewCategory> categories,

    /// The server's own total. Displayed as-is rather than re-summed here, so
    /// what the operator reads always matches what the backend counted
    /// (SC-006).
    required int total,
  }) = _MergePreview;

  const MergePreview._();

  factory MergePreview.fromResponse(ProductMergePreviewResponse response) {
    return MergePreview(
      categories: [
        for (final item in response.items)
          MergePreviewCategory(key: item.category, count: item.count),
      ],
      total: response.total,
    );
  }

  bool get isEmpty => categories.isEmpty;
}

/// One referencing relation and how many of its rows point at the product
/// being deleted.
@freezed
class MergePreviewCategory with _$MergePreviewCategory {
  const factory MergePreviewCategory({
    /// The raw `table.column` identifier as mbe-api reports it (e.g.
    /// `sales_order_detail.product`). Kept verbatim: the category set is
    /// derived from mbe-api's mapped metadata and grows whenever a new
    /// foreign key to `product` is added, so the UI resolves a label from
    /// this key rather than relying on a closed enum (research.md §4).
    required String key,
    required int count,
  }) = _MergePreviewCategory;

  const MergePreviewCategory._();

  /// Whether a merge *destroys* these rows instead of moving them to the kept
  /// product. Price rows are the one relation `merge_products` deletes
  /// wholesale — the preview still counts them, so the UI must say so rather
  /// than implying the operator's price list survives (research.md §4).
  bool get isDestroyed => key.startsWith('product_price.');

  /// The table portion of [key], used for label lookup and as the basis for
  /// the humanized fallback.
  String get table => key.split('.').first;
}
