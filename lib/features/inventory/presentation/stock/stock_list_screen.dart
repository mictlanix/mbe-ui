import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/inventory/domain/entities/stock.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_warehouse_options.dart';
import 'package:mbe_ui/features/inventory/presentation/stock/stock_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const stockPath = '/inventory/stock';

/// Existencias: one warehouse's stock, one row per product, in the server's
/// order (spec 071 US1, contracts/ui-contract.md "Existencias"). Gated by
/// WarehouseStockReport (SystemObject 67) read.
///
/// Read-only: no actions, and no row icons (§VI). A row tap opens the
/// product's stock in every warehouse. The warehouse picker lives in the
/// filter sheet, and the facts strip above the table always names the
/// chosen warehouse (research R2).
class StockListScreen extends ConsumerWidget {
  const StockListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final stockQuery = StockQuery.fromQuery(query);
    final warehouseId = stockQuery.warehouseId;
    final pageAsync = ref.watch(stockListControllerProvider(stockQuery));
    final fmt = ref.watch(formattersProvider);
    // Warehouses (4) read: the sheet's Almacén picker lists warehouses.
    final canReadWarehouses = ref
        .watch(accessControlProvider)
        .can(SystemObject.warehouses, AccessRight.read);
    final compact = LayoutBreakpoints.isCompact(context);

    void goTo(StockQuery updated) =>
        context.go(updated.toQuery().toUri(stockPath).toString());

    // No warehouse in the URL: start on the point-of-sale warehouse and
    // write it into the URL (FR-002, research R7). Until that is known the
    // screen shows a spinner rather than flashing the prompt.
    var seeding = false;
    if (warehouseId == null) {
      final start = ref.watch(stockStartingWarehouseProvider);
      final startId = start.value;
      seeding = start.isLoading || startId != null;
      if (startId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) goTo(stockQuery.withWarehouse(startId));
        });
      }
    }

    void openSheet() => showCatalogFilterSheet(
      context,
      title: l10n.filtersButton,
      clearAllLabel: l10n.clearAllFilters,
      applyLabel: l10n.applyFilters,
      onClearAll: () => goTo(const StockQuery()),
      builder: (_) => CurrentListQueryBuilder(
        builder: (context, query) => _StockFiltersPanel(query: query),
      ),
    );

    final String emptyMessage;
    if (warehouseId == null) {
      emptyMessage = l10n.inventoryStockPickWarehousePrompt;
    } else if (stockQuery.q.isNotEmpty) {
      emptyMessage = l10n.inventoryStockFilteredEmpty;
    } else {
      emptyMessage = l10n.inventoryStockEmpty;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogFilterBar(
          search: CatalogSearchBar(
            key: const Key('stock_search'),
            label: l10n.inventoryStockSearchLabel,
            searchTooltip: l10n.searchButtonTooltip,
            initialValue: stockQuery.q,
            onSubmitted: (value) => value == stockQuery.q
                ? ref.invalidate(stockListControllerProvider(stockQuery))
                : goTo(stockQuery.withSearch(value)),
          ),
          filters: [
            Badge.count(
              count: stockQuery.activeFilterCount,
              isLabelVisible: stockQuery.activeFilterCount > 0,
              child: IconButton.outlined(
                key: const Key('stock_filter_button'),
                icon: const Icon(Icons.tune),
                tooltip: l10n.filtersTooltip,
                onPressed: openSheet,
              ),
            ),
          ],
        ),
        if (warehouseId != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.cardPadding),
            child: FactStripRow(
              key: const Key('stock_selection'),
              facts: [
                CompactField(
                  label: l10n.inventoryStockSelectionWarehouse,
                  child: InventoryWarehouseName(warehouseId: warehouseId),
                ),
              ],
              trailing: const SizedBox.shrink(),
            ),
          ),
        Expanded(
          child: seeding
              ? const Center(child: CircularProgressIndicator())
              : CatalogListStateView<StockRow>(
                  state: pageAsync,
                  // The specific texts above replace the generic
                  // filtered-empty view: the warehouse is required, so only
                  // the search narrows the list.
                  isFiltered: false,
                  emptyMessage: emptyMessage,
                  // The prompt's "Elegir almacén" opens the sheet; without
                  // Warehouses (4) read the sheet has no picker, so the
                  // button is absent.
                  createLabel: warehouseId == null && canReadWarehouses
                      ? l10n.inventoryStockPickWarehouseButton
                      : null,
                  onCreate: openSheet,
                  clearFiltersLabel: l10n.clearFiltersButton,
                  onClearFilters: () => goTo(const StockQuery()),
                  retryLabel: l10n.retryButton,
                  onRetry: () =>
                      ref.invalidate(stockListControllerProvider(stockQuery)),
                  onData: (page) => DataTableView<StockRow>(
                    key: const Key('stock_table'),
                    columns: [
                      DataTableColumn(
                        label: l10n.inventoryStockColumnCode,
                        size: ColumnSize.S,
                        cellBuilder: (context, r) => Text(r.productCode),
                      ),
                      DataTableColumn(
                        label: l10n.inventoryStockColumnProduct,
                        size: ColumnSize.L,
                        cellBuilder: (context, r) => Text(r.productName),
                      ),
                      _quantityColumn(
                        l10n.inventoryStockColumnOnHand,
                        (r) => fmt.display.quantity(r.onHand.toString()),
                      ),
                      // Apartado and Por recibir are dropped on phones; the
                      // product view shows them (wireframes, compact tier).
                      if (!compact)
                        _quantityColumn(
                          l10n.inventoryStockColumnReserved,
                          (r) => fmt.display.quantity(r.reserved.toString()),
                        ),
                      _quantityColumn(
                        l10n.inventoryStockColumnAvailable,
                        (r) => fmt.display.quantity(r.available.toString()),
                      ),
                      if (!compact)
                        _quantityColumn(
                          l10n.inventoryStockColumnIncoming,
                          (r) => fmt.display.quantity(r.incoming.toString()),
                        ),
                    ],
                    rows: page.items,
                    pagination: page,
                    onPageChanged: (pageIndex) =>
                        goTo(stockQuery.copyWith(pageIndex: pageIndex)),
                    onRowTap: (r) =>
                        context.push('$stockPath/products/${r.productId}'),
                  ),
                ),
        ),
      ],
    );
  }

  /// A right-aligned quantity, shown as the server sends it: a negative
  /// figure stays negative (FR-016).
  DataTableColumn<StockRow> _quantityColumn(
    String label,
    String Function(StockRow r) value,
  ) => DataTableColumn(
    label: label,
    size: ColumnSize.S,
    numeric: true,
    cellBuilder: (context, r) => Text(value(r), textAlign: TextAlign.end),
  );
}

