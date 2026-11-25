import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/participation_form_controller.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/settings_panel.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Opens the participation panel: new when [participation] is `null`,
/// otherwise to view ([forceReadOnly], a row click) or edit.
Future<void> showCommissionParticipationPanel(
  BuildContext context, {
  CommissionParticipation? participation,
  bool forceReadOnly = false,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showCommissionSettingsPanel(
    context,
    title: participation == null
        ? l10n.commissionNewParticipationTitle
        : (forceReadOnly
              ? l10n.commissionViewParticipationTitle
              : l10n.commissionEditParticipationTitle),
    form: CommissionParticipationForm(
      participation: participation,
      forceReadOnly: forceReadOnly,
    ),
    isDirty: (c) => c
        .read(
          commissionParticipationFormControllerProvider(participation).notifier,
        )
        .isDirty,
  );
}

/// The one field of a participation type: its name.
class CommissionParticipationForm extends ConsumerWidget {
  const CommissionParticipationForm({
    super.key,
    this.participation,
    this.forceReadOnly = false,
  });

  final CommissionParticipation? participation;
  final bool forceReadOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final provider = commissionParticipationFormControllerProvider(
      participation,
    );
    final form = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return CommissionSettingsPanel(
      keyPrefix: 'commission_participation',
      isEdit: participation != null,
      forceReadOnly: forceReadOnly,
      submitting: form.submitting,
      error: form.error,
      onSave: controller.save,
      onDelete: controller.delete,
      deleteTitle: l10n.commissionDeleteParticipationTitle,
      deleteMessage: l10n.commissionDeleteConfirmBody(
        participation?.name ?? '',
      ),
      fields: (enabled) => [
        TextFormField(
          key: const Key('commission_participation_name_field'),
          initialValue: form.name,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: l10n.nameLabel,
            errorText: form.nameRequired ? l10n.commissionNameRequired : null,
          ),
          onChanged: controller.nameChanged,
        ),
      ],
    );
  }
}
