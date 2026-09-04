import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart'
    show DestinationLineRequest;
import 'package:mbe_ui/features/sales/presentation/pos_confirm.dart';
import 'package:mbe_ui/features/sales/presentation/pos_write_scope.dart';

part 'delivery_controller.g.dart';

/// The destinations recorded against the sale being delivered (FR-030).
///
/// `build()` loads what already exists, which is what makes resuming a
/// part-distributed sale work (contracts/pos-screen.md §5). Each
/// [addDestination] is one repository call carrying that destination's whole
/// line distribution — no trim step, and no ordering requirement between
/// destinations (research §3, mbe-api#138).
///
/// A refused create leaves this list exactly as it was: the failure is thrown
/// for the editor to render, and every already-created destination is
/// untouched (FR-037).
@riverpod
class DeliveryController extends _$DeliveryController {
  @override
  Future<List<Destination>> build(Sale sale) async {
    final destinations = await ref
        .watch(deliveryOrderRepositoryProvider)
        .listForSale(salesOrder: sale.id);
    return [for (final d in destinations) await _labelled(d)];
  }

  /// Fills the display-only address and contact labels the cards render
  /// (data-model.md §5).
  ///
  /// mbe-api returns `ship_to`/`contact` as bare ids, so without this join
  /// every destination reads "Dirección pendiente" and names no recipient —
  /// which makes two destinations indistinguishable, exactly when telling
  /// them apart matters. The customer's own records stay the source of
  /// truth; nothing is copied onto the delivery order.
  Future<Destination> _labelled(Destination destination) async {
    if (destination.isCounterPickup) return destination;
    final customer = await ref.read(
      saleCustomerControllerProvider(sale.customer).future,
    );

    String? addressLabel;
    for (final address in customer.addresses) {
      if (address.addressId == destination.shipTo) {
        addressLabel = address.label;
        break;
      }
    }
    Contact? recipient;
    for (final contact in customer.contacts) {
      if (contact.contactId == destination.contact) {
        recipient = contact;
        break;
      }
    }

    return destination.copyWith(
      addressSummary: addressLabel,
      contactName: recipient?.name,
      contactPhone: recipient?.preferredPhone,
    );
  }

  /// Registers this call in [pendingWritesProvider] for the whole of
  /// [action] — including [action]'s own state-publishing, which must
  /// happen *before* [action] returns so the count only reaches zero once
  /// the distribution a gated step reads is already the sale's own (spec
  /// 031 FR-003, research R6). Every mutating method below routes through
  /// this.
  Future<T> _tracked<T>(Future<T> Function() action) =>
      ref.read(pendingWritesProvider(posWritesScope).notifier).track(action);

  /// Records one addressed destination (FR-027). The **first** destination
  /// (no destinations yet) is the one case where "the obvious, almost-always-
  /// correct assignment" (US7) is worth sending explicitly: every line's full
  /// remaining `claimable` quantity, so the cashier lands on a fully assigned
  /// destination with zero manual entry (FR-023) — still adjustable
  /// afterwards on the resulting card's own stepper (FR-024), and this is one
  /// `create` call, so a refused create leaves nothing partially assigned
  /// (research R12). A second or later destination keeps the explicit empty
  /// `lines: const []`, never omitted (mbe-api#165, research R14): omitting
  /// `lines` claims everything the sale still owes, which is the opposite of
  /// what a destination joining others already in progress should hold
  /// (FR-025).
  Future<Destination> addDestination({
    required int shipTo,
    int? contact,
    DateTime? date,
    String? comment,
  }) => _tracked(() async {
    // spec 036 FR-008/R1: the first delivery-order create needs the sale
    // confirmed first — a no-op once already confirmed (e.g. a payment
    // already ran it, or an earlier destination already did).
    await confirmBeforePayableAction(ref.read, sale);
    final existing = state.valueOrNull ?? const <Destination>[];
    final lines = existing.isEmpty
        ? [
            for (final line in distributionFor(sale: sale, destinations: existing))
              if (compareAmounts(line.claimable, '0') > 0)
                DestinationLineRequest(
                  salesOrderDetail: line.saleLineId,
                  quantity: line.claimable,
                ),
          ]
        : const <DestinationLineRequest>[];
    final created = await ref
        .read(deliveryOrderRepositoryProvider)
        .create(
          salesOrder: sale.id,
          fulfillmentType: FulfillmentType.delivery,
          shipTo: shipTo,
          contact: contact,
          date: date,
          comment: comment,
          lines: lines,
        );

    final labelled = await _labelled(created);
    state = AsyncData([...existing, labelled]);
    return labelled;
  });

