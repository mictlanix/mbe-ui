import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/over_receipt.dart';
import 'package:mbe_ui/features/inventory/domain/receipt_cost_warning.dart';

part 'inventory_receipt.freezed.dart';

/// One row of the receipts list.
@freezed
abstract class InventoryReceiptSummary with _$InventoryReceiptSummary {
  const factory InventoryReceiptSummary({
    required int id,
    required int facilityId,
    required int warehouseId,
    int? purchaseOrderId,

    /// Null until the receipt is confirmed. The "Borrador #{id}" text for a
    /// draft is built by the presentation layer from l10n.
    int? serial,
    required InventoryDocumentStatus status,
    required int creatorId,
    required DateTime createdAt,

    /// Server-joined names (mbe-api#327–#330), null when the row is gone.
    /// The name cells fall back to a per-id lookup when one is null.
    String? warehouseName,
    String? facilityName,
    String? creatorName,
  }) = _InventoryReceiptSummary;
}

/// A page of receipts.
typedef InventoryReceiptPage = CatalogPage<InventoryReceiptSummary>;

/// A line of a receipt.
@freezed
abstract class InventoryReceiptLine with _$InventoryReceiptLine {
  const factory InventoryReceiptLine({
    required int id,
    required int productId,

    /// Snapshots from when the line was added.
    String? productCode,
    String? productName,
    required Decimal quantity,

    /// Null for a line added by hand.
    int? purchaseOrderLineId,

    /// Shown only on a linked receipt (0 on a hand-added line).
    required Decimal quantityOrdered,
    Decimal? quantityReceivedElsewhere,
  }) = _InventoryReceiptLine;
}

/// A receipt in full.
@freezed
abstract class InventoryReceipt with _$InventoryReceipt {
  const InventoryReceipt._();

  const factory InventoryReceipt({
    required int id,
    required int facilityId,
    required int warehouseId,
    int? purchaseOrderId,
    int? serial,
    required InventoryDocumentStatus status,
    required int creatorId,
    required DateTime createdAt,

    /// An empty string is treated as no note by the mapper.
    String? comment,
    required int updaterId,
    required DateTime modifiedAt,
    required List<InventoryReceiptLine> lines,

    /// The cost warnings of a confirm or cancel response (mbe-api#322). The
    /// server's over-receipt warnings are left out: [overReceipts] computes
    /// the same figures from the lines, drafts included.
    @Default(<ReceiptCostWarning>[]) List<ReceiptCostWarning> costWarnings,
  }) = _InventoryReceipt;

  bool get isDraft => status == InventoryDocumentStatus.draft;
  bool get isLinked => purchaseOrderId != null;

  List<OverReceipt> get overReceipts => computeOverReceipts(lines);
}
