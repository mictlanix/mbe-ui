import 'package:mbe_ui/features/sales/domain/entities/pending_delivery.dart';

/// Delivery itineraries (spec 063 R2), over the generated
/// `DeliveryItinerariesApi`. It starts with the pending-deliveries queue; the
/// itinerary screens (mbe-roadmap#41) extend it.
abstract class DeliveryItineraryRepository {
  /// `GET /delivery-itineraries/deliveries?skip=&limit=`. The server pages
  /// every bucket by the same `skip`/`limit` and offers no search or facility
  /// parameter, so none is sent.
  Future<PendingDeliveriesResult> pendingDeliveries({
    required int skip,
    required int limit,
  });
}
