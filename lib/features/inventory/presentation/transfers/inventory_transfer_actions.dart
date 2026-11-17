import 'package:decimal/decimal.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_transfer_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_transfer_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/in_transit_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfer_detail_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfers_list_controller.dart';

part 'inventory_transfer_actions.g.dart';

/// What `create` answers: the refusal, or the new transfer's id to navigate
/// to.
typedef TransferOpened = ({AppError? error, int? id});

/// The refusals after which the transfer on screen is stale: someone else
/// changed it meanwhile (spec edge case: concurrent edits).
const _staleCodes = {
  api.ErrorCode.documentPeriodNotEditable,
  api.ErrorCode.inventoryDocumentPeriodAlreadyCancelled,
  api.ErrorCode.lockPeriodBusy,
  api.ErrorCode.inventoryTransferPeriodNotInTransit,
  api.ErrorCode.inventoryTransferPeriodOverReceived,
};

/// Every write on a transfer (spec 069 contracts/repository.md "Actions
/// notifier").
///
/// Each method answers the [AppError] the server refused with, or `null`
/// when it went through, rather than throwing: the dialog that asked shows
/// the refusal where the user is looking. On success the returned transfer is
/// put into its detail provider (when one is alive) and the list is
/// invalidated; dispatch, receive, close and cancel also invalidate the
/// in-transit view.
///
/// Keep-alive because a write outlives the dialog that started it.
@Riverpod(keepAlive: true)
class InventoryTransferActions extends _$InventoryTransferActions {
  @override
  void build() {}

  /// `POST /inventory-transfers`: a new draft.
  Future<TransferOpened> create({
    required int warehouseId,
    required int warehouseToId,
    String? comment,
  }) async {
    final (:error, :transfer) = await _run(
      null,
      (r) => r.create(
        warehouseId: warehouseId,
        warehouseToId: warehouseToId,
        comment: comment,
      ),
    );
    return (error: error, id: transfer?.id);
  }

  /// `PUT /inventory-transfers/{id}`. See
  /// [InventoryTransferRepository.updateHeader].
  Future<AppError?> updateHeader(
    int id, {
    int? warehouseId,
    int? warehouseToId,
    String? comment,
    bool clearComment = false,
  }) async => (await _run(
    id,
    (r) => r.updateHeader(
      id,
      warehouseId: warehouseId,
      warehouseToId: warehouseToId,
      comment: comment,
      clearComment: clearComment,
    ),
  )).error;

  /// `POST /inventory-transfers/{id}/lines`. The server merges a product
  /// already on the transfer into its line.
  Future<AppError?> addLine(
    int id, {
    required int productId,
    required Decimal quantity,
  }) async => (await _run(
    id,
    (r) => r.addLine(id, productId: productId, quantity: quantity),
  )).error;

  /// `PUT /inventory-transfers/{id}/lines/{lineId}`.
  Future<AppError?> updateLine(
    int id,
    int lineId, {
    required Decimal quantity,
  }) async => (await _run(
    id,
    (r) => r.updateLine(id, lineId, quantity: quantity),
  )).error;

  /// `DELETE /inventory-transfers/{id}/lines/{lineId}`.
  Future<AppError?> removeLine(int id, int lineId) async =>
      (await _run(id, (r) => r.removeLine(id, lineId))).error;

  /// `POST /inventory-transfers/{id}/sales-order-items`. Answers the refusal
  /// and how many lines the order added: the line count after minus before
  /// (research R8). Zero when the order's products were already there.
  Future<(AppError?, int)> addSalesOrderItems(
    int id, {
    required int salesOrderId,
  }) async {
    final detail = inventoryTransferDetailControllerProvider(id);
    final before = ref.exists(detail)
        ? ref.read(detail).value?.lines.length
        : null;
    final (:error, :transfer) = await _run(
      id,
      (r) => r.addSalesOrderItems(id, salesOrderId: salesOrderId),
    );
    if (transfer == null) return (error, 0);
    // simplified: without a loaded detail the "before" is unknown, so the
    // count is the whole line list; the detail screen always has it loaded.
    return (null, transfer.lines.length - (before ?? 0));
  }

  /// `POST /inventory-transfers/{id}/dispatch`.
  Future<AppError?> dispatch(int id) async =>
      (await _run(id, (r) => r.dispatch(id), inTransit: true)).error;

  /// `POST /inventory-transfers/{id}/receive`. A null [lines] receives
  /// everything outstanding.
  Future<AppError?> receive(int id, {Map<int, Decimal>? lines}) async =>
      (await _run(
        id,
        (r) => r.receive(id, lines: lines),
        inTransit: true,
      )).error;

  /// `POST /inventory-transfers/{id}/close`.
  Future<AppError?> close(int id) async =>
      (await _run(id, (r) => r.close(id), inTransit: true)).error;

  /// `POST /inventory-transfers/{id}/cancel`.
  Future<AppError?> cancel(int id) async =>
      (await _run(id, (r) => r.cancel(id), inTransit: true)).error;

  /// The one write path. [id] is the transfer written to (`null` for
  /// `create`), refreshed after a stale refusal. [inTransit] also invalidates
  /// the in-transit view on success.
  Future<({AppError? error, InventoryTransfer? transfer})> _run(
    int? id,
    Future<InventoryTransfer> Function(InventoryTransferRepository r) write, {
    bool inTransit = false,
  }) async {
    final InventoryTransfer transfer;
    try {
      transfer = await write(ref.read(inventoryTransferRepositoryProvider));
    } on AppError catch (error) {
      if (id != null && _staleCodes.contains(error.problem?.code)) {
        final detail = inventoryTransferDetailControllerProvider(id);
        if (ref.exists(detail)) await ref.read(detail.notifier).refresh();
      }
      return (error: error, transfer: null);
    }
    final detail = inventoryTransferDetailControllerProvider(transfer.id);
    if (ref.exists(detail)) ref.read(detail.notifier).put(transfer);
    ref.invalidate(inventoryTransfersListControllerProvider);
    if (inTransit) ref.invalidate(inTransitControllerProvider);
    return (error: null, transfer: transfer);
  }
}
