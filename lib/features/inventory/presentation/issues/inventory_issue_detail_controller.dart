import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/inventory/data/inventory_issue_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_issue.dart';

part 'inventory_issue_detail_controller.g.dart';

/// One issue for its detail screen, keyed by id (spec 068). A failed load
/// keeps the repository's `AppError` (a missing issue is a `NotFound`).
///
/// Writes go through `InventoryIssueActions`, which puts the issue the
/// server returned straight into this provider.
@riverpod
class InventoryIssueDetailController extends _$InventoryIssueDetailController {
  @override
  Future<InventoryIssue> build(int id) =>
      ref.watch(inventoryIssueRepositoryProvider).get(id);

  /// Re-fetches the issue, keeping the current one on screen meanwhile.
  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(inventoryIssueRepositoryProvider).get(id),
    );
  }

  /// Shows [issue], the server's answer to a write.
  void put(InventoryIssue issue) => state = AsyncData(issue);
}
