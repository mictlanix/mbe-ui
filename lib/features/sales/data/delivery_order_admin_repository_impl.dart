import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart'
    show setQuantity1;
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart'
    show wireDate, wireDateEnd;
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_admin_repository.dart';

final deliveryOrderAdminRepositoryProvider =
    Provider<DeliveryOrderAdminRepository>((ref) {
      return DeliveryOrderAdminRepositoryImpl(ref.watch(dioProvider));
    });

/// `DeliveryOrderAdminRepository` backed by the generated `DeliveryOrdersApi`
/// (spec 061 R2).
class DeliveryOrderAdminRepositoryImpl implements DeliveryOrderAdminRepository {
  DeliveryOrderAdminRepositoryImpl(Dio dio)
    : _api = api.DeliveryOrdersApi(dio, appSerializers);

  final api.DeliveryOrdersApi _api;

  @override
  Future<DeliveryOrderPage> list({
    DeliveryOrderStatus? status,
    int? customer,
    int? facility,
    FulfillmentType? type,
    int? salesOrder,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listDeliveryOrdersApiV1DeliveryOrdersGet(
        status: status == null ? null : _statusToApi(status),
        customer: customer,
        facility: facility,
        fulfillmentType: type?.toApi(),
        salesOrder: salesOrder,
        dateFrom: dateFrom == null ? null : wireDate(dateFrom),
        dateTo: dateTo == null ? null : wireDateEnd(dateTo),
        // The generated default is `false`, which would put `mine=false` on
        // the wire; this list never filters by owner.
        mine: null,
        search: search,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return DeliveryOrderPage(
        items: result.items.map(DeliveryOrderSummary.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<DeliveryOrder> getById(int id) => _order(
    () => _api.getDeliveryOrderApiV1DeliveryOrdersDeliveryOrderIdGet(
      deliveryOrderId: id,
    ),
  );

  @override
  Future<List<DeliveryOrderEvent>> events(int id) async {
    try {
      final response = await _api
          .listDeliveryOrderEventsApiV1DeliveryOrdersDeliveryOrderIdEventsGet(
            deliveryOrderId: id,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return result.map(DeliveryOrderEvent.fromResponse).toList();
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<ProofOfDelivery> proof(int id) async {
    try {
      final response = await _api
          .getProofApiV1DeliveryOrdersDeliveryOrderIdProofGet(
            deliveryOrderId: id,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return ProofOfDelivery.fromResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Uint8List> proofImage(int id) async {
    try {
      final response = await _api
          .getProofImageApiV1DeliveryOrdersDeliveryOrderIdProofImageGet(
            deliveryOrderId: id,
          );
      final bytes = response.data;
      if (bytes == null) throw const AppError.server();
      // A 200 that is not a PNG (an HTML login page from a proxy, an empty
      // body) must never reach an image decoder.
      if (!_looksLikePng(bytes)) throw const AppError.server();
      return bytes;
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<DeliveryOrder> updateHeader({
    required int id,
    int? priority,
    int? shipTo,
    int? contact,
    DateTime? date,
    String? comment,
  }) => _order(
    () => _api.updateDeliveryOrderApiV1DeliveryOrdersDeliveryOrderIdPut(
      deliveryOrderId: id,
      deliveryOrderUpdate: api.DeliveryOrderUpdate((b) {
        b
          ..priority = priority
          ..shipTo = shipTo
          ..contact = contact
          ..date = date == null ? null : wireDate(date)
          ..comment = comment;
      }),
    ),
  );

  @override
  Future<DeliveryOrder> addLine({
    required int id,
    required int salesOrderDetail,
    required String quantity,
  }) => _order(
    () => _api.addDeliveryOrderLineApiV1DeliveryOrdersDeliveryOrderIdLinesPost(
      deliveryOrderId: id,
      deliveryOrderLineRequest: api.DeliveryOrderLineRequest((b) {
        b.salesOrderDetail = salesOrderDetail;
        setQuantity1(b.quantity, quantity);
      }),
    ),
  );

  @override
  Future<DeliveryOrder> updateLine({
    required int id,
    required int lineId,
    required String quantity,
  }) => _order(
    () => _api
        .updateDeliveryOrderLineApiV1DeliveryOrdersDeliveryOrderIdLinesLineIdPut(
          deliveryOrderId: id,
          lineId: lineId,
          deliveryOrderLineUpdate: api.DeliveryOrderLineUpdate((b) {
            setQuantity1(b.quantity, quantity);
          }),
        ),
  );

  @override
  Future<DeliveryOrder> removeLine({
    required int id,
    required int lineId,
  }) => _order(
    () => _api
        .deleteDeliveryOrderLineApiV1DeliveryOrdersDeliveryOrderIdLinesLineIdDelete(
          deliveryOrderId: id,
          lineId: lineId,
        ),
  );

  @override
  Future<DeliveryOrder> confirm(int id) => _order(
    () =>
        _api.confirmDeliveryOrderApiV1DeliveryOrdersDeliveryOrderIdConfirmPost(
          deliveryOrderId: id,
        ),
  );

  @override
  Future<DeliveryOrder> cancel({required int id, required String reason}) =>
      _order(
        () => _api
            .cancelDeliveryOrderApiV1DeliveryOrdersDeliveryOrderIdCancelPost(
              deliveryOrderId: id,
              reasonRequest: api.ReasonRequest((b) => b.reason = reason),
            ),
      );

  @override
  Future<DeliveryOrderPage> approvalQueue({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api
          .listApprovalQueueApiV1DeliveryOrdersApprovalGet(
            skip: skip,
            limit: limit,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return DeliveryOrderPage(
        items: result.items.map(DeliveryOrderSummary.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<DeliveryOrder> approve(int id) => _order(
    () => _api
        .approveDeliveryOrderApiV1DeliveryOrdersApprovalDeliveryOrderIdApprovePost(
          deliveryOrderId: id,
        ),
  );

  @override
  Future<DeliveryOrder> reject({
    required int id,
    required String reason,
  }) => _order(
    () => _api
        .rejectDeliveryOrderApiV1DeliveryOrdersApprovalDeliveryOrderIdRejectPost(
          deliveryOrderId: id,
          reasonRequest: api.ReasonRequest((b) => b.reason = reason),
        ),
  );

  @override
  Future<DeliveryOrder> requeue(int id) => _order(
    () =>
        _api.requeueDeliveryOrderApiV1DeliveryOrdersDeliveryOrderIdRequeuePost(
          deliveryOrderId: id,
        ),
  );

  @override
  Future<DeliveryOrder> markReadyForPickup(int id) => _order(
    () => _api
        .markReadyForPickupApiV1DeliveryOrdersDeliveryOrderIdReadyForPickupPost(
          deliveryOrderId: id,
        ),
  );

  @override
  Future<DeliveryOrder> confirmPickup({
    required int id,
    required String receiverName,
    required String receiverIdShown,
    required Uint8List bytes,
    required String filename,
  }) => _order(
    () => _api.confirmPickupApiV1DeliveryOrdersDeliveryOrderIdPickupPost(
      deliveryOrderId: id,
      receiverName: receiverName,
      receiverIdShown: receiverIdShown,
      image: MultipartFile.fromBytes(bytes, filename: filename),
    ),
  );

  /// Runs one call that answers with the order, mapping failures to
  /// [AppError].
  Future<DeliveryOrder> _order(
    Future<Response<api.DeliveryOrderResponse>> Function() call,
  ) async {
    try {
      final result = (await call()).data;
      if (result == null) throw const AppError.server();
      return DeliveryOrder.fromResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

api.DeliveryOrderStatus _statusToApi(DeliveryOrderStatus status) => api
    .DeliveryOrderStatus
    .values
    .firstWhere((v) => v.name == 'number${status.value}');

bool _looksLikePng(Uint8List bytes) {
  const signature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  if (bytes.length < signature.length) return false;
  for (var i = 0; i < signature.length; i++) {
    if (bytes[i] != signature[i]) return false;
  }
  return true;
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
