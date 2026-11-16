import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/inventory/data/inventory_receipt_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';

part 'inventory_receipt_detail_controller.g.dart';

/// One receipt for its detail screen, keyed by id (spec 067). A failed load
/// keeps the repository's `AppError` (a missing receipt is a `NotFound`).
///
/// Writes go through `InventoryReceiptActions`, which puts the receipt the
/// server returned straight into this provider.
@riverpod
class InventoryReceiptDetailController
    extends _$InventoryReceiptDetailController {
  @override
  Future<InventoryReceipt> build(int id) =>
      ref.watch(inventoryReceiptRepositoryProvider).get(id);

  /// Re-fetches the receipt, keeping the current one on screen meanwhile.
  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(inventoryReceiptRepositoryProvider).get(id),
    );
  }

  /// Shows [receipt], the server's answer to a write.
  void put(InventoryReceipt receipt) => state = AsyncData(receipt);
}
