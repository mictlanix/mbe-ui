import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';

/// Purchase orders (spec 080), over the generated `PurchaseOrdersApi`. Every
/// method throws `AppError` on failure. Every mutation returns the full order.
/// Orders are not facility-scoped, so no method takes a facility except Por
/// comprar.
abstract class PurchaseOrderRepository {
  /// `GET /purchase-orders`. The server orders newest first and decides the
  /// default scope; [all] widens it. [orderId] is the order number search. The
  /// filter is passed as its parts so the domain does not depend on the
  /// presentation-layer filter class. No `facility` is ever sent (FR-003).
  Future<PurchaseOrderPage> list({
    bool all = false,
    InventoryDocumentStatus? status,
    int? supplierId,
    int? creatorId,
    int? orderId,
    DateTime? from,
    DateTime? to,
    required int skip,
    required int limit,
  });

  /// `GET /purchase-orders/{id}`: no receipts until mictlanix/mbe-api#355.
  Future<PurchaseOrder> get(int id);

  /// `POST /purchase-orders`: a draft.
  Future<PurchaseOrder> create({
    required int supplierId,
    DateTime? estimatedReceiptDate,
    String? comment,
  });

  /// `PUT /purchase-orders/{id}`. Each field is sent only when given.
  /// [clearDate] sends an explicit null date; [clearComment] sends "".
  Future<PurchaseOrder> updateHeader(
    int id, {
    int? supplierId,
    DateTime? estimatedReceiptDate,
    bool clearDate = false,
    String? comment,
    bool clearComment = false,
  });

  /// `POST /purchase-orders/{id}/lines`. Warehouse, price and tax rate are the
  /// server's defaults.
  Future<PurchaseOrder> addLine(
    int id, {
    required int productId,
    required Decimal quantity,
  });

  /// `PUT /purchase-orders/{id}/lines/{lineId}`: only the given fields are
  /// sent.
  Future<PurchaseOrder> updateLine(
    int id,
    int lineId, {
    Decimal? quantity,
    int? warehouseId,
    Decimal? price,
    Decimal? taxRate,
  });

  /// `DELETE /purchase-orders/{id}/lines/{lineId}`.
  Future<PurchaseOrder> removeLine(int id, int lineId);

  /// `POST /purchase-orders/{id}/request-lines`; the result carries
  /// `skippedCount`.
  Future<PurchaseOrder> addRequestLines(int id, {required int requestId});

  /// `POST /purchase-orders/{id}/confirm`; the result carries the receipts.
  Future<PurchaseOrder> confirm(int id);

  /// `POST /purchase-orders/{id}/cancel`.
  Future<PurchaseOrder> cancel(int id);

  /// `GET /purchase-orders/to-purchase`: every group, in the server's order.
  Future<List<ToPurchaseGroup>> toPurchase({int? facilityId});

  /// `POST /purchase-orders/to-purchase`; the result carries `skippedCount`.
  Future<PurchaseOrder> createFromGroup({
    required int supplierId,
    required int facilityId,
  });

  /// `POST /purchase-orders/{id}/email`: 1 to 10 recipients, a message of up
  /// to 1000 characters.
  Future<OrderEmailReceipt> email(
    int id, {
    required List<String> recipients,
    String? message,
  });
}
