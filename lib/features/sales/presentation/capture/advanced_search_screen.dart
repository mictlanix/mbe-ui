import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/label_multi_picker.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/products_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/capture/advanced_search_state.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const advancedSearchPath = '/sales/product-search';

/// Browse the active, salable products catalog from inside a sale and tick
/// one or several to add as lines (spec 038). Modelled on
/// `ProductsListScreen`, minus the status column and row action icons, plus
/// a leading checkbox column — but pushed as its own top-level route rather
/// than a shell branch, and navigated within itself via [GoRouter.replace]
/// rather than `context.go`: this screen sits on top of an in-progress
/// sale, and `go` would unmount it (research.md R1).
///
/// The confirmed selection never returns through the `push` future — a
/// `replace` leaves it permanently uncompleted (research.md R1, R2) — it
/// travels back through [advancedSearchResultProvider] instead, consumed by
/// `ProductSearchField`.
class AdvancedSearchScreen extends ConsumerStatefulWidget {
  const AdvancedSearchScreen({super.key, required this.query});

  final ListQuery query;

  @override
  ConsumerState<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen> {
  // Guards the confirm action against a second tap landing before the pop
  // completes — one confirm must never publish two results (FR-022).
  bool _confirmed = false;

  /// This screen's own products filter: the URL's facets, with status and
  /// salable forced — unforgeable by the operator, since neither control is
  /// ever rendered and a hand-typed `?status=all` is simply not read here
  /// (FR-008; research.md R5).
  ProductFilter get _filter => ProductFilter.fromQuery(
    widget.query,
  ).copyWith(status: EntityStatus.active, salable: true);

  void _replaceWith(ListQuery query) {
    GoRouter.of(context).replace(query.toUri(advancedSearchPath).toString());
  }

  void _toggle(ProductListItem product, {required bool multiSelect}) {
    final notifier = ref.read(advancedSearchSelectionProvider.notifier);
    final current = notifier.state;
    final already = current.any((p) => p.productId == product.productId);
    if (already) {
      notifier.state = current.where((p) => p.productId != product.productId).toList();
    } else if (multiSelect) {
      notifier.state = [...current, product];
    } else {
      // Single-selection mode: ticking a row releases whatever was
      // previously selected rather than appending to it (FR-015, FR-016).
      notifier.state = [product];
    }
  }

  void _cancel() {
    ref.read(advancedSearchSelectionProvider.notifier).state = const [];
    Navigator.of(context).pop();
  }

  void _confirm(List<ProductListItem> selection) {
    if (_confirmed) return;
    _confirmed = true;
    ref.read(advancedSearchResultProvider.notifier).state = selection;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = widget.query;
    final filter = _filter;
    final productsAsync = ref.watch(productsListControllerProvider(filter));
    final selection = ref.watch(advancedSearchSelectionProvider);
    final multiSelect = ref.watch(productSearchMultiSelectProvider);
    final canPop = Navigator.of(context).canPop();
    final badgeCount = _panelFilterCount(filter);
    final isFiltered = query.search.isNotEmpty || badgeCount > 0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.advancedSearchTitle)),
      body: Column(
        children: [
          CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('advanced_search_search_field'),
              label: l10n.productsSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: query.search,
              onSubmitted: (value) {
                if (value == query.search) {
                  ref.invalidate(productsListControllerProvider(filter));
                  return;
                }
                _replaceWith(query.copyWith(search: value, pageIndex: 0));
              },
            ),
            filters: [
              Badge.count(
                count: badgeCount,
                isLabelVisible: badgeCount > 0,
                child: IconButton.outlined(
                  key: const Key('advanced_search_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filtersTooltip,
                  onPressed: () => showCatalogFilterSheet(
                    context,
                    title: l10n.filtersButton,
                    clearAllLabel: l10n.clearAllFilters,
                    applyLabel: l10n.applyFilters,
                    onClearAll: () => _replaceWith(const ListQuery()),
                    builder: (_) => CurrentListQueryBuilder(
                      builder: (context, currentQuery) => _AdvancedSearchFiltersPanel(
                        query: currentQuery,
                        onChanged: _replaceWith,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: CatalogListStateView<ProductListItem>(
              state: productsAsync,
              isFiltered: isFiltered,
              emptyMessage: l10n.noProductsFound,
              clearFiltersLabel: l10n.clearFiltersButton,
              onClearFilters: () => _replaceWith(const ListQuery()),
              retryLabel: l10n.retryButton,
              onRetry: () => ref.invalidate(productsListControllerProvider(filter)),
              onData: (page) => DataTableView<ProductListItem>(
                key: const Key('advanced_search_table'),
                columns: [
                  DataTableColumn(
                    label: '',
                    // Narrower than /products' own columns (research.md R4's
                    // consecutive-fixed-width note) — this screen has three
                    // fixed columns in a row instead of two, and the combined
                    // width must clear a phone's available table width
                    // without tripping data_table_2's own hard assertion on
                    // it (FR-014).
                    fixedWidth: 48,
                    cellBuilder: (context, p) {
                      final selected = selection.any((s) => s.productId == p.productId);
                      return IgnorePointer(
                        key: Key('advanced_search_row_${p.productId}'),
                        child: Checkbox(value: selected, onChanged: null),
                      );
                    },
                  ),
                  DataTableColumn(
                    label: '',
                    fixedWidth: 96,
                    cellBuilder: (context, p) => ProductPhoto(photoUrl: p.photo, size: 72),
                  ),
                  DataTableColumn.text(
                    label: l10n.columnCode,
                    text: (p) => p.code,
                    fixedWidth: 140,
                  ),
                  DataTableColumn.text(
                    label: l10n.columnName,
                    text: (p) => p.name,
                    size: ColumnSize.L,
                  ),
                  DataTableColumn.text(
                    label: l10n.columnBrand,
                    text: (p) => p.brand ?? '',
                    size: ColumnSize.S,
                  ),
                  DataTableColumn.text(
                    label: l10n.columnUnit,
                    text: (p) => p.unitOfMeasurementName,
                    size: ColumnSize.M,
                  ),
                ],
                rows: page.items,
                pagination: page,
                onPageChanged: (pageIndex) => _replaceWith(query.copyWith(pageIndex: pageIndex)),
                onRowTap: (p) => _toggle(p, multiSelect: multiSelect),
              ),
            ),
          ),
          _BottomActionBar(
            selection: selection,
            multiSelect: multiSelect,
            canPop: canPop,
            onClear: () => ref.read(advancedSearchSelectionProvider.notifier).state = const [],
            onCancel: _cancel,
            onConfirm: () => _confirm(selection),
          ),
        ],
      ),
    );
  }

  /// The filters badge counts only what the panel can change — not the two
  /// forced facets, which `ProductFilterBadge.activeFilterCount` would
  /// otherwise count, showing 2 on a virgin screen (research.md R5).
  int _panelFilterCount(ProductFilter filter) =>
      (filter.stockable != null ? 1 : 0) +
      (filter.purchasable != null ? 1 : 0) +
      (filter.supplier != null ? 1 : 0) +
      filter.labels.length;
}

/// The bottom action bar: a running selection count, a clear action (multi-
/// select only), and Cancel/Confirm.
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.selection,
    required this.multiSelect,
    required this.canPop,
    required this.onClear,
    required this.onCancel,
    required this.onConfirm,
  });

