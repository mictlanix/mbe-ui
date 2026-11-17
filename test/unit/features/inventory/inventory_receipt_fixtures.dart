import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/domain/receipt_cost_warning.dart';

/// A summary for tests; override what the case is about.
InventoryReceiptSummary aReceiptSummary({
  int id = 318,
  int warehouseId = 3,
  int? purchaseOrderId,
  int? serial,
  InventoryDocumentStatus status = InventoryDocumentStatus.draft,
}) => InventoryReceiptSummary(
  id: id,
  facilityId: 2,
  warehouseId: warehouseId,
  purchaseOrderId: purchaseOrderId,
  serial: serial,
  status: status,
  creatorId: 5,
  createdAt: DateTime(2026, 11, 16, 10, 2),
);

/// A receipt for tests; override what the case is about.
InventoryReceipt aReceipt({
  int id = 318,
  int warehouseId = 3,
  int? purchaseOrderId,
  int? serial,
  InventoryDocumentStatus status = InventoryDocumentStatus.draft,
  String? comment,
  List<InventoryReceiptLine>? lines,
  List<ReceiptCostWarning> costWarnings = const [],
}) => InventoryReceipt(
  id: id,
  facilityId: 2,
  warehouseId: warehouseId,
  purchaseOrderId: purchaseOrderId,
  serial: serial,
  status: status,
  creatorId: 5,
  createdAt: DateTime(2026, 11, 16, 10, 2),
  comment: comment,
  updaterId: 5,
  modifiedAt: DateTime(2026, 11, 16, 10, 2),
  lines: lines ?? [aReceiptLine()],
  costWarnings: costWarnings,
);

/// A line for tests; override what the case is about.
InventoryReceiptLine aReceiptLine({
  int id = 900,
  int productId = 7,
  String quantity = '8',
  int? purchaseOrderLineId,
  String ordered = '0',
  String? elsewhere,
}) => InventoryReceiptLine(
  id: id,
  productId: productId,
  productCode: 'A-100',
  productName: 'Tornillo 1/4 caja',
  quantity: Decimal.parse(quantity),
  purchaseOrderLineId: purchaseOrderLineId,
  quantityOrdered: Decimal.parse(ordered),
  quantityReceivedElsewhere: elsewhere == null
      ? null
      : Decimal.parse(elsewhere),
);
