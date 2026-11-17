import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';

part 'inventory_count.freezed.dart';

/// One row of the counts list. The server sends ids only; the shared name
/// cells look the names up (research R12).
@freezed
abstract class InventoryCountSummary with _$InventoryCountSummary {
  const factory InventoryCountSummary({
    required int id,
    required int facilityId,
    required int warehouseId,

    /// Null on drafts and cancelled counts. The "Borrador #{id}" text is
    /// built by the presentation layer from l10n.
    int? serial,
    required InventoryDocumentStatus status,
    required int creatorId,
    required DateTime createdAt,
  }) = _InventoryCountSummary;
}

/// A page of counts.
typedef InventoryCountPage = CatalogPage<InventoryCountSummary>;

/// A line of a count.
@freezed
abstract class InventoryCountLine with _$InventoryCountLine {
  const factory InventoryCountLine({
    required int id,
    required int productId,

    /// Snapshots from when the line was set; empty when the server sends none.
    required String productCode,
    required String productName,

    /// Counted, ≥ 0.
    required Decimal quantity,

    /// Null until the count is completed (drafts are blind, SC-003).
    Decimal? quantityOnHand,

    /// Counted minus on hand; null until the count is completed.
    Decimal? difference,
  }) = _InventoryCountLine;
}

/// A count in full.
@freezed
abstract class InventoryCount with _$InventoryCount {
  const InventoryCount._();

  const factory InventoryCount({
    required int id,
    required int facilityId,
    required int warehouseId,
    int? serial,
    required InventoryDocumentStatus status,
    required int creatorId,
    required DateTime createdAt,

    /// An empty string is treated as no note by the mapper.
    String? comment,
    required int updaterId,
    required DateTime updatedAt,
    required List<InventoryCountLine> lines,
  }) = _InventoryCount;

  bool get isDraft => status == InventoryDocumentStatus.draft;
  bool get isCompleted => status == InventoryDocumentStatus.completed;
  bool get isCancelled => status == InventoryDocumentStatus.cancelled;
}

/// A product whose available stock went negative with the count (it is
/// reserved by open orders).
@freezed
abstract class NegativeAvailableItem with _$NegativeAvailableItem {
  const factory NegativeAvailableItem({
    required int productId,
    required String productCode,
    required Decimal counted,
    required Decimal reserved,
    required Decimal available,
  }) = _NegativeAvailableItem;
}

/// A product another confirmed count corrected since this one was opened.
@freezed
abstract class CorrectedByOtherCountItem with _$CorrectedByOtherCountItem {
  const factory CorrectedByOtherCountItem({
    required int productId,
    required String productCode,
    required int otherCountId,
    int? otherCountSerial,
  }) = _CorrectedByOtherCountItem;
}

/// The warnings of a confirm response. Never stored by the server (R9).
@freezed
abstract class CountWarnings with _$CountWarnings {
  const CountWarnings._();

  const factory CountWarnings({
    @Default(<NegativeAvailableItem>[])
    List<NegativeAvailableItem> negativeAvailable,
    @Default(<CorrectedByOtherCountItem>[])
    List<CorrectedByOtherCountItem> correctedByOtherCounts,
  }) = _CountWarnings;

  bool get isEmpty =>
      negativeAvailable.isEmpty && correctedByOtherCounts.isEmpty;
}

/// What a confirm returns: the completed count and its warnings.
@freezed
abstract class CountConfirmResult with _$CountConfirmResult {
  const factory CountConfirmResult({
    required InventoryCount count,
    required CountWarnings warnings,
  }) = _CountConfirmResult;
}

/// One item of a line batch: a product by id or by code, plus the counted
/// quantity (research R3).
@freezed
sealed class CountLineInput with _$CountLineInput {
  const factory CountLineInput.byProduct({
    required int productId,
    required Decimal quantity,
  }) = CountLineByProduct;

  const factory CountLineInput.byCode({
    required String code,
    required Decimal quantity,
  }) = CountLineByCode;
}
