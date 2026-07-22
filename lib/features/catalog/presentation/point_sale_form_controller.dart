import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/presentation/points_of_sale_list_controller.dart';

part 'point_sale_form_controller.freezed.dart';
part 'point_sale_form_controller.g.dart';

/// Error codes for [PointSaleFormState.error]/`fieldErrors`, localized in
/// the UI layer.
abstract final class PointSaleFormErrorCode {
  static const facilityRequired = 'facilityRequired';
  static const codeRequired = 'codeRequired';
  static const nameRequired = 'nameRequired';
  static const warehouseRequired = 'warehouseRequired';
  static const loadFailed = 'loadFailed';
  static const createFailed = 'createFailed';
  static const updateFailed = 'updateFailed';
  static const deleteFailed = 'deleteFailed';
  static const createPermissionDenied = 'createPermissionDenied';
  static const updatePermissionDenied = 'updatePermissionDenied';
  static const deletePermissionDenied = 'deletePermissionDenied';
}

/// Create/edit form state for a single point of sale. [pointSaleId] is
/// `null` in create mode.
@freezed
class PointSaleFormState with _$PointSaleFormState {
  const factory PointSaleFormState({
    int? pointSaleId,
    int? facilityId,
    @Default('') String facilityDisplayText,
    @Default('') String code,
    @Default('') String name,
    int? warehouseId,
    @Default('') String warehouseDisplayText,
    @Default('') String comment,
    @Default(EntityStatus.active) EntityStatus status,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _PointSaleFormState;
}

/// Manages the create/edit point-of-sale form (FR-019, FR-020, FR-021,
/// FR-022).
@riverpod
class PointSaleFormController extends _$PointSaleFormController {
  @override
  PointSaleFormState build() => const PointSaleFormState();

  /// FR-022: the warehouse picker is scoped to [facilityId] (its
  /// `optionsBuilder` passes this through), so changing the facility to a
  /// *different* one clears any already-selected warehouse — forcing an
  /// explicit reselection rather than silently carrying over a pairing that
  /// may no longer be valid. Unconditional on facility change (not
  /// conditioned on checking whether the old warehouse still belongs, which
  /// would need another round-trip): the conservative choice, since an
  /// already-cleared field can only ever be too cautious, never wrong. This
  /// is a UX guard layered over the backend's own validation
  /// (mbe-api#102, research.md §10), not a substitute for it — a legacy
  /// record whose warehouse already mismatches still loads via
  /// [loadForEdit] without being cleared.
  void facilitySelected(int facilityId, String facilityName) {
    final facilityChanged = state.facilityId != facilityId;
    state = state.copyWith(
      facilityId: facilityId,
      facilityDisplayText: facilityName,
      warehouseId: facilityChanged ? null : state.warehouseId,
      warehouseDisplayText: facilityChanged ? '' : state.warehouseDisplayText,
      error: null,
      errorDetail: null,
      fieldErrors: const {},
    );
  }

  void warehouseSelected(int warehouseId, String warehouseName) {
    state = state.copyWith(
      warehouseId: warehouseId,
      warehouseDisplayText: warehouseName,
      error: null,
      errorDetail: null,
      fieldErrors: const {},
    );
  }

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

  /// Loads an existing point of sale into the form for viewing/editing. A
  /// legacy cross-facility pairing (FR-022) still loads and displays as-is —
  /// only a change made in this session forces reselection.
  Future<void> loadForEdit(int pointSaleId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final pointSale = await ref
          .read(pointSaleRepositoryProvider)
          .get(pointSaleId: pointSaleId);
      state = PointSaleFormState(
        pointSaleId: pointSale.pointSaleId,
        facilityId: pointSale.facilityId,
        facilityDisplayText: pointSale.facilityName,
        code: pointSale.code,
        name: pointSale.name,
        warehouseId: pointSale.warehouseId,
        warehouseDisplayText: pointSale.warehouseName,
        comment: pointSale.comment ?? '',
        status: pointSale.status,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: PointSaleFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (state.facilityId == null) {
      errors['facility'] = PointSaleFormErrorCode.facilityRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.code)) {
      errors['code'] = PointSaleFormErrorCode.codeRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.name)) {
      errors['name'] = PointSaleFormErrorCode.nameRequired;
    }
    if (state.warehouseId == null) {
      errors['warehouse'] = PointSaleFormErrorCode.warehouseRequired;
    }
    return errors;
  }

  void _invalidateCaches() {
    ref.invalidate(pointsOfSaleListControllerProvider);
  }

  /// Creates the point of sale (FR-019, FR-020). Re-checks the caller's
  /// `pointsOfSale` create privilege immediately before submitting, since it
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
        .can(SystemObject.pointsOfSale, AccessRight.create)) {
      state = state.copyWith(
        error: PointSaleFormErrorCode.createPermissionDenied,
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
          .read(pointSaleRepositoryProvider)
          .create(
            facilityId: state.facilityId!,
            code: state.code,
            name: state.name,
            warehouseId: state.warehouseId!,
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
          error: PointSaleFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Saves edits to the loaded point of sale. No-ops if none has been
  /// loaded.
  Future<void> submitUpdate() async {
    final pointSaleId = state.pointSaleId;
    if (pointSaleId == null) return;

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
        .can(SystemObject.pointsOfSale, AccessRight.update)) {
      state = state.copyWith(
        error: PointSaleFormErrorCode.updatePermissionDenied,
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
          .read(pointSaleRepositoryProvider)
          .update(
            pointSaleId: pointSaleId,
            facilityId: state.facilityId,
            code: state.code,
            name: state.name,
            warehouseId: state.warehouseId,
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
          error: PointSaleFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Deletes the loaded point of sale (FR-007). No-ops if none has been
  /// loaded. A server rejection is surfaced via `error`/`errorDetail`,
  /// leaving the record in place.
  Future<void> delete() async {
    final pointSaleId = state.pointSaleId;
    if (pointSaleId == null) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.pointsOfSale, AccessRight.delete)) {
      state = state.copyWith(
        error: PointSaleFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref
          .read(pointSaleRepositoryProvider)
          .delete(pointSaleId: pointSaleId);
      _invalidateCaches();
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: PointSaleFormErrorCode.deleteFailed,
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
