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

    // simplified: no warehouse choice yet, the preview is always unlimited; the
    // warehouse choice (spec 064 US3) adds the chooser here.
    await documents.preview(
      context,
      DocumentRef(
        kind: DocumentKind.deliveryTicket,
        recordId: orderId,
        title: l10n.documentDeliveryTicketTitle(folio),
      ),
    );
  } finally {
    inFlight.remove(orderId);
  }
}
