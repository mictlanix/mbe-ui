import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/presentation/labels_list_controller.dart';

part 'label_form_controller.freezed.dart';
part 'label_form_controller.g.dart';

/// Error codes for [LabelFormState.error]/`fieldErrors`, localized in the UI
/// layer (mirrors `SupplierFormErrorCode`).
abstract final class LabelFormErrorCode {
  static const nameRequired = 'nameRequired';
  static const loadFailed = 'loadFailed';
  static const createFailed = 'createFailed';
  static const updateFailed = 'updateFailed';
  static const deleteFailed = 'deleteFailed';
  static const createPermissionDenied = 'createPermissionDenied';
  static const updatePermissionDenied = 'updatePermissionDenied';
  static const deletePermissionDenied = 'deletePermissionDenied';
}

/// Create/edit form state for a single label. [labelId] is `null` in create
/// mode.
@freezed
class LabelFormState with _$LabelFormState {
  const factory LabelFormState({
    int? labelId,
    @Default('') String name,
    @Default('') String comment,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _LabelFormState;
}

/// Manages the create/edit label form (FR-012, FR-013, FR-014).
@riverpod
class LabelFormController extends _$LabelFormController {
  @override
  LabelFormState build() => const LabelFormState();

  void nameChanged(String v) => state = state.copyWith(
    name: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void commentChanged(String v) => state = state.copyWith(comment: v);

  /// Loads an existing label into the form for viewing/editing.
  Future<void> loadForEdit(int labelId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final label = await ref
          .read(labelRepositoryProvider)
          .get(labelId: labelId);
      state = LabelFormState(
        labelId: label.labelId,
        name: label.name,
        comment: label.comment ?? '',
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: LabelFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.name)) {
      errors['name'] = LabelFormErrorCode.nameRequired;
    }
    return errors;
  }

  /// Invalidates the Labels catalog list and the shared `allLabelsProvider`
  /// cache so the product form's label picker and the products list's label
  /// filter reflect the change immediately (FR-014).
  void _invalidateCaches() {
    ref.invalidate(labelsListControllerProvider);
    ref.invalidate(allLabelsProvider);
  }

  /// Creates the label (FR-012). Re-checks the caller's `labels` create
  /// privilege immediately before submitting, since it may have been revoked
  /// since the form was opened.
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
        .can(SystemObject.labels, AccessRight.create)) {
      state = state.copyWith(
        error: LabelFormErrorCode.createPermissionDenied,
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
          .read(labelRepositoryProvider)
          .create(name: state.name, comment: _orNull(state.comment));
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
          error: LabelFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Saves edits to the loaded label (FR-012). No-ops if no label has been
  /// loaded.
  Future<void> submitUpdate() async {
    final labelId = state.labelId;
    if (labelId == null) return;

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
        .can(SystemObject.labels, AccessRight.update)) {
      state = state.copyWith(
        error: LabelFormErrorCode.updatePermissionDenied,
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
          .read(labelRepositoryProvider)
          .update(labelId: labelId, name: state.name, comment: state.comment);
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
          error: LabelFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Deletes the loaded label (FR-006). No-ops if no label has been loaded.
  /// A server rejection (e.g. still assigned to a product) is surfaced via
  /// `error`/`errorDetail`, leaving the label in place.
  Future<void> delete() async {
    final labelId = state.labelId;
    if (labelId == null) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.labels, AccessRight.delete)) {
      state = state.copyWith(
        error: LabelFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref.read(labelRepositoryProvider).delete(labelId: labelId);
      _invalidateCaches();
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: LabelFormErrorCode.deleteFailed,
        errorDetail: e.serverMessage,
      );
    }
  }
}

String? _orNull(String value) => value.isEmpty ? null : value;

Map<String, String> _fieldErrorsFromServer(ValidationError error) {
  final result = <String, String>{};
  for (final fieldError in error.errors) {
    final locKey = fieldError.loc.isNotEmpty ? fieldError.loc.last : 'error';
    result[locKey] = fieldError.msg;
  }
  return result;
}
