import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_missing_price_facet.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_cell_key.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';
import 'package:mbe_ui/features/pricing/domain/pricing_defaults.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/product_price_repository.dart';
import 'package:mbe_ui/features/pricing/domain/pricing_validators.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_grid_columns.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_grid_row.dart';

part 'pricing_grid_controller.freezed.dart';
part 'pricing_grid_controller.g.dart';

const _pageSize = 20;

bool? _parseTriState(String? raw) {
  if (raw == 'true') return true;
  if (raw == 'false') return false;
  return null;
}

/// Error codes for a cell's [RejectedEdit.reason], localized in the UI layer
/// — the grid's counterpart to `PricingErrorCode` (`pricing_controller.dart`),
/// reusing the **same** localized strings (`pricingInvalidAmountError`,
/// `pricingSaveFailedError`) since the meaning is identical.
abstract final class PricingGridErrorCode {
  static const invalidAmount = 'invalidAmount';
  static const saveFailed = 'saveFailed';
}

/// The pricing grid's addressable view state (data-model.md §7), translated
/// from [ListQuery] exactly as `ProductFilter.fromQuery` is — the grid
/// narrows the same way the products list does, because it lists the same
/// records. [missingPriceList] is US2's worklist facet, read from the
/// `missing` query key (mbe-api#184): set, the grid shows only products with
/// no price on that list (FR-017).
///
/// ⚠️ Parsed with `int.tryParse` and tested for `null`, never for falsiness —
/// `0` is a real price list id (`Costo` in the deployment), so a truthiness
/// check would silently ignore that chip (FR-019a).
///
/// **Shown price-list columns are deliberately not here.** They change
/// which *attributes* of these rows are shown, not which records — a view
/// preference, not a narrowing — so they live in [pricingGridShownColumnsProvider]
/// instead of the URL (research.md §R9).
@freezed
class PricingGridFilter with _$PricingGridFilter {
  const factory PricingGridFilter({
    @Default('') String search,
    @Default(0) int pageIndex,
    EntityStatus? status,
    bool? stockable,
    bool? salable,
    bool? purchasable,
    int? supplier,
    @Default(<int>[]) List<int> labels,
    int? missingPriceList,
  }) = _PricingGridFilter;

  factory PricingGridFilter.fromQuery(ListQuery query) {
    final supplierRaw = query.facet('supplier');
    final missingRaw = query.facet('missing');
    return PricingGridFilter(
      search: query.search,
      pageIndex: query.pageIndex,
      status: decodeStatusFacet(query),
      stockable: _parseTriState(query.facet('stockable')),
      salable: _parseTriState(query.facet('salable')),
      purchasable: _parseTriState(query.facet('purchasable')),
      supplier: supplierRaw != null ? int.tryParse(supplierRaw) : null,
      labels: query
          .facetValues('label')
          .map(int.tryParse)
          .whereType<int>()
          .toList(),
      missingPriceList: missingRaw != null ? int.tryParse(missingRaw) : null,
    );
  }
}

/// A rejected cell edit (data-model.md §6) — the text the user typed, kept
/// on screen (FR-009), and why it was refused. Presence in
/// [PricingGridState.rejected] is itself the "show the rejected badge"
/// signal; the stored price in [PricingGridState.rows] is untouched.
@freezed
class RejectedEdit with _$RejectedEdit {
  const factory RejectedEdit({required String typed, required String reason}) =
      _RejectedEdit;
}

/// What kind of change a [PriceChange] represents — the summary bar's
/// wording and, later, which column action produced it (US3).
enum PriceChangeKind { cell, fillDown, copyFromCost, adjustPercent }

/// One write within a [PriceChange] (data-model.md §5) — the cell it
/// touched, what it held before, and what it was set to. `previous == null`
/// means the cell had no price row before this change (a create).
@freezed
class PriceWrite with _$PriceWrite {
  const factory PriceWrite({
    required PriceCellKey cell,
    required String? previous,
    required String next,
  }) = _PriceWrite;
}

