import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';

/// A summary for tests; override what the case is about.
PurchaseOrderSummary anOrderSummary({
  int id = 310,
  InventoryDocumentStatus status = InventoryDocumentStatus.draft,
  int? supplierId = 12,
  String? supplierName = 'Ferretera del Norte',
  DateTime? estimatedReceiptDate,
  int creatorId = 5,
  int lineCount = 1,
  String total = '1160.00',
}) => PurchaseOrderSummary(
  id: id,
  status: status,
  supplierId: supplierId,
  supplierName: supplierName,
  estimatedReceiptDate: estimatedReceiptDate,
  creatorId: creatorId,
  updaterId: creatorId,
  createdAt: DateTime(2026, 11, 26, 9, 30),
  modifiedAt: DateTime(2026, 11, 26, 9, 30),
  lineCount: lineCount,
  subtotal: Decimal.parse('1000.00'),
  tax: Decimal.parse('160.00'),
  total: Decimal.parse(total),
);

/// An order for tests; override what the case is about.
PurchaseOrder anOrder({
  int id = 310,
  InventoryDocumentStatus status = InventoryDocumentStatus.draft,
  int? supplierId = 12,
  String? supplierName = 'Ferretera del Norte',
  DateTime? estimatedReceiptDate,
  List<PurchaseOrderLine>? lines,
  int skippedCount = 0,
  List<OrderReceipt> receipts = const [],
}) {
  final items = lines ?? [anOrderLine()];
  return PurchaseOrder(
    id: id,
    status: status,
    supplierId: supplierId,
    supplierName: supplierName,
    estimatedReceiptDate: estimatedReceiptDate,
    creatorId: 5,
    updaterId: 5,
    createdAt: DateTime(2026, 11, 26, 9, 30),
    modifiedAt: DateTime(2026, 11, 26, 9, 30),
    lineCount: items.length,
    subtotal: Decimal.parse('1000.00'),
    tax: Decimal.parse('160.00'),
    total: Decimal.parse('1160.00'),
    lines: items,
    skippedCount: skippedCount,
    receipts: receipts,
  );
}

/// A line for tests; override what the case is about.
PurchaseOrderLine anOrderLine({
  int id = 900,
  int productId = 7,
  String code = 'A-100',
  String name = 'Tornillo 1/4 caja',
  String quantity = '8',
  String price = '125.00',
  String taxRate = '0.16',
  int? warehouseId = 3,
  int? requestId,
  String? received,
  String? pending,
}) => PurchaseOrderLine(
  id: id,
  productId: productId,
  productCode: code,
  productName: name,
  warehouseId: warehouseId,
  quantity: Decimal.parse(quantity),
  price: Decimal.parse(price),
  taxRate: Decimal.parse(taxRate),
  amount: Decimal.parse(quantity) * Decimal.parse(price),
  requestId: requestId,
  quantityReceived: received == null ? null : Decimal.parse(received),
  quantityPending: pending == null ? null : Decimal.parse(pending),
);

/// A Por comprar group for tests.
ToPurchaseGroup aToPurchaseGroup({
  int? supplierId = 12,
  String? supplierName = 'Ferretera del Norte',
  int facilityId = 2,
  List<ToPurchaseLine>? lines,
}) {
  final items = lines ?? [aToPurchaseLine()];
  return ToPurchaseGroup(
    supplierId: supplierId,
    supplierName: supplierName,
    facilityId: facilityId,
    lineCount: items.length,
    estimatedTotal: Decimal.parse('1000.00'),
    lines: items,
  );
}

ToPurchaseLine aToPurchaseLine({
  int requestLineId = 900,
  int requestId = 212,
  int? serial = 571,
  String cost = '125.00',
}) => ToPurchaseLine(
  requestLineId: requestLineId,
  requestId: requestId,
  serial: serial,
  productId: 7,
  productCode: 'A-100',
  productName: 'Tornillo 1/4 caja',
  quantity: Decimal.parse('8'),
  warehouseId: 3,
  cost: Decimal.parse(cost),
);

/// A generated receipt for tests.
OrderReceipt aReceipt({int id = 70, int warehouseId = 3, int facilityId = 2}) =>
    OrderReceipt(
      id: id,
      warehouseId: warehouseId,
      facilityId: facilityId,
      lineCount: 1,
    );
