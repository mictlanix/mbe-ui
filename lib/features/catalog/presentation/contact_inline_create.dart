import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/presentation/contact_inline_create_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Opens the "new contact" dialog (FR-031) and returns the created [Contact],
/// or `null` if the user cancelled. Mirrors
/// `showAddressInlineCreateDialog`: the caller links the returned contact to
/// the customer itself, and a later failure does NOT roll the contact back.
Future<Contact?> showContactInlineCreateDialog(BuildContext context) {
  return showDialog<Contact>(
    context: context,
    builder: (_) => const _ContactInlineCreateDialog(),
  );
}

class _ContactInlineCreateDialog extends ConsumerWidget {
  const _ContactInlineCreateDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(contactInlineCreateControllerProvider);
    final controller = ref.read(contactInlineCreateControllerProvider.notifier);
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
                l10n.newContactDialogTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ResponsiveFormGrid(
                maxColumns: 2,
                children: [
                  if (state.error != null)
                    FormGridChild(
                      span: FormGridSpan.full,
                      ErrorBanner(
                        error: AppError.server(message: state.errorDetail),
                      ),
                    ),
                  FormGridChild(
                    span: FormGridSpan.full,
                    TextFormField(
                      key: const Key('contact_name_field'),
                      enabled: fieldsEnabled,
                      decoration: InputDecoration(
                        labelText: l10n.contactNameLabel,
                        errorText: _localizeFieldError(l10n, state.fieldErrors['name']),
                      ),
                      onChanged: controller.nameChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('contact_mobile_field'),
                      enabled: fieldsEnabled,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: l10n.contactMobileLabel,
                        errorText: _localizeFieldError(
                          l10n,
                          state.fieldErrors['mobile'],
                        ),
                      ),
                      onChanged: controller.mobileChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('contact_phone_field'),
                      enabled: fieldsEnabled,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: l10n.contactPhoneLabel,
                        errorText: _localizeFieldError(
                          l10n,
                          state.fieldErrors['phone'],
                        ),
                      ),
                      onChanged: controller.phoneChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('contact_job_title_field'),
                      enabled: fieldsEnabled,
                      decoration: InputDecoration(labelText: l10n.contactJobTitleLabel),
                      onChanged: controller.jobTitleChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('contact_email_field'),
                      enabled: fieldsEnabled,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l10n.contactEmailLabel,
                        errorText: _localizeFieldError(
                          l10n,
                          state.fieldErrors['email'],
                        ),
                      ),
                      onChanged: controller.emailChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: fieldsEnabled ? () => Navigator.of(context).pop() : null,
                    child: Text(l10n.cancelButton),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const Key('contact_save_button'),
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
  String? _localizeFieldError(AppLocalizations l10n, String? code) => switch (code) {
    null => null,
    ContactInlineCreateErrorCode.nameRequired => l10n.fieldRequired,
    ContactInlineCreateErrorCode.contactMethodRequired => l10n.contactMethodRequired,
    _ => code,
  };
}
