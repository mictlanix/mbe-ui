import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';

part 'purchase_request.freezed.dart';

/// The state of a purchase request (spec 079 data-model). Only a draft is
/// editable.
enum PurchaseRequestStatus { draft, submitted, approved, cancelled }

/// One row of the requests list or the approval queue. The "Borrador #{id}"
/// text of an unnumbered draft is built by the presentation layer from l10n.
@freezed
abstract class PurchaseRequestSummary with _$PurchaseRequestSummary {
  const factory PurchaseRequestSummary({
    required int id,

    /// Null until the first submit.
    int? serial,
    required PurchaseRequestStatus status,
    required int warehouseId,
    int? facilityId,
    required DateTime date,
    String? comment,
    required int creatorId,
    required int updaterId,

    /// Set on approve, cleared on reject.
    int? approverId,
    DateTime? approvalTime,
    required int lineCount,
  }) = _PurchaseRequestSummary;
}

/// A page of requests.
typedef PurchaseRequestPage = CatalogPage<PurchaseRequestSummary>;

/// A line of a request.
@freezed
abstract class PurchaseRequestLine with _$PurchaseRequestLine {
  const factory PurchaseRequestLine({
    required int id,
    required int productId,

    /// Empty when the server sends none.
    required String productCode,
    required String productName,
    required Decimal quantity,

    /// The line's destination: any facility, never in transit.
    int? warehouseId,

    /// The purchase mark.
    required bool toPurchase,
    int? minOrderQty,

    /// The live purchase order holding this line.
    int? purchaseOrderId,
    InventoryDocumentStatus? purchaseOrderStatus,
  }) = _PurchaseRequestLine;
}

/// A request in full. The server's `warnings` are English text with no code
/// and are dropped in the mapping (research R7).
@freezed
abstract class PurchaseRequest with _$PurchaseRequest {
  const factory PurchaseRequest({
    required int id,
    int? serial,
    required PurchaseRequestStatus status,
    required int warehouseId,
    int? facilityId,
    required DateTime date,

    /// An empty string is treated as no note by the mapper.
    String? comment,
    required int creatorId,
    required int updaterId,
    int? approverId,
    DateTime? approvalTime,
    required int lineCount,
    required List<PurchaseRequestLine> lines,
  }) = _PurchaseRequest;
}

/// The outcome of one id in a bulk approval.
@freezed
abstract class BulkApproveOutcome with _$BulkApproveOutcome {
  const factory BulkApproveOutcome({
    required int requestId,
    required bool approved,

    /// Built from the result's `code` and `params` when refused.
    ApiProblem? problem,
  }) = _BulkApproveOutcome;
}
