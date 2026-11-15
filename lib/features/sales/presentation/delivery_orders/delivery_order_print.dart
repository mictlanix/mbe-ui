import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/presentation/document_actions.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart' show toAppError;
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_ticket_scope_dialog.dart';
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

/// The warehouses [lines] come from, without repeats, in the order they first
/// appear.
List<int> distinctWarehouses(List<DeliveryOrderLine> lines) => [
  ...{for (final line in lines) line.warehouseId},
];

/// Orders whose ticket flow is running (spec 064 research R5). A press on an
/// order already in it does nothing, so the lookup that follows a list press
/// can't start a second flow.
///
/// A provider rather than a global, so the guard belongs to the app's
/// container (constitution §II) and a test starts with it empty. It is a plain
/// mutable set because nothing watches it: the guard is read and written only
/// inside [openDeliveryTicket].
final deliveryTicketsInFlightProvider = Provider<Set<int>>((ref) => <int>{});

/// Opens the delivery ticket of order [orderId] in the shared preview (spec 064
/// contracts U3). The server chooses the delivery or the pickup ticket; the
/// app never does (FR-022).
///
/// [warehouseIds] are the warehouses the order's lines come from, when the
/// caller already knows them (the detail screen does). The list doesn't, since
/// a row has no lines, so with `null` the order is looked up first. A failed
/// lookup shows its message and opens nothing. [facilityId] names the
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
  final inFlight = ref.read(deliveryTicketsInFlightProvider);
  if (!inFlight.add(orderId)) return;
  try {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final fmt = ref.read(formattersProvider);
    final repository = ref.read(deliveryOrderAdminRepositoryProvider);
    final documents = ref.read(documentActionsProvider);

    if (warehouseIds == null) {
      try {
        warehouseIds = distinctWarehouses(
          (await repository.getById(orderId)).lines,
        );
      } on Object catch (error) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              toAppError(error).userMessage(l10n, fmt) ??
                  l10n.documentLoadFailedError,
            ),
          ),
        );
        return;
      }
      if (!context.mounted) return;
    }

    // An order drawing from several warehouses asks which lines to print
    // (FR-010); one warehouse never asks (FR-011). Dismissing the choice
    // opens, and fetches, nothing (FR-012).
    var scope = const DeliveryTicketScope.all();
    if (warehouseIds.length >= 2) {
      final chosen = await showDeliveryTicketScopeDialog(
        context,
        facilityId: facilityId,
        warehouseIds: warehouseIds,
      );
      if (chosen == null || !context.mounted) return;
      scope = chosen;
    }

    final warehouseId = scope.warehouseId;
    await documents.preview(
      context,
      DocumentRef(
        kind: DocumentKind.deliveryTicket,
        recordId: orderId,
        warehouseId: warehouseId,
        title: warehouseId == null
            ? l10n.documentDeliveryTicketTitle(folio)
            : l10n.documentDeliveryTicketWarehouseTitle(
                folio,
                scope.warehouseName!,
              ),
      ),
    );
  } finally {
    inFlight.remove(orderId);
  }
}
