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
import 'package:mbe_ui/core/widgets/record_sheet.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_recipient_form.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_recipients_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _taxpayerRecipientsPath = '/taxpayer-recipients';

void _openTaxpayerRecipientSheet(
  BuildContext context, {
  required String title,
  String? taxpayerRecipientId,
  bool forceReadOnly = false,
}) {
  final formKey = GlobalKey<TaxpayerRecipientFormPanelState>();
  showRecordSheet(
    context,
    title: title,
    form: (context) => TaxpayerRecipientForm(
      key: formKey,
      taxpayerRecipientId: taxpayerRecipientId,
      forceReadOnly: forceReadOnly,
    ),
    isDirty: () => formKey.currentState?.isDirty() ?? false,
  );
}

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
        CatalogFilterBar(
          search: CatalogSearchBar(
            key: const Key('taxpayer_recipients_search_field'),
            label: l10n.taxpayerRecipientsSearchLabel,
            searchTooltip: l10n.searchButtonTooltip,
            initialValue: filter.search,
            onSubmitted: (value) => submitCatalogSearch(
              context: context,
              query: query,
              path: _taxpayerRecipientsPath,
              submitted: value,
              current: filter.search,
              refresh: () => ref.invalidate(
                taxpayerRecipientsListControllerProvider(filter),
              ),
            ),
          ),
          actions: [
            if (canCreate)
              FilledButton.icon(
                key: const Key('new_taxpayer_recipient_button'),
                icon: Icon(CatalogAction.create.icon),
                label: Text(l10n.newTaxpayerRecipientTooltip),
                onPressed: () => _openTaxpayerRecipientSheet(
                  context,
                  title: l10n.newTaxpayerRecipientTitle,
                ),
              ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<TaxpayerRecipientListItem>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noTaxpayerRecipientsFound,
            createLabel: canCreate ? l10n.newTaxpayerRecipientTooltip : null,
            onCreate: canCreate
                ? () => _openTaxpayerRecipientSheet(
                    context,
                    title: l10n.newTaxpayerRecipientTitle,
                  )
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
              onRowTap: (t) => _openTaxpayerRecipientSheet(
                context,
                title: l10n.viewTaxpayerRecipientTitle,
                taxpayerRecipientId: t.taxpayerRecipientId,
                forceReadOnly: true,
              ),
              rowActionsBuilder: (context, t) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => _openTaxpayerRecipientSheet(
                        context,
                        title: l10n.editTaxpayerRecipientTitle,
                        taxpayerRecipientId: t.taxpayerRecipientId,
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
