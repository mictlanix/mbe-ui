import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/navigation/list_search_submit.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/label_multi_picker.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_list_item.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_cell_key.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/presentation/price_cell.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_grid_columns.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_grid_controller.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_grid_row.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _pricingPath = '/pricing';

/// Width of one price-list column. Wide enough for a formatted amount **plus**
/// a state badge beside it (FR-022): §VI forbids ellipsizing a monetary value,
/// so the badge's width is budgeted here rather than taken from the figure.
const kPriceColumnWidth = 200.0;

/// The bulk pricing grid (spec 033 US1) — replaces the product-picker
/// pricing tool at `/pricing`: one row per product, one column per shown
/// price list, prices edited in place. Gated by
/// `can(SystemObject.pricing, AccessRight.read)` in the router, exactly as
/// the screen it replaces was.
///
/// [query] is decoded from the route (spec 017 pattern) — the URL is this
/// screen's only source of *which records* are shown. Which *columns* are
/// shown is a separate, session-scoped choice (research.md §R9,
/// [pricingGridShownColumnsProvider]) deliberately kept out of the URL.
class PricingGridScreen extends ConsumerWidget {
  const PricingGridScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = PricingGridFilter.fromQuery(query);
    final gridAsync = ref.watch(pricingGridControllerProvider(filter));
    final access = ref.watch(accessControlProvider);
    final canUpdate = access.can(SystemObject.pricing, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    final loadedState = gridAsync.valueOrNull;
    final noPriceLists = loadedState != null && loadedState.allLists.isEmpty;

    // Scoped to this screen, not a global handler (research.md §R4).
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true): () =>
            _undoLast(ref, filter, canUpdate),
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () =>
            _undoLast(ref, filter, canUpdate),
      },
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            CatalogFilterBar(
              search: CatalogSearchBar(
                key: const Key('pricing_grid_search_field'),
                label: l10n.productsSearchLabel,
                searchTooltip: l10n.searchButtonTooltip,
                initialValue: filter.search,
                onSubmitted: (value) async {
                  // Guards both branches submitCatalogSearch can take — an
                  // unchanged term still re-fetches (spec 035 FR-008), and
                  // a refetch is exactly as destructive to unsaved edits as
                  // navigating away would be.
                  if (!await _confirmDiscard(context, loadedState)) return;
                  if (!context.mounted) return;
                  submitCatalogSearch(
                    context: context,
                    query: query,
                    path: _pricingPath,
                    submitted: value,
                    current: filter.search,
                    refresh: () =>
                        ref.invalidate(pricingGridControllerProvider(filter)),
                  );
                },
              ),
              filters: [
                Badge.count(
                  count: query.facets.length,
                  isLabelVisible: query.isFiltered,
                  child: IconButton.outlined(
                    key: const Key('pricing_grid_filter_button'),
                    icon: const Icon(Icons.tune),
                    tooltip: l10n.filtersTooltip,
                    onPressed: () => showCatalogFilterSheet(
                      context,
                      title: l10n.filtersButton,
                      clearAllLabel: l10n.clearAllFilters,
                      applyLabel: l10n.applyFilters,
                      onClearAll: () => context.go(_pricingPath),
                      builder: (_) => CurrentListQueryBuilder(
                        builder: (context, query) =>
                            _PricingGridFiltersPanel(query: query),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!noPriceLists)
              _WorklistChips(query: query, filter: filter, state: loadedState),
            if (canUpdate && loadedState != null && loadedState.hasChanges)
              _ChangeSummaryBar(filter: filter, state: loadedState),
            Expanded(
              child: noPriceLists
                  ? ListEmptyView(message: l10n.pricingNoPriceListsEmptyState)
                  : CatalogListStateView<PricingGridRow>(
                      state: gridAsync.whenData((s) => s.page!),
                      isFiltered: isFilteredBeyondStatusDefault(
                        query,
                        filter.status,
                      ),
                      emptyMessage: l10n.noProductsFound,
                      clearFiltersLabel: l10n.clearFiltersButton,
                      onClearFilters: () => context.go(_pricingPath),
                      retryLabel: l10n.retryButton,
                      onRetry: () => ref
                          .read(pricingGridControllerProvider(filter).notifier)
                          .retry(),
                      onData: (page) => _PricingGrid(
                        filter: filter,
                        query: query,
                        state: gridAsync.requireValue,
                        page: page,
                        canUpdate: canUpdate,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  canUpdate
                      ? l10n.pricingGridHint
                      : l10n.pricingGridReadOnlyHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _undoLast(WidgetRef ref, PricingGridFilter filter, bool canUpdate) {
    // A read-only user has nothing to undo and no way to have made a change;
    // the shortcut must not become the one editing affordance they can reach
    // (FR-026).
    if (!canUpdate) return;
    unawaited(
      ref.read(pricingGridControllerProvider(filter).notifier).undoLast(),
    );
  }
}

/// Confirms before a navigation that would discard the session's undo history
/// or any rejected text (FR-025).
///
/// The prices already written are untouched either way — what is lost is the
/// *ability to take them back*, and the typed text of anything refused, which
/// is what makes this worth a prompt rather than a silent reload.
///
/// A plain dialog rather than the `UnconfirmedEdits` registry the task list
/// sketched: that registry tracks per-field text a `ConfirmableFieldController`
/// is holding, and this grid deliberately does not use that controller
/// (research.md §R3). What is at stake here is controller state, not field
/// state, so the check reads the controller.
Future<bool> _confirmDiscard(
  BuildContext context,
  PricingGridState? state,
) async {
  if (state == null || !state.hasChanges) return true;
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      key: const Key('pricing_grid_discard_dialog'),
      title: Text(l10n.pricingGridDiscardTitle),
      content: Text(l10n.pricingGridDiscardBody),
      actions: [
        TextButton(
          key: const Key('pricing_grid_discard_cancel'),
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.pricingGridDiscardCancel),
        ),
        FilledButton(
          key: const Key('pricing_grid_discard_confirm'),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.pricingGridDiscardConfirm),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// The change-summary bar (FR-023): how many prices this session changed, how
/// many it had refused, and the two ways back — undo the newest change, or
/// revert every cell to what it held when the view loaded.
///
/// Visible only while there is something to say, and only to a user who could
/// have caused it (FR-026).
class _ChangeSummaryBar extends ConsumerWidget {
  const _ChangeSummaryBar({required this.filter, required this.state});

  final PricingGridFilter filter;
  final PricingGridState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final notifier = ref.read(pricingGridControllerProvider(filter).notifier);
    final rejected = state.rejectedCount;

    final summary = [
      l10n.pricingGridSummary(state.changedCount),
      if (rejected > 0) l10n.pricingGridSummaryRejected(rejected),
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        key: const Key('pricing_grid_summary_bar'),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Icon(Icons.history, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(summary)),
              // Only offered when there is something to dismiss, and placed
              // before the undo actions: it is the cheapest, safest of the
              // three (nothing was ever written) and the one a user with a
              // flagged cell is looking for.
              if (rejected > 0)
                TextButton(
                  key: const Key('pricing_grid_dismiss_rejected'),
                  onPressed: notifier.dismissRejected,
                  child: Text(l10n.pricingGridDismissRejected),
                ),
              TextButton(
                key: const Key('pricing_grid_undo_last'),
                onPressed: state.history.isEmpty
                    ? null
                    : () => unawaited(notifier.undoLast()),
                child: Text(l10n.pricingGridUndoLast),
              ),
              TextButton(
                key: const Key('pricing_grid_revert_all'),
                onPressed: () => unawaited(notifier.revertAll()),
                child: Text(l10n.pricingGridRevertAll),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The worklist row (US2, FR-017/FR-018): "All products" plus one
/// "Missing «list» (count)" chip per **shown** price list, each narrowing the
/// grid to products with no price on that list.
///
/// Renders **nothing at all** when the counts are unknown — still loading, or
/// the facet call failed (FR-019). A chip reading zero when the truth is
/// fourteen is a lie about how much work is left, which is worse than no chip;
/// this is the opposite default from the label facets, where unknown means
/// "leave every chip enabled".
class _WorklistChips extends ConsumerWidget {
  const _WorklistChips({
    required this.query,
    required this.filter,
    required this.state,
  });

  final ListQuery query;
  final PricingGridFilter filter;
  final PricingGridState? state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final gridState = state;
    if (gridState == null) return const SizedBox.shrink();

    // Keyed on the filter with the worklist selection cleared, so selecting a
    // chip does not change the numbers on the chips beside it.
    final facets = ref
        .watch(
          pricingGridMissingFacetsProvider(
            filter.copyWith(missingPriceList: null),
          ),
        )
        .valueOrNull;
    if (facets == null) return const SizedBox.shrink();

    final countByListId = {
      for (final facet in facets) facet.priceListId: facet.missingCount,
    };
    final shownIds = ref.watch(pricingGridShownColumnsProvider);
    final visibleLists = shownIds == null
        ? gridState.allLists
        : gridState.allLists
              .where((l) => shownIds.contains(l.priceListId))
              .toList();

    void goTo(ListQuery updated) =>
        context.go(updated.toUri(_pricingPath).toString());

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              key: const Key('pricing_grid_worklist_all'),
              label: Text(l10n.pricingGridWorklistAll),
              selected: filter.missingPriceList == null,
              onSelected: (_) =>
                  goTo(query.withFacet('missing', null).copyWith(pageIndex: 0)),
            ),
            for (final priceList in visibleLists)
              ChoiceChip(
                key: Key('pricing_grid_worklist_${priceList.priceListId}'),
                label: Text(
                  l10n.pricingGridWorklistMissing(
                    priceList.name,
                    countByListId[priceList.priceListId] ?? 0,
                  ),
                ),
                // `==`, never a truthiness check: `0` is a real price list id
                // (`Costo`), and `if (missingPriceList)` would never select it
                // (FR-019a).
                selected: filter.missingPriceList == priceList.priceListId,
                onSelected: (_) => goTo(
                  query
                      .withFacet('missing', '${priceList.priceListId}')
                      .copyWith(pageIndex: 0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PricingGrid extends ConsumerStatefulWidget {
  const _PricingGrid({
    required this.filter,
    required this.query,
    required this.state,
    required this.page,
    required this.canUpdate,
  });

  final PricingGridFilter filter;
  final ListQuery query;
  final PricingGridState state;
  final CatalogPage<PricingGridRow> page;
  final bool canUpdate;

  @override
  ConsumerState<_PricingGrid> createState() => _PricingGridState();
}

class _PricingGridState extends ConsumerState<_PricingGrid> {
  /// Bumped whenever a page change is **refused** (FR-025's "stay" answer).
  ///
  /// `PaginatedDataTable2` advances its own cursor *before* calling
  /// `onPageChanged`, so declining to navigate leaves the table showing page
  /// 2 while our state is still page 1 — and on the next build it fires the
  /// change again, reopening the dialog forever. Keying the subtree on this
  /// counter rebuilds the table from `pagination.pageIndex`, which is the
  /// only handle we have on a cursor the shared widget owns privately.
  int _resyncNonce = 0;

  PricingGridFilter get filter => widget.filter;
  ListQuery get query => widget.query;
  PricingGridState get state => widget.state;
  CatalogPage<PricingGridRow> get page => widget.page;
  bool get canUpdate => widget.canUpdate;

  List<PriceList> _visibleLists(Set<int>? shownIds) {
    if (shownIds == null) return state.allLists;
    return state.allLists
        .where((l) => shownIds.contains(l.priceListId))
        .toList();
  }

  PriceCellKey? _nextKey(
    PriceCellKey current,
    PriceCellMove move,
    List<int> rowIds,
    List<int> colIds,
  ) {
    var ri = rowIds.indexOf(current.productId);
    var ci = colIds.indexOf(current.priceListId);
    if (ri == -1 || ci == -1) return null;
    switch (move) {
      case PriceCellMove.down:
        ri += 1;
      case PriceCellMove.up:
        ri -= 1;
      case PriceCellMove.right:
        ci += 1;
        if (ci >= colIds.length) {
          ci = 0;
          ri += 1;
        }
      case PriceCellMove.left:
        ci -= 1;
        if (ci < 0) {
          ci = colIds.length - 1;
          ri -= 1;
        }
    }
    if (ri < 0 || ri >= rowIds.length) return null;
    return PriceCellKey(productId: rowIds[ri], priceListId: colIds[ci]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shownIds = ref.watch(pricingGridShownColumnsProvider);
    final visibleLists = _visibleLists(shownIds);
    // `state.rows`, not `page.items`: the page is the load-time snapshot the
    // shared list-state view hands back, while every write since lands in
    // `state.rows`. Rendering the page would show stale prices the moment a
    // cell is edited — `page` is used below for pagination metadata only.
    final rows = state.rows;
    final rowIds = rows.map((r) => r.product.productId).toList();
    final colIds = visibleLists.map((l) => l.priceListId).toList();

    void onMoveFrom(PriceCellKey current, PriceCellMove move) {
      final next = _nextKey(current, move, rowIds, colIds);
      if (next == null) return;
      ref.read(pricingGridControllerProvider(filter).notifier).openCell(next);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: KeyedSubtree(
        key: ValueKey(_resyncNonce),
        child: DataTableView<PricingGridRow>(
          key: const Key('pricing_grid_table'),
          minWidth: 640 + visibleLists.length * kPriceColumnWidth,
          columns: [
            DataTableColumn(
              label: '',
              fixedWidth: 96,
              cellBuilder: (context, row) =>
                  ProductPhoto(photoUrl: row.product.photo, size: 56),
            ),
            DataTableColumn(
              label: l10n.columnCode,
              fixedWidth: 190,
              cellBuilder: (context, row) => Text(row.product.code),
            ),
            DataTableColumn.text(
              label: l10n.columnName,
              text: (row) => row.product.name,
              size: ColumnSize.L,
            ),
            for (final priceList in visibleLists)
              DataTableColumn(
                label: priceList.name,
                fixedWidth: kPriceColumnWidth,
                numeric: true,
                header: _ColumnHeader(
                  filter: filter,
                  priceList: priceList,
                  canUpdate: canUpdate,
                ),
                cellBuilder: (context, row) {
                  final key = PriceCellKey(
                    productId: row.product.productId,
                    priceListId: priceList.priceListId,
                  );
                  final was = state.baseline[key];
                  final now = row.prices[priceList.priceListId]?.price;
                  return PriceCell(
                    filter: filter,
                    productId: row.product.productId,
                    priceListId: priceList.priceListId,
                    price: row.prices[priceList.priceListId],
                    rejected: state.rejected[key],
                    // Same amount, not same string: the server returns
                    // prices at `Numeric(18,4)` scale, so `120.00` and
                    // `120.0000` are one price and must not read as a change.
                    //
                    // `baseline` holds an entry for every visible cell, with a
                    // null *value* for one that had no price — so membership
                    // is what says "this cell was loaded", and the value is
                    // only the "was X" half of the tooltip.
                    hasChanged:
                        state.baseline.containsKey(key) &&
                        !sameAmount(was, now),
                    changedFrom: was,
                    inFlight: state.inFlight.contains(key),
                    isActive: state.active == key,
                    canUpdate: canUpdate,
                    onMove: (move) => onMoveFrom(key, move),
                  );
                },
              ),
          ],
          rows: rows,
          pagination: page,
          onPageChanged: (pageIndex) async {
            if (!await _confirmDiscard(context, state)) {
              // Put the table back where our state says it is.
              if (mounted) setState(() => _resyncNonce++);
              return;
            }
            if (!context.mounted) return;
            context.go(
              query
                  .copyWith(pageIndex: pageIndex)
                  .toUri(_pricingPath)
                  .toString(),
            );
          },
        ),
      ),
    );
  }
}

/// A price-list column header, with the ⋮ actions menu (US3, FR-013) when the
/// user may update prices. Without that right the header is just its name —
/// the menu is **absent**, not disabled (FR-026).
class _ColumnHeader extends ConsumerWidget {
  const _ColumnHeader({
    required this.filter,
    required this.priceList,
    required this.canUpdate,
  });

  final PricingGridFilter filter;
  final PriceList priceList;
  final bool canUpdate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (!canUpdate) return Text(priceList.name);

    final notifier = ref.read(pricingGridControllerProvider(filter).notifier);
    final state = ref.watch(pricingGridControllerProvider(filter)).valueOrNull;
    final costList = state == null ? null : notifier.costListOf(state);

    Future<void> run(Future<int> Function() action) async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        final changed = await action();
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.pricingGridRowsChanged(changed))),
        );
      } on Object {
        // All-or-nothing server-side, so there is nothing partially applied
        // to describe — say so plainly (FR-015).
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.pricingGridColumnActionFailed)),
        );
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(priceList.name, overflow: TextOverflow.ellipsis)),
        MenuAnchor(
          menuChildren: [
            MenuItemButton(
              key: Key('pricing_grid_fill_down_${priceList.priceListId}'),
              leadingIcon: const Icon(Icons.arrow_downward, size: 18),
              onPressed: () => run(
                () => notifier.fillDown(priceListId: priceList.priceListId),
              ),
              child: Text(l10n.pricingGridFillDown),
            ),
            // Offered only when the deployment's cost list actually exists and
            // is not this column itself (FR-013).
            if (costList != null &&
                costList.priceListId != priceList.priceListId)
              MenuItemButton(
                key: Key('pricing_grid_copy_cost_${priceList.priceListId}'),
                leadingIcon: const Icon(Icons.content_copy, size: 18),
                onPressed: () => run(
                  () => notifier.copyFromCostList(
                    priceListId: priceList.priceListId,
                  ),
                ),
                child: Text(l10n.pricingGridCopyFromCost(costList.name)),
              ),
            const Divider(height: 1),
            _AdjustByPercentItem(
              priceList: priceList,
              onApply: (percent) => run(
                () => notifier.adjustByPercent(
                  priceListId: priceList.priceListId,
                  percent: percent,
                ),
              ),
            ),
          ],
          builder: (context, controller, _) => IconButton(
            key: Key('pricing_grid_column_menu_${priceList.priceListId}'),
            icon: const Icon(Icons.more_vert, size: 18),
            tooltip: l10n.pricingGridColumnActionsTooltip,
            visualDensity: VisualDensity.compact,
            onPressed: () =>
                controller.isOpen ? controller.close() : controller.open(),
          ),
        ),
      ],
    );
  }
}

/// The percentage row of the column menu — its own widget because it holds a
/// text field, and a `MenuItemButton` closing on tap would take the field
/// with it.
class _AdjustByPercentItem extends StatefulWidget {
  const _AdjustByPercentItem({required this.priceList, required this.onApply});

  final PriceList priceList;
  final ValueChanged<Decimal> onApply;

  @override
  State<_AdjustByPercentItem> createState() => _AdjustByPercentItemState();
}

class _AdjustByPercentItemState extends State<_AdjustByPercentItem> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    final parsed = Decimal.tryParse(_controller.text.trim());
    if (parsed == null) return;
    widget.onApply(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.pricingGridAdjustLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 88,
                child: TextField(
                  key: Key(
                    'pricing_grid_adjust_field_${widget.priceList.priceListId}',
                  ),
                  controller: _controller,
                  textAlign: TextAlign.right,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(
                    suffixText: '%',
                    isDense: true,
                  ),
                  onSubmitted: (_) => _apply(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                key: Key(
                  'pricing_grid_adjust_apply_${widget.priceList.priceListId}',
                ),
                onPressed: _apply,
                child: Text(l10n.pricingGridAdjustApply),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Mirrors the products list's own filter drawer (FR-021) — same sections,
/// same order, same widgets — plus a "price lists shown" section (FR-020)
/// this grid alone needs. A small private duplicate of
/// `_ProductFiltersPanel`'s tri-state chip rather than a shared extraction:
/// the two screens' filters are not the same widget tree, only the same
/// visual convention.
class _PricingGridFiltersPanel extends ConsumerWidget {
  const _PricingGridFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = PricingGridFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final allLists =
        ref
            .watch(pricingGridControllerProvider(filter))
            .valueOrNull
            ?.allLists ??
        const <PriceList>[];
    final shownIds = ref.watch(pricingGridShownColumnsProvider);
    final allLabels = ref.watch(allLabelsProvider).valueOrNull ?? <LabelItem>[];
    final supplierRepo = ref.read(supplierRepositoryProvider);
    final supplierDisplayText = filter.supplier != null
        ? ref
                  .watch(supplierDisplayNameProvider(filter.supplier!))
                  .valueOrNull ??
              '${filter.supplier}'
        : '';

    void goTo(ListQuery updated) =>
        context.go(updated.toUri(_pricingPath).toString());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.pricingGridColumnsFilterLabel,
          key: const Key('pricing_grid_columns_section'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final list in allLists)
              FilterChip(
                key: Key('pricing_grid_column_chip_${list.priceListId}'),
                label: Text(list.name),
                selected:
                    shownIds == null || shownIds.contains(list.priceListId),
                onSelected: (_) => ref
                    .read(pricingGridShownColumnsProvider.notifier)
                    .toggle(
                      list.priceListId,
                      allIds: allLists.map((l) => l.priceListId).toList(),
                    ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.statusFilterLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        EntityStatusFilterChips(
          filterKey: 'pricing_grid_filter_status',
          value: filter.status,
          onChanged: (status) =>
              goTo(encodeStatusFacet(query, status).copyWith(pageIndex: 0)),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.productsAttributesFilterLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _TriStateFilterChip(
              chipKey: const Key('pricing_grid_filter_stockable'),
              label: l10n.productsStockableFilter,
              value: filter.stockable,
              onChanged: (value) => goTo(
                query
                    .withFacet('stockable', value?.toString())
                    .copyWith(pageIndex: 0),
              ),
            ),
            _TriStateFilterChip(
              chipKey: const Key('pricing_grid_filter_salable'),
              label: l10n.productsSalableFilter,
              value: filter.salable,
              onChanged: (value) => goTo(
                query
                    .withFacet('salable', value?.toString())
                    .copyWith(pageIndex: 0),
              ),
            ),
            _TriStateFilterChip(
              chipKey: const Key('pricing_grid_filter_purchasable'),
              label: l10n.productsPurchasableFilter,
              value: filter.purchasable,
              onChanged: (value) => goTo(
                query
                    .withFacet('purchasable', value?.toString())
                    .copyWith(pageIndex: 0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          l10n.productsSupplierFilter,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        CatalogEntityPicker<SupplierListItem>(
          key: const Key('pricing_grid_filter_supplier'),
          label: l10n.productsSupplierSearchHint,
          displayStringForOption: (s) => '${s.code} — ${s.name}',
          optionsBuilder: (search) async {
            final result = await supplierRepo.list(
              search: search.isEmpty ? null : search,
            );
            return result.items;
          },
          onSelected: (s) => goTo(
            query
                .withFacet('supplier', '${s.supplierId}')
                .copyWith(pageIndex: 0),
          ),
          initialDisplayText: supplierDisplayText,
        ),
        if (allLabels.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            l10n.productsLabelFilter,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          LabelMultiPicker(
            key: const Key('pricing_grid_filter_label'),
            labels: allLabels,
            selectedIds: filter.labels,
            onChanged: (labelIds) => goTo(
              query
                  .withFacetValues(
                    'label',
                    labelIds.map((id) => '$id').toList(),
                  )
                  .copyWith(pageIndex: 0),
            ),
          ),
        ],
      ],
    );
  }
}

class _TriStateFilterChip extends StatelessWidget {
  const _TriStateFilterChip({
    required this.label,
    required this.value,
    required this.onChanged,
    this.chipKey,
  });

  final String label;
  final bool? value;
  final ValueChanged<bool?> onChanged;
  final Key? chipKey;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      key: chipKey,
      label: Text(label),
      selected: value != null,
      showCheckmark: false,
      avatar: switch (value) {
        true => const Icon(Icons.check, size: 18),
        false => const Icon(Icons.close, size: 18),
        null => null,
      },
      onSelected: (_) => onChanged(switch (value) {
        null => true,
        true => false,
        false => null,
      }),
    );
  }
}
