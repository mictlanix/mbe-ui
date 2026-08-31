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
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/presentation/price_lists_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _priceListsPath = '/price-lists';

/// Price-lists catalog list screen (FR-001, FR-005). Gated by
/// `can(SystemObject.priceLists, AccessRight.read)` in the router.
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class PriceListsListScreen extends ConsumerWidget {
  const PriceListsListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = PriceListFilter.fromQuery(query);
    final pageAsync = ref.watch(priceListsListControllerProvider(filter));
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.priceLists, AccessRight.create);
    final canUpdate = access.can(SystemObject.priceLists, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        CatalogFilterBar(
          search: CatalogSearchBar(
            key: const Key('price_lists_search_field'),
            label: l10n.priceListsSearchLabel,
            searchTooltip: l10n.searchButtonTooltip,
            initialValue: filter.search,
            onSubmitted: (value) => submitCatalogSearch(
              context: context,
              query: query,
              path: _priceListsPath,
              submitted: value,
              current: filter.search,
              refresh: () =>
                  ref.invalidate(priceListsListControllerProvider(filter)),
            ),
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
        Expanded(
          child: CatalogListStateView<PriceList>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noPriceListsFound,
            createLabel: canCreate ? l10n.newPriceListTooltip : null,
            onCreate: canCreate ? () => context.push('/price-lists/new') : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_priceListsPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(priceListsListControllerProvider(filter)),
            onData: (page) => DataTableView<PriceList>(
              key: const Key('price_lists_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.priceListNameLabel,
                  text: (p) => p.name,
                  size: ColumnSize.L,
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_priceListsPath)
                    .toString(),
              ),
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