  /// Edits an already-created destination's header (spec 030 FR-017…FR-022)
  /// through the endpoint spec 026 already exposed on
  /// [DeliveryOrderRepository] but never called (`updateHeader`) — this is
  /// its first caller. `null` means "unchanged" at every layer, mbe-api's own
  /// `update_order` included (research R9), so a field left as the
  /// destination had it can simply be re-sent as-is; there is no way to
  /// *clear* a previously-set field through this call.
  ///
  /// Line assignments are untouched — this writes the header only, and
  /// [_replace] swaps in the server's response for this one destination
  /// without refetching the list (FR-020, FR-021).
  Future<Destination> updateDestination({
    required int destinationId,
    int? shipTo,
    int? contact,
    DateTime? date,
    String? comment,
  }) => _tracked(() async {
    final updated = await ref
        .read(deliveryOrderRepositoryProvider)
        .updateHeader(
          destinationId: destinationId,
          shipTo: shipTo,
          contact: contact,
          date: date,
          comment: comment,
        );
    return _replace(updated);
  });

  /// FR-036 — sweeps whatever is left into a counter-pickup destination.
  /// `lines` is deliberately omitted: that claims everything the sale still
  /// owes, which is exactly the remainder, computed server-side against the
  /// same figure it validates every other destination against.
  Future<Destination> sweepRemainderToCounter() => _tracked(() async {
    // spec 036 FR-008/R1: same guard as `addDestination` — this can also be
    // the sale's first delivery-order create (a pure-counter-pickup sweep
    // with no prior destination).
    await confirmBeforePayableAction(ref.read, sale);
    final created = await ref
        .read(deliveryOrderRepositoryProvider)
        .create(
          salesOrder: sale.id,
          fulfillmentType: FulfillmentType.counterPickup,
        );

    state = AsyncData([...?state.valueOrNull, created]);
    return created;
  });

  /// Undoes a destination the cashier changed their mind about, releasing the
  /// quantities it held back to the pool.
  Future<void> removeDestination(int destinationId, {required String reason}) =>
      _tracked(() async {
        await ref
            .read(deliveryOrderRepositoryProvider)
            .cancel(destinationId: destinationId, reason: reason);

        state = AsyncData([
          for (final destination in state.valueOrNull ?? const <Destination>[])
            if (destination.id != destinationId) destination,
        ]);
      });

  /// The distribution as it stands, optionally including the destination
  /// being edited but not yet submitted (FR-033).
  List<LineDistribution> distribution({Map<int, String> draft = const {}}) {
    return distributionFor(
      sale: sale,
      destinations: state.valueOrNull ?? const [],
      draft: draft,
    );
  }

  /// Assigns a sale line to a destination that does not yet carry it
  /// (mbe-api#163, FR-018). The card's stepper calls this the first time a
  /// line's quantity is raised above zero; every later change to that same
  /// line goes through [adjustLine] instead — a second `assignLine` on the
  /// same pair is refused with a 409 (research R13), so the caller must not
  /// reach it once `Destination.lines` already carries the line.
  Future<Destination> assignLine({
    required int destinationId,
    required int saleLineId,
    required String quantity,
  }) => _tracked(() async {
    final updated = await ref
        .read(deliveryOrderRepositoryProvider)
        .addLine(
          destinationId: destinationId,
          salesOrderDetail: saleLineId,
          quantity: quantity,
        );
    return _replace(updated);
  });

  /// Adjusts a line the destination already carries (`lineId` is the
  /// destination's own line id, not the sale line's).
  Future<Destination> adjustLine({
    required int destinationId,
    required int lineId,
    required String quantity,
  }) => _tracked(() async {
    final updated = await ref
        .read(deliveryOrderRepositoryProvider)
        .updateLine(destinationId: destinationId, lineId: lineId, quantity: quantity);
    return _replace(updated);
  });

  /// Takes a line's quantity to zero (FR-022) — a real delete, not an update
  /// to `'0'`, since neither `addLine` nor `updateLine` accepts a
  /// non-positive quantity.
  Future<Destination> dropLine({
    required int destinationId,
    required int lineId,
  }) => _tracked(() async {
    final updated = await ref
        .read(deliveryOrderRepositoryProvider)
        .removeLine(destinationId: destinationId, lineId: lineId);
    return _replace(updated);
  });

  /// Re-joins the server's response (which carries no address/contact
  /// labels of its own) and replaces that one destination in [state] —
  /// no refetch of the list (SC-010).
  Future<Destination> _replace(Destination updated) async {
    final labelled = await _labelled(updated);
    state = AsyncData([
      for (final destination in state.valueOrNull ?? const <Destination>[])
        if (destination.id == labelled.id) labelled else destination,
    ]);
    return labelled;
  }
}
