import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/presentation/warehouses_list_controller.dart';

part 'warehouse_form_controller.freezed.dart';
part 'warehouse_form_controller.g.dart';

/// Error codes for [WarehouseFormState.error]/`fieldErrors`, localized in
/// the UI layer (mirrors `VehicleOperatorFormErrorCode`).
abstract final class WarehouseFormErrorCode {
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

/// Create/edit form state for a single warehouse. [warehouseId] is `null` in
/// create mode.
@freezed
class WarehouseFormState with _$WarehouseFormState {
  const factory WarehouseFormState({
    int? warehouseId,
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
  }) = _WarehouseFormState;
}

/// Manages the create/edit warehouse form (FR-013, FR-014, FR-015).
@riverpod
class WarehouseFormController extends _$WarehouseFormController {
  @override
  WarehouseFormState build() => const WarehouseFormState();

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

  /// Loads an existing warehouse into the form for viewing/editing.
  Future<void> loadForEdit(int warehouseId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final warehouse = await ref
          .read(warehouseRepositoryProvider)
          .get(warehouseId: warehouseId);
      state = WarehouseFormState(
        warehouseId: warehouse.warehouseId,
        facilityId: warehouse.facilityId,
        facilityDisplayText: warehouse.facilityName,
        code: warehouse.code,
        name: warehouse.name,
        comment: warehouse.comment ?? '',
        status: warehouse.status,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: WarehouseFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (state.facilityId == null) {
      errors['facility'] = WarehouseFormErrorCode.facilityRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.code)) {
      errors['code'] = WarehouseFormErrorCode.codeRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.name)) {
      errors['name'] = WarehouseFormErrorCode.nameRequired;
    }
    return errors;
  }

  void _invalidateCaches() {
    ref.invalidate(warehousesListControllerProvider);
  }

  /// Creates the warehouse (FR-013, FR-014). Re-checks the caller's
  /// `warehouses` create privilege immediately before submitting, since it
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
        .can(SystemObject.warehouses, AccessRight.create)) {
      state = state.copyWith(
        error: WarehouseFormErrorCode.createPermissionDenied,
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
          .read(warehouseRepositoryProvider)
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
          error: WarehouseFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Saves edits to the loaded warehouse. No-ops if none has been loaded.
  Future<void> submitUpdate() async {
    final warehouseId = state.warehouseId;
    if (warehouseId == null) return;

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
        .can(SystemObject.warehouses, AccessRight.update)) {
      state = state.copyWith(
        error: WarehouseFormErrorCode.updatePermissionDenied,
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
          .read(warehouseRepositoryProvider)
          .update(
            warehouseId: warehouseId,
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
          error: WarehouseFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Deletes the loaded warehouse (FR-007). No-ops if none has been loaded.
  /// A server rejection is surfaced via `error`/`errorDetail`, leaving the
  /// record in place.
  Future<void> delete() async {
    final warehouseId = state.warehouseId;
    if (warehouseId == null) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.warehouses, AccessRight.delete)) {
      state = state.copyWith(
        error: WarehouseFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref
          .read(warehouseRepositoryProvider)
          .delete(warehouseId: warehouseId);
      _invalidateCaches();
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: WarehouseFormErrorCode.deleteFailed,
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
