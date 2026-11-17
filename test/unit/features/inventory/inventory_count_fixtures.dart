import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';

/// A summary for tests; override what the case is about.
InventoryCountSummary aCountSummary({
  int id = 412,
  int warehouseId = 3,
  int? serial,
  InventoryDocumentStatus status = InventoryDocumentStatus.draft,
}) => InventoryCountSummary(
  id: id,
  facilityId: 2,
  warehouseId: warehouseId,
  serial: serial,
  status: status,
  creatorId: 5,
  createdAt: DateTime(2026, 11, 17, 9, 30),
);

/// A count for tests; override what the case is about.
InventoryCount aCount({
  int id = 412,
  int warehouseId = 3,
  int? serial,
  InventoryDocumentStatus status = InventoryDocumentStatus.draft,
  String? comment,
  List<InventoryCountLine>? lines,
}) => InventoryCount(
  id: id,
  facilityId: 2,
  warehouseId: warehouseId,
  serial: serial,
  status: status,
  creatorId: 5,
  createdAt: DateTime(2026, 11, 17, 9, 30),
  comment: comment,
  updaterId: 5,
  updatedAt: DateTime(2026, 11, 17, 9, 30),
  lines: lines ?? [aCountLine()],
);

/// A blind (draft) line for tests: no on-hand figure, no difference.
InventoryCountLine aCountLine({
  int id = 1200,
  int productId = 7,
  String productCode = 'A-100',
  String productName = 'Tornillo 1/4 caja',
  String quantity = '8',
}) => InventoryCountLine(
  id: id,
  productId: productId,
  productCode: productCode,
  productName: productName,
  quantity: Decimal.parse(quantity),
);

/// A completed line for tests, with its on-hand figure and difference.
InventoryCountLine aCompletedCountLine({
  int id = 1200,
  int productId = 7,
  String productCode = 'A-100',
  String quantity = '8',
  String quantityOnHand = '10',
}) =>
    aCountLine(
      id: id,
      productId: productId,
      productCode: productCode,
      quantity: quantity,
    ).copyWith(
      quantityOnHand: Decimal.parse(quantityOnHand),
      difference: Decimal.parse(quantity) - Decimal.parse(quantityOnHand),
    );

/// Warnings for tests: one of each kind unless overridden.
CountWarnings someCountWarnings({
  List<NegativeAvailableItem>? negativeAvailable,
  List<CorrectedByOtherCountItem>? correctedByOtherCounts,
}) => CountWarnings(
  negativeAvailable:
      negativeAvailable ??
      [
        NegativeAvailableItem(
          productId: 7,
          productCode: 'A-100',
          counted: Decimal.parse('2'),
          reserved: Decimal.parse('5'),
          available: Decimal.parse('-3'),
        ),
      ],
  correctedByOtherCounts:
      correctedByOtherCounts ??
      [
        const CorrectedByOtherCountItem(
          productId: 8,
          productCode: 'B-200',
          otherCountId: 409,
          otherCountSerial: 57,
        ),
      ],
);
