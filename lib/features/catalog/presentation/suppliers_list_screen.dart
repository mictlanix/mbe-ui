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
import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';
import 'package:mbe_ui/features/catalog/presentation/suppliers_list_controller.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_formatters.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Suppliers catalog list screen (FR-001, FR-002, US1). Gated by
/// `can(SystemObject.suppliers, AccessRight.read)` in the router. Search-only
/// (no filter drawer): the list endpoint exposes no facets beyond `search`
/// (plan.md Constitution Check note on §VI).
class SuppliersListScreen extends ConsumerWidget {
  const SuppliersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(suppliersListControllerProvider);
    final search = ref.watch(supplierSearchControllerProvider);
    final searchController = ref.read(
      supplierSearchControllerProvider.notifier,
    );
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.suppliers, AccessRight.create);
    final canUpdate = access.can(SystemObject.suppliers, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('suppliers_search_field'),
              label: l10n.suppliersSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: search,
              onSubmitted: searchController.searchChanged,
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
          child: pageAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.suppliersLoadError(e))),
            data: (CatalogPage<Supplier> page) => page.items.isEmpty
                ? Center(child: Text(l10n.noSuppliersFound))
                : DataTableView<Supplier>(
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
                            Text(PricingFormatters.currency(s.creditLimit)),
                      ),
                    ],
                    rows: page.items,
                    pagination: page,
                    onPageChanged: (pageIndex) => ref
                        .read(suppliersListControllerProvider.notifier)
                        .goToPage(pageIndex),
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
