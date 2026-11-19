import 'package:decimal/decimal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/delivery_itinerary_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_itinerary_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itineraries_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itinerary_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_lookups.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_order_approval/delivery_order_approval_queue_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/for_delivery/pending_deliveries_controller.dart';

part 'delivery_itinerary_actions.g.dart';

/// Every write on an itinerary (spec 075 R10).
///
/// Each method answers the [AppError] the server refused with, or `null` when
/// it went through, rather than throwing: the dialog that asked shows the
/// refusal where the user is looking. A [NetworkError] means the request may
/// or may not have landed: the dialog shows it as an unknown result.
///
/// **On success** the trip the server returned becomes the screen's state (no
/// extra GET), and the list and the order lookups are refreshed. A write that
/// moves orders (departure, cancellation, closing a stop) also refreshes the
/// delivery-order list and detail, and the pending-deliveries queue, so those
/// screens never show a stale status or open quantity.
///
/// **On a refusal or an unknown result** the trip is invalidated, so the
/// screen reloads what the server holds.
///
/// Keep-alive because a write outlives the dialog that started it.
@Riverpod(keepAlive: true)
class DeliveryItineraryActions extends _$DeliveryItineraryActions {
  @override
  void build() {}

  /// `POST /delivery-itineraries`. Answers the new trip's id, or the error.
  Future<({int? id, AppError? error})> create({
    DateTime? date,
    int? vehicleId,
    int? operatorId,
    int? warehouseId,
    String? comment,
  }) async {
    try {
      final trip = await ref
          .read(deliveryItineraryRepositoryProvider)
          .create(
            date: date,
            vehicleId: vehicleId,
            operatorId: operatorId,
            warehouseId: warehouseId,
            comment: comment,
          );
      ref.invalidate(deliveryItinerariesListControllerProvider);
      return (id: trip.id, error: null);
    } on AppError catch (e) {
      if (e is NetworkError) {
        ref.invalidate(deliveryItinerariesListControllerProvider);
      }
      return (id: null, error: e);
    }
  }

  /// `PUT /delivery-itineraries/{id}`. A null field is left as it is.
  Future<AppError?> updateHeader(
    int id, {
    DateTime? date,
    int? vehicleId,
    int? operatorId,
    String? comment,
  }) => _run(
    id,
    (r) => r.updateHeader(
      id,
      date: date,
      vehicleId: vehicleId,
      operatorId: operatorId,
      comment: comment,
    ),
  );

  Future<AppError?> addStop(int id, {required int deliveryOrderId}) =>
      _run(id, (r) => r.addStop(id, deliveryOrderId: deliveryOrderId));

  Future<AppError?> removeStop(int id, int stopId) =>
      _run(id, (r) => r.removeStop(id, stopId), movesOpenQuantities: true);

  Future<AppError?> commitLine(
    int id,
    int stopId, {
    required int deliveryOrderLineId,
    required Decimal quantity,
  }) => _run(
    id,
    (r) => r.commitLine(
      id,
      stopId,
      deliveryOrderLineId: deliveryOrderLineId,
      quantity: quantity,
    ),
    movesOpenQuantities: true,
  );

  Future<AppError?> commitWholeOrder(
    int id,
    int stopId, {
    required int deliveryOrderId,
  }) => _run(
    id,
    (r) => r.commitWholeOrder(id, stopId, deliveryOrderId: deliveryOrderId),
    movesOpenQuantities: true,
  );

  Future<AppError?> adjust(
    int id,
    int stopId,
    int lineId, {
    required Decimal quantity,
  }) => _run(
    id,
    (r) => r.adjustCommitment(id, stopId, lineId, quantity: quantity),
    movesOpenQuantities: true,
  );

  Future<AppError?> release(int id, int stopId, int lineId) => _run(
    id,
    (r) => r.releaseCommitment(id, stopId, lineId),
    movesOpenQuantities: true,
  );

  /// `POST …/depart`: the orders go En tránsito.
  Future<AppError?> depart(int id) =>
      _run(id, (r) => r.depart(id), movesOrders: true);

  /// `POST …/cancel`: the loaded quantities are open again.
  Future<AppError?> cancel(int id) =>
      _run(id, (r) => r.cancel(id), movesOrders: true);

  /// `POST …/stops/{stopId}/close`: the stop's order is delivered, partially
  /// delivered or failed, and the trip closes itself after its last stop.
  Future<AppError?> closeStop(int id, int stopId, StopClosure closure) =>
      _run(id, (r) => r.closeStop(id, stopId, closure), movesOrders: true);

  /// The one write path. [movesOpenQuantities] refreshes the order lookups;
  /// [movesOrders] also refreshes the delivery-order and pending screens.
  Future<AppError?> _run(
    int id,
    Future<Itinerary> Function(DeliveryItineraryRepository repository) write, {
    bool movesOpenQuantities = false,
    bool movesOrders = false,
  }) async {
    try {
      final trip = await write(ref.read(deliveryItineraryRepositoryProvider));
      final detail = deliveryItineraryDetailControllerProvider(id);
      // Only a screen that is showing the trip takes it; otherwise there is
      // nothing to update, and reading the notifier would fetch it.
      if (ref.exists(detail)) {
        ref.read(detail.notifier).replace(trip);
      }
      ref.invalidate(deliveryItinerariesListControllerProvider);
      if (movesOpenQuantities || movesOrders) {
        ref.invalidate(itineraryOrderProvider);
      }
      if (movesOrders) {
        ref.invalidate(deliveryOrdersListControllerProvider);
        ref.invalidate(deliveryOrderDetailControllerProvider);
        ref.invalidate(deliveryOrderApprovalQueueControllerProvider);
        ref.invalidate(pendingDeliveriesControllerProvider);
      }
      return null;
    } on AppError catch (e) {
      ref.invalidate(deliveryItineraryDetailControllerProvider(id));
      if (e is NetworkError) {
        ref.invalidate(deliveryItinerariesListControllerProvider);
        ref.invalidate(itineraryOrderProvider);
      }
      return e;
    }
  }
}
