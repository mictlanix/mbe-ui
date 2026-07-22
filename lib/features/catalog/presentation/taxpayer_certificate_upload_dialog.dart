import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_certificate.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_certificate_upload_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Opens the "Agregar" (register certificate) dialog for [rfc]'s
/// Certificates section (FR-021), and returns the created
/// [TaxpayerCertificate], or `null` if the user cancelled. The section
/// itself already refreshes via the controller invalidating its own
/// provider on success (spec 014 inline-address-create precedent).
Future<TaxpayerCertificate?> showTaxpayerCertificateUploadDialog(
  BuildContext context, {
  required String rfc,
}) {
  return showDialog<TaxpayerCertificate>(
    context: context,
    builder: (_) => _TaxpayerCertificateUploadDialog(rfc: rfc),
  );
}

class _TaxpayerCertificateUploadDialog extends ConsumerWidget {
  const _TaxpayerCertificateUploadDialog({required this.rfc});

  final String rfc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taxpayerCertificateUploadControllerProvider(rfc));
    final controller = ref.read(
      taxpayerCertificateUploadControllerProvider(rfc).notifier,
    );
    final l10n = AppLocalizations.of(context)!;

    if (state.uploaded != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop(state.uploaded);
      });
    }

    final fieldsEnabled = !state.submitting;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.newCertificateDialogTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ResponsiveFormGrid(
                maxColumns: 1,
                children: [
                  if (state.error != null)
                    FormGridChild(
                      span: FormGridSpan.full,
                      ErrorBanner(
                        error: AppError.validation([
                          FieldError(
                            loc: const [],
                            msg: _localizeFormError(l10n, state.error!),
                            type: 'error',
                          ),
                          if (state.errorDetail != null)
                            FieldError(
                              loc: const [],
                              msg: state.errorDetail!,
                              type: 'error',
                            ),
                        ]),
                      ),
                    ),
                  FormGridChild(
                    span: FormGridSpan.full,
                    _FilePickerField(
                      key: const Key('certificate_file_field'),
                      label: l10n.certificateFileLabel,
                      fileName: state.certificateFileName,
                      errorText: _localizeFieldError(
                        l10n,
                        state.fieldErrors['certificate'],
                      ),
                      enabled: fieldsEnabled,
                      allowedExtensions: const ['cer'],
                      chooseFileLabel: l10n.chooseFileButton,
                      onPicked: controller.certificateFilePicked,
                    ),
                  ),
                  FormGridChild(
                    span: FormGridSpan.full,
                    _FilePickerField(
                      key: const Key('key_file_field'),
                      label: l10n.keyFileLabel,
                      fileName: state.keyFileName,
                      errorText: _localizeFieldError(
                        l10n,
                        state.fieldErrors['key'],
                      ),
                      enabled: fieldsEnabled,
                      allowedExtensions: const ['key'],
                      chooseFileLabel: l10n.chooseFileButton,
                      onPicked: controller.keyFilePicked,
                    ),
                  ),
                  FormGridChild(
                    span: FormGridSpan.full,
                    TextFormField(
                      key: const Key('key_password_field'),
                      decoration: InputDecoration(
                        labelText: l10n.keyPasswordLabel,
                        errorText: _localizeFieldError(
                          l10n,
                          state.fieldErrors['keyPassword'],
                        ),
                      ),
                      obscureText: true,
                      enabled: fieldsEnabled,
                      onChanged: controller.keyPasswordChanged,
                    ),
                  ),
                  FormGridChild(
                    span: FormGridSpan.full,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: state.submitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text(l10n.cancelButton),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          key: const Key('upload_certificate_button'),
                          onPressed: state.submitting
                              ? null
                              : controller.submit,
                          child: state.submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.uploadCertificateButton),
                        ),
                      ],
                    ),
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

/// A file-selection field: a read-only text display of the chosen file's
/// name plus a "Choose file" button that opens the platform file picker
/// restricted to [allowedExtensions] and reads the bytes eagerly
/// (`withData: true`) so the same code path works on web (research §8).
class _FilePickerField extends StatelessWidget {
  const _FilePickerField({
    super.key,
    required this.label,
    required this.fileName,
    required this.errorText,
    required this.enabled,
    required this.allowedExtensions,
    required this.chooseFileLabel,
    required this.onPicked,
  });

  final String label;
  final String fileName;
  final String? errorText;
  final bool enabled;
  final List<String> allowedExtensions;
  final String chooseFileLabel;
  final void Function(List<int> bytes, String fileName) onPicked;

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );
    final file = result?.files.singleOrNull;
    final bytes = file?.bytes;
    if (file != null && bytes != null) onPicked(bytes, file.name);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            readOnly: true,
            initialValue: fileName,
            decoration: InputDecoration(
              labelText: label,
              errorText: errorText,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: OutlinedButton(
            onPressed: enabled ? _pick : null,
            child: Text(chooseFileLabel),
          ),
        ),
      ],
    );
  }
}

String _localizeFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case TaxpayerCertificateUploadErrorCode.uploadFailed:
      return l10n.certificateUploadFailedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case TaxpayerCertificateUploadErrorCode.certificateFileRequired:
      return l10n.certificateFileRequiredError;
    case TaxpayerCertificateUploadErrorCode.keyFileRequired:
      return l10n.keyFileRequiredError;
    case TaxpayerCertificateUploadErrorCode.keyPasswordRequired:
      return l10n.keyPasswordRequiredError;
    default:
      return code;
  }
}
