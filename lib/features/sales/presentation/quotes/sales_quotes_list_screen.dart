import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/navigation/list_search_submit.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sales_quote_summary.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/sales_quotes_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/sales_quote_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _quotesPath = '/sales/quotes';

/// The Sales Quotes list (spec 040 FR-034…FR-039) — the facility's quotes,
/// never filtered to the current user (FR-034, `SalesQuotesListController`'s
/// own `mine: false`). Simpler than `SalesOrdersListScreen`: no date range,
/// no administrator-only facets — just status and customer (data-model.md
/// §4).
class SalesQuotesListScreen extends ConsumerWidget {
  const SalesQuotesListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final access = ref.watch(accessControlProvider);
    final filter = SalesQuotesFilter.fromQuery(query);
    final pageAsync = ref.watch(salesQuotesListControllerProvider(filter));
    final canCreate = access.can(SystemObject.salesQuotes, AccessRight.create);
    final canUpdate = access.can(SystemObject.salesQuotes, AccessRight.update);
    final fmt = ref.watch(formattersProvider);

    void goTo(ListQuery updated) =>
        context.go(updated.toUri(_quotesPath).toString());

    Future<void> openQuote(int quoteId) async {
      await context.push('$_quotesPath/$quoteId');
      if (!context.mounted) return;
      ref.invalidate(salesQuotesListControllerProvider(filter));
    }

