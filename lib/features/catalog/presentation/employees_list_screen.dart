import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/employees_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _employeesPath = '/employees';

/// Employees catalog list screen (FR-001, FR-002, FR-017, US3). Gated by
/// `can(SystemObject.employees, AccessRight.read)` in the router. Ships a
/// filter drawer (status + salesPerson tri-state) since the list endpoint
/// exposes those facets, per constitution §VI.
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class EmployeesListScreen extends ConsumerWidget {
  const EmployeesListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = EmployeeFilter.fromQuery(query);
    final pageAsync = ref.watch(employeesListControllerProvider(filter));
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.employees, AccessRight.create);
    final canUpdate = access.can(SystemObject.employees, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('employees_search_field'),
              label: l10n.employeesSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: (value) => context.go(
                query
                    .copyWith(search: value, pageIndex: 0)
                    .toUri(_employeesPath)
                    .toString(),
              ),
            ),
            actions: [
              if (canCreate)
                FilledButton.icon(
                  key: const Key('new_employee_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.newEmployeeTooltip),
                  onPressed: () => context.push('/employees/new'),
                ),
            ],
            filters: [
              Badge.count(
                count: filter.activeFilterCount,
                isLabelVisible: filter.hasActiveFilters,
                child: IconButton.outlined(
                  key: const Key('employees_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filtersTooltip,
                  onPressed: () => showCatalogFilterSheet(
                    context,
                    title: l10n.filtersButton,
                    clearAllLabel: l10n.clearAllFilters,
                    applyLabel: l10n.applyFilters,
                    onClearAll: () => context.go(_employeesPath),
                    builder: (_) => CurrentListQueryBuilder(
                      builder: (context, query) =>
                          _EmployeeFiltersPanel(query: query),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CatalogListStateView<EmployeeListItem>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noEmployeesFound,
            createLabel: canCreate ? l10n.newEmployeeTooltip : null,
            onCreate: canCreate ? () => context.push('/employees/new') : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_employeesPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(employeesListControllerProvider(filter)),
            onData: (page) => DataTableView<EmployeeListItem>(
              key: const Key('employees_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.columnFullName,
                  text: (e) => e.fullName,
                  size: ColumnSize.L,
                ),
                DataTableColumn.text(
                  label: l10n.nicknameLabel,
                  text: (e) => e.nickname,
                  size: ColumnSize.M,
                ),
                DataTableColumn(
                  label: l10n.salesPersonLabel,
                  size: ColumnSize.S,
                  cellBuilder: (_, e) => e.salesPerson
                      ? const Icon(Icons.check)
                      : const SizedBox.shrink(),
                ),
                DataTableColumn(
                  label: l10n.columnStatus,
                  size: ColumnSize.S,
                  cellBuilder: (context, e) =>
                      EntityStatusCell(status: e.status),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_employeesPath)
                    .toString(),
              ),
              onRowTap: (e) =>
                  context.push('/employees/${e.employeeId}?view=true'),
              rowActionsBuilder: (context, e) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => context.push('/employees/${e.employeeId}')
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The Employees catalog's facet filters (status, sales-person tri-state),
/// rendered inside the filter panel opened from the Filters button (FR-017).
/// A [ConsumerWidget] so the controls stay reactive as the URL changes while
/// the sheet — which lives on its own navigator route — is open. Each
/// change navigates immediately via `context.go`; the panel itself holds no
/// state.
class _EmployeeFiltersPanel extends ConsumerWidget {
  const _EmployeeFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = EmployeeFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;

    void goTo(ListQuery updated) =>
        context.go(updated.toUri(_employeesPath).toString());

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
          filterKey: 'employees_filter_status',
          value: filter.status,
          onChanged: (status) => goTo(
            query.withFacet('status', status?.name).copyWith(pageIndex: 0),
          ),
        ),
        const SizedBox(height: 12),
        _TriStateFilterChip(
          chipKey: const Key('employees_filter_sales_person'),
          label: l10n.employeesSalesPersonFilter,
          value: filter.salesPerson,
          onChanged: (value) => goTo(
            query
                .withFacet('salesPerson', value?.toString())
                .copyWith(pageIndex: 0),
          ),
        ),
      ],
    );
  }
}

/// A [FilterChip] that cycles through `null` (no filter) → `true` → `false`
/// → `null` on tap, mirroring `products_list_screen.dart`'s
/// `_TriStateFilterChip`.
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
