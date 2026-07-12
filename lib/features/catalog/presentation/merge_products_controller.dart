import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/merge_products_state.dart';

part 'merge_products_controller.g.dart';

/// Drives the Merge Products screen (specs/008-merge-products FR-001,
/// FR-005..FR-011). Local UI state, not persisted (constitution §II).
@riverpod
class MergeProductsController extends _$MergeProductsController {
  @override
  MergeProductsState build() => const MergeProductsState();

  void canonicalSelected(ProductListItem item) =>
      state = state.copyWith(canonical: item);

  void duplicateSelected(ProductListItem item) =>
      state = state.copyWith(duplicate: item);

  void canonicalCleared() => state = state.copyWith(canonical: null);

  void duplicateCleared() => state = state.copyWith(duplicate: null);

  /// Submits the merge (FR-008). No-ops if [MergeProductsState.canSubmit]
  /// is `false` — the screen is expected to have already gated this behind
  /// an explicit permanence confirmation (FR-007). On failure, both
  /// selections are preserved so the user can retry or adjust (FR-011).
  Future<void> submit() async {
    if (!state.canSubmit) return;

    final canonical = state.canonical!;
    final duplicate = state.duplicate!;

    state = state.copyWith(submission: const AsyncValue.loading());
    try {
      await ref.read(productRepositoryProvider).mergeProducts(
            productId: canonical.productId,
            duplicateId: duplicate.productId,
          );
      state = state.copyWith(
        submission: const AsyncValue.data(null),
        merged: true,
      );
    } on AppError catch (e, stackTrace) {
      state = state.copyWith(
        submission: AsyncValue.error(e, stackTrace),
      );
    }
  }
}
