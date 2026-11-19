import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/sales/data/wire_value_setters.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/domain/entities/pending_delivery.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_itinerary_repository.dart';

final deliveryItineraryRepositoryProvider =
    Provider<DeliveryItineraryRepository>((ref) {
      return DeliveryItineraryRepositoryImpl(ref.watch(dioProvider));
    });

/// `DeliveryItineraryRepository` backed by the generated
/// `DeliveryItinerariesApi` (specs 063 R2 and 075).
class DeliveryItineraryRepositoryImpl implements DeliveryItineraryRepository {
  DeliveryItineraryRepositoryImpl(Dio dio)
    : _api = api.DeliveryItinerariesApi(dio, appSerializers);

  final api.DeliveryItinerariesApi _api;

  @override
  Future<PendingDeliveriesResult> pendingDeliveries({
    required int skip,
    required int limit,
  }) async {
    try {
      final response = await _api
          .pendingDeliveriesApiV1DeliveryItinerariesDeliveriesGet(
            skip: skip,
            limit: limit,
          );
      final body = response.data;
      if (body == null) throw const AppError.server();
      final result = <PendingDeliveryPeriod, PendingDeliveryBucket>{};
      for (final bucket in body.buckets) {
        final period = PendingDeliveryPeriod.values
            .where((p) => p.key == bucket.key)
            .firstOrNull;
        if (period == null) continue;
        result[period] = (
          // The bucket's date is a calendar date (generated `Date`).
          date: bucket.date?.toDateTime(),
          total: bucket.total,
          items: bucket.items.map(PendingDeliveryLine.fromResponse).toList(),
        );
      }
      return result;
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<ItineraryPage> list({
    ItineraryStatus? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? vehicleId,
    int? operatorId,
    int? warehouseId,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _api.listItinerariesApiV1DeliveryItinerariesGet(
        // The generated parameters are calendar `Date`s, so no time of day
        // reaches the wire.
        dateFrom: dateFrom?.toDate(),
        dateTo: dateTo?.toDate(),
        vehicle: vehicleId,
        vehicleOperator: operatorId,
        warehouse: warehouseId,
        status: status?.toApi(),
        skip: skip,
        limit: limit,
      );
      final body = response.data;
      if (body == null) throw const AppError.server();
      return ItineraryPage(
        items: body.items.map(ItinerarySummary.fromResponse).toList(),
        total: body.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  @override
  Future<Itinerary> getById(int id) => _trip(
    () => _api.getItineraryApiV1DeliveryItinerariesItineraryIdGet(
      itineraryId: id,
    ),
  );

  @override
  Future<Itinerary> create({
    DateTime? date,
    int? vehicleId,
    int? operatorId,
    int? warehouseId,
    String? comment,
  }) => _trip(
    () => _api.createItineraryApiV1DeliveryItinerariesPost(
      itineraryCreate: api.ItineraryCreate((b) {
        b
          ..date = date?.toDate()
          ..vehicle = vehicleId
          ..vehicleOperator = operatorId
          ..warehouse = warehouseId
          ..comment = comment;
      }),
    ),
  );

  @override
  Future<Itinerary> updateHeader(
    int id, {
    DateTime? date,
    int? vehicleId,
    int? operatorId,
    String? comment,
  }) => _trip(
    () => _api.updateItineraryApiV1DeliveryItinerariesItineraryIdPut(
      itineraryId: id,
      // Only the fields that changed are set; the rest stay unset (null).
      itineraryUpdate: api.ItineraryUpdate((b) {
        if (date != null) b.date = date.toDate();
        if (vehicleId != null) b.vehicle = vehicleId;
        if (operatorId != null) b.vehicleOperator = operatorId;
        if (comment != null) b.comment = comment;
      }),
    ),
  );

  @override
  Future<Itinerary> cancel(int id) => _trip(
    () => _api.cancelItineraryApiV1DeliveryItinerariesItineraryIdCancelPost(
      itineraryId: id,
    ),
  );

  @override
  Future<Itinerary> depart(int id) => _trip(
    () => _api.departApiV1DeliveryItinerariesItineraryIdDepartPost(
      itineraryId: id,
    ),
  );

  @override
  Future<Itinerary> addStop(int id, {required int deliveryOrderId}) => _trip(
    () => _api.addStopApiV1DeliveryItinerariesItineraryIdStopsPost(
      itineraryId: id,
      // No comment is sent (contracts/repository.md).
      stopCreate: api.StopCreate((b) => b.deliveryOrder = deliveryOrderId),
    ),
  );

  @override
  Future<Itinerary> removeStop(int id, int stopId) => _trip(
    () => _api.removeStopApiV1DeliveryItinerariesItineraryIdStopsStopIdDelete(
      itineraryId: id,
      stopId: stopId,
    ),
  );

  @override
  Future<Itinerary> commitLine(
    int id,
    int stopId, {
    required int deliveryOrderLineId,
    required Decimal quantity,
  }) => _trip(
    () =>
        _api.commitLineApiV1DeliveryItinerariesItineraryIdStopsStopIdLinesPost(
          itineraryId: id,
          stopId: stopId,
          commitLineRequest: api.CommitLineRequest((b) {
            b.deliveryOrderDetail = deliveryOrderLineId;
            setQuantity(b.quantity, quantity.toString());
          }),
        ),
  );

  @override
  Future<Itinerary> commitWholeOrder(
    int id,
    int stopId, {
    required int deliveryOrderId,
  }) => _trip(
    () => _api
        .commitWholeOrderApiV1DeliveryItinerariesItineraryIdStopsStopIdLinesAllPost(
          itineraryId: id,
          stopId: stopId,
          commitOrderRequest: api.CommitOrderRequest(
            (b) => b.deliveryOrder = deliveryOrderId,
          ),
        ),
  );

  @override
  Future<Itinerary> adjustCommitment(
    int id,
    int stopId,
    int lineId, {
    required Decimal quantity,
  }) => _trip(
    () => _api
        .adjustCommitmentApiV1DeliveryItinerariesItineraryIdStopsStopIdLinesLineIdPut(
          itineraryId: id,
          stopId: stopId,
          lineId: lineId,
          commitLineUpdate: api.CommitLineUpdate(
            (b) => setQuantity1(b.quantity, quantity.toString()),
          ),
        ),
  );

  @override
  Future<Itinerary> releaseCommitment(int id, int stopId, int lineId) => _trip(
    () => _api
        .releaseCommitmentApiV1DeliveryItinerariesItineraryIdStopsStopIdLinesLineIdDelete(
          itineraryId: id,
          stopId: stopId,
          lineId: lineId,
        ),
  );

  @override
  Future<Itinerary> closeStop(int id, int stopId, StopClosure closure) => _trip(
    () => _api.closeStopApiV1DeliveryItinerariesItineraryIdStopsStopIdClosePost(
      itineraryId: id,
      stopId: stopId,
      receiverName: closure.receiverName,
      receiverIdShown: closure.receiverIdShown,
      lines: jsonEncode([
        for (final line in closure.lines)
          {
            'line': line.lineId,
            // Decimal strings, as the rest of the wire carries quantities.
            'delivered_quantity': line.delivered.toString(),
            'reason_code': line.reason?.value,
          },
      ]),
      image: MultipartFile.fromBytes(
        closure.proof.bytes,
        filename: closure.proof.filename,
      ),
    ),
  );

  /// Runs one call that answers with the trip, mapping failures to
  /// [AppError]. The response's `warnings` are dropped by the mapping (R4).
  Future<Itinerary> _trip(
    Future<Response<api.ItineraryResponse>> Function() call,
  ) async {
    try {
      final body = (await call()).data;
      if (body == null) throw const AppError.server();
      return Itinerary.fromResponse(body);
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }

  AppError _toAppError(DioException e) {
    final mapped = e.error;
    return mapped is AppError ? mapped : mapDioException(e);
  }
}
