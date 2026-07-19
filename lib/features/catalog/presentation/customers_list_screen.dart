import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/customers_list_controller.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Customers catalog list screen (FR-001, FR-002, FR-022, US4). Gated by
/// `can(SystemObject.customers, AccessRight.read)` in the router. Ships a
/// filter drawer (active tri-state + price-list/salesperson FK pickers)
/// since the list endpoint exposes those facets, per constitution §VI.
class CustomersListScreen extends ConsumerWidget {
  const CustomersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(customersListControllerProvider);
    final filter = ref.watch(customerFilterControllerProvider);
    final filterController = ref.read(
      customerFilterControllerProvider.notifier,
    );
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.customers, AccessRight.create);
    final canUpdate = access.can(SystemObject.customers, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('customers_search_field'),
              label: l10n.customersSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: filterController.searchChanged,
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
                    onClearAll: filterController.reset,
                    builder: (_) => const _CustomerFiltersPanel(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: pageAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.customersLoadError(e))),
            data: (CatalogPage<CustomerListItem> page) => page.items.isEmpty
                ? Center(child: Text(l10n.noCustomersFound))
                : DataTableView<CustomerListItem>(
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
                        text: (c) =>
                            c.salesperson?.name ?? l10n.noneAssignedLabel,
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
                        cellBuilder: (context, c) => Text(
                          c.disabled
                              ? l10n.statusInactiveBadge
                              : l10n.statusActive,
                        ),
                      ),
                    ],
                    rows: page.items,
                    pagination: page,
                    onPageChanged: (pageIndex) => ref
                        .read(customersListControllerProvider.notifier)
                        .goToPage(pageIndex),
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
/// salesperson FK pickers), rendered inside the filter panel (FR-022).
class _CustomerFiltersPanel extends ConsumerWidget {
  const _CustomerFiltersPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(customerFilterControllerProvider);
    final filterController = ref.read(
      customerFilterControllerProvider.notifier,
    );
    final l10n = AppLocalizations.of(context)!;
    final priceListRepo = ref.read(priceListRepositoryProvider);
    final employeeRepo = ref.read(employeeRepositoryProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // `filter.disabled` is the wire field; this chip shows the positive
        // "Active" framing (spec 012 Assumptions, `/speckit-analyze` finding
        // I3) — cycling null -> active(disabled=false) -> inactive
        // (disabled=true) -> null.
        _TriStateFilterChip(
          chipKey: const Key('customers_filter_active'),
          label: l10n.customersActiveFilter,
          value: filter.disabled == null ? null : !filter.disabled!,
          onChanged: (activeValue) => filterController.disabledChanged(
            activeValue == null ? null : !activeValue,
          ),
        ),
        const SizedBox(height: 12),
        CatalogEntityPicker<PriceList>(
          key: const Key('customers_filter_price_list'),
          label: l10n.customersPriceListFilterLabel,
          displayStringForOption: (p) => p.name,
          optionsBuilder: (query) async {
            final result = await priceListRepo.list(
              search: query.isEmpty ? null : query,
            );
            return result.items;
          },
          onSelected: (p) =>
              filterController.priceListChanged(p.priceListId, p.name),
          initialDisplayText: filter.priceListDisplayText ?? '',
        ),
        const SizedBox(height: 12),
        CatalogEntityPicker<EmployeeListItem>(
          key: const Key('customers_filter_salesperson'),
          label: l10n.customersSalespersonFilterLabel,
          displayStringForOption: (e) => e.fullName,
          optionsBuilder: (query) async {
            final result = await employeeRepo.list(
              search: query.isEmpty ? null : query,
            );
            return result.items;
          },
          onSelected: (e) =>
              filterController.salespersonChanged(e.employeeId, e.fullName),
          initialDisplayText: filter.salespersonDisplayText ?? '',
        ),
      ],
    );
  }
}

/// A [FilterChip] that cycles through `null` → `true` → `false` → `null` on
/// tap, mirroring `products_list_screen.dart`'s `_TriStateFilterChip`.
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
