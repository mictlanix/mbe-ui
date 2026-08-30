import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list_delete_preview.dart';

part 'price_list_delete_preview_provider.g.dart';

/// The blast radius of a pending price list retirement — every category of
/// record attached to the list, with counts and a total
/// (specs/034-price-list-retirement-ui FR-001, FR-002).
///
/// Auto-disposing and keyed by [priceListId], so the report is fetched when
/// the delete dialog opens and released when it closes. Its failure is
/// informational, not blocking (research.md R4, mirroring `mergePreview` in
/// `merge_products_comparison_provider.dart`): the dialog degrades to the
/// FR-020 state rather than becoming unusable.
@riverpod
Future<PriceListDeletePreview> priceListDeletePreview(
  PriceListDeletePreviewRef ref, {
  required int priceListId,
}) {
  return ref
      .read(priceListRepositoryProvider)
      .deletePreview(priceListId: priceListId);
}
