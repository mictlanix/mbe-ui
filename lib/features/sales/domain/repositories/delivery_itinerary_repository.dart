import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/domain/entities/pending_delivery.dart';

/// Delivery itineraries, over the generated `DeliveryItinerariesApi`. Spec 063
/// added the pending-deliveries queue; spec 075 (mbe-roadmap#41) adds the trip
/// screens. Each write returns the full [Itinerary] the server sends back, so
/// callers never need an extra GET.
abstract class DeliveryItineraryRepository {
  /// `GET /delivery-itineraries/deliveries?skip=&limit=`. The server pages
  /// every bucket by the same `skip`/`limit` and offers no search or facility
  /// parameter, so none is sent.
  Future<PendingDeliveriesResult> pendingDeliveries({
    required int skip,
    required int limit,
  });

  /// `GET /delivery-itineraries`. [status] is one value, or null for all.
  Future<ItineraryPage> list({
    ItineraryStatus? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? vehicleId,
    int? operatorId,
    int? warehouseId,
    int skip = 0,
    int limit = 20,
  });

  Future<Itinerary> getById(int id);

  /// `POST /delivery-itineraries`. Everything is optional; a null warehouse
  /// takes the point of sale's.
  Future<Itinerary> create({
    DateTime? date,
    int? vehicleId,
    int? operatorId,
    int? warehouseId,
    String? comment,
  });

  /// `PUT /delivery-itineraries/{id}`. Null leaves a field unchanged; the
  /// server can't clear one. The dispatch warehouse isn't updatable.
  Future<Itinerary> updateHeader(
    int id, {
    DateTime? date,
    int? vehicleId,
    int? operatorId,
    String? comment,
  });

  Future<Itinerary> cancel(int id);

  Future<Itinerary> depart(int id);

  Future<Itinerary> addStop(int id, {required int deliveryOrderId});

  Future<Itinerary> removeStop(int id, int stopId);

  /// The quantity is always sent.
  Future<Itinerary> commitLine(
    int id,
    int stopId, {
    required int deliveryOrderLineId,
    required Decimal quantity,
  });

  Future<Itinerary> commitWholeOrder(
    int id,
    int stopId, {
    required int deliveryOrderId,
  });

  Future<Itinerary> adjustCommitment(
    int id,
    int stopId,
    int lineId, {
    required Decimal quantity,
  });

  Future<Itinerary> releaseCommitment(int id, int stopId, int lineId);

  /// `POST …/stops/{stopId}/close`, multipart: the receiver, the `lines` JSON
  /// and the proof image.
  Future<Itinerary> closeStop(int id, int stopId, StopClosure closure);
}
