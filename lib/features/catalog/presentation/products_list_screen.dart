import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productsTitle),
        actions: [
          if (canCreate)
            IconButton(
              key: const Key('new_product_button'),
              icon: const Icon(Icons.add_box),
              tooltip: l10n.newProductTooltip,
              onPressed: () => context.push('/products/new'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  key: const Key('products_search_field'),
                  decoration: InputDecoration(
                    labelText: l10n.productsSearchLabel,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: filterController.searchChanged,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      key: const Key('products_filter_show_inactive'),
                      label: Text(l10n.productsShowInactiveFilter),
                      selected: filter.deactivated == null,
                      onSelected: (selected) => filterController
                          .deactivatedChanged(selected ? null : false),
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
              ],
            ),
          ),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.productsLoadError(e))),
              data: (result) => result.items.isEmpty
                  ? Center(child: Text(l10n.noProductsFound))
                  : Column(
                      children: [
                        Expanded(
                          child: DataTableView<ProductListItem>(
                            key: const Key('products_table'),
                            columns: [
                              DataTableColumn(
                                label: l10n.columnCode,
                                cellBuilder: (_, p) => Text(p.code),
                                comparator: (a, b) => a.code.compareTo(b.code),
                              ),
                              DataTableColumn(
                                label: l10n.columnName,
                                cellBuilder: (_, p) => Text(p.name),
                                comparator: (a, b) => a.name.compareTo(b.name),
                              ),
                              DataTableColumn(
                                label: l10n.columnBrand,
                                cellBuilder: (_, p) => Text(p.brand ?? ''),
                              ),
                              DataTableColumn(
                                label: l10n.columnUnit,
                                cellBuilder: (_, p) => Text(p.unitOfMeasurement),
                              ),
                              DataTableColumn(
                                label: l10n.columnStatus,
                                cellBuilder: (_, p) => Text(
                                  p.deactivated
                                      ? l10n.statusDisabled
                                      : l10n.statusActive,
                                ),
                              ),
                            ],
                            rows: result.items,
                            onRowTap: (p) =>
                                context.push('/products/${p.productId}'),
                          ),
                        ),
                        if (result.items.length < result.total)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextButton(
                              key: const Key('products_load_more_button'),
                              onPressed: () => ref
                                  .read(productsListControllerProvider.notifier)
                                  .loadMore(),
                              child: Text(l10n.loadMoreButton),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
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
