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
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/presentation/price_lists_list_controller.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_formatters.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Price-lists catalog list screen (FR-001, FR-005). Gated by
/// `can(SystemObject.priceLists, AccessRight.read)` in the router.
class PriceListsListScreen extends ConsumerWidget {
  const PriceListsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(priceListsListControllerProvider);
    final search = ref.watch(priceListSearchControllerProvider);
    final searchController = ref.read(
      priceListSearchControllerProvider.notifier,
    );
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.priceLists, AccessRight.create);
    final canUpdate = access.can(SystemObject.priceLists, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('price_lists_search_field'),
              label: l10n.priceListsSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: search,
              onSubmitted: searchController.searchChanged,
            ),
            actions: [
              if (canCreate)
                FilledButton.icon(
                  key: const Key('new_price_list_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.newPriceListTooltip),
                  onPressed: () => context.push('/price-lists/new'),
                ),
            ],
          ),
        ),
        Expanded(
          child: pageAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.priceListsLoadError(e))),
            data: (CatalogPage<PriceList> page) => page.items.isEmpty
                ? Center(child: Text(l10n.noPriceListsFound))
                : DataTableView<PriceList>(
                    key: const Key('price_lists_table'),
                    columns: [
                      DataTableColumn.text(
                        label: l10n.priceListNameLabel,
                        text: (p) => p.name,
                        size: ColumnSize.L,
                      ),
                      DataTableColumn(
                        label: l10n.columnHighProfitMargin,
                        numeric: true,
                        fixedWidth: 140,
                        cellBuilder: (context, p) =>
                            Text(PricingFormatters.percent(p.highProfitMargin)),
                      ),
                      DataTableColumn(
                        label: l10n.columnLowProfitMargin,
                        numeric: true,
                        fixedWidth: 140,
                        cellBuilder: (context, p) =>
                            Text(PricingFormatters.percent(p.lowProfitMargin)),
                      ),
                    ],
                    rows: page.items,
                    pagination: page,
                    onPageChanged: (pageIndex) => ref
                        .read(priceListsListControllerProvider.notifier)
                        .goToPage(pageIndex),
                    onRowTap: (p) =>
                        context.push('/price-lists/${p.priceListId}?view=true'),
                    rowActionsBuilder: (context, p) => buildCatalogRowActions(
                      editTooltip: l10n.editActionTooltip,
                      onEdit: canUpdate
                          ? () => context.push('/price-lists/${p.priceListId}')
                          : null,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
