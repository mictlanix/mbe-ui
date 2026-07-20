import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicles_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Vehicles catalog list screen (FR-001, FR-002, US2). Gated by
/// `can(SystemObject.vehicle, AccessRight.read)` in the router. Search-only
/// (no filter drawer): the list endpoint exposes no facets beyond `search`
/// (plan.md Constitution Check note on §VI).
class VehiclesListScreen extends ConsumerWidget {
  const VehiclesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(vehiclesListControllerProvider);
    final search = ref.watch(vehicleSearchControllerProvider);
    final searchController = ref.read(vehicleSearchControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.vehicle, AccessRight.create);
    final canUpdate = access.can(SystemObject.vehicle, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('vehicles_search_field'),
              label: l10n.vehiclesSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: search,
              onSubmitted: searchController.searchChanged,
            ),
            actions: [
              if (canCreate)
                FilledButton.icon(
                  key: const Key('new_vehicle_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.newVehicleTooltip),
                  onPressed: () => context.push('/vehicles/new'),
                ),
            ],
          ),
        ),
        Expanded(
          child: pageAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.vehiclesLoadError(e))),
            data: (CatalogPage<Vehicle> page) => page.items.isEmpty
                ? Center(child: Text(l10n.noVehiclesFound))
                : DataTableView<Vehicle>(
                    key: const Key('vehicles_table'),
                    columns: [
                      DataTableColumn.text(
                        label: l10n.licensePlateLabel,
                        text: (v) => v.licensePlate,
                        size: ColumnSize.M,
                      ),
                      DataTableColumn.text(
                        label: l10n.nameLabel,
                        text: (v) => v.name,
                        size: ColumnSize.L,
                      ),
                      DataTableColumn.text(
                        label: l10n.nicknameLabel,
                        text: (v) => v.nickname,
                        size: ColumnSize.M,
                      ),
                      DataTableColumn(
                        label: l10n.columnStatus,
                        fixedWidth: 130,
                        cellBuilder: (context, v) =>
                            EntityStatusCell(status: v.status),
                      ),
                    ],
                    rows: page.items,
                    pagination: page,
                    onPageChanged: (pageIndex) => ref
                        .read(vehiclesListControllerProvider.notifier)
                        .goToPage(pageIndex),
                    onRowTap: (v) =>
                        context.push('/vehicles/${v.vehicleId}?view=true'),
                    rowActionsBuilder: (context, v) => buildCatalogRowActions(
                      editTooltip: l10n.editActionTooltip,
                      onEdit: canUpdate
                          ? () => context.push('/vehicles/${v.vehicleId}')
                          : null,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
