import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/participation_form.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/settings_scaffold.dart';
import 'package:mbe_ui/features/commissions/presentation/shared/commission_lookups.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Participaciones: the participation types (spec 078 FR-013), a name each.
/// Client-side search and paging; "+ Nueva participación" needs Create and
/// the row's Edit needs Update.
class CommissionParticipationsSection extends ConsumerStatefulWidget {
  const CommissionParticipationsSection({super.key});

  @override
  ConsumerState<CommissionParticipationsSection> createState() =>
      _CommissionParticipationsSectionState();
}

class _CommissionParticipationsSectionState
    extends ConsumerState<CommissionParticipationsSection> {
  String _search = '';
  int _page = 0;

  void _setSearch(String value) => setState(() {
    _search = value.trim();
    _page = 0;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final access = ref.watch(accessControlProvider);
    const object = SystemObject.commissionsBySalesPerson;
    final canCreate = access.can(object, AccessRight.create);
    final canUpdate = access.can(object, AccessRight.update);
    final needle = _search.toLowerCase();

    return CommissionSettingsScaffold(
      section: CommissionSettingsSection.participations,
      search: CatalogSearchBar(
        key: const Key('commission_participations_search_field'),
        label: l10n.commissionSearchLabel,
        searchTooltip: l10n.searchButtonTooltip,
        initialValue: _search,
        onSubmitted: _setSearch,
      ),
      actions: [
        if (canCreate)
          FilledButton(
            key: const Key('commission_new_participation_button'),
            onPressed: () => showCommissionParticipationPanel(context),
            child: Text(l10n.commissionNewParticipationAction),
          ),
      ],
      body: CatalogListStateView<CommissionParticipation>(
        state: ref
            .watch(commissionParticipationsProvider)
            .whenData(
              (all) => commissionClientPage([
                for (final p in all)
                  if (needle.isEmpty || p.name.toLowerCase().contains(needle))
                    p,
              ], _page),
            ),
        isFiltered: _search.isNotEmpty,
        emptyMessage: l10n.commissionParticipationsEmpty,
        createLabel: canCreate ? l10n.commissionNewParticipationAction : null,
        onCreate: canCreate
            ? () => showCommissionParticipationPanel(context)
            : null,
        clearFiltersLabel: l10n.clearFiltersButton,
        onClearFilters: () => _setSearch(''),
        retryLabel: l10n.retryButton,
        onRetry: () => ref.invalidate(commissionParticipationsProvider),
        onData: (page) => DataTableView<CommissionParticipation>(
          key: const Key('commission_participations_table'),
          columns: [
            DataTableColumn.text(
              label: l10n.nameLabel,
              size: ColumnSize.L,
              text: (p) => p.name,
            ),
          ],
          rows: page.items,
          pagination: page,
          onPageChanged: (i) => setState(() => _page = i),
          onRowTap: (p) => showCommissionParticipationPanel(
            context,
            participation: p,
            forceReadOnly: true,
          ),
          rowActionsBuilder: (context, p) => buildCatalogRowActions(
            editTooltip: l10n.editActionTooltip,
            editKey: Key('commission_participation_edit_${p.id}'),
            onEdit: canUpdate
                ? () => showCommissionParticipationPanel(
                    context,
                    participation: p,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
