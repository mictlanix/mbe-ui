import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pricing_grid_columns.g.dart';

/// Which price lists render as columns on the pricing grid — a per-session
/// view preference (spec 033 research.md §R9, FR-020), not a URL-addressable
/// filter: it changes which *attributes* of the grid's rows are shown, not
/// which records match, so it is kept out of [PricingGridFilter]/the URL on
/// purpose. `null` means "show every price list" (the default); narrowing to
/// a proper subset is what a non-null [Set] represents.
///
/// `keepAlive: true` so the choice survives navigating within the session
/// (leaving and returning to `/pricing`), but it is never persisted to
/// device storage or synced — a fresh app launch starts back at "all".
@Riverpod(keepAlive: true)
class PricingGridShownColumns extends _$PricingGridShownColumns {
  @override
  Set<int>? build() => null;

  /// Toggles [priceListId] on or off. [allIds] is every price list that
  /// exists, needed to expand the implicit "all" state into an explicit set
  /// on the first toggle, and to collapse back to `null` when every list
  /// ends up selected again (so a later-added price list is shown by
  /// default rather than silently excluded).
  void toggle(int priceListId, {required List<int> allIds}) {
    final current = state ?? allIds.toSet();
    final next = {...current};
    if (!next.remove(priceListId)) next.add(priceListId);
    state = next.length == allIds.length ? null : next;
  }

  /// Explicitly resets to "show every price list".
  void showAll() => state = null;
}
