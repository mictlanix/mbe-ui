import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The commission agents (spec 078 research R3), read once and shared by the
/// month, the settings sections and the pickers. A screen that changes an
/// agent invalidates it. Commissions (112) read is the right it needs.
final commissionAgentsProvider = FutureProvider<List<CommissionAgent>>(
  (ref) => ref.watch(commissionRepositoryProvider).listAgents(),
);

/// The commission labels, shared like [commissionAgentsProvider].
final commissionLabelsProvider = FutureProvider<List<CommissionLabel>>(
  (ref) => ref.watch(commissionRepositoryProvider).listLabels(),
);

/// The participation types, shared like [commissionAgentsProvider].
final commissionParticipationsProvider =
    FutureProvider<List<CommissionParticipation>>(
      (ref) => ref.watch(commissionRepositoryProvider).listParticipations(),
    );

/// An agent's display name (research R3): the agents list first, then the
/// employee's own name (a former agent is no longer on the list, but a month
/// they earned in still names them), then `null`. [CommissionAgentName] turns
/// that last case into the localized fallback. A failed list read degrades to
/// the next source rather than failing the name.
final commissionAgentNameProvider = FutureProvider.family<String?, int>((
  ref,
  agentId,
) async {
  try {
    final agents = await ref.watch(commissionAgentsProvider.future);
    for (final agent in agents) {
      if (agent.employeeId == agentId) return agent.name;
    }
  } catch (_) {
    // Fall through to the employee's name.
  }
  return ref.watch(employeeDisplayNameProvider(agentId).future);
});

/// An agent's name on one line, ellipsized, with the full text in a tooltip
/// (constitution §VI). Shows `…` while loading and "Agente #id" when no
/// source knows the agent.
class CommissionAgentName extends ConsumerWidget {
  const CommissionAgentName({super.key, required this.agentId});

  final int agentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fallback = l10n.commissionAgentFallback('$agentId');
    final text = ref
        .watch(commissionAgentNameProvider(agentId))
        .when(
          data: (name) => name ?? fallback,
          loading: () => '…',
          error: (_, _) => fallback,
        );
    return Tooltip(
      message: text,
      child: Text(text, overflow: TextOverflow.ellipsis, maxLines: 1),
    );
  }
}
