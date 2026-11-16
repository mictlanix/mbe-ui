import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_receipt_repository.dart';

final inventoryReceiptRepositoryProvider = Provider<InventoryReceiptRepository>(
  (ref) => InventoryReceiptRepositoryImpl(ref.watch(dioProvider)),
);

/// `InventoryReceiptRepository` backed by the generated `InventoryReceiptsApi`
/// (spec 067 R8).
class InventoryReceiptRepositoryImpl implements InventoryReceiptRepository {
  InventoryReceiptRepositoryImpl(Dio dio)
    : _api = api.InventoryReceiptsApi(dio, appSerializers);

  final api.InventoryReceiptsApi _api;

  @override
  Future<InventoryReceiptPage> list({
    InventoryDocumentStatus? status,
    int? warehouseId,
    required int skip,
    required int limit,
  }) async {
    try {
      final response = await _api
          .listInventoryReceiptsApiV1InventoryReceiptsGet(
            status: status?.name,
            warehouse: warehouseId,
            skip: skip,
            limit: limit,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return InventoryReceiptPage(
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
  Future<InventoryReceipt> get(int id) => _receipt(
    () => _api.getInventoryReceiptApiV1InventoryReceiptsReceiptIdGet(
      receiptId: id,
    ),
  );

  @override
  Future<InventoryReceipt> create({
    required int warehouseId,
    String? comment,
  }) => _receipt(
    () => _api.createInventoryReceiptApiV1InventoryReceiptsPost(
      receiptCreate: api.ReceiptCreate((b) {
        b.warehouse = warehouseId;
        b.comment = comment;
      }),
    ),
  );

  @override
  Future<InventoryReceipt> updateHeader(
    int id, {
    int? warehouseId,
    String? comment,
    bool clearComment = false,
  }) => _receipt(
    () => _api.updateInventoryReceiptApiV1InventoryReceiptsReceiptIdPut(
      receiptId: id,
      receiptUpdate: api.ReceiptUpdate((b) {
        b.warehouse = warehouseId;
        // simplified: a cleared note goes as "" because the generated client
        // drops a null field. The live check (T030, 2026-11-16) showed the
        // server stores "" and `_toReceipt` shows it as no note; should a
        // stored "" ever matter, fall back to a raw `dio.put` with
        // {"comment": null} deserialized with appSerializers.
        b.comment = clearComment ? '' : comment;
      }),
    ),
  );

  @override
  Future<InventoryReceipt> addLine(
    int id, {
    required int productId,
    required Decimal quantity,
  }) => _receipt(
    () => _api.addInventoryReceiptLineApiV1InventoryReceiptsReceiptIdLinesPost(
      receiptId: id,
      lineAdd: api.LineAdd((b) {
        b.product = productId;
        _setQuantity(b.quantity, quantity);
      }),
    ),
  );

  @override
  Future<InventoryReceipt> updateLine(
    int id,
    int lineId, {
    required Decimal quantity,
  }) => _receipt(
    () => _api
        .updateInventoryReceiptLineApiV1InventoryReceiptsReceiptIdLinesLineIdPut(
          receiptId: id,
          lineId: lineId,
          lineUpdate: api.LineUpdate((b) => _setQuantity(b.quantity, quantity)),
        ),
  );

  @override
  Future<InventoryReceipt> removeLine(int id, int lineId) => _receipt(
    () => _api
        .removeInventoryReceiptLineApiV1InventoryReceiptsReceiptIdLinesLineIdDelete(
          receiptId: id,
          lineId: lineId,
        ),
  );

  @override
  Future<InventoryReceipt> confirm(int id) => _receipt(
    () =>
        _api.confirmInventoryReceiptApiV1InventoryReceiptsReceiptIdConfirmPost(
          receiptId: id,
        ),
  );

  @override
  Future<InventoryReceipt> cancel(int id) => _receipt(
    () => _api.cancelInventoryReceiptApiV1InventoryReceiptsReceiptIdCancelPost(
      receiptId: id,
    ),
  );

  @override
  Future<InventoryReceipt> complementary(int id) => _receipt(
    () => _api
        .complementaryInventoryReceiptApiV1InventoryReceiptsReceiptIdComplementaryPost(
          receiptId: id,
        ),
  );

  Future<InventoryReceipt> _receipt(
    Future<Response<api.InventoryReceiptResponse>> Function() call,
  ) async {
    try {
      final result = (await call()).data;
      if (result == null) throw const AppError.server();
      return _toReceipt(result);
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

/// A `paid` status never occurs on a receipt, so it is a mapping error
/// rather than a guess.
InventoryDocumentStatus _status(api.DocumentStatus status) {
  if (status == api.DocumentStatus.draft) return InventoryDocumentStatus.draft;
  if (status == api.DocumentStatus.completed) {
    return InventoryDocumentStatus.completed;
  }
  if (status == api.DocumentStatus.cancelled) {
    return InventoryDocumentStatus.cancelled;
  }
  throw AppError.server(message: 'Unexpected receipt status: ${status.name}');
}

InventoryReceiptSummary _summary(api.InventoryReceiptSummary s) =>
    InventoryReceiptSummary(
      id: s.inventoryReceiptId,
      facilityId: s.facility,
      warehouseId: s.warehouse,
      purchaseOrderId: s.purchaseOrder,
      serial: s.serial,
      status: _status(s.status),
      creatorId: s.creator,
      createdAt: s.creationTime,
    );

InventoryReceipt _toReceipt(api.InventoryReceiptResponse r) => InventoryReceipt(
  id: r.inventoryReceiptId,
  facilityId: r.facility,
  warehouseId: r.warehouse,
  purchaseOrderId: r.purchaseOrder,
  serial: r.serial,
  status: _status(r.status),
  creatorId: r.creator,
  createdAt: r.creationTime,
  comment: (r.comment ?? '').isEmpty ? null : r.comment,
  updaterId: r.updater,
  modifiedAt: r.modificationTime,
  lines: r.lines?.map(_line).toList() ?? [],
  serverWarningCount: r.warnings?.length ?? 0,
);

InventoryReceiptLine _line(api.InventoryReceiptLineResponse l) =>
    InventoryReceiptLine(
      id: l.receiptDetailId,
      productId: l.product,
      productCode: l.productCode,
      productName: l.productName,
      quantity: Decimal.parse(l.quantity),
      purchaseOrderLineId: l.purchaseOrderDetail,
      quantityOrdered: Decimal.parse(l.quantityOrdered),
      quantityReceivedElsewhere: l.quantityReceivedElsewhere == null
          ? null
          : Decimal.parse(l.quantityReceivedElsewhere!),
    );

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
