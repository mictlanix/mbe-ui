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
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_issuer.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_issuers_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _taxpayerIssuersPath = '/taxpayer-issuers';

/// Taxpayer Issuers catalog list screen ("Razones Sociales"; FR-010, FR-031,
/// US2). Gated by `can(SystemObject.taxpayers, AccessRight.read)` in the
/// router. Search-only (no filter drawer): the issuer has no backend facets
/// beyond `search` (contracts/mbe-api-catalogs.md §2, mirrors
/// `TaxpayerRecipientsListScreen`).
///
/// Rows use the full `TaxpayerIssuer` entity (via
/// `TaxpayerIssuerRepository.listDetail`) so the table can show postal code
/// and fiscal regime alongside RFC and name, matching the legacy "Razones
/// Sociales" screen's columns (FR-010) — both arrive pre-expanded on the
/// list response already, so this adds no per-row lookup (FR-026).
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class TaxpayerIssuersListScreen extends ConsumerWidget {
  const TaxpayerIssuersListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = TaxpayerIssuerFilter.fromQuery(query);
    final pageAsync = ref.watch(taxpayerIssuersListControllerProvider(filter));
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.taxpayers, AccessRight.create);
    final canUpdate = access.can(SystemObject.taxpayers, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('taxpayer_issuers_search_field'),
              label: l10n.taxpayerIssuersSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: (value) => context.go(
                query
                    .copyWith(search: value, pageIndex: 0)
                    .toUri(_taxpayerIssuersPath)
                    .toString(),
              ),
            ),
            actions: [
              if (canCreate)
                FilledButton.icon(
                  key: const Key('new_taxpayer_issuer_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.newTaxpayerIssuerTooltip),
                  onPressed: () => context.push('/taxpayer-issuers/new'),
                ),
            ],
          ),
        ),
        Expanded(
          child: CatalogListStateView<TaxpayerIssuer>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noTaxpayerIssuersFound,
            createLabel: canCreate ? l10n.newTaxpayerIssuerTooltip : null,
            onCreate: canCreate
                ? () => context.push('/taxpayer-issuers/new')
                : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_taxpayerIssuersPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(taxpayerIssuersListControllerProvider(filter)),
            onData: (page) => DataTableView<TaxpayerIssuer>(
              key: const Key('taxpayer_issuers_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.columnRfc,
                  text: (t) => t.rfc,
                  size: ColumnSize.S,
                ),
                DataTableColumn.text(
                  label: l10n.columnPostalCodeShort,
                  text: (t) =>
                      t.postalCode?.description ?? t.postalCode?.code ?? '',
                  size: ColumnSize.S,
                ),
                DataTableColumn.text(
                  label: l10n.columnName,
                  text: (t) => t.name,
                  size: ColumnSize.L,
                ),
                DataTableColumn.text(
                  label: l10n.columnRegime,
                  text: (t) => t.regime?.description ?? t.regime?.code ?? '',
                  size: ColumnSize.L,
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_taxpayerIssuersPath)
                    .toString(),
              ),
              onRowTap: (t) =>
                  context.push('/taxpayer-issuers/${t.rfc}?view=true'),
              rowActionsBuilder: (context, t) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => context.push('/taxpayer-issuers/${t.rfc}')
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
