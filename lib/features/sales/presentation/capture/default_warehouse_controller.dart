import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';

part 'default_warehouse_controller.g.dart';

/// The warehouse a newly-added line defaults to (FR-024): the warehouse
/// configured for the cashier's point of sale — a point of sale draws from
/// exactly one warehouse (`PointSale.warehouseId`). An autodispose family
/// keyed by point-of-sale id, since a sale never changes point of sale.
@riverpod
Future<int> defaultWarehouseController(Ref ref, int pointSaleId) async {
  final pointSale = await ref
      .watch(pointSaleRepositoryProvider)
      .get(pointSaleId: pointSaleId);
  return pointSale.warehouseId;
}
