import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/data/product_price_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/pricing_validators.dart';
import 'package:mbe_ui/features/pricing/presentation/product_price_row.dart';

part 'pricing_controller.freezed.dart';
part 'pricing_controller.g.dart';

/// Error codes for [PricingRowEditState.error], localized in the UI layer.
abstract final class PricingErrorCode {
  static const invalidAmount = 'invalidAmount';
  static const saveFailed = 'saveFailed';
  static const updatePermissionDenied = 'updatePermissionDenied';
}

/// The pricing screen's overall state: the selected product (if any) and
/// its left-joined price rows (research.md §5). `null` `productId` is the
/// no-selection empty state (US2 §8).
@freezed
class PricingState with _$PricingState {
  const factory PricingState({
    int? productId,
    String? productDisplayText,
    @Default(<ProductPriceRow>[]) List<ProductPriceRow> rows,
    @Default(false) bool loading,
    String? error,
  }) = _PricingState;
}

/// Per-row inline-edit state, keyed by price-list id, so each row can be
/// edited/saved independently.
@freezed
class PricingRowEditState with _$PricingRowEditState {
  const factory PricingRowEditState({
    @Default('') String price,
    @Default('') String lowProfit,
    @Default('') String highProfit,
    @Default(false) bool submitting,
    String? error,
    Map<String, String>? fieldErrors,
  }) = _PricingRowEditState;
}

/// Fetches the full price-list set + the selected product's prices and
/// left-joins them (research.md §5); routes each row save to create-vs-
/// update depending on whether a price already exists for that list
/// (data-model.md §3).
@riverpod
class PricingController extends _$PricingController {
  @override
  PricingState build() => const PricingState();

  /// Selects [productId] and loads its price grid. Clearing back to the
  /// empty state (e.g. after a 404 on a stale selection, spec Edge Cases —
  /// "Product deleted from the catalog") is done via [clearSelection].
  Future<void> selectProduct({
    required int productId,
    required String displayText,
  }) async {
    state = PricingState(
      productId: productId,
      productDisplayText: displayText,
      loading: true,
    );
    await _load(productId);
  }

  Future<void> _load(int productId) async {
    try {
      final priceLists = await ref
          .read(priceListRepositoryProvider)
          .list(limit: 100);
      final prices = await ref
          .read(productPriceRepositoryProvider)
          .listByProduct(
            productId: productId,
            limit: priceLists.items.length.clamp(20, 1000),
          );
      state = state.copyWith(
        loading: false,
        rows: buildProductPriceRows(
          priceLists: priceLists.items,
          prices: prices,
        ),
        error: null,
      );
    } on AppError catch (e) {
      if (e is NotFoundError) {
        // The selected product disappeared mid-session — clear back to the
        // empty/no-selection state rather than leaving stale prices on
        // screen (spec Edge Cases).
        clearSelection();
        return;
      }
      state = state.copyWith(loading: false, error: e.serverMessage ?? 'error');
    }
  }

  /// Clears the current selection back to the empty state (US2 §8).
  void clearSelection() => state = const PricingState();

  /// Client-side validation (FR-011) for a row's price/low-profit/
  /// high-profit inputs.
  Map<String, String> _validateRow(PricingRowEditState edit) {
    final errors = <String, String>{};
    if (!PricingValidators.isNonNegativeDecimal(edit.price)) {
      errors['price'] = PricingErrorCode.invalidAmount;
    }
    if (!PricingValidators.isNonNegativeDecimal(edit.lowProfit)) {
      errors['lowProfit'] = PricingErrorCode.invalidAmount;
    }
    if (!PricingValidators.isNonNegativeDecimal(edit.highProfit)) {
      errors['highProfit'] = PricingErrorCode.invalidAmount;
    }
    return errors;
  }

  /// Saves a row's price (FR-009, FR-010). Routes to **create** when the
  /// row has no existing price (`productPriceId == null`) and **update**
  /// otherwise (research.md §5). Returns the validation field errors (empty
  /// on success/submission).
  Future<Map<String, String>> saveRow({
    required int priceListId,
    required PricingRowEditState edit,
  }) async {
    final fieldErrors = _validateRow(edit);
    if (fieldErrors.isNotEmpty) return fieldErrors;

    if (!ref
        .read(accessControlProvider)
        .can(SystemObject.pricing, AccessRight.update)) {
      return {'error': PricingErrorCode.updatePermissionDenied};
    }

    final productId = state.productId;
    if (productId == null) return const {};

    final rowIndex = state.rows.indexWhere(
      (r) => r.priceList.priceListId == priceListId,
    );
    if (rowIndex == -1) return const {};
    final existing = state.rows[rowIndex].price;

    try {
      final saved = existing == null
          ? await ref
                .read(productPriceRepositoryProvider)
                .create(
                  productId: productId,
                  priceListId: priceListId,
                  price: edit.price,
                  lowProfit: edit.lowProfit,
                  highProfit: edit.highProfit,
                )
          : await ref
                .read(productPriceRepositoryProvider)
                .update(
                  productPriceId: existing.productPriceId,
                  price: edit.price,
                  lowProfit: edit.lowProfit,
                  highProfit: edit.highProfit,
                );

      final updatedRows = [...state.rows];
      updatedRows[rowIndex] = ProductPriceRow(
        priceList: state.rows[rowIndex].priceList,
        price: saved,
      );
      state = state.copyWith(rows: updatedRows);
      return const {};
    } on AppError catch (e) {
      if (e is ValidationError) {
        final errors = <String, String>{};
        for (final fe in e.errors) {
          final key = fe.loc.isNotEmpty ? fe.loc.last : 'error';
          errors[key] = fe.msg;
        }
        return errors;
      }
      return {'error': PricingErrorCode.saveFailed};
    }
  }
}
