import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/presentation/document_access.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';

/// Whether the delivery order's print actions are offered (spec 064 FR-003,
/// FR-004, research R3): the user can read Delivery Orders and the order is
/// past approval. Cancelled orders are included: the server renders them
/// stamped "CANCELADA" so their history can be reprinted.
///
/// A draft or an order awaiting approval is a 409
/// `delivery_order.not_approved` on the server, so no action is offered for
/// them. One rule for the detail screen and the list row, so the two never
/// disagree (as [canOpenDocument]'s other callers do).
bool canPrintDeliveryOrder(
  AccessControlService access,
  DeliveryOrderStatus status,
) =>
    status != DeliveryOrderStatus.draft &&
    status != DeliveryOrderStatus.pendingApproval &&
    canOpenDocument(access, DocumentKind.deliveryTicket);
