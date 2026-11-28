import 'dart:math' as math;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/purchases/data/purchase_order_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';

part 'to_purchase_controller.g.dart';

/// Groups shown per page on Por comprar.
const toPurchasePageSize = 20;

/// Fetches and holds every Por comprar group for one facility (null: all),
/// in the server's order (spec 080 FR-007, research R5).
///
/// simplified: client-side paging, no search or supplier facet, until
/// mictlanix/mbe-api#354. The endpoint returns every group at once, so the
/// whole response is kept and [toPurchasePage] slices it; when the pending
/// lines outgrow one response, move paging to the server.
@riverpod
class ToPurchaseController extends _$ToPurchaseController {
  @override
  Future<List<ToPurchaseGroup>> build(int? facilityId) => ref
      .watch(purchaseOrderRepositoryProvider)
      .toPurchase(facilityId: facilityId);
}

/// The page [pageIndex] of [groups], [toPurchasePageSize] groups per page.
/// A page past the last one is clamped to the last (as `fetchClampedPage`
/// does for server-paged lists); no groups is page 0, empty.
CatalogPage<ToPurchaseGroup> toPurchasePage(
  List<ToPurchaseGroup> groups,
  int pageIndex,
) {
  final last = groups.isEmpty ? 0 : (groups.length - 1) ~/ toPurchasePageSize;
  final index = pageIndex.clamp(0, last);
  final start = index * toPurchasePageSize;
  return CatalogPage(
    items: groups.sublist(
      math.min(start, groups.length),
      math.min(start + toPurchasePageSize, groups.length),
    ),
    total: groups.length,
    pageIndex: index,
    pageSize: toPurchasePageSize,
  );
}
