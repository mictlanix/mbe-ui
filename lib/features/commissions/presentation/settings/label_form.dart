import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/formatting/percent_input.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/label_form_controller.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/settings_panel.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Opens the label panel: new when [label] is `null`, otherwise to view
/// ([forceReadOnly], a row click) or edit.
Future<void> showCommissionLabelPanel(
  BuildContext context, {
  CommissionLabel? label,
  bool forceReadOnly = false,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showCommissionSettingsPanel(
    context,
    title: label == null
        ? l10n.commissionNewLabelTitle
        : (forceReadOnly
              ? l10n.commissionViewLabelTitle
              : l10n.commissionEditLabelTitle),
    form: CommissionLabelForm(label: label, forceReadOnly: forceReadOnly),
    isDirty: (c) =>
        c.read(commissionLabelFormControllerProvider(label).notifier).isDirty,
  );
}

/// Name, rate (a percentage, 0 to 100) and comment of a commission label.
class CommissionLabelForm extends ConsumerWidget {
  const CommissionLabelForm({
    super.key,
    this.label,
    this.forceReadOnly = false,
  });

  final CommissionLabel? label;
  final bool forceReadOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final provider = commissionLabelFormControllerProvider(label);
    final form = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return CommissionSettingsPanel(
      keyPrefix: 'commission_label',
      isEdit: label != null,
      forceReadOnly: forceReadOnly,
      submitting: form.submitting,
      error: form.error,
      onSave: controller.save,
      onDelete: controller.delete,
      deleteTitle: l10n.commissionDeleteLabelTitle,
      deleteMessage: l10n.commissionDeleteConfirmBody(label?.name ?? ''),
      fields: (enabled) => [
        TextFormField(
          key: const Key('commission_label_name_field'),
          initialValue: form.name,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: l10n.nameLabel,
            errorText: form.nameRequired ? l10n.commissionNameRequired : null,
          ),
          onChanged: controller.nameChanged,
        ),
        TextFormField(
          key: const Key('commission_label_rate_field'),
          initialValue: form.rate,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.commissionFieldRate,
            errorText: switch (form.rateError) {
              null => null,
              PercentInputError.invalid => l10n.commissionPercentInvalid,
              PercentInputError.outOfRange => l10n.commissionPercentOutOfRange,
              PercentInputError.tooPrecise => l10n.commissionPercentTooPrecise,
            },
          ),
          onChanged: controller.rateChanged,
        ),
        TextFormField(
          key: const Key('commission_label_comment_field'),
          initialValue: form.comment,
          enabled: enabled,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n.commissionFieldComment),
          onChanged: controller.commentChanged,
        ),
      ],
    );
  }
}
