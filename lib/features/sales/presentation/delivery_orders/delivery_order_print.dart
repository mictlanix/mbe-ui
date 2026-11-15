import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/presentation/document_actions.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

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

/// Opens the delivery ticket of order [orderId] in the shared preview (spec 064
/// contracts U3). The server chooses the delivery or the pickup ticket; the
/// app never does (FR-022).
///
/// [warehouseIds] are the warehouses the order's lines come from, when the
/// caller already knows them (the detail screen does). [facilityId] names the
/// warehouses in the chooser.
///
/// Printing records nothing and reloads nothing (FR-041).
Future<void> openDeliveryTicket(
  BuildContext context,
  WidgetRef ref, {
  required int orderId,
  required String folio,
  required int facilityId,
  List<int>? warehouseIds,
}) async {
  final l10n = AppLocalizations.of(context)!;
  // simplified: no warehouse choice yet, the preview is always unlimited; the
  // warehouse choice (spec 064 US3) adds the chooser here.
  await ref
      .read(documentActionsProvider)
      .preview(
        context,
        DocumentRef(
          kind: DocumentKind.deliveryTicket,
          recordId: orderId,
          title: l10n.documentDeliveryTicketTitle(folio),
        ),
      );
}
