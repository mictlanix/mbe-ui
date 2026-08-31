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
import 'package:mbe_ui/features/catalog/domain/entities/label.dart';
import 'package:mbe_ui/features/catalog/presentation/labels_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _labelsPath = '/labels';

/// Labels catalog list screen (FR-001, FR-002, US2). Gated by
/// `can(SystemObject.labels, AccessRight.read)` in the router. Search-only
/// (no filter drawer): the list endpoint exposes no facets beyond `search`
/// (plan.md Constitution Check note on §VI).
///
/// [query] is decoded from the route by the router builder
/// (017-ui-consistency-filters FR-017) — the URL is this screen's only
/// source of view state; there is no local filter notifier.
class LabelsListScreen extends ConsumerWidget {
  const LabelsListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = LabelFilter.fromQuery(query);
    final pageAsync = ref.watch(labelsListControllerProvider(filter));
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.labels, AccessRight.create);
    final canUpdate = access.can(SystemObject.labels, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        CatalogFilterBar(
          search: CatalogSearchBar(
            key: const Key('labels_search_field'),
            label: l10n.labelsSearchLabel,
            searchTooltip: l10n.searchButtonTooltip,
            initialValue: filter.search,
            onSubmitted: (value) => submitCatalogSearch(
              context: context,
              query: query,
              path: _labelsPath,
              submitted: value,
              current: filter.search,
              refresh: () =>
                  ref.invalidate(labelsListControllerProvider(filter)),
            ),
          ),
          actions: [
            if (canCreate)
              FilledButton.icon(
                key: const Key('new_label_button'),
                icon: Icon(CatalogAction.create.icon),
                label: Text(l10n.newLabelTooltip),
                onPressed: () => context.push('/labels/new'),
              ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<Label>(
            state: pageAsync,
            isFiltered: query.isFiltered,
            emptyMessage: l10n.noLabelsFound,
            createLabel: canCreate ? l10n.newLabelTooltip : null,
            onCreate: canCreate ? () => context.push('/labels/new') : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_labelsPath),
            retryLabel: l10n.retryButton,
            onRetry: () => ref.invalidate(labelsListControllerProvider(filter)),
            onData: (page) => DataTableView<Label>(
              key: const Key('labels_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.nameLabel,
                  text: (lb) => lb.name,
                  size: ColumnSize.L,
                ),
                DataTableColumn.text(
                  label: l10n.commentLabel,
                  text: (lb) => lb.comment ?? '',
                  size: ColumnSize.L,
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_labelsPath)
                    .toString(),
              ),
              onRowTap: (lb) => context.push('/labels/${lb.labelId}?view=true'),
              rowActionsBuilder: (context, lb) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => context.push('/labels/${lb.labelId}')
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
