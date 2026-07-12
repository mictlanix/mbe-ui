import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';

part 'merge_products_state.freezed.dart';

/// Local UI state for the Merge Products screen (specs/008-merge-products
/// data-model.md "MergeProductsState"). Neither [canonical] nor
/// [duplicate] is persisted until [MergeProductsController.submit]
/// succeeds.
@freezed
class MergeProductsState with _$MergeProductsState {
  const factory MergeProductsState({
    /// The "Product" selection — kept after a merge. `null` until chosen.
    ProductListItem? canonical,
    /// The "Duplicate" selection — removed after a merge. `null` until
    /// chosen.
    ProductListItem? duplicate,
    /// `AsyncData` (idle/success), `AsyncLoading` (in-flight), or
    /// `AsyncError(AppError)` (failed) — drives the in-flight lock (FR-009)
    /// and the error banner (FR-011).
    @Default(AsyncValue<void>.data(null)) AsyncValue<void> submission,
    /// `true` after a successful [MergeProductsController.submit] call —
    /// the screen confirms and returns to the list on this, mirroring
    /// `ProductFormState.saved`/`deleted`'s one-shot-flag convention (a
    /// plain `submission == AsyncData` can't distinguish "just succeeded"
    /// from "never submitted", since idle state starts as `AsyncData(null)`
    /// too).
    @Default(false) bool merged,
  }) = _MergeProductsState;

  const MergeProductsState._();

  bool get bothSelected => canonical != null && duplicate != null;

  bool get isSameProduct =>
      canonical != null &&
      duplicate != null &&
      canonical!.productId == duplicate!.productId;

  /// FR-005, FR-006, FR-009: both selected, distinct, and not already
  /// submitting.
  bool get canSubmit =>
      bothSelected && !isSameProduct && !submission.isLoading;

  /// A code identifying which client-side guard is blocking submission, or
  /// `null` when none applies. Localized in the UI layer (no
  /// `BuildContext`/`AppLocalizations` access here), mirroring
  /// `ProductFormState.error`'s convention.
  String? get validationMessageCode {
    if (!bothSelected) return MergeValidationCode.bothRequired;
    if (isSameProduct) return MergeValidationCode.sameProduct;
    return null;
  }
}

/// Codes for [MergeProductsState.validationMessageCode], mapped to
/// localized text in `merge_products_screen.dart`.
abstract final class MergeValidationCode {
  static const bothRequired = 'bothRequired';
  static const sameProduct = 'sameProduct';
}
