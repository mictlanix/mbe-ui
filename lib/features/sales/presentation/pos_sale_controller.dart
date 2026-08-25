import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/pos_write_scope.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editing.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';

part 'pos_sale_controller.g.dart';

/// The single owner of the current [Sale] (research.md §1). Every mutation
/// calls its repository endpoint and replaces `state` wholesale with the
/// response — the screen never recomputes totals locally (FR-007, FR-008).
/// The mutation bodies themselves live in [SaleEditing] (spec 029 research
/// §R1) — this class is the register's own registration of that shared
/// behaviour under its own [writesScope], plus the three methods no shared
/// widget calls and that stay this controller's alone: [ensureOpen] and the
/// mutations are inherited; [load], [refresh] and [startNew] are not shared
/// because the back-office order controller has its own versions of the
/// first two and no need at all for the third.
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
class PosSaleController extends _$PosSaleController with SaleEditing implements SaleEditor {
  @override
  Future<Sale?> build() async => null;

  @override
  String get writesScope => posWritesScope;

  /// Loads an existing sale instead of opening a new one — the open-sales
  /// selector's "resume" action (US3).
  ///
  /// Resets [pendingWritesProvider] for this scope (spec 031 FR-001, research
  /// R2): whatever was outstanding belonged to the *previous* sale this
  /// controller held, and none of it can still be relevant to the one about
  /// to replace it.
  Future<void> load(int saleId) async {
    ref.read(pendingWritesProvider(posWritesScope).notifier).reset();
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

  /// Starts a fresh sale, discarding the currently-held one from view (it
  /// stays open server-side and reachable from the selector) — "start a new
  /// sale" (FR-050, US3 scenario 3).
  /// Returns the register to its empty state rather than opening a draft —
  /// a cashier who finishes a sale and walks away leaves nothing behind. The
  /// next scan opens the next sale.
  ///
  /// Resets [pendingWritesProvider] for this scope, for the same reason
  /// [load] does (spec 031 research R2).
  Future<void> startNew() async {
    ref.read(pendingWritesProvider(posWritesScope).notifier).reset();
    state = const AsyncValue.data(null);
  }
}
