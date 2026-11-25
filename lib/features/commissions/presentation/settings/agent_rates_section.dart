import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/agent_rates_grid.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/settings_scaffold.dart';
import 'package:mbe_ui/features/commissions/presentation/shared/commission_lookups.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Tasas por agente: one agent's grid of labels by participation types (spec
/// 078 FR-015, research R11). The agent is picked in the filter drawer and
/// shown in a strip above the grid; `?agent=` (from "Ver tasas") picks it
/// first, otherwise it is the first agent by name. Each cell needs the right
/// of the call it makes (see [AgentRatesGrid]); Read alone sees text.
class CommissionRatesSection extends ConsumerStatefulWidget {
  const CommissionRatesSection({super.key, this.agentId});

  /// The `?agent=` of the route.
  final int? agentId;

  @override
  ConsumerState<CommissionRatesSection> createState() =>
      _CommissionRatesSectionState();
}

class _CommissionRatesSectionState
    extends ConsumerState<CommissionRatesSection> {
  /// The agent chosen in the drawer or the route; `null` is the default, the
  /// first by name.
  int? _agentId;

  @override
  void initState() {
    super.initState();
    _agentId = widget.agentId;
  }

  @override
  void didUpdateWidget(CommissionRatesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.agentId != widget.agentId) _agentId = widget.agentId;
  }

  List<CommissionAgent> _sorted(List<CommissionAgent> agents) =>
      [...agents]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  void _openSheet(List<CommissionAgent> agents) {
    final l10n = AppLocalizations.of(context)!;
    showCatalogFilterSheet(
      context,
      title: l10n.filtersButton,
      clearAllLabel: l10n.clearAllFilters,
      applyLabel: l10n.applyFilters,
      onClearAll: () => setState(() => _agentId = null),
      builder: (_) => Padding(
        padding: EdgeInsets.all(Theme.of(context).spacing.cardPadding),
        child: CatalogEntityPicker<CommissionAgent>(
          key: const Key('commission_rates_agent_picker'),
          label: l10n.commissionAgentFilterLabel,
          initialDisplayText: _currentName(agents),
          displayStringForOption: (a) => a.name,
          optionsBuilder: (query) async {
            final needle = query.trim().toLowerCase();
            return _sorted(agents).where(
              (a) => needle.isEmpty || a.name.toLowerCase().contains(needle),
            );
          },
          onSelected: (a) => setState(() => _agentId = a.employeeId),
        ),
      ),
    );
  }

  String? _currentName(List<CommissionAgent> agents) {
    final id = _agentId;
    if (id == null) return null;
    for (final a in agents) {
      if (a.employeeId == id) return a.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final agentsState = ref.watch(commissionAgentsProvider);
    final agents = agentsState.value ?? const <CommissionAgent>[];
    final sorted = _sorted(agents);
    final selected =
        _agentId ?? (sorted.isEmpty ? null : sorted.first.employeeId);
    final filterCount = _agentId == null ? 0 : 1;

    final Widget body = agentsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ListFailedView(
        error: toAppError(error),
        retryLabel: l10n.retryButton,
        onRetry: () => ref.invalidate(commissionAgentsProvider),
      ),
      data: (_) => selected == null
          ? ListEmptyView(message: l10n.commissionRatesEmpty)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: spacing.fieldGapVertical,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.cardPadding,
                  ),
                  child: FactStripRow(
                    key: const Key('commission_rates_agent_strip'),
                    facts: [
                      CompactField(
                        label: l10n.commissionAgentFilterLabel,
                        child: CommissionAgentName(agentId: selected),
                      ),
                    ],
                    trailing: const SizedBox.shrink(),
                  ),
                ),
                Expanded(
                  child: AgentRatesGrid(
                    key: ValueKey(selected),
                    agentId: selected,
                  ),
                ),
              ],
            ),
    );

    return CommissionSettingsScaffold(
      section: CommissionSettingsSection.rates,
      filters: [
        Badge.count(
          count: filterCount,
          isLabelVisible: filterCount > 0,
          child: IconButton.outlined(
            key: const Key('commission_rates_filter_button'),
            icon: const Icon(Icons.tune),
            tooltip: l10n.filtersTooltip,
            onPressed: agentsState.hasValue ? () => _openSheet(agents) : null,
          ),
        ),
      ],
      body: body,
    );
  }
}
