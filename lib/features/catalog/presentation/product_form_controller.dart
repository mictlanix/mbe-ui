import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/presentation/products_list_controller.dart';

part 'product_form_controller.freezed.dart';
part 'product_form_controller.g.dart';

/// Error codes for [ProductFormState.error]/`fieldErrors`, mapped to
/// localized text in the UI layer (`product_detail_screen.dart`) since this
/// controller has no `BuildContext`/`AppLocalizations` access.
abstract final class ProductFormErrorCode {
  static const codeRequired = 'codeRequired';
  static const codeWhitespace = 'codeWhitespace';
  static const codeTooLong = 'codeTooLong';
  static const nameLength = 'nameLength';
  static const unitRequired = 'unitRequired';
  static const barCodeInvalid = 'barCodeInvalid';
  static const loadFailed = 'loadFailed';
  static const createFailed = 'createFailed';
  static const updateFailed = 'updateFailed';
  static const deactivateFailed = 'deactivateFailed';
  static const createPermissionDenied = 'createPermissionDenied';
  static const updatePermissionDenied = 'updatePermissionDenied';
  static const deactivatePermissionDenied = 'deactivatePermissionDenied';
}

/// Create/edit form state for a single product. Local UI state, not
/// persisted (constitution §II). [productId] is `null` in create mode.
@freezed
class ProductFormState with _$ProductFormState {
  const factory ProductFormState({
    int? productId,
    @Default('') String code,
    @Default('') String name,
    String? brand,
    String? model,
    String? barCode,
    String? location,
    @Default('') String unitOfMeasurement,
    String? taxRate,
    String? comment,
    @Default(false) bool stockable,
    @Default(false) bool perishable,
    @Default(false) bool seriable,
    @Default(false) bool purchasable,
    @Default(false) bool salable,
    @Default(false) bool invoiceable,
    @Default(false) bool deactivated,
    @Default(false) bool loading,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    String? error,
    /// The server-provided detail behind [error] (e.g. mbe-api's `detail`
    /// string on a `404`/`5xx`), shown alongside the localized [error]
    /// message since it can't be localized client-side. `null` for
    /// client-side-only errors (validation, permission checks).
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _ProductFormState;
}

/// Manages the create (and, from US3, edit) product form (FR-003..FR-007,
/// FR-009, FR-014, FR-015).
@riverpod
class ProductFormController extends _$ProductFormController {
  @override
  ProductFormState build() => const ProductFormState();

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

  void brandChanged(String v) => state = state.copyWith(brand: v);
  void modelChanged(String v) => state = state.copyWith(model: v);

  void barCodeChanged(String v) => state = state.copyWith(
        barCode: v,
        error: null,
        errorDetail: null,
        fieldErrors: const {},
      );

  void locationChanged(String v) => state = state.copyWith(location: v);

  void unitOfMeasurementChanged(String v) => state = state.copyWith(
        unitOfMeasurement: v,
        error: null,
        errorDetail: null,
        fieldErrors: const {},
      );

  void taxRateChanged(String v) => state = state.copyWith(taxRate: v);
  void commentChanged(String v) => state = state.copyWith(comment: v);

  void stockableChanged(bool v) => state = state.copyWith(stockable: v);
  void perishableChanged(bool v) => state = state.copyWith(perishable: v);
  void seriableChanged(bool v) => state = state.copyWith(seriable: v);
  void purchasableChanged(bool v) => state = state.copyWith(purchasable: v);
  void salableChanged(bool v) => state = state.copyWith(salable: v);
  void invoiceableChanged(bool v) => state = state.copyWith(invoiceable: v);

  /// Loads an existing product into the form for viewing/editing (FR-008,
  /// FR-009). Whether the form renders read-only (FR-013) is derived
  /// reactively in the screen from `accessControlProvider`, not snapshotted
  /// here — `ref.read` at this one-shot async call site could race with
  /// `authNotifierProvider`'s own async session restore.
  Future<void> loadForEdit(int productId) async {
    state = state.copyWith(loading: true, error: null, errorDetail: null);
    try {
      final product = await ref.read(productRepositoryProvider).get(productId: productId);
      state = ProductFormState(
        productId: product.productId,
        code: product.code,
        name: product.name,
        brand: product.brand,
        model: product.model,
        barCode: product.barCode,
        location: product.location,
        unitOfMeasurement: product.unitOfMeasurement,
        taxRate: product.taxRate,
        comment: product.comment,
        stockable: product.stockable,
        perishable: product.perishable,
        seriable: product.seriable,
        purchasable: product.purchasable,
        salable: product.salable,
        invoiceable: product.invoiceable,
        deactivated: product.deactivated,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        loading: false,
        error: ProductFormErrorCode.loadFailed,
        errorDetail: e.serverMessage,
      );
    }
  }

  /// Client-side validation mirroring contracts/mbe-api-products.md
  /// (FR-005, FR-006, FR-007) so the form fails fast before a round-trip.
  Map<String, String> _validate() {
    final errors = <String, String>{};

    final code = state.code;
    if (code.isEmpty) {
      errors['code'] = ProductFormErrorCode.codeRequired;
    } else if (code.contains(RegExp(r'\s'))) {
      errors['code'] = ProductFormErrorCode.codeWhitespace;
    } else if (code.length > 25) {
      errors['code'] = ProductFormErrorCode.codeTooLong;
    }

    if (state.name.length < 4 || state.name.length > 250) {
      errors['name'] = ProductFormErrorCode.nameLength;
    }

    if (state.unitOfMeasurement.trim().isEmpty) {
      errors['unitOfMeasurement'] = ProductFormErrorCode.unitRequired;
    }

    final barCode = state.barCode;
    if (barCode != null &&
        barCode.isNotEmpty &&
        !RegExp(r'^\d{13}$').hasMatch(barCode)) {
      errors['barCode'] = ProductFormErrorCode.barCodeInvalid;
    }

    return errors;
  }

  /// Creates the product (FR-003, FR-015). No-ops with a field-level error
  /// summary if client-side validation fails; re-checks the caller's
  /// `products` create privilege immediately before submitting, since it
  /// may have been revoked since the form was opened (spec.md Edge Cases).
  Future<void> submitCreate() async {
    final fieldErrors = _validate();
    if (fieldErrors.isNotEmpty) {
      state = state.copyWith(fieldErrors: fieldErrors, error: null, errorDetail: null);
      return;
    }

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.products, AccessRight.create)) {
      state = state.copyWith(
        error: ProductFormErrorCode.createPermissionDenied,
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
      await ref.read(productRepositoryProvider).create(
            code: state.code,
            name: state.name,
            unitOfMeasurement: state.unitOfMeasurement,
            brand: _orNull(state.brand),
            model: _orNull(state.model),
            barCode: _orNull(state.barCode),
            location: _orNull(state.location),
            taxRate: _orNull(state.taxRate),
            comment: _orNull(state.comment),
            stockable: state.stockable,
            perishable: state.perishable,
            seriable: state.seriable,
            purchasable: state.purchasable,
            salable: state.salable,
            invoiceable: state.invoiceable,
          );
      ref.invalidate(productsListControllerProvider);
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
          error: ProductFormErrorCode.createFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Saves edits to the loaded product (FR-009), subject to the same
  /// validation as [submitCreate] (FR-009). Re-checks the caller's
  /// `products` update privilege immediately before submitting (spec.md
  /// Edge Cases). No-ops if no product has been loaded.
  Future<void> submitUpdate() async {
    final productId = state.productId;
    if (productId == null) return;

    final fieldErrors = _validate();
    if (fieldErrors.isNotEmpty) {
      state = state.copyWith(fieldErrors: fieldErrors, error: null, errorDetail: null);
      return;
    }

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.products, AccessRight.update)) {
      state = state.copyWith(
        error: ProductFormErrorCode.updatePermissionDenied,
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
      await ref.read(productRepositoryProvider).update(
            productId: productId,
            code: state.code,
            name: state.name,
            unitOfMeasurement: state.unitOfMeasurement,
            brand: _orNull(state.brand),
            model: _orNull(state.model),
            barCode: _orNull(state.barCode),
            location: _orNull(state.location),
            taxRate: _orNull(state.taxRate),
            comment: _orNull(state.comment),
            stockable: state.stockable,
            perishable: state.perishable,
            seriable: state.seriable,
            purchasable: state.purchasable,
            salable: state.salable,
            invoiceable: state.invoiceable,
          );
      ref.invalidate(productsListControllerProvider);
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
          error: ProductFormErrorCode.updateFailed,
          errorDetail: e.serverMessage,
        );
      }
    }
  }

