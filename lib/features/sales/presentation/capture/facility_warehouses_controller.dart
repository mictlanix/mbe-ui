import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';

part 'facility_warehouses_controller.g.dart';

/// The warehouses a line's warehouse picker offers (FR-024) — every
/// warehouse belonging to the sale's own facility. An autodispose family
/// keyed by facility id, since a sale never changes facility mid-capture.
@riverpod
Future<List<Warehouse>> facilityWarehousesController(Ref ref, int facilityId) async {
  final result = await ref
      .watch(warehouseRepositoryProvider)
      .list(facilityId: facilityId, limit: 100);
  return result.items;
}
