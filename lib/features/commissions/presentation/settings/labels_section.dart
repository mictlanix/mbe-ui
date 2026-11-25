import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/label_form.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/settings_scaffold.dart';
import 'package:mbe_ui/features/commissions/presentation/shared/commission_lookups.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Etiquetas: name, rate and comment of each commission label (spec 078
/// FR-012). The search and the paging are client-side. "+ Nueva etiqueta"
/// needs Create and the row's Edit needs Update; a row click opens the panel
/// read-only.
class CommissionLabelsSection extends ConsumerStatefulWidget {
  const CommissionLabelsSection({super.key});

  @override
  ConsumerState<CommissionLabelsSection> createState() =>
      _CommissionLabelsSectionState();
}

class _CommissionLabelsSectionState
    extends ConsumerState<CommissionLabelsSection> {
  String _search = '';
  int _page = 0;

  void _setSearch(String value) => setState(() {
    _search = value.trim();
    _page = 0;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final access = ref.watch(accessControlProvider);
    const object = SystemObject.commissionsBySalesPerson;
    final canCreate = access.can(object, AccessRight.create);
    final canUpdate = access.can(object, AccessRight.update);
    final needle = _search.toLowerCase();

    return CommissionSettingsScaffold(
      section: CommissionSettingsSection.labels,
      search: CatalogSearchBar(
        key: const Key('commission_labels_search_field'),
        label: l10n.commissionSearchLabel,
        searchTooltip: l10n.searchButtonTooltip,
        initialValue: _search,
        onSubmitted: _setSearch,
      ),
      actions: [
        if (canCreate)
          FilledButton(
            key: const Key('commission_new_label_button'),
            onPressed: () => showCommissionLabelPanel(context),
            child: Text(l10n.commissionNewLabelAction),
          ),
      ],
      body: CatalogListStateView<CommissionLabel>(
        state: ref
            .watch(commissionLabelsProvider)
            .whenData(
              (all) => commissionClientPage([
                for (final label in all)
                  if (needle.isEmpty ||
                      label.name.toLowerCase().contains(needle) ||
                      (label.comment ?? '').toLowerCase().contains(needle))
                    label,
              ], _page),
            ),
        isFiltered: _search.isNotEmpty,
        emptyMessage: l10n.commissionLabelsEmpty,
        createLabel: canCreate ? l10n.commissionNewLabelAction : null,
        onCreate: canCreate ? () => showCommissionLabelPanel(context) : null,
        clearFiltersLabel: l10n.clearFiltersButton,
        onClearFilters: () => _setSearch(''),
        retryLabel: l10n.retryButton,
        onRetry: () => ref.invalidate(commissionLabelsProvider),
        onData: (page) => DataTableView<CommissionLabel>(
          key: const Key('commission_labels_table'),
          columns: [
            DataTableColumn.text(
              label: l10n.nameLabel,
              size: ColumnSize.L,
              text: (l) => l.name,
            ),
            DataTableColumn.text(
              label: l10n.commissionColumnRateLabel,
              size: ColumnSize.S,
              numeric: true,
              text: (l) => fmt.display.percent(l.rate.toString()),
            ),
            DataTableColumn.text(
              label: l10n.columnComment,
              size: ColumnSize.L,
              text: (l) => l.comment ?? '',
            ),
          ],
          rows: page.items,
          pagination: page,
          onPageChanged: (i) => setState(() => _page = i),
          onRowTap: (l) =>
              showCommissionLabelPanel(context, label: l, forceReadOnly: true),
          rowActionsBuilder: (context, l) => buildCatalogRowActions(
            editTooltip: l10n.editActionTooltip,
            editKey: Key('commission_label_edit_${l.id}'),
            onEdit: canUpdate
                ? () => showCommissionLabelPanel(context, label: l)
                : null,
          ),
        ),
      ),
    );
  }
}
