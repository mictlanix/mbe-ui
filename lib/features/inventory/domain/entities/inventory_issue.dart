import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';

part 'inventory_issue.freezed.dart';

/// One row of the issues list. The server's `supplierReturn` is not kept: the
/// list has no column for it (spec FR-007).
@freezed
abstract class InventoryIssueSummary with _$InventoryIssueSummary {
  const factory InventoryIssueSummary({
    required int id,
    required int facilityId,
    required int warehouseId,

    /// Null until the issue is confirmed. The "Borrador #{id}" text for a
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
  }) = _InventoryIssueSummary;
}

/// A page of issues.
typedef InventoryIssuePage = CatalogPage<InventoryIssueSummary>;

/// A line of an issue.
@freezed
abstract class InventoryIssueLine with _$InventoryIssueLine {
  const factory InventoryIssueLine({
    required int id,
    required int productId,

    /// Snapshots from when the line was added.
    String? productCode,
    String? productName,
    required Decimal quantity,
  }) = _InventoryIssueLine;
}

/// An issue in full.
@freezed
abstract class InventoryIssue with _$InventoryIssue {
  const InventoryIssue._();

  const factory InventoryIssue({
    required int id,
    required int facilityId,
    required int warehouseId,
    int? serial,
    required InventoryDocumentStatus status,
    required int creatorId,
    required DateTime createdAt,

    /// Legacy link only; shown read-only when set (research R7).
    int? supplierReturnId,

    /// The reason. An empty string is treated as no note by the mapper.
    String? comment,
    required int updaterId,
    required DateTime modifiedAt,
    required List<InventoryIssueLine> lines,
  }) = _InventoryIssue;

  bool get isDraft => status == InventoryDocumentStatus.draft;
}
