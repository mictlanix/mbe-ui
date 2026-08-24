import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';

part 'pos_step_controller.g.dart';

/// The three steps a sale can move through (contracts/pos-screen.md §2).
/// `entrega` only ever appears for `delivery`/`mixed` fulfilment — the step
/// indicator shows two steps or three depending on
/// [PosStepState.stepCount].
enum PosStep { venta, cobro, entrega }

/// UI-only state: which step is current, and the fulfilment mode chosen so
/// far. Never persisted — reconstructed from the resumed `Sale`'s own
/// `status`/`shipTo` on reload (contracts/pos-screen.md §5), not from
/// anything held here.
///
/// Whether a write is in flight is no longer tracked here (spec 031 FR-010):
/// this field existed for exactly that and nothing ever set or read it —
/// `pendingWritesProvider(posWritesScope)`
/// (`lib/core/async/critical_action_guard.dart`) is the one mechanism for
/// that question now, read directly by each step's own gate rather than
/// mirrored through this controller.
class PosStepState {
  const PosStepState({
    this.current = PosStep.venta,
    this.mode = FulfillmentMode.counterPickup,
  });

  final PosStep current;
  final FulfillmentMode mode;

  /// FR-005: two steps for counter pickup, three otherwise.
  int get stepCount => mode == FulfillmentMode.counterPickup ? 2 : 3;

  PosStepState copyWith({PosStep? current, FulfillmentMode? mode}) =>
      PosStepState(current: current ?? this.current, mode: mode ?? this.mode);
}

/// The step machine (contracts/pos-screen.md §2). Every transition is a
/// guarded method here rather than a bare setter, so the guards
/// (FR-038, FR-049) live in exactly one place.
@riverpod
class PosStepController extends _$PosStepController {
  @override
  PosStepState build() => const PosStepState();

  void setMode(FulfillmentMode mode) {
    state = state.copyWith(mode: mode);
  }

  /// Jumps directly to a step — used when resuming a sale
  /// (contracts/pos-screen.md §5), not as part of the ordinary forward flow.
  void jumpTo(PosStep step, {FulfillmentMode? mode}) {
    state = state.copyWith(current: step, mode: mode ?? state.mode);
  }

  /// Venta → Cobro, gated on at least one line (FR-038). Callers check this
  /// before invoking `PosSaleController.confirm()`; on success they call
  /// [advanceToCobro].
  bool canConfirm({required int lineCount}) => lineCount > 0;

  void advanceToCobro() {
    state = state.copyWith(current: PosStep.cobro);
  }

  /// Cobro → done (counter pickup) or Cobro → Entrega (delivery/mixed),
  /// gated on a zero balance unless the sale is on credit terms (FR-049,
  /// FR-051).
  bool canLeavePayment({required String balance, required bool isCreditTerms}) =>
      isCreditTerms || isZeroAmount(balance);

  void advanceFromCobro() {
    if (state.mode == FulfillmentMode.counterPickup) return;
    state = state.copyWith(current: PosStep.entrega);
  }

  /// Back to Venta, counter pickup, nothing in flight — what a genuinely new
  /// sale starts from. Distinct from [jumpTo]: that reconstructs a *resumed*
  /// sale's own step/mode (contracts/pos-screen.md §5) and must keep whatever
  /// mode it is given, where this always goes to the one default a fresh
  /// `Sale? == null` starts from. Without it, `PosSaleController.startNew()`
  /// left this controller's `mode` exactly as the finished sale left it, so
  /// `FulfillmentModeSelector` kept showing the previous sale's delivery/mixed
  /// choice already selected on a sale that has not chosen anything yet.
  void reset() {
    state = const PosStepState();
  }
}
