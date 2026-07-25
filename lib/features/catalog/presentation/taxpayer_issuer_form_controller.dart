import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide ValidationError;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_issuers_list_controller.dart';

part 'taxpayer_issuer_form_controller.freezed.dart';
part 'taxpayer_issuer_form_controller.g.dart';

/// Error codes for [TaxpayerIssuerFormState.error]/`fieldErrors`, localized
/// in the UI layer (mirrors `WarehouseFormErrorCode`).
abstract final class TaxpayerIssuerFormErrorCode {
  static const rfcRequired = 'rfcRequired';
  static const nameRequired = 'nameRequired';
  static const regimeRequired = 'regimeRequired';
  static const loadFailed = 'loadFailed';
  static const createFailed = 'createFailed';
  static const updateFailed = 'updateFailed';
  static const deleteFailed = 'deleteFailed';
  static const createPermissionDenied = 'createPermissionDenied';
  static const updatePermissionDenied = 'updatePermissionDenied';
  static const deletePermissionDenied = 'deletePermissionDenied';
}

/// Create/edit form state for a single taxpayer issuer. [rfc] is entered by
/// the user on create and, once [isEdit] (a record has been loaded), is
/// **immutable** — the screen renders it disabled (FR-012).
@freezed
class TaxpayerIssuerFormState with _$TaxpayerIssuerFormState {
  const factory TaxpayerIssuerFormState({
    @Default(false) bool isEdit,
    @Default('') String rfc,
    @Default('') String name,
    @Default('') String regime,
    @Default('') String regimeDisplayText,
    @Default(FiscalCertificationProvider.number0) FiscalCertificationProvider provider,
    @Default('') String postalCode,
    @Default('') String postalCodeDisplayText,
    @Default('') String comment,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _TaxpayerIssuerFormState;
}

/// Manages the create/edit taxpayer issuer form (FR-011, FR-012, FR-015,
/// FR-016).
@riverpod
class TaxpayerIssuerFormController extends _$TaxpayerIssuerFormController {
  @override
  TaxpayerIssuerFormState build() => const TaxpayerIssuerFormState();

  void rfcChanged(String v) => state = _clearErrors(state.copyWith(rfc: v));

  void nameChanged(String v) => state = _clearErrors(state.copyWith(name: v));

  void regimeSelected(String code, String displayText) => state = _clearErrors(
    state.copyWith(regime: code, regimeDisplayText: displayText),
  );

  void providerChanged(FiscalCertificationProvider v) =>
      state = state.copyWith(provider: v);

  void postalCodeSelected(String code, String displayText) =>
      state = state.copyWith(postalCode: code, postalCodeDisplayText: displayText);

  void commentChanged(String v) => state = state.copyWith(comment: v);

  TaxpayerIssuerFormState _clearErrors(TaxpayerIssuerFormState s) =>
      s.copyWith(error: null, errorDetail: null, fieldErrors: const {});

  /// Loads an existing issuer into the form for viewing/editing.
  Future<void> loadForEdit(String rfc) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final issuer = await ref
          .read(taxpayerIssuerRepositoryProvider)
          .getDetail(rfc);
      state = TaxpayerIssuerFormState(
        isEdit: true,
        rfc: issuer.rfc,
        name: issuer.name,
        regime: issuer.regime?.code ?? '',
        regimeDisplayText: issuer.regime?.description ?? issuer.regime?.code ?? '',
        provider: issuer.provider,
        postalCode: issuer.postalCode?.code ?? '',
        postalCodeDisplayText:
            issuer.postalCode?.description ?? issuer.postalCode?.code ?? '',
        comment: issuer.comment ?? '',
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: TaxpayerIssuerFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.rfc)) {
      errors['rfc'] = TaxpayerIssuerFormErrorCode.rfcRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.name)) {
      errors['name'] = TaxpayerIssuerFormErrorCode.nameRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.regime)) {
      errors['regime'] = TaxpayerIssuerFormErrorCode.regimeRequired;
    }
    return errors;
  }

  void _invalidateCaches() {
    ref.invalidate(taxpayerIssuersListControllerProvider);
  }

  /// Registers the issuer (FR-011). Re-checks the caller's `taxpayers`
  /// create privilege immediately before submitting, since it may have been
  /// revoked since the form was opened.
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
        .can(SystemObject.taxpayers, AccessRight.create)) {
      state = state.copyWith(
        error: TaxpayerIssuerFormErrorCode.createPermissionDenied,
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
          .read(taxpayerIssuerRepositoryProvider)
          .create(
            rfc: state.rfc,
            name: state.name,
            regime: state.regime,
            provider: state.provider,
            postalCode: state.postalCode.isEmpty ? null : state.postalCode,
            comment: state.comment.isEmpty ? null : state.comment,
          );
      _invalidateCaches();
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
          error: TaxpayerIssuerFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Saves edits to the loaded issuer. No-ops if none has been loaded. The
  /// RFC is never sent — it is the path parameter, not a field (FR-012).
  Future<void> submitUpdate() async {
    if (!state.isEdit) return;

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
        .can(SystemObject.taxpayers, AccessRight.update)) {
      state = state.copyWith(
        error: TaxpayerIssuerFormErrorCode.updatePermissionDenied,
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
          .read(taxpayerIssuerRepositoryProvider)
          .update(
            rfc: state.rfc,
            name: state.name,
            regime: state.regime,
            provider: state.provider,
            postalCode: state.postalCode,
            comment: state.comment,
          );
      _invalidateCaches();
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
          error: TaxpayerIssuerFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Deletes the loaded issuer (FR-016). No-ops if none has been loaded. A
  /// server rejection (e.g. still referenced by a certificate) is surfaced
  /// via `error`/`errorDetail`, leaving the record in place.
  Future<void> delete() async {
    if (!state.isEdit) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.taxpayers, AccessRight.delete)) {
      state = state.copyWith(
        error: TaxpayerIssuerFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref.read(taxpayerIssuerRepositoryProvider).delete(state.rfc);
      _invalidateCaches();
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: TaxpayerIssuerFormErrorCode.deleteFailed,
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
