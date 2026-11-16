import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_issue.dart';

/// A summary for tests; override what the case is about.
InventoryIssueSummary anIssueSummary({
  int id = 318,
  int warehouseId = 3,
  int? serial,
  InventoryDocumentStatus status = InventoryDocumentStatus.draft,
}) => InventoryIssueSummary(
  id: id,
  facilityId: 2,
  warehouseId: warehouseId,
  serial: serial,
  status: status,
  creatorId: 5,
  createdAt: DateTime(2026, 11, 16, 10, 2),
);

/// An issue for tests; override what the case is about.
InventoryIssue anIssue({
  int id = 318,
  int warehouseId = 3,
  int? serial,
  InventoryDocumentStatus status = InventoryDocumentStatus.draft,
  int? supplierReturnId,
  String? comment,
  List<InventoryIssueLine>? lines,
}) => InventoryIssue(
  id: id,
  facilityId: 2,
  warehouseId: warehouseId,
  serial: serial,
  status: status,
  creatorId: 5,
  createdAt: DateTime(2026, 11, 16, 10, 2),
  supplierReturnId: supplierReturnId,
  comment: comment,
  updaterId: 5,
  modifiedAt: DateTime(2026, 11, 16, 10, 2),
  lines: lines ?? [anIssueLine()],
);

/// A line for tests; override what the case is about.
InventoryIssueLine anIssueLine({
  int id = 900,
  int productId = 7,
  String quantity = '8',
}) => InventoryIssueLine(
  id: id,
  productId: productId,
  productCode: 'A-100',
  productName: 'Tornillo 1/4 caja',
  quantity: Decimal.parse(quantity),
);
