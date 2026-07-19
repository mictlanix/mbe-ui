import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/presentation/customers_list_controller.dart';

part 'customer_form_controller.freezed.dart';
part 'customer_form_controller.g.dart';

/// Error codes for [CustomerFormState.error]/`fieldErrors`, localized in the
/// UI layer.
abstract final class CustomerFormErrorCode {
  static const codeRequired = 'codeRequired';
  static const nameRequired = 'nameRequired';
  static const priceListRequired = 'priceListRequired';
  static const creditLimitInvalid = 'creditLimitInvalid';
  static const creditDaysInvalid = 'creditDaysInvalid';
  static const loadFailed = 'loadFailed';
  static const createFailed = 'createFailed';
  static const updateFailed = 'updateFailed';
  static const deleteFailed = 'deleteFailed';
  static const createPermissionDenied = 'createPermissionDenied';
  static const updatePermissionDenied = 'updatePermissionDenied';
  static const deletePermissionDenied = 'deletePermissionDenied';
}

/// Create/edit form state for a single customer. [customerId] is `null` in
/// create mode. `priceListId`/`salespersonId` are set by the form's
/// `CatalogEntityPicker`s (FR-020); their display-text fields pre-fill the
/// picker when editing an existing customer.
@freezed
class CustomerFormState with _$CustomerFormState {
  const factory CustomerFormState({
    int? customerId,
    @Default('') String code,
    @Default('') String name,
    @Default('') String zone,
    @Default('') String creditLimit,
    @Default('') String creditDays,
    int? priceListId,
    @Default('') String priceListDisplayText,
    @Default(false) bool shipping,
    @Default(false) bool shippingRequiredDocument,
    int? salespersonId,
    @Default('') String salespersonDisplayText,
    @Default(false) bool disabled,
    @Default('') String comment,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _CustomerFormState;
}

/// Manages the create/edit customer form (FR-018, FR-019, FR-020).
@riverpod
class CustomerFormController extends _$CustomerFormController {
  @override
  CustomerFormState build() => const CustomerFormState();

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

  void zoneChanged(String v) => state = state.copyWith(zone: v);

  void creditLimitChanged(String v) => state = state.copyWith(
    creditLimit: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void creditDaysChanged(String v) => state = state.copyWith(
    creditDays: v,
    error: null,
    errorDetail: null,
    fieldErrors: const {},
  );

  void priceListSelected(int id, String displayText) => state = state
      .copyWith(
        priceListId: id,
        priceListDisplayText: displayText,
        error: null,
        errorDetail: null,
        fieldErrors: const {},
      );

  void shippingChanged(bool v) => state = state.copyWith(shipping: v);

  void shippingRequiredDocumentChanged(bool v) =>
      state = state.copyWith(shippingRequiredDocument: v);

  void salespersonSelected(int? id, String displayText) => state = state
      .copyWith(salespersonId: id, salespersonDisplayText: displayText);

  void disabledChanged(bool v) => state = state.copyWith(disabled: v);

  void commentChanged(String v) => state = state.copyWith(comment: v);

  /// Loads an existing customer into the form for viewing/editing.
  Future<void> loadForEdit(int customerId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final customer = await ref
          .read(customerRepositoryProvider)
          .get(customerId: customerId);
      state = CustomerFormState(
        customerId: customer.customerId,
        code: customer.code,
        name: customer.name,
        zone: customer.zone ?? '',
        creditLimit: customer.creditLimit,
        creditDays: customer.creditDays.toString(),
        priceListId: customer.priceList.id,
        priceListDisplayText: customer.priceList.name,
        shipping: customer.shipping,
        shippingRequiredDocument: customer.shippingRequiredDocument,
        salespersonId: customer.salesperson?.id,
        salespersonDisplayText: customer.salesperson?.name ?? '',
        disabled: customer.disabled,
        comment: customer.comment ?? '',
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: CustomerFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  /// Client-side validation (FR-019).
  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.code)) {
      errors['code'] = CustomerFormErrorCode.codeRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.name)) {
      errors['name'] = CustomerFormErrorCode.nameRequired;
    }
    if (state.priceListId == null) {
      errors['priceList'] = CustomerFormErrorCode.priceListRequired;
    }
    if (!CatalogFieldValidators.isOptionalNonNegativeDecimal(
      state.creditLimit,
    )) {
      errors['creditLimit'] = CustomerFormErrorCode.creditLimitInvalid;
    }
    if (!CatalogFieldValidators.isOptionalNonNegativeInteger(
      state.creditDays,
    )) {
      errors['creditDays'] = CustomerFormErrorCode.creditDaysInvalid;
    }
    return errors;
  }

  /// Creates the customer (FR-018, FR-019). Re-checks the caller's
  /// `customers` create privilege immediately before submitting.
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
        .can(SystemObject.customers, AccessRight.create)) {
      state = state.copyWith(
        error: CustomerFormErrorCode.createPermissionDenied,
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
          .read(customerRepositoryProvider)
          .create(
            code: state.code,
            name: state.name,
            priceList: state.priceListId!,
            zone: _orNull(state.zone),
            creditLimit: _orNull(state.creditLimit),
            creditDays: _orNullInt(state.creditDays),
            shipping: state.shipping,
            shippingRequiredDocument: state.shippingRequiredDocument,
            salesperson: state.salespersonId,
            comment: _orNull(state.comment),
          );
      ref.invalidate(customersListControllerProvider);
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
          error: CustomerFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Saves edits to the loaded customer. No-ops if no customer has been
  /// loaded.
  Future<void> submitUpdate() async {
    final customerId = state.customerId;
    if (customerId == null) return;

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
        .can(SystemObject.customers, AccessRight.update)) {
      state = state.copyWith(
        error: CustomerFormErrorCode.updatePermissionDenied,
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
          .read(customerRepositoryProvider)
          .update(
            customerId: customerId,
            code: state.code,
            name: state.name,
            priceList: state.priceListId,
            zone: state.zone,
            creditLimit: _orNull(state.creditLimit) ?? '',
            creditDays: _orNullInt(state.creditDays),
            shipping: state.shipping,
            shippingRequiredDocument: state.shippingRequiredDocument,
            salesperson: state.salespersonId,
            disabled: state.disabled,
            comment: state.comment,
          );
      ref.invalidate(customersListControllerProvider);
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
          error: CustomerFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Deletes the loaded customer. No-ops if no customer has been loaded. A
  /// server rejection (e.g. existing sales orders) is surfaced via
  /// `error`/`errorDetail`, leaving the customer in place.
  Future<void> delete() async {
    final customerId = state.customerId;
    if (customerId == null) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.customers, AccessRight.delete)) {
      state = state.copyWith(
        error: CustomerFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref
          .read(customerRepositoryProvider)
          .delete(customerId: customerId);
      ref.invalidate(customersListControllerProvider);
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: CustomerFormErrorCode.deleteFailed,
        errorDetail: e.serverMessage,
      );
    }
  }
}

String? _orNull(String value) => value.isEmpty ? null : value;

int? _orNullInt(String value) => value.isEmpty ? null : int.tryParse(value);

Map<String, String> _fieldErrorsFromServer(ValidationError error) {
  final result = <String, String>{};
  for (final fieldError in error.errors) {
    final locKey = fieldError.loc.isNotEmpty ? fieldError.loc.last : 'error';
    result[locKey] = fieldError.msg;
  }
  return result;
}
