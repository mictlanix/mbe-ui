import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/features/inventory/domain/entities/kardex.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_counts_list_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/inventory_issues_list_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipts_list_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfers_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The label of a kardex movement's source type (research R5). It comes from
/// the number, never from the server's `source_name` (§III).
String kardexSourceLabel(AppLocalizations l10n, int type) => switch (type) {
  1 => l10n.inventoryKardexSourceSalesOrder,
  2 => l10n.inventoryKardexSourceSalesReturn,
  3 => l10n.inventoryKardexSourceWarehouseIssue,
  4 => l10n.inventoryKardexSourceWarehouseReceipt,
  5 => l10n.inventoryKardexSourceTransfer,
  6 => l10n.inventoryKardexSourcePurchaseOrder,
  8 => l10n.inventoryKardexSourceLegacyAdjustment,
  10 => l10n.inventoryKardexSourceDeliveryItinerary,
  12 => l10n.inventoryKardexSourceCount,
  13 => l10n.inventoryKardexSourceCounterDelivery,
  _ => l10n.inventoryKardexSourceFallback,
};

/// The path of a movement's document, or null when the type has no screen
/// or the user lacks the read right that screen's route is gated on, so a
/// link never leads to a redirect (FR-011, research R5).
///
/// The sales paths are written out rather than imported, so inventory does
/// not depend on the sales presentation layer; each matches its route in
/// `app_router.dart`.
String? kardexDocumentRoute(
  KardexDocumentRef? ref,
  AccessControlService access,
) {
  if (ref == null) return null;
  final (object, path) = switch (ref.type) {
    // SalesOrders (7): the back-office order workspace, `/sales/orders/:orderId`.
    1 => (SystemObject.salesOrders, '/sales/orders'),
    // CustomerRefunds (22): `/sales/refunds/:refundId`.
    2 => (SystemObject.customerRefunds, '/sales/refunds'),
    // InventoryIssues (16).
    3 => (SystemObject.inventoryIssues, inventoryIssuesPath),
    // InventoryReceipts (15). Type 8, the legacy count adjustment, resolves
    // to the receipt it raised.
    4 || 8 => (SystemObject.inventoryReceipts, inventoryReceiptsPath),
    // InventoryTransfers (17).
    5 => (SystemObject.inventoryTransfers, inventoryTransfersPath),
    // PhysicalCountAdjustment (74).
    12 => (SystemObject.physicalCountAdjustment, inventoryCountsPath),
    // DeliveryOrders (71): `/sales/delivery-orders/:deliveryOrderId`. Type
    // 13, a counter delivery, resolves to the delivery order.
    13 => (SystemObject.deliveryOrders, '/sales/delivery-orders'),
    // 6 (purchase order), 10 (itinerary) and any other: no screen.
    _ => (null, null),
  };
  if (object == null || !access.can(object, AccessRight.read)) return null;
  return '$path/${ref.id}';
}
