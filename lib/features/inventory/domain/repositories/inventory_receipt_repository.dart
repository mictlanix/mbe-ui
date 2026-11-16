import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';

/// Warehouse receipts (spec 067), over the generated `InventoryReceiptsApi`.
/// Every method throws `AppError` on failure. Every mutation returns the full
/// receipt.
abstract class InventoryReceiptRepository {
  /// `GET /inventory-receipts?status&warehouse&skip&limit`. The server orders
  /// newest first.
  Future<InventoryReceiptPage> list({
    InventoryDocumentStatus? status,
    int? warehouseId,
    required int skip,
    required int limit,
  });

  /// `GET /inventory-receipts/{id}`.
  Future<InventoryReceipt> get(int id);

  /// `POST /inventory-receipts`: a draft.
  Future<InventoryReceipt> create({required int warehouseId, String? comment});

  /// `PUT /inventory-receipts/{id}`. [warehouseId] is sent only when given.
  /// [clearComment] empties the notes (research R8).
  Future<InventoryReceipt> updateHeader(
    int id, {
    int? warehouseId,
    String? comment,
    bool clearComment = false,
  });

  /// `POST /inventory-receipts/{id}/lines`.
  Future<InventoryReceipt> addLine(
    int id, {
    required int productId,
    required Decimal quantity,
  });

  /// `PUT /inventory-receipts/{id}/lines/{lineId}`.
  Future<InventoryReceipt> updateLine(
    int id,
    int lineId, {
    required Decimal quantity,
  });

  /// `DELETE /inventory-receipts/{id}/lines/{lineId}`.
  Future<InventoryReceipt> removeLine(int id, int lineId);

  /// `POST /inventory-receipts/{id}/confirm`.
  Future<InventoryReceipt> confirm(int id);

  /// `POST /inventory-receipts/{id}/cancel`.
  Future<InventoryReceipt> cancel(int id);

  /// `POST /inventory-receipts/{id}/complementary`: the existing draft (200)
  /// or a new one (201).
  Future<InventoryReceipt> complementary(int id);
}