  /// Deactivates the loaded product ("soft delete", FR-010, FR-011) by
  /// calling `update` with only `deactivated: true`. No-ops if already
  /// deactivated or if no product has been loaded (edge case: repeated
  /// deactivation). Re-checks the caller's `products` delete privilege
  /// immediately before submitting (spec.md Edge Cases).
  Future<void> deactivate() async {
    final productId = state.productId;
    if (productId == null || state.deactivated) return;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.products, AccessRight.delete)) {
      state = state.copyWith(
        error: ProductFormErrorCode.deactivatePermissionDenied,
        errorDetail: null,
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, errorDetail: null);
    try {
      await ref.read(productRepositoryProvider).update(
            productId: productId,
            deactivated: true,
          );
      ref.invalidate(productsListControllerProvider);
      state = state.copyWith(submitting: false, deactivated: true);
    } on AppError catch (e) {
      state = state.copyWith(
        errorDetail: e.serverMessage,
        submitting: false,
        error: ProductFormErrorCode.deactivateFailed,
      );
    }
  }
}

String? _orNull(String? value) =>
    (value == null || value.isEmpty) ? null : value;

/// Maps mbe-api's `loc`-based field errors onto this form's field keys
/// (camelCase, matching the client-side validation in [_validate]) so
/// server-only rejections (e.g. a concurrent duplicate-code race) render
/// through the same field-error UI as client-side ones (FR-014).
Map<String, String> _fieldErrorsFromServer(ValidationError error) {
  const keyMap = {'bar_code': 'barCode', 'unit_of_measurement': 'unitOfMeasurement'};
  final result = <String, String>{};
  for (final fieldError in error.errors) {
    final locKey = fieldError.loc.isNotEmpty ? fieldError.loc.last : 'error';
    result[keyMap[locKey] ?? locKey] = fieldError.msg;
  }
  return result;
}
