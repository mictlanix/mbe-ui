import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
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
    final canDelete = access.can(SystemObject.products, AccessRight.delete);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productsTitle),
        actions: [
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
                FilterChip(
                  key: const Key('products_filter_show_inactive'),
                  label: Text(l10n.productsShowInactiveFilter),
                  selected: filter.deactivated == null,
                  onSelected: (selected) => filterController.deactivatedChanged(
                    selected ? null : false,
                  ),
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
                        DataTableColumn.text(
                          label: l10n.columnCode,
                          text: (p) => p.code,
                          frozen: true,
                        ),
                        DataTableColumn.text(
                          label: l10n.columnName,
                          text: (p) => p.name,
                        ),
                        DataTableColumn.text(
                          label: l10n.columnBrand,
                          text: (p) => p.brand ?? '',
                        ),
                        DataTableColumn.text(
                          label: l10n.columnUnit,
                          text: (p) => p.unitOfMeasurement,
                        ),
                        DataTableColumn(
                          label: l10n.columnStatus,
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
                      onRowTap: (p) => context.push('/products/${p.productId}'),
                      rowActionsBuilder: (context, p) => buildCatalogRowActions(
                        viewTooltip: l10n.viewActionTooltip,
                        editTooltip: l10n.editActionTooltip,
                        deleteTooltip: l10n.deleteActionTooltip,
                        onView: () =>
                            context.push('/products/${p.productId}?view=true'),
                        onEdit: canUpdate
                            ? () => context.push('/products/${p.productId}')
                            : null,
                        onDelete: (canDelete && !p.deactivated)
                            ? () => _confirmDeactivate(context, ref, p)
                            : null,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeactivate(
    BuildContext context,
    WidgetRef ref,
    ProductListItem product,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deactivateProductConfirmTitle),
        content: Text(l10n.deactivateProductConfirmMessage(product.code)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            key: const Key('confirm_deactivate_product_button'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deactivateButton),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(productRepositoryProvider)
          .update(productId: product.productId, deactivated: true);
      final pageIndex =
          ref.read(productsListControllerProvider).value?.pageIndex ?? 0;
      ref.read(productsListControllerProvider.notifier).goToPage(pageIndex);
    }
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
