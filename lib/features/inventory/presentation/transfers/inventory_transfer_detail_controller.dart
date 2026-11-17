import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/inventory/data/inventory_transfer_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';

part 'inventory_transfer_detail_controller.g.dart';

/// One transfer for its detail screen, keyed by id (spec 069). A failed load
/// keeps the repository's `AppError` (a missing transfer is a `NotFound`).
///
/// Writes go through `InventoryTransferActions`, which puts the transfer the
/// server returned straight into this provider.
@riverpod
class InventoryTransferDetailController
    extends _$InventoryTransferDetailController {
  @override
  Future<InventoryTransfer> build(int id) =>
      ref.watch(inventoryTransferRepositoryProvider).get(id);

  /// Re-fetches the transfer, keeping the current one on screen meanwhile.
  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(inventoryTransferRepositoryProvider).get(id),
    );
  }

  /// Shows [transfer], the server's answer to a write.
  void put(InventoryTransfer transfer) => state = AsyncData(transfer);
}
