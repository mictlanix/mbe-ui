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
import 'package:mbe_ui/features/catalog/domain/entities/label.dart';
import 'package:mbe_ui/features/catalog/presentation/labels_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Labels catalog list screen (FR-001, FR-002, US2). Gated by
/// `can(SystemObject.labels, AccessRight.read)` in the router. Search-only
/// (no filter drawer): the list endpoint exposes no facets beyond `search`
/// (plan.md Constitution Check note on §VI).
class LabelsListScreen extends ConsumerWidget {
  const LabelsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(labelsListControllerProvider);
    final search = ref.watch(labelSearchControllerProvider);
    final searchController = ref.read(labelSearchControllerProvider.notifier);
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(SystemObject.labels, AccessRight.create);
    final canUpdate = access.can(SystemObject.labels, AccessRight.update);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('labels_search_field'),
              label: l10n.labelsSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: search,
              onSubmitted: searchController.searchChanged,
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
        ),
        Expanded(
          child: pageAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.labelsLoadError(e))),
            data: (CatalogPage<Label> page) => page.items.isEmpty
                ? Center(child: Text(l10n.noLabelsFound))
                : DataTableView<Label>(
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
                    onPageChanged: (pageIndex) => ref
                        .read(labelsListControllerProvider.notifier)
                        .goToPage(pageIndex),
                    onRowTap: (lb) =>
                        context.push('/labels/${lb.labelId}?view=true'),
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
