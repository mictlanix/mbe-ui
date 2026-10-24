import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/presentation/license_photo_provider.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_operators_list_controller.dart';

part 'vehicle_operator_form_controller.freezed.dart';
part 'vehicle_operator_form_controller.g.dart';

/// Error codes for [VehicleOperatorFormState.error]/`fieldErrors`, localized
/// in the UI layer (mirrors `VehicleFormErrorCode`).
abstract final class VehicleOperatorFormErrorCode {
  static const driverRequired = 'driverRequired';
  static const licenseTypeRequired = 'licenseTypeRequired';
  static const driverLicenseNumberRequired = 'driverLicenseNumberRequired';
  static const issueDateRequired = 'issueDateRequired';
  static const expirationDateRequired = 'expirationDateRequired';
  static const expirationBeforeIssue = 'expirationBeforeIssue';
  static const issuingLocationRequired = 'issuingLocationRequired';
  static const loadFailed = 'loadFailed';
  static const createFailed = 'createFailed';
  static const updateFailed = 'updateFailed';
  static const deleteFailed = 'deleteFailed';
  static const createPermissionDenied = 'createPermissionDenied';
  static const updatePermissionDenied = 'updatePermissionDenied';
  static const deletePermissionDenied = 'deletePermissionDenied';
  static const licensePhotoInvalidType = 'licensePhotoInvalidType';
  static const licensePhotoTooLarge = 'licensePhotoTooLarge';
  static const licensePhotoSaveFailed = 'licensePhotoSaveFailed';
}

const _maxLicensePhotoBytes = 2 * 1024 * 1024;
const _validLicensePhotoExtensions = ['.jpg', '.jpeg', '.png'];

