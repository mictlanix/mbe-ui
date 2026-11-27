import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
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
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_warehouse_options.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/new_request_dialog.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_status_chip.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_requests_filter.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_requests_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const purchaseRequestsPath = '/purchases/requests';

/// Solicitudes de compra: the requests the server returns for the user,
/// newest first (spec 079 US1, contracts/ui-contract.md "Solicitudes de
/// compra list"). Gated by PurchaseRequest (SystemObject 86) read.
///
/// A request is a document, so a row has no icons and its tap opens the
/// detail screen (§VI document reading).
class PurchaseRequestsListScreen extends ConsumerWidget {
  const PurchaseRequestsListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final access = ref.watch(accessControlProvider);
    // PurchaseRequest (86) create, and Warehouses (4) read for the dialog's
    // warehouse picker (FR-006, FR-025).
    final canCreate =
        access.can(SystemObject.purchaseRequest, AccessRight.create) &&
        access.can(SystemObject.warehouses, AccessRight.read);
    final filter = PurchaseRequestsFilter.fromQuery(query);
    final pageAsync = ref.watch(purchaseRequestsListControllerProvider(filter));
    final fmt = ref.watch(formattersProvider);
    final compact = LayoutBreakpoints.isCompact(context);
    final clearedPath = const ListQuery()
        .toUri(purchaseRequestsPath)
        .toString();
    // "Limpiar todo" in the drawer empties the facets and keeps the folio.
    final facetsClearedPath = filter
        .cleared()
        .copyWith(serial: filter.serial)
        .toQuery()
        .toUri(purchaseRequestsPath)
        .toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        // §VI: the row holds only the folio search, the filters button and
        // "Nueva solicitud"; the Mostrar scope is a facet in the drawer
        // (research R9, analysis finding C2).
        CatalogFilterBar(
          search: CatalogSearchBar(
            key: const Key('purchase_requests_search'),
            label: l10n.purchaseRequestSearchHint,
            searchTooltip: l10n.searchButtonTooltip,
            initialValue: filter.serial?.toString() ?? '',
            // The server matches the folio (`serial`) as a number.
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (value) => submitCatalogSearch(
              context: context,
              query: query,
              path: purchaseRequestsPath,
              submitted: value.trim(),
              current: filter.serial?.toString() ?? '',
              refresh: () => ref.invalidate(
                purchaseRequestsListControllerProvider(filter),
              ),
            ),
          ),
          filters: [
            Badge.count(
              count: filter.activeFilterCount,
              isLabelVisible: filter.activeFilterCount > 0,
              child: IconButton.outlined(
                key: const Key('purchase_requests_filter_button'),
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
                        _PurchaseRequestsFiltersPanel(query: query),
                  ),
                ),
              ),
            ),
          ],
          actions: [
            if (canCreate)
              FilledButton.icon(
                key: const Key('purchase_requests_new_button'),
                onPressed: () => showNewRequestDialog(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.purchaseRequestNewAction),
              ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<PurchaseRequestSummary>(
            state: pageAsync,
            // The scope alone isn't a narrowing: "Todas" with nothing else
            // set has its own empty text.
            isFiltered: filter.copyWith(all: false).isNarrowed,
            emptyMessage: filter.all
                ? l10n.purchaseRequestEmptyAll
                : l10n.purchaseRequestEmptyMine,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(clearedPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(purchaseRequestsListControllerProvider(filter)),
            onData: (page) => DataTableView<PurchaseRequestSummary>(
              key: const Key('purchase_requests_table'),
              columns: [
                DataTableColumn(
                  label: l10n.purchaseRequestColFolio,
                  size: ColumnSize.S,
                  numeric: true,
                  cellBuilder: (context, r) => RecordIdText(
                    r.serial == null
                        ? l10n.purchaseRequestDraftFolio('${r.id}')
                        : '${r.serial}',
                    key: Key('purchase_request_folio_${r.id}'),
                    textAlign: TextAlign.end,
                  ),
                ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.purchaseRequestColFacility,
                    size: ColumnSize.M,
                    cellBuilder: (context, r) {
                      final facilityId = r.facilityId;
                      return facilityId == null
                          ? const SizedBox.shrink()
                          : InventoryFacilityName(facilityId: facilityId);
                    },
                  ),
                DataTableColumn(
                  label: l10n.purchaseRequestColWarehouse,
                  size: ColumnSize.M,
                  cellBuilder: (context, r) =>
                      InventoryWarehouseName(warehouseId: r.warehouseId),
                ),
                DataTableColumn(
                  label: l10n.purchaseRequestColStatus,
                  size: ColumnSize.S,
                  cellBuilder: (context, r) =>
                      PurchaseRequestStatusChip(status: r.status),
                ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.purchaseRequestColCreator,
                    size: ColumnSize.M,
                    cellBuilder: (context, r) =>
                        InventoryEmployeeName(employeeId: r.creatorId),
                  ),
                DataTableColumn.timestamp(
                  label: l10n.purchaseRequestColDate,
                  size: ColumnSize.S,
                  text: (r) => fmt.display.dateTime(r.date),
                ),
                DataTableColumn(
                  label: l10n.purchaseRequestColLines,
                  size: ColumnSize.S,
                  numeric: true,
                  cellBuilder: (context, r) => Text(
                    fmt.display.count(r.lineCount),
                    key: Key('purchase_request_lines_${r.id}'),
                  ),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(purchaseRequestsPath)
                    .toString(),
              ),
              onRowTap: (r) => context.push('$purchaseRequestsPath/${r.id}'),
            ),
          ),
        ),
      ],
    );
  }
}

