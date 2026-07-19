import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/catalog_field_validators.dart';
import 'package:mbe_ui/features/catalog/presentation/suppliers_list_controller.dart';

part 'supplier_form_controller.freezed.dart';
part 'supplier_form_controller.g.dart';

/// Error codes for [SupplierFormState.error]/`fieldErrors`, localized in the
/// UI layer (mirrors `PriceListFormErrorCode`).
abstract final class SupplierFormErrorCode {
  static const codeRequired = 'codeRequired';
  static const nameRequired = 'nameRequired';
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

/// Create/edit form state for a single supplier. [supplierId] is `null` in
/// create mode.
@freezed
class SupplierFormState with _$SupplierFormState {
  const factory SupplierFormState({
    int? supplierId,
    @Default('') String code,
    @Default('') String name,
    @Default('') String zone,
    @Default('') String creditLimit,
    @Default('') String creditDays,
    @Default('') String comment,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    @Default(false) bool deleted,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _SupplierFormState;
}

/// Manages the create/edit supplier form (FR-010, FR-011).
@riverpod
class SupplierFormController extends _$SupplierFormController {
  @override
  SupplierFormState build() => const SupplierFormState();

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

  void commentChanged(String v) => state = state.copyWith(comment: v);

  /// Loads an existing supplier into the form for viewing/editing.
  Future<void> loadForEdit(int supplierId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final supplier = await ref
          .read(supplierRepositoryProvider)
          .get(supplierId: supplierId);
      state = SupplierFormState(
        supplierId: supplier.supplierId,
        code: supplier.code,
        name: supplier.name,
        zone: supplier.zone ?? '',
        creditLimit: supplier.creditLimit,
        creditDays: supplier.creditDays.toString(),
        comment: supplier.comment ?? '',
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: SupplierFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  /// Client-side validation (FR-010, FR-011).
  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.code)) {
      errors['code'] = SupplierFormErrorCode.codeRequired;
    }
    if (!CatalogFieldValidators.isRequiredNonEmpty(state.name)) {
      errors['name'] = SupplierFormErrorCode.nameRequired;
    }
    if (!CatalogFieldValidators.isOptionalNonNegativeDecimal(
      state.creditLimit,
    )) {
      errors['creditLimit'] = SupplierFormErrorCode.creditLimitInvalid;
    }
    if (!CatalogFieldValidators.isOptionalNonNegativeInteger(
      state.creditDays,
    )) {
      errors['creditDays'] = SupplierFormErrorCode.creditDaysInvalid;
    }
    return errors;
  }

  /// Creates the supplier (FR-010). Re-checks the caller's `suppliers`
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
        .can(SystemObject.suppliers, AccessRight.create)) {
      state = state.copyWith(
        error: SupplierFormErrorCode.createPermissionDenied,
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
          .read(supplierRepositoryProvider)
          .create(
            code: state.code,
            name: state.name,
            zone: _orNull(state.zone),
            creditLimit: _orNull(state.creditLimit),
            creditDays: _orNullInt(state.creditDays),
            comment: _orNull(state.comment),
          );
      ref.invalidate(suppliersListControllerProvider);
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
          error: SupplierFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Saves edits to the loaded supplier (FR-010). No-ops if no supplier has
  /// been loaded.
  Future<void> submitUpdate() async {
    final supplierId = state.supplierId;
    if (supplierId == null) return;

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
        .can(SystemObject.suppliers, AccessRight.update)) {
      state = state.copyWith(
        error: SupplierFormErrorCode.updatePermissionDenied,
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
          .read(supplierRepositoryProvider)
          .update(
            supplierId: supplierId,
            code: state.code,
            name: state.name,
            zone: state.zone,
            creditLimit: _orNull(state.creditLimit) ?? '',
            creditDays: _orNullInt(state.creditDays),
            comment: state.comment,
          );
      ref.invalidate(suppliersListControllerProvider);
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
          error: SupplierFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Deletes the loaded supplier (FR-006). No-ops if no supplier has been
  /// loaded. A server rejection (e.g. still referenced by a product) is
  /// surfaced via `error`/`errorDetail`, leaving the supplier in place.
  Future<void> delete() async {
    final supplierId = state.supplierId;
    if (supplierId == null) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.suppliers, AccessRight.delete)) {
      state = state.copyWith(
        error: SupplierFormErrorCode.deletePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref.read(supplierRepositoryProvider).delete(supplierId: supplierId);
      ref.invalidate(suppliersListControllerProvider);
      state = state.copyWith(submitting: false, deleted: true);
    } on AppError catch (e) {
      state = state.copyWith(
        submitting: false,
        error: SupplierFormErrorCode.deleteFailed,
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
