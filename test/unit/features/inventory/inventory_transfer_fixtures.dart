import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';

/// A summary for tests; override what the case is about.
InventoryTransferSummary aTransferSummary({
  int id = 412,
  int warehouseId = 3,
  int warehouseToId = 4,
  int? serial,
  InventoryTransferStatus status = InventoryTransferStatus.draft,
}) => InventoryTransferSummary(
  id: id,
  facilityId: 2,
  warehouseId: warehouseId,
  warehouseToId: warehouseToId,
  serial: serial,
  status: status,
  creatorId: 5,
  createdAt: DateTime(2026, 11, 16, 10, 2),
);

/// A transfer for tests; override what the case is about.
InventoryTransfer aTransfer({
  int id = 412,
  int warehouseId = 3,
  int warehouseToId = 4,
  int? serial,
  InventoryTransferStatus status = InventoryTransferStatus.draft,
  String? comment,
  List<InventoryTransferLine>? lines,
}) => InventoryTransfer(
  id: id,
  facilityId: 2,
  warehouseId: warehouseId,
  warehouseToId: warehouseToId,
  serial: serial,
  status: status,
  creatorId: 5,
  createdAt: DateTime(2026, 11, 16, 10, 2),
  comment: comment,
  updaterId: 5,
  modifiedAt: DateTime(2026, 11, 16, 10, 2),
  lines: lines ?? [aTransferLine()],
);

/// A line for tests; override what the case is about.
InventoryTransferLine aTransferLine({
  int id = 900,
  int productId = 7,
  String quantity = '8',
  String received = '0',
  String outstanding = '0',
}) => InventoryTransferLine(
  id: id,
  productId: productId,
  productCode: 'A-100',
  productName: 'Tornillo 1/4 caja',
  quantity: Decimal.parse(quantity),
  quantityReceived: Decimal.parse(received),
  quantityOutstanding: Decimal.parse(outstanding),
);

/// An in-transit view for tests.
InTransitView anInTransitView({int facilityId = 2}) => InTransitView(
  facilityId: facilityId,
  products: [
    InTransitProductTotal(
      productId: 7,
      productCode: 'A-100',
      productName: 'Tornillo',
      quantity: Decimal.parse('5.5'),
    ),
  ],
  lines: [
    InTransitLineItem(
      transferId: 412,
      serial: 77,
      warehouseId: 3,
      warehouseToId: 4,
      lineId: 900,
      productId: 7,
      productCode: 'A-100',
      productName: 'Tornillo',
      quantityOutstanding: Decimal.parse('5.5'),
    ),
  ],
);
