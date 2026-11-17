import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';

/// Inventory transfers (spec 069), over the generated
/// `InventoryTransfersApi`. Every method throws `AppError` on failure. Every
/// mutation returns the full transfer.
abstract class InventoryTransferRepository {
  /// `GET /inventory-transfers?status&warehouse&skip&limit`. The server
  /// orders newest first; [warehouseId] matches the origin or the destination.
  Future<InventoryTransferPage> list({
    InventoryTransferStatus? status,
    int? warehouseId,
    required int skip,
    required int limit,
  });

  /// `GET /inventory-transfers/{id}`.
  Future<InventoryTransfer> get(int id);

  /// `POST /inventory-transfers`: a draft.
  Future<InventoryTransfer> create({
    required int warehouseId,
    required int warehouseToId,
    String? comment,
  });

  /// `PUT /inventory-transfers/{id}`. Each field is sent only when given.
  /// [clearComment] empties the notes.
  Future<InventoryTransfer> updateHeader(
    int id, {
    int? warehouseId,
    int? warehouseToId,
    String? comment,
    bool clearComment = false,
  });

  /// `POST /inventory-transfers/{id}/lines`.
  Future<InventoryTransfer> addLine(
    int id, {
    required int productId,
    required Decimal quantity,
  });

  /// `PUT /inventory-transfers/{id}/lines/{lineId}`.
  Future<InventoryTransfer> updateLine(
    int id,
    int lineId, {
    required Decimal quantity,
  });

  /// `DELETE /inventory-transfers/{id}/lines/{lineId}`.
  Future<InventoryTransfer> removeLine(int id, int lineId);

  /// `POST /inventory-transfers/{id}/sales-order-items`.
  Future<InventoryTransfer> addSalesOrderItems(
    int id, {
    required int salesOrderId,
  });

  /// `POST /inventory-transfers/{id}/dispatch`.
  Future<InventoryTransfer> dispatch(int id);

  /// `POST /inventory-transfers/{id}/receive`. A null [lines] sends no body
  /// and receives everything outstanding; otherwise it maps line id to the
  /// quantity received.
  Future<InventoryTransfer> receive(int id, {Map<int, Decimal>? lines});

  /// `POST /inventory-transfers/{id}/close`: closes what is still pending.
  Future<InventoryTransfer> close(int id);

  /// `POST /inventory-transfers/{id}/cancel`.
  Future<InventoryTransfer> cancel(int id);

  /// `GET /inventory-transfers/in-transit?facility`.
  Future<InTransitView> inTransit({required int facilityId});
}