/// Create/edit form state for a single vehicle operator. [vehicleOperatorId]
/// is `null` in create mode.
@freezed
abstract class VehicleOperatorFormState with _$VehicleOperatorFormState {
  const factory VehicleOperatorFormState({
    int? vehicleOperatorId,
    int? driverId,
    @Default('') String driverDisplayText,
    @Default('') String licenseType,
    @Default('') String driverLicenseNumber,
    DateTime? issueDate,
    DateTime? expirationDate,
    @Default('') String issuingLocation,
    @Default(EntityStatus.active) EntityStatus status,

    /// The server holds a license photo for this operator. The photo itself is
    /// read through `licensePhotoProvider`, not kept here, so a slow or failed
    /// read is never mistaken for an edit (051 R3).
    @Default(false) bool hasLicensePhoto,

    /// A picked, validated image that is sent when the form is saved.
    Uint8List? pendingLicensePhotoBytes,

    /// Original filename of [pendingLicensePhotoBytes], sent as the multipart
    /// filename.
    String? pendingLicensePhotoFilename,

    /// The user chose "remove photo" and has not picked a new one since.
    /// Mutually exclusive with [pendingLicensePhotoBytes].
    @Default(false) bool licensePhotoMarkedForRemoval,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _VehicleOperatorFormState;
}

/// Manages the create/edit vehicle operator form (FR-015, FR-016, FR-017).
@riverpod
class VehicleOperatorFormController extends _$VehicleOperatorFormController {
  @override
  VehicleOperatorFormState build() => const VehicleOperatorFormState();

  void driverSelected(int driverId, String driverName) =>
      state = state.copyWith(
        driverId: driverId,
        driverDisplayText: driverName,
        error: null,
        errorDetail: null,
        fieldErrors: const {},
      );

  void licenseTypeChanged(String v) => state = state.copyWith(
    licenseType: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void driverLicenseNumberChanged(String v) => state = state.copyWith(
    driverLicenseNumber: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void issueDateChanged(DateTime v) => state = state.copyWith(
    issueDate: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void expirationDateChanged(DateTime v) => state = state.copyWith(
    expirationDate: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void issuingLocationChanged(String v) => state = state.copyWith(
    issuingLocation: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void statusChanged(EntityStatus v) => state = state.copyWith(status: v);

  /// Stages [bytes] as the license photo after the same client-side checks as
  /// the product photo (JPG/PNG, 2 MB — FR-006). A rejected pick leaves any
  /// staged or saved photo as it was. A valid one supersedes a pending removal
  /// (FR-009).
  void licensePhotoPicked(Uint8List bytes, String filename) {
    final lower = filename.toLowerCase();
    if (!_validLicensePhotoExtensions.any(lower.endsWith)) {
      state = state.copyWith(
        fieldErrors: {
          ...state.fieldErrors,
          'licensePhoto': VehicleOperatorFormErrorCode.licensePhotoInvalidType,
        },
      );
      return;
    }
    if (bytes.length > _maxLicensePhotoBytes) {
      state = state.copyWith(
        fieldErrors: {
          ...state.fieldErrors,
          'licensePhoto': VehicleOperatorFormErrorCode.licensePhotoTooLarge,
        },
      );
      return;
    }
    final fieldErrors = {...state.fieldErrors}..remove('licensePhoto');
    state = state.copyWith(
      pendingLicensePhotoBytes: bytes,
      pendingLicensePhotoFilename: filename,
      licensePhotoMarkedForRemoval: false,
      fieldErrors: fieldErrors,
    );
  }

  /// Drops the license photo, applied on save (FR-008). A staged image goes
  /// straight back to "none"; only a photo the server actually holds is marked
  /// for deletion, so Save never asks the server to delete one that is not
  /// there. No-op when there is nothing to remove.
  void licensePhotoRemoveRequested() {
    if (!state.hasLicensePhoto && state.pendingLicensePhotoBytes == null) {
      return;
    }
    state = state.copyWith(
      licensePhotoMarkedForRemoval: state.hasLicensePhoto,
      pendingLicensePhotoBytes: null,
      pendingLicensePhotoFilename: null,
    );
  }

  /// Loads an existing vehicle operator into the form for viewing/editing.
  Future<void> loadForEdit(int vehicleOperatorId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final operator = await ref
          .read(vehicleOperatorRepositoryProvider)
          .get(vehicleOperatorId: vehicleOperatorId);
      state = VehicleOperatorFormState(
        vehicleOperatorId: operator.vehicleOperatorId,
        driverId: operator.driverId,
        driverDisplayText: operator.driverName,
        licenseType: operator.licenseType,
        driverLicenseNumber: operator.driverLicenseNumber,
        issueDate: operator.issueDate,
        expirationDate: operator.expirationDate,
        issuingLocation: operator.issuingLocation,
        status: operator.status,
        hasLicensePhoto: operator.hasLicensePhoto,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: VehicleOperatorFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (state.driverId == null) {
      errors['driver'] = VehicleOperatorFormErrorCode.driverRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.licenseType)) {
      errors['licenseType'] = VehicleOperatorFormErrorCode.licenseTypeRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.driverLicenseNumber)) {
      errors['driverLicenseNumber'] =
          VehicleOperatorFormErrorCode.driverLicenseNumberRequired;
    }
    if (state.issueDate == null) {
      errors['issueDate'] = VehicleOperatorFormErrorCode.issueDateRequired;
    }
    if (state.expirationDate == null) {
      errors['expirationDate'] =
          VehicleOperatorFormErrorCode.expirationDateRequired;
    }
    if (state.issueDate != null &&
        state.expirationDate != null &&
        !CatalogFieldValidators.dateNotBefore(
          state.issueDate,
          state.expirationDate,
        )) {
      errors['expirationDate'] =
          VehicleOperatorFormErrorCode.expirationBeforeIssue;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.issuingLocation)) {
      errors['issuingLocation'] =
          VehicleOperatorFormErrorCode.issuingLocationRequired;
    }
    return errors;
  }

  void _invalidateCaches() {
    ref.invalidate(vehicleOperatorsListControllerProvider);
  }

  /// The photo step of a save, run once the operator's fields are stored
  /// (051 R4). Finishes the save: success sets `saved`, which closes the panel.
  ///
  /// A failure here does **not** set `saved`. The fields are already stored, so
  /// the panel stays open with the photo change still staged and Save retries
  /// it (FR-012) — unlike the product form, whose full screen can afford to
  /// close and drop the staged image.
  Future<void> _applyLicensePhoto(int vehicleOperatorId) async {
    final bytes = state.pendingLicensePhotoBytes;
    if (bytes == null) {
      if (state.licensePhotoMarkedForRemoval) {
        await _removeLicensePhoto(vehicleOperatorId);
      } else {
        state = state.copyWith(submitting: false, saved: true);
      }
      return;
    }
    try {
      await ref
          .read(vehicleOperatorRepositoryProvider)
          .uploadLicensePhoto(
            vehicleOperatorId: vehicleOperatorId,
            bytes: bytes,
            filename: state.pendingLicensePhotoFilename!,
          );
      ref.invalidate(licensePhotoProvider(vehicleOperatorId));
      state = state.copyWith(
        submitting: false,
        saved: true,
        hasLicensePhoto: true,
        pendingLicensePhotoBytes: null,
        pendingLicensePhotoFilename: null,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: VehicleOperatorFormErrorCode.licensePhotoSaveFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  Future<void> _removeLicensePhoto(int vehicleOperatorId) async {
    try {
      await ref
          .read(vehicleOperatorRepositoryProvider)
          .removeLicensePhoto(vehicleOperatorId: vehicleOperatorId);
      ref.invalidate(licensePhotoProvider(vehicleOperatorId));
      state = state.copyWith(
        submitting: false,
        saved: true,
        hasLicensePhoto: false,
        licensePhotoMarkedForRemoval: false,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: VehicleOperatorFormErrorCode.licensePhotoSaveFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  /// Creates the vehicle operator (FR-015, FR-016). Re-checks the caller's
  /// `vehicleOperators` create privilege immediately before submitting,
  /// since it may have been revoked since the form was opened.
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
        .can(SystemObject.vehicleOperators, AccessRight.create)) {
      state = state.copyWith(
        error: VehicleOperatorFormErrorCode.createPermissionDenied,
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
      final created = await ref
          .read(vehicleOperatorRepositoryProvider)
          .create(
            driverId: state.driverId!,
            licenseType: state.licenseType,
            driverLicenseNumber: state.driverLicenseNumber,
            issueDate: state.issueDate!,
            expirationDate: state.expirationDate!,
            issuingLocation: state.issuingLocation,
            status: state.status,
          );
      _invalidateCaches();
      // The operator now exists: a retry after a failed photo step must update
      // it, not create it again (the form dispatches on this id).
      state = state.copyWith(vehicleOperatorId: created.vehicleOperatorId);
      await _applyLicensePhoto(created.vehicleOperatorId);
    } on AppError catch (e) {
      if (e is ValidationError) {
        state = state.copyWith(
          submitting: false,
          fieldErrors: _fieldErrorsFromServer(e),
        );
      } else {
        state = state.copyWith(
          submitting: false,
          error: VehicleOperatorFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Saves edits to the loaded vehicle operator. No-ops if none has been
  /// loaded.
  Future<void> submitUpdate() async {
    final vehicleOperatorId = state.vehicleOperatorId;
    if (vehicleOperatorId == null) return;

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
        .can(SystemObject.vehicleOperators, AccessRight.update)) {
      state = state.copyWith(
        error: VehicleOperatorFormErrorCode.updatePermissionDenied,
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
          .read(vehicleOperatorRepositoryProvider)
          .update(
            vehicleOperatorId: vehicleOperatorId,
            driverId: state.driverId,
            licenseType: state.licenseType,
            driverLicenseNumber: state.driverLicenseNumber,
            issueDate: state.issueDate,
            expirationDate: state.expirationDate,
            issuingLocation: state.issuingLocation,
            status: state.status,
          );
      _invalidateCaches();
      await _applyLicensePhoto(vehicleOperatorId);
    } on AppError catch (e) {
      if (e is ValidationError) {
        state = state.copyWith(
          submitting: false,
          fieldErrors: _fieldErrorsFromServer(e),
        );
      } else {
        state = state.copyWith(
          submitting: false,
          error: VehicleOperatorFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Deletes the loaded vehicle operator (FR-006). No-ops if none has been
  /// loaded. A server rejection is surfaced via `error`/`errorDetail`,
  /// leaving the record in place.
  Future<void> delete() async {
    final vehicleOperatorId = state.vehicleOperatorId;
    if (vehicleOperatorId == null) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.vehicleOperators, AccessRight.delete)) {
      state = state.copyWith(
        error: VehicleOperatorFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref
          .read(vehicleOperatorRepositoryProvider)
          .delete(vehicleOperatorId: vehicleOperatorId);
      _invalidateCaches();
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: VehicleOperatorFormErrorCode.deleteFailed,
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
