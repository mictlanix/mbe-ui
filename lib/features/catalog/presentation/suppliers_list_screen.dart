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
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';
import 'package:mbe_ui/features/catalog/presentation/suppliers_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _suppliersPath = '/suppliers';

/// Suppliers catalog list screen (FR-001, FR-002, US1). Gated by
/// `can(SystemObject.suppliers, AccessRight.read)` in the router. Search-only
/// (no filter drawer): the list endpoint exposes no facets beyond `search`
/// (plan.md Constitution Check note on §VI).
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class SuppliersListScreen extends ConsumerWidget {
  const SuppliersListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = SupplierFilter.fromQuery(query);
    final pageAsync = ref.watch(suppliersListControllerProvider(filter));
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.suppliers, AccessRight.create);
    final canUpdate = access.can(SystemObject.suppliers, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('suppliers_search_field'),
              label: l10n.suppliersSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: (value) => context.go(
                query
                    .copyWith(search: value, pageIndex: 0)
                    .toUri(_suppliersPath)
                    .toString(),
              ),
            ),
            actions: [
              if (canCreate)
                FilledButton.icon(
                  key: const Key('new_supplier_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.newSupplierTooltip),
                  onPressed: () => context.push('/suppliers/new'),
                ),
            ],
          ),
        ),
        Expanded(
          child: CatalogListStateView<Supplier>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noSuppliersFound,
            createLabel: canCreate ? l10n.newSupplierTooltip : null,
            onCreate: canCreate ? () => context.push('/suppliers/new') : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_suppliersPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(suppliersListControllerProvider(filter)),
            onData: (page) => DataTableView<Supplier>(
              key: const Key('suppliers_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.columnCode,
                  text: (s) => s.code,
                  size: ColumnSize.S,
                ),
                DataTableColumn.text(
                  label: l10n.columnName,
                  text: (s) => s.name,
                  size: ColumnSize.L,
                ),
                DataTableColumn.text(
                  label: l10n.zoneLabel,
                  text: (s) => s.zone ?? '',
                  size: ColumnSize.M,
                ),
                DataTableColumn(
                  label: l10n.creditLimitLabel,
                  numeric: true,
                  fixedWidth: 140,
                  cellBuilder: (context, s) =>
                      Text(fmt.display.currency(s.creditLimit)),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_suppliersPath)
                    .toString(),
              ),
              onRowTap: (s) =>
                  context.push('/suppliers/${s.supplierId}?view=true'),
              rowActionsBuilder: (context, s) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => context.push('/suppliers/${s.supplierId}')
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
