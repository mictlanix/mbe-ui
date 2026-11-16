import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_issue.dart';

/// Warehouse issues (spec 068), over the generated `InventoryIssuesApi`.
/// Every method throws `AppError` on failure. Every mutation returns the full
/// issue.
abstract class InventoryIssueRepository {
  /// `GET /inventory-issues?status&warehouse&skip&limit`. The server orders
  /// newest first.
  Future<InventoryIssuePage> list({
    InventoryDocumentStatus? status,
    int? warehouseId,
    required int skip,
    required int limit,
  });

  /// `GET /inventory-issues/{id}`.
  Future<InventoryIssue> get(int id);

  /// `POST /inventory-issues`: a draft.
  Future<InventoryIssue> create({required int warehouseId, String? comment});

  /// `PUT /inventory-issues/{id}`. [warehouseId] is sent only when given.
  /// [clearComment] empties the notes (research R6).
  Future<InventoryIssue> updateHeader(
    int id, {
    int? warehouseId,
    String? comment,
    bool clearComment = false,
  });

  /// `POST /inventory-issues/{id}/lines`.
  Future<InventoryIssue> addLine(
    int id, {
    required int productId,
    required Decimal quantity,
  });

  /// `PUT /inventory-issues/{id}/lines/{lineId}`.
  Future<InventoryIssue> updateLine(
    int id,
    int lineId, {
    required Decimal quantity,
  });

  /// `DELETE /inventory-issues/{id}/lines/{lineId}`.
  Future<InventoryIssue> removeLine(int id, int lineId);

  /// `POST /inventory-issues/{id}/confirm`.
  Future<InventoryIssue> confirm(int id);

  /// `POST /inventory-issues/{id}/cancel`.
  Future<InventoryIssue> cancel(int id);
}
