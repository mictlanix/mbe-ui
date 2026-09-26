import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/data/sales_quote_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';
import 'package:mbe_ui/features/sales/presentation/tracked_editing.dart';

/// The quote's own [SaleEditor] mutation bodies (spec 040 research.md R3) —
/// [SaleEditing]'s twin, backed by [salesQuoteRepositoryProvider] instead of
/// `salesOrderRepositoryProvider`. Mixes in [TrackedEditing] for the
/// document-agnostic scaffold, exactly as [SaleEditing] does.
///
/// `SaleEditor`'s method set is the union both hosts' controllers
/// implement, which is wider than what a quote can actually write: a quote
/// has no `origin`, and `updateHeader`/`addLine`/`updateLine` accept several
/// parameters no quote endpoint has a field for. Each is explicitly ignored
/// below, one line per field, rather than silently dropped — the same
/// discipline `SalesQuoteRepository`'s own doc comment states for why its
/// interface is narrower than `SalesOrderRepository`'s.
mixin QuoteEditing on TrackedEditing implements SaleEditor {
  @override
  Future<Sale> ensureOpen() async {
    final current = state.valueOrNull;
    if (current != null) return current;
    // Unlike `SaleEditing.ensureOpen`, no `origin` is sent — a quote has no
    // such field on `SalesQuoteCreate`, and no path other than conversion
    // (which mbe-api itself stamps) ever needs to tell a quote's raising
    // workflow apart.
    final opened = await ref.read(salesQuoteRepositoryProvider).open();
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
    // Quotes carry no per-document name override — there is no walk-in
    // customer on a quote to override the name of (spec 040 A8).
    String? customerName,
    // Quotes carry no fulfilment intent — that is asked at the counter when
    // an accepted quote is converted, which is after this (spec 040 A2).
    FulfillmentMode? fulfillmentIntent,
    // Quotes carry no promise date — delivery is planned only on the order
    // a conversion produces, never on the quote itself (spec 040 §Out of
    // Scope).
    DateTime? promiseDate,
    int? salesperson,
    // Quotes carry no priority — an order-only concept `SalesQuoteUpdate`
    // has no field for.
    Priority? priority,
    String? comment,
    // Quotes carry no recipient override — `SalesQuoteUpdate` has no such
    // field.
    String? recipient,
  }) => tracked(() async {
    final repository = ref.read(salesQuoteRepositoryProvider);
    // spec 040 FR-009: the very first customer pick on a brand-new quote —
    // no quote open yet, and nothing beyond customer/salesperson
    // requested — opens with both already set, one POST instead of an
    // empty create followed by this same method's own PUT below. Any
    // *other* field requested alongside still falls through to the general
    // path unchanged, since `open()` takes only these two — mirroring
    // `SaleEditing.updateHeader`'s own fast path (spec 036 research.md R5).
    if (state.valueOrNull == null &&
        paymentTerms == null &&
        currency == null &&
        shipTo == null &&
        contact == null &&
        comment == null) {
      state = AsyncValue.data(
        await repository.open(customer: customer, salesperson: salesperson),
      );
      return;
    }
    final current = await ensureOpen();
    final updated = await repository.updateHeader(
      quoteId: current.id,
      customer: customer,
      salesperson: salesperson,
      paymentTerms: paymentTerms,
      currency: currency,
      dueDate: null,
      contact: contact,
      shipTo: shipTo,
      comment: comment,
    );
    state = AsyncValue.data(updated);
  });

  @override
  Future<void> addLine({
    required int product,
    String? quantity,
    String? price,
    String? discountRate,
    // Quotes carry no per-line tax-rate override — the server derives it
    // from the product, and `SalesQuoteLineCreate` has no field to set.
    String? taxRate,
    // Quotes carry no warehouse — spec 040 FR-014. `CaptureStep` never
    // passes one when `showWarehouse: false`, but the ignore is explicit
    // here too, matching the discipline for every other field this mixin
    // silently drops.
    int? warehouse,
    String? comment,
  }) => tracked(() async {
    final current = await ensureOpen();
    final repository = ref.read(salesQuoteRepositoryProvider);
    final updated = await repository.addLine(
      quoteId: current.id,
      product: product,
      quantity: quantity,
      price: price,
      discountRate: discountRate,
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
    final repository = ref.read(salesQuoteRepositoryProvider);
    final updated = await repository.updateLine(
      quoteId: current.id,
      lineId: lineId,
      quantity: quantity,
      price: price,
      discountRate: discountRate,
      comment: comment,
    );
    state = AsyncValue.data(updated);
  });

  @override
  Future<void> removeLine(int lineId) => tracked(() async {
    final current = openSale;
    final repository = ref.read(salesQuoteRepositoryProvider);
    final updated = await repository.removeLine(
      quoteId: current.id,
      lineId: lineId,
    );
    state = AsyncValue.data(updated);
  });

  @override
  Future<void> confirm() => tracked(() async {
    final current = openSale;
    final repository = ref.read(salesQuoteRepositoryProvider);
    final updated = await repository.confirm(quoteId: current.id);
    state = AsyncValue.data(updated);
  });
}
