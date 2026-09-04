import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';

/// The mutation bodies [PosSaleController] and the back-office order
/// controller share (research §R1) — each is "call the repository, replace
/// `state` with the response, track the write in this notifier's own
/// [writesScope]". Extracted from `PosSaleController`, which used to own
/// this outright, so a second `SaleEditor` implementation doesn't have to
/// duplicate it.
///
/// No `on` clause: the common ancestor both `PosSaleController` (a plain
/// `@riverpod` class, generated base `AutoDisposeAsyncNotifier<Sale?>`) and
/// the order-id-keyed family notifier (generated base
/// `BuildlessAutoDisposeAsyncNotifier<Sale?>`) actually share is that
/// package-private type, which cannot be named from outside `package:
/// riverpod` — verified against the generated code for both shapes rather
/// than assumed. Declaring [ref] and [state] here instead, matching
/// `AsyncNotifierBase`'s own signatures exactly, lets Dart's structural
/// mixin application satisfy them from whichever concrete base a mixing-in
/// class actually has.
mixin SaleEditing implements SaleEditor {
  // The exact type both generated bases actually declare in riverpod 2.6.1
  // — deprecated in favor of plain `Ref` in a later major version, but
  // that alias isn't a valid override of this one today, and this is a
  // structural mixin with no `on` clause to inherit the type from.
  // ignore: deprecated_member_use
  AutoDisposeAsyncNotifierProviderRef<Sale?> get ref;
  AsyncValue<Sale?> get state;
  set state(AsyncValue<Sale?> value);
  /// The scope this notifier's writes and unconfirmed edits register
  /// against (spec 031, spec 029 FR-038) — `posWritesScope` for the
  /// register, `salesOrderWritesScope` for the back-office order screen.
  /// Never shared between the two.
  String get writesScope;

  @override
  Future<Sale> ensureOpen() async {
    final current = state.valueOrNull;
    if (current != null) return current;
    final opened = await ref.read(salesOrderRepositoryProvider).open();
    state = AsyncValue.data(opened);
    return opened;
  }

  /// For the mutations that cannot be a first action — there is nothing to
  /// update, remove or confirm before a sale exists.
  Sale get openSale {
    final current = state.valueOrNull;
    if (current == null) {
      throw StateError('This action needs an open sale; none is started.');
    }
    return current;
  }

  /// Registers this call in `pendingWritesProvider(writesScope)` for the
  /// whole of [action] — including [action]'s own
  /// `state = AsyncValue.data(...)` assignment, which must happen *before*
  /// [action] returns so the count only reaches zero once the figures a
  /// gated step reads are already the sale's own (spec 031 FR-003, research
  /// R6). Every mutating method below routes through this rather than
  /// registering by hand.
  Future<T> tracked<T>(Future<T> Function() action) =>
      ref.read(pendingWritesProvider(writesScope).notifier).track(action);

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
    // sale — no sale open yet, and nothing beyond customer/salesperson
    // requested — opens with both already set, one POST instead of an empty
    // create followed by this same method's own PUT below. Any other field
    // requested alongside falls through to the general path unchanged,
    // since `open()` only ever takes these two.
    if (state.valueOrNull == null &&
        paymentTerms == null &&
        currency == null &&
        shipTo == null &&
        contact == null &&
        customerName == null &&
        fulfillmentIntent == null &&
        promiseDate == null &&
        priority == null &&
        comment == null &&
        recipient == null) {
      state = AsyncValue.data(
        await repository.open(customer: customer, salesperson: salesperson),
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