/// One undoable unit (data-model.md §5, FR-016). A single-cell edit is a
/// [PriceChange] with one [PriceWrite]; a column action (US3) is one
/// [PriceChange] with many — undo reverses the whole list as one operation
/// either way, which is what makes "a fill-down of 9 rows is one undo, not
/// nine" true by construction rather than by bookkeeping.
@freezed
class PriceChange with _$PriceChange {
  const factory PriceChange({
    required PriceChangeKind kind,
    required List<PriceWrite> writes,
  }) = _PriceChange;
}

/// The pricing grid's overall state (data-model.md §4). Wrapped in
/// `AsyncValue` by the `@riverpod` machinery (loading/error are
/// [PricingGridController.build]'s concern, not a field here — unlike the
/// older per-product `PricingState`, which predates this codebase's
/// AsyncNotifier convention for list screens).
///
/// Draft text of the cell currently being edited is deliberately **not**
/// here — it lives in that cell's own local `State` (research.md §R3 — a
/// per-keystroke provider write would rebuild the whole row and steal
/// focus). [active] names *which* cell that is, which changes rarely enough
/// (once per cell, not once per keystroke) that holding it here is safe.
@freezed
class PricingGridState with _$PricingGridState {
  const factory PricingGridState({
    @Default(<PricingGridRow>[]) List<PricingGridRow> rows,
    @Default(<PriceList>[]) List<PriceList> allLists,
    CatalogPage<PricingGridRow>? page,

    /// The cell currently open for editing, or `null` when none is.
    PriceCellKey? active,

    /// Cells whose write is in flight (FR-022 "saving").
    @Default(<PriceCellKey>{}) Set<PriceCellKey> inFlight,

    /// Cells the server (or client-side parsing) refused (FR-009).
    @Default(<PriceCellKey, RejectedEdit>{})
    Map<PriceCellKey, RejectedEdit> rejected,

    /// The value each visible cell held when the current view loaded — the
    /// baseline "revert all" restores to (FR-024), and the source of the
    /// "was X" tooltip and the changed-count in the summary bar.
    @Default(<PriceCellKey, String?>{}) Map<PriceCellKey, String?> baseline,

    /// Newest last. One entry per undoable change (FR-016, FR-024).
    @Default(<PriceChange>[]) List<PriceChange> history,
  }) = _PricingGridState;
}

/// Derived lookups and FR-023's three summary-bar numbers — computed
/// rather than stored so they can never drift from [PricingGridState.rows].
extension PricingGridSummary on PricingGridState {
  /// The stored price row for [key], or `null` if the product has no price
  /// on that list yet ("not set", FR-005).
  ProductPrice? priceAt(PriceCellKey key) {
    for (final row in rows) {
      if (row.product.productId == key.productId) {
        return row.prices[key.priceListId];
      }
    }
    return null;
  }

  /// Just the wire value at [key], or `null`.
  String? valueOf(PriceCellKey key) => priceAt(key)?.price;

  int get changedCount {
    var count = 0;
    for (final entry in baseline.entries) {
      if (!sameAmount(entry.value, valueOf(entry.key))) count++;
    }
    return count;
  }

  int get rejectedCount => rejected.length;

  bool get hasChanges => changedCount > 0 || rejectedCount > 0;
}

/// Whether two wire values are the **same amount**, not the same string.
///
/// mbe-api stores prices as `Numeric(18,4)` and returns them at full scale, so
/// a stored `120.0000` and a typed `120.00` are the same price spelled two
/// ways. Comparing the strings makes FR-010's "an unchanged value issues no
/// write" fire almost never, and would flag an untouched cell as changed the
/// moment the server echoed its own scale back — found by the live
/// integration test, which is the only place the real scale shows up.
bool sameAmount(String? a, String? b) {
  if (a == null || b == null) return a == b;
  final left = Decimal.tryParse(a);
  final right = Decimal.tryParse(b);
  if (left == null || right == null) return a == b;
  return left == right;
}

