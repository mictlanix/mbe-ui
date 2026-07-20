import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicles_list_controller.dart';

part 'vehicle_form_controller.freezed.dart';
part 'vehicle_form_controller.g.dart';

/// Error codes for [VehicleFormState.error]/`fieldErrors`, localized in the
/// UI layer (mirrors `ExpenseFormErrorCode`).
abstract final class VehicleFormErrorCode {
  static const licensePlateRequired = 'licensePlateRequired';
  static const nameRequired = 'nameRequired';
  static const nicknameRequired = 'nicknameRequired';
  static const tonsCapacityInvalid = 'tonsCapacityInvalid';
  static const loadFailed = 'loadFailed';
  static const createFailed = 'createFailed';
  static const updateFailed = 'updateFailed';
  static const deleteFailed = 'deleteFailed';
  static const createPermissionDenied = 'createPermissionDenied';
  static const updatePermissionDenied = 'updatePermissionDenied';
  static const deletePermissionDenied = 'deletePermissionDenied';
}

/// Create/edit form state for a single vehicle. [vehicleId] is `null` in
/// create mode.
@freezed
class VehicleFormState with _$VehicleFormState {
  const factory VehicleFormState({
    int? vehicleId,
    @Default('') String licensePlate,
    @Default('') String name,
    @Default('') String nickname,
    @Default('') String tonsCapacity,
    @Default(true) bool active,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _VehicleFormState;
}

/// Manages the create/edit vehicle form (FR-012, FR-013, FR-014).
@riverpod
class VehicleFormController extends _$VehicleFormController {
  @override
  VehicleFormState build() => const VehicleFormState();

  void licensePlateChanged(String v) => state = state.copyWith(
    licensePlate: v,
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

  void nicknameChanged(String v) => state = state.copyWith(
    nickname: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void tonsCapacityChanged(String v) => state = state.copyWith(
    tonsCapacity: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void activeChanged(bool v) => state = state.copyWith(active: v);

  /// Loads an existing vehicle into the form for viewing/editing.
  Future<void> loadForEdit(int vehicleId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final vehicle = await ref
          .read(vehicleRepositoryProvider)
          .get(vehicleId: vehicleId);
      state = VehicleFormState(
        vehicleId: vehicle.vehicleId,
        licensePlate: vehicle.licensePlate,
        name: vehicle.name,
        nickname: vehicle.nickname,
        tonsCapacity: vehicle.tonsCapacity.toString(),
        active: vehicle.active,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: VehicleFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.licensePlate)) {
      errors['licensePlate'] = VehicleFormErrorCode.licensePlateRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.name)) {
      errors['name'] = VehicleFormErrorCode.nameRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.nickname)) {
      errors['nickname'] = VehicleFormErrorCode.nicknameRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonNegativeInteger(
      state.tonsCapacity,
    )) {
      errors['tonsCapacity'] = VehicleFormErrorCode.tonsCapacityInvalid;
    }
    return errors;
  }

  void _invalidateCaches() {
    ref.invalidate(vehiclesListControllerProvider);
  }

  /// Creates the vehicle (FR-012, FR-013). Re-checks the caller's `vehicle`
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
        .can(SystemObject.vehicle, AccessRight.create)) {
      state = state.copyWith(
        error: VehicleFormErrorCode.createPermissionDenied,
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
          .read(vehicleRepositoryProvider)
          .create(
            licensePlate: state.licensePlate,
            name: state.name,
            nickname: state.nickname,
            tonsCapacity: int.parse(state.tonsCapacity),
            active: state.active,
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
          error: VehicleFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Saves edits to the loaded vehicle. No-ops if no vehicle has been loaded.
  Future<void> submitUpdate() async {
    final vehicleId = state.vehicleId;
    if (vehicleId == null) return;

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
        .can(SystemObject.vehicle, AccessRight.update)) {
      state = state.copyWith(
        error: VehicleFormErrorCode.updatePermissionDenied,
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
          .read(vehicleRepositoryProvider)
          .update(
            vehicleId: vehicleId,
            licensePlate: state.licensePlate,
            name: state.name,
            nickname: state.nickname,
            tonsCapacity: int.parse(state.tonsCapacity),
            active: state.active,
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
          error: VehicleFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Deletes the loaded vehicle (FR-006). No-ops if no vehicle has been
  /// loaded. A server rejection is surfaced via `error`/`errorDetail`,
  /// leaving the vehicle in place.
  Future<void> delete() async {
    final vehicleId = state.vehicleId;
    if (vehicleId == null) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.vehicle, AccessRight.delete)) {
      state = state.copyWith(
        error: VehicleFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref.read(vehicleRepositoryProvider).delete(vehicleId: vehicleId);
      _invalidateCaches();
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: VehicleFormErrorCode.deleteFailed,
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
