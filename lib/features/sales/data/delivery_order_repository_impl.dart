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
/// Two of this feature's assumptions did not survive contact with the live
/// API, and both are absorbed here rather than leaking into the delivery
/// step:
///
/// 1. **A destination cannot be created complete.** `DeliveryOrderCreate`
///    takes only `salesOrder`/`fulfillmentType`/`lines`; the header goes
///    through `PUT` ([create] does the pair, and rolls back on failure) —
///    [mbe-api#146](https://github.com/mictlanix/mbe-api/issues/146).
/// 2. **A delivery order does not say which sale it came from.** There is no
///    `sales_order` field and no such filter, so [listForSale] reconstructs
///    the link through line ids —
///    [mbe-api#147](https://github.com/mictlanix/mbe-api/issues/147).
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
    final created = await _create(
      salesOrder: salesOrder,
      fulfillmentType: fulfillmentType,
      lines: lines,
    );

    final needsHeader =
        shipTo != null || contact != null || date != null || comment != null;
    if (!needsHeader) return created;

    try {
      return await updateHeader(
        destinationId: created.id,
        shipTo: shipTo,
        contact: contact,
        date: date,
        comment: comment,
      );
    } on AppError {
      // The destination exists but points at the wrong address while holding
      // committed quantities. Leaving it would silently consume stock the
      // cashier believes is still available, so it is cancelled before the
      // failure is surfaced (FR-037). A failed rollback must not mask the
      // original error, which is the one the cashier can act on.
      try {
        await cancel(
          destinationId: created.id,
          reason: 'Rollback: destination header could not be set',
        );
      } on AppError {
        // Intentionally swallowed — see above.
      }
      rethrow;
    }
  }

  Future<Destination> _create({
    required int salesOrder,
    required FulfillmentType fulfillmentType,
    List<DestinationLineRequest>? lines,
  }) async {
    try {
      final response = await _api.createDeliveryOrderApiV1DeliveryOrdersPost(
        deliveryOrderCreate: api.DeliveryOrderCreate((b) {
          b
            ..salesOrder = salesOrder
            ..fulfillmentType = fulfillmentType.toApi();
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

  /// Reconstructs "the destinations of sale N" without an endpoint that can
  /// answer it (mbe-api#147): list the customer's recent delivery orders,
  /// fetch each one's detail (the summary carries no lines), and keep those
  /// whose lines reference one of [saleLineIds].
  ///
  /// Bounded by [searchLimit] rather than paging to exhaustion — a very
  /// active customer could otherwise cost an unbounded number of round
  /// trips. That bound is the caveat: a destination older than the most
  /// recent [searchLimit] for this customer will not be found. Acceptable
  /// only because the delivery step resumes a sale from the same shift, and
  /// it disappears entirely once #147 ships.
  @override
  Future<List<Destination>> listForSale({
    required int salesOrder,
    required int customer,
    required Set<int> saleLineIds,
    int searchLimit = 50,
  }) async {
    if (saleLineIds.isEmpty) return const [];
    try {
      final response = await _api.listDeliveryOrdersApiV1DeliveryOrdersGet(
        customer: customer,
        limit: searchLimit,
      );
      final summaries = response.data?.items ?? const <api.DeliveryOrderSummary>[];

      final destinations = <Destination>[];
      for (final summary in summaries) {
        final detail = await _api
            .getDeliveryOrderApiV1DeliveryOrdersDeliveryOrderIdGet(
              deliveryOrderId: summary.deliveryOrderId,
            );
        final result = detail.data;
        if (result == null) continue;
        final destination = Destination.fromResponse(result);
        final belongsToSale = destination.lines.any(
          (line) => saleLineIds.contains(line.salesOrderDetail),
        );
        if (belongsToSale) destinations.add(destination);
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
