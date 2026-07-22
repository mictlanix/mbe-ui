import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/presentation/payment_method_options_list_controller.dart';

part 'payment_method_option_form_controller.freezed.dart';
part 'payment_method_option_form_controller.g.dart';

/// Error codes for [PaymentMethodOptionFormState.error]/`fieldErrors`,
/// localized in the UI layer (mirrors `WarehouseFormErrorCode`).
abstract final class PaymentMethodOptionFormErrorCode {
  static const facilityRequired = 'facilityRequired';
  static const nameRequired = 'nameRequired';
  static const paymentMethodRequired = 'paymentMethodRequired';
  static const numberOfPaymentsInvalid = 'numberOfPaymentsInvalid';
  static const commissionInvalid = 'commissionInvalid';
  static const loadFailed = 'loadFailed';
  static const createFailed = 'createFailed';
  static const updateFailed = 'updateFailed';
  static const deleteFailed = 'deleteFailed';
  static const createPermissionDenied = 'createPermissionDenied';
  static const updatePermissionDenied = 'updatePermissionDenied';
  static const deletePermissionDenied = 'deletePermissionDenied';
}

/// Create/edit form state for a single payment method option.
/// [paymentMethodOptionId] is `null` in create mode. [numberOfPayments]
/// defaults to `1` and [displayOnTicket] to `true` (FR-005) so a create left
/// untouched persists those defaults.
@freezed
class PaymentMethodOptionFormState with _$PaymentMethodOptionFormState {
  const factory PaymentMethodOptionFormState({
    int? paymentMethodOptionId,
    int? facilityId,
    @Default('') String facilityDisplayText,
    int? warehouseId,
    @Default('') String warehouseDisplayText,
    @Default('') String name,
    @Default(1) int numberOfPayments,
    @Default(true) bool displayOnTicket,
    int? paymentMethod,
    @Default('') String commission,
    @Default(EntityStatus.active) EntityStatus status,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _PaymentMethodOptionFormState;
}

/// Manages the create/edit payment method option form (FR-003, FR-005,
/// FR-006, FR-007).
@riverpod
class PaymentMethodOptionFormController
    extends _$PaymentMethodOptionFormController {
  @override
  PaymentMethodOptionFormState build() =>
      const PaymentMethodOptionFormState();

  void facilitySelected(int facilityId, String facilityName) =>
      state = _clearErrors(
        state.copyWith(
          facilityId: facilityId,
          facilityDisplayText: facilityName,
        ),
      );

  void warehouseSelected(int? warehouseId, String warehouseName) =>
      state = _clearErrors(
        state.copyWith(
          warehouseId: warehouseId,
          warehouseDisplayText: warehouseName,
        ),
      );

  void nameChanged(String v) => state = _clearErrors(state.copyWith(name: v));

  void numberOfPaymentsChanged(int v) =>
      state = _clearErrors(state.copyWith(numberOfPayments: v));

  void displayOnTicketChanged(bool v) =>
      state = state.copyWith(displayOnTicket: v);

  void paymentMethodChanged(int v) =>
      state = _clearErrors(state.copyWith(paymentMethod: v));

  void commissionChanged(String v) =>
      state = _clearErrors(state.copyWith(commission: v));

  void statusChanged(EntityStatus v) => state = state.copyWith(status: v);

  PaymentMethodOptionFormState _clearErrors(
    PaymentMethodOptionFormState s,
  ) => s.copyWith(error: null, errorDetail: null, fieldErrors: const {});

  /// Loads an existing payment method option into the form for
  /// viewing/editing.
  Future<void> loadForEdit(int paymentMethodOptionId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final option = await ref
          .read(paymentMethodOptionRepositoryProvider)
          .get(paymentMethodOptionId: paymentMethodOptionId);
      state = PaymentMethodOptionFormState(
        paymentMethodOptionId: option.paymentMethodOptionId,
        facilityId: option.facilityId,
        facilityDisplayText: option.facilityName,
        warehouseId: option.warehouseId,
        warehouseDisplayText: option.warehouseName ?? '',
        name: option.name,
        numberOfPayments: option.numberOfPayments,
        displayOnTicket: option.displayOnTicket,
        paymentMethod: option.paymentMethod,
        commission: option.commission ?? '',
        status: option.status,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: PaymentMethodOptionFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (state.facilityId == null) {
      errors['facility'] = PaymentMethodOptionFormErrorCode.facilityRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.name)) {
      errors['name'] = PaymentMethodOptionFormErrorCode.nameRequired;
    }
    if (state.paymentMethod == null) {
      errors['paymentMethod'] =
          PaymentMethodOptionFormErrorCode.paymentMethodRequired;
    }
    if (state.numberOfPayments < 1) {
      errors['numberOfPayments'] =
          PaymentMethodOptionFormErrorCode.numberOfPaymentsInvalid;
    }
    if (!CatalogFieldValidators.isOptionalNonNegativeDecimal(
      state.commission,
    )) {
      errors['commission'] = PaymentMethodOptionFormErrorCode.commissionInvalid;
    }
    return errors;
  }

  void _invalidateCaches() {
    ref.invalidate(paymentMethodOptionsListControllerProvider);
  }

  /// Creates the payment method option (FR-003, FR-005). Re-checks the
  /// caller's `paymentMethodOptions` create privilege immediately before
  /// submitting, since it may have been revoked since the form was opened.
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
        .can(SystemObject.paymentMethodOptions, AccessRight.create)) {
      state = state.copyWith(
        error: PaymentMethodOptionFormErrorCode.createPermissionDenied,
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
          .read(paymentMethodOptionRepositoryProvider)
          .create(
            facilityId: state.facilityId!,
            warehouseId: state.warehouseId,
            name: state.name,
            numberOfPayments: state.numberOfPayments,
            displayOnTicket: state.displayOnTicket,
            paymentMethod: state.paymentMethod!,
            commission: state.commission.isEmpty ? null : state.commission,
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
          error: PaymentMethodOptionFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Saves edits to the loaded payment method option. No-ops if none has
  /// been loaded.
  Future<void> submitUpdate() async {
    final paymentMethodOptionId = state.paymentMethodOptionId;
    if (paymentMethodOptionId == null) return;

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
        .can(SystemObject.paymentMethodOptions, AccessRight.update)) {
      state = state.copyWith(
        error: PaymentMethodOptionFormErrorCode.updatePermissionDenied,
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
          .read(paymentMethodOptionRepositoryProvider)
          .update(
            paymentMethodOptionId: paymentMethodOptionId,
            facilityId: state.facilityId,
            warehouseId: state.warehouseId,
            name: state.name,
            numberOfPayments: state.numberOfPayments,
            displayOnTicket: state.displayOnTicket,
            paymentMethod: state.paymentMethod,
            commission: state.commission,
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
          error: PaymentMethodOptionFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Deletes the loaded payment method option (FR-007). No-ops if none has
  /// been loaded. A server rejection is surfaced via `error`/`errorDetail`,
  /// leaving the record in place.
  Future<void> delete() async {
    final paymentMethodOptionId = state.paymentMethodOptionId;
    if (paymentMethodOptionId == null) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.paymentMethodOptions, AccessRight.delete)) {
      state = state.copyWith(
        error: PaymentMethodOptionFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref
          .read(paymentMethodOptionRepositoryProvider)
          .delete(paymentMethodOptionId: paymentMethodOptionId);
      _invalidateCaches();
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: PaymentMethodOptionFormErrorCode.deleteFailed,
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
