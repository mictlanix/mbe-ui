import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_certificate_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_certificate.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_certificates_controller.dart';

part 'taxpayer_certificate_upload_controller.freezed.dart';
part 'taxpayer_certificate_upload_controller.g.dart';

/// Error codes for [TaxpayerCertificateUploadState.error]/`fieldErrors`,
/// localized in the UI layer.
abstract final class TaxpayerCertificateUploadErrorCode {
  static const certificateFileRequired = 'certificateFileRequired';
  static const keyFileRequired = 'keyFileRequired';
  static const keyPasswordRequired = 'keyPasswordRequired';
  static const uploadFailed = 'uploadFailed';
}

/// Form state for the Certificates section's "Agregar" upload dialog
/// (FR-021, FR-023). Scoped to one dialog instance — auto-disposed when the
/// dialog closes, so each opening starts from a blank form. [taxpayer] is
/// fixed to the open issuer's RFC (FR-021) — never a user-editable field.
@freezed
class TaxpayerCertificateUploadState with _$TaxpayerCertificateUploadState {
  const factory TaxpayerCertificateUploadState({
    required String taxpayer,
    List<int>? certificateBytes,
    @Default('') String certificateFileName,
    List<int>? keyBytes,
    @Default('') String keyFileName,
    @Default('') String keyPassword,
    @Default(false) bool submitting,
    TaxpayerCertificate? uploaded,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _TaxpayerCertificateUploadState;
}

/// Manages the certificate-upload dialog's form (FR-021, FR-022, FR-023).
@riverpod
class TaxpayerCertificateUploadController
    extends _$TaxpayerCertificateUploadController {
  @override
  TaxpayerCertificateUploadState build(String rfc) =>
      TaxpayerCertificateUploadState(taxpayer: rfc);

  TaxpayerCertificateUploadState _clearErrors(
    TaxpayerCertificateUploadState s,
  ) => s.copyWith(error: null, errorDetail: null, fieldErrors: const {});

  void certificateFilePicked(List<int> bytes, String fileName) => state =
      _clearErrors(
        state.copyWith(certificateBytes: bytes, certificateFileName: fileName),
      );

  void keyFilePicked(List<int> bytes, String fileName) => state = _clearErrors(
    state.copyWith(keyBytes: bytes, keyFileName: fileName),
  );

  void keyPasswordChanged(String v) =>
      state = _clearErrors(state.copyWith(keyPassword: v));

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (state.certificateBytes == null) {
      errors['certificate'] =
          TaxpayerCertificateUploadErrorCode.certificateFileRequired;
    }
    if (state.keyBytes == null) {
      errors['key'] = TaxpayerCertificateUploadErrorCode.keyFileRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.keyPassword)) {
      errors['keyPassword'] =
          TaxpayerCertificateUploadErrorCode.keyPasswordRequired;
    }
    return errors;
  }

  /// Registers the certificate (FR-021, FR-023). On success,
  /// [TaxpayerCertificateUploadState.uploaded] carries the new record for
  /// the dialog to pop itself with — this controller only ever talks to the
  /// repository, never `Navigator`. Refreshes the open issuer's Certificates
  /// section on success.
  Future<void> submit() async {
    final fieldErrors = _validate();
    if (fieldErrors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: fieldErrors,
        error: null,
        errorDetail: null,
      );
      return;
    }

    state = _clearErrors(state).copyWith(submitting: true);
    try {
      final uploaded = await ref
          .read(taxpayerCertificateRepositoryProvider)
          .upload(
            taxpayer: state.taxpayer,
            certificateBytes: state.certificateBytes!,
            keyBytes: state.keyBytes!,
            keyPassword: state.keyPassword,
          );
      ref.invalidate(taxpayerCertificatesControllerProvider(state.taxpayer));
      state = state.copyWith(submitting: false, uploaded: uploaded);
    } on AppError catch (e) {
      if (e is ValidationError) {
        state = state.copyWith(
          submitting: false,
          fieldErrors: _fieldErrorsFromServer(e),
        );
      } else {
        state = state.copyWith(
          submitting: false,
          error: TaxpayerCertificateUploadErrorCode.uploadFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }
}

Map<String, String> _fieldErrorsFromServer(ValidationError error) {
  final result = <String, String>{};
  for (final fieldError in error.errors) {
    final locKey = fieldError.loc.isNotEmpty ? fieldError.loc.last : 'error';
    result[locKey] = fieldError.msg;
  }
  return result;
}
