import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';

part 'inventory_transfer.freezed.dart';

/// A transfer's state (spec 069 data-model). The wire value of [inTransit]
/// is `in_transit`; the repository maps it.
enum InventoryTransferStatus { draft, inTransit, received, cancelled }

/// One row of the transfers list.
@freezed
abstract class InventoryTransferSummary with _$InventoryTransferSummary {
  const factory InventoryTransferSummary({
    required int id,

    /// The origin's facility.
    required int facilityId,

    /// The origin.
    required int warehouseId,

    /// The destination.
    required int warehouseToId,

    /// Null until the transfer is dispatched.
    int? serial,
    required InventoryTransferStatus status,
    required int creatorId,
    required DateTime createdAt,

    /// Server-joined names (mbe-api#327–#330), null when the row is gone.
    /// The name cells fall back to a per-id lookup when one is null.
    String? warehouseName,
    String? warehouseToName,
    String? facilityName,
    String? creatorName,
  }) = _InventoryTransferSummary;
}

/// A page of transfers.
typedef InventoryTransferPage = CatalogPage<InventoryTransferSummary>;

/// A line of a transfer.
@freezed
abstract class InventoryTransferLine with _$InventoryTransferLine {
  const factory InventoryTransferLine({
    required int id,
    required int productId,

    /// Snapshots from when the line was added.
    String? productCode,
    String? productName,

    /// Sent.
    required Decimal quantity,
    required Decimal quantityReceived,

    /// Zero unless the transfer is in transit.
    required Decimal quantityOutstanding,
  }) = _InventoryTransferLine;
}

/// A transfer in full.
@freezed
abstract class InventoryTransfer with _$InventoryTransfer {
  const InventoryTransfer._();

  const factory InventoryTransfer({
    required int id,
    required int facilityId,
    required int warehouseId,
    required int warehouseToId,
    int? serial,
    required InventoryTransferStatus status,
    required int creatorId,
    required DateTime createdAt,

    /// An empty string is treated as no note by the mapper.
    String? comment,
    required int updaterId,
    required DateTime modifiedAt,
    required List<InventoryTransferLine> lines,
  }) = _InventoryTransfer;

  bool get isDraft => status == InventoryTransferStatus.draft;
  bool get isInTransit => status == InventoryTransferStatus.inTransit;

  /// Selects the three-quantity lines table and the "Traspaso {folio}" title
  /// (research R10).
  bool get isDispatched => serial != null;

  List<InventoryTransferLine> get outstandingLines => [
    for (final line in lines)
      if (line.quantityOutstanding > Decimal.zero) line,
  ];
}

/// What is in transit toward a facility's warehouses (spec 069 US7).
@freezed
abstract class InTransitView with _$InTransitView {
  const factory InTransitView({
    required int facilityId,
    required List<InTransitProductTotal> products,
    required List<InTransitLineItem> lines,
  }) = _InTransitView;
}

/// A product's total across every transfer in transit.
@freezed
abstract class InTransitProductTotal with _$InTransitProductTotal {
  const factory InTransitProductTotal({
    required int productId,
    String? productCode,
    String? productName,
    required Decimal quantity,
  }) = _InTransitProductTotal;
}

/// One outstanding line of a transfer in transit.
@freezed
abstract class InTransitLineItem with _$InTransitLineItem {
  const factory InTransitLineItem({
    required int transferId,
    int? serial,
    required int warehouseId,
    required int warehouseToId,
    required int lineId,
    required int productId,
    String? productCode,
    String? productName,
    required Decimal quantityOutstanding,

    /// Server-joined names (mbe-api#330), null when the row is gone.
    String? warehouseName,
    String? warehouseToName,
  }) = _InTransitLineItem;
}
