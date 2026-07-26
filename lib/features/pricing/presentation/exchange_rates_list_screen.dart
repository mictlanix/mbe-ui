import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/pricing/domain/entities/exchange_rate.dart';
import 'package:mbe_ui/features/pricing/presentation/exchange_rates_list_controller.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_formatters.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _exchangeRatesPath = '/exchange-rates';

/// Exchange-rates catalog list screen (FR-014, FR-015). Gated by
/// `can(SystemObject.exchangeRates, AccessRight.read)` in the router.
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class ExchangeRatesListScreen extends ConsumerWidget {
  const ExchangeRatesListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ExchangeRateFilter.fromQuery(query);
    final pageAsync = ref.watch(exchangeRatesListControllerProvider(filter));

    void goTo(ListQuery updated) =>
        context.go(updated.toUri(_exchangeRatesPath).toString());

    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(
      SystemObject.exchangeRates,
      AccessRight.create,
    );
    final canUpdate = access.can(
      SystemObject.exchangeRates,
      AccessRight.update,
    );
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: const SizedBox.shrink(),
            actions: [
              if (canCreate)
                FilledButton.icon(
                  key: const Key('new_exchange_rate_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.newExchangeRateTooltip),
                  onPressed: () => context.push('/exchange-rates/new'),
                ),
            ],
            filters: [
              OutlinedButton.icon(
                key: const Key('exchange_rate_date_range_filter'),
                icon: const Icon(Icons.date_range),
                label: Text(
                  filter.dateFrom == null
                      ? l10n.dateRangeFilterLabel
                      : '${PricingFormatters.date(filter.dateFrom!)} – '
                            '${PricingFormatters.date(filter.dateTo ?? filter.dateFrom!)}',
                ),
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDateRange:
                        filter.dateFrom != null && filter.dateTo != null
                        ? DateTimeRange(
                            start: filter.dateFrom!,
                            end: filter.dateTo!,
                          )
                        : null,
                  );
                  if (range != null) {
                    goTo(
                      query
                          .withFacet('dateFrom', toIsoDateFacet(range.start))
                          .withFacet('dateTo', toIsoDateFacet(range.end))
                          .copyWith(pageIndex: 0),
                    );
                  }
                },
              ),
              if (filter.dateFrom != null)
                IconButton(
                  key: const Key('clear_date_range_button'),
                  icon: const Icon(Icons.clear),
                  tooltip: l10n.clearDateRangeTooltip,
                  onPressed: () => goTo(
                    query
                        .withFacet('dateFrom', null)
                        .withFacet('dateTo', null)
                        .copyWith(pageIndex: 0),
                  ),
                ),
              DropdownButton<Currency?>(
                key: const Key('exchange_rate_base_filter'),
                value: filter.base != null
                    ? Currency.fromValue(filter.base!)
                    : null,
                hint: Text(l10n.currencyFilterLabel),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.currencyFilterLabel),
                  ),
                  for (final currency in Currency.values)
                    DropdownMenuItem(
                      value: currency,
                      child: Text(_currencyLabel(l10n, currency)),
                    ),
                ],
                onChanged: (currency) => goTo(
                  query
                      .withFacet('base', currency?.value.toString())
                      .copyWith(pageIndex: 0),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CatalogListStateView<ExchangeRate>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noExchangeRatesFound,
            createLabel: canCreate ? l10n.newExchangeRateTooltip : null,
            onCreate: canCreate
                ? () => context.push('/exchange-rates/new')
                : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_exchangeRatesPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(exchangeRatesListControllerProvider(filter)),
            onData: (page) => DataTableView<ExchangeRate>(
              key: const Key('exchange_rates_table'),
              columns: [
                DataTableColumn(
                  label: l10n.columnDate,
                  fixedWidth: 140,
                  cellBuilder: (context, r) =>
                      Text(PricingFormatters.date(r.date)),
                ),
                DataTableColumn.text(
                  label: l10n.columnBaseCurrency,
                  text: (r) => r.base != null
                      ? r.base!.name.toUpperCase()
                      : '${r.rawBase}',
                  size: ColumnSize.S,
                ),
                DataTableColumn.text(
                  label: l10n.columnTargetCurrency,
                  text: (r) => r.target != null
                      ? r.target!.name.toUpperCase()
                      : '${r.rawTarget}',
                  size: ColumnSize.S,
                ),
                DataTableColumn(
                  label: l10n.columnRate,
                  numeric: true,
                  fixedWidth: 140,
                  cellBuilder: (context, r) => Text(r.rate),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) =>
                  goTo(query.copyWith(pageIndex: pageIndex)),
              onRowTap: (r) =>
                  context.push('/exchange-rates/${r.exchangeRateId}?view=true'),
              rowActionsBuilder: (context, r) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => context.push('/exchange-rates/${r.exchangeRateId}')
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _currencyLabel(AppLocalizations l10n, Currency currency) =>
    switch (currency) {
      Currency.mxn => l10n.currencyMxnLabel,
      Currency.usd => l10n.currencyUsdLabel,
      Currency.eur => l10n.currencyEurLabel,
    };
