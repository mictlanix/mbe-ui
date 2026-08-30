import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/pricing_validators.dart';
import 'package:mbe_ui/features/pricing/presentation/price_lists_list_controller.dart';

part 'price_list_form_controller.freezed.dart';
part 'price_list_form_controller.g.dart';

/// Error codes for [PriceListFormState.error]/`fieldErrors`, localized in
/// the UI layer (mirrors `ProductFormErrorCode`).
abstract final class PriceListFormErrorCode {
  static const nameRequired = 'nameRequired';
  static const loadFailed = 'loadFailed';
  static const createFailed = 'createFailed';
  static const updateFailed = 'updateFailed';
  static const deleteFailed = 'deleteFailed';
  static const createPermissionDenied = 'createPermissionDenied';
  static const updatePermissionDenied = 'updatePermissionDenied';
  static const deletePermissionDenied = 'deletePermissionDenied';
}

/// Create/edit form state for a single price list. [priceListId] is `null`
/// in create mode.
@freezed
class PriceListFormState with _$PriceListFormState {
  const factory PriceListFormState({
    int? priceListId,
    @Default('') String name,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _PriceListFormState;
}

/// Manages the create/edit price-list form (FR-002, FR-003, FR-004).
@riverpod
class PriceListFormController extends _$PriceListFormController {
  @override
  PriceListFormState build() => const PriceListFormState();

  void nameChanged(String v) => state = state.copyWith(
    name: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  /// Loads an existing price list into the form for viewing/editing.
  Future<void> loadForEdit(int priceListId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final priceList = await ref
          .read(priceListRepositoryProvider)
          .get(priceListId: priceListId);
      state = PriceListFormState(
        priceListId: priceList.priceListId,
        name: priceList.name,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: PriceListFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  /// Client-side validation (FR-002, FR-006).
  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (!PricingValidators.isRequiredNonEmpty(state.name)) {
      errors['name'] = PriceListFormErrorCode.nameRequired;
    }
    return errors;
  }

  /// Creates the price list (FR-002). Re-checks the caller's `priceLists`
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
        .can(SystemObject.priceLists, AccessRight.create)) {
      state = state.copyWith(
        error: PriceListFormErrorCode.createPermissionDenied,
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
          .read(priceListRepositoryProvider)
          // Margins omitted: deprecated since mbe-api#185, and defaulted to
          // `0` server-side (spec 033 FR-035).
          .create(name: state.name);
      ref.invalidate(priceListsListControllerProvider);
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
          error: PriceListFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Saves edits to the loaded price list (FR-003). No-ops if no price list
  /// has been loaded.
  Future<void> submitUpdate() async {
    final priceListId = state.priceListId;
    if (priceListId == null) return;

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
        .can(SystemObject.priceLists, AccessRight.update)) {
      state = state.copyWith(
        error: PriceListFormErrorCode.updatePermissionDenied,
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
          .read(priceListRepositoryProvider)
          // Margins omitted: deprecated since mbe-api#185, and an omitted
          // value leaves the stored one alone (spec 033 FR-035).
          .update(priceListId: priceListId, name: state.name);
      ref.invalidate(priceListsListControllerProvider);
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
          error: PriceListFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Deletes the loaded price list (specs/034-price-list-retirement-ui
  /// FR-012, research.md R9), optionally moving its customers to
  /// [replacement]. Returns `true` on success, `false` on any refusal —
  /// the caller (the delete review dialog) awaits this rather than
  /// watching a `deleted` flag, since a flag flipping mid-dialog would
  /// trigger the *screen's* old post-frame pop while the dialog is still
  /// the topmost route, popping the dialog instead of the screen.
  ///
  /// No-ops (returns `false`) if no price list has been loaded. A server
  /// refusal (blocked, or a race the preview couldn't see, US1 §6) is
  /// surfaced via `error`/`errorDetail`, leaving the list in place.
  Future<bool> delete({int? replacement}) async {
    final priceListId = state.priceListId;
    if (priceListId == null) return false;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.priceLists, AccessRight.delete)) {
      state = state.copyWith(
        error: PriceListFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return false;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref
          .read(priceListRepositoryProvider)
          .delete(priceListId: priceListId, replacement: replacement);
      ref.invalidate(priceListsListControllerProvider);
      state = state.copyWith(submitting: false);
      return true;
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: PriceListFormErrorCode.deleteFailed,
        errorDetail: e.serverMessage,
      );
      return false;
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
