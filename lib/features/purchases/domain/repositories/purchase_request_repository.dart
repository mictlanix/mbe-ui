import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';

/// Purchase requests (spec 079), over the generated `PurchaseRequestsApi`.
/// Every method throws `AppError` on failure. Every mutation returns the full
/// request.
abstract class PurchaseRequestRepository {
  /// `GET /purchase-requests`. The server orders newest first and decides the
  /// default scope; [all] widens it. The filter is passed as its parts so the
  /// domain does not depend on the presentation-layer filter class.
  Future<PurchaseRequestPage> list({
    bool all = false,
    PurchaseRequestStatus? status,
    int? facilityId,
    int? warehouseId,
    int? creatorId,
    int? serial,
    DateTime? from,
    DateTime? to,
    required int skip,
    required int limit,
  });

  /// `GET /purchase-requests/approval-queue`: submitted requests, oldest
  /// first.
  Future<PurchaseRequestPage> approvalQueue({
    int? facilityId,
    required int skip,
    required int limit,
  });

  /// `GET /purchase-requests/{id}`.
  Future<PurchaseRequest> get(int id);

  /// `POST /purchase-requests`: a draft.
  Future<PurchaseRequest> create({required int warehouseId, String? comment});

  /// `PUT /purchase-requests/{id}`. [warehouseId] is sent only when given.
  /// [clearComment] empties the notes (research R8).
  Future<PurchaseRequest> updateHeader(
    int id, {
    int? warehouseId,
    String? comment,
    bool clearComment = false,
  });

  /// `POST /purchase-requests/{id}/lines`.
  Future<PurchaseRequest> addLine(int id, {required int productId});

  /// `PUT /purchase-requests/{id}/lines/{lineId}`: only the given fields are
  /// sent.
  Future<PurchaseRequest> updateLine(
    int id,
    int lineId, {
    Decimal? quantity,
    String? productName,
    int? warehouseId,
  });

  /// `DELETE /purchase-requests/{id}/lines/{lineId}`.
  Future<PurchaseRequest> removeLine(int id, int lineId);

  /// `POST /purchase-requests/{id}/submit`.
  Future<PurchaseRequest> submit(int id);

  /// `POST /purchase-requests/{id}/cancel`.
  Future<PurchaseRequest> cancel(int id);

  /// `PUT /purchase-requests/{id}/lines/{lineId}/to-purchase`.
  Future<PurchaseRequest> markLine(
    int id,
    int lineId, {
    required bool toPurchase,
  });

  /// `POST /purchase-requests/{id}/approve`.
  Future<PurchaseRequest> approve(int id);

  /// `POST /purchase-requests/approve` (1 to 100 ids). A per-id refusal is an
  /// outcome, never a throw; only a whole-call failure throws.
  Future<List<BulkApproveOutcome>> approveMany(List<int> ids);

  /// `POST /purchase-requests/{id}/reject`: back to draft, keeping the folio.
  Future<PurchaseRequest> reject(int id, {required String reason});
}
