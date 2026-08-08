import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
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

/// Where a sale should reopen, derived from the sale itself rather than from
/// anything the screen held (FR-057, contracts/pos-screen.md §5).
///
/// [facilityAddressId] is `null` while it is still loading; the mode then
/// falls back to counter pickup, which is also what a `null` `shipTo` means,
/// so a slow lookup never silently turns a delivery sale into a counter one —
/// it only delays the third step appearing.
({PosStep step, FulfillmentMode mode}) resumeTargetFor(
  Sale sale, {
  required int? facilityAddressId,
}) {
  final isDelivery =
      facilityAddressId != null &&
      FulfillmentModeEncoding.impliesDelivery(
        shipTo: sale.shipTo,
        facilityAddressId: facilityAddressId,
      );
  final mode = isDelivery ? FulfillmentMode.delivery : FulfillmentMode.counterPickup;

  final step = switch (sale.status) {
    // Still being captured.
    SaleStatus.draft => PosStep.venta,
    // Confirmed but not settled — the money is owed.
    SaleStatus.completed => PosStep.cobro,
    // Paid: a delivery sale still owes its distribution; a counter sale is
    // finished and the screen offers a new one.
    SaleStatus.paid => isDelivery ? PosStep.entrega : PosStep.cobro,
    // Never offered by the selector, but reopen read-only rather than crash.
    SaleStatus.cancelled => PosStep.venta,
  };

  return (step: step, mode: mode);
}
