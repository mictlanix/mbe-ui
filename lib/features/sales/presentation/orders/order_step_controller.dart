import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

part 'order_step_controller.g.dart';

/// The two steps a back-office order moves through (spec 039 FR-001,
/// corrected 2026-09-20 — the workspace originally shipped with a third,
/// Cliente, step ahead of Venta; naming a customer was never meant to be a
/// screen of its own, only Venta's own first move, so that step was removed
/// and `CaptureStep` now withholds product capture until a customer is
/// attached instead) — deliberately not `PosStep`: the two hosts do not
/// share a vocabulary (Venta/Cobro/Entrega vs Venta/Entrega), and a union of
/// both would serve neither (research R1).
enum OrderStep { venta, entrega }

/// UI-only state: which step is current. Never persisted — reconstructed
/// from the reopened order's own `status` on load ([resumeTo]), not from
/// anything held here, mirroring `PosStepState`'s own contract.
class OrderStepState {
  const OrderStepState({this.current = OrderStep.venta});

  final OrderStep current;

  OrderStepState copyWith({OrderStep? current}) =>
      OrderStepState(current: current ?? this.current);
}

/// The step machine (contracts/order-workspace.md §2). Every transition is a
/// guarded method here rather than a bare setter, matching
/// `PosStepController`'s own shape.
@riverpod
class OrderStepController extends _$OrderStepController {
  @override
  OrderStepState build() => const OrderStepState();

  /// Venta → Entrega, gated by the host on line count, outstanding writes
  /// and unconfirmed edits before this is ever called (FR-007, FR-008,
  /// FR-022) — this method itself is unconditional, matching
  /// `PosStepController.advanceToCobro`'s own shape.
  void advanceToEntrega() {
    state = state.copyWith(current: OrderStep.entrega);
  }

  /// Entrega → Venta, allowed only while the order is still a draft
  /// (FR-006, spec A2): the first destination created is what commits it,
  /// so once one exists there is no step to return *to* — the lines it
  /// would edit are already fixed. [isDraft] is the caller's own read of the
  /// order's current status, not tracked here.
  bool canReturnToVenta({required bool isDraft}) => isDraft;

  void returnToVenta() {
    state = state.copyWith(current: OrderStep.venta);
  }

  /// Back to Venta, nothing chosen — what a genuinely new order starts
  /// from. Mirrors `PosStepController.reset`.
  void reset() {
    state = const OrderStepState();
  }

  /// Where a reopened order resumes (data-model.md §4, research R2):
  /// derived from `status` alone, with no extra fetch, because for an order
  /// this workspace raised "is no longer a draft" and "has at least one
  /// destination" are the same condition — mbe-api refuses to record a
  /// delivery against an order that is not yet completed (spec A2).
  OrderStep resumeTargetFor(Sale sale) => switch (sale.status) {
    SaleStatus.draft => OrderStep.venta,
    SaleStatus.completed || SaleStatus.paid => OrderStep.entrega,
    // Never offered by this workspace, but resume read-only rather than
    // crash — mirrors `resumeTargetFor`'s own POS fallback.
    SaleStatus.cancelled => OrderStep.venta,
  };

  /// Applies [resumeTargetFor] and jumps there. Called once per reopened
  /// order (the host guards against re-deriving on every rebuild, mirroring
  /// `pos_workspace_screen.dart`'s own `_syncStepTo`).
  void resumeTo(Sale sale) {
    state = state.copyWith(current: resumeTargetFor(sale));
  }
}
