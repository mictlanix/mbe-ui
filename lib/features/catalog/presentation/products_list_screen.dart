import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/label_multi_picker.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/products_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Product catalog list screen (FR-001, FR-002). Gated by
/// `can(SystemObject.products, AccessRight.read)` in the router.
class ProductsListScreen extends ConsumerWidget {
  const ProductsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsListControllerProvider);
    final filter = ref.watch(productFilterControllerProvider);
    final filterController = ref.read(productFilterControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.products, AccessRight.create);
    final canUpdate = access.can(SystemObject.products, AccessRight.update);
    final canMerge = access.can(SystemObject.productsMerge, AccessRight.create);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productsTitle),
        actions: [
          if (canMerge)
            IconButton(
              key: const Key('merge_products_button'),
              icon: const Icon(Icons.merge),
              tooltip: l10n.mergeProductsTooltip,
              onPressed: () => context.push('/products/merge'),
            ),
          if (canCreate)
            IconButton(
              key: const Key('new_product_button'),
              icon: Icon(CatalogAction.create.icon),
              tooltip: l10n.newProductTooltip,
              onPressed: () => context.push('/products/new'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: CatalogFilterBar(
              search: CatalogSearchBar(
                key: const Key('products_search_field'),
                label: l10n.productsSearchLabel,
                searchTooltip: l10n.searchButtonTooltip,
                initialValue: filter.search,
                onSubmitted: filterController.searchChanged,
              ),
              filters: [
                Badge.count(
                  count: filter.activeFilterCount,
                  isLabelVisible: filter.hasActiveFilters,
                  child: IconButton.outlined(
                    key: const Key('products_filter_button'),
                    icon: const Icon(Icons.tune),
                    tooltip: l10n.filtersTooltip,
                    onPressed: () => showCatalogFilterSheet(
                      context,
                      title: l10n.filtersButton,
                      clearAllLabel: l10n.clearAllFilters,
                      applyLabel: l10n.applyFilters,
                      onClearAll: filterController.reset,
                      builder: (_) => const _ProductFiltersPanel(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.productsLoadError(e))),
              data: (CatalogPage<ProductListItem> page) => page.items.isEmpty
                  ? Center(child: Text(l10n.noProductsFound))
                  : DataTableView<ProductListItem>(
                      key: const Key('products_table'),
                      columns: [
                        DataTableColumn(
                          label: '',
                          fixedWidth: 120,
                          cellBuilder: (context, p) =>
                              ProductPhoto(photoUrl: p.photo),
                        ),
                        DataTableColumn(
                          label: l10n.columnCode,
                          fixedWidth: 200,
                          cellBuilder: (context, p) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(p.code),
                              IconButton(
                                key: Key('copy_code_button_${p.productId}'),
                                icon: const Icon(Icons.copy, size: 16),
                                tooltip: l10n.copyCodeTooltip,
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 28,
                                  minHeight: 28,
                                ),
                                onPressed: () => _copyCode(context, p.code, l10n),
                              ),
                            ],
                          ),
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
                        DataTableColumn(
                          label: l10n.columnStatus,
                          fixedWidth: 130,
                          cellBuilder: (context, p) => p.deactivated
                              ? Chip(
                                  key: const Key('inactive_badge'),
                                  label: Text(l10n.statusInactiveBadge),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.errorContainer,
                                  labelStyle: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                )
                              : Text(l10n.statusActive),
                        ),
                      ],
                      rows: page.items,
                      pagination: page,
                      onPageChanged: (pageIndex) => ref
                          .read(productsListControllerProvider.notifier)
                          .goToPage(pageIndex),
                      onRowTap: (p) =>
                          context.push('/products/${p.productId}?view=true'),
                      rowActionsBuilder: (context, p) => buildCatalogRowActions(
                        editTooltip: l10n.editActionTooltip,
                        onEdit: canUpdate
                            ? () => context.push('/products/${p.productId}')
                            : null,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Copies [code] to the system clipboard and shows a brief confirmation
  /// (FR-020).
  Future<void> _copyCode(
    BuildContext context,
    String code,
    AppLocalizations l10n,
  ) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.codeCopiedMessage)),
    );
  }
}

/// The products catalog's facet filters (show-inactive, the three tri-state
/// attribute chips, and the label selector), rendered inside the filter panel
/// opened from the Filters button (FR-001). A [ConsumerWidget] so the controls
/// stay reactive to [ProductFilterController] changes while the sheet — which
/// lives on its own navigator route — is open.
class _ProductFiltersPanel extends ConsumerWidget {
  const _ProductFiltersPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(productFilterControllerProvider);
    final filterController = ref.read(productFilterControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final allLabels = ref.watch(allLabelsProvider).valueOrNull ?? <LabelItem>[];
    // `null` while loading/errored => every chip stays enabled (fail open,
    // spec 009 FR-010) rather than blocking the user on a facet failure.
    final availableLabelIds =
        ref.watch(productLabelFacetsProvider).valueOrNull;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              key: const Key('products_filter_show_inactive'),
              label: Text(l10n.productsShowInactiveFilter),
              selected: filter.deactivated == null,
              onSelected: (selected) =>
                  filterController.deactivatedChanged(selected ? null : false),
            ),
            _TriStateFilterChip(
              chipKey: const Key('products_filter_stockable'),
              label: l10n.productsStockableFilter,
              value: filter.stockable,
              onChanged: filterController.stockableChanged,
            ),
            _TriStateFilterChip(
              chipKey: const Key('products_filter_salable'),
              label: l10n.productsSalableFilter,
              value: filter.salable,
              onChanged: filterController.salableChanged,
            ),
            _TriStateFilterChip(
              chipKey: const Key('products_filter_purchasable'),
              label: l10n.productsPurchasableFilter,
              value: filter.purchasable,
              onChanged: filterController.purchasableChanged,
            ),
          ],
        ),
        if (allLabels.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            l10n.productsLabelFilter,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          LabelMultiPicker(
            key: const Key('products_filter_label'),
            labels: allLabels,
            selectedIds: filter.labels,
            availableIds: availableLabelIds,
            onChanged: filterController.labelsChanged,
          ),
        ],
      ],
    );
  }
}

/// A [FilterChip] that cycles through `null` (no filter) → `true` → `false`
/// → `null` on tap, since [ProductFilter]'s attribute filters are tri-state
/// (data-model.md "ProductFilter").
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
