import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/date_range_filter_chip.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_no_register_notice.dart';
import 'package:mbe_ui/features/sales/presentation/orders/sales_orders_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/pos_sale_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _ordersPath = '/sales/orders';

/// `/sales/orders` — the back-office Sales Orders list (spec 029
/// contracts/sales-orders-screen.md §1). Scoped by *who the order belongs
/// to* and *which facility*, never by register: an ordinary user sees only
/// their own orders (FR-006); an administrator sees everyone's, with
/// salesperson and facility facets to narrow (FR-011 — added in a later
/// increment, US5).
///
/// [query] is decoded from the route by the router builder, exactly like
/// every other catalog list screen.
class SalesOrdersListScreen extends ConsumerWidget {
  const SalesOrdersListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final access = ref.watch(accessControlProvider);
    final isAdministrator = access.isAdministrator;
    final facilityId = ref.watch(userFacilityIdProvider);

    // Distinct from "no orders in range": no request is issued at all when
    // the signed-in user has no facility configured (spec Edge Cases) — an
    // administrator is not exempt, since FR-011's facility facet still
    // defaults to "the caller's own".
    if (facilityId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                key: const Key('sales_orders_no_facility'),
                l10n.salesOrderNoFacilityTitle,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(l10n.salesOrderNoFacilityMessage, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    final today = DateTime.now();
    final filter = SalesOrdersFilter.fromQuery(
      query,
      today: today,
      isAdministrator: isAdministrator,
    );
    final pageAsync = ref.watch(
      salesOrdersListControllerProvider(filter, isAdministrator),
    );
    final canCreate = access.can(SystemObject.salesOrders, AccessRight.create);
    final hasRegister = ref.watch(registerPointSaleProvider) != null;
    final fmt = ref.watch(formattersProvider);

    void goTo(ListQuery updated) => context.go(updated.toUri(_ordersPath).toString());

    Future<void> openOrder(int orderId) async {
      await context.push('$_ordersPath/$orderId');
      if (!context.mounted) return;
      ref.invalidate(salesOrdersListControllerProvider(filter, isAdministrator));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('sales_orders_search_field'),
              label: l10n.salesOrdersSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: (value) =>
                  goTo(query.copyWith(search: value, pageIndex: 0)),
            ),
            actions: [
              // FR-003: absent without create rights, no notice either — a
              // read-only user gets nothing to explain. FR-014: with create
              // rights but no register, the button is replaced by the
              // notice naming the missing setting, told before the user
              // types anything.
              if (canCreate && hasRegister) ...[
                // US5 scenario 4: an administrator viewing another
                // facility's orders still creates in their own — said
                // before they begin, not after a surprising result.
                if (isAdministrator && filter.facility != null && filter.facility != facilityId)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Tooltip(
                      message: l10n.salesOrderCrossFacilityNotice,
                      child: Icon(
                        Icons.info_outline,
                        key: const Key('sales_orders_cross_facility_notice'),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                FilledButton.icon(
                  key: const Key('sales_orders_new_order_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.salesOrderNewAction),
                  onPressed: () => context.push('$_ordersPath/new'),
                ),
              ] else if (canCreate)
                const OrderNoRegisterNotice(),
            ],
            filters: [
              Badge.count(
                count: filter.activeFilterCount(today),
                isLabelVisible: filter.hasActiveFilters(today),
                child: IconButton.outlined(
                  key: const Key('sales_orders_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filtersTooltip,
                  onPressed: () => showCatalogFilterSheet(
                    context,
                    title: l10n.filtersButton,
                    clearAllLabel: l10n.clearAllFilters,
                    applyLabel: l10n.applyFilters,
                    onClearAll: () => goTo(
                      query
                          .withFacet('date-from', null)
                          .withFacet('date-to', null)
                          .withFacet('status', null)
                          .withFacet('salesperson', null)
                          .withFacet('facility', null)
                          .copyWith(pageIndex: 0),
                    ),
                    builder: (_) => CurrentListQueryBuilder(
                      builder: (context, currentQuery) => _SalesOrdersFiltersPanel(
                        query: currentQuery,
                        today: today,
                        isAdministrator: isAdministrator,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CatalogListStateView<OpenSale>(
            state: pageAsync,
            isFiltered: filter.hasActiveFilters(today) || filter.search.isNotEmpty,
            emptyMessage: l10n.salesOrdersEmptyMessage,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_ordersPath),
            retryLabel: l10n.retryButton,
            onRetry: () => ref.invalidate(
              salesOrdersListControllerProvider(filter, isAdministrator),
            ),
            onData: (page) => DataTableView<OpenSale>(
              key: const Key('sales_orders_list_table'),
              columns: [
                DataTableColumn(
                  label: l10n.salesOrdersColumnReference,
                  size: ColumnSize.S,
                  cellBuilder: (context, sale) => Text('${sale.serial ?? sale.id}'),
                ),
                DataTableColumn(
                  label: l10n.salesOrdersColumnDate,
                  size: ColumnSize.M,
                  cellBuilder: (context, sale) => Text(fmt.display.dateTime(sale.date)),
                ),
                DataTableColumn.text(
                  label: l10n.salesOrdersColumnCustomer,
                  text: posSaleCustomerLabel,
                  size: ColumnSize.L,
                ),
                DataTableColumn(
                  label: l10n.salesOrdersColumnStatus,
                  size: ColumnSize.S,
                  cellBuilder: (context, sale) => PosSaleStatusChip(status: sale.status),
                ),
                DataTableColumn(
                  label: l10n.salesOrdersColumnTotal,
                  numeric: true,
                  size: ColumnSize.S,
                  cellBuilder: (context, sale) => Text(fmt.display.currency(sale.total)),
                ),
                DataTableColumn(
                  label: l10n.salesOrdersColumnBalance,
                  numeric: true,
                  size: ColumnSize.S,
                  cellBuilder: (context, sale) => Text(fmt.display.currency(sale.balance)),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context
                  .go(query.copyWith(pageIndex: pageIndex).toUri(_ordersPath).toString()),
              rowActionsBuilder: (context, sale) {
                final canUpdate = access.can(SystemObject.salesOrders, AccessRight.update);
                final editable = sale.status == SaleStatus.draft;
                return buildCatalogRowActions(
                  editTooltip: l10n.editActionTooltip,
                  onEdit: canUpdate && editable ? () => openOrder(sale.id) : null,
                );
              },
              onRowTap: (sale) => openOrder(sale.id),
            ),
          ),
        ),
      ],
    );
  }
}

/// The list's facets (spec 029 FR-008, FR-011): date range and status for
/// everyone; salesperson and facility, administrator-only, join in US5.
/// Both admin facets are `CatalogEntityPicker`s seeded from
/// `employeeDisplayNameProvider`/`facilityDisplayNameProvider`, so a facet
/// arriving in the URL as a bare id still shows a name
/// (`cash_sessions_screen.dart:475-535` is the precedent this copies).
class _SalesOrdersFiltersPanel extends ConsumerWidget {
  const _SalesOrdersFiltersPanel({
    required this.query,
    required this.today,
    required this.isAdministrator,
  });

  final ListQuery query;
  final DateTime today;
  final bool isAdministrator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = SalesOrdersFilter.fromQuery(
      query,
      today: today,
      isAdministrator: isAdministrator,
    );
    final l10n = AppLocalizations.of(context)!;

    void goTo(ListQuery updated) => context.go(updated.toUri(_ordersPath).toString());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dateRangeFilterLabel, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        DateRangeFilterChip(
          from: filter.from,
          to: filter.to,
          isToday: filter.isDefaultRange(today),
          onChanged: (range) => goTo(
            query
                .withFacet('date-from', encodeSalesOrdersDateFacet(range.start))
                .withFacet('date-to', encodeSalesOrdersDateFacet(range.end))
                .copyWith(pageIndex: 0),
          ),
          onClear: () => goTo(
            query
                .withFacet('date-from', null)
                .withFacet('date-to', null)
                .copyWith(pageIndex: 0),
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.posSalesStatusFilterLabel, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              key: const Key('sales_orders_filter_status_all'),
              label: Text(l10n.posSalesStatusFilterAll),
              selected: filter.status == null,
              onSelected: (_) =>
                  goTo(query.withFacet('status', null).copyWith(pageIndex: 0)),
            ),
            for (final status in SaleStatus.values)
              ChoiceChip(
                key: Key('sales_orders_filter_status_${status.name}'),
                label: Text(posSaleStatusLabel(l10n, status)),
                selected: filter.status == status,
                onSelected: (_) =>
                    goTo(query.withFacet('status', status.name).copyWith(pageIndex: 0)),
              ),
          ],
        ),
        if (isAdministrator) ...[
          const SizedBox(height: 12),
          CatalogEntityPicker<EmployeeListItem>(
            key: const Key('sales_orders_filter_salesperson'),
            label: l10n.salesOrderSalespersonLabel,
            displayStringForOption: (e) => e.fullName,
            optionsBuilder: (search) async {
              final result = await ref
                  .read(employeeRepositoryProvider)
                  .list(search: search.isEmpty ? null : search, salesPerson: true);
              return result.items;
            },
            onSelected: (e) => goTo(
              query.withFacet('salesperson', '${e.employeeId}').copyWith(pageIndex: 0),
            ),
            // Scenario 2: unset shows "everyone", not a blank field.
            initialDisplayText: filter.salesperson != null
                ? ref.watch(employeeDisplayNameProvider(filter.salesperson!)).valueOrNull ??
                      '${filter.salesperson}'
                : l10n.salesOrderSalespersonEveryone,
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              // Scenario 2: unset resolves to the caller's own facility —
              // the one `SalesOrdersListController` requests when this
              // facet is absent — rather than a blank field.
              final effectiveFacilityId = filter.facility ?? ref.watch(userFacilityIdProvider);
              final resolvedName = effectiveFacilityId != null
                  ? ref.watch(facilityDisplayNameProvider(effectiveFacilityId)).valueOrNull
                  : null;
              return CatalogEntityPicker<FacilityListItem>(
                key: const Key('sales_orders_filter_facility'),
                label: l10n.facilityFieldLabel,
                displayStringForOption: (f) => f.name,
                optionsBuilder: (search) async {
                  final result = await ref
                      .read(facilityRepositoryProvider)
                      .list(search: search.isEmpty ? null : search);
                  return result.items;
                },
                onSelected: (f) => goTo(
                  query.withFacet('facility', '${f.facilityId}').copyWith(pageIndex: 0),
                ),
                initialDisplayText: resolvedName ?? effectiveFacilityId?.toString(),
              );
            },
          ),
        ],
      ],
    );
  }
}
