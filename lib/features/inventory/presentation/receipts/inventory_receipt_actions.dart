import 'package:decimal/decimal.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_receipt_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_receipt_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipt_detail_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipts_list_controller.dart';

part 'inventory_receipt_actions.g.dart';

/// What `create` and `complementary` answer: the refusal, or the receipt's id
/// to navigate to.
typedef ReceiptOpened = ({AppError? error, int? id});

/// What `confirm` and `cancel` answer: the refusal, or whether the server
/// raised cost warnings beyond the computed over-receipts (research R6).
typedef ReceiptSettled = ({AppError? error, bool hasUnmappedWarnings});

/// The refusals after which the receipt on screen is stale: someone else
/// changed it meanwhile (spec edge case: concurrent edits, research R7).
const _staleCodes = {
  api.ErrorCode.documentPeriodNotEditable,
  api.ErrorCode.inventoryDocumentPeriodAlreadyCancelled,
  api.ErrorCode.lockPeriodBusy,
};

/// Every write on a warehouse receipt (spec 067 contracts/repository.md
/// "Actions notifier").
///
/// Each method answers the [AppError] the server refused with, or `null`
/// when it went through, rather than throwing: the dialog that asked shows
/// the refusal where the user is looking. On success the returned receipt is
/// put into its detail provider (when one is alive) and the list is
/// invalidated.
///
/// Keep-alive because a write outlives the dialog that started it.
@Riverpod(keepAlive: true)
class InventoryReceiptActions extends _$InventoryReceiptActions {
  @override
  void build() {}

  /// `POST /inventory-receipts`: a new draft.
  Future<ReceiptOpened> create({required int warehouseId, String? comment}) =>
      _opened(
        null,
        (r) => r.create(warehouseId: warehouseId, comment: comment),
      );

  /// `PUT /inventory-receipts/{id}`. See
  /// [InventoryReceiptRepository.updateHeader].
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

  /// `POST /inventory-receipts/{id}/lines`. The server merges a product
  /// already on the receipt into its line.
  Future<AppError?> addLine(
    int id, {
    required int productId,
    required Decimal quantity,
  }) async => (await _run(
    id,
    (r) => r.addLine(id, productId: productId, quantity: quantity),
  )).error;

  /// `PUT /inventory-receipts/{id}/lines/{lineId}`.
  Future<AppError?> updateLine(
    int id,
    int lineId, {
    required Decimal quantity,
  }) async => (await _run(
    id,
    (r) => r.updateLine(id, lineId, quantity: quantity),
  )).error;

  /// `DELETE /inventory-receipts/{id}/lines/{lineId}`.
  Future<AppError?> removeLine(int id, int lineId) async =>
      (await _run(id, (r) => r.removeLine(id, lineId))).error;

  /// `POST /inventory-receipts/{id}/confirm`.
  Future<ReceiptSettled> confirm(int id) => _settled(id, (r) => r.confirm(id));

  /// `POST /inventory-receipts/{id}/cancel`.
  Future<ReceiptSettled> cancel(int id) => _settled(id, (r) => r.cancel(id));

  /// `POST /inventory-receipts/{id}/complementary`: the existing draft or a
  /// new one, whose id is answered.
  Future<ReceiptOpened> complementary(int id) =>
      _opened(id, (r) => r.complementary(id));

  Future<ReceiptOpened> _opened(
    int? id,
    Future<InventoryReceipt> Function(InventoryReceiptRepository r) write,
  ) async {
    final (:error, :receipt) = await _run(id, write);
    return (error: error, id: receipt?.id);
  }

  Future<ReceiptSettled> _settled(
    int id,
    Future<InventoryReceipt> Function(InventoryReceiptRepository r) write,
  ) async {
    final (:error, :receipt) = await _run(id, write);
    return (
      error: error,
      hasUnmappedWarnings: receipt?.hasUnmappedWarnings ?? false,
    );
  }

  /// The one write path. [id] is the receipt written to (`null` for
  /// `create`), refreshed after a stale refusal.
  Future<({AppError? error, InventoryReceipt? receipt})> _run(
    int? id,
    Future<InventoryReceipt> Function(InventoryReceiptRepository r) write,
  ) async {
    final InventoryReceipt receipt;
    try {
      receipt = await write(ref.read(inventoryReceiptRepositoryProvider));
    } on AppError catch (error) {
      if (id != null && _staleCodes.contains(error.problem?.code)) {
        final detail = inventoryReceiptDetailControllerProvider(id);
        if (ref.exists(detail)) await ref.read(detail.notifier).refresh();
      }
      return (error: error, receipt: null);
    }
    final detail = inventoryReceiptDetailControllerProvider(receipt.id);
    if (ref.exists(detail)) ref.read(detail.notifier).put(receipt);
    ref.invalidate(inventoryReceiptsListControllerProvider);
    return (error: null, receipt: receipt);
  }
}
