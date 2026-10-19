import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';

part 'pos_resume_controller.g.dart';

/// The facility's own address id — what distinguishes "collected here" from
/// "shipped somewhere" in `Sale.shipTo` (data-model.md §4, research §4).
@riverpod
Future<int> facilityAddressController(Ref ref, int facilityId) async {
  final facility = await ref
      .watch(facilityRepositoryProvider)
      .get(facilityId: facilityId);
  return facility.addressId;
}

/// The sale's delivery destinations, for deciding whether a paid delivery sale
/// still owes its distribution (spec 048 R6).
@riverpod
Future<List<Destination>> saleDestinations(Ref ref, int saleId) =>
    ref.watch(deliveryOrderRepositoryProvider).listForSale(salesOrder: saleId);

/// Whether [sale] is for delivery rather than counter pickup.
///
/// [sale.fulfillmentIntent] is tried first — it is what a sale captured after
/// mbe-api#171 actually recorded, `mixed` included. A `null` intent (every
/// older sale, or one from a client that never asks) falls back to the
/// address heuristic, which cannot answer `mixed`. [facilityAddressId] is
/// `null` while it is still loading; the fallback then reads as counter
/// pickup, which is also what a `null` `shipTo` means.
bool saleIsDelivery(Sale sale, {int? facilityAddressId}) {
  final recorded = sale.fulfillmentIntent;
  if (recorded != null) return recorded != FulfillmentMode.counterPickup;
  return facilityAddressId != null &&
      FulfillmentModeEncoding.impliesDelivery(
        shipTo: sale.shipTo,
        facilityAddressId: facilityAddressId,
      );
}

/// Whether a sale opens as the read-only detail instead of a step (spec 048
/// FR-010, FR-014): paid in full, and — for a delivery sale — with every line
/// fully distributed. A `null` [destinations] (loading or failed) is not
/// "distributed", so the sale falls back to Entrega as before.
bool opensAsReadOnlyDetail(
  Sale sale, {
  required bool isDelivery,
  List<Destination>? destinations,
}) {
  if (sale.status != SaleStatus.paid || !isZeroAmount(sale.balanceOrZero)) {
    return false;
  }
  if (!isDelivery) return true;
  if (destinations == null) return false;
  return distributionFor(
    sale: sale,
    destinations: destinations,
  ).every((line) => line.isFullyDistributed);
}

/// Where a sale should reopen, derived from the sale itself rather than from
/// anything the screen held (FR-057, contracts/pos-screen.md §5).
///
/// The mode comes from [saleIsDelivery], and `mixed` is only knowable from a
/// recorded intent — the delivery step's own "leave the rest at the counter"
/// action is what recovers a mixed sale caught by the address fallback
/// (`LineDistributionFoot`).
///
/// A paid, fully settled counter sale still resolves to Cobro here; the
/// workspace overrides that through [opensAsReadOnlyDetail] (spec 048).
///
/// [facilityAddressId] is `null` while it is still loading; a slow lookup
/// never silently turns a delivery sale into a counter one — it only delays
/// the third step appearing.
({PosStep step, FulfillmentMode mode}) resumeTargetFor(
  Sale sale, {
  required int? facilityAddressId,
}) {
  final isDelivery = saleIsDelivery(sale, facilityAddressId: facilityAddressId);
  final mode =
      sale.fulfillmentIntent ??
      (isDelivery ? FulfillmentMode.delivery : FulfillmentMode.counterPickup);

  final step = switch (sale.status) {
    // Still being captured.
    SaleStatus.draft => PosStep.venta,
    // Confirmed but not settled — the money is owed.
    SaleStatus.completed => PosStep.cobro,
    // Paid: a delivery sale still owes its distribution; a counter sale is
    // finished.
    SaleStatus.paid => isDelivery ? PosStep.entrega : PosStep.cobro,
    // Never offered by the selector, but reopen read-only rather than crash.
    SaleStatus.cancelled => PosStep.venta,
  };

  return (step: step, mode: mode);
}
