import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/navigation/list_search_submit.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/customers_list_controller.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _customersPath = '/customers';

/// Customers catalog list screen (FR-001, FR-002, FR-022, US4). Gated by
/// `can(SystemObject.customers, AccessRight.read)` in the router. Ships a
/// filter drawer (active tri-state + price-list/salesperson FK pickers)
/// since the list endpoint exposes those facets, per constitution §VI.
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class CustomersListScreen extends ConsumerWidget {
  const CustomersListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = CustomerFilter.fromQuery(query);
    final pageAsync = ref.watch(customersListControllerProvider(filter));
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.customers, AccessRight.create);
    final canUpdate = access.can(SystemObject.customers, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        CatalogFilterBar(
          search: CatalogSearchBar(
            key: const Key('customers_search_field'),
            label: l10n.customersSearchLabel,
            searchTooltip: l10n.searchButtonTooltip,
            initialValue: filter.search,
            onSubmitted: (value) => submitCatalogSearch(
              context: context,
              query: query,
              path: _customersPath,
              submitted: value,
              current: filter.search,
              refresh: () =>
                  ref.invalidate(customersListControllerProvider(filter)),
            ),
          ),
          actions: [
            if (canCreate)
              FilledButton.icon(
                key: const Key('new_customer_button'),
                icon: Icon(CatalogAction.create.icon),
                label: Text(l10n.newCustomerTooltip),
                onPressed: () => context.push('/customers/new'),
              ),
          ],
          filters: [
            Badge.count(
              count: filter.activeFilterCount,
              isLabelVisible: filter.hasActiveFilters,
              child: IconButton.outlined(
                key: const Key('customers_filter_button'),
                icon: const Icon(Icons.tune),
                tooltip: l10n.filtersTooltip,
                onPressed: () => showCatalogFilterSheet(
                  context,
                  title: l10n.filtersButton,
                  clearAllLabel: l10n.clearAllFilters,
                  applyLabel: l10n.applyFilters,
                  onClearAll: () => context.go(_customersPath),
                  builder: (_) => CurrentListQueryBuilder(
                    builder: (context, query) =>
                        _CustomerFiltersPanel(query: query),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<CustomerListItem>(
            state: pageAsync,
            isFiltered: isFilteredBeyondStatusDefault(query, filter.status),
            emptyMessage: l10n.noCustomersFound,
            createLabel: canCreate ? l10n.newCustomerTooltip : null,
            onCreate: canCreate ? () => context.push('/customers/new') : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_customersPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(customersListControllerProvider(filter)),
            onData: (page) => DataTableView<CustomerListItem>(
              key: const Key('customers_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.columnCode,
                  text: (c) => c.code,
                  size: ColumnSize.S,
                ),
                DataTableColumn.text(
                  label: l10n.columnName,
                  text: (c) => c.name,
                  size: ColumnSize.L,
                ),
                DataTableColumn.text(
                  label: l10n.columnSalesperson,
                  text: (c) => c.salesperson?.name ?? l10n.noneAssignedLabel,
                  size: ColumnSize.M,
                ),
                DataTableColumn.text(
                  label: l10n.columnPriceList,
                  text: (c) => c.priceList.name,
                  size: ColumnSize.M,
                ),
                DataTableColumn(
                  label: l10n.columnStatus,
                  fixedWidth: 130,
                  cellBuilder: (context, c) =>
                      EntityStatusCell(status: c.status),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_customersPath)
                    .toString(),
              ),
              onRowTap: (c) =>
                  context.push('/customers/${c.customerId}?view=true'),
              rowActionsBuilder: (context, c) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => context.push('/customers/${c.customerId}')
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The Customers catalog's facet filters (active tri-state, price-list and
/// salesperson FK pickers), rendered inside the filter panel (FR-022). A
/// [ConsumerWidget] so the controls stay reactive as the URL changes while
/// the sheet — which lives on its own navigator route — is open. Each
/// change navigates immediately via `context.go`; the panel itself holds no
/// state.
class _CustomerFiltersPanel extends ConsumerWidget {
  const _CustomerFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = CustomerFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final priceListRepo = ref.read(priceListRepositoryProvider);
    final employeeRepo = ref.read(employeeRepositoryProvider);
    final priceListDisplayText = filter.priceListId != null
        ? ref
                  .watch(priceListDisplayNameProvider(filter.priceListId!))
                  .valueOrNull ??
              '${filter.priceListId}'
        : '';
    final salespersonDisplayText = filter.salespersonId != null
        ? ref
                  .watch(employeeDisplayNameProvider(filter.salespersonId!))
                  .valueOrNull ??
              '${filter.salespersonId}'
        : '';

    void goTo(ListQuery updated) =>
        context.go(updated.toUri(_customersPath).toString());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The old polarity juggling (spec 012 `/speckit-analyze` finding I3)
        // is gone: mbe-api#81 replaced `disabled` with the same `status`
        // enum every catalog now filters on.
        Text(
          l10n.statusFilterLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        EntityStatusFilterChips(
          filterKey: 'customers_filter_status',
          value: filter.status,
          onChanged: (status) =>
              goTo(encodeStatusFacet(query, status).copyWith(pageIndex: 0)),
        ),
        const SizedBox(height: 12),
        CatalogEntityPicker<PriceList>(
          key: const Key('customers_filter_price_list'),
          label: l10n.customersPriceListFilterLabel,
          displayStringForOption: (p) => p.name,
          optionsBuilder: (search) async {
            final result = await priceListRepo.list(
              search: search.isEmpty ? null : search,
            );
            return result.items;
          },
          onSelected: (p) => goTo(
            query
                .withFacet('priceList', '${p.priceListId}')
                .copyWith(pageIndex: 0),
          ),
          initialDisplayText: priceListDisplayText,
        ),
        const SizedBox(height: 12),
        CatalogEntityPicker<EmployeeListItem>(
          key: const Key('customers_filter_salesperson'),
          label: l10n.customersSalespersonFilterLabel,
          displayStringForOption: (e) => e.fullName,
          optionsBuilder: (search) async {
            final result = await employeeRepo.list(
              search: search.isEmpty ? null : search,
            );
            return result.items;
          },
          onSelected: (e) => goTo(
            query
                .withFacet('salesperson', '${e.employeeId}')
                .copyWith(pageIndex: 0),
          ),
          initialDisplayText: salespersonDisplayText,
        ),
      ],
    );
  }
}
