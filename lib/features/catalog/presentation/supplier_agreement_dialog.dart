import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/record_form_actions.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_agreement.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_agreement_dialog_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Opens the agreement dialog (spec 050 FR-013): add when [existing] is
/// `null`, edit otherwise (with Delete). Saving or deleting invalidates the
/// supplier's agreements list itself and closes the dialog.
Future<void> showSupplierAgreementDialog(
  BuildContext context, {
  required int supplierId,
  SupplierAgreement? existing,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) =>
        _SupplierAgreementDialog(supplierId: supplierId, existing: existing),
  );
}

class _SupplierAgreementDialog extends ConsumerWidget {
  const _SupplierAgreementDialog({
    required this.supplierId,
    required this.existing,
  });

  final int supplierId;
  final SupplierAgreement? existing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = supplierAgreementDialogControllerProvider(
      supplierId,
      existing,
    );
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final current = existing;

    if (state.done) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop();
      });
    }

    final fieldsEnabled = !state.submitting;

    Future<void> pickDate(
      DateTime? initial,
      void Function(DateTime) onPicked,
    ) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: initial ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );
      if (picked != null) onPicked(picked);
    }

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                current == null
                    ? l10n.newAgreementDialogTitle
                    : l10n.editAgreementDialogTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // Outside the grid: inserting a child there would shift the
              // fields' positions and drop what the user entered.
              if (state.error != null) ...[
                ErrorBanner(
                  error: AppError.server(
                    message:
                        state.errorDetail ??
                        (state.error ==
                                SupplierAgreementDialogErrorCode.deleteFailed
                            ? l10n.agreementDeleteFailedError
                            : l10n.agreementSaveFailedError),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ResponsiveFormGrid(
                maxColumns: 2,
                children: [
                  FormGridChild(
                    InkWell(
                      key: const Key('agreement_start_field'),
                      onTap: fieldsEnabled
                          ? () => pickDate(state.start, controller.startChanged)
                          : null,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.supplierAgreementColumnStart,
                          errorText: state.fieldErrors['start'],
                        ),
                        child: Text(fmt.display.date(state.start)),
                      ),
                    ),
                  ),
                  FormGridChild(
                    InkWell(
                      key: const Key('agreement_end_field'),
                      onTap: fieldsEnabled
                          ? () => pickDate(
                              state.end ?? state.start,
                              controller.endChanged,
                            )
                          : null,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.supplierAgreementColumnEnd,
                          errorText: state.endBeforeStart
                              ? l10n.supplierAgreementEndBeforeStartError
                              : state.fieldErrors['end'],
                        ),
                        child: Text(fmt.display.date(state.end)),
                      ),
                    ),
                  ),
                  FormGridChild(
                    span: FormGridSpan.full,
                    TextFormField(
                      key: const Key('agreement_comment_field'),
                      initialValue: state.comment,
                      enabled: fieldsEnabled,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: l10n.supplierAgreementColumnNotes,
                        errorText:
                            state.comment.length >
                                supplierAgreementCommentMaxLength
                            ? l10n.agreementCommentTooLongError(
                                supplierAgreementCommentMaxLength,
                              )
                            : state.fieldErrors['comment'],
                      ),
                      onChanged: controller.commentChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Destructive action furthest from the primary one.
                  if (current != null)
                    OutlinedButton(
                      key: const Key('agreement_delete_button'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      onPressed: fieldsEnabled
                          ? () async {
                              final confirmed =
                                  await showRecordDeleteConfirmation(
                                    context,
                                    RecordDeleteConfirmation(
                                      title: l10n.deleteAgreementConfirmTitle,
                                      message: l10n
                                          .deleteAgreementConfirmMessage(
                                            fmt.display.date(current.start),
                                            fmt.display.date(current.end),
                                          ),
                                      confirmLabel: l10n.deleteButton,
                                      cancelLabel: l10n.cancelButton,
                                      confirmKey: const Key(
                                        'confirm_delete_agreement_button',
                                      ),
                                    ),
                                  );
                              if (confirmed == true) controller.delete();
                            }
                          : null,
                      child: Text(l10n.deleteAgreementButton),
                    ),
                  const Spacer(),
                  TextButton(
                    key: const Key('agreement_cancel_button'),
                    onPressed: fieldsEnabled
                        ? () => Navigator.of(context).pop()
                        : null,
                    child: Text(l10n.cancelButton),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const Key('agreement_save_button'),
                    onPressed: state.canSubmit ? controller.submit : null,
                    child: state.submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.saveButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
