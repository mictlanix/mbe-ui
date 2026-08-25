import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editing.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';
import 'package:mbe_ui/features/sales/presentation/sales_order_write_scope.dart';

part 'order_editor_controller.g.dart';

/// The back-office order screen's own [SaleEditor] — the twin of
/// `PosSaleController`, keyed by [orderId] instead of held as a singleton
/// (spec 029 data-model.md §5.2). `autoDispose` is deliberate here, unlike
/// the register's own choice to stay resident: a back-office user opens many
/// orders in a session and each one's state should die with its route.
///
/// [orderId] is `null` for a brand-new order — [build] returns `null` and
/// writes **nothing** (FR-015, SC-005); the order is created by whichever
/// action is first, exactly as [PosSaleController.ensureOpen] does for the
/// register.
@riverpod
class OrderEditorController extends _$OrderEditorController
    with SaleEditing
    implements SaleEditor {
  @override
  Future<Sale?> build(int? orderId) async {
    if (orderId == null) return null;
    return ref.read(salesOrderRepositoryProvider).getById(saleId: orderId);
  }

  @override
  String get writesScope => salesOrderWritesScope;

  /// Re-fetches the order without mutating it — mirrors
  /// `PosSaleController.refresh`, for the stale-draft case (US2 scenario 5):
  /// a mutation refused because the order is no longer editable re-reads it
  /// rather than leaving stale controls on screen.
  Future<void> refresh() async {
    final current = state.value;
    if (current == null) return;
    final repository = ref.read(salesOrderRepositoryProvider);
    final refreshed = await repository.getById(saleId: current.id);
    state = AsyncValue.data(refreshed);
  }

  /// `POST /sales-orders/{id}/cancel` — this controller's own action; no
  /// shared widget calls it, so it is not on [SaleEditor] (FR-026).
  Future<void> cancel() => tracked(() async {
    final current = openSale;
    await ref.read(salesOrderRepositoryProvider).cancel(saleId: current.id);
    // The repository's `cancel` returns `void` — mbe-api's own response
    // shape for this endpoint carries no updated order — so the cancelled
    // state is read back explicitly rather than assumed.
    final refreshed = await ref
        .read(salesOrderRepositoryProvider)
        .getById(saleId: current.id);
    state = AsyncValue.data(refreshed);
  });
}
