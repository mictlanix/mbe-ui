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
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_recipients_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Taxpayer Recipients catalog list screen (FR-001, FR-002, US5). Gated by
/// `can(SystemObject.taxpayerRecipients, AccessRight.read)` in the router.
/// Search-only (no filter drawer): the list endpoint exposes no facets
/// beyond `search` (plan.md Constitution Check note on §VI).
class TaxpayerRecipientsListScreen extends ConsumerWidget {
  const TaxpayerRecipientsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(taxpayerRecipientsListControllerProvider);
    final search = ref.watch(taxpayerRecipientSearchControllerProvider);
    final searchController = ref.read(
      taxpayerRecipientSearchControllerProvider.notifier,
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
              initialValue: search,
              onSubmitted: searchController.searchChanged,
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
          child: pageAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text(l10n.taxpayerRecipientsLoadError(e))),
            data: (CatalogPage<TaxpayerRecipientListItem> page) =>
                page.items.isEmpty
                ? Center(child: Text(l10n.noTaxpayerRecipientsFound))
                : DataTableView<TaxpayerRecipientListItem>(
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
                    onPageChanged: (pageIndex) => ref
                        .read(taxpayerRecipientsListControllerProvider.notifier)
                        .goToPage(pageIndex),
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
