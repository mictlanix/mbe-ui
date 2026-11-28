import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/navigation/list_search_submit.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/date_range_filter_chip.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/record_id_text.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_list_item.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_document_status_chip.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/new_order_dialog.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_availability.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_detail_screen.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_orders_filter.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_orders_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Órdenes de compra: the orders the server returns for the user, newest
/// first (spec 080 US2, contracts/ui-contract.md "Órdenes de compra list").
/// Gated by PurchasesOrders (SystemObject 20) read, at the route.
///
/// An order is a document, so a row has no icons and its tap opens the
/// detail screen (§VI document reading).
class PurchaseOrdersListScreen extends ConsumerWidget {
  const PurchaseOrdersListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    // PurchasesOrders (20) create, and Suppliers (3) read for the dialog's
    // supplier picker (FR-010).
    final canCreate = PurchaseOrderAvailability(
      status: null,
      access: ref.watch(accessControlProvider),
    ).canCreate;
    final filter = PurchaseOrdersFilter.fromQuery(query);
    final pageAsync = ref.watch(purchaseOrdersListControllerProvider(filter));
    final fmt = ref.watch(formattersProvider);
    final compact = LayoutBreakpoints.isCompact(context);
    final clearedPath = const ListQuery().toUri(purchaseOrdersPath).toString();
    // "Limpiar todo" in the drawer empties the facets and keeps the number.
    final facetsClearedPath = filter
        .cleared()
        .copyWith(search: filter.search)
        .toQuery()
        .toUri(purchaseOrdersPath)
        .toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        // §VI: the row holds only the number search, the filters button and
        // "Nueva orden"; the Mostrar scope is a facet in the drawer
        // (research R15).
        CatalogFilterBar(
          search: CatalogSearchBar(
            key: const Key('purchase_orders_search'),
            label: l10n.purchaseOrderSearchHint,
            searchTooltip: l10n.searchButtonTooltip,
            initialValue: filter.search,
            // The server matches the order number (`id`) as a number.
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (value) => submitCatalogSearch(
              context: context,
              query: query,
              path: purchaseOrdersPath,
              submitted: value.trim(),
              current: filter.search.trim(),
              refresh: () =>
                  ref.invalidate(purchaseOrdersListControllerProvider(filter)),
            ),
          ),
          filters: [
            Badge.count(
              count: filter.activeFilterCount,
              isLabelVisible: filter.activeFilterCount > 0,
              child: IconButton.outlined(
                key: const Key('purchase_orders_filter_button'),
                icon: const Icon(Icons.tune),
                tooltip: l10n.filtersTooltip,
                onPressed: () => showCatalogFilterSheet(
                  context,
                  title: l10n.filtersButton,
                  clearAllLabel: l10n.clearAllFilters,
                  applyLabel: l10n.applyFilters,
                  onClearAll: () => context.go(facetsClearedPath),
                  builder: (_) => CurrentListQueryBuilder(
                    builder: (context, query) =>
                        _PurchaseOrdersFiltersPanel(query: query),
                  ),
                ),
              ),
            ),
          ],
          actions: [
            if (canCreate)
              FilledButton.icon(
                key: const Key('purchase_orders_new_button'),
                onPressed: () => showNewOrderDialog(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.purchaseOrderNewAction),
              ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<PurchaseOrderSummary>(
            state: pageAsync,
            // The scope alone isn't a narrowing: "Todas" with nothing else
            // set has its own empty text.
            isFiltered: filter.copyWith(all: false).isNarrowed,
            emptyMessage: filter.all
                ? l10n.purchaseOrderEmptyAll
                : l10n.purchaseOrderEmptyMine,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(clearedPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(purchaseOrdersListControllerProvider(filter)),
            onData: (page) => DataTableView<PurchaseOrderSummary>(
              key: const Key('purchase_orders_table'),
              columns: [
                DataTableColumn(
                  label: l10n.purchaseOrderColNumber,
                  size: ColumnSize.S,
                  numeric: true,
                  cellBuilder: (context, o) => RecordIdText(
                    '${o.id}',
                    key: Key('purchase_order_number_${o.id}'),
                    textAlign: TextAlign.end,
                  ),
                ),
                // Truncated with a tooltip (FR-006).
                DataTableColumn.text(
                  label: l10n.purchaseOrderColSupplier,
                  size: ColumnSize.L,
                  text: (o) {
                    final name = o.supplierName;
                    return name == null || name.isEmpty
                        ? emptyValuePlaceholder
                        : name;
                  },
                ),
                DataTableColumn(
                  label: l10n.purchaseOrderColStatus,
                  size: ColumnSize.S,
                  cellBuilder: (context, o) =>
                      InventoryDocumentStatusChip(status: o.status),
                ),
                if (!compact)
                  DataTableColumn.timestamp(
                    label: l10n.purchaseOrderColDelivery,
                    size: ColumnSize.S,
                    text: (o) => fmt.display.date(o.estimatedReceiptDate),
                  ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.purchaseOrderColCreator,
                    size: ColumnSize.M,
                    cellBuilder: (context, o) =>
                        InventoryEmployeeName(employeeId: o.creatorId),
                  ),
                if (!compact)
                  DataTableColumn.timestamp(
                    label: l10n.purchaseOrderColDate,
                    size: ColumnSize.S,
                    text: (o) => fmt.display.dateTime(o.createdAt),
                  ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.purchaseOrderColLines,
                    size: ColumnSize.S,
                    numeric: true,
                    cellBuilder: (context, o) => Text(
                      fmt.display.count(o.lineCount),
                      key: Key('purchase_order_lines_${o.id}'),
                    ),
                  ),
                // Never truncated (FR-006).
                DataTableColumn(
                  label: l10n.purchaseOrderColTotal,
                  size: ColumnSize.M,
                  numeric: true,
                  cellBuilder: (context, o) => Text(
                    fmt.display.currency(o.total.toString()),
                    key: Key('purchase_order_total_${o.id}'),
                    softWrap: false,
                  ),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(purchaseOrdersPath)
                    .toString(),
              ),
              onRowTap: (o) => context.push('$purchaseOrdersPath/${o.id}'),
            ),
          ),
        ),
      ],
    );
  }
}

/// The drawer's facets (research R15): Mostrar and Estado, then Proveedor
/// and Creó, each with read on its catalog, and the date range. Each change
/// writes the URL and returns to the first page.
class _PurchaseOrdersFiltersPanel extends ConsumerWidget {
  const _PurchaseOrdersFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(accessControlProvider);
    // Suppliers (3) and Employees (6) read: each picker lists its catalog.
    final canReadSuppliers = access.can(
      SystemObject.suppliers,
      AccessRight.read,
    );
    final canReadEmployees = access.can(
      SystemObject.employees,
      AccessRight.read,
    );
    final filter = PurchaseOrdersFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final supplierId = filter.supplierId;
    final creatorId = filter.creatorId;
    final supplierName = supplierId == null || !canReadSuppliers
        ? null
        : ref.watch(supplierDisplayNameProvider(supplierId)).value;
    final creatorName = creatorId == null || !canReadEmployees
        ? null
        : ref.watch(employeeDisplayNameProvider(creatorId)).value;