    return Column(
      children: [
        CatalogFilterBar(
          search: CatalogSearchBar(
            key: const Key('sales_quotes_search_field'),
            label: l10n.salesQuotesSearchLabel,
            searchTooltip: l10n.searchButtonTooltip,
            initialValue: filter.search,
            onSubmitted: (value) => submitCatalogSearch(
              context: context,
              query: query,
              path: _quotesPath,
              submitted: value,
              current: filter.search,
              refresh: () =>
                  ref.invalidate(salesQuotesListControllerProvider(filter)),
            ),
          ),
          actions: [
            if (canCreate)
              FilledButton.icon(
                key: const Key('sales_quotes_new_quote_button'),
                icon: Icon(CatalogAction.create.icon),
                label: Text(l10n.salesQuoteNewAction),
                onPressed: () => context.push('$_quotesPath/new'),
              ),
          ],
          filters: [
            Badge.count(
              count: filter.activeFilterCount,
              isLabelVisible: filter.hasActiveFilters,
              child: IconButton.outlined(
                key: const Key('sales_quotes_filter_button'),
                icon: const Icon(Icons.tune),
                tooltip: l10n.filtersTooltip,
                onPressed: () => showCatalogFilterSheet(
                  context,
                  title: l10n.filtersButton,
                  clearAllLabel: l10n.clearAllFilters,
                  applyLabel: l10n.applyFilters,
                  onClearAll: () => goTo(
                    query
                        .withFacet('status', null)
                        .withFacet('customer', null)
                        .copyWith(pageIndex: 0),
                  ),
                  builder: (_) => CurrentListQueryBuilder(
                    builder: (context, currentQuery) =>
                        _SalesQuotesFiltersPanel(query: currentQuery),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<SalesQuoteSummary>(
            state: pageAsync,
            isFiltered: filter.hasActiveFilters || filter.search.isNotEmpty,
            emptyMessage: l10n.salesOrdersEmptyMessage,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_quotesPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(salesQuotesListControllerProvider(filter)),
            onData: (page) => DataTableView<SalesQuoteSummary>(
              key: const Key('sales_quotes_list_table'),
              columns: [
                DataTableColumn(
                  label: l10n.salesQuotesColumnReference,
                  size: ColumnSize.S,
                  cellBuilder: (context, quote) =>
                      Text('${quote.serial ?? quote.id}'),
                ),
                DataTableColumn(
                  label: l10n.salesQuotesColumnCustomer,
                  size: ColumnSize.L,
                  cellBuilder: (context, quote) =>
                      Text(quote.customerDisplayName ?? '—'),
                ),
                DataTableColumn(
                  label: l10n.salesQuotesColumnDate,
                  size: ColumnSize.M,
                  // A calendar date, not a timestamp — `dateTime` (used by
                  // the orders list's own Date column) doesn't fit this
                  // column's width once the Expiry column beside it also
                  // carries the expired marker (FR-035).
                  cellBuilder: (context, quote) =>
                      Text(fmt.display.date(quote.date)),
                ),
                DataTableColumn(
                  label: l10n.salesQuotesColumnExpiry,
                  size: ColumnSize.L,
                  // FR-024, FR-037: the expired marker sits beside the date
                  // here, never folded into the status chip's own column.
                  // Wider than the plain Date column since it sometimes
                  // carries this marker too.
                  cellBuilder: (context, quote) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(fmt.display.date(quote.dueDate)),
                      if (quote.hasExpired) ...[
                        const SizedBox(width: 2),
                        SalesQuoteExpiredMarker(hasExpired: quote.hasExpired),
                      ],
                    ],
                  ),
                ),
                DataTableColumn(
                  label: l10n.salesQuotesColumnStatus,
                  size: ColumnSize.S,
                  cellBuilder: (context, quote) =>
                      SalesQuoteStatusChip(status: quote.status),
                ),
                DataTableColumn(
                  label: l10n.salesQuotesColumnTotal,
                  numeric: true,
                  size: ColumnSize.S,
                  cellBuilder: (context, quote) =>
                      Text(fmt.display.currency(quote.total)),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_quotesPath)
                    .toString(),
              ),
              rowActionsBuilder: (context, quote) {
                final editable = quote.status == SaleStatus.draft;
                return buildCatalogRowActions(
                  editTooltip: l10n.editActionTooltip,
                  onEdit: canUpdate && editable
                      ? () => openQuote(quote.id)
                      : null,
                );
              },
              onRowTap: (quote) => openQuote(quote.id),
            ),
          ),
        ),
      ],
    );
  }
}

/// The list's facets (spec 040 FR-036): status and customer — no date
/// range, no administrator-only facets, unlike `SalesOrdersListScreen`'s own
/// panel.
class _SalesQuotesFiltersPanel extends ConsumerWidget {
  const _SalesQuotesFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = SalesQuotesFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;

    void goTo(ListQuery updated) =>
        context.go(updated.toUri(_quotesPath).toString());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.salesQuotesStatusFilterLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              key: const Key('sales_quotes_filter_status_all'),
              label: Text(l10n.posSalesStatusFilterAll),
              selected: filter.status == null,
              onSelected: (_) =>
                  goTo(query.withFacet('status', null).copyWith(pageIndex: 0)),
            ),
            for (final status in SaleStatus.values)
              ChoiceChip(
                key: Key('sales_quotes_filter_status_${status.name}'),
                label: Text(salesQuoteStatusLabel(l10n, status)),
                selected: filter.status == status,
                onSelected: (_) => goTo(
                  query.withFacet('status', status.name).copyWith(pageIndex: 0),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        CatalogEntityPicker<CustomerListItem>(
          key: const Key('sales_quotes_filter_customer'),
          label: l10n.salesQuotesCustomerFilterLabel,
          displayStringForOption: (c) => '${c.code} — ${c.name}',
          optionsBuilder: (search) async {
            final result = await ref
                .read(customerRepositoryProvider)
                .list(search: search.isEmpty ? null : search, limit: 10);
            return result.items;
          },
          onSelected: (c) => goTo(
            query
                .withFacet('customer', '${c.customerId}')
                .copyWith(pageIndex: 0),
          ),
          // No name-resolution provider for a bare id arriving via the URL
          // (unlike `employeeDisplayNameProvider`/`facilityDisplayNameProvider`
          // in the orders panel) — the id itself stands in until the picker
          // is touched again.
          initialDisplayText: filter.customer?.toString(),
        ),
      ],
    );
  }
}
