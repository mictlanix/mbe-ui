import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'price_list_delete_preview.freezed.dart';

/// What retiring a price list touches: every category of record attached to
/// it, with counts (specs/034-price-list-retirement-ui FR-002), from
/// `GET /api/v1/price-lists/{price_list_id}/delete/preview`.
@freezed
class PriceListDeletePreview with _$PriceListDeletePreview {
  const factory PriceListDeletePreview({
    /// One entry per referencing relation, in the server's order (largest
    /// count first). Never re-sorted client-side.
    required List<PriceListDeleteCategory> categories,

    /// The server's own total, displayed as-is rather than re-summed here
    /// (SC-005) — records the deletion *touches*, not records it deletes
    /// (FR-004).
    required int total,
  }) = _PriceListDeletePreview;

  const PriceListDeletePreview._();

  factory PriceListDeletePreview.fromResponse(
    PriceListDeletePreviewResponse response,
  ) {
    return PriceListDeletePreview(
      categories: [
        for (final item in response.items)
          PriceListDeleteCategory(key: item.category, count: item.count),
      ],
      total: response.total,
    );
  }

  /// Nothing depends on this list (FR-008): a plain confirmation, no
  /// breakdown, no replacement picker, no acknowledgment.
  bool get isEmpty => categories.isEmpty;

  /// Any category this deletion cannot handle is present, so the deletion
  /// must be refused before it is even attempted (FR-018, research.md R11).
  bool get isBlocked =>
      categories.any((c) => c.fate == PriceListDeleteFate.blocking);

  /// How many customers this deletion moves to the replacement — `0` when
  /// the `customer.price_list` category is absent. Drives both the
  /// required-replacement gate (FR-009) and the "N customers move to X"
  /// copy (FR-011).
  int get movedCount => _countFor(PriceListDeleteFate.moved);

  /// How many of the list's own prices this deletion destroys — `0` when
  /// the `product_price.list` category is absent. Drives the confirm
  /// button's label (FR-015).
  int get destroyedCount => _countFor(PriceListDeleteFate.destroyed);

  int _countFor(PriceListDeleteFate fate) {
    for (final category in categories) {
      if (category.fate == fate) return category.count;
    }
    return 0;
  }
}

/// One relation referencing the list and how many of its rows do.
@freezed
class PriceListDeleteCategory with _$PriceListDeleteCategory {
  const factory PriceListDeleteCategory({
    /// The raw `table.column` identifier mbe-api reports, kept verbatim so
    /// an unrecognized relation still reaches the UI rather than being
    /// dropped (FR-005).
    required String key,
    required int count,
  }) = _PriceListDeleteCategory;

  const PriceListDeleteCategory._();

  /// What this deletion does with the category, matched on the **exact**
  /// key — never a table-name prefix (research.md R2). A second foreign key
  /// from `product_price` or `customer` to `price_list` would arrive as a
  /// different `key` and must still block; prefix-matching the table would
  /// silently misclassify it as destroyed/moved.
  PriceListDeleteFate get fate => switch (key) {
    'product_price.list' => PriceListDeleteFate.destroyed,
    'customer.price_list' => PriceListDeleteFate.moved,
    _ => PriceListDeleteFate.blocking,
  };

  /// The table portion of [key] — the basis for label lookup and the
  /// humanized fallback.
  String get table => key.split('.').first;
}

/// What a retirement does with one category of attached record
/// (data-model.md §1.2). Deliberately has no `unknown` arm: an unrecognized
/// relation is not a classification gap, it blocks (SC-006).
enum PriceListDeleteFate {
  /// Deleted with the list (`product_price.list`).
  destroyed,

  /// Reassigned to the replacement, or the deletion is refused
  /// (`customer.price_list`).
  moved,

  /// Prevents the deletion entirely — every other category, including one
  /// added to the data model after this feature ships.
  blocking,
}
