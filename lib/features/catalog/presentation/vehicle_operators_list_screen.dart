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
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle_operator.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_operators_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Vehicle Operators catalog list screen (FR-001, FR-002, FR-018, US3).
/// Gated by `can(SystemObject.vehicleOperators, AccessRight.read)` in the
/// router. Ships a driver filter drawer since the list endpoint exposes an
/// `employee` facet, per constitution §VI.
class VehicleOperatorsListScreen extends ConsumerWidget {
  const VehicleOperatorsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(vehicleOperatorsListControllerProvider);
    final filter = ref.watch(vehicleOperatorFilterControllerProvider);
    final filterController = ref.read(
      vehicleOperatorFilterControllerProvider.notifier,
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
              onSubmitted: filterController.searchChanged,
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
                    onClearAll: filterController.reset,
                    builder: (_) => const _VehicleOperatorFiltersPanel(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: pageAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text(l10n.vehicleOperatorsLoadError(e))),
            data: (CatalogPage<VehicleOperator> page) => page.items.isEmpty
                ? Center(child: Text(l10n.noVehicleOperatorsFound))
                : DataTableView<VehicleOperator>(
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
                        cellBuilder: (context, op) => Text(
                          _expiryLabel(l10n, op.effectiveDaysUntilExpiry),
                        ),
                      ),
                      DataTableColumn(
                        label: l10n.activeLabel,
                        fixedWidth: 130,
                        cellBuilder: (context, op) => op.active
                            ? Text(l10n.statusActive)
                            : Chip(
                                key: const Key('inactive_badge'),
                                label: Text(l10n.statusInactiveBadge),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                                labelStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                      ),
                    ],
                    rows: page.items,
                    pagination: page,
                    onPageChanged: (pageIndex) => ref
                        .read(vehicleOperatorsListControllerProvider.notifier)
                        .goToPage(pageIndex),
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

/// The Vehicle Operators catalog's driver facet, rendered inside the filter
/// panel opened from the Filters button (FR-018).
class _VehicleOperatorFiltersPanel extends ConsumerWidget {
  const _VehicleOperatorFiltersPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(vehicleOperatorFilterControllerProvider);
    final filterController = ref.read(
      vehicleOperatorFilterControllerProvider.notifier,
    );
    final employeeRepo = ref.read(employeeRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

    return CatalogEntityPicker<EmployeeListItem>(
      key: const Key('vehicle_operators_filter_driver'),
      label: l10n.vehicleOperatorsDriverFilter,
      displayStringForOption: (e) => e.fullName,
      optionsBuilder: (query) async {
        final result = await employeeRepo.list(
          search: query.isEmpty ? null : query,
        );
        return result.items;
      },
      onSelected: (e) =>
          filterController.driverSelected(e.employeeId, e.fullName),
      initialDisplayText: filter.driverDisplayText,
    );
  }
}
