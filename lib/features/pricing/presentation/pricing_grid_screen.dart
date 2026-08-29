import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('pricing_grid_search_field'),
              label: l10n.productsSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: (value) => context.go(
                query
                    .copyWith(search: value, pageIndex: 0)
                    .toUri(_pricingPath)
                    .toString(),
              ),
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
        ),
        Expanded(
          child: noPriceLists
              ? ListEmptyView(message: l10n.pricingNoPriceListsEmptyState)
              : CatalogListStateView<PricingGridRow>(
                  state: gridAsync.whenData((s) => s.page!),
                  isFiltered: query.isFiltered,
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
    );
  }
}

class _PricingGrid extends ConsumerWidget {
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

  List<PriceList> _visibleLists(Set<int>? shownIds) {
    if (shownIds == null) return state.allLists;
    return state.allLists.where((l) => shownIds.contains(l.priceListId)).toList();
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final shownIds = ref.watch(pricingGridShownColumnsProvider);
    final visibleLists = _visibleLists(shownIds);
    final rowIds = page.items.map((r) => r.product.productId).toList();
    final colIds = visibleLists.map((l) => l.priceListId).toList();

    void onMoveFrom(PriceCellKey current, PriceCellMove move) {
      final next = _nextKey(current, move, rowIds, colIds);
      if (next == null) return;
      ref
          .read(pricingGridControllerProvider(filter).notifier)
          .openCell(next);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataTableView<PricingGridRow>(
        key: const Key('pricing_grid_table'),
        minWidth: 640 + visibleLists.length * 176,
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
              fixedWidth: 176,
              numeric: true,
              cellBuilder: (context, row) {
                final key = PriceCellKey(
                  productId: row.product.productId,
                  priceListId: priceList.priceListId,
                );
                return PriceCell(
                  filter: filter,
                  productId: row.product.productId,
                  priceListId: priceList.priceListId,
                  price: row.prices[priceList.priceListId],
                  rejected: state.rejected[key],
                  inFlight: state.inFlight.contains(key),
                  isActive: state.active == key,
                  canUpdate: canUpdate,
                  onMove: (move) => onMoveFrom(key, move),
                );
              },
            ),
        ],
        rows: page.items,
        pagination: page,
        onPageChanged: (pageIndex) => context.go(
          query.copyWith(pageIndex: pageIndex).toUri(_pricingPath).toString(),
        ),
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
        ref.watch(pricingGridControllerProvider(filter)).valueOrNull?.allLists ??
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
                selected: shownIds == null || shownIds.contains(list.priceListId),
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
          onChanged: (status) => goTo(
            query.withFacet('status', status?.name).copyWith(pageIndex: 0),
          ),
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
                query.withFacet('salable', value?.toString()).copyWith(pageIndex: 0),
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
          label: l10n.productsSupplierFilter,
          displayStringForOption: (s) => '${s.code} — ${s.name}',
          optionsBuilder: (search) async {
            final result = await supplierRepo.list(
              search: search.isEmpty ? null : search,
            );
            return result.items;
          },
          onSelected: (s) => goTo(
            query.withFacet('supplier', '${s.supplierId}').copyWith(pageIndex: 0),
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
                  .withFacetValues('label', labelIds.map((id) => '$id').toList())
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
