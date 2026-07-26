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
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_recipients_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _taxpayerRecipientsPath = '/taxpayer-recipients';

/// Taxpayer Recipients catalog list screen (FR-001, FR-002, US5). Gated by
/// `can(SystemObject.taxpayerRecipients, AccessRight.read)` in the router.
/// Search-only (no filter drawer): the list endpoint exposes no facets
/// beyond `search` (plan.md Constitution Check note on §VI).
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class TaxpayerRecipientsListScreen extends ConsumerWidget {
  const TaxpayerRecipientsListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = TaxpayerRecipientFilter.fromQuery(query);
    final pageAsync = ref.watch(
      taxpayerRecipientsListControllerProvider(filter),
    );
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(
      SystemObject.taxpayerRecipients,
      AccessRight.create,
    );
    final canUpdate = access.can(
      SystemObject.taxpayerRecipients,
      AccessRight.update,
    );
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('taxpayer_recipients_search_field'),
              label: l10n.taxpayerRecipientsSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: (value) => context.go(
                query
                    .copyWith(search: value, pageIndex: 0)
                    .toUri(_taxpayerRecipientsPath)
                    .toString(),
              ),
            ),
            actions: [
              if (canCreate)
                FilledButton.icon(
                  key: const Key('new_taxpayer_recipient_button'),
                  icon: Icon(CatalogAction.create.icon),
                  label: Text(l10n.newTaxpayerRecipientTooltip),
                  onPressed: () => context.push('/taxpayer-recipients/new'),
                ),
            ],
          ),
        ),
        Expanded(
          child: CatalogListStateView<TaxpayerRecipientListItem>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noTaxpayerRecipientsFound,
            createLabel: canCreate ? l10n.newTaxpayerRecipientTooltip : null,
            onCreate: canCreate
                ? () => context.push('/taxpayer-recipients/new')
                : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_taxpayerRecipientsPath),
            retryLabel: l10n.retryButton,
            onRetry: () => ref.invalidate(
              taxpayerRecipientsListControllerProvider(filter),
            ),
            onData: (page) => DataTableView<TaxpayerRecipientListItem>(
              key: const Key('taxpayer_recipients_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.taxpayerRecipientIdLabel,
                  text: (t) => t.taxpayerRecipientId,
                  size: ColumnSize.M,
                ),
                DataTableColumn.text(
                  label: l10n.columnName,
                  text: (t) => t.name,
                  size: ColumnSize.L,
                ),
                DataTableColumn.text(
                  label: l10n.columnEmail,
                  text: (t) => t.email,
                  size: ColumnSize.L,
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_taxpayerRecipientsPath)
                    .toString(),
              ),
              onRowTap: (t) => context.push(
                '/taxpayer-recipients/${t.taxpayerRecipientId}?view=true',
              ),
              rowActionsBuilder: (context, t) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => context.push(
                        '/taxpayer-recipients/${t.taxpayerRecipientId}',
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