List<PricingGridRow> _withPrice(
  List<PricingGridRow> rows, {
  required int productId,
  required int priceListId,
  required ProductPrice price,
}) {
  return [
    for (final row in rows)
      if (row.product.productId == productId)
        row.copyWith(prices: {...row.prices, priceListId: price})
      else
        row,
  ];
}

/// Per-price-list counts of products still missing a price, over the current
/// filter set — the numbers on the grid's worklist chips (US2, FR-017/FR-018).
///
/// `autoDispose`, so it runs only while the grid is watching it, and re-runs
/// on every filter change. Keyed by the filter **with `missingPriceList`
/// cleared**: the counts describe the whole filtered set, so selecting one
/// chip must not move the numbers on the chips beside it — and clearing the
/// field here means selecting a chip does not even invalidate the provider.
///
/// Consumers read `.valueOrNull` and treat `null` (loading or failed) as
/// "counts unknown", which renders **no chips at all** rather than chips
/// reading zero (FR-019) — the same fail-quiet shape `productLabelFacets`
/// uses, with the opposite default, because a wrong count here is a lie about
/// how much work is left.
@riverpod
Future<List<ProductMissingPriceFacet>> pricingGridMissingFacets(
  Ref ref,
  PricingGridFilter filter,
) {
  return ref
      .read(productRepositoryProvider)
      .productMissingPriceFacets(
        search: filter.search.isEmpty ? null : filter.search,
        status: filter.status,
        stockable: filter.stockable,
        salable: filter.salable,
        purchasable: filter.purchasable,
        supplier: filter.supplier,
        labels: filter.labels,
      );
}

/// Loads and edits one page of the pricing grid, keyed by [PricingGridFilter]
/// (spec 033 US1). Mirrors `ProductsListController`'s
/// fetch-and-hold-a-`CatalogPage` shape, extended with the per-session
/// change-tracking US4 needs — both live in the same `AsyncValue`, so a
/// background refetch (e.g. a filter change) and an in-flight edit can never
/// observe each other's half-applied state.
@riverpod
class PricingGridController extends _$PricingGridController {
  @override
  Future<PricingGridState> build(PricingGridFilter filter) async {
    final shownColumns = ref.watch(pricingGridShownColumnsProvider);
    final priceLists = await ref
        .read(priceListRepositoryProvider)
        .list(limit: 100);
    final allLists = priceLists.items;
    if (allLists.isEmpty) {
      // Nothing to build columns from — the screen renders its own empty
      // state for this (contracts/pricing-grid-screen.md §4).
      return const PricingGridState();
    }
    final visibleIds =
        (shownColumns ?? allLists.map((l) => l.priceListId).toSet()).toList();

    final page = await fetchClampedPage<PricingGridRow>(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) =>
          _fetchPage(filter.copyWith(pageIndex: pageIndex), visibleIds),
    );

    final baseline = <PriceCellKey, String?>{};
    for (final row in page.items) {
      for (final listId in visibleIds) {
        baseline[PriceCellKey(
              productId: row.product.productId,
              priceListId: listId,
            )] =
            row.prices[listId]?.price;
      }
    }

