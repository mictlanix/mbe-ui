import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/agent_form_controller.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/settings_panel.dart';
import 'package:mbe_ui/features/commissions/presentation/shared/commission_lookups.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

String commissionSchemeLabel(AppLocalizations l10n, CommissionScheme scheme) =>
    switch (scheme) {
      CommissionScheme.fullyPaid => l10n.commissionSchemeFullyPaid,
      CommissionScheme.partialPayments => l10n.commissionSchemePartialPayments,
    };

/// Opens the agent panel: new when [agent] is `null`, otherwise to view
/// ([forceReadOnly], a row click) or edit.
Future<void> showCommissionAgentPanel(
  BuildContext context, {
  CommissionAgent? agent,
  bool forceReadOnly = false,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showCommissionSettingsPanel(
    context,
    title: agent == null
        ? l10n.commissionNewAgentTitle
        : (forceReadOnly
              ? l10n.commissionViewAgentTitle
              : l10n.commissionEditAgentTitle),
    form: CommissionAgentForm(agent: agent, forceReadOnly: forceReadOnly),
    isDirty: (c) =>
        c.read(commissionAgentFormControllerProvider(agent).notifier).isDirty,
  );
}

/// An agent's employee (picked once, fixed afterwards) and scheme.
class CommissionAgentForm extends ConsumerWidget {
  const CommissionAgentForm({
    super.key,
    this.agent,
    this.forceReadOnly = false,
  });

  final CommissionAgent? agent;
  final bool forceReadOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = commissionAgentFormControllerProvider(agent);
    final form = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return CommissionSettingsPanel(
      keyPrefix: 'commission_agent',
      isEdit: agent != null,
      forceReadOnly: forceReadOnly,
      submitting: form.submitting,
      error: form.error,
      onSave: controller.save,
      onDelete: controller.delete,
      deleteTitle: l10n.commissionDeleteAgentTitle,
      deleteMessage: l10n.commissionDeleteConfirmBody(agent?.name ?? ''),
      fields: (enabled) => [
        CatalogEntityPicker<EmployeeListItem>(
          key: const Key('commission_agent_employee_field'),
          label: l10n.commissionFieldEmployee,
          // Fixed once the agent exists.
          enabled: agent == null && enabled,
          initialDisplayText: agent?.name,
          errorText: form.employeeRequired
              ? l10n.commissionEmployeeRequired
              : null,
          displayStringForOption: (e) => e.fullName,
          optionsBuilder: (query) async {
            final result = await ref
                .read(employeeRepositoryProvider)
                .list(search: query.isEmpty ? null : query, salesPerson: true);
            final current = await ref.read(commissionAgentsProvider.future);
            final taken = {for (final a in current) a.employeeId};
            return result.items.where((e) => !taken.contains(e.employeeId));
          },
          onSelected: (e) => controller.employeeChosen(e.employeeId),
        ),
        Text(l10n.commissionFieldScheme, style: theme.textTheme.labelLarge),
        RadioGroup<CommissionScheme>(
          groupValue: form.scheme,
          onChanged: (value) {
            if (enabled && value != null) controller.schemeChanged(value);
          },
          child: Column(
            children: [
              for (final scheme in CommissionScheme.values)
                RadioListTile<CommissionScheme>(
                  key: Key('commission_agent_scheme_${scheme.name}'),
                  value: scheme,
                  enabled: enabled,
                  contentPadding: EdgeInsets.zero,
                  title: Text(commissionSchemeLabel(l10n, scheme)),
                ),
            ],
          ),
        ),
        Text(
          l10n.commissionSchemeChangeNote,
          key: const Key('commission_agent_scheme_note'),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
