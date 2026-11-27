import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';

part 'purchase_request_detail_controller.g.dart';

/// One request for its detail screen, keyed by id (spec 079). A failed load
/// keeps the repository's `AppError` (a missing request is a `NotFound`).
///
/// Writes go through `PurchaseRequestActions`, which puts the request the
/// server returned straight into this provider.
@riverpod
class PurchaseRequestDetailController
    extends _$PurchaseRequestDetailController {
  @override
  Future<PurchaseRequest> build(int id) =>
      ref.watch(purchaseRequestRepositoryProvider).get(id);

  /// Re-fetches the request, keeping the current one on screen meanwhile.
  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(purchaseRequestRepositoryProvider).get(id),
    );
  }

  /// Shows [request], the server's answer to a write.
  void put(PurchaseRequest request) => state = AsyncData(request);
}
