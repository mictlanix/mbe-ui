import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/widgets/info_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_period_actions.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/period_dialogs.dart';
import 'package:mbe_ui/features/commissions/presentation/shared/commission_label_dropdown.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "Asignar…" on an unlabelled line of an open month (spec 078 FR-016a): the
/// line's product, read-only, and a label to give it. Assigning is a PUT
/// (Update, the caller's gate) and recomputes the month. Answers like the
/// period prompts: the refusal in the result, or `null` when the user backed
/// out; the screen shows a refusal in its banner.
Future<CommissionActionResult?> showAssignLabelDialog(
  BuildContext context, {
  required CommissionLine line,
}) => showResponsiveDialog<CommissionActionResult>(
  context,
  builder: (_) => _AssignLabelDialog(line: line),
);

class _AssignLabelDialog extends ConsumerStatefulWidget {
  const _AssignLabelDialog({required this.line});

  final CommissionLine line;

  @override
  ConsumerState<_AssignLabelDialog> createState() => _AssignLabelDialogState();
}

class _AssignLabelDialogState extends ConsumerState<_AssignLabelDialog> {
  int? _labelId;
  bool _busy = false;

  Future<void> _submit() async {
    final labelId = _labelId;
    if (_busy || labelId == null) return;
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final error = await ref
        .read(commissionPeriodActionsProvider.notifier)
        .assignLabel(widget.line.productId, labelId);
    if (!mounted) return;
    navigator.pop((error: error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return ResponsiveDialog(
      key: const Key('commission_assign_label_dialog'),
      title: l10n.commissionProductLabelTitle,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          TextFormField(
            key: const Key('commission_assign_label_product'),
            enabled: false,
            initialValue: widget.line.productName,
            decoration: InputDecoration(
              labelText: l10n.commissionProductLabelProduct,
            ),
          ),
          CommissionLabelDropdown(
            key: const Key('commission_assign_label_label'),
            label: l10n.commissionProductLabelLabel,
            value: _labelId,
            enabled: !_busy,
            onChanged: (id) => setState(() => _labelId = id),
          ),
          InfoBanner(
            key: const Key('commission_assign_label_note'),
            message: l10n.commissionSettingsNote,
          ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        key: const Key('commission_assign_label_cancel'),
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('commission_assign_label_submit'),
        label: l10n.commissionProductLabelAssign,
        busy: _busy,
        onPressed: _labelId == null ? null : _submit,
      ),
    );
  }
}
