import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
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
@riverpod
class PosSaleController extends _$PosSaleController {
  @override
  Future<Sale> build() {
    return ref.watch(salesOrderRepositoryProvider).open();
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
  }) async {
    final current = state.requireValue;
    final repository = ref.read(salesOrderRepositoryProvider);
    final updated = await repository.updateHeader(
      saleId: current.id,
      customer: customer,
      paymentTerms: paymentTerms,
      currency: currency,
      shipTo: shipTo,
      contact: contact,
      customerName: customerName,
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
    final current = state.requireValue;
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
    final current = state.requireValue;
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
    final current = state.requireValue;
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
    final current = state.requireValue;
    final repository = ref.read(salesOrderRepositoryProvider);
    final updated = await repository.confirm(saleId: current.id);
    state = AsyncValue.data(updated);
  }

  /// Starts a fresh sale, discarding the currently-held one from view (it
  /// stays open server-side and reachable from the selector) — "start a new
  /// sale" (FR-050, US3 scenario 3).
  Future<void> startNew() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(salesOrderRepositoryProvider).open(),
    );
  }
}
