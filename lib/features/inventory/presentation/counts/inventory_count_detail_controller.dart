import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/inventory/data/inventory_count_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';

part 'inventory_count_detail_controller.g.dart';

/// One count for its detail screen, keyed by id (spec 070). A failed load
/// keeps the repository's `AppError` (a missing count is a `NotFound`).
///
/// Writes go through `InventoryCountActions`, which puts the count the
/// server returned straight into this provider, or, for a line write, the
/// lines it changed.
@riverpod
class InventoryCountDetailController extends _$InventoryCountDetailController {
  @override
  Future<InventoryCount> build(int id) =>
      ref.watch(inventoryCountRepositoryProvider).get(id);

  /// Re-fetches the count, keeping the current one on screen meanwhile.
  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(inventoryCountRepositoryProvider).get(id),
    );
  }

  /// Shows [count], the server's answer to a write.
  void put(InventoryCount count) => state = AsyncData(count);

  /// Merges [change], a line write's answer, into the count on screen, or
  /// re-fetches when it doesn't fit (see [InventoryCount.merge]).
  Future<void> apply(InventoryCountLinesChange change) async {
    final merged = state.value?.merge(change);
    if (merged == null) return refresh();
    state = AsyncData(merged);
  }
}