/// The drawer's facets (research R9, wireframes "State: filter drawer
/// open"): Mostrar and Estado, then Sucursal, Almacén and Solicitó, each with
/// read on its catalog, and the date range. Each change writes the URL and
/// returns to the first page.
class _PurchaseRequestsFiltersPanel extends ConsumerWidget {
  const _PurchaseRequestsFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(accessControlProvider);
    // Facilities (29), Warehouses (4) and Employees (6) read: each picker
    // lists its catalog (FR-025).
    final canReadFacilities = access.can(
      SystemObject.facilities,
      AccessRight.read,
    );
    final canReadWarehouses = access.can(
      SystemObject.warehouses,
      AccessRight.read,
    );
    final canReadEmployees = access.can(
      SystemObject.employees,
      AccessRight.read,
    );
    final filter = PurchaseRequestsFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final facilityId = filter.facilityId;
    final warehouseId = filter.warehouseId;
    final creatorId = filter.creatorId;
    final facilityName = facilityId == null || !canReadFacilities
        ? null
        : ref.watch(facilityDisplayNameProvider(facilityId)).value;
    final warehouseName = warehouseId == null || !canReadWarehouses
        ? null
        : ref.watch(warehouseDisplayNameProvider(warehouseId)).value;
    final creatorName = creatorId == null || !canReadEmployees
        ? null
        : ref.watch(employeeDisplayNameProvider(creatorId)).value;

    void goTo(ListQuery updated) => context.go(
      updated.copyWith(pageIndex: 0).toUri(purchaseRequestsPath).toString(),
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
          l10n.purchaseRequestFacetScope,
          Wrap(
            key: const Key('purchase_requests_scope_filter'),
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              ChoiceChip(
                key: const Key('purchase_requests_scope_mine'),
                label: Text(l10n.purchaseRequestScopeMine),
                selected: !filter.all,
                onSelected: (_) => goTo(query.withFacet('all', null)),
              ),
              ChoiceChip(
                key: const Key('purchase_requests_scope_all'),
                label: Text(l10n.purchaseRequestScopeAll),
                selected: filter.all,
                onSelected: (_) => goTo(query.withFacet('all', 'true')),
              ),
            ],
          ),
        ),
        facet(
          l10n.purchaseRequestFacetStatus,
          Wrap(
            key: const Key('purchase_requests_status_filter'),
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              for (final status in PurchaseRequestStatus.values)
                ChoiceChip(
                  key: Key('purchase_requests_status_${status.name}'),
                  label: Text(purchaseRequestStatusLabel(l10n, status)),
                  selected: filter.status == status,
                  // Tapping the selected chip again clears the facet.
                  onSelected: (selected) => goTo(
                    query.withFacet('status', selected ? status.name : null),
                  ),
                ),
            ],
          ),
        ),
        if (canReadFacilities)
          CatalogEntityPicker<FacilityListItem>(
            key: const Key('purchase_requests_facility_filter'),
            label: l10n.purchaseRequestFacetFacility,
            displayStringForOption: (f) => f.name,
            optionsBuilder: (search) async {
              final result = await ref
                  .read(facilityRepositoryProvider)
                  .list(search: search.isEmpty ? null : search);
              return result.items;
            },
            onSelected: (f) =>
                goTo(query.withFacet('facility', '${f.facilityId}')),
            initialDisplayText:
                facilityName ?? (facilityId == null ? null : '#$facilityId'),
          ),
        if (canReadWarehouses)
          // Unscoped: any warehouse the user can read (research R9).
          CatalogEntityPicker<Warehouse>(
            key: const Key('purchase_requests_warehouse_filter'),
            label: l10n.purchaseRequestFacetWarehouse,
            displayStringForOption: (w) => w.name,
            optionSubtitle: (w) => w.facilityName,
            optionsBuilder: (search) => inventoryFilterWarehouseOptions(
              ref.read(warehouseRepositoryProvider),
              search,
            ),
            onSelected: (w) =>
                goTo(query.withFacet('warehouse', '${w.warehouseId}')),
            initialDisplayText:
                warehouseName ?? (warehouseId == null ? null : '#$warehouseId'),
          ),
        if (canReadEmployees)
          CatalogEntityPicker<EmployeeListItem>(
            key: const Key('purchase_requests_creator_filter'),
            label: l10n.purchaseRequestFacetCreator,
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
          l10n.purchaseRequestFacetDate,
          DateRangeFilterChip(
            key: const Key('purchase_requests_date_filter'),
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
