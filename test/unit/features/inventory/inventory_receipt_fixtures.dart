import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';

/// A summary for tests; override what the case is about.
InventoryReceiptSummary aReceiptSummary({
  int id = 318,
  int warehouseId = 3,
  int? purchaseOrderId,
  int? serial,
  ReceiptStatus status = ReceiptStatus.draft,
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
  ReceiptStatus status = ReceiptStatus.draft,
  String? comment,
  List<InventoryReceiptLine>? lines,
  int serverWarningCount = 0,
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
  serverWarningCount: serverWarningCount,
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
