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
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/record_sheet.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_form.dart';
import 'package:mbe_ui/features/catalog/presentation/suppliers_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _suppliersPath = '/suppliers';

void _openSupplierSheet(
  BuildContext context, {
  required String title,
  int? supplierId,
  bool forceReadOnly = false,
}) {
  final formKey = GlobalKey<SupplierFormPanelState>();
  showRecordSheet(
    context,
    title: title,
    form: (context) => SupplierForm(
      key: formKey,
      supplierId: supplierId,
      forceReadOnly: forceReadOnly,
    ),
    isDirty: () => formKey.currentState?.isDirty() ?? false,
  );
}

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
        CatalogFilterBar(
          search: CatalogSearchBar(
            key: const Key('suppliers_search_field'),
            label: l10n.suppliersSearchLabel,
            searchTooltip: l10n.searchButtonTooltip,
            initialValue: filter.search,
            onSubmitted: (value) => submitCatalogSearch(
              context: context,
              query: query,
              path: _suppliersPath,
              submitted: value,
              current: filter.search,
              refresh: () =>
                  ref.invalidate(suppliersListControllerProvider(filter)),
            ),
          ),
          actions: [
            if (canCreate)
              FilledButton.icon(
                key: const Key('new_supplier_button'),
                icon: Icon(CatalogAction.create.icon),
                label: Text(l10n.newSupplierTooltip),
                onPressed: () =>
                    _openSupplierSheet(context, title: l10n.newSupplierTitle),
              ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<Supplier>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noSuppliersFound,
            createLabel: canCreate ? l10n.newSupplierTooltip : null,
            onCreate: canCreate
                ? () => _openSupplierSheet(context, title: l10n.newSupplierTitle)
                : null,
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
              onRowTap: (s) => _openSupplierSheet(
                context,
                title: l10n.viewSupplierTitle,
                supplierId: s.supplierId,
                forceReadOnly: true,
              ),
              rowActionsBuilder: (context, s) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => _openSupplierSheet(
                        context,
                        title: l10n.editSupplierTitle,
                        supplierId: s.supplierId,
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
