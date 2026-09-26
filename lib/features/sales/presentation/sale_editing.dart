import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';
import 'package:mbe_ui/features/sales/presentation/tracked_editing.dart';

/// The mutation bodies [PosSaleController] and the back-office order
/// controller share (research §R1) — each is "call the repository, replace
/// `state` with the response, track the write in this notifier's own
/// [writesScope]". Extracted from `PosSaleController`, which used to own
/// this outright, so a second `SaleEditor` implementation doesn't have to
/// duplicate it.
///
/// Mixes in [TrackedEditing] for the document-agnostic half of that scaffold
/// — `ref`/`state`/`writesScope`, `tracked()`, `openSale` — (spec 040
/// research.md R3) and adds everything a sales order specifically needs:
/// [origin], [ensureOpen]'s call to `SalesOrderRepository.open`, and every
/// mutation body's order-shaped parameters, none of which a quote's own
/// `QuoteEditing` shares.
mixin SaleEditing on TrackedEditing implements SaleEditor {
  /// Which workflow this editor raises orders for (mbe-api#209, spec 039
  /// FR-051) — `SaleOrigin.pointOfSale` for the register,
  /// `SaleOrigin.backOffice` for the order workspace. Declared here rather
  /// than passed in from a widget: the editor is the one thing that always
  /// knows which host it belongs to, so no call site can send the wrong
  /// value, and every path that opens an order carries it without each
  /// caller having to remember.
  SaleOrigin get origin;

  @override
  Future<Sale> ensureOpen() async {
    final current = state.valueOrNull;
    if (current != null) return current;
    // Carries [origin] like every other open: this is the path a register
    // sale takes when the first *scan* opens it rather than a customer pick,
    // and an order that recorded no origin can never be told apart later
    // (`SalesOrderUpdate` has no such field).
    final opened = await ref
        .read(salesOrderRepositoryProvider)
        .open(origin: origin);
    state = AsyncValue.data(opened);
    return opened;
  }

  @override
  Future<void> updateHeader({
    int? customer,
    PaymentTerms? paymentTerms,
    Currency? currency,
    int? shipTo,
    int? contact,
    String? customerName,
    FulfillmentMode? fulfillmentIntent,
    DateTime? promiseDate,
    int? salesperson,
    Priority? priority,
    String? comment,
    String? recipient,
  }) => tracked(() async {
    final repository = ref.read(salesOrderRepositoryProvider);
    // spec 036 research.md R5: the very first customer pick on a brand-new
    // sale — no sale open yet, and nothing beyond customer/salesperson/
    // fulfillmentIntent requested — opens with all three already set, one
    // POST instead of an empty create followed by this same method's own PUT
    // below. `fulfillmentIntent` joined this list in spec 039 (research R3):
    // the back-office order's Cliente step attaches its first customer with
    // an intent to deliver in the same call, and disqualifying that from the
    // fast path would open the order on the server's own default customer
    // for one round trip before this method's PUT corrected it — exactly
    // what FR-014 exists to prevent. Any *other* field requested alongside
    // still falls through to the general path unchanged, since `open()`
    // takes only these three.
    if (state.valueOrNull == null &&
        paymentTerms == null &&
        currency == null &&
        shipTo == null &&
        contact == null &&
        customerName == null &&
        promiseDate == null &&
        priority == null &&
        comment == null &&
        recipient == null) {
      state = AsyncValue.data(
        await repository.open(
          customer: customer,
          salesperson: salesperson,
          fulfillmentIntent: fulfillmentIntent,
          origin: origin,
        ),
      );
      return;
    }
    final current = await ensureOpen();
    final updated = await repository.updateHeader(
      saleId: current.id,
      customer: customer,
      paymentTerms: paymentTerms,
      currency: currency,
      shipTo: shipTo,
      contact: contact,
      customerName: customerName,
      fulfillmentIntent: fulfillmentIntent,
      promiseDate: promiseDate,
      salesperson: salesperson,
      priority: priority,
      comment: comment,
      recipient: recipient,
    );
    state = AsyncValue.data(updated);
  });

  @override
  Future<void> addLine({
    required int product,
    String? quantity,
    String? price,
    String? discountRate,
    String? taxRate,
    int? warehouse,
    String? comment,
  }) => tracked(() async {
    final current = await ensureOpen();
    final repository = ref.read(salesOrderRepositoryProvider);
    final updated = await repository.addLine(
      saleId: current.id,
      product: product,
      quantity: quantity,
      price: price,
      discountRate: discountRate,
      taxRate: taxRate,
      warehouse: warehouse,
      comment: comment,
    );
    state = AsyncValue.data(updated);
  });

  @override
  Future<void> updateLine({
    required int lineId,
    String? quantity,
    String? price,
    String? discountRate,
    String? taxRate,
    int? warehouse,
    String? comment,
  }) => tracked(() async {
    final current = openSale;
    final repository = ref.read(salesOrderRepositoryProvider);
    final updated = await repository.updateLine(
      saleId: current.id,
      lineId: lineId,
      quantity: quantity,
      price: price,
      discountRate: discountRate,
      taxRate: taxRate,
      warehouse: warehouse,
      comment: comment,
    );
    state = AsyncValue.data(updated);
  });

  @override
  Future<void> removeLine(int lineId) => tracked(() async {
    final current = openSale;
    final repository = ref.read(salesOrderRepositoryProvider);
    final updated = await repository.removeLine(
      saleId: current.id,
      lineId: lineId,
    );
    state = AsyncValue.data(updated);
  });

  @override
  Future<void> confirm() => tracked(() async {
    final current = openSale;
    final repository = ref.read(salesOrderRepositoryProvider);
    final updated = await repository.confirm(saleId: current.id);
    state = AsyncValue.data(updated);
  });
}
