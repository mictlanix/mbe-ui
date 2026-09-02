import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/navigation/list_search_submit.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/label_multi_picker.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/products_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _productsPath = '/products';

/// Product catalog list screen (FR-001, FR-002). Gated by
/// `can(SystemObject.products, AccessRight.read)` in the router.
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class ProductsListScreen extends ConsumerWidget {
  const ProductsListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ProductFilter.fromQuery(query);
    final productsAsync = ref.watch(productsListControllerProvider(filter));
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.products, AccessRight.create);
    final canUpdate = access.can(SystemObject.products, AccessRight.update);
    final canMerge = access.can(SystemObject.productsMerge, AccessRight.create);
    final canViewPricing = access.can(SystemObject.pricing, AccessRight.read);
    final l10n = AppLocalizations.of(context)!;

    // Body-only: the shell owns the Scaffold/app bar (spec 010 US1). Entity
    // actions sit beside the search bar, Add emphasised as primary (US4).
    return Column(
      children: [
        CatalogFilterBar(
          search: CatalogSearchBar(
            key: const Key('products_search_field'),
            label: l10n.productsSearchLabel,
            searchTooltip: l10n.searchButtonTooltip,
            initialValue: filter.search,
            onSubmitted: (value) => submitCatalogSearch(
              context: context,
              query: query,
              path: _productsPath,
              submitted: value,
              current: filter.search,
              refresh: () =>
                  ref.invalidate(productsListControllerProvider(filter)),
            ),
          ),
          actions: [
            if (canCreate)
              FilledButton.icon(
                key: const Key('new_product_button'),
                icon: Icon(CatalogAction.create.icon),
                label: Text(l10n.newProductTooltip),
                onPressed: () => context.push('/products/new'),
              ),
            if (canMerge)
              IconButton.outlined(
                key: const Key('merge_products_button'),
                icon: const Icon(Icons.merge),
                tooltip: l10n.mergeProductsTooltip,
                onPressed: () => context.push('/products/merge'),
              ),
          ],
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
                  onClearAll: () => context.go(_productsPath),
                  builder: (_) => CurrentListQueryBuilder(
                    builder: (context, query) =>
                        _ProductFiltersPanel(query: query),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<ProductListItem>(
            state: productsAsync,
            isFiltered: isFilteredBeyondStatusDefault(query, filter.status),
            emptyMessage: l10n.noProductsFound,
            createLabel: canCreate ? l10n.newProductTooltip : null,
            onCreate: canCreate ? () => context.push('/products/new') : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_productsPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(productsListControllerProvider(filter)),
            onData: (page) => DataTableView<ProductListItem>(
              key: const Key('products_table'),
              columns: [
                DataTableColumn(
                  label: '',
                  fixedWidth: 120,
                  cellBuilder: (context, p) => ProductPhoto(photoUrl: p.photo),
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
                  cellBuilder: (context, p) =>
                      EntityStatusCell(status: p.status),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_productsPath)
                    .toString(),
              ),
              onRowTap: (p) =>
                  context.push('/products/${p.productId}?view=true'),
              rowActionsBuilder: (context, p) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => context.push('/products/${p.productId}')
                    : null,
                extraActions: [
                  if (canViewPricing)
                    CatalogRowAction(
                      key: Key('view_pricing_button_${p.productId}'),
                      icon: Icons.sell_outlined,
                      tooltip: l10n.viewPricingButton,
                      onPressed: () => context.push(
                        Uri(
                          path: '/products/${p.productId}/pricing',
                          queryParameters: {
                            'productDisplayText': '${p.code} — ${p.name}',
                          },
                        ).toString(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.codeCopiedMessage)));
  }
}

/// The products catalog's facet filters (show-inactive, the three tri-state
/// attribute chips, and the label selector), rendered inside the filter panel
/// opened from the Filters button (FR-001). A [ConsumerWidget] so the controls
/// stay reactive as the URL changes while the sheet — which lives on its own
/// navigator route — is open. Each change navigates immediately via
/// `context.go`; the panel itself holds no state.
class _ProductFiltersPanel extends ConsumerWidget {
  const _ProductFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ProductFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final allLabels = ref.watch(allLabelsProvider).valueOrNull ?? <LabelItem>[];
    // `null` while loading/errored => every chip stays enabled (fail open,
    // spec 009 FR-010) rather than blocking the user on a facet failure.
    final labelCounts = ref
        .watch(productLabelFacetsProvider(filter))
        .valueOrNull;
    final supplierRepo = ref.read(supplierRepositoryProvider);
    final supplierDisplayText = filter.supplier != null
        ? ref
                  .watch(supplierDisplayNameProvider(filter.supplier!))
                  .valueOrNull ??
              '${filter.supplier}'
        : '';

    void goTo(ListQuery updated) =>
        context.go(updated.toUri(_productsPath).toString());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.statusFilterLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        EntityStatusFilterChips(
          filterKey: 'products_filter_status',
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
              chipKey: const Key('products_filter_stockable'),
              label: l10n.productsStockableFilter,
              value: filter.stockable,
              onChanged: (value) => goTo(
                query
                    .withFacet('stockable', value?.toString())
                    .copyWith(pageIndex: 0),
              ),
            ),
            _TriStateFilterChip(
              chipKey: const Key('products_filter_salable'),
              label: l10n.productsSalableFilter,
              value: filter.salable,
              onChanged: (value) => goTo(
                query
                    .withFacet('salable', value?.toString())
                    .copyWith(pageIndex: 0),
              ),
            ),
            _TriStateFilterChip(
              chipKey: const Key('products_filter_purchasable'),
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
          key: const Key('products_filter_supplier'),
          // The section heading already says "Supplier"; the field says what
          // to do with it, rather than repeating the noun.
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
            labelCounts: labelCounts,
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
