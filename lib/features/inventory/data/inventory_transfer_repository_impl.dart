import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_transfer_repository.dart';

final inventoryTransferRepositoryProvider =
    Provider<InventoryTransferRepository>(
      (ref) => InventoryTransferRepositoryImpl(ref.watch(dioProvider)),
    );

/// `InventoryTransferRepository` backed by the generated
/// `InventoryTransfersApi` (spec 069).
class InventoryTransferRepositoryImpl implements InventoryTransferRepository {
  InventoryTransferRepositoryImpl(Dio dio)
    : _api = api.InventoryTransfersApi(dio, appSerializers);

  final api.InventoryTransfersApi _api;

  @override
  Future<InventoryTransferPage> list({
    InventoryTransferStatus? status,
    int? warehouseId,
    required int skip,
    required int limit,
  }) async {
    try {
      final response = await _api
          .listInventoryTransfersApiV1InventoryTransfersGet(
            status: status == null ? null : _wireStatus(status),
            warehouse: warehouseId,
            skip: skip,
            limit: limit,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return InventoryTransferPage(
        items: result.items.map(_summary).toList(),
        total: result.total,
        pageIndex: skip ~/ limit,
        pageSize: limit,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<InventoryTransfer> get(int id) => _transfer(
    () =>
        _api.getInventoryTransferApiV1InventoryTransfersInventoryTransferIdGet(
          inventoryTransferId: id,
        ),
  );

  @override
  Future<InventoryTransfer> create({
    required int warehouseId,
    required int warehouseToId,
    String? comment,
  }) => _transfer(
    () => _api.createInventoryTransferApiV1InventoryTransfersPost(
      transferCreate: api.TransferCreate((b) {
        b.warehouse = warehouseId;
        b.warehouseTo = warehouseToId;
        b.comment = comment;
      }),
    ),
  );

  @override
  Future<InventoryTransfer> updateHeader(
    int id, {
    int? warehouseId,
    int? warehouseToId,
    String? comment,
    bool clearComment = false,
  }) => _transfer(
    () => _api
        .updateInventoryTransferApiV1InventoryTransfersInventoryTransferIdPut(
          inventoryTransferId: id,
          transferUpdate: api.TransferUpdate((b) {
            b.warehouse = warehouseId;
            b.warehouseTo = warehouseToId;
            // simplified: a cleared note goes as "" because the generated client
            // drops a null field; `_toTransfer` reads "" as no note. Should a
            // stored "" ever matter, fall back to a raw `dio.put` with
            // {"comment": null}, as 068's issue repository notes.
            b.comment = clearComment ? '' : comment;
          }),
        ),
  );

  @override
  Future<InventoryTransfer> addLine(
    int id, {
    required int productId,
    required Decimal quantity,
  }) => _transfer(
    () => _api
        .addInventoryTransferLineApiV1InventoryTransfersInventoryTransferIdLinesPost(
          inventoryTransferId: id,
          lineAdd: api.LineAdd((b) {
            b.product = productId;
            _setQuantity(b.quantity, quantity);
          }),
        ),
  );

  @override
  Future<InventoryTransfer> updateLine(
    int id,
    int lineId, {
    required Decimal quantity,
  }) => _transfer(
    () => _api
        .updateInventoryTransferLineApiV1InventoryTransfersInventoryTransferIdLinesLineIdPut(
          inventoryTransferId: id,
          lineId: lineId,
          lineUpdate: api.LineUpdate((b) => _setQuantity(b.quantity, quantity)),
        ),
  );

  @override
  Future<InventoryTransfer> removeLine(int id, int lineId) => _transfer(
    () => _api
        .removeInventoryTransferLineApiV1InventoryTransfersInventoryTransferIdLinesLineIdDelete(
          inventoryTransferId: id,
          lineId: lineId,
        ),
  );

  @override
  Future<InventoryTransfer> addSalesOrderItems(
    int id, {
    required int salesOrderId,
  }) => _transfer(
    () => _api
        .addInventoryTransferSalesOrderItemsApiV1InventoryTransfersInventoryTransferIdSalesOrderItemsPost(
          inventoryTransferId: id,
          salesOrderItemsAdd: api.SalesOrderItemsAdd(
            (b) => b.salesOrder = salesOrderId,
          ),
        ),
  );

  @override
  Future<InventoryTransfer> dispatch(int id) => _transfer(
    () => _api
        .dispatchInventoryTransferApiV1InventoryTransfersInventoryTransferIdDispatchPost(
          inventoryTransferId: id,
        ),
  );

  @override
  Future<InventoryTransfer> receive(
    int id, {
    Map<int, Decimal>? lines,
  }) => _transfer(
    () => _api
        .receiveInventoryTransferApiV1InventoryTransfersInventoryTransferIdReceivePost(
          inventoryTransferId: id,
          transferReceive: lines == null
              ? null
              : api.TransferReceive(
                  (b) => b.lines.addAll([
                    for (final MapEntry(:key, :value) in lines.entries)
                      api.TransferReceiveLine((l) {
                        l.lineId = key;
                        _setQuantity(l.quantity, value);
                      }),
                  ]),
                ),
        ),
  );

  @override
  Future<InventoryTransfer> close(int id) => _transfer(
    () => _api
        .closeInventoryTransferApiV1InventoryTransfersInventoryTransferIdClosePost(
          inventoryTransferId: id,
        ),
  );

  @override
  Future<InventoryTransfer> cancel(int id) => _transfer(
    () => _api
        .cancelInventoryTransferApiV1InventoryTransfersInventoryTransferIdCancelPost(
          inventoryTransferId: id,
        ),
  );

  @override
  Future<InTransitView> inTransit({required int facilityId}) async {
    try {
      final response = await _api
          .getInventoryInTransitApiV1InventoryTransfersInTransitGet(
            facility: facilityId,
          );
      final r = response.data;
      if (r == null) throw const AppError.server();
      return InTransitView(
        facilityId: r.facility,
        products: [
          for (final p in r.products ?? <api.InTransitProduct>[])
            InTransitProductTotal(
              productId: p.product,
              productCode: p.productCode,
              productName: p.productName,
              quantity: Decimal.parse(p.quantity),
            ),
        ],
        lines: [
          for (final l in r.lines ?? <api.InTransitLine>[])
            InTransitLineItem(
              transferId: l.inventoryTransferId,
              serial: l.serial,
              warehouseId: l.warehouse,
              warehouseToId: l.warehouseTo,
              lineId: l.transferDetailId,
              productId: l.product,
              productCode: l.productCode,
              productName: l.productName,
              quantityOutstanding: Decimal.parse(l.quantityOutstanding),
            ),
        ],
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  Future<InventoryTransfer> _transfer(
    Future<Response<api.InventoryTransferResponse>> Function() call,
  ) async {
    try {
      final result = (await call()).data;
      if (result == null) throw const AppError.server();
      return _toTransfer(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

/// The wire carries quantities as decimal strings (`Quantity5`): the String
/// arm, key `0`, as everywhere else.
void _setQuantity(api.Quantity5Builder builder, Decimal value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value.toString()});
}

api.TransferStatus _wireStatus(InventoryTransferStatus status) =>
    switch (status) {
      InventoryTransferStatus.draft => api.TransferStatus.draft,
      InventoryTransferStatus.inTransit => api.TransferStatus.inTransit,
      InventoryTransferStatus.received => api.TransferStatus.received,
      InventoryTransferStatus.cancelled => api.TransferStatus.cancelled,
    };

InventoryTransferStatus _status(api.TransferStatus status) {
  if (status == api.TransferStatus.draft) return InventoryTransferStatus.draft;
  if (status == api.TransferStatus.inTransit) {
    return InventoryTransferStatus.inTransit;
  }
  if (status == api.TransferStatus.received) {
    return InventoryTransferStatus.received;
  }
  if (status == api.TransferStatus.cancelled) {
    return InventoryTransferStatus.cancelled;
  }
  throw AppError.server(message: 'Unexpected transfer status: ${status.name}');
}

InventoryTransferSummary _summary(api.InventoryTransferSummary s) =>
    InventoryTransferSummary(
      id: s.inventoryTransferId,
      facilityId: s.facility,
      warehouseId: s.warehouse,
      warehouseToId: s.warehouseTo,
      serial: s.serial,
      status: _status(s.status),
      creatorId: s.creator,
      createdAt: s.creationTime,
    );

InventoryTransfer _toTransfer(api.InventoryTransferResponse r) =>
    InventoryTransfer(
      id: r.inventoryTransferId,
      facilityId: r.facility,
      warehouseId: r.warehouse,
      warehouseToId: r.warehouseTo,
      serial: r.serial,
      status: _status(r.status),
      creatorId: r.creator,
      createdAt: r.creationTime,
      comment: (r.comment ?? '').isEmpty ? null : r.comment,
      updaterId: r.updater,
      modifiedAt: r.modificationTime,
      lines: r.lines?.map(_line).toList() ?? [],
    );

InventoryTransferLine _line(api.InventoryTransferLineResponse l) =>
    InventoryTransferLine(
      id: l.transferDetailId,
      productId: l.product,
      productCode: l.productCode,
      productName: l.productName,
      quantity: Decimal.parse(l.quantity),
      quantityReceived: Decimal.parse(l.quantityReceived),
      quantityOutstanding: Decimal.parse(l.quantityOutstanding),
    );

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
