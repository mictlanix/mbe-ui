import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/customer_refund_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_refund_repository.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';

part 'refund_editor_controller.g.dart';

/// The write-gate scope refund edits register against (spec 057 R4). Never
/// shared with a sale's scopes.
const customerRefundWritesScope = 'customer-refund';

/// What [RefundEditorController.confirm] did (spec 057 R5).
sealed class RefundConfirmResult {
  const RefundConfirmResult();
}

/// The refund was confirmed. [adjusted] is `true` when the server lowered or
/// dropped a line that was entered (FR-011).
class RefundConfirmed extends RefundConfirmResult {
  const RefundConfirmed({required this.adjusted});
  final bool adjusted;
}

/// The caller has no valid cash session, so nothing was sent. [staleSessionId]
/// is the stale session's id, `null` when there is none (or it could not be
/// read).
class RefundSessionInvalid extends RefundConfirmResult {
  const RefundSessionInvalid({this.staleSessionId});
  final int? staleSessionId;
}

/// One customer refund being edited (spec 057 R4, R5). Every write replaces
/// the whole refund with the server's response; the app never computes a
/// total or a refundable quantity (FR-006).
@riverpod
class RefundEditorController extends _$RefundEditorController {
  /// Tail of the write queue; writes on one refund run one at a time.
  Future<void> _tail = Future<void>.value();

  bool _adjusted = false;

  /// Whether the last [confirm] on this refund lowered or dropped a line.
  bool get adjusted => _adjusted;

  @override
  Future<CustomerRefund> build(int refundId) =>
      ref.read(customerRefundRepositoryProvider).getById(refundId);

  CustomerRefund get _current => state.requireValue;

  /// Sets a line's return quantity. A refused write rethrows its [AppError]
  /// and leaves the state unchanged.
  Future<void> setQuantity(int lineId, String quantity) => _write(
    (repo, refund) => repo.updateLine(refund.id, lineId, quantity: quantity),
  );

  /// Sets a line's return-to warehouse. Same failure behaviour as
  /// [setQuantity].
  Future<void> setWarehouse(int lineId, int warehouseId) => _write(
    (repo, refund) =>
        repo.updateLine(refund.id, lineId, warehouseId: warehouseId),
  );

  /// Re-reads the cash session. `null` when it is valid, otherwise what the
  /// screen shows instead of the payout dialog (contracts C5, FR-009).
  Future<RefundSessionInvalid?> sessionBlock() async {
    try {
      final current = await ref.refresh(
        currentSessionControllerProvider.future,
      );
      if (current.isValid) return null;
      return RefundSessionInvalid(
        staleSessionId: current.session?.cashSessionId,
      );
    } on Object {
      return const RefundSessionInvalid();
    }
  }

  /// Confirms the refund with [payout]. The cash session is re-read first;
  /// without a valid one nothing is sent and [RefundSessionInvalid] comes
  /// back. After a network failure the refund is re-read and published before
  /// the error is rethrown, so a refund that went through is not confirmed
  /// twice.
  Future<RefundConfirmResult> confirm(RefundPayout payout) =>
      _serialized(() async {
        final blocked = await sessionBlock();
        if (blocked != null) return blocked;

        final repo = ref.read(customerRefundRepositoryProvider);
        final before = _current;
        final entered = {
          for (final l in before.lines)
            if (!isZeroAmount(l.quantity)) l.id: l.quantity,
        };
        _adjusted = false;
        return tracked(() async {
          try {
            final confirmed = await repo.confirm(before.id, payout);
            _adjusted = _wasAdjusted(entered, confirmed);
            _publish(confirmed);
            return RefundConfirmed(adjusted: _adjusted);
          } on NetworkError {
            try {
              _publish(await repo.getById(before.id));
            } on AppError {
              // Keep the original failure; the screen still has the draft.
            }
            rethrow;
          }
        });
      });

  /// Cancels the draft refund and publishes the server's answer. A refused
  /// cancel rethrows its [AppError] and leaves the state unchanged.
  Future<void> cancel() => _write((repo, refund) => repo.cancel(refund.id));

  Future<void> _write(
    Future<CustomerRefund> Function(
      CustomerRefundRepository repo,
      CustomerRefund refund,
    )
    action,
  ) => _serialized(
    () => tracked(() async {
      final refund = await action(
        ref.read(customerRefundRepositoryProvider),
        _current,
      );
      _publish(refund);
    }),
  );

  /// Runs [action] after every earlier write on this refund has settled.
  Future<T> _serialized<T>(Future<T> Function() action) {
    final previous = _tail;
    final done = Completer<void>();
    _tail = done.future;
    return previous.then((_) => action()).whenComplete(done.complete);
  }

  /// Registers [action] in the refund write scope, keeping this notifier
  /// alive for its whole run, and publishing before the count drops
  /// (spec 031 research R6).
  Future<T> tracked<T>(Future<T> Function() action) async {
    final keepAlive = ref.keepAlive();
    try {
      return await ref
          .read(pendingWritesProvider(customerRefundWritesScope).notifier)
          .track(action);
    } finally {
      keepAlive.close();
    }
  }

  /// Publishes [refund] unless the screen closed while the request ran.
  void _publish(CustomerRefund refund) {
    if (ref.mounted) state = AsyncValue.data(refund);
  }

  bool _wasAdjusted(Map<int, String> entered, CustomerRefund confirmed) {
    final byId = {for (final l in confirmed.lines) l.id: l.quantity};
    return entered.entries.any((e) {
      final now = byId[e.key];
      return now == null || compareAmounts(now, e.value) < 0;
    });
  }
}
