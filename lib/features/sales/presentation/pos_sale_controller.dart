import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

part 'pos_sale_controller.g.dart';

/// The single owner of the current [Sale] (research.md §1). Every mutation
/// calls its repository endpoint and replaces `state` wholesale with the
/// response — the screen never recomputes totals locally (FR-007, FR-008).
///
/// A rejected mutation leaves `state` at its last accepted value: callers
/// catch the thrown `AppError` themselves and render it inline (FR-009)
/// rather than letting this notifier surface it as `AsyncError`, which
/// would blank the whole sale from view.
///
/// **`null` until the cashier does something.** `open()` is a `POST` that
/// creates a draft server-side, so calling it from `build` left an empty sale
/// behind on every visit to the screen — every reload, every navigation back,
/// every hot restart. Measured on a live register: 12 of a day's 21 drafts
/// were empty, 39 had accumulated in total. The draft is now created by the
/// first action that needs one, so a register nobody has touched writes
/// nothing.
@riverpod
class PosSaleController extends _$PosSaleController {
  @override
  Future<Sale?> build() async => null;

  /// The sale in hand, opening one if the cashier has not started yet.
  ///
  /// Every action that can legitimately be the *first* goes through this:
  /// adding a line, editing the header, and the product lookup — which prices
  /// against a customer, and the customer is the sale's. The rest
  /// ([updateLine], [removeLine], [confirm]) are impossible before a sale
  /// exists and assert one instead.
  Future<Sale> ensureOpen() async {
    final current = state.valueOrNull;
    if (current != null) return current;
    final opened = await ref.read(salesOrderRepositoryProvider).open();
    state = AsyncValue.data(opened);
    return opened;
  }

  /// For the mutations that cannot be a first action — there is nothing to
  /// update, remove or confirm before a sale exists.
  Sale get _openSale {
    final current = state.valueOrNull;
    if (current == null) {
      throw StateError('This action needs an open sale; none is started.');
    }
    return current;
  }

  /// Loads an existing sale instead of opening a new one — the open-sales
  /// selector's "resume" action (US3).
  Future<void> load(int saleId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(salesOrderRepositoryProvider).getById(saleId: saleId),
    );
  }

  /// Re-fetches the sale from the server without mutating it — for callers
  /// outside this controller's own mutations whose write changes something
  /// about the sale through a *different* repository (notably
  /// `PaymentController`, since applying a payment changes `Sale.balance`
  /// via `CustomerPaymentRepository`, not this one — contracts/pos-screen.md
  /// §3–§4).
  Future<void> refresh() async {
    final current = state.value;
    if (current == null) return;
    final repository = ref.read(salesOrderRepositoryProvider);
    final refreshed = await repository.getById(saleId: current.id);
    state = AsyncValue.data(refreshed);
  }

  Future<void> updateHeader({
    int? customer,
    PaymentTerms? paymentTerms,
    Currency? currency,
    int? shipTo,
    int? contact,
    String? customerName,
    FulfillmentMode? fulfillmentIntent,
  }) async {
    final current = await ensureOpen();
    final repository = ref.read(salesOrderRepositoryProvider);
    final updated = await repository.updateHeader(
      saleId: current.id,
      customer: customer,
      paymentTerms: paymentTerms,
      currency: currency,
      shipTo: shipTo,
      contact: contact,
      customerName: customerName,
      fulfillmentIntent: fulfillmentIntent,
    );
    state = AsyncValue.data(updated);
  }

  Future<void> addLine({
    required int product,
    String? quantity,
    String? price,
    String? discountRate,
    String? taxRate,
    int? warehouse,
    String? comment,
  }) async {
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
  }

  Future<void> updateLine({
    required int lineId,
    String? quantity,
    String? price,
    String? discountRate,
    String? taxRate,
    int? warehouse,
    String? comment,
  }) async {
    final current = _openSale;
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
  }

  Future<void> removeLine(int lineId) async {
    final current = _openSale;
    final repository = ref.read(salesOrderRepositoryProvider);
    final updated = await repository.removeLine(
      saleId: current.id,
      lineId: lineId,
    );
    state = AsyncValue.data(updated);
  }

  /// "Continuar al cobro" — assigns the folio, commits stock, freezes the
  /// document (FR-038–FR-040). Throws the server's `AppError` on refusal
  /// (zero-priced lines, insufficient stock, no lines); the caller renders
  /// it on the capture step without leaving it.
  Future<void> confirm() async {
    final current = _openSale;
    final repository = ref.read(salesOrderRepositoryProvider);
    final updated = await repository.confirm(saleId: current.id);
    state = AsyncValue.data(updated);
  }

  /// Starts a fresh sale, discarding the currently-held one from view (it
  /// stays open server-side and reachable from the selector) — "start a new
  /// sale" (FR-050, US3 scenario 3).
  /// Returns the register to its empty state rather than opening a draft —
  /// a cashier who finishes a sale and walks away leaves nothing behind. The
  /// next scan opens the next sale.
  Future<void> startNew() async {
    state = const AsyncValue.data(null);
  }
}
