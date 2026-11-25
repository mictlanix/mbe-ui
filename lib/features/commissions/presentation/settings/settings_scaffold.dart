import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/info_banner.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The settings route, `/commissions/settings`. Declared before the month
/// route in the router; the `/commissions` gate covers it.
const commissionSettingsPath = '/commissions/settings';

/// Rows per in-memory page in the settings tables (the lists are unpaged).
const commissionSettingsPageSize = 25;

/// The settings screen's sections, in switch order. [name] is the
/// `?section=` value.
enum CommissionSettingsSection {
  labels,
  participations,
  agents,
  rates,
  products;

  /// The section `?section=` names; an absent or unknown value is [labels].
  static CommissionSettingsSection fromQuery(String? value) =>
      values.firstWhere(
        (s) => s.name == value,
        orElse: () => CommissionSettingsSection.labels,
      );

  String label(AppLocalizations l10n) => switch (this) {
    labels => l10n.commissionSectionLabels,
    participations => l10n.commissionSectionParticipations,
    agents => l10n.commissionSectionAgents,
    rates => l10n.commissionSectionRates,
    products => l10n.commissionSectionProducts,
  };
}

/// `/commissions/settings?section=…[&agent=ID]`.
String commissionSettingsLocation(
  CommissionSettingsSection section, {
  int? agentId,
}) => Uri(
  path: commissionSettingsPath,
  queryParameters: {
    'section': section.name,
    if (agentId != null) 'agent': '$agentId',
  },
).toString();

/// One page of [rows] held in memory.
CatalogPage<T> commissionClientPage<T>(List<T> rows, int pageIndex) {
  final start = pageIndex * commissionSettingsPageSize;
  return CatalogPage(
    items: start >= rows.length
        ? const []
        : rows.sublist(
            start,
            (start + commissionSettingsPageSize).clamp(0, rows.length),
          ),
    total: rows.length,
    pageIndex: pageIndex,
    pageSize: commissionSettingsPageSize,
  );
}

/// The section switch: a `SegmentedButton` from 840 px (the filter row's
/// single-row tier), a `DropdownButton` below. It writes `?section=`, replacing the settings entry in the history.
class CommissionSectionSwitch extends StatelessWidget {
  const CommissionSectionSwitch({super.key, required this.section});

  final CommissionSettingsSection section;

  void _go(BuildContext context, CommissionSettingsSection next) =>
      context.replace(commissionSettingsLocation(next));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    // Five segments need the filter row's single-row layout (840 px); in the
    // wrapped layout below it they would overflow, so the dropdown takes over.
    if (MediaQuery.sizeOf(context).width < LayoutBreakpoints.expanded) {
      return DropdownButton<CommissionSettingsSection>(
        key: const Key('commission_settings_section_dropdown'),
        value: section,
        items: [
          for (final s in CommissionSettingsSection.values)
            DropdownMenuItem(value: s, child: Text(s.label(l10n))),
        ],
        onChanged: (s) {
          if (s != null && s != section) _go(context, s);
        },
      );
    }
    return SegmentedButton<CommissionSettingsSection>(
      key: const Key('commission_settings_section_switch'),
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: spacing.sm),
      ),
      segments: [
        for (final s in CommissionSettingsSection.values)
          ButtonSegment(value: s, label: Text(s.label(l10n))),
      ],
      selected: {section},
      onSelectionChanged: (selection) => _go(context, selection.first),
    );
  }
}

/// The frame every settings section shares: the filter row (the section's
/// [search], its own [actions] after the section switch, its [filters]), the
/// FR-018 note and the [body].
class CommissionSettingsScaffold extends StatelessWidget {
  const CommissionSettingsScaffold({
    super.key,
    required this.section,
    required this.body,
    this.search,
    this.actions = const [],
    this.filters = const [],
  });

  final CommissionSettingsSection section;
  final Widget body;
  final Widget? search;
  final List<Widget> actions;
  final List<Widget> filters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogFilterBar(
          search: search,
          actions: [
            CommissionSectionSwitch(section: section),
            ...actions,
          ],
          filters: filters,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.cardPadding),
          child: InfoBanner(
            key: const Key('commission_settings_note'),
            message: l10n.commissionSettingsNote,
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}