  final List<ProductListItem> selection;
  final bool multiSelect;
  final bool canPop;
  final VoidCallback onClear;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final count = selection.length;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.cardPadding,
          vertical: theme.spacing.sm,
        ),
        // `OverflowBar`, not `Row`: at a narrow width (FR-014) the info side
        // and the two action buttons can genuinely not share one line —
        // Material 3's minimum tap targets alone can exceed a phone's width
        // once a selection count is showing. Lays out like a `Row` (info,
        // Cancel, Add, left to right) whenever all three fit, and stacks
        // each onto its own line, Add last, only when they don't — the same
        // pattern `catalog_filter_sheet.dart`'s footer already uses.
        child: OverflowBar(
          alignment: MainAxisAlignment.spaceBetween,
          overflowAlignment: OverflowBarAlignment.end,
          overflowSpacing: 8,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                if (count > 0) ...[
                  Text(
                    l10n.advancedSearchSelectionCount(count),
                    key: const Key('advanced_search_selection_count'),
                  ),
                  if (multiSelect)
                    TextButton(
                      key: const Key('advanced_search_clear_selection'),
                      onPressed: onClear,
                      child: Text(l10n.advancedSearchClearSelection),
                    ),
                ],
                if (!canPop)
                  Text(l10n.advancedSearchNoSaleHint, style: theme.textTheme.bodySmall),
              ],
            ),
            TextButton(
              key: const Key('advanced_search_cancel_button'),
              onPressed: onCancel,
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              key: const Key('advanced_search_add_button'),
              onPressed: count > 0 && canPop ? onConfirm : null,
              child: Text(l10n.advancedSearchAddButton(count)),
            ),
          ],
        ),
      ),
    );
  }
}

