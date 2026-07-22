import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/cash_drawer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/presentation/cash_drawers_list_controller.dart';

part 'cash_drawer_form_controller.freezed.dart';
part 'cash_drawer_form_controller.g.dart';

/// Error codes for [CashDrawerFormState.error]/`fieldErrors`, localized in
/// the UI layer (mirrors `VehicleOperatorFormErrorCode`).
abstract final class CashDrawerFormErrorCode {
  static const facilityRequired = 'facilityRequired';
  static const codeRequired = 'codeRequired';
  static const nameRequired = 'nameRequired';
  static const loadFailed = 'loadFailed';
  static const createFailed = 'createFailed';
  static const updateFailed = 'updateFailed';
  static const deleteFailed = 'deleteFailed';
  static const createPermissionDenied = 'createPermissionDenied';
  static const updatePermissionDenied = 'updatePermissionDenied';
  static const deletePermissionDenied = 'deletePermissionDenied';
}

/// Create/edit form state for a single cashDrawer. [cashDrawerId] is `null` in
/// create mode.
@freezed
class CashDrawerFormState with _$CashDrawerFormState {
  const factory CashDrawerFormState({
    int? cashDrawerId,
    int? facilityId,
    @Default('') String facilityDisplayText,
    @Default('') String code,
    @Default('') String name,
    @Default('') String comment,
    @Default(EntityStatus.active) EntityStatus status,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _CashDrawerFormState;
}

/// Manages the create/edit cash drawer form (FR-016, FR-017, FR-018).
@riverpod
class CashDrawerFormController extends _$CashDrawerFormController {
  @override
  CashDrawerFormState build() => const CashDrawerFormState();

  void facilitySelected(int facilityId, String facilityName) =>
      state = state.copyWith(
        facilityId: facilityId,
        facilityDisplayText: facilityName,
        error: null,
        errorDetail: null,
        fieldErrors: const {},
      );

  void codeChanged(String v) => state = state.copyWith(
    code: v,
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

  void commentChanged(String v) => state = state.copyWith(comment: v);

  void statusChanged(EntityStatus v) => state = state.copyWith(status: v);

  /// Loads an existing cash drawer into the form for viewing/editing.
  Future<void> loadForEdit(int cashDrawerId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final cashDrawer = await ref
          .read(cashDrawerRepositoryProvider)
          .get(cashDrawerId: cashDrawerId);
      state = CashDrawerFormState(
        cashDrawerId: cashDrawer.cashDrawerId,
        facilityId: cashDrawer.facilityId,
        facilityDisplayText: cashDrawer.facilityName,
        code: cashDrawer.code,
        name: cashDrawer.name,
        comment: cashDrawer.comment ?? '',
        status: cashDrawer.status,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: CashDrawerFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (state.facilityId == null) {
      errors['facility'] = CashDrawerFormErrorCode.facilityRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.code)) {
      errors['code'] = CashDrawerFormErrorCode.codeRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.name)) {
      errors['name'] = CashDrawerFormErrorCode.nameRequired;
    }
    return errors;
  }

  void _invalidateCaches() {
    ref.invalidate(cashDrawersListControllerProvider);
  }

  /// Creates the cash drawer (FR-016, FR-017). Re-checks the caller's
  /// `cashDrawers` create privilege immediately before submitting, since it
  /// may have been revoked since the form was opened.
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
        .can(SystemObject.cashDrawers, AccessRight.create)) {
      state = state.copyWith(
        error: CashDrawerFormErrorCode.createPermissionDenied,
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
          .read(cashDrawerRepositoryProvider)
          .create(
            facilityId: state.facilityId!,
            code: state.code,
            name: state.name,
            comment: state.comment.isEmpty ? null : state.comment,
            status: state.status,
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
          error: CashDrawerFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Saves edits to the loaded cashDrawer. No-ops if none has been loaded.
  Future<void> submitUpdate() async {
    final cashDrawerId = state.cashDrawerId;
    if (cashDrawerId == null) return;

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
        .can(SystemObject.cashDrawers, AccessRight.update)) {
      state = state.copyWith(
        error: CashDrawerFormErrorCode.updatePermissionDenied,
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
          .read(cashDrawerRepositoryProvider)
          .update(
            cashDrawerId: cashDrawerId,
            facilityId: state.facilityId,
            code: state.code,
            name: state.name,
            comment: state.comment,
            status: state.status,
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
          error: CashDrawerFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Deletes the loaded cash drawer (FR-007). No-ops if none has been loaded.
  /// A server rejection is surfaced via `error`/`errorDetail`, leaving the
  /// record in place.
  Future<void> delete() async {
    final cashDrawerId = state.cashDrawerId;
    if (cashDrawerId == null) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.cashDrawers, AccessRight.delete)) {
      state = state.copyWith(
        error: CashDrawerFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref
          .read(cashDrawerRepositoryProvider)
          .delete(cashDrawerId: cashDrawerId);
      _invalidateCaches();
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: CashDrawerFormErrorCode.deleteFailed,
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
