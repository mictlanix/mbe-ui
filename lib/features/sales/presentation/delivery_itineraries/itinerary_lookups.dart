import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle_operator.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_pickers.dart';

/// The two reads the itinerary screens still make themselves (spec 075
/// research R2, R4). Names come from the trip since mbe-api#343.
///
/// A failed or forbidden read answers `null` rather than failing the screen:
/// the caller shows "—" for the open quantities, or no licence warning.

/// A stop's delivery order, read once per order for its lines' open
/// quantities (spec 075 R2). Only an Abierto trip needs it: the Pendiente
/// column, "Cargar línea" and the quantity prompt's maximum.
///
/// Not auto-disposed, so every stop card of the trip shares one read.
/// `DeliveryItineraryActions` invalidates it after each write that moves the
/// order's open quantity.
final itineraryOrderProvider = FutureProvider.family<DeliveryOrder?, int>((
  ref,
  deliveryOrderId,
) async {
  try {
    return await ref
        .watch(deliveryOrderAdminRepositoryProvider)
        .getById(deliveryOrderId);
  } catch (_) {
    return null;
  }
});

/// The assigned operator, read for the licence expiry (spec 075 R4).
final vehicleOperatorProvider = FutureProvider.family<VehicleOperator?, int>((
  ref,
  vehicleOperatorId,
) async {
  try {
    return await ref
        .watch(vehicleOperatorRepositoryProvider)
        .get(vehicleOperatorId: vehicleOperatorId);
  } catch (_) {
    return null;
  }
});

/// The names the list's filter drawer shows for a vehicle or operator facet
/// that arrives as a bare id in the URL (a cold load or a shared link). Rows
/// never use these: the server names them (mbe-api#343). `null` on any
/// failure, so the drawer falls back to the number.
final vehicleFacetNameProvider = FutureProvider.family<String?, int>((
  ref,
  vehicleId,
) async {
  try {
    final vehicle = await ref
        .watch(vehicleRepositoryProvider)
        .get(vehicleId: vehicleId);
    return vehicleOptionLabel(vehicle);
  } catch (_) {
    return null;
  }
});

final operatorFacetNameProvider = FutureProvider.family<String?, int>((
  ref,
  operatorId,
) async {
  try {
    return (await ref
            .watch(vehicleOperatorRepositoryProvider)
            .get(vehicleOperatorId: operatorId))
        .driverName;
  } catch (_) {
    return null;
  }
});
