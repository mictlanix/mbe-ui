import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/agent_form.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/settings_scaffold.dart';
import 'package:mbe_ui/features/commissions/presentation/shared/commission_lookups.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Agentes: the employees who earn commissions and their scheme (spec 078
/// FR-014). Client-side search and paging; "+ Nuevo agente" needs Create and
/// the row's Edit needs Update. The row's one extra action, "Ver tasas",
/// opens the rates section on that agent.
class CommissionAgentsSection extends ConsumerStatefulWidget {
  const CommissionAgentsSection({super.key});

  @override
  ConsumerState<CommissionAgentsSection> createState() =>
      _CommissionAgentsSectionState();
}

class _CommissionAgentsSectionState
    extends ConsumerState<CommissionAgentsSection> {
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
      section: CommissionSettingsSection.agents,
      search: CatalogSearchBar(
        key: const Key('commission_agents_search_field'),
        label: l10n.commissionSearchLabel,
        searchTooltip: l10n.searchButtonTooltip,
        initialValue: _search,
        onSubmitted: _setSearch,
      ),
      actions: [
        if (canCreate)
          FilledButton(
            key: const Key('commission_new_agent_button'),
            onPressed: () => showCommissionAgentPanel(context),
            child: Text(l10n.commissionNewAgentAction),
          ),
      ],
      body: CatalogListStateView<CommissionAgent>(
        state: ref
            .watch(commissionAgentsProvider)
            .whenData(
              (all) => commissionClientPage([
                for (final a in all)
                  if (needle.isEmpty || a.name.toLowerCase().contains(needle))
                    a,
              ], _page),
            ),
        isFiltered: _search.isNotEmpty,
        emptyMessage: l10n.commissionAgentsEmpty,
        createLabel: canCreate ? l10n.commissionNewAgentAction : null,
        onCreate: canCreate ? () => showCommissionAgentPanel(context) : null,
        clearFiltersLabel: l10n.clearFiltersButton,
        onClearFilters: () => _setSearch(''),
        retryLabel: l10n.retryButton,
        onRetry: () => ref.invalidate(commissionAgentsProvider),
        onData: (page) => DataTableView<CommissionAgent>(
          key: const Key('commission_agents_table'),
          columns: [
            DataTableColumn(
              label: l10n.commissionColumnAgent,
              size: ColumnSize.L,
              cellBuilder: (context, a) =>
                  CommissionAgentName(agentId: a.employeeId),
            ),
            DataTableColumn.text(
              label: l10n.commissionColumnScheme,
              size: ColumnSize.M,
              text: (a) => commissionSchemeLabel(l10n, a.scheme),
            ),
          ],
          rows: page.items,
          pagination: page,
          onPageChanged: (i) => setState(() => _page = i),
          onRowTap: (a) =>
              showCommissionAgentPanel(context, agent: a, forceReadOnly: true),
          rowActionsBuilder: (context, a) => buildCatalogRowActions(
            editTooltip: l10n.editActionTooltip,
            editKey: Key('commission_agent_edit_${a.employeeId}'),
            onEdit: canUpdate
                ? () => showCommissionAgentPanel(context, agent: a)
                : null,
            extraActions: [
              CatalogRowAction(
                key: Key('commission_agent_rates_${a.employeeId}'),
                icon: Icons.percent,
                tooltip: l10n.commissionViewRatesAction,
                onPressed: () => context.replace(
                  commissionSettingsLocation(
                    CommissionSettingsSection.rates,
                    agentId: a.employeeId,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
