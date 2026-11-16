import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';

part 'inventory_warehouse_options.g.dart';

/// Which warehouses Nueva entrada and Editar encabezado offer (spec 067
/// FR-017, research R5).
class InventoryWarehouseScope {
  const InventoryWarehouseScope({this.facilityId, this.noFacility = false});

  /// The facility the options are limited to; `null` offers every warehouse
  /// (an administrator).
  final int? facilityId;

  /// A non-administrator with no facility in their settings: no warehouse is
  /// offered, and the dialog shows the no-sucursal text.
  final bool noFacility;
}

UserSettings? _settings(Ref ref) {
  final state = ref.watch(authProvider).value;
  return state is AuthAuthenticated ? state.user.settings : null;
}

/// The session user's [InventoryWarehouseScope]: every warehouse for an
/// administrator, their own facility's for anyone else.
@riverpod
InventoryWarehouseScope inventoryWarehouseScope(Ref ref) {
  if (ref.watch(accessControlProvider).isAdministrator) {
    return const InventoryWarehouseScope();
  }
  final facilityId = _settings(ref)?.facilityId;
  return facilityId == null
      ? const InventoryWarehouseScope(noFacility: true)
      : InventoryWarehouseScope(facilityId: facilityId);
}

/// The active warehouses within [scope] matching [search], for the dialogs'
/// `CatalogEntityPicker<Warehouse>`. Empty, with no request, when the scope
/// has no facility.
Future<List<Warehouse>> inventoryWarehouseOptions(
  WarehouseRepository repository,
  InventoryWarehouseScope scope,
  String search,
) async {
  if (scope.noFacility) return const [];
  final result = await repository.list(
    search: search.isEmpty ? null : search,
    status: EntityStatus.active,
    facilityId: scope.facilityId,
    limit: 10,
  );
  return result.items;
}

/// The list filter's options: every active warehouse, for everyone, since
/// reading is not limited by facility (FR-017).
Future<List<Warehouse>> inventoryFilterWarehouseOptions(
  WarehouseRepository repository,
  String search,
) => inventoryWarehouseOptions(
  repository,
  const InventoryWarehouseScope(),
  search,
);

/// The warehouse Nueva entrada starts with (FR-005): the user's point-of-sale
/// warehouse. `null` when the user has no point of sale, when a lookup fails,
/// or, for a non-administrator, when that warehouse is outside their own
/// facility, so the starting value is always one the picker would offer.
/// Its name comes from `warehouseDisplayNameProvider`.
@riverpod
Future<int?> inventoryStartingWarehouse(Ref ref) async {
  final pointSaleId = _settings(ref)?.pointSaleId;
  if (pointSaleId == null) return null;
  final scope = ref.watch(inventoryWarehouseScopeProvider);
  if (scope.noFacility) return null;
  try {
    final pointSale = await ref
        .watch(pointSaleRepositoryProvider)
        .get(pointSaleId: pointSaleId);
    final warehouseId = pointSale.warehouseId;
    if (scope.facilityId == null) return warehouseId;
    // The warehouse's own facility, not the point of sale's: the picker
    // filters on the warehouse's.
    final warehouse = await ref
        .watch(warehouseRepositoryProvider)
        .get(warehouseId: warehouseId);
    return warehouse.facilityId == scope.facilityId ? warehouseId : null;
  } catch (_) {
    return null;
  }
}
