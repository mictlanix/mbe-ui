import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';

/// Physical inventory counts (spec 070), over the generated
/// `InventoryCountsApi`. Every method throws `AppError` on failure. Every
/// mutation returns the full count.
abstract class InventoryCountRepository {
  /// `GET /inventory-counts?status&warehouse&skip&limit`. The server orders
  /// newest first and decides the scope.
  Future<InventoryCountPage> list({
    InventoryDocumentStatus? status,
    int? warehouseId,
    required int skip,
    required int limit,
  });

  /// `GET /inventory-counts/{id}`.
  Future<InventoryCount> get(int id);

  /// `POST /inventory-counts`: a draft.
  Future<InventoryCount> create({required int warehouseId, String? comment});

  /// `PUT /inventory-counts/{id}`. [warehouseId] is sent only when given;
  /// [comment] is always sent, and null clears it.
  Future<InventoryCount> updateHeader(
    int id, {
    int? warehouseId,
    String? comment,
  });

  /// `PUT /inventory-counts/{id}/lines`: 1–2,000 items, applied whole or not
  /// at all, each replacing its product's quantity. Splitting a longer list
  /// is the caller's job (research R8).
  Future<InventoryCount> setLines(int id, List<CountLineInput> items);

  /// `PUT /inventory-counts/{id}/lines/{lineId}`.
  Future<InventoryCount> updateLine(
    int id,
    int lineId, {
    required Decimal quantity,
  });

  /// `DELETE /inventory-counts/{id}/lines/{lineId}`.
  Future<InventoryCount> removeLine(int id, int lineId);

  /// `POST /inventory-counts/{id}/confirm`.
  Future<CountConfirmResult> confirm(int id, {required bool includeUncounted});

  /// `POST /inventory-counts/{id}/cancel`. Drafts only.
  Future<InventoryCount> cancel(int id);
}
