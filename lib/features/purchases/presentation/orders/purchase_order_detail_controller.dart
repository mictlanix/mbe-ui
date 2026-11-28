import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/purchases/data/purchase_order_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';

part 'purchase_order_detail_controller.g.dart';

/// One order for its detail screen, keyed by id (spec 080 research R11). A
/// failed load keeps the repository's `AppError` (a missing order is a
/// `NotFound`).
///
/// The state is the order plus, in its `receipts`, the receipts the last
/// confirm returned. A plain load has none: `GET` returns none until
/// mictlanix/mbe-api#355.
///
/// Writes go through `PurchaseOrderActions`, which puts the order the server
/// returned straight into this provider.
@riverpod
class PurchaseOrderDetailController extends _$PurchaseOrderDetailController {
  @override
  Future<PurchaseOrder> build(int id) =>
      ref.watch(purchaseOrderRepositoryProvider).get(id);

  /// Re-fetches the order, keeping the current one on screen meanwhile. Keeps
  /// nothing from before: the receipts drop, as they do on the server's
  /// reload.
  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(purchaseOrderRepositoryProvider).get(id),
    );
  }

  /// Shows [order], the server's answer to a write. The receipts already held
  /// stay unless [order] carries some.
  void put(PurchaseOrder order) {
    final held = state.value?.receipts ?? const <OrderReceipt>[];
    state = AsyncData(
      order.receipts.isEmpty && held.isNotEmpty
          ? order.copyWith(receipts: held)
          : order,
    );
  }
}
