import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:one_of/any_of.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';

final deliveryOrderRepositoryProvider = Provider<DeliveryOrderRepository>((ref) {
  return DeliveryOrderRepositoryImpl(ref.watch(dioProvider));
});

/// `DeliveryOrderRepository` backed by the generated `DeliveryOrdersApi`
/// (contracts/mbe-api-pos.md §2).
///
/// This implementation briefly carried two workarounds — a create-then-`PUT`
/// pair with cancel-on-failure rollback (mbe-api#146), and reconstructing
/// "the destinations of sale N" from line ids (mbe-api#147). Both shipped on
/// the backend, so both are gone: a destination is created complete in one
/// call, and the sale is a first-class filter.
class DeliveryOrderRepositoryImpl implements DeliveryOrderRepository {
  DeliveryOrderRepositoryImpl(Dio dio)
    : _api = api.DeliveryOrdersApi(dio, api.standardSerializers);

  final api.DeliveryOrdersApi _api;

  @override
  Future<Destination> create({
    required int salesOrder,
    required FulfillmentType fulfillmentType,
    int? shipTo,
    int? contact,
    DateTime? date,
    String? comment,
    List<DestinationLineRequest>? lines,
  }) async {
    try {
      final response = await _api.createDeliveryOrderApiV1DeliveryOrdersPost(
        deliveryOrderCreate: api.DeliveryOrderCreate((b) {
          b
            ..salesOrder = salesOrder
            ..fulfillmentType = fulfillmentType.toApi()
            ..shipTo = shipTo
            ..contact = contact
            ..date = date
            ..comment = comment;
          // Omitted claims everything the sale still owes — how the
          // counter-pickup remainder is recorded (FR-036).
          if (lines != null) {
            b.lines = ListBuilder<api.DeliveryOrderLineRequest>(
              lines.map(
                (line) => api.DeliveryOrderLineRequest((lb) {
                  lb.salesOrderDetail = line.salesOrderDetail;
                  _setQuantity1(lb.quantity, line.quantity);
                }),
              ),
            );
          }
        }),
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Destination.fromResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Destination> updateHeader({
    required int destinationId,
    int? shipTo,
    int? contact,
    DateTime? date,
    String? comment,
  }) async {
    try {
      final response = await _api
          .updateDeliveryOrderApiV1DeliveryOrdersDeliveryOrderIdPut(
            deliveryOrderId: destinationId,
            deliveryOrderUpdate: api.DeliveryOrderUpdate((b) {
              b
                ..shipTo = shipTo
                ..contact = contact
                ..date = date
                ..comment = comment;
            }),
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Destination.fromResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Destination> updateLine({
    required int destinationId,
    required int lineId,
    required String quantity,
  }) async {
    try {
      final response = await _api
          .updateDeliveryOrderLineApiV1DeliveryOrdersDeliveryOrderIdLinesLineIdPut(
            deliveryOrderId: destinationId,
            lineId: lineId,
            deliveryOrderLineUpdate: api.DeliveryOrderLineUpdate((b) {
              _setQuantity1(b.quantity, quantity);
            }),
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Destination.fromResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Destination> removeLine({
    required int destinationId,
    required int lineId,
  }) async {
    try {
      final response = await _api
          .deleteDeliveryOrderLineApiV1DeliveryOrdersDeliveryOrderIdLinesLineIdDelete(
            deliveryOrderId: destinationId,
            lineId: lineId,
          );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return Destination.fromResponse(result);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<void> cancel({
    required int destinationId,
    required String reason,
  }) async {
    try {
      await _api.cancelDeliveryOrderApiV1DeliveryOrdersDeliveryOrderIdCancelPost(
        deliveryOrderId: destinationId,
        reasonRequest: api.ReasonRequest((b) => b.reason = reason),
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<List<Destination>> listForSale({required int salesOrder}) async {
    try {
      final response = await _api.listDeliveryOrdersApiV1DeliveryOrdersGet(
        salesOrder: salesOrder,
        limit: 100,
      );
      final summaries = response.data?.items ?? const <api.DeliveryOrderSummary>[];

      // The summary carries no lines, and the distribution panel needs them,
      // so each is read back in full.
      final destinations = <Destination>[];
      for (final summary in summaries) {
        final detail = await _api
            .getDeliveryOrderApiV1DeliveryOrdersDeliveryOrderIdGet(
              deliveryOrderId: summary.deliveryOrderId,
            );
        final result = detail.data;
        if (result != null) destinations.add(Destination.fromResponse(result));
      }
      return destinations;
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}

/// `quantity` is `anyOf: [string, num]` on both the create-line and
/// update-line bodies — the generator gives both the same `Quantity1`
/// wrapper, so one setter serves both. Same String arm, key `0`, as
/// everywhere else (see `sales_order_repository_impl.dart`).
void _setQuantity1(api.Quantity1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}
