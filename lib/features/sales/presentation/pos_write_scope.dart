/// The point of sale's scope for [pendingWritesProvider]/[unconfirmedEditsProvider]
/// (`lib/core/async/critical_action_guard.dart`) — one register, one scope
/// (spec 031 FR-001…FR-002). Every mutating call on `PosSaleController`,
/// `DeliveryController` and `PaymentController` registers here, and every
/// step's own primary action gates on it.
///
/// This constant is the only sales-specific line in this feature's
/// core-adjacent wiring (FR-011) — the guard itself knows nothing about a
/// sale, a line, or a step.
const posWritesScope = 'pos-sale';