/// The screen's own facet filters (Stockable, Purchasable, Supplier, Label)
/// — deliberately **not** `ProductsListScreen`'s `_ProductFiltersPanel`: this
/// screen shows neither a Status control nor a Salable control, since both
/// are forced (FR-008). A [ConsumerWidget] so the controls stay reactive as
/// the URL changes while the sheet — on its own navigator route — is open,
/// the same pattern `_ProductFiltersPanel` uses.
class _AdvancedSearchFiltersPanel extends ConsumerWidget {
  const _AdvancedSearchFiltersPanel({required this.query, required this.onChanged});

  final ListQuery query;
  final ValueChanged<ListQuery> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ProductFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final allLabels = ref.watch(allLabelsProvider).valueOrNull ?? <LabelItem>[];
    final forcedFilter = filter.copyWith(status: EntityStatus.active, salable: true);
    final labelCounts = ref.watch(productLabelFacetsProvider(forcedFilter)).valueOrNull;
    final supplierRepo = ref.read(supplierRepositoryProvider);
    final supplierDisplayText = filter.supplier != null
        ? ref.watch(supplierDisplayNameProvider(filter.supplier!)).valueOrNull ?? '${filter.supplier}'
        : '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              chipKey: const Key('advanced_search_filter_stockable'),
              label: l10n.productsStockableFilter,
              value: filter.stockable,
              onChanged: (value) => onChanged(
                query.withFacet('stockable', value?.toString()).copyWith(pageIndex: 0),
              ),
            ),
            _TriStateFilterChip(
              chipKey: const Key('advanced_search_filter_purchasable'),
              label: l10n.productsPurchasableFilter,
              value: filter.purchasable,
              onChanged: (value) => onChanged(
                query.withFacet('purchasable', value?.toString()).copyWith(pageIndex: 0),
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
          key: const Key('advanced_search_filter_supplier'),
          label: l10n.productsSupplierSearchHint,
          displayStringForOption: (s) => '${s.code} — ${s.name}',
          optionsBuilder: (search) async {
            final result = await supplierRepo.list(search: search.isEmpty ? null : search);
            return result.items;
          },
          onSelected: (s) => onChanged(
            query.withFacet('supplier', '${s.supplierId}').copyWith(pageIndex: 0),
          ),
          initialDisplayText: supplierDisplayText,
        ),
        if (allLabels.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            l10n.productsLabelFilter,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          LabelMultiPicker(
            key: const Key('advanced_search_filter_label'),
            labels: allLabels,
            selectedIds: filter.labels,
            labelCounts: labelCounts,
            onChanged: (labelIds) => onChanged(
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

/// A [FilterChip] that cycles `null` → `true` → `false` → `null` on tap —
/// identical to `ProductsListScreen`'s private chip of the same shape, kept
/// as its own copy here since that one is private to its file.
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
