import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_discount.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_discounts_controller.dart';

part 'customer_discount_dialog_controller.freezed.dart';
part 'customer_discount_dialog_controller.g.dart';

/// Error codes for [CustomerDiscountDialogState.error], localized in the UI
/// layer — same split as `SupplierAgreementDialogErrorCode`.
abstract final class CustomerDiscountDialogErrorCode {
  static const duplicateProduct = 'duplicateProduct';
  static const productMissing = 'productMissing';
  static const discountMissing = 'discountMissing';
  static const saveFailed = 'saveFailed';
  static const deleteFailed = 'deleteFailed';
}

/// Why the percentage text is refused (spec 052 FR-006), localized in the UI
/// layer.
abstract final class CustomerDiscountPercentError {
  static const required = 'required';
  static const invalid = 'invalid';
  static const outOfRange = 'outOfRange';
  static const tooPrecise = 'tooPrecise';
}

/// A percentage has at most this many decimals: the server stores the rate
/// as a fraction with 8, and a fraction is the percentage shifted two places.
const customerDiscountPercentMaxDecimals = 6;

/// The first rule [text] breaks, or `null` when it is a valid percentage.
String? validateCustomerDiscountPercent(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return CustomerDiscountPercentError.required;
  final parsed = Decimal.tryParse(trimmed);
  if (parsed == null) return CustomerDiscountPercentError.invalid;
  if (parsed < Decimal.zero || parsed > Decimal.fromInt(100)) {
    return CustomerDiscountPercentError.outOfRange;
  }
  if (parsed.scale > customerDiscountPercentMaxDecimals) {
    return CustomerDiscountPercentError.tooPrecise;
  }
  return null;
}

/// Form state for the discount dialog (spec 052 FR-004..FR-006). Scoped to
/// one dialog instance — auto-disposed when it closes, so each opening
/// starts blank, or from its `existing` discount.
@freezed
abstract class CustomerDiscountDialogState with _$CustomerDiscountDialogState {
  const CustomerDiscountDialogState._();

  const factory CustomerDiscountDialogState({
    /// The product picked in add mode. Edit mode never changes the product.
    ProductListItem? product,

    /// The field text, as a percentage.
    @Default('') String percent,

    /// `false` until the user edits the field, so a blank new dialog doesn't
    /// open already showing an error, and so an untouched edit sends the
    /// stored rate back exactly as it was.
    @Default(false) bool percentDirty,
    @Default(false) bool submitting,
    @Default(false) bool done,
    String? error,
    String? errorDetail,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = _CustomerDiscountDialogState;

  /// What to show under the field: the rule it breaks, once the user has
  /// touched it.
  String? get percentError =>
      percentDirty ? validateCustomerDiscountPercent(percent) : null;

  bool get percentValid => validateCustomerDiscountPercent(percent) == null;
}

@riverpod
class CustomerDiscountDialogController
    extends _$CustomerDiscountDialogController {
  @override
  CustomerDiscountDialogState build(
    int customerId,
    CustomerDiscount? existing,
  ) => CustomerDiscountDialogState(
    // Seeded at the stored rate's full precision, so an unchanged edit loses
    // nothing; the product is never held here, because it can't change.
    percent: existing == null
        ? ''
        : ref.read(formattersProvider).field.rate(existing.discount),
  );

  /// Whether Save is allowed: a product is chosen (add mode), the percentage
  /// is valid, and no request is in flight.
  bool get canSubmit =>
      (existing != null || state.product != null) &&
      state.percentValid &&
      !state.submitting;

  void productSelected(ProductListItem product) =>
      state = _clearErrors(state.copyWith(product: product));

  /// Drops the picked product so the user can search for another.
  void productCleared() => state = _clearErrors(state.copyWith(product: null));

  void percentChanged(String value) =>
      state = _clearErrors(state.copyWith(percent: value, percentDirty: true));

  Future<void> submit() async {
    if (!canSubmit) return;
    state = _clearErrors(state).copyWith(submitting: true);
    final repository = ref.read(customerRepositoryProvider);
    final current = existing;
    // An untouched edit sends the stored rate back exactly as it was.
    final fraction = current != null && !state.percentDirty
        ? current.discount
        : ref.read(formattersProvider).field.parseRate(state.percent);
    if (fraction == null) {
      state = state.copyWith(submitting: false);
      return;
    }
    try {
      if (current == null) {
        await repository.createDiscount(
          customerId: customerId,
          productId: state.product!.productId,
          discount: fraction,
        );
      } else {
        await repository.updateDiscount(
          customerId: customerId,
          customerDiscountId: current.customerDiscountId,
          discount: fraction,
        );
      }
      ref.invalidate(customerDiscountsControllerProvider(customerId));
      state = state.copyWith(submitting: false, done: true);
    } on AppError catch (e) {
      _fail(e, CustomerDiscountDialogErrorCode.saveFailed);
    }
  }

  Future<void> delete() async {
    final current = existing;
    if (current == null || state.submitting) return;
    state = _clearErrors(state).copyWith(submitting: true);
    try {
      await ref
          .read(customerRepositoryProvider)
          .deleteDiscount(
            customerId: customerId,
            customerDiscountId: current.customerDiscountId,
          );
      ref.invalidate(customerDiscountsControllerProvider(customerId));
      state = state.copyWith(submitting: false, done: true);
    } on AppError catch (e) {
      _fail(e, CustomerDiscountDialogErrorCode.deleteFailed);
    }
  }

  void _fail(AppError e, String genericCode) {
    if (e is ValidationError && e.errors.isNotEmpty) {
      final errors = <String, String>{};
      for (final fieldError in e.errors) {
        final field = fieldError.loc.isEmpty ? null : fieldError.loc.last;
        if (field != null) errors[field] = fieldError.msg;
      }
      state = state.copyWith(submitting: false, fieldErrors: errors);
    } else if (e is ValidationError && existing == null) {
      // A 422 with a plain detail on an add: mbe-api's "Product not found".
      state = state.copyWith(
        submitting: false,
        error: CustomerDiscountDialogErrorCode.productMissing,
      );
    } else if (e is ServerError && e.statusCode == 409) {
      // Someone else added the product first: show what is there now.
      ref.invalidate(customerDiscountsControllerProvider(customerId));
      state = state.copyWith(
        submitting: false,
        error: CustomerDiscountDialogErrorCode.duplicateProduct,
      );
    } else if (e is NotFoundError) {
      // Someone else removed the discount: show what is there now.
      ref.invalidate(customerDiscountsControllerProvider(customerId));
      state = state.copyWith(
        submitting: false,
        error: CustomerDiscountDialogErrorCode.discountMissing,
      );
    } else {
      state = state.copyWith(
        submitting: false,
        error: genericCode,
        errorDetail: e.serverMessage,
      );
    }
  }

  CustomerDiscountDialogState _clearErrors(CustomerDiscountDialogState next) =>
      next.copyWith(error: null, errorDetail: null, fieldErrors: const {});
}