    return PricingGridState(
      rows: page.items,
      allLists: allLists,
      page: page,
      baseline: baseline,
    );
  }

  Future<CatalogPage<PricingGridRow>> _fetchPage(
    PricingGridFilter filter,
    List<int> visibleIds,
  ) async {
    final productPage = await ref
        .read(productRepositoryProvider)
        .list(
          search: filter.search.isEmpty ? null : filter.search,
          status: filter.status,
          stockable: filter.stockable,
          salable: filter.salable,
          purchasable: filter.purchasable,
          supplier: filter.supplier,
          labels: filter.labels,
          missingPriceList: filter.missingPriceList,
          skip: filter.pageIndex * _pageSize,
          limit: _pageSize,
        );
    final prices = await ref
        .read(productPriceRepositoryProvider)
        .listForProducts(
          productIds: productPage.items.map((p) => p.productId).toList(),
          priceListIds: visibleIds,
        );
    final rows = buildPricingGridRows(
      products: productPage.items,
      prices: prices,
    );
    return CatalogPage(
      items: rows,
      total: productPage.total,
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
    );
  }

  /// Re-fetches the current page unchanged, for the failed state's Retry
  /// action.
  void retry() => ref.invalidateSelf();

  /// Opens [key] for editing — closes whatever else was open first, since
  /// exactly one cell is ever active at a time (research.md §R3).
  void openCell(PriceCellKey key) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(active: key));
  }

  /// Closes the active cell without committing anything (Escape), and drops
  /// any rejection it was carrying.
  ///
  /// Escape means "cancel this edit", and a rejection **is** an edit that was
  /// never accepted — the typed text is kept on screen precisely so the user
  /// can come back and fix it (FR-009). Leaving it flagged after they have
  /// explicitly cancelled would strand a warning about a value nobody is
  /// still trying to save, and nothing was ever written, so there is nothing
  /// to undo.
  void closeCell() {
    final current = state.value;
    if (current == null) return;
    final active = current.active;
    state = AsyncData(
      current.copyWith(
        active: null,
        rejected: active == null
            ? current.rejected
            : ({...current.rejected}..remove(active)),
      ),
    );
  }

  /// Drops every rejection, restoring those cells to the values actually
  /// stored (FR-023a).
  ///
  /// Distinct from [revertAll], which is about *written* prices and issues
  /// writes to undo them. A rejection was refused — nothing reached the
  /// server — so discarding one is local, instant and safe, and must not
  /// cost the user the accepted edits sitting beside it.
  void dismissRejected() {
    final current = state.value;
    if (current == null || current.rejected.isEmpty) return;
    state = AsyncData(current.copyWith(rejected: const {}));
  }

  /// Re-reads the worklist counts, but **only** when a write changed whether
  /// some cell has a price at all.
  ///
  /// The chips count *products with no price on a list*, so revaluing an
  /// existing price cannot move them — only creating one can (or, later,
  /// clearing one). Invalidating on every commit would put an extra request
  /// behind every keystroke-ended edit on a screen built for bulk editing;
  /// invalidating on none left the chips reading their load-time numbers
  /// while the user worked the list down, which is what the recording showed.
  void _refreshWorklistCountsIfNeeded({required bool createdOrCleared}) {
    if (!createdOrCleared) return;
    ref.invalidate(pricingGridMissingFacetsProvider);
  }

  /// Reverses the newest change — a single cell edit or a whole column
  /// action alike, because a [PriceChange] carries every write it made
  /// (FR-016, FR-024, SC-004).
  ///
  /// Undo is a **forward write**, not a local rollback: it re-sends the
  /// previous values and can itself fail, at which point nothing has changed
  /// and the entry stays on the history for another try (spec Assumptions,
  /// constitution §VII).
  ///
  /// A cell whose `previous` is `null` had no price row before the change.
  /// There is no delete in the bulk write, so those cells are **skipped** and
  /// keep their value — reported honestly by the return count rather than
  /// papered over.
  Future<int> undoLast() async {
    final current = state.value;
    if (current == null || current.history.isEmpty) return 0;
    final last = current.history.last;
    final restorable = [
      for (final write in last.writes)
        if (write.previous != null)
          PriceWrite(
            cell: write.cell,
            previous: write.next,
            next: write.previous!,
          ),
    ];

    if (restorable.isEmpty) {
      state = AsyncData(
        current.copyWith(
          history: current.history.sublist(0, current.history.length - 1),
        ),
      );
      return 0;
    }

    final restored = await _writeCells(restorable);
    final latest = state.value;
    if (latest == null) return restored;
    state = AsyncData(
      latest.copyWith(
        history: latest.history.sublist(0, latest.history.length - 1),
      ),
    );
    return restored;
  }

  /// Restores every cell to the value it held when this view loaded
  /// (FR-024), clearing the history and every rejected edit with it.
  ///
  /// Same forward-write caveat as [undoLast], and the same skip: a cell that
  /// had no price row at load time cannot be un-created.
  Future<int> revertAll() async {
    final current = state.value;
    if (current == null) return 0;
    final writes = <PriceWrite>[];
    for (final entry in current.baseline.entries) {
      final was = entry.value;
      final now = current.valueOf(entry.key);
      if (was == null || sameAmount(was, now)) continue;
      writes.add(PriceWrite(cell: entry.key, previous: now, next: was));
    }

    final restored = writes.isEmpty ? 0 : await _writeCells(writes);
    final latest = state.value;
    if (latest == null) return restored;
    state = AsyncData(
      latest.copyWith(history: const [], rejected: const {}, active: null),
    );
    return restored;
  }

  /// Sends [writes] as one bulk upsert and folds the results into `rows`,
  /// **without** recording a history entry — shared by [undoLast] and
  /// [revertAll], which manage the history themselves (undoing an undo is
  /// not a thing this screen offers).
  Future<int> _writeCells(List<PriceWrite> writes) async {
    final byCell = <PriceCellKey, PriceWrite>{
      for (final write in writes) write.cell: write,
    };
    final deduped = byCell.values.toList();
    final current = state.value;
    if (current == null) return 0;

    state = AsyncData(
      current.copyWith(inFlight: {...current.inFlight, ...byCell.keys}),
    );
    try {
      final saved = await ref
          .read(productPriceRepositoryProvider)
          .applyPriceChanges([
            for (final write in deduped)
              PriceCellWrite(
                productId: write.cell.productId,
                priceListId: write.cell.priceListId,
                price: write.next,
              ),
          ]);
      final latest = state.value;
      if (latest == null) return deduped.length;
      var rows = latest.rows;
      for (final price in saved) {
        rows = _withPrice(
          rows,
          productId: price.productId,
          priceListId: price.priceList.priceListId,
          price: price,
        );
      }
      state = AsyncData(
        latest.copyWith(
          rows: rows,
          inFlight: {...latest.inFlight}..removeAll(byCell.keys),
        ),
      );
      return deduped.length;
    } on AppError {
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(
          latest.copyWith(
            inFlight: {...latest.inFlight}..removeAll(byCell.keys),
          ),
        );
      }
      rethrow;
    }
  }

  /// The price list "copy from the cost list" reads, or `null` when the
  /// deployment's configured cost list is not among the lists that exist —
  /// in which case the action is offered at all (FR-013).
  ///
  /// Compares ids rather than testing [costPriceListId] for truthiness: `0`
  /// is both the default and a real list (FR-019a).
  PriceList? costListOf(PricingGridState state) {
    for (final list in state.allLists) {
      if (list.priceListId == costPriceListId) return list;
    }
    return null;
  }

  /// Applies [writes] as **one** transaction and **one** undoable change
  /// (FR-015, FR-016). Returns the number of rows changed, for FR-014's
  /// "it changed N rows" report; `0` means the action found nothing to do and
  /// no request was issued.
  ///
  /// De-duplicates by cell before sending: a repeated `(product, priceList)`
  /// is a 400 from mbe-api, deliberately, and resolving it silently would
  /// hide a client bug (contracts/mbe-api-pricing.md §6). A duplicate can
  /// only arise here from a bug, so the last value wins and the shape is
  /// simply made un-sendable-wrong.
  Future<int> _applyColumnAction({
    required PriceChangeKind kind,
    required List<PriceWrite> writes,
  }) async {
    final current = state.value;
    if (current == null || writes.isEmpty) return 0;

    final byCell = <PriceCellKey, PriceWrite>{
      for (final write in writes) write.cell: write,
    };
    final deduped = byCell.values.toList();

    state = AsyncData(
      current.copyWith(
        active: null,
        inFlight: {...current.inFlight, ...byCell.keys},
      ),
    );

    try {
      final saved = await ref
          .read(productPriceRepositoryProvider)
          .applyPriceChanges([
            for (final write in deduped)
              PriceCellWrite(
                productId: write.cell.productId,
                priceListId: write.cell.priceListId,
                price: write.next,
              ),
          ]);

      final latest = state.value;
      if (latest == null) return deduped.length;
      var rows = latest.rows;
      for (final price in saved) {
        rows = _withPrice(
          rows,
          productId: price.productId,
          priceListId: price.priceList.priceListId,
          price: price,
        );
      }
      state = AsyncData(
        latest.copyWith(
          rows: rows,
          inFlight: {...latest.inFlight}..removeAll(byCell.keys),
          history: [
            ...latest.history,
            PriceChange(kind: kind, writes: deduped),
          ],
        ),
      );
      _refreshWorklistCountsIfNeeded(
        createdOrCleared: deduped.any((w) => w.previous == null),
      );
      return deduped.length;
    } on AppError {
      // All-or-nothing on the server, so nothing local changes either: the
      // cells simply stop being in flight (FR-015).
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(
          latest.copyWith(
            inFlight: {...latest.inFlight}..removeAll(byCell.keys),
          ),
        );
      }
      rethrow;
    }
  }

  /// Copies the first shown row's price on [priceListId] down every other
  /// shown row (FR-013). A no-op when that first row has no price there —
  /// there is nothing to copy, and creating rows at "nothing" is not it.
  Future<int> fillDown({required int priceListId}) async {
    final current = state.value;
    if (current == null || current.rows.isEmpty) return 0;
    final source = current.rows.first.prices[priceListId]?.price;
    if (source == null) return 0;
    return _applyColumnAction(
      kind: PriceChangeKind.fillDown,
      writes: [
        for (final row in current.rows.skip(1))
          PriceWrite(
            cell: PriceCellKey(
              productId: row.product.productId,
              priceListId: priceListId,
            ),
            previous: row.prices[priceListId]?.price,
            next: source,
          ),
      ],
    );
  }

  /// Copies each shown row's cost price into [priceListId] (FR-013). Rows
  /// with no cost price are **skipped**, not created at zero.
  Future<int> copyFromCostList({required int priceListId}) async {
    final current = state.value;
    if (current == null) return 0;
    final costList = costListOf(current);
    if (costList == null || costList.priceListId == priceListId) return 0;
    return _applyColumnAction(
      kind: PriceChangeKind.copyFromCost,
      writes: [
        for (final row in current.rows)
          if (row.prices[costList.priceListId] != null)
            PriceWrite(
              cell: PriceCellKey(
                productId: row.product.productId,
                priceListId: priceListId,
              ),
              previous: row.prices[priceListId]?.price,
              next: row.prices[costList.priceListId]!.price,
            ),
      ],
    );
  }

  /// Moves every shown row that **has** a price on [priceListId] by [percent]
  /// (FR-013). A cell with no price has nothing to adjust and is skipped —
  /// never created at `0` (spec Edge Cases).
  Future<int> adjustByPercent({
    required int priceListId,
    required Decimal percent,
  }) async {
    final current = state.value;
    if (current == null) return 0;
    final factor =
        (Decimal.one +
        (percent / Decimal.fromInt(100)).toDecimal(
          scaleOnInfinitePrecision: 6,
        ));
    final writes = <PriceWrite>[];
    for (final row in current.rows) {
      final existing = row.prices[priceListId];
      if (existing == null) continue;
      final currentPrice = Decimal.tryParse(existing.price);
      if (currentPrice == null) continue;
      // Rounded to two places and rendered with `toString()` — the canonical
      // decimal string, which is what goes on the wire and what the API
      // stores. Fixed-precision rendering belongs to the display surface
      // (spec 028), which formats this value again on the way back out; a
      // presentation file building one by hand is what that spec's guard
      // test exists to catch.
      final next = (currentPrice * factor).round(scale: 2);
      if (next < Decimal.zero) continue;
      writes.add(
        PriceWrite(
          cell: PriceCellKey(
            productId: row.product.productId,
            priceListId: priceListId,
          ),
          previous: existing.price,
          next: next.toString(),
        ),
      );
    }
    return _applyColumnAction(
      kind: PriceChangeKind.adjustPercent,
      writes: writes,
    );
  }

  /// Commits [typed] to the cell at ([productId], [priceListId]) — FR-007
  /// through FR-012. Parses and validates client-side first (FR-009);
  /// issues nothing for an unchanged value (FR-010); otherwise creates or
  /// updates depending on whether the cell already has a price row,
  /// applying research.md §R6's profit-band rule on create.
  Future<void> commitCell({
    required int productId,
    required int priceListId,
    required String typed,
  }) async {
    final current = state.value;
    if (current == null) return;
    final key = PriceCellKey(productId: productId, priceListId: priceListId);
    final trimmed = typed.trim();
    final existingBefore = current.priceAt(key);

    // Nothing typed into a cell that has no price is not an error — it is
    // the *unchanged* case (FR-010), spelled the only way an unpriced cell
    // can spell it. This has to be tested before validation, because an
    // empty string is not a valid amount and would otherwise be flagged.
    //
    // It matters far more than it looks: traversing a "Missing «list»"
    // worklist means arrowing through cells that are unpriced by definition,
    // and every one passed over without typing was being marked as a
    // rejected edit the user never made.
    if (trimmed.isEmpty && existingBefore == null) {
      state = AsyncData(
        current.copyWith(
          active: null,
          rejected: {...current.rejected}..remove(key),
        ),
      );
      return;
    }

    if (!PricingValidators.isNonNegativeDecimal(trimmed)) {
      state = AsyncData(
        current.copyWith(
          active: null,
          rejected: {
            ...current.rejected,
            key: RejectedEdit(
              typed: typed,
              reason: PricingGridErrorCode.invalidAmount,
            ),
          },
        ),
      );
      return;
    }

    final existing = existingBefore;
    if (existing != null && sameAmount(existing.price, trimmed)) {
      final rejected = {...current.rejected}..remove(key);
      state = AsyncData(current.copyWith(active: null, rejected: rejected));
      return;
    }

    state = AsyncData(
      current.copyWith(
        active: null,
        inFlight: {...current.inFlight, key},
        rejected: {...current.rejected}..remove(key),
      ),
    );

    try {
      // The grid edits one number, and since mbe-api#185 that is all it has
      // to send: a created row takes its profit band from the price list's
      // own margins server-side, and an update leaves the stored band alone
      // when the fields are omitted (FR-012, FR-034).
      final saved = existing == null
          ? await ref
                .read(productPriceRepositoryProvider)
                .create(
                  productId: productId,
                  priceListId: priceListId,
                  price: trimmed,
                )
          : await ref
                .read(productPriceRepositoryProvider)
                .update(
                  productPriceId: existing.productPriceId,
                  price: trimmed,
                );
      final latest = state.value;
      if (latest == null) return; // filter/columns changed mid-write
      state = AsyncData(
        latest.copyWith(
          rows: _withPrice(
            latest.rows,
            productId: productId,
            priceListId: priceListId,
            price: saved,
          ),
          inFlight: {...latest.inFlight}..remove(key),
          history: [
            ...latest.history,
            PriceChange(
              kind: PriceChangeKind.cell,
              writes: [
                PriceWrite(
                  cell: key,
                  previous: existing?.price,
                  next: saved.price,
                ),
              ],
            ),
          ],
        ),
      );
      _refreshWorklistCountsIfNeeded(createdOrCleared: existing == null);
    } on AppError catch (e) {
      final latest = state.value;
      if (latest == null) return;
      final reason = switch (e) {
        ValidationError(errors: final errors) when errors.isNotEmpty =>
          errors.first.msg,
        _ => PricingGridErrorCode.saveFailed,
      };
      state = AsyncData(
        latest.copyWith(
          inFlight: {...latest.inFlight}..remove(key),
          rejected: {
            ...latest.rejected,
            key: RejectedEdit(typed: typed, reason: reason),
          },
        ),
      );
    }
  }
}
