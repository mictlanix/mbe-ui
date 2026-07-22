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
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/cash_drawer.dart';
import 'package:mbe_ui/features/catalog/presentation/cash_drawers_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// CashDrawers catalog list screen (FR-001, FR-002, FR-003, US2). Gated by
/// `can(SystemObject.cashDrawers, AccessRight.read)` in the router. Ships a
/// filter drawer (facility picker + status) since the list endpoint exposes
/// both facets, per constitution §VI.
class CashDrawersListScreen extends ConsumerWidget {
  const CashDrawersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(cashDrawersListControllerProvider);
    final filter = ref.watch(cashDrawerFilterControllerProvider);
    final filterController = ref.read(
      cashDrawerFilterControllerProvider.notifier,
    );
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.cashDrawers, AccessRight.create);
    final canUpdate = access.can(SystemObject.cashDrawers, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('cash_drawers_search_field'),
              label: l10n.cashDrawersSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: filterController.searchChanged,
            ),
            actions: [
              if (canCreate)
                FilledButton.icon(
                  key: const Key('new_cash_drawer_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.newCashDrawerTooltip),
                  onPressed: () => context.push('/cash-drawers/new'),
                ),
            ],
            filters: [
              Badge.count(
                count: filter.activeFilterCount,
                isLabelVisible: filter.hasActiveFilters,
                child: IconButton.outlined(
                  key: const Key('cash_drawers_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filtersTooltip,
                  onPressed: () => showCatalogFilterSheet(
                    context,
                    title: l10n.filtersButton,
                    clearAllLabel: l10n.clearAllFilters,
                    applyLabel: l10n.applyFilters,
                    onClearAll: filterController.reset,
                    builder: (_) => const _CashDrawerFiltersPanel(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: pageAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.cashDrawersLoadError(e))),
            data: (CatalogPage<CashDrawer> page) => page.items.isEmpty
                ? Center(child: Text(l10n.noCashDrawersFound))
                : DataTableView<CashDrawer>(
                    key: const Key('cash_drawers_table'),
                    columns: [
                      DataTableColumn.text(
                        label: l10n.columnFacility,
                        text: (w) =>
                            w.facilityDisplayName(l10n.unknownFacilityLabel),
                        size: ColumnSize.M,
                      ),
                      DataTableColumn.text(
                        label: l10n.columnCode,
                        text: (w) => w.code,
                        size: ColumnSize.S,
                      ),
                      DataTableColumn.text(
                        label: l10n.columnName,
                        text: (w) => w.name,
                        size: ColumnSize.L,
                      ),
                      DataTableColumn(
                        label: l10n.columnStatus,
                        fixedWidth: 130,
                        cellBuilder: (context, w) =>
                            EntityStatusCell(status: w.status),
                      ),
                    ],
                    rows: page.items,
                    pagination: page,
                    onPageChanged: (pageIndex) => ref
                        .read(cashDrawersListControllerProvider.notifier)
                        .goToPage(pageIndex),
                    onRowTap: (w) =>
                        context.push('/cash-drawers/${w.cashDrawerId}?view=true'),
                    rowActionsBuilder: (context, w) => buildCatalogRowActions(
                      editTooltip: l10n.editActionTooltip,
                      onEdit: canUpdate
                          ? () => context.push('/cash-drawers/${w.cashDrawerId}')
                          : null,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// The CashDrawers catalog's facet filters (facility picker + status),
/// rendered inside the filter panel (FR-003).
class _CashDrawerFiltersPanel extends ConsumerWidget {
  const _CashDrawerFiltersPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(cashDrawerFilterControllerProvider);
    final filterController = ref.read(
      cashDrawerFilterControllerProvider.notifier,
    );
    final l10n = AppLocalizations.of(context)!;
    final facilityRepo = ref.read(facilityRepositoryProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogEntityPicker<FacilityListItem>(
          key: const Key('cash_drawers_filter_facility'),
          label: l10n.facilityFieldLabel,
          displayStringForOption: (f) => f.name,
          optionsBuilder: (query) async {
            final result = await facilityRepo.list(
              search: query.isEmpty ? null : query,
            );
            return result.items;
          },
          onSelected: (f) =>
              filterController.facilitySelected(f.facilityId, f.name),
          initialDisplayText: filter.facilityDisplayText,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.statusFilterLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        EntityStatusFilterChips(
          filterKey: 'cash_drawers_filter_status',
          value: filter.status,
          onChanged: filterController.statusChanged,
        ),
      ],
    );
  }
}
