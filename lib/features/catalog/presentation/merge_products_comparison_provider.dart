import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/merge_preview.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';

part 'merge_products_comparison_provider.g.dart';

/// The two full product records the merge review step compares
/// (specs/016-product-merge-review FR-003, FR-005).
///
/// The pickers only hold `ProductListItem`s — enough to identify a product,
/// but not enough for a field-by-field comparison to say anything the
/// suggestion row didn't already (research.md §1). So the review step
/// re-fetches both ids in full.
typedef MergeComparison = ({Product kept, Product deleted});

/// Fetches both selected products in full, in parallel.
///
/// `autoDispose`, keyed by the pair: swapping or re-picking either side
/// re-keys the provider, so the review step can never render a comparison for
/// a product that is no longer selected (FR-010).
///
/// A failure here **blocks** the merge (FR-011) — unlike
/// [mergePreview], whose counts are informational. The screen surfaces the
/// error and leaves the submit button disabled rather than letting an
/// operator confirm a deletion against data that never loaded.
@riverpod
Future<MergeComparison> mergeComparison(
  MergeComparisonRef ref, {
  required int canonicalId,
  required int duplicateId,
}) async {
  final repository = ref.read(productRepositoryProvider);
  final products = await Future.wait([
    repository.get(productId: canonicalId),
    repository.get(productId: duplicateId),
  ]);
  return (kept: products[0], deleted: products[1]);
}

/// The blast radius of the pending merge — every category of record attached
/// to the product marked for deletion, with counts and a total
/// (specs/016-product-merge-review FR-006).
///
/// Deliberately **separate** from [mergeComparison] rather than fetched
/// alongside it: this is informational context, so a failure here must leave
/// the review step fully usable and the merge button untouched (Story 5 #4),
/// whereas a comparison failure blocks. Combining them into one provider
/// would couple those two very different failure policies.
@riverpod
Future<MergePreview> mergePreview(
  MergePreviewRef ref, {
  required int canonicalId,
  required int duplicateId,
}) {
  return ref
      .read(productRepositoryProvider)
      .mergePreview(productId: canonicalId, duplicateId: duplicateId);
}
