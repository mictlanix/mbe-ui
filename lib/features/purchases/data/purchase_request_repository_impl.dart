import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_request_repository.dart';

final purchaseRequestRepositoryProvider = Provider<PurchaseRequestRepository>(
  (ref) => PurchaseRequestRepositoryImpl(ref.watch(dioProvider)),
);

/// `PurchaseRequestRepository` backed by the generated `PurchaseRequestsApi`
/// (spec 079 R6 and R8).
class PurchaseRequestRepositoryImpl implements PurchaseRequestRepository {
  PurchaseRequestRepositoryImpl(Dio dio)
    : _api = api.PurchaseRequestsApi(dio, appSerializers);

  final api.PurchaseRequestsApi _api;

  @override
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
  }) => _page(
    skip: skip,
    limit: limit,
    call: () => _api.listPurchaseRequestsApiV1PurchaseRequestsGet(
      all: all ? true : null,
      status: status?.name,
      facility: facilityId,
      warehouse: warehouseId,
      creator: creatorId,
      serial: serial,
      from: from?.toDate(),
      to: to?.toDate(),
      skip: skip,
      limit: limit,
    ),
  );

  @override
  Future<PurchaseRequestPage> approvalQueue({
    int? facilityId,
    required int skip,
    required int limit,
  }) => _page(
    skip: skip,
    limit: limit,
    call: () =>
        _api.purchaseRequestApprovalQueueApiV1PurchaseRequestsApprovalQueueGet(
          facility: facilityId,
          skip: skip,
          limit: limit,
        ),
  );

  @override
  Future<PurchaseRequest> get(int id) => _request(
    () =>
        _api.getPurchaseRequestApiV1PurchaseRequestsRequestIdGet(requestId: id),
  );

  @override
  Future<PurchaseRequest> create({required int warehouseId, String? comment}) =>
      _request(
        () => _api.createPurchaseRequestApiV1PurchaseRequestsPost(
          purchaseRequestCreate: api.PurchaseRequestCreate((b) {
            b.warehouse = warehouseId;
            b.comment = comment;
          }),
        ),
      );

  @override
  Future<PurchaseRequest> updateHeader(
    int id, {
    int? warehouseId,
    String? comment,
    bool clearComment = false,
  }) => _request(
    () => _api.updatePurchaseRequestApiV1PurchaseRequestsRequestIdPut(
      requestId: id,
      purchaseRequestUpdate: api.PurchaseRequestUpdate((b) {
        b.warehouse = warehouseId;
        // simplified: a cleared note goes as "" because the generated client
        // drops a null field, and `_toRequest` shows "" as no note. If the
        // live check (T035) shows the server rejects or keeps it, fall back
        // to a raw `dio.put` with {"comment": null} deserialized with
        // appSerializers.
        b.comment = clearComment ? '' : comment;
      }),
    ),
  );

  @override
  Future<PurchaseRequest> addLine(int id, {required int productId}) => _request(
    () => _api.addPurchaseRequestLineApiV1PurchaseRequestsRequestIdLinesPost(
      requestId: id,
      requestLineAdd: api.RequestLineAdd((b) => b.product = productId),
    ),
  );

  @override
  Future<PurchaseRequest> updateLine(
    int id,
    int lineId, {
    Decimal? quantity,
    String? productName,
    int? warehouseId,
  }) => _request(
    () => _api
        .updatePurchaseRequestLineApiV1PurchaseRequestsRequestIdLinesLineIdPut(
          requestId: id,
          lineId: lineId,
          requestLineUpdate: api.RequestLineUpdate((b) {
            if (quantity != null) _setQuantity(b.quantity, quantity);
            b.productName = productName;
            b.warehouse = warehouseId;
          }),
        ),
  );

  @override
  Future<PurchaseRequest> removeLine(int id, int lineId) => _request(
    () => _api
        .removePurchaseRequestLineApiV1PurchaseRequestsRequestIdLinesLineIdDelete(
          requestId: id,
          lineId: lineId,
        ),
  );

  @override
  Future<PurchaseRequest> submit(int id) => _request(
    () => _api.submitPurchaseRequestApiV1PurchaseRequestsRequestIdSubmitPost(
      requestId: id,
    ),
  );

  @override
  Future<PurchaseRequest> cancel(int id) => _request(
    () => _api.cancelPurchaseRequestApiV1PurchaseRequestsRequestIdCancelPost(
      requestId: id,
    ),
  );

  @override
  Future<PurchaseRequest> markLine(
    int id,
    int lineId, {
    required bool toPurchase,
  }) => _request(
    () => _api
        .markPurchaseRequestLineApiV1PurchaseRequestsRequestIdLinesLineIdToPurchasePut(
          requestId: id,
          lineId: lineId,
          toPurchaseSet: api.ToPurchaseSet((b) => b.toPurchase = toPurchase),
        ),
  );

  @override
  Future<PurchaseRequest> approve(int id) => _request(
    () => _api.approvePurchaseRequestApiV1PurchaseRequestsRequestIdApprovePost(
      requestId: id,
    ),
  );

  @override
  Future<List<BulkApproveOutcome>> approveMany(List<int> ids) async {
    try {
      final result =
          (await _api.approvePurchaseRequestsApiV1PurchaseRequestsApprovePost(
            bulkApprove: api.BulkApprove((b) => b.ids = ListBuilder(ids)),
          )).data;
      if (result == null) throw const AppError.server();
      return result.results.map(_outcome).toList();
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<PurchaseRequest> reject(int id, {required String reason}) => _request(
    () => _api.rejectPurchaseRequestApiV1PurchaseRequestsRequestIdRejectPost(
      requestId: id,
      rejectRequest: api.RejectRequest((b) => b.reason = reason),
    ),
  );

  Future<PurchaseRequestPage> _page({
    required int skip,
    required int limit,
    required Future<Response<api.ListResponsePurchaseRequestSummary>> Function()
    call,
  }) async {
    try {
      final result = (await call()).data;
      if (result == null) throw const AppError.server();
      return PurchaseRequestPage(
        items: result.items.map(_summary).toList(),
        total: result.total,
        pageIndex: skip ~/ limit,
        pageSize: limit,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  Future<PurchaseRequest> _request(
    Future<Response<api.PurchaseRequestResponse>> Function() call,
  ) async {
    try {
      final result = (await call()).data;
      if (result == null) throw const AppError.server();
      return _toRequest(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

/// The wire carries quantities as decimal strings (`Quantity6`): the String
/// arm, key `0`, as everywhere else (`wire_value_setters.dart`).
void _setQuantity(api.Quantity6Builder builder, Decimal value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value.toString()});
}

/// An unknown wire value is a mapping error, never a guess.
PurchaseRequestStatus _status(api.RequestStatus status) {
  if (status == api.RequestStatus.draft) return PurchaseRequestStatus.draft;
  if (status == api.RequestStatus.submitted) {
    return PurchaseRequestStatus.submitted;
  }
  if (status == api.RequestStatus.approved) {
    return PurchaseRequestStatus.approved;
  }
  if (status == api.RequestStatus.cancelled) {
    return PurchaseRequestStatus.cancelled;
  }
  throw AppError.server(
    message: 'Unexpected purchase request status: ${status.name}',
  );
}

/// A `paid` status never occurs on a purchase order, so it is a mapping error
/// rather than a guess (as in spec 067).
InventoryDocumentStatus _orderStatus(api.DocumentStatus status) {
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

PurchaseRequestSummary _summary(api.PurchaseRequestSummary s) =>
    PurchaseRequestSummary(
      id: s.purchaseRequestId,
      serial: s.serial,
      status: _status(s.status),
      warehouseId: s.warehouse,
      facilityId: s.facility,
      date: s.date,
      comment: (s.comment ?? '').isEmpty ? null : s.comment,
      creatorId: s.creator,
      updaterId: s.updater,
      approverId: s.approver,
      approvalTime: s.approvalTime,
      lineCount: s.lineCount,
    );

/// The server's `warnings` are English text with no code and are dropped
/// (research R7).
PurchaseRequest _toRequest(api.PurchaseRequestResponse r) => PurchaseRequest(
  id: r.purchaseRequestId,
  serial: r.serial,
  status: _status(r.status),
  warehouseId: r.warehouse,
  facilityId: r.facility,
  date: r.date,
  comment: (r.comment ?? '').isEmpty ? null : r.comment,
  creatorId: r.creator,
  updaterId: r.updater,
  approverId: r.approver,
  approvalTime: r.approvalTime,
  lineCount: r.lineCount,
  lines: r.lines?.map(_line).toList() ?? [],
);

PurchaseRequestLine _line(api.PurchaseRequestLine l) => PurchaseRequestLine(
  id: l.purchaseRequestDetailId,
  productId: l.product,
  productCode: l.productCode ?? '',
  productName: l.productName ?? '',
  quantity: Decimal.parse(l.quantity),
  warehouseId: l.warehouse,
  toPurchase: l.toPurchase,
  minOrderQty: l.minOrderQty,
  purchaseOrderId: l.purchaseOrder,
  purchaseOrderStatus: l.purchaseOrderStatus == null
      ? null
      : _orderStatus(l.purchaseOrderStatus!),
);

BulkApproveOutcome _outcome(api.BulkApproveResult r) {
  final code = r.code;
  return BulkApproveOutcome(
    requestId: r.purchaseRequestId,
    approved: r.approved,
    problem: r.approved || code == null
        ? null
        : ApiProblem(
            // The wire name, not the generated member's Dart name.
            codeName:
                appSerializers.serializeWith(api.ErrorCode.serializer, code)!
                    as String,
            code: code,
            params: {
              for (final e
                  in r.params?.entries ??
                      const <MapEntry<String, JsonObject?>>[])
                e.key: e.value?.value,
            },
          ),
  );
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