/// The sheet's facets (spec 071 ui-contract): Almacén with Warehouses (4)
/// read, and "Mostrar sin existencia". Each change writes the URL and
/// returns to the first page.
class _StockFiltersPanel extends ConsumerWidget {
  const _StockFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Warehouses (4) read: the picker lists warehouses.
    final canReadWarehouses = ref
        .watch(accessControlProvider)
        .can(SystemObject.warehouses, AccessRight.read);
    final stockQuery = StockQuery.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final warehouseId = stockQuery.warehouseId;
    final warehouseName = warehouseId == null || !canReadWarehouses
        ? null
        : ref.watch(warehouseDisplayNameProvider(warehouseId)).value;

    void goTo(StockQuery updated) =>
        context.go(updated.toQuery().toUri(stockPath).toString());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        if (canReadWarehouses)
          CatalogEntityPicker<Warehouse>(
            key: const Key('stock_warehouse_filter'),
            label: l10n.inventoryStockFilterWarehouse,
            displayStringForOption: (w) => w.name,
            optionSubtitle: (w) => w.facilityName,
            optionsBuilder: (search) => inventoryFilterWarehouseOptions(
              ref.read(warehouseRepositoryProvider),
              search,
            ),
            onSelected: (w) => goTo(stockQuery.withWarehouse(w.warehouseId)),
            initialDisplayText:
                warehouseName ?? (warehouseId == null ? null : '#$warehouseId'),
          ),
        SwitchListTile(
          key: const Key('stock_include_zero'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.inventoryStockFilterIncludeZero),
          value: stockQuery.includeZero,
          onChanged: (on) => goTo(stockQuery.withIncludeZero(on)),
        ),
      ],
    );
  }
}