    void goTo(ListQuery updated) => context.go(
      updated.copyWith(pageIndex: 0).toUri(purchaseOrdersPath).toString(),
    );

    Widget facet(String label, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.sm,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        child,
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        facet(
          l10n.purchaseOrderFacetScope,
          Wrap(
            key: const Key('purchase_orders_scope_filter'),
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              ChoiceChip(
                key: const Key('purchase_orders_scope_mine'),
                label: Text(l10n.purchaseOrderScopeMine),
                selected: !filter.all,
                onSelected: (_) => goTo(query.withFacet('all', null)),
              ),
              ChoiceChip(
                key: const Key('purchase_orders_scope_all'),
                label: Text(l10n.purchaseOrderScopeAll),
                selected: filter.all,
                onSelected: (_) => goTo(query.withFacet('all', 'true')),
              ),
            ],
          ),
        ),
        facet(
          l10n.purchaseOrderFacetStatus,
          Wrap(
            key: const Key('purchase_orders_status_filter'),
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              for (final status in InventoryDocumentStatus.values)
                ChoiceChip(
                  key: Key('purchase_orders_status_${status.name}'),
                  label: Text(inventoryDocumentStatusLabel(l10n, status)),
                  selected: filter.status == status,
                  // Tapping the selected chip again clears the facet.
                  onSelected: (selected) => goTo(
                    query.withFacet('status', selected ? status.name : null),
                  ),
                ),
            ],
          ),
        ),
        if (canReadSuppliers)
          CatalogEntityPicker<SupplierListItem>(
            key: const Key('purchase_orders_supplier_filter'),
            label: l10n.purchaseOrderFacetSupplier,
            // As supplierDisplayNameProvider names it, for the initial text.
            displayStringForOption: (s) => '${s.code} — ${s.name}',
            optionsBuilder: (search) async {
              final result = await ref
                  .read(supplierRepositoryProvider)
                  .list(search: search.isEmpty ? null : search);
              return result.items;
            },
            onSelected: (s) =>
                goTo(query.withFacet('supplier', '${s.supplierId}')),
            initialDisplayText:
                supplierName ?? (supplierId == null ? null : '#$supplierId'),
          ),
        if (canReadEmployees)
          CatalogEntityPicker<EmployeeListItem>(
            key: const Key('purchase_orders_creator_filter'),
            label: l10n.purchaseOrderFacetCreator,
            displayStringForOption: (e) => e.fullName,
            optionsBuilder: (search) async {
              final result = await ref
                  .read(employeeRepositoryProvider)
                  .list(search: search.isEmpty ? null : search);
              return result.items;
            },
            onSelected: (e) =>
                goTo(query.withFacet('creator', '${e.employeeId}')),
            initialDisplayText:
                creatorName ?? (creatorId == null ? null : '#$creatorId'),
          ),
        facet(
          l10n.purchaseOrderFacetDate,
          DateRangeFilterChip(
            key: const Key('purchase_orders_date_filter'),
            from: filter.from,
            to: filter.to,
            isToday: false,
            onChanged: (range) => goTo(
              query
                  .withFacet('from', encodePaymentsDateFacet(range.start))
                  .withFacet('to', encodePaymentsDateFacet(range.end)),
            ),
            onClear: () =>
                goTo(query.withFacet('from', null).withFacet('to', null)),
          ),
        ),
      ],
    );
  }
}
