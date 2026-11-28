import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_order_repository.dart';
import 'package:mbe_ui/features/sales/data/wire_value_setters.dart';

final purchaseOrderRepositoryProvider = Provider<PurchaseOrderRepository>(
  (ref) => PurchaseOrderRepositoryImpl(ref.watch(dioProvider)),
);

/// `PurchaseOrderRepository` backed by the generated `PurchaseOrdersApi`
/// (spec 080 research R7 and R8).
class PurchaseOrderRepositoryImpl implements PurchaseOrderRepository {
  PurchaseOrderRepositoryImpl(this._dio)
    : _api = api.PurchaseOrdersApi(_dio, appSerializers);

  final Dio _dio;
  final api.PurchaseOrdersApi _api;

  @override
  Future<PurchaseOrderPage> list({
    bool all = false,
    InventoryDocumentStatus? status,
    int? supplierId,
    int? creatorId,
    int? orderId,
    DateTime? from,
    DateTime? to,
    required int skip,
    required int limit,
  }) async {
    try {
      final result = (await _api.listPurchaseOrdersApiV1PurchaseOrdersGet(
        all: all ? true : null,
        status: status?.name,
        supplier: supplierId,
        creator: creatorId,
        id: orderId,
        from: from?.toDate(),
        to: to?.toDate(),
        skip: skip,
        limit: limit,
      )).data;
      if (result == null) throw const AppError.server();
      return PurchaseOrderPage(
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
  Future<PurchaseOrder> get(int id) => _order(
    () => _api.getPurchaseOrderApiV1PurchaseOrdersOrderIdGet(orderId: id),
  );

  @override
  Future<PurchaseOrder> create({
    required int supplierId,
    DateTime? estimatedReceiptDate,
    String? comment,
  }) => _order(
    () => _api.createPurchaseOrderApiV1PurchaseOrdersPost(
      purchaseOrderCreate: api.PurchaseOrderCreate((b) {
        b.supplier = supplierId;
        b.estimatedReceiptDate = estimatedReceiptDate?.toDate();
        b.comment = comment;
      }),
    ),
  );

  @override
  Future<PurchaseOrder> updateHeader(
    int id, {
    int? supplierId,
    DateTime? estimatedReceiptDate,
    bool clearDate = false,
    String? comment,
    bool clearComment = false,
  }) {
    // A cleared note goes as "" (`_toOrder` shows "" as no note).
    final sentComment = clearComment ? '' : comment;
    if (clearDate) {
      return _clearDate(id, supplierId: supplierId, comment: sentComment);
    }
    return _order(
      () => _api.updatePurchaseOrderApiV1PurchaseOrdersOrderIdPut(
        orderId: id,
        purchaseOrderUpdate: api.PurchaseOrderUpdate((b) {
          b.supplier = supplierId;
          b.estimatedReceiptDate = estimatedReceiptDate?.toDate();
          b.comment = sentComment;
        }),
      ),
    );
  }

  /// A raw PUT: `PurchaseOrderUpdate`'s serializer drops null fields, so it
  /// cannot send the explicit `estimated_receipt_date: null` that clears the
  /// date (the server applies `exclude_unset`, research R7).
  // simplified: the raw body is the header fields only; if the live check
  // (T036) shows the server rejects the null, drop the clear from the UI.
  Future<PurchaseOrder> _clearDate(
    int id, {
    int? supplierId,
    String? comment,
  }) async {
    try {
      final response = await _dio.put<Object>(
        '/api/v1/purchase-orders/$id',
        data: {
          'supplier': ?supplierId,
          'comment': ?comment,
          'estimated_receipt_date': null,
        },
      );
      final raw = response.data;
      if (raw == null) throw const AppError.server();
      return _toOrder(
        appSerializers.deserialize(
              raw,
              specifiedType: const FullType(api.PurchaseOrderResponse),
            )
            as api.PurchaseOrderResponse,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PurchaseOrder> addLine(
    int id, {
    required int productId,
    required Decimal quantity,
  }) => _order(
    () => _api.addPurchaseOrderLineApiV1PurchaseOrdersOrderIdLinesPost(
      orderId: id,
      orderLineAdd: api.OrderLineAdd((b) {
        b.product = productId;
        setQuantity5(b.quantity, quantity.toString());
      }),
    ),
  );

  @override
  Future<PurchaseOrder> updateLine(
    int id,
    int lineId, {
    Decimal? quantity,
    int? warehouseId,
    Decimal? price,
    Decimal? taxRate,
  }) => _order(
    () => _api.updatePurchaseOrderLineApiV1PurchaseOrdersOrderIdLinesLineIdPut(
      orderId: id,
      lineId: lineId,
      orderLineUpdate: api.OrderLineUpdate((b) {
        if (quantity != null) setQuantity4(b.quantity, quantity.toString());
        b.warehouse = warehouseId;
        if (price != null) setPrice(b.price, price.toString());
        if (taxRate != null) setTaxRate1(b.taxRate, taxRate.toString());
      }),
    ),
  );

  @override
  Future<PurchaseOrder> removeLine(int id, int lineId) => _order(
    () =>
        _api.removePurchaseOrderLineApiV1PurchaseOrdersOrderIdLinesLineIdDelete(
          orderId: id,
          lineId: lineId,
        ),
  );

  @override
  Future<PurchaseOrder> addRequestLines(int id, {required int requestId}) =>
      _order(
        () => _api
            .addPurchaseRequestLinesApiV1PurchaseOrdersOrderIdRequestLinesPost(
              orderId: id,
              addRequestLines: api.AddRequestLines(
                (b) => b.purchaseRequest = requestId,
              ),
            ),
      );

  @override
  Future<PurchaseOrder> confirm(int id) => _order(
    () => _api.confirmPurchaseOrderApiV1PurchaseOrdersOrderIdConfirmPost(
      orderId: id,
    ),
  );

  @override
  Future<PurchaseOrder> cancel(int id) => _order(
    () => _api.cancelPurchaseOrderApiV1PurchaseOrdersOrderIdCancelPost(
      orderId: id,
    ),
  );

  @override
  Future<List<ToPurchaseGroup>> toPurchase({int? facilityId}) async {
    try {
      final result =
          (await _api.toPurchaseBySupplierApiV1PurchaseOrdersToPurchaseGet(
            facility: facilityId,
          )).data;
      if (result == null) throw const AppError.server();
      return result.groups.map(_group).toList();
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PurchaseOrder> createFromGroup({
    required int supplierId,
    required int facilityId,
  }) => _order(
    () => _api.createPurchaseOrderFromGroupApiV1PurchaseOrdersToPurchasePost(
      toPurchaseCreate: api.ToPurchaseCreate((b) {
        b.supplier = supplierId;
        b.facility = facilityId;
      }),
    ),
  );

  @override
  Future<OrderEmailReceipt> email(
    int id, {
    required List<String> recipients,
    String? message,
  }) async {
    try {
      final result =
          (await _api.emailPurchaseOrderApiV1PurchaseOrdersOrderIdEmailPost(
            orderId: id,
            purchaseOrderEmailRequest: api.PurchaseOrderEmailRequest((b) {
              b.to = ListBuilder(recipients);
              b.message = message;
            }),
          )).data;
      if (result == null) throw const AppError.server();
      return OrderEmailReceipt(
        recipients: result.recipients.toList(),
        sentAt: result.sentAt,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  Future<PurchaseOrder> _order(
    Future<Response<api.PurchaseOrderResponse>> Function() call,
  ) async {
    try {
      final result = (await call()).data;
      if (result == null) throw const AppError.server();
      return _toOrder(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

/// An unknown wire value is a mapping error, never a guess; `paid` never
/// occurs on a purchase order (as in spec 067).
InventoryDocumentStatus _status(api.DocumentStatus status) {
  if (status == api.DocumentStatus.draft) return InventoryDocumentStatus.draft;
  if (status == api.DocumentStatus.completed) {
    return InventoryDocumentStatus.completed;
  }
  if (status == api.DocumentStatus.cancelled) {
    return InventoryDocumentStatus.cancelled;
  }
  throw AppError.server(
    message: 'Unexpected purchase order status: ${status.name}',
  );
}

/// An unparseable decimal string is a mapping error.
Decimal _decimal(String value) {
  final parsed = Decimal.tryParse(value);
  if (parsed == null) {
    throw AppError.server(message: 'Unexpected decimal value: $value');
  }
  return parsed;
}

String? _note(String? comment) => (comment ?? '').isEmpty ? null : comment;

PurchaseOrderSummary _summary(api.PurchaseOrderSummary s) =>
    PurchaseOrderSummary(
      id: s.purchaseOrderId,
      status: _status(s.status),
      supplierId: s.supplier,
      supplierName: s.supplierName,
      estimatedReceiptDate: s.estimatedReceiptDate,
      comment: _note(s.comment),
      creatorId: s.creator,
      updaterId: s.updater,
      createdAt: s.creationTime,
      modifiedAt: s.modificationTime,
      lineCount: s.lineCount,
      subtotal: _decimal(s.subtotal),
      tax: _decimal(s.tax),
      total: _decimal(s.total),
    );

/// The server's `warnings` are English text with no code and are dropped;
/// `skipped` is kept as a count (research R10).
PurchaseOrder _toOrder(api.PurchaseOrderResponse r) => PurchaseOrder(
  id: r.purchaseOrderId,
  status: _status(r.status),
  supplierId: r.supplier,
  supplierName: r.supplierName,
  estimatedReceiptDate: r.estimatedReceiptDate,
  comment: _note(r.comment),
  creatorId: r.creator,
  updaterId: r.updater,
  createdAt: r.creationTime,
  modifiedAt: r.modificationTime,
  lineCount: r.lineCount,
  subtotal: _decimal(r.subtotal),
  tax: _decimal(r.tax),
  total: _decimal(r.total),
  lines: r.lines?.map(_line).toList() ?? [],
  skippedCount: r.skipped?.length ?? 0,
  receipts: r.receipts?.map(_receipt).toList() ?? [],
);

PurchaseOrderLine _line(api.PurchaseOrderLine l) => PurchaseOrderLine(
  id: l.purchaseOrderDetailId,
  productId: l.product,
  productCode: l.productCode,
  productName: l.productName,
  warehouseId: l.warehouse,
  quantity: _decimal(l.quantity),
  price: _decimal(l.price),
  taxRate: _decimal(l.taxRate),
  amount: _decimal(l.amount),
  requestLineId: l.purchaseRequestDetail,
  requestId: l.purchaseRequest,
  quantityReceived: l.quantityReceived == null
      ? null
      : _decimal(l.quantityReceived!),
  quantityPending: l.quantityPending == null
      ? null
      : _decimal(l.quantityPending!),
);

OrderReceipt _receipt(api.GeneratedReceipt r) => OrderReceipt(
  id: r.inventoryReceiptId,
  warehouseId: r.warehouse,
  facilityId: r.facility,
  lineCount: r.lineCount,
);

ToPurchaseGroup _group(api.ToPurchaseGroup g) => ToPurchaseGroup(
  supplierId: g.supplier,
  supplierName: g.supplierName,
  facilityId: g.facility,
  lineCount: g.lineCount,
  estimatedTotal: _decimal(g.estimatedTotal),
  lines: g.lines.map(_toPurchaseLine).toList(),
);

ToPurchaseLine _toPurchaseLine(api.ToPurchaseLine l) => ToPurchaseLine(
  requestLineId: l.purchaseRequestDetailId,
  requestId: l.purchaseRequest,
  serial: l.serial,
  productId: l.product,
  productCode: l.productCode,
  productName: l.productName,
  quantity: _decimal(l.quantity),
  warehouseId: l.warehouse,
  cost: _decimal(l.cost),
);

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
