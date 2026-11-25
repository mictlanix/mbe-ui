import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/features/commissions/presentation/settings/agent_rates_section.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/agents_section.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/labels_section.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/participations_section.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/product_labels_section.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/settings_scaffold.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

export 'package:mbe_ui/features/commissions/presentation/settings/settings_scaffold.dart'
    show
        CommissionSettingsScaffold,
        CommissionSettingsSection,
        commissionClientPage,
        commissionSettingsLocation,
        commissionSettingsPath;

/// Configuración de comisiones (spec 078 US4 to US6, contracts/ui-contract.md
/// "Settings"): one screen, five sections chosen by `?section=`. Gated by
/// SystemObject 112 (`commissionsBySalesPerson`) read through the router's
/// `/commissions` prefix rule; each control needs the right of the call it
/// makes.
///
/// A section is a widget that builds its own [CommissionSettingsScaffold]
/// (filter row with the section switch, the FR-018 note, the body). [agentId]
/// is the `?agent=` of the rates section.
class CommissionSettingsScreen extends StatelessWidget {
  const CommissionSettingsScreen({
    super.key,
    required this.section,
    this.agentId,
  });

  final CommissionSettingsSection section;
  final int? agentId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      // No app bar actions (constitution §VI).
      appBar: AppBar(title: Text(l10n.commissionSettingsTitle)),
      body: switch (section) {
        CommissionSettingsSection.labels => const CommissionLabelsSection(),
        CommissionSettingsSection.participations =>
          const CommissionParticipationsSection(),
        CommissionSettingsSection.agents => const CommissionAgentsSection(),
        CommissionSettingsSection.rates => CommissionRatesSection(
          agentId: agentId,
        ),
        CommissionSettingsSection.products =>
          const CommissionProductLabelsSection(),
      },
    );
  }
}

/// The settings route (`/commissions/settings?section=…[&agent=ID]`). Must be
/// declared before the month route so `settings` is not read as a year.
GoRoute commissionSettingsRoute() => GoRoute(
  path: commissionSettingsPath,
  builder: (context, state) => CommissionSettingsScreen(
    section: CommissionSettingsSection.fromQuery(
      state.uri.queryParameters['section'],
    ),
    agentId: int.tryParse(state.uri.queryParameters['agent'] ?? ''),
  ),
);
