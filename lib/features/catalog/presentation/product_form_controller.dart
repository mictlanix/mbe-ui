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
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _ProductFormState;
}

/// Manages the create (and, from US3, edit) product form (FR-003..FR-007,
/// FR-009, FR-014, FR-015).
@riverpod
class ProductFormController extends _$ProductFormController {
  @override
  ProductFormState build() => const ProductFormState();

  void codeChanged(String v) =>
      state = state.copyWith(code: v, error: null, fieldErrors: const {});

  void nameChanged(String v) =>
      state = state.copyWith(name: v, error: null, fieldErrors: const {});

  void brandChanged(String v) => state = state.copyWith(brand: v);
  void modelChanged(String v) => state = state.copyWith(model: v);

  void barCodeChanged(String v) =>
      state = state.copyWith(barCode: v, error: null, fieldErrors: const {});

  void locationChanged(String v) => state = state.copyWith(location: v);

  void unitOfMeasurementChanged(String v) => state = state.copyWith(
        unitOfMeasurement: v,
        error: null,
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
    state = state.copyWith(loading: true, error: null);
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
    } on AppError {
      state = state.copyWith(loading: false, error: 'Failed to load product.');
    }
  }

  /// Client-side validation mirroring contracts/mbe-api-products.md
  /// (FR-005, FR-006, FR-007) so the form fails fast before a round-trip.
  Map<String, String> _validate() {
    final errors = <String, String>{};

    final code = state.code;
    if (code.isEmpty) {
      errors['code'] = 'Code is required.';
    } else if (code.contains(RegExp(r'\s'))) {
      errors['code'] = 'Code must not contain whitespace.';
    } else if (code.length > 25) {
      errors['code'] = 'Code must be at most 25 characters.';
    }

    if (state.name.length < 4 || state.name.length > 250) {
      errors['name'] = 'Name must be between 4 and 250 characters.';
    }

    if (state.unitOfMeasurement.trim().isEmpty) {
      errors['unitOfMeasurement'] = 'Unit of measurement is required.';
    }

    final barCode = state.barCode;
    if (barCode != null &&
        barCode.isNotEmpty &&
        !RegExp(r'^\d{13}$').hasMatch(barCode)) {
      errors['barCode'] = 'Barcode must be empty or exactly 13 digits.';
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
      state = state.copyWith(fieldErrors: fieldErrors, error: null);
      return;
    }

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.products, AccessRight.create)) {
      state = state.copyWith(
        error: 'You no longer have permission to create products.',
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, fieldErrors: const {});
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
          error: 'Failed to create product.',
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
      state = state.copyWith(fieldErrors: fieldErrors, error: null);
      return;
    }

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.products, AccessRight.update)) {
      state = state.copyWith(
        error: 'You no longer have permission to edit products.',
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null, fieldErrors: const {});
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
          error: 'Failed to update product.',
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
        error: 'You no longer have permission to deactivate products.',
      );
      return;
    }

    state = state.copyWith(submitting: true, error: null);
    try {
      await ref.read(productRepositoryProvider).update(
            productId: productId,
            deactivated: true,
          );
      ref.invalidate(productsListControllerProvider);
      state = state.copyWith(submitting: false, deactivated: true);
    } on AppError {
      state = state.copyWith(
        submitting: false,
        error: 'Failed to deactivate product.',
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
