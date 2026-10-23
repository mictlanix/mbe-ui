import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/domain/entities/bank_account.dart';
import 'package:mbe_ui/features/catalog/presentation/bank_account_inline_create_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Opens the "new bank account" dialog (FR-006) and returns the created
/// [BankAccount], or `null` if the user cancelled. Mirrors
/// `showContactInlineCreateDialog`: the caller links the returned account to
/// the supplier itself, and a later failure does NOT roll the account back.
Future<BankAccount?> showBankAccountInlineCreateDialog(BuildContext context) {
  return showDialog<BankAccount>(
    context: context,
    builder: (_) => const _BankAccountInlineCreateDialog(),
  );
}

class _BankAccountInlineCreateDialog extends ConsumerWidget {
  const _BankAccountInlineCreateDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bankAccountInlineCreateControllerProvider);
    final controller = ref.read(
      bankAccountInlineCreateControllerProvider.notifier,
    );
    final l10n = AppLocalizations.of(context)!;

    if (state.created != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop(state.created);
      });
    }

    final fieldsEnabled = !state.submitting;

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
                l10n.newBankAccountDialogTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // Outside the grid: inserting a child there would shift the
              // fields' positions and drop what the user typed.
              if (state.error != null) ...[
                ErrorBanner(error: AppError.server(message: state.errorDetail)),
                const SizedBox(height: 16),
              ],
              ResponsiveFormGrid(
                maxColumns: 2,
                children: [
                  FormGridChild(
                    span: FormGridSpan.full,
                    TextFormField(
                      key: const Key('bank_account_bank_name_field'),
                      enabled: fieldsEnabled,
                      decoration: InputDecoration(
                        labelText: l10n.bankAccountBankNameLabel,
                        errorText: _localizeFieldError(
                          l10n,
                          state.fieldErrors,
                          'bank_name',
                        ),
                      ),
                      onChanged: controller.bankNameChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('bank_account_number_field'),
                      enabled: fieldsEnabled,
                      decoration: InputDecoration(
                        labelText: l10n.bankAccountNumberLabel,
                        errorText: _localizeFieldError(
                          l10n,
                          state.fieldErrors,
                          'account_number',
                        ),
                      ),
                      onChanged: controller.accountNumberChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('bank_account_reference_field'),
                      enabled: fieldsEnabled,
                      decoration: InputDecoration(
                        labelText: l10n.bankAccountReferenceLabel,
                        errorText: _localizeFieldError(
                          l10n,
                          state.fieldErrors,
                          'reference',
                        ),
                      ),
                      onChanged: controller.referenceChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('bank_account_routing_field'),
                      enabled: fieldsEnabled,
                      decoration: InputDecoration(
                        labelText: l10n.bankAccountRoutingLabel,
                        errorText: _localizeFieldError(
                          l10n,
                          state.fieldErrors,
                          'routing_number',
                        ),
                      ),
                      onChanged: controller.routingNumberChanged,
                    ),
                  ),
                  FormGridChild(
                    span: FormGridSpan.full,
                    TextFormField(
                      key: const Key('bank_account_comment_field'),
                      enabled: fieldsEnabled,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: l10n.commentLabel,
                        errorText: _localizeFieldError(
                          l10n,
                          state.fieldErrors,
                          'comment',
                        ),
                      ),
                      onChanged: controller.commentChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: fieldsEnabled
                        ? () => Navigator.of(context).pop()
                        : null,
                    child: Text(l10n.cancelButton),
                  ),
                  FilledButton(
                    key: const Key('bank_account_save_button'),
                    onPressed: fieldsEnabled ? controller.submit : null,
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

  /// Maps this dialog's own codes to copy; anything else is a server message
  /// already in the user's language, passed through unchanged.
  String? _localizeFieldError(
    AppLocalizations l10n,
    Map<String, String> errors,
    String field,
  ) => switch (errors[field]) {
    null => null,
    BankAccountInlineCreateErrorCode.required => l10n.fieldRequired,
    BankAccountInlineCreateErrorCode.tooLong =>
      l10n.bankAccountFieldTooLongError(BankAccountFieldLimit.byField[field]!),
    final other => other,
  };
}
