import 'package:decimal/decimal.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/purchases/data/purchase_order_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_order_repository.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_detail_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_orders_list_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/to_purchase/to_purchase_controller.dart';

part 'purchase_order_actions.g.dart';

/// What `create` and `createFromGroup` answer: the refusal, or the new
/// order's id to navigate to, how many lines it holds (counted on the
/// server's answer) and how many request lines were left out because they
/// were already on another order (FR-018).
typedef PurchaseOrderOpened = ({
  AppError? error,
  int? id,
  int lines,
  int skipped,
});

/// What `addRequestLines` answers: the refusal, or how many lines were added
/// and how many were left out (FR-018).
typedef PurchaseOrderLinesAdded = ({AppError? error, int added, int skipped});

/// The refusals after which the order on screen is stale: someone else
/// confirmed, cancelled or is writing it meanwhile (research R17, spec edge
/// case: concurrent confirm).
const _staleCodes = {
  api.ErrorCode.purchaseOrderPeriodAlreadyCancelled,
  api.ErrorCode.purchaseOrderPeriodConfirmedCannotCancel,
  api.ErrorCode.purchaseOrderPeriodNotConfirmed,
  api.ErrorCode.documentPeriodNotEditable,
  api.ErrorCode.lockPeriodBusy,
};

/// Whether [error] says the order on screen is stale. Keyed on the code,
/// never on the text.
bool isStaleOrderRefusal(AppError error) =>
    _staleCodes.contains(error.problem?.code);

/// Every write on a purchase order (spec 080 contracts/repository.md,
/// research R17).
///
/// Each method answers the [AppError] the server refused with, or `null`
/// when it went through, rather than throwing: the dialog or screen that
/// asked shows the refusal where the user is looking. On success the
/// returned order is put into its detail provider (when one is alive), and
/// the orders list and Por comprar are invalidated: every write may change
/// a row's lines, total or status, and which request lines are pending
/// (FR-009). A stale refusal re-fetches the detail.
///
/// Keep-alive because a write outlives the dialog that started it.
@Riverpod(keepAlive: true)
class PurchaseOrderActions extends _$PurchaseOrderActions {
  @override
  void build() {}

  /// `POST /purchase-orders`: a new draft.
  Future<PurchaseOrderOpened> create({
    required int supplierId,
    DateTime? estimatedReceiptDate,
    String? comment,
  }) async {
    final (:error, :order) = await _run(
      null,
      (r) => r.create(
        supplierId: supplierId,
        estimatedReceiptDate: estimatedReceiptDate,
        comment: comment,
      ),
    );
    return _opened(error, order);
  }

  /// `POST /purchase-orders/to-purchase`: a draft holding a Por comprar
  /// group's pending lines.
  Future<PurchaseOrderOpened> createFromGroup({
    required int supplierId,
    required int facilityId,
  }) async {
    final (:error, :order) = await _run(
      null,
      (r) => r.createFromGroup(supplierId: supplierId, facilityId: facilityId),
    );
    return _opened(error, order);
  }

  PurchaseOrderOpened _opened(AppError? error, PurchaseOrder? order) => (
    error: error,
    id: order?.id,
    lines: order?.lines.length ?? 0,
    skipped: order?.skippedCount ?? 0,
  );

  /// `PUT /purchase-orders/{id}`. See [PurchaseOrderRepository.updateHeader].
  Future<AppError?> updateHeader(
    int id, {
    int? supplierId,
    DateTime? estimatedReceiptDate,
    bool clearDate = false,
    String? comment,
    bool clearComment = false,
  }) async => (await _run(
    id,
    (r) => r.updateHeader(
      id,
      supplierId: supplierId,
      estimatedReceiptDate: estimatedReceiptDate,
      clearDate: clearDate,
      comment: comment,
      clearComment: clearComment,
    ),
  )).error;

  /// `POST /purchase-orders/{id}/lines`.
  Future<AppError?> addLine(
    int id, {
    required int productId,
    required Decimal quantity,
  }) async => (await _run(
    id,
    (r) => r.addLine(id, productId: productId, quantity: quantity),
  )).error;

  /// `PUT /purchase-orders/{id}/lines/{lineId}`.
  Future<AppError?> updateLine(
    int id,
    int lineId, {
    Decimal? quantity,
    int? warehouseId,
    Decimal? price,
    Decimal? taxRate,
  }) async => (await _run(
    id,
    (r) => r.updateLine(
      id,
      lineId,
      quantity: quantity,
      warehouseId: warehouseId,
      price: price,
      taxRate: taxRate,
    ),
  )).error;

  /// `DELETE /purchase-orders/{id}/lines/{lineId}`.
  Future<AppError?> removeLine(int id, int lineId) async =>
      (await _run(id, (r) => r.removeLine(id, lineId))).error;

  /// `POST /purchase-orders/{id}/request-lines`. The lines added are the line
  /// count after minus the one on screen before (research R9); with no order
  /// on screen, every line counts as added.
  Future<PurchaseOrderLinesAdded> addRequestLines(
    int id, {
    required int requestId,
  }) async {
    final detail = purchaseOrderDetailControllerProvider(id);
    final before = ref.exists(detail)
        ? ref.read(detail).value?.lines.length ?? 0
        : 0;
    final (:error, :order) = await _run(
      id,
      (r) => r.addRequestLines(id, requestId: requestId),
    );
    if (order == null) return (error: error, added: 0, skipped: 0);
    return (
      error: null,
      added: order.lines.length - before,
      skipped: order.skippedCount,
    );
  }

  /// `POST /purchase-orders/{id}/confirm`. The response's receipts stay on
  /// the detail until the next reload (research R11).
  Future<AppError?> confirm(int id) async =>
      (await _run(id, (r) => r.confirm(id))).error;

  /// `POST /purchase-orders/{id}/cancel`.
  Future<AppError?> cancel(int id) async =>
      (await _run(id, (r) => r.cancel(id))).error;

  /// The one write path. [id] is the order written to (`null` for the
  /// creates), refreshed after a stale refusal.
  Future<({AppError? error, PurchaseOrder? order})> _run(
    int? id,
    Future<PurchaseOrder> Function(PurchaseOrderRepository r) write,
  ) async {
    final PurchaseOrder order;
    try {
      order = await write(ref.read(purchaseOrderRepositoryProvider));
    } on AppError catch (error) {
      if (id != null && isStaleOrderRefusal(error)) {
        final detail = purchaseOrderDetailControllerProvider(id);
        if (ref.exists(detail)) await ref.read(detail.notifier).refresh();
      }
      return (error: error, order: null);
    }
    final detail = purchaseOrderDetailControllerProvider(order.id);
    if (ref.exists(detail)) ref.read(detail.notifier).put(order);
    ref.invalidate(purchaseOrdersListControllerProvider);
    ref.invalidate(toPurchaseControllerProvider);
    return (error: null, order: order);
  }
}
