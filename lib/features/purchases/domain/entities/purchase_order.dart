import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';

part 'purchase_order.freezed.dart';

/// One row of the purchase orders list (spec 080 data-model). The status is
/// the warehouse-document one: draft, completed (Confirmada), cancelled.
@freezed
abstract class PurchaseOrderSummary with _$PurchaseOrderSummary {
  const factory PurchaseOrderSummary({
    /// The order number.
    required int id,
    required InventoryDocumentStatus status,
    int? supplierId,
    String? supplierName,

    /// The wall-clock value the server holds; the UI shows the date only.
    DateTime? estimatedReceiptDate,
    String? comment,
    required int creatorId,
    required int updaterId,
    required DateTime createdAt,
    required DateTime modifiedAt,
    required int lineCount,
    required Decimal subtotal,
    required Decimal tax,
    required Decimal total,
  }) = _PurchaseOrderSummary;
}

/// A page of orders.
typedef PurchaseOrderPage = CatalogPage<PurchaseOrderSummary>;

/// A line of an order. The product code and name are snapshotted on the order.
@freezed
abstract class PurchaseOrderLine with _$PurchaseOrderLine {
  const factory PurchaseOrderLine({
    required int id,
    required int productId,
    required String productCode,
    required String productName,
    int? warehouseId,

    /// More than 0, up to 4 decimals.
    required Decimal quantity,

    /// Unit price before tax, 0 or more, up to 7 decimals.
    required Decimal price,

    /// A fraction: 0 up to (not including) 1.
    required Decimal taxRate,
    required Decimal amount,

    /// The request line this line came from.
    int? requestLineId,
    int? requestId,

    /// Null on a non-stockable product.
    Decimal? quantityReceived,
    Decimal? quantityPending,
  }) = _PurchaseOrderLine;
}

/// An entry receipt created by confirming an order.
@freezed
abstract class OrderReceipt with _$OrderReceipt {
  const factory OrderReceipt({
    required int id,
    required int warehouseId,
    required int facilityId,
    required int lineCount,
  }) = _OrderReceipt;
}

/// An order in full. The server's `warnings` are English text with no code and
/// are dropped (research R10).
@freezed
abstract class PurchaseOrder with _$PurchaseOrder {
  const factory PurchaseOrder({
    required int id,
    required InventoryDocumentStatus status,
    int? supplierId,
    String? supplierName,
    DateTime? estimatedReceiptDate,
    String? comment,
    required int creatorId,
    required int updaterId,
    required DateTime createdAt,
    required DateTime modifiedAt,
    required int lineCount,
    required Decimal subtotal,
    required Decimal tax,
    required Decimal total,
    required List<PurchaseOrderLine> lines,

    /// Only the count of `skipped` is used; the reasons are uncoded
    /// (mictlanix/mbe-api#353).
    @Default(0) int skippedCount,

    /// Filled only by the confirm response until mictlanix/mbe-api#355.
    @Default([]) List<OrderReceipt> receipts,
  }) = _PurchaseOrder;
}

/// One pending purchase-request line in a Por comprar group.
@freezed
abstract class ToPurchaseLine with _$ToPurchaseLine {
  const factory ToPurchaseLine({
    required int requestLineId,
    required int requestId,
    int? serial,
    required int productId,
    required String productCode,
    String? productName,
    required Decimal quantity,
    required int warehouseId,

    /// 0 means "sin costo".
    required Decimal cost,
  }) = _ToPurchaseLine;
}

/// Pending lines for one supplier and facility.
@freezed
abstract class ToPurchaseGroup with _$ToPurchaseGroup {
  const factory ToPurchaseGroup({
    /// Null is "Sin proveedor": no order can be created from it.
    int? supplierId,
    String? supplierName,
    required int facilityId,
    required int lineCount,
    required Decimal estimatedTotal,
    required List<ToPurchaseLine> lines,
  }) = _ToPurchaseGroup;
}

/// What an order email returned.
@freezed
abstract class OrderEmailReceipt with _$OrderEmailReceipt {
  const factory OrderEmailReceipt({
    required List<String> recipients,
    required DateTime sentAt,
  }) = _OrderEmailReceipt;
}
