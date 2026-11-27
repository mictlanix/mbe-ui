import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';

/// A summary for tests; override what the case is about.
PurchaseRequestSummary aRequestSummary({
  int id = 212,
  int? serial,
  PurchaseRequestStatus status = PurchaseRequestStatus.draft,
  int warehouseId = 3,
  int? facilityId = 2,
  int creatorId = 5,
  int lineCount = 1,
  String? comment,
}) => PurchaseRequestSummary(
  id: id,
  serial: serial,
  status: status,
  warehouseId: warehouseId,
  facilityId: facilityId,
  date: DateTime(2026, 11, 26, 9, 30),
  creatorId: creatorId,
  updaterId: creatorId,
  lineCount: lineCount,
  comment: comment,
);

/// A request for tests; override what the case is about.
PurchaseRequest aRequest({
  int id = 212,
  int? serial,
  PurchaseRequestStatus status = PurchaseRequestStatus.draft,
  int warehouseId = 3,
  int? facilityId = 2,
  String? comment,
  int? approverId,
  DateTime? approvalTime,
  List<PurchaseRequestLine>? lines,
}) {
  final items = lines ?? [aRequestLine()];
  return PurchaseRequest(
    id: id,
    serial: serial,
    status: status,
    warehouseId: warehouseId,
    facilityId: facilityId,
    date: DateTime(2026, 11, 26, 9, 30),
    comment: comment,
    creatorId: 5,
    updaterId: 5,
    approverId: approverId,
    approvalTime: approvalTime,
    lineCount: items.length,
    lines: items,
  );
}

/// A line for tests; override what the case is about.
PurchaseRequestLine aRequestLine({
  int id = 900,
  int productId = 7,
  String code = 'A-100',
  String quantity = '8',
  int? warehouseId = 3,
  bool toPurchase = false,
  int? minOrderQty,
  int? purchaseOrderId,
  InventoryDocumentStatus? purchaseOrderStatus,
}) => PurchaseRequestLine(
  id: id,
  productId: productId,
  productCode: code,
  productName: 'Tornillo 1/4 caja',
  quantity: Decimal.parse(quantity),
  warehouseId: warehouseId,
  toPurchase: toPurchase,
  minOrderQty: minOrderQty,
  purchaseOrderId: purchaseOrderId,
  purchaseOrderStatus: purchaseOrderStatus,
);
