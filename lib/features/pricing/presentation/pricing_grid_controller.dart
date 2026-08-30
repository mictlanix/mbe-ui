import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_cell_key.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';
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

extension _EntityStatusByName on List<EntityStatus> {
  EntityStatus? byNameOrNull(String name) {
    for (final value in this) {
      if (value.name == name) return value;
    }
    return null;
  }
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
/// records. [missingPriceList] is US2's worklist facet; it stays
/// permanently `null` until mbe-api#184 exists (FR-019, spec 033
/// research.md §R8) — nothing sets it yet.
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
    final statusRaw = query.facet('status');
    final supplierRaw = query.facet('supplier');
    return PricingGridFilter(
      search: query.search,
      pageIndex: query.pageIndex,
      status: statusRaw != null
          ? EntityStatus.values.byNameOrNull(statusRaw)
          : null,
      stockable: _parseTriState(query.facet('stockable')),
      salable: _parseTriState(query.facet('salable')),
      purchasable: _parseTriState(query.facet('purchasable')),
      supplier: supplierRaw != null ? int.tryParse(supplierRaw) : null,
      labels: query
          .facetValues('label')
          .map(int.tryParse)
          .whereType<int>()
          .toList(),
      // missingPriceList intentionally not read from the query yet — no
      // facet key exists for it until mbe-api#184 lands (US2).
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
      if (entry.value != valueOf(entry.key)) count++;
    }
    return count;
  }

  int get rejectedCount => rejected.length;

  bool get hasChanges => changedCount > 0 || rejectedCount > 0;
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
        )] = row.prices[listId]?.price;
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

  /// Closes the active cell without committing anything (Escape).
  void closeCell() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(active: null));
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

    final existing = current.priceAt(key);
    if (existing != null && existing.price == trimmed) {
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
                PriceWrite(cell: key, previous: existing?.price, next: saved.price),
              ],
            ),
          ],
        ),
      );
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
          rejected: {...latest.rejected, key: RejectedEdit(typed: typed, reason: reason)},
        ),
      );
    }
  }
}
