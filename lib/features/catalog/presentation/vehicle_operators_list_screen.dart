import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle_operator.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_operators_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _vehicleOperatorsPath = '/vehicle-operators';

/// Vehicle Operators catalog list screen (FR-001, FR-002, FR-010, FR-018,
/// US2, US3). Gated by `can(SystemObject.vehicleOperators, AccessRight.read)`
/// in the router. Ships a driver + status filter drawer since the list
/// endpoint exposes both facets, per constitution §VI.
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class VehicleOperatorsListScreen extends ConsumerWidget {
  const VehicleOperatorsListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = VehicleOperatorFilter.fromQuery(query);
    final pageAsync = ref.watch(
      vehicleOperatorsListControllerProvider(filter),
    );
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(
      SystemObject.vehicleOperators,
      AccessRight.create,
    );
    final canUpdate = access.can(
      SystemObject.vehicleOperators,
      AccessRight.update,
    );
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('vehicle_operators_search_field'),
              label: l10n.vehicleOperatorsSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: (value) => context.go(
                query
                    .copyWith(search: value, pageIndex: 0)
                    .toUri(_vehicleOperatorsPath)
                    .toString(),
              ),
            ),
            actions: [
              if (canCreate)
                FilledButton.icon(
                  key: const Key('new_vehicle_operator_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.newVehicleOperatorTooltip),
                  onPressed: () => context.push('/vehicle-operators/new'),
                ),
            ],
            filters: [
              Badge.count(
                count: filter.activeFilterCount,
                isLabelVisible: filter.hasActiveFilters,
                child: IconButton.outlined(
                  key: const Key('vehicle_operators_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filtersTooltip,
                  onPressed: () => showCatalogFilterSheet(
                    context,
                    title: l10n.filtersButton,
                    clearAllLabel: l10n.clearAllFilters,
                    applyLabel: l10n.applyFilters,
                    onClearAll: () => context.go(_vehicleOperatorsPath),
                    builder: (_) => CurrentListQueryBuilder(
                      builder: (context, query) =>
                          _VehicleOperatorFiltersPanel(query: query),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CatalogListStateView<VehicleOperator>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noVehicleOperatorsFound,
            createLabel: canCreate ? l10n.newVehicleOperatorTooltip : null,
            onCreate: canCreate
                ? () => context.push('/vehicle-operators/new')
                : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_vehicleOperatorsPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(vehicleOperatorsListControllerProvider(filter)),
            onData: (page) => DataTableView<VehicleOperator>(
              key: const Key('vehicle_operators_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.driverLabel,
                  text: (op) => op.driverName,
                  size: ColumnSize.L,
                ),
                DataTableColumn.text(
                  label: l10n.licenseTypeLabel,
                  text: (op) => op.licenseType,
                  size: ColumnSize.M,
                ),
                DataTableColumn.text(
                  label: l10n.driverLicenseNumberLabel,
                  text: (op) => op.driverLicenseNumber,
                  size: ColumnSize.M,
                ),
                DataTableColumn(
                  label: l10n.daysUntilExpiryColumn,
                  size: ColumnSize.M,
                  cellBuilder: (context, op) =>
                      Text(_expiryLabel(l10n, op.effectiveDaysUntilExpiry)),
                ),
                DataTableColumn(
                  label: l10n.columnStatus,
                  fixedWidth: 130,
                  cellBuilder: (context, op) =>
                      EntityStatusCell(status: op.status),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_vehicleOperatorsPath)
                    .toString(),
              ),
              onRowTap: (op) => context.push(
                '/vehicle-operators/${op.vehicleOperatorId}?view=true',
              ),
              rowActionsBuilder: (context, op) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => context.push(
                        '/vehicle-operators/${op.vehicleOperatorId}',
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A human-readable "days until expiry" label (FR-019, SC-003).
String _expiryLabel(AppLocalizations l10n, int days) {
  if (days > 0) return l10n.expiresInDays(days);
  if (days == 0) return l10n.expiresToday;
  return l10n.expiredDaysAgo(-days);
}

/// The Vehicle Operators catalog's driver and status facets, rendered
/// inside the filter panel opened from the Filters button (FR-010,
/// FR-018). A [ConsumerWidget] so the controls stay reactive as the URL
/// changes while the sheet — which lives on its own navigator route — is
/// open. Each change navigates immediately via `context.go`; the panel
/// itself holds no state.
class _VehicleOperatorFiltersPanel extends ConsumerWidget {
  const _VehicleOperatorFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = VehicleOperatorFilter.fromQuery(query);
    final employeeRepo = ref.read(employeeRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final driverDisplayText = filter.driverId != null
        ? ref.watch(employeeDisplayNameProvider(filter.driverId!)).valueOrNull ??
              '${filter.driverId}'
        : '';

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
          filterKey: 'vehicle_operators_filter_status',
          value: filter.status,
          onChanged: (status) => context.go(
            query
                .withFacet('status', status?.name)
                .copyWith(pageIndex: 0)
                .toUri(_vehicleOperatorsPath)
                .toString(),
          ),
        ),
        const SizedBox(height: 12),
        CatalogEntityPicker<EmployeeListItem>(
          key: const Key('vehicle_operators_filter_driver'),
          label: l10n.vehicleOperatorsDriverFilter,
          displayStringForOption: (e) => e.fullName,
          optionsBuilder: (search) async {
            final result = await employeeRepo.list(
              search: search.isEmpty ? null : search,
            );
            return result.items;
          },
          onSelected: (e) => context.go(
            query
                .withFacet('driver', '${e.employeeId}')
                .copyWith(pageIndex: 0)
                .toUri(_vehicleOperatorsPath)
                .toString(),
          ),
          initialDisplayText: driverDisplayText,
        ),
      ],
    );
  }
}
