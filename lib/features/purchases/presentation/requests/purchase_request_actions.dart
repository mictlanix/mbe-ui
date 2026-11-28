import 'package:decimal/decimal.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_request_repository.dart';
import 'package:mbe_ui/features/purchases/presentation/approval/approval_queue_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_detail_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_requests_list_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/to_purchase/to_purchase_controller.dart';

part 'purchase_request_actions.g.dart';

/// What `create` answers: the refusal, or the new request's id to navigate to.
typedef PurchaseRequestOpened = ({AppError? error, int? id});

/// What `approveMany` answers: a whole-call failure, or one outcome per id.
typedef PurchaseRequestsApproved = ({
  AppError? error,
  List<BulkApproveOutcome>? outcomes,
});

/// The refusals after which the request on screen is stale: someone else
/// decided or changed it meanwhile (research R13, spec edge case: concurrent
/// decisions).
const _staleCodes = {
  api.ErrorCode.purchaseRequestPeriodNotDraft,
  api.ErrorCode.purchaseRequestPeriodNotSubmitted,
  api.ErrorCode.purchaseRequestPeriodAlreadyCancelled,
  api.ErrorCode.purchaseRequestPeriodLinesNotMarkable,
  api.ErrorCode.purchaseRequestPeriodWarehouseFacilityChanged,
  api.ErrorCode.lockPeriodBusy,
};

/// Whether [error] says the request on screen is stale: a dialog that got it
/// offers only "Cerrar", since retrying can't succeed.
bool isStaleRefusal(AppError error) =>
    _staleCodes.contains(error.problem?.code);

/// Every write on a purchase request (spec 079 contracts/repository.md,
/// research R11 and R13).
///
/// Each method answers the [AppError] the server refused with, or `null`
/// when it went through, rather than throwing: the dialog that asked shows
/// the refusal where the user is looking. On success the returned request is
/// put into its detail provider (when one is alive) and the list and the
/// approval queue are invalidated (and Por comprar, after a write that
/// changes which lines are pending); a stale refusal also reloads the queue.
///
/// Keep-alive because a write outlives the dialog that started it.
@Riverpod(keepAlive: true)
class PurchaseRequestActions extends _$PurchaseRequestActions {
  @override
  void build() {}

  /// `POST /purchase-requests`: a new draft.
  Future<PurchaseRequestOpened> create({
    required int warehouseId,
    String? comment,
  }) async {
    final (:error, :request) = await _run(
      null,
      (r) => r.create(warehouseId: warehouseId, comment: comment),
    );
    return (error: error, id: request?.id);
  }

  /// `PUT /purchase-requests/{id}`. See
  /// [PurchaseRequestRepository.updateHeader].
  Future<AppError?> updateHeader(
    int id, {
    int? warehouseId,
    String? comment,
    bool clearComment = false,
  }) async => (await _run(
    id,
    (r) => r.updateHeader(
      id,
      warehouseId: warehouseId,
      comment: comment,
      clearComment: clearComment,
    ),
  )).error;

  /// `POST /purchase-requests/{id}/lines`.
  Future<AppError?> addLine(int id, {required int productId}) async =>
      (await _run(id, (r) => r.addLine(id, productId: productId))).error;

  /// `PUT /purchase-requests/{id}/lines/{lineId}`.
  Future<AppError?> updateLine(
    int id,
    int lineId, {
    Decimal? quantity,
    String? productName,
    int? warehouseId,
  }) async => (await _run(
    id,
    (r) => r.updateLine(
      id,
      lineId,
      quantity: quantity,
      productName: productName,
      warehouseId: warehouseId,
    ),
  )).error;

  /// `DELETE /purchase-requests/{id}/lines/{lineId}`.
  Future<AppError?> removeLine(int id, int lineId) async =>
      (await _run(id, (r) => r.removeLine(id, lineId))).error;

  /// `POST /purchase-requests/{id}/submit`.
  Future<AppError?> submit(int id) async =>
      (await _run(id, (r) => r.submit(id))).error;

  /// `POST /purchase-requests/{id}/cancel`.
  Future<AppError?> cancel(int id) async =>
      (await _run(id, (r) => r.cancel(id), changesPending: true)).error;

  /// `PUT /purchase-requests/{id}/lines/{lineId}/to-purchase`.
  Future<AppError?> markLine(
    int id,
    int lineId, {
    required bool toPurchase,
  }) async => (await _run(
    id,
    (r) => r.markLine(id, lineId, toPurchase: toPurchase),
    changesPending: true,
  )).error;

  /// `POST /purchase-requests/{id}/approve`.
  Future<AppError?> approve(int id) async =>
      (await _run(id, (r) => r.approve(id), changesPending: true)).error;

  /// `POST /purchase-requests/{id}/reject`.
  Future<AppError?> reject(int id, {required String reason}) async =>
      (await _run(
        id,
        (r) => r.reject(id, reason: reason),
        changesPending: true,
      )).error;

  /// `POST /purchase-requests/approve`: one outcome per id. A refused id is an
  /// outcome, not an error; only a whole-call failure answers an error. No
  /// detail is written, since the response carries no requests.
  Future<PurchaseRequestsApproved> approveMany(List<int> ids) async {
    final List<BulkApproveOutcome> outcomes;
    try {
      outcomes = await ref
          .read(purchaseRequestRepositoryProvider)
          .approveMany(ids);
    } on AppError catch (error) {
      return (error: error, outcomes: null);
    }
    ref.invalidate(purchaseRequestsListControllerProvider);
    ref.invalidate(approvalQueueControllerProvider);
    ref.invalidate(toPurchaseControllerProvider);
    return (error: null, outcomes: outcomes);
  }

  /// The one write path. [id] is the request written to (`null` for
  /// `create`), refreshed after a stale refusal. [changesPending]: the write
  /// changes which lines are pending, so Por comprar is reloaded on success.
  Future<({AppError? error, PurchaseRequest? request})> _run(
    int? id,
    Future<PurchaseRequest> Function(PurchaseRequestRepository r) write, {
    bool changesPending = false,
  }) async {
    final PurchaseRequest request;
    try {
      request = await write(ref.read(purchaseRequestRepositoryProvider));
    } on AppError catch (error) {
      if (id != null && isStaleRefusal(error)) {
        final detail = purchaseRequestDetailControllerProvider(id);
        if (ref.exists(detail)) await ref.read(detail.notifier).refresh();
        // Someone else decided it: the queue may no longer hold it (FR-024).
        ref.invalidate(approvalQueueControllerProvider);
      }
      return (error: error, request: null);
    }
    final detail = purchaseRequestDetailControllerProvider(request.id);
    if (ref.exists(detail)) ref.read(detail.notifier).put(request);
    ref.invalidate(purchaseRequestsListControllerProvider);
    ref.invalidate(approvalQueueControllerProvider);
    if (changesPending) ref.invalidate(toPurchaseControllerProvider);
    return (error: null, request: request);
  }
}
