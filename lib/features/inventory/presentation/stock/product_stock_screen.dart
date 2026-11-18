import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/inventory/domain/entities/stock.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/inventory/presentation/stock/product_stock_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One product's stock in every warehouse (spec 071 US2, contracts/
/// ui-contract.md "Product view"), with its totals above the table and its
/// in-transit stock below (research R6). Read-only, no AppBar actions.
///
/// Reached from an Existencias row and from the catalog's "Ver existencias";
/// the route is gated by WarehouseStockReport (SystemObject 67) read.
class ProductStockScreen extends ConsumerWidget {
  /// [productId] is `null` for an address whose id isn't a number, which
  /// shows the not-found state instead of throwing.
  const ProductStockScreen({super.key, required this.productId});

  final int? productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final id = productId;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navInventoryStock)),
        body: const _NotFound(),
      );
    }
    final async = ref.watch(productStockControllerProvider(id));
    final view = async.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          view == null
              ? l10n.navInventoryStock
              : l10n.inventoryStockProductTitle(view.code, view.name).trim(),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => error is NotFoundError
            ? const _NotFound()
            : ListFailedView(
                error: toAppError(error),
                retryLabel: l10n.retryButton,
                onRetry: () =>
                    ref.invalidate(productStockControllerProvider(id)),
              ),
        data: (view) => view.stock.isEmpty
            ? ListEmptyView(message: l10n.inventoryStockProductEmpty)
            : _ProductStockBody(view: view),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(Theme.of(context).spacing.screenMargin),
    child: const Align(
      alignment: Alignment.topLeft,
      child: ErrorBanner(
        key: Key('product_stock_not_found'),
        error: AppError.notFound(),
      ),
    ),
  );
}

class _ProductStockBody extends ConsumerWidget {
  const _ProductStockBody({required this.view});

  final ProductStockView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    // Kardex (32) read: the "Ver kardex" row action.
    final canReadKardex = ref
        .watch(accessControlProvider)
        .can(SystemObject.kardex, AccessRight.read);
    final stock = view.stock;
    final totals = stock.totals;

    // Negative figures stay negative (FR-016).
    String quantity(Object value) => fmt.display.quantity(value.toString());

    DataTableColumn<StockRow> quantityColumn(
      String label,
      Object Function(StockRow r) value,
    ) => DataTableColumn(
      label: label,
      size: ColumnSize.S,
      numeric: true,
      cellBuilder: (context, r) =>
          Text(quantity(value(r)), textAlign: TextAlign.end),
    );

    Widget total(String label, Object value) =>
        CompactField(label: label, child: Text(quantity(value)));

    // simplified: unpaginated, a product sits in at most a few dozen warehouses; page the table if a catalog ever spans hundreds.
    return ListView(
      padding: EdgeInsets.all(spacing.screenMargin),
      children: [
        if (stock.warehouses.isNotEmpty) ...[
          FactStripRow(
            key: const Key('product_stock_totals'),
            facts: [
              total(l10n.inventoryStockTotalOnHand, totals.onHand),
              total(l10n.inventoryStockTotalReserved, totals.reserved),
              total(l10n.inventoryStockTotalAvailable, totals.available),
              total(l10n.inventoryStockTotalIncoming, totals.incoming),
            ],
            trailing: const SizedBox.shrink(),
          ),
          SizedBox(height: spacing.fieldGapVertical),
          DataTableView<StockRow>(
            key: const Key('product_stock_table'),
            shrinkWrap: true,
            margin: EdgeInsets.zero,
            rows: stock.warehouses,
            columns: [
              DataTableColumn(
                label: l10n.inventoryStockColumnWarehouse,
                size: ColumnSize.M,
                cellBuilder: (context, r) =>
                    InventoryWarehouseName(warehouseId: r.warehouseId),
              ),
              DataTableColumn(
                label: l10n.inventoryStockColumnFacility,
                size: ColumnSize.M,
                cellBuilder: (context, r) {
                  final facility = view.facilities[r.warehouseId];
                  // An unresolved warehouse keeps its id (T011).
                  return facility == null
                      ? Text('#${r.warehouseId}')
                      : InventoryFacilityName(
                          facilityId: facility.facilityId,
                          name: facility.facilityName,
                        );
                },
              ),
              quantityColumn(l10n.inventoryStockColumnOnHand, (r) => r.onHand),
              quantityColumn(
                l10n.inventoryStockColumnReserved,
                (r) => r.reserved,
              ),
              quantityColumn(
                l10n.inventoryStockColumnAvailable,
                (r) => r.available,
              ),
              quantityColumn(
                l10n.inventoryStockColumnIncoming,
                (r) => r.incoming,
              ),
            ],
            rowActionsBuilder: canReadKardex
                ? (context, r) => buildCatalogRowActions(
                    editTooltip: l10n.editRecordTooltip,
                    onEdit: null,
                    extraActions: [
                      CatalogRowAction(
                        key: Key('product_stock_kardex_${r.warehouseId}'),
                        icon: Icons.receipt_long_outlined,
                        tooltip: l10n.inventoryStockViewKardex,
                        onPressed: () => context.push(
                          Uri(
                            path: kardexPagePath,
                            queryParameters: {
                              'product': '${stock.productId}',
                              'warehouse': '${r.warehouseId}',
                            },
                          ).toString(),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ],
        if (stock.inTransit.isNotEmpty) ...[
          SizedBox(height: spacing.sectionGap),
          Column(
            key: const Key('product_stock_in_transit'),
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.sm,
            children: [
              Text(
                l10n.inventoryStockInTransitHeading,
                style: theme.textTheme.titleMedium,
              ),
              for (final t in stock.inTransit)
                Row(
                  spacing: spacing.md,
                  children: [
                    Flexible(
                      child: InventoryFacilityName(facilityId: t.facilityId),
                    ),
                    Text(quantity(t.onHand)),
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }
}
