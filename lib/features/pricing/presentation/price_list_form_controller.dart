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
  static const marginInvalid = 'marginInvalid';
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
    @Default('') String highProfitMargin,
    @Default('') String lowProfitMargin,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
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

  void highProfitMarginChanged(String v) => state = state.copyWith(
    highProfitMargin: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void lowProfitMarginChanged(String v) => state = state.copyWith(
    lowProfitMargin: v,
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
        highProfitMargin: priceList.highProfitMargin,
        lowProfitMargin: priceList.lowProfitMargin,
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
    if (!PricingValidators.isOptionalNonNegativeDecimal(
      state.highProfitMargin,
    )) {
      errors['highProfitMargin'] = PriceListFormErrorCode.marginInvalid;
    }
    if (!PricingValidators.isOptionalNonNegativeDecimal(
      state.lowProfitMargin,
    )) {
      errors['lowProfitMargin'] = PriceListFormErrorCode.marginInvalid;
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
          .create(
            name: state.name,
            highProfitMargin: _orNull(state.highProfitMargin),
            lowProfitMargin: _orNull(state.lowProfitMargin),
          );
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
          .update(
            priceListId: priceListId,
            name: state.name,
            highProfitMargin: _orNull(state.highProfitMargin),
            lowProfitMargin: _orNull(state.lowProfitMargin),
          );
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

  /// Deletes the loaded price list (FR-004). No-ops if no price list has
  /// been loaded. A server rejection (e.g. still assigned to a customer,
  /// US1 §6) is surfaced via `error`/`errorDetail`, leaving the list in
  /// place.
  Future<void> delete() async {
    final priceListId = state.priceListId;
    if (priceListId == null) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.priceLists, AccessRight.delete)) {
      state = state.copyWith(
        error: PriceListFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref
          .read(priceListRepositoryProvider)
          .delete(priceListId: priceListId);
      ref.invalidate(priceListsListControllerProvider);
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: PriceListFormErrorCode.deleteFailed,
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
