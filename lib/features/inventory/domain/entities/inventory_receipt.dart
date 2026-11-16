import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/over_receipt.dart';

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

    /// Only the count of the server's `warnings[]` is kept; their text is
    /// never shown (spec FR-015a).
    @Default(0) int serverWarningCount,
  }) = _InventoryReceipt;

  bool get isDraft => status == InventoryDocumentStatus.draft;
  bool get isLinked => purchaseOrderId != null;

  List<OverReceipt> get overReceipts => computeOverReceipts(lines);

  /// Cost warnings the server raised beyond the over-receipts this client
  /// computes. Read only from a confirm or cancel response.
  bool get hasUnmappedWarnings => serverWarningCount > overReceipts.length;
}
