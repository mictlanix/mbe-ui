import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_recipients_list_controller.dart';

part 'taxpayer_recipient_form_controller.freezed.dart';
part 'taxpayer_recipient_form_controller.g.dart';

/// Error codes for [TaxpayerRecipientFormState.error]/`fieldErrors`,
/// localized in the UI layer.
abstract final class TaxpayerRecipientFormErrorCode {
  static const idRequired = 'idRequired';
  static const nameRequired = 'nameRequired';
  static const emailRequired = 'emailRequired';
  static const loadFailed = 'loadFailed';
  static const createFailed = 'createFailed';
  static const updateFailed = 'updateFailed';
  static const deleteFailed = 'deleteFailed';
  static const createPermissionDenied = 'createPermissionDenied';
  static const updatePermissionDenied = 'updatePermissionDenied';
  static const deletePermissionDenied = 'deletePermissionDenied';
}

/// Create/edit form state for a single taxpayer recipient.
/// [existingTaxpayerRecipientId] is `null` in create mode; once set (either
/// loaded for edit, or after a successful create) the id field becomes
/// immutable — mirroring the Users admin screen's `user_id_field` pattern
/// (research.md §9). [taxpayerRecipientId] holds the *editable* create-mode
/// input.
@freezed
class TaxpayerRecipientFormState with _$TaxpayerRecipientFormState {
  const factory TaxpayerRecipientFormState({
    String? existingTaxpayerRecipientId,
    @Default('') String taxpayerRecipientId,
    @Default('') String name,
    @Default('') String email,
    String? postalCode,
    @Default('') String postalCodeDisplayText,
    String? regime,
    @Default('') String regimeDisplayText,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _TaxpayerRecipientFormState;
}

/// Manages the create/edit taxpayer recipient form (FR-023, FR-024, FR-025).
@riverpod
class TaxpayerRecipientFormController
    extends _$TaxpayerRecipientFormController {
  @override
  TaxpayerRecipientFormState build() => const TaxpayerRecipientFormState();

  void taxpayerRecipientIdChanged(String v) => state = state.copyWith(
    taxpayerRecipientId: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void nameChanged(String v) => state = state.copyWith(
    name: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void emailChanged(String v) => state = state.copyWith(
    email: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void postalCodeSelected(String code, String displayText) => state = state
      .copyWith(postalCode: code, postalCodeDisplayText: displayText);

  void regimeSelected(String code, String displayText) =>
      state = state.copyWith(regime: code, regimeDisplayText: displayText);

  /// Loads an existing taxpayer recipient into the form for viewing/editing.
  Future<void> loadForEdit(String taxpayerRecipientId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final taxpayerRecipient = await ref
          .read(taxpayerRecipientRepositoryProvider)
          .get(taxpayerRecipientId: taxpayerRecipientId);
      state = TaxpayerRecipientFormState(
        existingTaxpayerRecipientId:
            taxpayerRecipient.taxpayerRecipientId,
        taxpayerRecipientId: taxpayerRecipient.taxpayerRecipientId,
        name: taxpayerRecipient.name,
        email: taxpayerRecipient.email,
        postalCode: taxpayerRecipient.postalCode?.code,
        postalCodeDisplayText: taxpayerRecipient.postalCode?.description ?? '',
        regime: taxpayerRecipient.regime?.code,
        regimeDisplayText: taxpayerRecipient.regime?.description ?? '',
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: TaxpayerRecipientFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  /// Client-side validation (FR-023, FR-024).
  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (state.existingTaxpayerRecipientId == null &&
        !CatalogFieldValidators.isRequiredNonEmpty(
          state.taxpayerRecipientId,
        )) {
      errors['taxpayerRecipientId'] = TaxpayerRecipientFormErrorCode.idRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.name)) {
      errors['name'] = TaxpayerRecipientFormErrorCode.nameRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.email)) {
      errors['email'] = TaxpayerRecipientFormErrorCode.emailRequired;
    }
    return errors;
  }

  /// Creates the taxpayer recipient (FR-023, FR-024). Re-checks the
  /// caller's `taxpayerRecipients` create privilege immediately before
  /// submitting. A duplicate tax id is surfaced via the server's validation
  /// response (FR-027), never silently overwritten.
  Future<void> submitCreate() async {
    final fieldErrors = _validate();
    if (fieldErrors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: fieldErrors,
        error: null,
        errorDetail: null,
      );
      return;
    }

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.taxpayerRecipients, AccessRight.create)) {
      state = state.copyWith(
        error: TaxpayerRecipientFormErrorCode.createPermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(
      submitting: true,
      error: null,
      errorDetail: null,
      fieldErrors: const {},
    );
    try {
      await ref
          .read(taxpayerRecipientRepositoryProvider)
          .create(
            taxpayerRecipientId: state.taxpayerRecipientId,
            email: state.email,
            name: state.name,
            postalCode: state.postalCode,
            regime: state.regime,
          );
      ref.invalidate(taxpayerRecipientsListControllerProvider);
      state = state.copyWith(submitting: false, saved: true);
    } on AppError catch (e) {
      if (e is ValidationError) {
        state = state.copyWith(
          submitting: false,
          fieldErrors: _fieldErrorsFromServer(e),
        );
      } else {
        state = state.copyWith(
          submitting: false,
          error: TaxpayerRecipientFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Saves edits to the loaded taxpayer recipient. No-ops if none has been
  /// loaded. The id itself is never sent (immutable).
  Future<void> submitUpdate() async {
    final taxpayerRecipientId = state.existingTaxpayerRecipientId;
    if (taxpayerRecipientId == null) return;

    final fieldErrors = _validate();
    if (fieldErrors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: fieldErrors,
        error: null,
        errorDetail: null,
      );
      return;
    }

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.taxpayerRecipients, AccessRight.update)) {
      state = state.copyWith(
        error: TaxpayerRecipientFormErrorCode.updatePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(
      submitting: true,
      error: null,
      errorDetail: null,
      fieldErrors: const {},
    );
    try {
      await ref
          .read(taxpayerRecipientRepositoryProvider)
          .update(
            taxpayerRecipientId: taxpayerRecipientId,
            name: state.name,
            email: state.email,
            postalCode: state.postalCode,
            regime: state.regime,
          );
      ref.invalidate(taxpayerRecipientsListControllerProvider);
      state = state.copyWith(submitting: false, saved: true);
    } on AppError catch (e) {
      if (e is ValidationError) {
        state = state.copyWith(
          submitting: false,
          fieldErrors: _fieldErrorsFromServer(e),
        );
      } else {
        state = state.copyWith(
          submitting: false,
          error: TaxpayerRecipientFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Deletes the loaded taxpayer recipient. No-ops if none has been loaded.
  Future<void> delete() async {
    final taxpayerRecipientId = state.existingTaxpayerRecipientId;
    if (taxpayerRecipientId == null) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.taxpayerRecipients, AccessRight.delete)) {
      state = state.copyWith(
        error: TaxpayerRecipientFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref
          .read(taxpayerRecipientRepositoryProvider)
          .delete(taxpayerRecipientId: taxpayerRecipientId);
      ref.invalidate(taxpayerRecipientsListControllerProvider);
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: TaxpayerRecipientFormErrorCode.deleteFailed,
        errorDetail: e.serverMessage,
      );
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
